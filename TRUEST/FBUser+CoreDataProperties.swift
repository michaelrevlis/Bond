//
//  FBUser+CoreDataProperties.swift
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

extension FBUser {

    @NSManaged var email: String?
    @NSManaged var fbID: String?
    @NSManaged var fbProfileLink: String?
    @NSManaged var authID: String?
    @NSManaged var name: String?
    @NSManaged var pictureUrl: String?
    @NSManaged var userNode: String?

}
