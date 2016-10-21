//
//  ReceivedPostcard+CoreDataProperties.swift
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

extension ReceivedPostcard {

    @NSManaged var context: String?
    @NSManaged var image: NSData?
    @NSManaged var received_time: NSDate?
    @NSManaged var receiver: String?
    @NSManaged var sender: String?
    @NSManaged var sender_name: String?
    @NSManaged var signature: String?
    @NSManaged var title: String?

}
