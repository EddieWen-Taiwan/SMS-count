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

    var objectIsChanged: Bool = false
    var objectIdStatus: Bool = false
    let userObject = PFObject(className: "User")

    init() {
        // Initialize
        self.addUserObjectId()
    }

    private func addUserObjectId() {
        if self.objectIdStatus == false && self.userPreference.stringForKey("UserID") != nil {
            self.userObject.objectId = self.userPreference.stringForKey("UserID")
            self.objectIdStatus = true
        }
    }

    func save() {
        if self.objectIsChanged {
            self.userObject.saveInBackground()
        }
    }

}
