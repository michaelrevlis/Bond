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

class LoginViewController: UIViewController, LoginManagerDelegate {

    
    @IBOutlet weak var loginDescription: UILabel!
    @IBOutlet weak var button1: UIButton!
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingSpinnerActive(false)
        self.hideLoginButtons(false)
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { (auth, user) in
            
            if user != nil {
                
                NavigationLogo.shared.setup()
                
                LoginManager.shared.delegate = self
                
            } else {
                
                self.setup()
            }
            
        }
        
    }
    
}



extension LoginViewController {
    
    @IBAction func facebookPressed(sender: AnyObject) {
        
        FIRAnalytics.logEventWithName("loginWithFB", parameters: nil)
        
        loginWithFacebook()
        
        self.loadingSpinnerActive(true)
        self.hideLoginButtons(true)
        
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
    
    
    
    private func loadingSpinnerActive(active: Bool) {
        
        if active == true {

            loadingSpinner.hidden = false
            loadingSpinner.startAnimating()

        } else {
        
            loadingSpinner.hidden = true
            loadingSpinner.stopAnimating()
        }
    }
    
    
    
    private func setup() {
        
        facebookButton.setTitle("", forState: .Normal) // use setTitle to set button's title, don't use titleLabel
       facebookButton.layer.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0).CGColor
    }
    
    
    func manager(manager: LoginManager, userDidLogin: Bool) {
        if userDidLogin == true {
            
            UserDefaultManager().downloadCurrentUserInfo()
            print("download user info")
            
            switchViewController(from: self, to: "TabBarController")
            
            self.hideLoginButtons(false)
            self.loadingSpinnerActive(false)
            
        } else {
            print("user not login yet")
        }
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
                
                // using fb access token to sign in to firebase
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                
                FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                    
                    LoginManager.shared.userLogin()
                    
                }
            }
        })
        
    }
}

//    private func getFBUserData() {
//        
//        if (FBSDKAccessToken.currentAccessToken() != nil) {
//            let parameters = ["fields": "name, id, picture.type(large), email, link"]
//            
//            FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler({ (connection, result, error) -> Void in
//                
//                if let error = error {
//                    print("FB user data access error: \(error)")
//                    return
//                }
//
//                guard let  result = result as? NSDictionary,
//                                name = result["name"] as? String,
//                                id = result["id"] as? String,
//                                email = result["email"] as? String,
//                                link = result["link"] as? String,
//                                picture = result["picture"] as? NSDictionary,
//                                data = picture["data"] as? NSDictionary,
//                                url = data["url"] as? String
//                    else {
//                        let error = error
//                        print("Error: \(error)")
//                        return
//                }
//                print("FB user info get")
//                
////                CoreDataModel().deleteFBUser()
//                self.cleanUserInfo()
//                
//                // get user's firebase UID
//                guard let uid = FIRAuth.auth()?.currentUser?.uid else { fatalError() }
//                
//                // convert those data's format so we can save it into core data
//                let userInfo: [String: AnyObject] =  [ "authID": uid, "fbID": id, "name": name, "email": email, "fbProfileLink": link, "pictureUrl": url ]
//                
//                let currentLoginUserFBID = userInfo["fbID"] as! String
//                
//                self.checkIfUserExist(currentLoginUserFBID, completion: { (exist, user_node) in
//                
//                    // an existed user
//                    if exist == true {
//                        
//                        self.downloadUserInfo(currentLoginUserFBID)
//                        
//                    // a new user
//                    } else {
//                        
//                        self.uploadUserInfo(userInfo)
//                    }
//                    
//                })
//            })
//        }
//    }
//}


    
    
//    typealias CheckIfUserExist = (exist: Bool, user_node: String) -> Void
//    
//    private func checkIfUserExist(fbID: String, completion: CheckIfUserExist) {
//        
//        var exist = false
//        var existedUser_node = String()
//
//        FirebaseDatabaseRef.shared.child("users").queryOrderedByChild("fbID").queryEqualToValue(fbID).observeEventType(.Value, withBlock: { snapshot in
//            
//            // if a user exist, return it's node
//            if snapshot.exists() {
//                
//                print("user exists")
//                
//                guard let  result = snapshot.value as? NSDictionary else { fatalError() }
//                let resultKey = result.allKeys
//                existedUser_node = resultKey[0] as! String
//                
//                exist = true
//                completion(exist: exist, user_node: existedUser_node)
//                
//            } else {
//                
//                completion(exist: exist, user_node: existedUser_node)
//                
//            }
//        })
//        
//    }
//    
//    
//    
//    private func downloadUserInfo(currentLoginUserFBID: String) {
//        
//        FirebaseDatabaseRef.shared.child("users").queryOrderedByChild("fbID").queryEqualToValue(currentLoginUserFBID).observeEventType(.ChildAdded, withBlock: { snapshot in
//            
//            guard let  user = snapshot.value as? NSDictionary,
//                            email = user["email"] as? String,
//                            authID = user["authID"] as? String,
//                            name = user["name"] as? String,
//                            pictureUrl = user["pictureUrl"] as? String,
//                            fbID = user["fbID"] as? String
//                else {
//                    print("error when download user info")
//                    return
//            }
//            
//            let userNode = snapshot.ref.key
//            
//            let downloadUserInfo: [String: String] = ["authID": authID, "email": email, "fbID": fbID, "name": name, "pictureUrl": pictureUrl, "userNode": userNode]
//            print("download login user info from firebase")
//            
//            self.setupUserInfo(downloadUserInfo)
//            print("setup userinfo")
//        })
//    }
//    
//    
//    
//    
//    private func uploadUserInfo(tempUserInfo: [String: AnyObject]) {
//        
//        let fbUserInfoSentRef = FirebaseDatabaseRef.shared.child("users").childByAutoId()  //在database產生一個user uid。註：不用auth()的uid是因為未來可能會讓user用多種方式登入，此時一個user就會有多個auth的uid
//        var uploadUserInfo = tempUserInfo
//        
//        let newUser_node = fbUserInfoSentRef.key
//        
//        uploadUserInfo["userNode"] = newUser_node
//
//        fbUserInfoSentRef.setValue(uploadUserInfo)
//        print("upload FB user info to firebase")
//
//        self.setupUserInfo(uploadUserInfo)
//        print("setup userinfo")
//    }
//    
//    
//    // saving data into core data: FBUser
//    private func setupUserInfo(userInfo: [String: AnyObject]) {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        
//        let managedContext = appDelegate.managedObjectContext
//        
//        let entity = NSEntityDescription.entityForName("FBUser", inManagedObjectContext: managedContext)
//        
//        let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
//        
//        for (key, value) in userInfo {
//            user.setValue(value, forKey: key)
//        }
//        
//        do {
//            try managedContext.save()
//            print("saving user info in core data")
//            
//            CurrentUserManager.shared.getUserID()
//            CurrentUserManager.shared.getUserName()
//            CurrentUserManager.shared.getUserPicture()
//            MailboxManager.shared.downloadReceivedPostcards()
//        } catch {
//            print("Error in saving userInfo into core data")
//        }
//////////////////////////////////////////////////////////////////////////////////////////////////////
////// request core data we just saved to check if we do save it/////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//        let request = NSFetchRequest(entityName: "FBUser")
//        do {
//            let results = try managedContext.executeFetchRequest(request) as! [FBUser]
//            
//            let c = results.count
//            print("FBUser number: \(c)")
//            print("\(results[0])")
//            
//        }catch{
//            fatalError("Failed to fetch data: \(error)")
//        }
//////////////////////////////////////////////////////////////////////////////////////////////////////
//    }













