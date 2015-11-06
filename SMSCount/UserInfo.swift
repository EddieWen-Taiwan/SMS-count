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

    // From Facebook API
    // Add user infomation: ID, name, email
    func addUserFBID( fbid: String ) {

        self.checkObjectId()

        self.userObject.setObject( fbid, forKey: "fb_id" )
        self.userPreference.setObject( fbid, forKey: "fb_id" )
        self.objectIsChanged = true
    }

    func addUserName( name: String ) {
        self.userObject.setObject( name, forKey: "username" )
        self.userPreference.setObject( name, forKey: "username" )
        self.objectIsChanged = true
    }

    func addUserMail( mail: String ) {
        self.userObject.setObject( mail, forKey: "email" )
        self.objectIsChanged = true
    }

    // This user has registered on Parse
    // Update the objectId in app
    func updateLocalObjectId( objectId: String ) {
        self.userPreference.setObject( objectId, forKey: "UserID" )
        self.userObject.objectId = objectId
        self.objectIdStatus = true
        self.objectIsChanged = true
    }

    func updateUserStatus( status: String ) {
        
    }

    // Update the username in app
    func updateLocalUsername( name: String ) {
        self.userPreference.setObject( name, forKey: "username" )
    }

    func updateEnterDate( date: String ) {
        let userEnterArray = self.split2Int( date )
        userObject.setObject( userEnterArray[0], forKey: "yearOfEnterDate" )
        userObject.setObject( userEnterArray[1], forKey: "monthOfEnterDate" )
        userObject.setObject( userEnterArray[2], forKey: "dateOfEnterDate" )
        self.objectIsChanged = true
    }

    func updateServiceDays( days: Int ) {
        self.userObject.setObject( days, forKey: "serviceDays" )
        self.objectIsChanged = true
    }

    func updateDiscountDays( days: Int ) {
        self.userObject.setObject( days, forKey: "discountDays" )
        self.objectIsChanged = true
    }

    // Save local data to Parse
    func save() {
        if self.objectIdStatus && self.objectIsChanged {
            self.userObject.saveInBackground()
            self.objectIsChanged = false
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

            userObject.saveInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
                if success {
                    self.userPreference.setObject( self.userObject.objectId, forKey: "UserID" )
                    self.userObject.objectId = self.userObject.objectId
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
