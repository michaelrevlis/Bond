//
//  SendManager.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/27.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseCrash
import FirebaseAnalytics


class SendManager {
    
    // sent postcard to server
    private func send(currentPostcard currentPostcard: [PostcardInDrawer]) {
        // 在data base 並產生postcard's uid
        let postcardSentRef = FirebaseDatabaseRef.shared.child("postcards").childByAutoId()
        
        let postcardSentUid = postcardSentRef.key
        
        // 該圖片存在firebase storage上的名稱
        let imagePath = postcardSentUid
        
        // 將NSDate轉成String
        let dateFormatter = NSDateFormatter()
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
        
        /////////// saving image into firebase storage ///////////
        // 指定storage要存的相關資訊，在儲存到firebase storage前記得要去更改rule讓read,write = if true
        FirebaseStorageRef.shared.child(imagePath)
        
        // 定義上傳資料的metadata，以便日後去判斷此筆資料是image/audio/video，並呼叫對應的方始來開啟該檔案
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpg"
        
        //將照片存入storage中
        FirebaseStorageRef.shared.child(imagePath).putData(currentPostcard[0].image, metadata: metadata) { (metadata, error) in
            
            if let error = error {
                FIRCrashMessage("Error in upload image: \(error)")
                return
            } else {
                
                // get downloadURL
                let downloadUrl = metadata!.downloadURL()!.absoluteString
                
                // update postcard's image as its downloadURL
                FirebaseDatabaseRef.shared.child("postcards").child(postcardSentUid).updateChildValues(["image": downloadUrl])
            }
        }
        
        /////////// save bond ///////////
        let sendBond: [String: String] = [ "postcard": postcardSentUid, "receiver": currentPostcard[0].receiver, "sender": CurrentUserInfoManager.shared.currentUserNode ]
        
        let bondRef = FirebaseDatabaseRef.shared.child("bonds").childByAutoId()
        
        bondRef.setValue(sendBond)
        
        FIRAnalytics.logEventWithName("Postcard sent", parameters: nil)
    }
    
}


extension SendManager: SaveManagerDelegate {
    
    func manager(manager: SaveManager, postcardToSave: [PostcardInDrawer], newPostcardDidSave: Bool) {
        
        if newPostcardDidSave == true {
            send(currentPostcard: postcardToSave)
        }
    }
    
}