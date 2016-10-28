//
//  SinglePostcard.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/28.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import UIKit

class SinglePostcardController: UIViewController {

    @IBOutlet weak var postcardImageView: UIImageView!
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var imageShadow: UILabel!
    @IBOutlet weak var postcardTitle: UILabel!
    @IBOutlet weak var postcardContext: UILabel!
    @IBOutlet weak var postcardSignature: UILabel!
    @IBOutlet weak var postcardDeliverTime: UILabel!
    @IBOutlet weak var NavigationItem: UINavigationItem!
    
    var theImage = NSData()
    var theTitle = String()
    var theContext = String()
    var theSignature = String()
    var theDeliverTime = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
}


extension SinglePostcardController {
    
    private func setup() {
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        let logoView = UIImageView()
        logoView.frame = CGRectMake(0, 0, 50, 70)
        logoView.contentMode = .ScaleAspectFit
        logoView.image = UIImage(named: "navi_logo")
        
        NavigationItem.titleView = logoView
        
        imageShadow.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        imageShadow.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).CGColor
        imageShadow.layer.shadowOpacity = 1.0
        imageShadow.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        
        postcardImageView.image = UIImage(data: theImage)
        
        titleImageView.image = UIImage(named: "thread_title")
        titleImageView.contentMode = .ScaleAspectFit
        
        postcardTitle.text = theTitle
        postcardTitle.font = UIFont(name: "Avenir Next", size: 14)
        
        postcardContext.text = theContext
        postcardContext.font = UIFont(name: "Avenir Next", size: 14)
        
        postcardSignature.text = theSignature
        postcardSignature.font = UIFont(name: "Zapfino", size: 12)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let receivedTime = dateFormatter.stringFromDate(theDeliverTime)
        postcardDeliverTime.text = receivedTime
        postcardDeliverTime.font = UIFont(name: "Avenir Next", size: 12)
        postcardDeliverTime.textColor = UIColor.lightGrayColor()
    }
    
}
