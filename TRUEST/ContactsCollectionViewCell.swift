//
//  ContactsTableViewCell.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/13.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import UIKit

class ContactsCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var ContentView: UIView!
    var imageInSmall = UIImageView()
    var contactName = UILabel()
    private let imageShadow = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    
    func setup() {
        // each cell is 110 * 110
        imageInSmall.frame = CGRect(center: CGPoint(x: 55, y: 40), size: CGSize(width: 70, height: 70))
        imageInSmall.backgroundColor = UIColor.whiteColor()
        imageInSmall.contentMode = .ScaleAspectFill
        imageInSmall.clipsToBounds = true
        imageInSmall.layer.masksToBounds = true
        imageInSmall.layer.cornerRadius = imageInSmall.frame.height / 2
        
        imageShadow.frame = CGRect(center: CGPoint(x: 55, y: 40), size: CGSize(width: 70, height: 70))
        imageShadow.layer.shadowColor = UIColor.blackColor().CGColor
        imageShadow.layer.shadowOpacity = 1.0
        imageShadow.layer.shadowPath = UIBezierPath(roundedRect: imageInSmall.bounds, cornerRadius: 35).CGPath
        imageShadow.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        
        contactName.frame = CGRectMake(5, 80, 100, 30)
        contactName.textAlignment = .Center
        
        self.ContentView.addSubview(imageShadow)
        self.ContentView.addSubview(imageInSmall)
        self.ContentView.addSubview(contactName)
        
    }
}
