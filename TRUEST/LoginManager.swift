//
//  LoginManager.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/24.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseCrash

protocol LoginManagerDelegate: class {
    func manager(manager: LoginManager, userDidLogin: Bool)
}


class LoginManager {
    
    static let shared = LoginManager()
    
    weak var delegate: LoginManagerDelegate?
    
    func userLogin() {
        
        getFacebookUserInfo { (result, id) in
         
            self.checkIfUserExist(id, completion: { (exist, user_node) in
                
                if exist == false {
                    
                    self.uploadUserInfoToFirebase(result)
                    
                } else {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.delegate?.manager(self, userDidLogin: true)
                        
                    })
                }
                
            })
            
        }
    }
    
}

extension LoginManager {
    
    typealias getFacebookUserInfoCompletion = (result: [String: String], id: String) -> Void
    
    private func getFacebookUserInfo(completion: getFacebookUserInfoCompletion) {
        
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
                
                let fbUserInfo: [String: String] = ["fbID": id, "name": name, "email": email, "fbProfileLink": link, "pictureUrl": url]
                
                completion(result: fbUserInfo, id: id)
                
            })
        }
    }
    
    
    
    typealias CheckIfUserExistCompletion = (exist: Bool, user_node: String) -> Void
    
    private func checkIfUserExist(fbID: String, completion: CheckIfUserExistCompletion) {
        
        var exist = false
        var existedUser_node = String()
        
        FirebaseDatabaseRef.shared.child("users").queryOrderedByChild("fbID").queryEqualToValue(fbID).observeEventType(.Value, withBlock: { snapshot in
            
            if snapshot.exists() {
                
                guard let  result = snapshot.value as? NSDictionary
                    else {
                        FIRCrashMessage("Fail to open data from server")
                        return
                }
                
                let resultKey = result.allKeys
                existedUser_node = resultKey[0] as! String
                
                exist = true
                
                completion(exist: exist, user_node: existedUser_node)
                
            } else {
                
                completion(exist: exist, user_node: existedUser_node)
                
            }
        })
        
    }
    
    
    
    private func uploadUserInfoToFirebase(tempUserInfo: [String: AnyObject]) {
        
        let fbUserInfoSentRef = FirebaseDatabaseRef.shared.child("users").childByAutoId()  //在database產生一個user uid。註：不用auth()的uid是因為未來可能會讓user用多種方式登入，此時一個user就會有多個auth的uid
        var uploadUserInfo = tempUserInfo
        
        let newUser_node = fbUserInfoSentRef.key
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        uploadUserInfo["userNode"] = newUser_node
        
        uploadUserInfo["authID"] = uid
        
        fbUserInfoSentRef.setValue(uploadUserInfo)
        
        dispatch_async(dispatch_get_main_queue(), {

            self.delegate?.manager(self, userDidLogin: true)
            
        })
        
    }

    
}