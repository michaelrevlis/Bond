//
//  Manager.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/3.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//
import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import FBSDKCoreKit
import CoreData




class FirebaseDatabaseRef {
    static let shared = FIRDatabase.database().reference()
}

class FirebaseStorageRef {
    static let shared = FIRStorage.storage().reference()
}




//以後要把downloadPostcards寫在背景執行
//func downloadPostcards() {
//    firebaseStorageRef.shared.child("-KTm_8FrWO9NfS-6lN5b").dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
//        if error != nil {
//            print("error in downloading postcard")
//        } else {
//            print("data")
//            print(data)
//        }
//    }
//}



