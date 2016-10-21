//
//  MailboxTableViewCell.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/12.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import UIKit

class MailboxTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var ContentView: UIView!
    var cellBackground = UILabel(frame: CGRectMake(20, 20, 320, 80))
    var imageInSmall = UIImageView()
    var title = UILabel()
    var receivers = UILabel()
    private var titleImage = UIImageView()
    private var receiverImage = UIImageView()
    private var conditionImage = UIImageView()
    private var urgencyImage = UIImageView()
    var lastEditedLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
        
    }
    
}

extension MailboxTableViewCell {
    private func setup() {
        
        ContentView.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        
        cellBackground.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1)
        cellBackground.layer.borderColor = UIColor(red: 96/255, green: 171/255, blue: 129/255, alpha: 1).CGColor
        cellBackground.layer.borderWidth = 5.0
        cellBackground.layer.cornerRadius = cellBackground.frame.height / 2
        cellBackground.clipsToBounds = true
        
        title.frame = CGRectMake(122, 30, 100, 30)
        title.backgroundColor = UIColor.clearColor()
        
        receivers.frame = CGRectMake(122, 65, 100, 30)
        receivers.backgroundColor = UIColor.clearColor()
        
        lastEditedLabel.frame = CGRectMake(20, 100, 320, 20)
        lastEditedLabel.backgroundColor = UIColor.clearColor()
        lastEditedLabel.textAlignment = .Right
        
        titleImage.frame = CGRectMake(95, 32.5, 25, 25)
        titleImage.image = UIImage(named: "thread_title")!//.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        titleImage.tintColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1)
        
        receiverImage.frame = CGRectMake(95, 65, 25, 25)
        receiverImage.image = UIImage(named: "circle(group)")
        receiverImage.tintColor = UIColor.grayColor()
        
        conditionImage.frame = CGRectMake(222, 35, 50, 50)
        conditionImage.image = UIImage(named: "time condition")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        conditionImage.tintColor = UIColor(red: 96/255, green: 171/255, blue: 129/255, alpha: 1)
        
        let urgency = UIImage(named: "Exclamation")
        urgencyImage.frame = CGRect(center: CGPoint(x: 300, y: 60), size: CGSize(width: 50, height: 50))
        //            CGRectMake(272, 35, 45, 45)
        urgencyImage.image = urgency
        urgencyImage.opaque = false
        //        urgencyImage.backgroundColor = UIColor.clearColor()
        
        
        self.ContentView.addSubview(cellBackground)
        self.ContentView.addSubview(title)
        self.ContentView.addSubview(imageInSmall)
        self.ContentView.addSubview(lastEditedLabel)
        self.ContentView.addSubview(titleImage)
        self.ContentView.addSubview(receiverImage)
        self.ContentView.addSubview(conditionImage)
        self.ContentView.addSubview(urgencyImage)
        self.ContentView.addSubview(receivers)
    }



}
