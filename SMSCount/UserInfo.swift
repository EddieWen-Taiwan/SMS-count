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

    func addUserFBID( fbid: String ) {

        self.checkObjectId()

        self.userObject.setObject( fbid, forKey: "fb_id" )
        self.objectIsChanged = true
    }

    func addUserName( name: String ) {
        self.userObject.setObject( name, forKey: "username" )
        self.objectIsChanged = true
    }

    func addUserMail( mail: String ) {
        self.userObject.setObject( mail, forKey: "email" )
        self.objectIsChanged = true
    }

    func updateLocalObjectId( objectId: String ) {
        self.userPreference.setObject( objectId, forKey: "UserID" )
        self.userObject.objectId = objectId
        self.objectIdStatus = true
        self.objectIsChanged = true
    }

    // Save local data to Parse
    func save() {
        if self.objectIdStatus && self.objectIsChanged {
            self.userObject.saveInBackground()
            self.objectIdStatus = false
        }
    }

    private func checkObjectId() {
        if !self.objectIdStatus { self.registerNewUser() }
    }

    // Register a new user data in Parse
    // And save objectId in local userPreference
    func registerNewUser() {

        if Reachability().isConnectedToNetwork() {

            if let userEnter: NSString = userPreference.stringForKey("enterDate") {
                let year = userEnter.substringToIndex(4)
                let month = userEnter.substringWithRange(NSMakeRange(7, 2))
                let date = userEnter.substringFromIndex(12)
                userObject.setObject( Int(year)!, forKey: "yearOfEnterDate" )
                userObject.setObject( Int(month)!, forKey: "monthOfEnterDate" )
                userObject.setObject( Int(date)!, forKey: "dateOfEnterDate" )
            }
            if let userService = userPreference.stringForKey("serviceDays") {
                userObject.setObject( Int(userService)!, forKey: "serviceDays" )
            }
            if let userDiscount = userPreference.stringForKey("discountDays") {
                userObject.setObject( Int(userDiscount)!, forKey: "discountDays" )
            }

            userObject.saveInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
                if success {
                    self.userPreference.setObject( self.userObject.objectId, forKey: "UserID" )
                    self.userObject.objectId = self.userObject.objectId
                    self.objectIdStatus = true
                }
            }
        }

    }

}
