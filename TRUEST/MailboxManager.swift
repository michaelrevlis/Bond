//
//  MailboxManager.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/18.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import Foundation
import Firebase
import CoreData



class MailboxManager {
    
    static let shared = MailboxManager()
    
    func downloadReceivedPostcards() {
        
        cleanMailbox()
        
        // use userNode to find related bond
        FirebaseDatabaseRef.shared.child("bonds").queryOrderedByChild("receiver").queryEqualToValue(CurrentUserInfoManager.shared.currentUserNode).observeEventType(.ChildAdded, withBlock: { snapshot in
            
            guard let  bond = snapshot.value as? NSDictionary,
                            postcard_id = bond["postcard"] as? String,
                            sender_node = bond["sender"] as? String
                else {
                    print("No one has sent a postcard to this user or error in getting bond")
                    return
            }
            
            print("postcard ID")
            print(postcard_id)
            
            // use postcardID to find postcard
            FirebaseDatabaseRef.shared.child("postcards").queryOrderedByKey().queryEqualToValue(postcard_id).observeEventType(.ChildAdded, withBlock: { snapshot in
                
                //                    enum downloadError: ErrorType{  //以後有空要來做error handling
                //                        case StringConvertError, NSDateConvertError
                //                    }
                
                guard let  postcard = snapshot.value as? NSDictionary,
                                context = postcard["context"] as? String,
                                delivered_time = postcard["delivered_time"] as? String,
                                imageUrl = postcard["image"] as? String,
                                sender = postcard["sender"] as? String,
                                signature = postcard["signature"] as? String,
                                title = postcard["title"] as? String
                    else {
                        print("error in getting postcard")
                        return
                }
                
                FirebaseDatabaseRef.shared.child("users").queryOrderedByKey().queryEqualToValue(sender_node).observeEventType(.ChildAdded, withBlock: { snapshot in
                    
                    print("find users/sender_node")
                    print(snapshot)
                    
                    guard let  result = snapshot.value as? NSDictionary,
                                    sender_name = result["name"] as? String
                        else {
                            print("error in getting sender's name")
                            return
                    }
                    
                    print("find users/sender_node")
                    print(sender_name)
                    
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
                    guard let received_time = dateFormatter.dateFromString(delivered_time) else { fatalError() }
                    
                    guard let url = NSURL(string: imageUrl) else { fatalError() }
                    guard let image = NSData(contentsOfURL: url) else { fatalError() }
                    
                    // TODO: 未來要新增user last login date，並將該日期之後received的postcard下載存在core data
                    let receivedPostcards: [String: AnyObject] = ["sender": sender, "sender_name": sender_name, "receiver": CurrentUserInfoManager.shared.currentUserNode, "received_time": received_time, "title": title, "context": context, "signature": signature, "image": image]
                    
                    // TODO: 將save to core data寫成func，只需輸入指定的參數即可
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    
                    let managedContext = appDelegate.managedObjectContext
                    
                    let entity = NSEntityDescription.entityForName("ReceivedPostcard", inManagedObjectContext: managedContext)
                    
                    let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                    
                    for (key, value) in receivedPostcards {
                        user.setValue(value, forKey: key)
                    }
                    
                    do {
                        try managedContext.save()
                        print("saving received postcards in core data")
                    } catch {
                        print("Error in saving received postcards into core data")
                    }

                    
                })
                
            })
        })
       
    }


}

extension MailboxManager {
    
    private func cleanMailbox() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let request = NSFetchRequest(entityName: "ReceivedPostcard")
        
        do {
            let results = try managedContext.executeFetchRequest(request) as! [ReceivedPostcard]
            
            for result in results {
                managedContext.deleteObject(result)
            }
        }catch {
            print("Error in deleting core data: ReceivedPostcard")
        }
        
        do {
            try managedContext.save()
            print("deleting ReceivedPostcard in core data")
        } catch {
            print("Error in updating ReceivedPostcard deletion")
        }
    }

}
