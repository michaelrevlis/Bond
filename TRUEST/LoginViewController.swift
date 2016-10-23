//
//  ViewController.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/9/26.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import CoreData

class LoginViewController: UIViewController {

    
    @IBOutlet weak var loginDescription: UILabel!
    @IBOutlet weak var button1: UIButton!
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingSpinner.hidden = true
        
        self.hideLoginButtons(true)
        
/////////////// 判斷user是否登入過，給予不同的開場畫面 ///////////
        FIRAuth.auth()?.addAuthStateDidChangeListener { (auth, user) in
            if user != nil {
                // user is signed in
                NavigationLogo.shared.setup()
                
                CurrentUserInfoManager().loadCurrentUserInfo()
                
                // move user to homeViewController
                switchViewController(from: self, to: "TabBarController") // ContactsViewController  //
                
            } else {
                // user is not signed in
                // setup UIs for LoginViewController
                self.hideLoginButtons(false)
                self.setup()
            }
        }
    }
    
}

extension LoginViewController {
    
    private func hideLoginButtons(decision: Bool) {
          loginDescription.hidden = decision
          button1.hidden = decision
          facebookButton.hidden = decision
    
          button3.hidden = decision
          button4.hidden = decision
     }
    
    
    
    private func setup() {
        
        facebookButton.setTitle("", forState: .Normal) // use setTitle to set button's title, don't use titleLabel
       facebookButton.layer.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0).CGColor
        
    }
}


extension LoginViewController {
    // when clicking Facebook login button
    @IBAction func facebookPressed(sender: AnyObject) {
        
        loginWithFacebook()
        
    }
    
}


extension LoginViewController {
    
    private func loginWithFacebook() {

        self.loadingSpinner.startAnimating()
        
        // get Facebook login authentication
        let fbLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logInWithReadPermissions(["public_profile", "email", "user_friends"], handler: { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            
            if let error = error {
                print("FB login error: \(error)")
                self.hideLoginButtons(false)
                self.loadingSpinner.stopAnimating()
                return
            }
            
            if result.isCancelled {
                print("Cancle button pressed")
                self.hideLoginButtons(false)
                self.loadingSpinner.stopAnimating()
            } else {
                
                // permission get
                print("FB logged in")
                
                // using fb access token to sign in to firebase
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("FB access token get")
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                
                FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                    print("sign in firebase with FB")
                    self.getFBUserData()
                }

                self.dismissViewControllerAnimated(true, completion: nil)
                
                switchViewController(from: self, to: "TabBarController")
            }
        })
        
    }
    
    private func getFBUserData() {
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            let parameters = ["fields": "name, id, picture.type(large), email, link"]
            
            FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler({ (connection, result, error) -> Void in
                
                if let error = error {
                    print("FB user data access error: \(error)")
                    return
                }

                guard let  result = result as? NSDictionary,
                                name = result["name"] as? String,
                                id = result["id"] as? String,
                                email = result["email"] as? String,
                                link = result["link"] as? String,
                                picture = result["picture"] as? NSDictionary,
                                data = picture["data"] as? NSDictionary,
                                url = data["url"] as? String
                    else {
                        let error = error
                        print("Error: \(error)")
                        return
                }
                print("FB user info get")
                
                // TODO: try to orginaze all the info data download in a specific thread in background
//                CoreDataModel().deleteFBUser()
                self.cleanUserInfo()
                
                // get user's firebase UID
                guard let uid = FIRAuth.auth()?.currentUser?.uid else { fatalError() }
                
                // convert those data's format so we can save it into core data
                let userInfo: [String: AnyObject] =  [ "authID": uid, "fbID": id, "name": name, "email": email, "fbProfileLink": link, "pictureUrl": url ]
                
//// method: save into userDefaults
//let userDefaults_fbLoginData = NSUserDefaults.standardUserDefaults()
//userDefaults_fbLoginData.setObject(name, forKey: "FB_userName")
//userDefaults_fbLoginData.setObject(id, forKey: "FB_userID")
//userDefaults_fbLoginData.setObject(email, forKey: "FB_userEmail")
//userDefaults_fbLoginData.setObject(link, forKey: "FB_userLink")
//userDefaults_fbLoginData.setObject(url, forKey: "FB_userPictureURL")
                
                let currentLoginUserFBID = userInfo["fbID"] as! String
                
                self.checkIfUserExist(currentLoginUserFBID, completion: { (exist, user_node) in
                
                    // an existed user
                    if exist == true {
                        
                        self.downloadUserInfo(currentLoginUserFBID)
                        
                    // a new user
                    } else {
                        
                        self.uploadUserInfo(userInfo)
                    }
                    
                })
            })
        }
    }
}

extension UIViewController {
    
    // delete all data in FBUser. because it is allowed only one user at the same time
    private func cleanUserInfo() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let request = NSFetchRequest(entityName: "FBUser")
        
        do {
            let results = try managedContext.executeFetchRequest(request) as! [FBUser]
            
            for result in results {
                managedContext.deleteObject(result)
            }
        }catch {
            print("Error in deleting core data: FBUser")
        }
        
        do {
            try managedContext.save()
            print("deleting user info in core data")
        } catch {
            print("Error in updating FBUser deletion")
        }
    }
    
    
    typealias CheckIfUserExist = (exist: Bool, user_node: String) -> Void
    
    private func checkIfUserExist(fbID: String, completion: CheckIfUserExist) {
        
        var exist = false
        var existedUser_node = String()

        FirebaseDatabaseRef.shared.child("users").queryOrderedByChild("fbID").queryEqualToValue(fbID).observeEventType(.Value, withBlock: { snapshot in
            
            // if a user exist, return it's node
            if snapshot.exists() {
                
                print("user exists")
                
                guard let  result = snapshot.value as? NSDictionary else { fatalError() }
                let resultKey = result.allKeys
                existedUser_node = resultKey[0] as! String
                
                exist = true
                completion(exist: exist, user_node: existedUser_node)
                
            } else {
                
                completion(exist: exist, user_node: existedUser_node)
                
            }
        })
        
    }
    
    
    
    private func downloadUserInfo(currentLoginUserFBID: String) {
        
        FirebaseDatabaseRef.shared.child("users").queryOrderedByChild("fbID").queryEqualToValue(currentLoginUserFBID).observeEventType(.ChildAdded, withBlock: { snapshot in
            
            guard let  user = snapshot.value as? NSDictionary,
                            email = user["email"] as? String,
                            authID = user["authID"] as? String,
                            name = user["name"] as? String,
                            pictureUrl = user["pictureUrl"] as? String,
                            fbID = user["fbID"] as? String
                else {
                    print("error when download user info")
                    return
            }
            
            let userNode = snapshot.ref.key
            
            let downloadUserInfo: [String: String] = ["authID": authID, "email": email, "fbID": fbID, "name": name, "pictureUrl": pictureUrl, "userNode": userNode]
            print("download login user info from firebase")
            
            self.setupUserInfo(downloadUserInfo)
            print("setup userinfo")
        })
    }
    
    
    
    
    private func uploadUserInfo(tempUserInfo: [String: AnyObject]) {
        
        let fbUserInfoSentRef = FirebaseDatabaseRef.shared.child("users").childByAutoId()  //在database產生一個user uid。註：不用auth()的uid是因為未來可能會讓user用多種方式登入，此時一個user就會有多個auth的uid
        var uploadUserInfo = tempUserInfo
        
        let newUser_node = fbUserInfoSentRef.key
        
        uploadUserInfo["userNode"] = newUser_node

        fbUserInfoSentRef.setValue(uploadUserInfo)
        print("upload FB user info to firebase")

        self.setupUserInfo(uploadUserInfo)
        print("setup userinfo")
    }
    
    
    // saving data into core data: FBUser
    private func setupUserInfo(userInfo: [String: AnyObject]) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("FBUser", inManagedObjectContext: managedContext)
        
        let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        for (key, value) in userInfo {
            user.setValue(value, forKey: key)
        }
        
        do {
            try managedContext.save()
            print("saving user info in core data")
            
            CurrentUserManager.shared.getUserID()
            CurrentUserManager.shared.getUserName()
            CurrentUserManager.shared.getUserPicture()
            MailboxManager.shared.downloadReceivedPostcards()
        } catch {
            print("Error in saving userInfo into core data")
        }
////////////////////////////////////////////////////////////////////////////////////////////////////
//// request core data we just saved to check if we do save it/////
////////////////////////////////////////////////////////////////////////////////////////////////////
        let request = NSFetchRequest(entityName: "FBUser")
        do {
            let results = try managedContext.executeFetchRequest(request) as! [FBUser]
            
            let c = results.count
            print("FBUser number: \(c)")
            print("\(results[0])")
            
        }catch{
            fatalError("Failed to fetch data: \(error)")
        }
////////////////////////////////////////////////////////////////////////////////////////////////////
    }

    

}













