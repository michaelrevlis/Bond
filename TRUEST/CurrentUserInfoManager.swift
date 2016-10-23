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
    
    let currentUserAuth = FIRAuth.auth()!.currentUser!.uid
    
    func loadCurrentUserInfo() {
        
        FirebaseDatabaseRef.shared.child("users").queryOrderedByChild("authID").queryEqualToValue(currentUserAuth).observeEventType(.ChildAdded, withBlock: { snapshot in
            
            guard let  result = snapshot.value as? NSDictionary,
                            email = result["email"] as? String,
                            fbID = result["fbID"] as? String,
                            name = result["name"] as? String,
                            pictureUrl = result["pictureUrl"] as? String,
                            userNode = result["userNode"] as? String
                else { fatalError() }
            
            let currentUserInfo = ["authID": self.currentUserAuth, "email": email, "fbID": fbID, "name": name, "pictureUrl": pictureUrl, "userNode": userNode]
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            let entity = NSEntityDescription.entityForName("FBUser", inManagedObjectContext: managedContext)
            
            let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            
            for (key, value) in currentUserInfo {
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
            
            
        })
        
    }
}



