//
//  SelfDefineDataStructure.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/21.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import Foundation


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
