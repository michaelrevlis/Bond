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


struct PostcardInDrawer {
    let sender: String! = CurrentUserManager.shared.currentUserNode
    var receiver: String!
    var receiver_name: String!
    let created_time: NSDate!
//    let last_edited_time: NSDate!
//    let sent_time: NSDate?
    var delivered_time: NSDate!
    var title: String!
    var context: String!
    var signature: String!
    var image: NSData!
//    let audioUrl: NSData?
//    let videoUrl: NSData?
//    let urgency: Int! = 0
//    let deliver_condition: String!
//    var specific_date: NSDate!
//    let relative_days: Int?
}


class PostcardInMailbox {
    var sender: String!
    var sender_name: String!
    var receiver: String!
    //    var created_time: NSDate!
    //    let last_edited_time: NSDate!
    //    let sent_time: NSDate?
    var received_time: NSDate!  // 與寄出時不一樣
    var title: String!
    var context: String!
    var signature: String!
    var image: NSData!
    //    let audioUrl: NSData?
    //    let videoUrl: NSData?
    //    let urgency: Int! = 0
    //    let deliver_condition: String!
    //    var specific_date: NSDate!
    //    let relative_days: Int?
    init (sender: String, sender_name: String, receiver: String, received_time: NSDate, title: String, context: String, signature: String, image: NSData) {
        self.sender = sender
        self.sender_name = sender_name
        self.receiver = receiver
        self.received_time = received_time
        self.title = title
        self.context = context
        self.signature = signature
        self.image = image
    }
}


class Friends {

    var name: String!
    var userNode: String!
    var fbID: String!
    var email: String!
    var image: NSData!
    
    init (name: String, userNode: String, fbID: String, email: String, image: NSData) {
        self.name = name
        self.userNode = userNode
        self.fbID = fbID
        self.email = email
        self.image = image
    }

}


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




extension CGRect {
    init(center: CGPoint, size: CGSize) {
        let originX = center.x - (size.width / 2)
        let originY = center.y - (size.height / 2)
        self.init(origin: CGPoint(x: originX, y: originY), size: size)
    }
}



// 嘗試將開啟新UIViewController做成一個func
func switchViewController(from originalViewController: UIViewController, to identifierOfDestinationViewController: String!) {
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    let destinationViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier(identifierOfDestinationViewController)
    
    destinationViewController.modalPresentationStyle = .CurrentContext
    destinationViewController.modalTransitionStyle = .CoverVertical
    
    originalViewController.presentViewController(destinationViewController, animated: true, completion: nil)
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


extension NSDate {
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        
        var isLess = false
        
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        
        return isLess
    }
}


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
