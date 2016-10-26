//
//  MailboxViewController.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/12.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import UIKit
import CoreData
import Firebase


class MailboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var NavigationItem: UINavigationItem!
    
    @IBOutlet weak var MailboxTableView: UITableView!
    var postcardsInMailbox = [PostcardInMailbox]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let logoView = UIImageView()
        logoView.frame = CGRectMake(0, 0, 50, 70)
        logoView.contentMode = .ScaleAspectFit
        logoView.image = UIImage(named: "navi_logo")
        
        
        self.NavigationItem.titleView = logoView
        print("this is Mailbox")
       // NavigationLogo.shared.setup()
        
      //  NavigationItem.titleView = NavigationLogo.shared.titleView
       // self.navigationController!.navigationBar.topItem?.titleView = NavigationLogo.shared.titleView
        viewMailbox()
        
        MailboxTableView.delegate = self
        MailboxTableView.dataSource = self
        
        self.MailboxTableView.rowHeight = 120
        
        if self.MailboxTableView != nil {
            self.MailboxTableView.reloadData()
        }
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postcardsInMailbox.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MailboxCell", forIndexPath: indexPath) as! MailboxTableViewCell
        
        let thePostcard = postcardsInMailbox[indexPath.row]
        
        cell.receivers.text = thePostcard.sender_name // should be receiver's name. add receiverName to coredata and request it while downloading it.
        cell.receivers.font = cell.receivers.font.fontWithSize(12)
        
        cell.title.text = thePostcard.title
        cell.title.font = UIFont(name: "Avenir Next", size: 12)
        
        cell.imageInSmall.frame = CGRectMake(35, 35, 50, 50)
        cell.imageInSmall.layer.cornerRadius = cell.imageInSmall.frame.height / 2
        cell.imageInSmall.contentMode = .ScaleAspectFit
        cell.imageInSmall.image = UIImage(data: thePostcard.image)
        cell.imageInSmall.clipsToBounds = true
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        cell.lastEditedLabel.text = dateFormatter.stringFromDate(thePostcard.received_time)
        cell.lastEditedLabel.textColor = UIColor.grayColor()
        cell.lastEditedLabel.font = UIFont(name: "Avenir Next", size: 12)
        
        cell.ContentView.addSubview(cell.imageInSmall)
        
        return cell
    }
 
}


extension MailboxViewController {
    
    // request received Postcard from core data
    private func viewMailbox() {

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let request = NSFetchRequest(entityName: "ReceivedPostcard")
        do {
            let results = try managedContext.executeFetchRequest(request) as! [ReceivedPostcard]
            
            for result in  results {
                guard let  sender = result.sender,
                                sender_name = result.sender_name,
                                receiver = result.receiver,
                                title = result.title,
                                context = result.context,
                                signature = result.signature,
                                received_time = result.received_time,
                                image = result.image else { fatalError() }
                
                let currentTime = NSDate()
                
                if received_time.isLessThanDate(currentTime) {
                    
                    print("postcard is delivered")
                    postcardsInMailbox.append(PostcardInMailbox(sender: sender, sender_name: sender_name, receiver: receiver, received_time: received_time, title: title, context: context, signature: signature, image: image))
                }
            }
            
        }catch{
            fatalError("Failed to fetch data: \(error)")
        }
    }
    
    
}

