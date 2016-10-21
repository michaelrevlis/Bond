//
//  ContactsViewController.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/13.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import FBSDKCoreKit

class ContactsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var NavigationItem: UINavigationItem!
    
    var friendList: [existedFBUser] = []
    var createNew: Bool = true // should be false, change to true for testing, it should be that pressed + and change it into true
    var selectedIndexes = [NSIndexPath]() {
        didSet {
            CollectionView.reloadData()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("hi I'm at ContactsViewController")
        
        
        FriendManager.shared.delegate = self
        
        FriendManager.shared.myFriends()

        CollectionView.delegate = self
        
        CollectionView.dataSource = self
        
        CollectionView.backgroundColor = UIColor.whiteColor()
        
        NavigationItem.titleView = NavigationLogo.shared.titleView
                
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        NavigationItem.titleView = NavigationLogo.shared.titleView

    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return friendList.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ContactsCell", forIndexPath: indexPath) as! ContactsCollectionViewCell
        
        let row = indexPath.row
        
        let theFriend = friendList[row]
        
        let selectedUser = theFriend.name
        let selectedUserID = theFriend.userNode
        
        // TODO: dealing with picture "!" and the case of not having a picture. (later one consider as further feature)
        let pictureUrl = NSURL(string: theFriend.pictureUrl)
        let data = NSData(contentsOfURL: pictureUrl!)
        
        cell.setup()
        cell.imageInSmall.image = UIImage(data: data!)
        cell.contactName.text = theFriend.name
        

//        // select a colection cell and something will happen. ex. change cell color
//        if self.selectedIndexes.indexOf(indexPath) != nil { // Selected
//            
//            if self.createNew == false {
//                // show a view with SendFromOutbox and ViewThread
//            } else {
//                // create a new post and pass selected intimate to addPost as receiver
//            }
//        }
        
        return cell
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 375 110
        if let layout = CollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            
            let itemWidth = 110
            let itemHeight = itemWidth
            let edgeSpacing = (view.bounds.width - 334) / 2
            layout.sectionInset = UIEdgeInsets(top: 10, left: edgeSpacing, bottom: 15, right: edgeSpacing)
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            layout.minimumLineSpacing = 2
            layout.minimumInteritemSpacing = 2
            layout.invalidateLayout()
        }
    }
    

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // insure what happened to selected cell did not be refresh when scrolling down
        if let indexSelectThenDo = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(indexSelectThenDo)
        } else {
            selectedIndexes.append(indexPath)
        }
        
        
    }
}



extension ContactsViewController: FriendManagerDelegate {
    
    func manager(manager: FriendManager, didGetFriendList friendList: [existedFBUser]) {
        self.friendList = friendList
        
        self.CollectionView.reloadData()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                
            case "SelectFriendAsReceiver":
                // create a new post and pass selected intimate to addPost as receiver
                if createNew == true {
                    let addPostVC = segue.destinationViewController as! AddBondViewController
                    
                    print("segue to addPost")
                    
                    if let indexPath = self.CollectionView.indexPathForCell(sender as! UICollectionViewCell) {
                        
                        addPostVC.receiverName = friendList[indexPath.row].name
                        addPostVC.receiverNode = friendList[indexPath.row].userNode
                        print("\(addPostVC.receiverName)")
                    }
                    
                }
                
            // show a view with SendFromOutbox and ViewThread
            case "ShowMailbox": break
              
            case "ShowThread": break
                
            default:
                break
            }
        }
    }
}
