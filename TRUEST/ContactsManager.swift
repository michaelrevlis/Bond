//
//  ContactsManager.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/13.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FirebaseCrash


class existedFBUser {
    var userNode: String
    var name: String
    var email: String
    var pictureUrl: String
    
    init (userNode:String, name: String, email: String, pictureUrl: String) {
        self.userNode = userNode
        self.name = name
        self.email = email
        self.pictureUrl = pictureUrl
    }
}


protocol ContactsManagerDelegate: class {
    func manager(manager: ContactsManager, didGetFriendList friendList: [existedFBUser])
}

// TODO: save friends into core data
class ContactsManager {
    
    static let shared = ContactsManager()
    
    private(set) var friendList = [existedFBUser]()
    
    weak var delegate: ContactsManagerDelegate?
    
    func myFriends(){
        
        getFriendList { (success, results) in
            
            if success == true {
                
                self.getFriendInfo(friendlist: results)
                
                self.delegate?.manager(self, didGetFriendList: self.friendList)
                
            }
        }
    }
    
}

extension ContactsManager {
 
    typealias GetFriendListCompletion = (success: Bool, results: [NSDictionary]) -> Void
    
    private func getFriendList(completion completion: GetFriendListCompletion) {
        
        var friendlist = [NSDictionary]()
        let param = ["fields": "friends"]
        let request = FBSDKGraphRequest(graphPath: "/me/friends", parameters: param, HTTPMethod: "GET")
        
        request.startWithCompletionHandler{ (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) in
                
                if let error = error {
                    FIRCrashMessage("Error in access FB user friend list data: \(error)")
                    return
                }
                
                guard let  result = result as? NSDictionary,
                                totalData = result["data"] as? NSArray
                    else {
                        FIRCrashMessage("Fail to open friendlist data from FB")
                        return
            }

                    for item in totalData {
                        guard let  item = item as? NSDictionary,
                                        id = item["id"] as? String // co-friend's FB ID
                            else {
                                FIRCrashMessage("Fail to extract friend's FB ID")
                                return
                        }
                        
                        FirebaseDatabaseRef.shared.child("users").queryOrderedByChild("fbID").queryEqualToValue(id).observeEventType(.ChildAdded, withBlock: { snapshot in
                            
                            guard let  user = snapshot.value as? NSDictionary
                                else {
                                    FIRCrashMessage("Fail to open friend's user data from firebase")
                                    return
                            }
                            
                            // download co-friend's user info from firebase
                            friendlist.append(user)

                            if friendlist.count == totalData.count {
                                
                                completion(success: true, results: friendlist)
                            }
                            
                        })
                        
            }
        }
    }
    
    
    private func getFriendInfo(friendlist friendlist: [NSDictionary]) {
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        guard
        let email = userDefault.stringForKey("user_email") as String!,
             node = userDefault.stringForKey("user_userNode") as String!,
             pictureUrl = userDefault.stringForKey("user_pictureUrl") as String!
            else {
                FIRCrashMessage("Fail to convert current user self info as friend")
                return
        }
        self.friendList.append(existedFBUser(userNode: node, name: "ME", email: email, pictureUrl: pictureUrl))
        
        
        
        for user in friendlist {

            guard let  userNode = user["userNode"] as? String,
                            email = user["email"] as? String,
                            name = user["name"] as? String,
                            pictureUrl = user["pictureUrl"] as? String
                else {
                    FIRCrashMessage("error in matching user's info with their fb id")
                    break
            }
            
            self.friendList.append(existedFBUser(userNode: userNode, name: name, email: email, pictureUrl: pictureUrl))
            
        }
    }
    
    
    func cleanupFriendlist() {
        self.friendList = []
    }
    
}

