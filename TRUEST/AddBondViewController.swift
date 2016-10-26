//
//  AddBondViewController.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/1.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import UIKit
import FirebaseCrash
import FirebaseAnalytics
import FirebaseDatabase
import CoreData
import FBSDKCoreKit


class AddBondViewController: UIViewController {

    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var ContentView: UIView!
    @IBOutlet weak var PostcardImage: UIImageView!
    @IBOutlet weak var LabelForShadow: UILabel!
    @IBOutlet weak var AddPhotoDescription: UILabel!
    @IBOutlet weak var AddPhotoPress: UIButton!
    @IBOutlet weak var Next: UIButton!
    @IBOutlet weak var TitleTextField: UITextField!
    @IBOutlet weak var SignatureTextField: UITextField!
    @IBOutlet weak var ContextTextField: UITextView!
    @IBOutlet weak var NavigationItem: UINavigationItem!

    var receiverName = String()
    var receiverNode  = String()
    private var pickedImage = UIImage()
    private var imageData = NSData()
    private var imageUrl = String()
    private let imagePicker = UIImagePickerController()
    private var newPostcard: [PostcardInDrawer] = []
    // TODO: 先設計成"!"，之後再改成?並在儲存時判斷是否為nil，若為nil則塞預設值給它
    private var currentTextOfTitle: String! = "Edit title here"
    private var currentTextOfSignature: String! = "Sign up your name here"
    private var currentTextOfContext: String! = "What I want to say is..."
    private var imageSelectedTimes: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        let logoView = UIImageView()
        logoView.frame = CGRectMake(0, 0, 50, 70)
        logoView.contentMode = .ScaleAspectFit
        logoView.image = UIImage(named: "navi_logo")
        
        self.NavigationItem.titleView = logoView
        
        setup()
        
        TitleTextField.delegate = self
        ContextTextField.delegate = self
        SignatureTextField.delegate = self
        imagePicker.delegate = self
        
    }
    
    ///////////////////////////////////////////////
    //// all @IBAction are here ////
   ///////////////////////////////////////////////
    @IBAction func SelectImage(sender: AnyObject) {
        self.imageSelectedTimes += 1
        FIRAnalytics.logEventWithName("selectAnImage", parameters: ["selectTimes": self.imageSelectedTimes])
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func NextPressed(sender: AnyObject) {
        print("Next pressed")
        FIRAnalytics.logEventWithName("addBondNextPressed", parameters: nil)
        next()
    }

}


extension AddBondViewController {
    
    private func setup() {
        
        self.view.addSubview(ScrollView)
        ScrollView.addSubview(ContentView)
        
        // LabelForShadow
        LabelForShadow.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        LabelForShadow.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).CGColor
        LabelForShadow.layer.shadowOpacity = 1.0
        LabelForShadow.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        
        // Next Button
        Next.setTitle("Next", forState: .Normal)
    }

}



extension AddBondViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // iOS 8.0用UIImagePickerControllerReferenceURL，else用OriginalImage
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            else {
                FIRCrashMessage("Fail to select image from album")
                showErrorAlert(self, title: "Notice", msg: "Due to some technique problem, this image can not be selected. Please select another.")
                return
        }
        PostcardImage.contentMode = .ScaleToFill
        PostcardImage.image = pickedImage
        self.pickedImage = pickedImage as UIImage
        imageData = UIImageJPEGRepresentation(pickedImage, 1.0)! //將所選取的image轉型成NSData，不壓縮
        
        guard let url = info[UIImagePickerControllerReferenceURL] as? NSURL
            else {
                FIRCrashMessage("Fail to convert selected image into url")
                return
        }
        imageUrl = url.absoluteString
        
        AddPhotoDescription.hidden = true
        ScrollView.setContentOffset(CGPointMake(0, -64), animated: true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion:nil)
    }
    
}


extension AddBondViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // TODO: 在UITextView中只有一個return鍵，但user可能會同時需要「斷行」、「結束」兩個功能
    //    // return keyboard when 'return' pressed in UITextView
    //    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    //        if text == "\n" {
    //            textView.resignFirstResponder()
    //            return false
    //        } else {
    //            return true
    //        }
    //    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        switch textField {
        case TitleTextField:
            ScrollView.setContentOffset(CGPointMake(0, -64), animated: true)
        case SignatureTextField:
            ScrollView.setContentOffset(CGPointMake(0, 100), animated: true)
        default: break
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        switch textField {
        case TitleTextField:
            currentTextOfTitle = textField.text
            
        case SignatureTextField:
            currentTextOfSignature = textField.text
            
        default:
            break
            
        }
        ScrollView.setContentOffset(CGPointMake(0, -64), animated: true)
    }
    
}



extension AddBondViewController: UITextViewDelegate {

    func textViewDidBeginEditing(textView: UITextView) {
        ScrollView.setContentOffset(CGPointMake(0, 100), animated: true)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        currentTextOfContext = textView.text
        ScrollView.setContentOffset(CGPointMake(0, -64), animated: true)
    }
}



extension AddBondViewController {

    func next() {
        
        let created_time = NSDate()
        print("postcard created time: \(created_time)")
        
        self.newPostcard.append(PostcardInDrawer(receiver: self.receiverNode,receiver_name: self.receiverName, created_time: created_time, delivered_time: created_time, title: currentTextOfTitle, context: currentTextOfContext, signature: currentTextOfSignature, image: imageData))
        
    }
    
    
    
    // TODO: 用一個母controller來存資料，add1, add2都只負責取資料而已
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let destinationVC = segue.destinationViewController as! AddBondStage2ViewController
        
        destinationVC.newPostcard = self.newPostcard
        destinationVC.receiverName = self.receiverName
        
    }
    
}


