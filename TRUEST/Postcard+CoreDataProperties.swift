//
//  Postcard+CoreDataProperties.swift
//  
//
//  Created by MichaelRevlis on 2016/10/21.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Postcard {

    @NSManaged var audio: String?
    @NSManaged var context: String?
    @NSManaged var created_time: NSDate?
    @NSManaged var deliver_condition: NSNumber?
    @NSManaged var delivered_time: NSDate?
    @NSManaged var image: NSData?
    @NSManaged var last_edited_time: NSDate?
    @NSManaged var postcard_uid: String?
    @NSManaged var receivers: NSObject?
    @NSManaged var relative_days: NSNumber?
    @NSManaged var sender: String?
    @NSManaged var sent_time: NSDate?
    @NSManaged var signature: String?
    @NSManaged var specific_date: NSDate?
    @NSManaged var title: String?
    @NSManaged var urgency: NSNumber?
    @NSManaged var video: String?
    @NSManaged var receiver_name: String?

}
