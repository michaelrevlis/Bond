//
//  Manager.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/3.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//
import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import FBSDKCoreKit
import CoreData




class FirebaseDatabaseRef {
    static let shared = FIRDatabase.database().reference()
}

class FirebaseStorageRef {
    static let shared = FIRStorage.storage().reference()
}


// TODO: 將core data的存取寫成model
class CurrentUserManager {
    
    static let shared = CurrentUserManager()

    private(set) var currentUserNode = String()
    private(set) var currentUserName = String()
    private(set) var currentUserPictureURL = String()
    
    func getUserID() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let request = NSFetchRequest(entityName: "FBUser")
        
        do {
            
            let results = try managedContext.executeFetchRequest(request) as! [FBUser]
            
            for result in results {
                
                guard let  userNode = result.userNode
                    else {
                        print("error when getting current user's userNode from core data")
                        return
                }
                
                self.currentUserNode = userNode                
                print("current user node: \(CurrentUserManager.shared.currentUserNode)")
                
            }
            
            
            
            
        
            
            
        }catch{
            
            fatalError("Failed to fetch data: \(error)")
            
        }
    }
    
    func getUserName() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let request = NSFetchRequest(entityName: "FBUser")
        
        do {
            
            let results = try managedContext.executeFetchRequest(request) as! [FBUser]
            
            for result in results {
                
                guard let  userName = result.name
                    else {
                        print("error when getting current user's userName from core data")
                        return
                }
                
                self.currentUserName = userName
                print("current user node: \(CurrentUserManager.shared.currentUserName)")
                
            }
            
            
            
            
            
            
            
        }catch{
            
            fatalError("Failed to fetch data: \(error)")
            
        }
    }
    
    func getUserPicture() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let request = NSFetchRequest(entityName: "FBUser")
        
        do {
            
            let results = try managedContext.executeFetchRequest(request) as! [FBUser]
            
            for result in results {
                
                guard let  userPicture = result.pictureUrl
                    else {
                        print("error when getting current user's userName from core data")
                        return
                }
                
                self.currentUserPictureURL = userPicture
                print("current user picture: \(CurrentUserManager.shared.currentUserPictureURL)")
                
            }
            
            
            
            
            
            
            
        }catch{
            
            fatalError("Failed to fetch data: \(error)")
            
        }
    }
    

    
    
    
    
}



//以後要把downloadPostcards寫在背景執行
//func downloadPostcards() {
//    firebaseStorageRef.shared.child("-KTm_8FrWO9NfS-6lN5b").dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
//        if error != nil {
//            print("error in downloading postcard")
//        } else {
//            print("data")
//            print(data)
//        }
//    }
//}



// setup navigationLogo
class NavigationLogo: UIViewController{
    
    static let shared = NavigationLogo()
    
    var titleView = UIImageView()
    
    func setup() {
    
        titleView.frame = CGRectMake(0, 0, 50, 70)
        titleView.contentMode = .ScaleAspectFit
        titleView.image = UIImage(named: "navi_logo")
    
    }
}
