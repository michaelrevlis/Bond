//
//  SaveManager.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/27.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import FirebaseCrash
import FirebaseAnalytics


protocol SendAfterSaveDelegate: class {
    func manager(manager: SaveManager, postcardToSend: [PostcardInDrawer], newPostcardDidSave: Bool)
}

protocol SaveManagerDelegate: class {
    func manager(manager: SaveManager, postcardSaved: [PostcardInDrawer], newPostcardDidSave: Bool)
}


class SaveManager {

    static let shared = SaveManager()
    
    weak var delegate: SendAfterSaveDelegate?
    weak var saveDelegate: SaveManagerDelegate?
    
    func savePressed(viewController: UIViewController, postcardToSave: [PostcardInDrawer]) {
        
        checkPostcard(viewController, postcardToSave: postcardToSave, completion: { result in
            
            if result == true {
                
                self.savePostcard(postcardToSave)
                
                self.delegate?.manager(self, postcardToSend: postcardToSave, newPostcardDidSave: true)
                
                self.saveDelegate?.manager(self, postcardSaved: postcardToSave, newPostcardDidSave: true)
                
            }
            
        })
        
    }
    
}

extension SaveManager {

    typealias CheckCompletion = (result: Bool) -> Void
    
    private func checkPostcard(viewController: UIViewController, postcardToSave: [PostcardInDrawer], completion: CheckCompletion) {
        
        let postcard = postcardToSave[0]
        
        if postcard.delivered_time == postcard.created_time {
            FIRAnalytics.logEventWithName("Missing delivered_time before postcard been saved", parameters: nil)
            showErrorAlert(viewController, title: "", msg: "Please select deliver date of this message.")
            completion(result: false)
        }
        
        else if postcard.title == "" {
            FIRAnalytics.logEventWithName("Missing title before postcard been saved", parameters: nil)
            showErrorAlert(viewController, title: "", msg: "Please edit message title.")
            completion(result: false)
        }
        
        else if postcard.context == "" {
            FIRAnalytics.logEventWithName("Missing context before postcard been saved", parameters: nil)
            showErrorAlert(viewController, title: "", msg: "Please edit context of this message.")
            completion(result: false)
        }
        
        else if postcard.signature == "" {
            FIRAnalytics.logEventWithName("Missing signature before postcard been saved", parameters: nil)
            showErrorAlert(viewController, title: "", msg: "Please sign up your name at the bottom of this message.")
            completion(result: false)
        }
        
        else if postcard.image == NSData() {
            FIRAnalytics.logEventWithName("Missing image before postcard been saved", parameters: nil)
            showErrorAlert(viewController, title: "Please Select An Image", msg: "An image in harmony with your emotion is worth a thousand words.")
            completion(result: false)
        }
        
        else {
            completion(result: true)
        }
        
    }
    
    
    
    private func savePostcard(postcardToSave: [PostcardInDrawer]) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Postcard", inManagedObjectContext: managedContext)
        
        let newPostcard = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        newPostcard.setValue(postcardToSave[0].sender, forKey: "sender")
        newPostcard.setValue(postcardToSave[0].receiver, forKey: "receivers")
        newPostcard.setValue(postcardToSave[0].receiver_name, forKey: "receiver_name")
        newPostcard.setValue(postcardToSave[0].created_time, forKey: "created_time")
        newPostcard.setValue(postcardToSave[0].title, forKey: "title")
        newPostcard.setValue(postcardToSave[0].context, forKey: "context")
        newPostcard.setValue(postcardToSave[0].signature, forKey: "signature")
        newPostcard.setValue(postcardToSave[0].image, forKey: "image")
        newPostcard.setValue(postcardToSave[0].delivered_time, forKey: "delivered_time")
        
        do {
            try managedContext.save()
            FIRAnalytics.logEventWithName("Saves newPostcard into core data.", parameters: nil)
            
        } catch {
            FIRCrashMessage("Error in saving newPostcard into core data")
            return
        }
    }

    
}