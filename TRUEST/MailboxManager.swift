//
//  MailboxManager.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/18.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseCrash
import FirebaseAnalytics
import CoreData



class MailboxManager {
    
    static let shared = MailboxManager()
    
    func downloadReceivedPostcards() {
        
        // TODO: only download postcard that sent after user's last login time. we delete all because we download all of them so there will be redundant
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let requestReceivedPostcard = NSFetchRequest(entityName: "ReceivedPostcard")
        
        do {
            
            let resultsReceivedPostcard = try managedContext.executeFetchRequest(requestReceivedPostcard) as! [ReceivedPostcard]
            
            for result in resultsReceivedPostcard {
                managedContext.deleteObject(result)
            }
            
        }catch {
            FIRCrashMessage("Error in cleaning Mailbox")
        }
        
        do {
            try managedContext.save()
            FIRAnalytics.logEventWithName("Mailbox has been deleted", parameters: nil)
        } catch {
            FIRCrashMessage("Error in updating Mailbox deletion")
        }
        
        
        
        // use userNode to find related bond
        let userDefault = NSUserDefaults.standardUserDefaults()
        guard let userNode = userDefault.stringForKey("user_userNode") as String!
            else {
                FIRCrashMessage("Fail to unwrap userNode from user default")
                return
        }
        
        FirebaseDatabaseRef.shared.child("bonds").queryOrderedByChild("receiver").queryEqualToValue(userNode).observeEventType(.ChildAdded, withBlock: { snapshot in
        
            let bondRef = snapshot.ref
            
            guard let  bond = snapshot.value as? NSDictionary,
                            postcard_id = bond["postcard"] as? String,
                            sender_node = bond["sender"] as? String,
                            download = bond["download"] as? String
                else {
                    FIRCrashMessage("No one has sent a postcard to this user or error in getting bond")
                    return
            }
            
            guard download == "0" else { return } // 0表示此postcard尚未被下載到user手機上
            
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
                        FIRCrashMessage("Fail to convert data type when getting received postcard")
                        return
                }
                
                FirebaseDatabaseRef.shared.child("users").queryOrderedByKey().queryEqualToValue(sender_node).observeEventType(.ChildAdded, withBlock: { snapshot in
                    
                    guard let  result = snapshot.value as? NSDictionary,
                                    sender_name = result["name"] as? String
                        else {
                            FIRCrashMessage("Fail in getting sender's name with sender_node")
                            return
                    }
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
                    guard let received_time = dateFormatter.dateFromString(delivered_time)
                        else {
                            FIRCrashMessage("Fail to convert received_time from string to date")
                            return
                    }
                    
                    let image = stringToNSData(imageUrl)
                    
                    // TODO: 未來要新增user last login date，並將該日期之後received的postcard下載存在core data
                    let receivedPostcards: [String: AnyObject] = ["sender": sender, "sender_name": sender_name, "receiver": CurrentUserInfoManager.shared.currentUserNode, "received_time": received_time, "title": title, "context": context, "signature": signature, "image": image]
                    
                    
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    
                    let managedContext = appDelegate.managedObjectContext
                    
                    let entity = NSEntityDescription.entityForName("ReceivedPostcard", inManagedObjectContext: managedContext)
                    
                    let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                    
                    for (key, value) in receivedPostcards {
                        user.setValue(value, forKey: key)
                    }
                    
                    do {
                        try managedContext.save()
                        FIRAnalytics.logEventWithName("saving received postcard in Core", parameters: nil)
                    } catch {
                        FIRCrashMessage("Error in saving received postcards into core data")
                    }

                    
                    // update download status to firebase
                    bondRef.updateChildValues(["download": "1"])
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
            FIRCrashMessage("Error in deleting core data: ReceivedPostcard")
        }
        
        do {
            try managedContext.save()
            FIRAnalytics.logEventWithName("deleting ReceivedPostcard in core data", parameters: nil)
        } catch {
            FIRCrashMessage("Error in updating ReceivedPostcard deletion")
        }
    }

}
