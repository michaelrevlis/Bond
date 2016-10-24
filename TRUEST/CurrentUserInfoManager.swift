//
//  CurrentUserInfoManager.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/23.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import CoreData


class CurrentUserInfoManager {
    
    static let shared = CurrentUserInfoManager()
    
    private(set) var currentUserNode = String()
    private(set) var currentUserName = String()
    private(set) var currentUserPictureUrl = String()
    
    private let currentUserAuth = FIRAuth.auth()!.currentUser!.uid
    
    func downloadCurrentUserInfo() {
        
        FirebaseDatabaseRef.shared.child("users").queryOrderedByChild("authID").queryEqualToValue(currentUserAuth).observeEventType(.ChildAdded, withBlock: { snapshot in
            
            guard let  result = snapshot.value as? NSDictionary,
                            email = result["email"] as? String,
                            fbID = result["fbID"] as? String,
                            name = result["name"] as? String,
                            pictureUrl = result["pictureUrl"] as? String,
                            authID = result["authID"] as? String,
                            userNode = result["userNode"] as? String
                else { fatalError() }
            
            let userDefaults_currentUserInfo = NSUserDefaults.standardUserDefaults()
                 userDefaults_currentUserInfo.setObject(name, forKey: "user_name")
                 userDefaults_currentUserInfo.setObject(fbID, forKey: "user_fbID")
                 userDefaults_currentUserInfo.setObject(email, forKey: "user_email")
                 userDefaults_currentUserInfo.setObject(userNode, forKey: "user_userNode")
                 userDefaults_currentUserInfo.setObject(pictureUrl, forKey: "user_pictureUrl")
                 userDefaults_currentUserInfo.setObject(authID, forKey: "user_authID")

            self.currentUserNode = userDefaults_currentUserInfo.stringForKey("user_userNode") as String!
            
            self.currentUserName = userDefaults_currentUserInfo.stringForKey("user_name") as String!
            
            self.currentUserPictureUrl = userDefaults_currentUserInfo.stringForKey("user_pictureUrl") as String!
            
        })
        
    }
}



