//
//  SettingManager.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/24.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase


class SettingManager {
    
    func cleanUpUserData() {
     
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user_name")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user_userNode")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user_fbID")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user_email")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user_pictureUrl")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user_authID")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("currentPasscode")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("loginMethod")
        
        NSUserDefaults.standardUserDefaults().synchronize()

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let requestUser = NSFetchRequest(entityName: "User")
        
        let requestPostcard = NSFetchRequest(entityName: "Postcard")
        
        let requestReceivedPostcard = NSFetchRequest(entityName: "ReceivedPostcard")
        
        do {
            
            let resultsUser = try managedContext.executeFetchRequest(requestUser) as! [User]
            
            for result in resultsUser {
                managedContext.deleteObject(result)
            }
            
            let resultsPostcard = try managedContext.executeFetchRequest(requestPostcard) as! [Postcard]
            
            for result in resultsPostcard {
                managedContext.deleteObject(result)
            }
            
            let resultsReceivedPostcard = try managedContext.executeFetchRequest(requestReceivedPostcard) as! [ReceivedPostcard]
            
            for result in resultsReceivedPostcard {
                managedContext.deleteObject(result)
            }
            
        }catch {
            FIRCrashMessage("Error in deleting core data")
        }
        
        do {
            try managedContext.save()
            FIRAnalytics.logEventWithName("Core data has been deleted", parameters: nil)
        } catch {
            FIRCrashMessage("Error in updating core data deletion")
        }
        
        
        ContactsManager.shared.cleanupFriendlist()
        
    }

    
    
    func updateUserName(newName: String) {
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        
        userDefault.setObject(newName, forKey: "user_Name")
        
        userDefault.synchronize()
        
        CurrentUserInfoManager.shared.currentUserInfoInit()
        
        FirebaseDatabaseRef.shared.child("users").child(CurrentUserInfoManager.shared.currentUserNode).updateChildValues(["name": newName])
        
        // TODO: showing user a block that displayname has been changed successfully
        
    }
    
    
    
    func updateUserPicture(newPicture: NSData) {
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpg"
        
        FirebaseStorageRef.shared.child(CurrentUserInfoManager.shared.currentUserNode).putData(newPicture, metadata: metadata) { (metadata, error) in
            
            if let error = error {
                FIRCrashMessage("Error upload user's profile picture: \(error)")
                return
            } else {
                
                let downloadUrl = metadata!.downloadURL()!.absoluteString
                
                FirebaseDatabaseRef.shared.child("users").child(CurrentUserInfoManager.shared.currentUserNode).updateChildValues(["pictureUrl": downloadUrl])
                
            }
        }
                
        UserDefaultManager().downloadCurrentUserInfo()
        
        // TODO: showing user a block that displayname has been changed successfully
        
    }
}




