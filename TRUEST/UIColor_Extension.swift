//
//  Extension.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/23.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexString: String) {
        let hex = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        var int = UInt32()
        NSScanner(string: hex).scanHexInt(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    
    class func SD_BackgroudWhite_EEEEEE() -> UIColor {
        return UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
    }
    
    class func SD_CellBackgroudGray_D8D8D8() -> UIColor {
        return UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1)
    }
    
    class func SD_CellBorderGreen_60AB81() -> UIColor {
        return UIColor(red: 96/255, green: 171/255, blue: 129/255, alpha: 1)
    }
    
    class func SD_ImageTintGray_979797() -> UIColor {
        return UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
    }
}

