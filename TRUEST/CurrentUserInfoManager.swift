//
//  CurrentUserInfoManager.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/25.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import Foundation


class CurrentUserInfoManager {
    
    static let shared = CurrentUserInfoManager()
    
    private(set) var currentUserNode = String()
    private(set) var currentUserName = String()
    private(set) var currentUserPictureUrl = String()
    private let userDefault = NSUserDefaults.standardUserDefaults()
    
    func currentUserInfoInit() {
        self.currentUserNode = userDefault.stringForKey("user_userNode") as String!
        self.currentUserName = userDefault.stringForKey("user_name") as String!
        self.currentUserPictureUrl = userDefault.stringForKey("user_pictureUrl") as String!
 
    }
}