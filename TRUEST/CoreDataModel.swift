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
            print("Error in deleting core data: FBUser")
        }
        
        do {
            try managedContext.save()
            print("deleting FBUser in core data")
            
        } catch {
            print("Error in updating deletion of FBUser")
        }

        
    }
    
}
