//
//  PasscodeViewController.swift
//  TRUEST
//
//  Created by 林柏翰 on 2016/10/25.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//
//其實都沒有用到，留著做更改參考//
import UIKit
import ABPadLockScreen
class PasscodeViewController: UINavigationController,UINavigationBarDelegate,ABPadLockScreenSetupViewControllerDelegate, ABPadLockScreenViewControllerDelegate {
    
    @IBOutlet weak var setPinButton: UIButton!
    @IBOutlet weak var lockAppButton: UIButton!
    
    private(set) var thePin: String?
    private(set) var thePasscode: String?
    //MARK: View Controller Lifecycle
    override func viewDidLoad() {
        
    thePasscode = NSUserDefaults.standardUserDefaults().stringForKey("currentPasscode")
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
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        print("test")
        print(thePasscode)
        super.viewDidLoad()
        
        if thePasscode == nil {
        } else if thePasscode != nil {
            let lockScreen = ABPadLockScreenViewController(delegate: self, complexPin: false)
            lockScreen.setAllowedAttempts(3)
            lockScreen.modalPresentationStyle = UIModalPresentationStyle.FullScreen
            lockScreen.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            presentViewController(lockScreen, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    
    
    //MARK: Action methods
    @IBAction func lockAppSelected(sender: AnyObject) {
        if thePin == nil {
            let alertController = UIAlertController(title: "placeholder", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        let lockScreen = ABPadLockScreenViewController(delegate: self, complexPin: false)
        lockScreen.setAllowedAttempts(3)
        lockScreen.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        lockScreen.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        presentViewController(lockScreen, animated: true, completion: nil)
    }
    
    @IBAction func setPinSelected(sender: AnyObject) {
        let lockSetupScreen = ABPadLockScreenSetupViewController(delegate: self, complexPin: false, subtitleLabelText: "Please Set Your Passcode")
        lockSetupScreen.tapSoundEnabled = false
        lockSetupScreen.errorVibrateEnabled = false
        lockSetupScreen.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        lockSetupScreen.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        presentViewController(lockSetupScreen, animated: true, completion: nil)
    }
    
    //MARK: Lock Screen Setup Delegate
    func pinSet(pin: String!, padLockScreenSetupViewController padLockScreenViewController: ABPadLockScreenSetupViewController!) {
        thePin = pin
        dismissViewControllerAnimated(true, completion: nil)
    }
    
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
        dismissViewControllerAnimated(true, completion: nil)
    }
}
