//
//  UserInfo.swift
//  SMSCount
//
//  Created by Eddie on 10/26/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import Parse

class UserInfo { // Save userInfomation to Parse

    let userPreference = NSUserDefaults( suiteName: "group.EddieWen.SMSCount" )!

    var objectIdStatus: Bool = false
    let userObject = PFObject(className: "User")

    init() {
        // Initialize
        self.addUserObjectId()
    }

    private func addUserObjectId() {
        if objectIdStatus == false && self.userPreference.stringForKey("UserID") != nil {
            self.userObject.objectId = self.userPreference.stringForKey("UserID")
            self.objectIdStatus = true
        }
    }
    

}
