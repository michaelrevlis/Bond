//
//  SettingManager.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/24.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import Foundation


class SettingManager {
    
    func cleanUpUserData() {
     
        let b = CurrentUserInfoManager.shared.currentUserName
        print(b)
        let c = NSUserDefaults.standardUserDefaults().stringForKey("user_name") as String!
        print(c)
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user_name")
        let a = CurrentUserInfoManager.shared.currentUserName
        print(a)
        let d = NSUserDefaults.standardUserDefaults().stringForKey("user_name") as String!
        print(d)
        
        
        
    }
    
}


//extension UIViewController {
//    
//    // delete all data in FBUser. because it is allowed only one user at the same time
//    private func cleanUserInfo() {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        
//        let managedContext = appDelegate.managedObjectContext
//        
//        let request = NSFetchRequest(entityName: "FBUser")
//        
//        do {
//            let results = try managedContext.executeFetchRequest(request) as! [FBUser]
//            
//            for result in results {
//                managedContext.deleteObject(result)
//            }
//        }catch {
//            print("Error in deleting core data: FBUser")
//        }
//        
//        do {
//            try managedContext.save()
//            print("deleting user info in core data")
//        } catch {
//            print("Error in updating FBUser deletion")
//        }
//    }
//    
//}