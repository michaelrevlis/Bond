//
//  AddBondStage2ViewController.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/18.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseCrash
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
    
    var newPostcard: [PostcardInDrawer] = []
    private var dateFormatter = NSDateFormatter()
    private var delivered_date = NSDate()
    private var deliverDateSelectedTimes: Int = 0
    private let sendManager = SendManager()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        let logoView = UIImageView()
        logoView.frame = CGRectMake(0, 0, 50, 70)
        logoView.contentMode = .ScaleAspectFit
        logoView.image = UIImage(named: "navi_logo")
        
        self.NavigationItem.titleView = logoView
        
        SaveManager.shared.delegate = self
        sendManager.delegate = self
        
        //將日期轉換成文字
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        setup()
        
    }
    
    
    /////// @IBActions ///////
//    @IBAction func SavePressed(sender: AnyObject) {
//        print("Save pressed")
//        let saveManager = SaveManager()
//        saveManager.savePressed(self, postcardToSave: newPostcard)
//    }
    
    @IBAction func SendPressed(sender: AnyObject) {
        print("Save & Send pressed")
        SaveManager.shared.savePressed(self, postcardToSave: newPostcard)
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
        ConditionInputTextField.textColor = UIColor.lightGrayColor()
        if newPostcard[0].delivered_time == newPostcard[0].created_time {
            ConditionInputTextField.text = "Select deliver time here"
        } else {
            let deliveredTime = dateFormatter.stringFromDate(newPostcard[0].delivered_time)
            ConditionInputTextField.text = deliveredTime
        }

        // LabelForShadow
        LabelForShadow.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        LabelForShadow.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).CGColor
        LabelForShadow.layer.shadowOpacity = 1.0
        LabelForShadow.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)

        // Save & Send Button
//        SaveButton.setTitle("Save", forState: .Normal)
        SaveButton.hidden = true
        SendButton.setTitle("Save & Send", forState: .Normal)
        
        // PostcardImage
        PostcardImage.contentMode = .ScaleToFill
        let data = newPostcard[0].image
        PostcardImage.image = UIImage(data: data)
        
        // ReceiverLabel
        ReceiverLabel.text = newPostcard[0].receiver_name
        ReceiverLabel.textAlignment = .Center
        
        // ReceiverImageView
        ReceiverImageView.image = UIImage(named: "circle(group)")

    }
    
    
    @objc private func datePickerValueChanged(sender: UIDatePicker) {
        
        ConditionInputTextField.text = dateFormatter.stringFromDate(sender.date)
        // 可以選擇的最早日期時間
        //        let fromDateTime = dateFormatter("2016-01-02 18:08")
        //        datePickerView.minimumDate = fromDateTime
    }
    
    
    @objc private func finishSelect(sender: AnyObject) {
        
        self.deliverDateSelectedTimes += 1
        
        FIRAnalytics.logEventWithName("selectDeliverDate", parameters: ["deliverDateSelectedTimes": self.deliverDateSelectedTimes])
        
        guard let deliverTime = ConditionInputTextField.text as String!
            else {
                FIRCrashMessage("User click date picker but didn't choose one.")
                return
        }
        
        guard dateFormatter.dateFromString(deliverTime) != nil
            else {
                showErrorAlert(self, title: "", msg: "Please determine when this message been delivered to receiver.")
                FIRCrashMessage("User click date picker but didn't choose one.")
                return
        }
        
        delivered_date = dateFormatter.dateFromString(deliverTime)!
        
        self.newPostcard[0].delivered_time = delivered_date
        
        ConditionInputTextField.resignFirstResponder()
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



extension AddBondStage2ViewController: SendAfterSaveDelegate {
    func manager(manager: SaveManager, postcardToSend postcardToSave: [PostcardInDrawer], newPostcardDidSave: Bool) {
        
        if newPostcardDidSave == true {
            sendManager.send(currentPostcard: postcardToSave)
        }
    }
}


extension AddBondStage2ViewController: SendManagerDelegate {
    func manager(manager: SendManager, postcardDidSent: Bool) {
        
        let alert = UIAlertController(title: "Success!", message: "This message will be delivered to receiver by the time you wishes.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let action = UIAlertAction(title: "Thanks!", style: UIAlertActionStyle.Default, handler: { action in
            
            self.tabBarController?.selectedIndex = 3
            
            let allViewController: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            
            for aviewcontroller in allViewController {
                if aviewcontroller.isKindOfClass(ContactsViewController) {
                    self.navigationController?.popToViewController(aviewcontroller, animated: true)
                }
            }
        })
        
        alert.addAction(action)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}


