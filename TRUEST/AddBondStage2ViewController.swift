//
//  AddBondStage2ViewController.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/18.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class AddBondStage2ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var PostcardImage: UIImageView!
    @IBOutlet weak var ConditionImageView: UIImageView!
    @IBOutlet weak var ReceiverImageView: UIImageView!
    @IBOutlet weak var LabelForShadow: UILabel!
    @IBOutlet weak var ConditionInputBackground: UILabel!
    @IBOutlet weak var ReceiverLabel: UILabel!
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var ConditionInputTextField: UITextField!
    @IBOutlet weak var NavigationItem: UINavigationItem!
    
    //    @IBOutlet weak var FinishDateSelectButton: UIButton!
    
    var receiverName = String()
    var newPostcard: [PostcardInDrawer] = []
    private var dateFormatter = NSDateFormatter()
    private var delivered_date = NSDate()
    private var deliverDateSelectedTimes: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        let logoView = UIImageView()
        logoView.frame = CGRectMake(0, 0, 50, 70)
        logoView.contentMode = .ScaleAspectFit
        logoView.image = UIImage(named: "navi_logo")
        
        self.NavigationItem.titleView = logoView
        
        setup()
        
    }
    
    
    /////// @IBActions ///////
    @IBAction func SavePressed(sender: AnyObject) {
        print("Save pressed")
        FIRAnalytics.logEventWithName("bondSaved", parameters: nil)
        savePostcard(newPostcard)
    }
    @IBAction func SendPressed(sender: AnyObject) {
        print("Send pressed")
        FIRAnalytics.logEventWithName("bondSent", parameters: nil)
        send(currentPostcard: newPostcard)
    }

    

    @IBAction func ConditionInputFieldClicked(sender: UITextField) {
    
        ConditionInputTextField.text = ""
        
        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 300))
        
        let datePickerView = UIDatePicker(frame: CGRectMake(0, 30, 0, 0))
        
        let doneButton = UIButton(frame: CGRectMake((self.view.frame.size.width/2) - (100/2), 0, 100, 30))
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        
        inputView.addSubview(datePickerView)
        inputView.addSubview(doneButton)
        
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        
        datePickerView.minuteInterval = 30  //設定每30分鐘為一個間隔
        
        sender.inputView = inputView
        
        datePickerView.addTarget(self, action: #selector(AddBondStage2ViewController.datePickerValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        doneButton.addTarget(self, action: #selector(AddBondStage2ViewController.finishSelect(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    
    // 透明的button以偵測使用者已選好時間日期了
    //    @IBAction func FinishDateSelect(sender: AnyObject) {
    //        delivered_date = dateFormatter.dateFromString(ConditionInputField.text!)!
    //
    //        self.newPostcard[0].specific_date = delivered_date
    //
    //        ConditionInputField.resignFirstResponder()
    //        //有傳資料但是沒有收datepicker
    //    }
    
    }
    
}


extension AddBondStage2ViewController {

    func setup() {
        // ConditionInputBackground
        ConditionInputBackground.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        ConditionInputBackground.layer.borderColor = UIColor.blackColor().CGColor
        ConditionInputBackground.layer.borderWidth = 2.5
        ConditionInputBackground.layer.cornerRadius = 20
        
        // ConditionImageView
        let conditionImage = UIImage(named: "thread_title")
        ConditionImageView.image = conditionImage
        
        // ConditionInputTextField
        ConditionInputTextField.text = "Select deliver time here"
        ConditionInputTextField.textColor = UIColor.lightGrayColor()

        // LabelForShadow
        LabelForShadow.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        LabelForShadow.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).CGColor
        LabelForShadow.layer.shadowOpacity = 1.0
        LabelForShadow.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)

        // Save & Send Button
        SaveButton.setTitle("Save", forState: .Normal)
        SendButton.setTitle("Send", forState: .Normal)
        
        // PostcardImage
        PostcardImage.contentMode = .ScaleToFill
        let data = newPostcard[0].image
        PostcardImage.image = UIImage(data: data)
        
        // ReceiverLabel
        ReceiverLabel.text = receiverName
        ReceiverLabel.textAlignment = .Center
        
        // ReceiverImageView
        ReceiverImageView.image = UIImage(named: "circle(group)")

    }
    
    
    @objc private func datePickerValueChanged(sender: UIDatePicker) {
        //將日期轉換成文字
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        ConditionInputTextField.text = dateFormatter.stringFromDate(sender.date)
        // 可以選擇的最早日期時間
        //        let fromDateTime = dateFormatter("2016-01-02 18:08")
        //        datePickerView.minimumDate = fromDateTime
    }
    
    
    @objc private func finishSelect(sender: AnyObject) {
        
        self.deliverDateSelectedTimes += 1
        
        FIRAnalytics.logEventWithName("selectDeliverDate", parameters: ["deliverDateSelectedTimes": self.deliverDateSelectedTimes])
        
        delivered_date = dateFormatter.dateFromString(ConditionInputTextField.text!)!
        
        self.newPostcard[0].delivered_time = delivered_date
        
        ConditionInputTextField.resignFirstResponder()
    }

    
    
    func savePostcard(postcardToSave: [PostcardInDrawer]) {
        
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
            print("edited postcard has been saved")
        } catch {
            print("Error in saving newPostcard into core data")
        }
    }
    
    
    
    // sent postcard to server
    func send(currentPostcard currentPostcard: [PostcardInDrawer]) {
        // 在data base 並產生postcard's uid
        let postcardSentRef = FirebaseDatabaseRef.shared.child("postcards").childByAutoId()
        
        let postcardSentUid = postcardSentRef.key
        
        print("UID: \(postcardSentUid)")
        
        // 該圖片存在firebase storage上的名稱
        let imagePath = postcardSentUid
        
        // 將NSDate轉成String
        let created_time = dateFormatter.stringFromDate(currentPostcard[0].created_time)
        let delivered_time = dateFormatter.stringFromDate(currentPostcard[0].delivered_time)
        
        let sendAPostcard: [String: AnyObject] =
              [ "sender": currentPostcard[0].sender,
                "created_time": created_time,
                "title": currentPostcard[0].title,
                "context": currentPostcard[0].context,
                "signature": currentPostcard[0].signature,
                "image": imagePath,
                "delivered_time": delivered_time]
        
        /////////// 將postcard的資料新增進firebase database ///////////
        postcardSentRef.setValue(sendAPostcard)
        print("postcard sent")
        
        
        /////////// saving image into firebase storage ///////////
        // 指定storage要存的相關資訊，在儲存到firebase storage前記得要去更改rule讓read,write = if true
        FirebaseStorageRef.shared.child(imagePath)
        
        // 定義上傳資料的metadata，以便日後去判斷此筆資料是image/audio/video，並呼叫對應的方始來開啟該檔案
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpg"
        
        //將照片存入storage中
        FirebaseStorageRef.shared.child(imagePath).putData(newPostcard[0].image, metadata: metadata) { (metadata, error) in
            
            if let error = error {
                print("Error upload image: \(error)")
                return
            } else {
                
                // get downloadURL
                let downloadUrl = metadata!.downloadURL()!.absoluteString
                
                // update postcard's image as its downloadURL
                FirebaseDatabaseRef.shared.child("postcards").child(postcardSentUid).updateChildValues(["image": downloadUrl])
                
                print("update image downloadURL")
            }
        }
        print("image stored")
        
        
        /////////// save bond ///////////
        let sendBond: [String: String] = [ "postcard": postcardSentUid, "receiver": currentPostcard[0].receiver, "sender": CurrentUserInfoManager.shared.currentUserNode ]
        
        let bondRef = FirebaseDatabaseRef.shared.child("bonds").childByAutoId()
        
        bondRef.setValue(sendBond)
        print("bond added")
        
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }

    
}



