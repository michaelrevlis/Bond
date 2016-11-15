//
//  SettingViewController.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/17.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCrash
import FirebaseDatabase
import FBSDKCoreKit

import ABPadLockScreen
class SettingViewController: UITableViewController,UITextFieldDelegate, UIImagePickerControllerDelegate ,ABPadLockScreenSetupViewControllerDelegate, ABPadLockScreenViewControllerDelegate,UINavigationControllerDelegate {



    
    @IBOutlet weak var DisplayNameLabel: UILabel!
    @IBOutlet weak var DisplayNameField: UITextField!
    @IBOutlet weak var IDLabel: UILabel!
    @IBOutlet weak var IDField: UITextField!
    @IBOutlet weak var ProfilePicture: UIImageView!
    
    @IBOutlet weak var PasscodeSwitch: UISwitch!
    @IBOutlet weak var DisplayNameChange: UIButton!
    @IBOutlet weak var IDChange: UIButton!
    @IBOutlet weak var ProfilePictureChange: UIButton!
    
    @IBOutlet weak var LogoutButton: UIButton!
    
    @IBOutlet weak var NavigationItem: UINavigationItem!
    private var pickedImage = UIImage()
    private var imageData = NSData()
    private var imageUrl = String()
    private let imagePicker = UIImagePickerController()
    private(set) var thePasscode: String?
    private(set) var switchStatus: Bool?

    private let settingManager = SettingManager()
    

    @IBOutlet weak var testimg: UIImageView!
    
    @IBAction func DisplayNameChangePressed(sender: AnyObject) {
        DisplayNameField.hidden = false
        DisplayNameLabel.hidden = true
        DisplayNameField.placeholder = "Display Name Change Pressed"
    }
    
    @IBAction func PasscodeSwitchPressed(sender: UISwitch) {
        if PasscodeSwitch.on == true{
            ActivatePasscode()
            NSUserDefaults.standardUserDefaults().setObject(PasscodeSwitch.on, forKey: "switchstatus")
        }
        if PasscodeSwitch.on == false{
            DeactivatePasscode()
            NSUserDefaults.standardUserDefaults().setObject(PasscodeSwitch.on, forKey: "switchstatus")
        }
    }
    
    
    
    @IBAction func IDChangePressed(sender: AnyObject) {
//        IDField.hidden = false
//        IDLabel.hidden = true
//        IDField.placeholder = "ID Change Pressed"
    }
    
    @IBAction func LogoutPressed(sender: AnyObject) {
        logout()
    }
    
    @IBAction func PictureChangePressed(sender: AnyObject) {
        
        print("Picture Change Pressed")
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.SD_BackgroudWhite_EEEEEE()
        
        IDChange.hidden = true
        
        thePasscode = NSUserDefaults.standardUserDefaults().stringForKey("currentPasscode")
        let userDefault = NSUserDefaults.standardUserDefaults()
        
        guard let imgUrl = userDefault.stringForKey("user_pictureUrl")
            else {
                let alert = UIAlertController(title: "Error!",
                                                            message: "Please log out and re-log in again.",
                                                            preferredStyle: UIAlertControllerStyle.Alert)
                
                let action = UIAlertAction(title: "Log out!",
                                                        style: UIAlertActionStyle.Default,
                                                        handler: { action in
                                                        self.logout()
                })
                
                alert.addAction(action)
                
                self.presentViewController(alert, animated: true, completion: nil)
                
                return
        }
        
        let url = NSURL(string: imgUrl)
        if let data = NSData(contentsOfURL: url!) {
            ProfilePicture.contentMode = .ScaleAspectFit
            ProfilePicture.image = UIImage(data: data)
            let imageData = stringToNSData(imgUrl)
            ProfilePicture.image = UIImage(data: imageData)
        }
        
        DisplayNameField.hidden = true
        IDField.hidden = true
        DisplayNameLabel.text = userDefault.stringForKey("user_name")
        IDLabel.text = ""
        IDField.delegate = self
        DisplayNameField.delegate = self
        switchStatus = NSUserDefaults.standardUserDefaults().boolForKey("switchstatus")
        if   switchStatus == nil {
            PasscodeSwitch.on = false
            
        } else if switchStatus == false {
            PasscodeSwitch.on = false
        } else {
            PasscodeSwitch.on = true
        }
        
        let logoView = UIImageView()
        logoView.frame = CGRectMake(0, 0, 50, 70)
        logoView.contentMode = .ScaleAspectFit
        logoView.image = UIImage(named: "navi_logo")
        
        
        self.NavigationItem.titleView = logoView
        print("hi I'm at setting")
        ABPadLockScreenView.appearance().backgroundColor = UIColor(hue:0.61, saturation:0.55, brightness:0.64, alpha:1)
        
        ABPadLockScreenView.appearance().labelColor = UIColor(red: 23/255, green: 114/255, blue: 133/255, alpha: 1)
        
        let buttonLineColor = UIColor(red: 23/255, green: 114/255, blue: 133/255, alpha: 1)
        ABPadButton.appearance().backgroundColor = UIColor.clearColor()
        ABPadButton.appearance().borderColor = buttonLineColor
        ABPadButton.appearance().selectedColor = buttonLineColor
        ABPinSelectionView.appearance().selectedColor = buttonLineColor
        let lockSetupScreen = ABPadLockScreenSetupViewController(delegate: self, complexPin: false, subtitleLabelText: "Please Set Your Passcode")
        lockSetupScreen.tapSoundEnabled = false
        lockSetupScreen.errorVibrateEnabled = false
        lockSetupScreen.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        lockSetupScreen.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        imagePicker.delegate = self
        ProfilePicture.contentMode = .ScaleAspectFit
        
    }
    
    
    func logout() {

        self.cleanupPostcardDownloadFlagOnServer()
        
        settingManager.cleanUpUserData()
        
        try! FIRAuth.auth()!.signOut()
        
        FBSDKAccessToken.setCurrentAccessToken(nil)
        
        self.dismissViewControllerAnimated(true, completion:{})
    }
    
    
    func ActivatePasscode() {
      
        let lockSetupScreen = ABPadLockScreenSetupViewController(delegate: self, complexPin: false, subtitleLabelText: "Please Set Your Passcode")
        lockSetupScreen.tapSoundEnabled = false
        lockSetupScreen.errorVibrateEnabled = false
        lockSetupScreen.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        lockSetupScreen.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        presentViewController(lockSetupScreen, animated: true, completion: nil)
        //1.pop up ablockpad
        //2.enter again
        //3.save it to ??
        //(4.call the pad elsewhere when thread/outbox/app is entered)
        
    }
    func DeactivatePasscode() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("currentPasscode")
        NSUserDefaults.standardUserDefaults().synchronize()
        thePasscode = nil
        //1.clean the passcode from save point
        //2.do not call pad anywhere
    }
    
    
    func lockScreen() {
        
        print(thePasscode)
            let lockScreen = ABPadLockScreenViewController(delegate: self, complexPin: false)
            lockScreen.setAllowedAttempts(3)
            lockScreen.modalPresentationStyle = UIModalPresentationStyle.FullScreen
            lockScreen.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            
            presentViewController(lockScreen, animated: true, completion: nil)
    }
    
    
    
    //MARK: Lock Screen Setup Delegate
    func pinSet(passcode: String!, padLockScreenSetupViewController padLockScreenViewController: ABPadLockScreenSetupViewController!) {
        thePasscode = passcode
        NSUserDefaults.standardUserDefaults().setObject(passcode, forKey: "currentPasscode")
        NSUserDefaults.standardUserDefaults().synchronize()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func unlockWasCancelledForSetupViewController(padLockScreenViewController: ABPadLockScreenAbstractViewController!) {
        PasscodeSwitch.on = false
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
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}


extension SettingViewController{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // iOS 8.0用UIImagePickerControllerReferenceURL，else用OriginalImage
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            else {
                FIRCrashMessage("Fail to select image")
                showErrorAlert(self, title: "Notice", msg: "Due to some technique problem, this image can not be selected. Please select another one")
                return
        }
        ProfilePicture.contentMode = .ScaleToFill
        ProfilePicture.image = pickedImage
        self.pickedImage = pickedImage as UIImage
        imageData = UIImageJPEGRepresentation(pickedImage, 1.0)! //將所選取的image轉型成NSData，不壓縮
        
        guard let url = info[UIImagePickerControllerReferenceURL] as? NSURL
            else {
                FIRCrashMessage("Fail to convert selected image into url")
                return
        }
        imageUrl = url.absoluteString
        
        settingManager.updateUserPicture(imageData)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion:nil)
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    func textFieldDidEndEditing(textField: UITextField) {
        switch textField {
        case IDField:
            IDLabel.text = textField.text
            IDLabel.hidden = false
            IDField.hidden = true
            
            
        case DisplayNameField:
            DisplayNameLabel.text = textField.text
            DisplayNameLabel.hidden = false
            DisplayNameField.hidden = true
            
            guard let newName = textField.text as String!
                else {
                    showErrorAlert(self, title: "Error", msg: "Display name can't be empty.")
                    return
            }
            settingManager.updateUserName(newName)
            
        default:
            break
        }
        
    }
    
    
    func cleanupPostcardDownloadFlagOnServer() {
        
        let userNode = CurrentUserInfoManager.shared.currentUserNode
        
        FirebaseDatabaseRef.shared.child("bonds").queryOrderedByChild("receiver").queryEqualToValue(userNode).observeEventType(.ChildAdded, withBlock: { snapshot in
            
            let bondRef = snapshot.ref
            print(bondRef)
            
            bondRef.updateChildValues(["download": "0"])
            
        })
    }
}
