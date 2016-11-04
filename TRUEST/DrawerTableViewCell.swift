//
//  DrawerUIViewTableViewCell.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/5.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import UIKit

class DrawerTableViewCell: UITableViewCell {

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

extension DrawerTableViewCell {
    private func setup() {
        
        ContentView.backgroundColor = UIColor.SD_BackgroudWhite_EEEEEE()
        
        cellBackground.backgroundColor = UIColor.SD_CellBackgroudGray_D8D8D8()
        cellBackground.layer.borderColor = UIColor.SD_CellBorderGreen_60AB81().CGColor
        cellBackground.layer.borderWidth = 5.0
        cellBackground.layer.cornerRadius = cellBackground.frame.height / 2
        cellBackground.clipsToBounds = true
        
        title.frame = CGRectMake(122, 30, 180, 30)
        title.backgroundColor = UIColor.clearColor()
        title.font = UIFont(name: "Avenir Next", size: 14)
        
        receivers.frame = CGRectMake(122, 65, 100, 30)
        receivers.backgroundColor = UIColor.clearColor()
        receivers.font = UIFont(name: "Zapfino", size: 12)

        lastEditedLabel.frame = CGRectMake(20, 100, 320, 20)
        lastEditedLabel.backgroundColor = UIColor.clearColor()
        lastEditedLabel.textAlignment = .Right
        lastEditedLabel.font = UIFont(name: "Avenir Next", size: 12)
        
        titleImage.frame = CGRectMake(95, 32.5, 25, 25)
        titleImage.image = UIImage(named: "thread_title")!
        titleImage.tintColor = UIColor.SD_ImageTintGray_979797()
        
        receiverImage.frame = CGRectMake(95, 65, 25, 25)
        receiverImage.image = UIImage(named: "circle(group)")
        
        conditionImage.frame = CGRectMake(222, 35, 50, 50)
        conditionImage.image = UIImage(named: "time condition")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        conditionImage.tintColor = UIColor.SD_CellBorderGreen_60AB81()
        
        let urgency = UIImage(named: "Exclamation")
        urgencyImage.frame = CGRect(center: CGPoint(x: 300, y: 60), size: CGSize(width: 50, height: 50))
        urgencyImage.image = urgency
        urgencyImage.opaque = false
        
        self.ContentView.addSubview(cellBackground)
        self.ContentView.addSubview(title)
        self.ContentView.addSubview(imageInSmall)
        self.ContentView.addSubview(lastEditedLabel)
        self.ContentView.addSubview(titleImage)
        self.ContentView.addSubview(receiverImage)
//        self.ContentView.addSubview(conditionImage)
//        self.ContentView.addSubview(urgencyImage)
        self.ContentView.addSubview(receivers)
    }
}

