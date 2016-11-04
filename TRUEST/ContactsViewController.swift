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
import FBSDKShareKit
import ABPadLockScreen
import QuartzCore
import FirebaseCrash

class ContactsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,  ABPadLockScreenViewControllerDelegate {
    
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var NavigationItem: UINavigationItem!
    @IBOutlet weak var Hint: UILabel!
    @IBAction func AddFriendPressed(sender: AnyObject) {
        
        let content = FBSDKAppInviteContent()
        let inviteURL = "https://www.facebook.com/BOND-communication-tool-145977405872589/?fref=ts"
        content.appLinkURL = NSURL(string: inviteURL)
        let inviteImageURL = "https://scontent-tpe1-1.xx.fbcdn.net/v/t1.0-9/14956574_145977942539202_5014903996623382975_n.png?oh=1dfa7bf394c24b93c7f0372b38259715&oe=58977BED"
        content.appInvitePreviewImageURL = NSURL(string: inviteImageURL)
        FBSDKAppInviteDialog.showFromViewController(self, withContent: content, delegate: self)
        
    }
    
    var friendList: [existedFBUser] = []
    var createNew: Bool = true // should be false, change to true for testing, it should be that pressed + and change it into true
    var selectedIndexes = [NSIndexPath]() {
        didSet {
            CollectionView.reloadData()
        }
    }
    private(set) var thePasscode: String?
    private var foregroundNotification: NSObjectProtocol!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        thePasscode = NSUserDefaults.standardUserDefaults().stringForKey("currentPasscode")
        print(thePasscode)
        if thePasscode == nil {
        } else if self.thePasscode != nil {
            let lockScreen = ABPadLockScreenViewController(delegate: self, complexPin: false)
            lockScreen.setAllowedAttempts(3)
            lockScreen.modalPresentationStyle = UIModalPresentationStyle.FullScreen
            lockScreen.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            presentViewController(lockScreen, animated: true, completion: nil)
        } //第一次進來run一次lock//
        
        
        foregroundNotification = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
            [unowned self] notification in
            guard let currentPasscode = NSUserDefaults.standardUserDefaults().stringForKey("currentPasscode") as String!
                else {
                    FIRCrashMessage("no currentPasscode at ContactsVC")
                    return
            }
            self.thePasscode = currentPasscode
            let lockScreen = ABPadLockScreenViewController(delegate: self, complexPin: false)
            lockScreen.setAllowedAttempts(3)
            lockScreen.modalPresentationStyle = UIModalPresentationStyle.FullScreen
            lockScreen.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            self.presentViewController(lockScreen, animated: true, completion: nil)
        }
        print("hi I'm at ContactsViewController")
       
        ABPadLockScreenView.appearance().backgroundColor = UIColor(hue:0.61, saturation:0.55, brightness:0.64, alpha:1)
        
        ABPadLockScreenView.appearance().labelColor = UIColor(red: 23/255, green: 114/255, blue: 133/255, alpha: 1)
        
        let buttonLineColor = UIColor(red: 23/255, green: 114/255, blue: 133/255, alpha: 1)
        ABPadButton.appearance().backgroundColor = UIColor.clearColor()
        ABPadButton.appearance().borderColor = buttonLineColor
        ABPadButton.appearance().selectedColor = buttonLineColor
        ABPinSelectionView.appearance().selectedColor = buttonLineColor
        
        
        ContactsManager.shared.delegate = self
        
        ContactsManager.shared.myFriends()

        CollectionView.delegate = self
        
        CollectionView.dataSource = self
        
        CollectionView.backgroundColor = UIColor.whiteColor()
        
        let logoView = UIImageView()
            logoView.frame = CGRectMake(0, 0, 50, 70)
            logoView.contentMode = .ScaleAspectFit
            logoView.image = UIImage(named: "navi_logo")
       
        Hint.text = "Tap an intimate to create a bond."
        Hint.textColor = UIColor.lightGrayColor()
//        Hint.layer.borderWidth = 1
        let dotborder =  CAShapeLayer()
        dotborder.strokeColor = UIColor.grayColor().CGColor
        dotborder.fillColor = nil
        dotborder.lineDashPattern = [4, 2]
        dotborder.path = UIBezierPath(roundedRect: Hint.bounds, cornerRadius: 5).CGPath
        dotborder.frame = Hint.bounds
        Hint.layer.addSublayer(dotborder)
        
        
      self.NavigationItem.titleView = logoView

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()

    }
    
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return friendList.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ContactsCell", forIndexPath: indexPath) as! ContactsCollectionViewCell
        
        let row = indexPath.row
        
        let theFriend = friendList[row]
        
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
            let edgeSpacing = (view.bounds.width - 332) / 2
            layout.sectionInset = UIEdgeInsets(top: 10, left: edgeSpacing, bottom: 15, right: edgeSpacing)
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            layout.minimumLineSpacing = 1
            layout.minimumInteritemSpacing = 1
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
    
    //MARK: Lock Screen Setup Delegate
//    func pinSet(pin: String!, padLockScreenSetupViewController padLockScreenViewController: ABPadLockScreenSetupViewController!) {
//        thePin = pin
//        dismissViewControllerAnimated(true, completion: nil)
//    }
    
    func unlockWasCancelledForSetupViewController(padLockScreenViewController: ABPadLockScreenAbstractViewController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Lock Screen Delegate
    func padLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!, validatePin pin: String!) -> Bool {
        print("Validating Pin \(pin)")
        return thePasscode == pin
    }
    
    func unlockWasSuccessfulForPadLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Unlock Successful!")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func unlockWasUnsuccessful(falsePin: String!, afterAttemptNumber attemptNumber: Int, padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Failed Attempt \(attemptNumber) with incorrect pin \(falsePin)")
    }
    
    func unlockWasCancelledForPadLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Unlock Cancled")
        
        
        
    }



    
    
}



extension ContactsViewController: ContactsManagerDelegate {
    
    func manager(manager: ContactsManager, didGetFriendList friendList: [existedFBUser]) {
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
    
                        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
                        
                    }
                    
                    FIRAnalytics.logEventWithName("selectAFriendAsReceiver", parameters: nil)
                    
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


extension ContactsViewController: FBSDKAppInviteDialogDelegate {
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("invite a friend")
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        print("cannot invite a friend: \(error)")
    }
    
}

