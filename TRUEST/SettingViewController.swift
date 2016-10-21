//
//  SettingViewController.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/17.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit

class SettingViewController: UITableViewController,UITextFieldDelegate, UIImagePickerControllerDelegate{
    
    @IBOutlet weak var DisplayNameLabel: UILabel!
    @IBOutlet weak var DisplayNameField: UITextField!
    @IBOutlet weak var IDLabel: UILabel!
    @IBOutlet weak var IDField: UITextField!
    @IBOutlet weak var ProfilePicture: UIImageView!
    
    @IBOutlet weak var DisplayNameChange: UIButton!
    @IBOutlet weak var IDChange: UIButton!
    @IBOutlet weak var ProfilePictureChange: UIButton!
    
    @IBOutlet weak var LogoutButton: UIButton!
    
    @IBOutlet weak var NavigationItem: UINavigationItem!
    private var pickedImage = UIImage()
    private var imageData = NSData()
    private var imageUrl = String()
    private let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var testimg: UIImageView!
    @IBAction func DisplayNameChangePressed(sender: AnyObject) {
        DisplayNameField.hidden = false
        DisplayNameLabel.hidden = true
        DisplayNameField.text   = "Display Name Change Pressed"
    }
    
    
    @IBAction func IDChangePressed(sender: AnyObject) {
            IDField.hidden = false
            IDLabel.hidden = true
            IDField.text   = "ID Change Pressed"
    }
    
    @IBAction func LogoutPressed(sender: AnyObject) {
        try! FIRAuth.auth()!.signOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
        self.dismissViewControllerAnimated(true, completion:{}) //避免使用switch時造成tabbar仍然存在
    }
   
    @IBAction func PictureChangePressed(sender: AnyObject) {
        //todo//
        print("Picture Change Pressed")
    }

    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imgUrl = CurrentUserManager.shared.currentUserPictureURL
        NavigationLogo.shared.setup()
        NavigationItem.titleView = NavigationLogo.shared.titleView
        DisplayNameField.hidden = true
        IDField.hidden = true
        DisplayNameLabel.text = CurrentUserManager.shared.currentUserName
        IDLabel.text = ""
        IDField.delegate = self
        DisplayNameField.delegate = self
        let url = NSURL(string: imgUrl)
        let data = NSData(contentsOfURL: url!)
        if data != nil {
            ProfilePicture.contentMode = .ScaleAspectFit
            ProfilePicture.image = UIImage(data: data!)
        }
        print("hi I'm at ContactsViewController")

    }
}
extension SettingViewController{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // iOS 8.0用UIImagePickerControllerReferenceURL，else用OriginalImage
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { fatalError() }
        ProfilePicture.contentMode = .ScaleToFill
        ProfilePicture.image = pickedImage
        self.pickedImage = pickedImage as UIImage
        imageData = UIImageJPEGRepresentation(pickedImage, 1.0)! //將所選取的image轉型成NSData，不壓縮
        
        guard let url = info[UIImagePickerControllerReferenceURL] as? NSURL else { fatalError() }
        imageUrl = url.absoluteString
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
        default:
            break
        }
        
    }
    
}
