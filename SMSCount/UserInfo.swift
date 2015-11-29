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
    let userObject = PFObject(className: "UserT")

    init() {
        // Initialize
        if self.userPreference.stringForKey("UserID") != nil {
            userObject.objectId = self.userPreference.stringForKey("UserID")
            self.objectIdStatus = true
        }
        userObject.setObject( "iOS", forKey: "platform" )
    }

    // From Facebook API
    // Add user infomation: ID, name, email
    func addUserFBID( fbid: String ) {

        self.checkObjectId()

        userObject.setObject( fbid, forKey: "fb_id" )
        self.userPreference.setObject( fbid, forKey: "fb_id" )
        self.objectIsChanged = true
    }

    func addUserName( name: String ) {
        userObject.setObject( name, forKey: "username" )
        self.userPreference.setObject( name, forKey: "username" )
        self.objectIsChanged = true
    }

    func addUserMail( mail: String ) {
        userObject.setObject( mail, forKey: "email" )
        self.userPreference.setObject( mail, forKey: "email" )
        self.objectIsChanged = true
    }

    // This user has registered on Parse
    // Update the objectId in app
    func updateLocalObjectId( objectId: String ) {
        self.userPreference.setObject( objectId, forKey: "UserID" )
        userObject.objectId = objectId
        self.objectIdStatus = true
        self.objectIsChanged = true
    }

    func updateUserStatus( status: String ) {
        userObject.setObject( status, forKey: "status" )
        self.userPreference.setObject( status, forKey: "status" )
        self.objectIsChanged = true
    }

    // Update the username in app
    func updateLocalUsername( name: String ) {
        self.userPreference.setObject( name, forKey: "username" )
    }

    func updateLocalMail( mail: String ) {
        self.userPreference.setObject( mail, forKey: "email" )
    }

    func updateEnterDate( date: String ) {
        self.userPreference.setObject( date, forKey: "enterDate" )
        let userEnterArray = self.split2Int( date )
        userObject.setObject( userEnterArray[0], forKey: "yearOfEnterDate" )
        userObject.setObject( userEnterArray[1], forKey: "monthOfEnterDate" )
        userObject.setObject( userEnterArray[2], forKey: "dateOfEnterDate" )
        self.objectIsChanged = true
    }

    func updateServiceDays( days: Int ) {
        userObject.setObject( days, forKey: "serviceDays" )
        self.objectIsChanged = true
    }

    func updateDiscountDays( days: Int ) {
        userObject.setObject( days, forKey: "discountDays" )
        self.objectIsChanged = true
    }

    // Save local data to Parse
    func save() {
        if self.objectIdStatus && self.objectIsChanged {
            self.userPreference.setObject( "no", forKey: "sync" )
            userObject.saveInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
                if success {
                    self.userPreference.removeObjectForKey("sync")
                }
            }
            self.objectIsChanged = false
        }
    }

    // There is not completed task at last time, continue to do it
    func continueTask() {

        if let fbid = self.userPreference.stringForKey("fb_id") {
            userObject.setObject( fbid, forKey: "fb_id" )
        }
        if let name = self.userPreference.stringForKey("username") {
            userObject.setObject( name, forKey: "username" )
        }
        if let mail = self.userPreference.stringForKey("email") {
            userObject.setObject( mail, forKey: "email" )
        }
        if let userStatus = self.userPreference.stringForKey("status") {
            userObject.setObject( userStatus, forKey: "status" )
        }
        if let userEnterDate: NSString = self.userPreference.stringForKey("enterDate") {
            let userEnterArray = self.split2Int(userEnterDate)
            userObject.setObject( userEnterArray[0], forKey: "yearOfEnterDate" )
            userObject.setObject( userEnterArray[1], forKey: "monthOfEnterDate" )
            userObject.setObject( userEnterArray[2], forKey: "dateOfEnterDate" )
        }
        if self.userPreference.stringForKey("serviceDays") != nil {
            userObject.setObject( self.userPreference.integerForKey("serviceDays"), forKey: "serviceDays" )
        }
        if self.userPreference.stringForKey("discountDays") != nil {
            userObject.setObject( self.userPreference.integerForKey("discountDays"), forKey: "discountDays" )
        }

        // Save to Parse
        self.save()

    }

    private func checkObjectId() {
        if !self.objectIdStatus { self.registerNewUser() }
    }

    // Register a new user data in Parse
    // And save objectId in local userPreference
    func registerNewUser() {

        if Reachability().isConnectedToNetwork() {

            if let userEnter: NSString = userPreference.stringForKey("enterDate") {
                let userEnterArray = self.split2Int(userEnter)

                userObject.setObject( userEnterArray[0], forKey: "yearOfEnterDate" )
                userObject.setObject( userEnterArray[1], forKey: "monthOfEnterDate" )
                userObject.setObject( userEnterArray[2], forKey: "dateOfEnterDate" )
            }
            if let userService = userPreference.stringForKey("serviceDays") {
                userObject.setObject( Int(userService)!, forKey: "serviceDays" )
            }
            if let userDiscount = userPreference.stringForKey("discountDays") {
                userObject.setObject( Int(userDiscount)!, forKey: "discountDays" )
            }

            // Note to parse this is iOS
            userObject.setObject( "iOS", forKey: "platform" )

            userObject.saveInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
                if success {
                    self.userPreference.setObject( self.userObject.objectId, forKey: "UserID" )
                    self.objectIdStatus = true
                }
            }

        }

    }

    // private
    func split2Int( string: NSString ) -> NSArray {
        var splitArray: [Int] = []

        let year = string.substringToIndex(4)
        let month = string.substringWithRange(NSMakeRange(7, 2))
        let date = string.substringFromIndex(12)

        splitArray.append( Int(year)! )
        splitArray.append( Int(month)! )
        splitArray.append( Int(date)! )

        return splitArray
    }

}
