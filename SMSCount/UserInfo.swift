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
        if self.userPreference.stringForKey("UserID") != nil {
            self.userObject.objectId = self.userPreference.stringForKey("UserID")
            self.objectIdStatus = true
        }
    }

    private func addUserObjectId() {

        if self.objectIdStatus == false {
            self.registerNewUser()
        }

    }

    func updateLocalObjectId( objectId: String ) {
        self.userPreference.setObject( objectId, forKey: "UserID" )
        self.userObject.objectId = objectId
        self.objectIdStatus = true
        self.objectIsChanged = true
    }

    // Save local data to Parse
    func save() {
        if self.objectIsChanged {
            self.userObject.saveInBackground()
            self.objectIdStatus = false
        }
    }

    // Register a new user data in Parse
    // And save objectId in local userPreference
    func registerNewUser() {

        if Reachability().isConnectedToNetwork() {
            let newUser = PFObject(className: "User")

            if let userEnter: NSString = userPreference.stringForKey("enterDate") {
                let year = userEnter.substringToIndex(4)
                let month = userEnter.substringWithRange(NSMakeRange(7, 2))
                let date = userEnter.substringFromIndex(12)
                newUser["yearOfEnterDate"] = Int(year)
                newUser["monthOfEnterDate"] = Int(month)
                newUser["dateOfEnterDate"] = Int(date)
            }
            if let userService = userPreference.stringForKey("serviceDays") {
                newUser["serviceDays"] = Int(userService)
            }
            if let userDiscount = userPreference.stringForKey("discountDays") {
                newUser["discountDays"] = Int(userDiscount)
            }

            newUser.saveInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
                if success {
                    self.userPreference.setObject( newUser.objectId, forKey: "UserID" )
                    self.userObject.objectId = newUser.objectId
                    self.objectIdStatus = true
                }
            }
        }

    }

}
