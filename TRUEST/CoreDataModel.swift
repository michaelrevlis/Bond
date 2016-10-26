//
//  CoreDataModel.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/21.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import FirebaseCrash


class CoreDataModel {
    
    func deleteFBUser() {
     
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let request = NSFetchRequest(entityName: "FBUser")
        
        do {
            let results = try managedContext.executeFetchRequest(request) as! [FBUser]
            
            for result in results {
                managedContext.deleteObject(result)
            }
            
        } catch {
            FIRCrashMessage("Error in deleting core data: FBUser")
            return
        }
        
        do {
            try managedContext.save()
            
        } catch {
            FIRCrashMessage("Error in saving the deletion of FBUser")
            return
        }

        
    }
    
}
