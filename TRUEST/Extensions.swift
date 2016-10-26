//
//  Extensions.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/24.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//


import Foundation
import UIKit


// 讓宣告CGRect時能以圖案的中心為基準，而非左上角
extension CGRect {
    init(center: CGPoint, size: CGSize) {
        let originX = center.x - (size.width / 2)
        let originY = center.y - (size.height / 2)
        self.init(origin: CGPoint(x: originX, y: originY), size: size)
    }
}


// 用來判斷前者的日期是否早於後者
extension NSDate {
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        
        var isLess = false
        
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        
        return isLess
    }
}


// String -> NSData
func stringToNSData(sourceString: String) -> NSData{
    
    if let url = NSURL(string: sourceString) {
        if let data = NSData(contentsOfURL: url) {
            return data
        }
    }
    return NSData()
}


// 嘗試將開啟新UIViewController做成一個func
func switchViewController(from originalViewController: UIViewController, to identifierOfDestinationViewController: String!) {
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    let destinationViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier(identifierOfDestinationViewController)
    
    destinationViewController.modalPresentationStyle = .CurrentContext
    destinationViewController.modalTransitionStyle = .CoverVertical
    
    originalViewController.presentViewController(destinationViewController, animated: true, completion: nil)
}



// 無需動作的警告視窗
func showErrorAlert(viewController: UIViewController, title: String, msg: String) {
    let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
    alert.addAction(action)
    viewController.presentViewController(alert, animated: true, completion: nil)
}

