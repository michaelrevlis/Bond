//
//  User+CoreDataProperties.swift
//  
//
//  Created by MichaelRevlis on 2016/10/19.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var email: String?
    @NSManaged var fbID: String?
    @NSManaged var image: NSData?
    @NSManaged var name: String?
    @NSManaged var userNode: String?
    @NSManaged var authID: String?

}
