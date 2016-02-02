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
            userObject.objectId = self.userPreference.stringForKey("UserID")
            self.objectIdStatus = true
        }

        // Note to parse this is iOS
        userObject.setValue( "iOS", forKey: "platform" )
    }

    // From Facebook API
    // Add user infomation: ID, name, email
    func addUserFBID( fbid: String ) {

        self.checkObjectId()

        userObject.setValue( fbid, forKey: "fb_id" )
        self.userPreference.setValue( fbid, forKey: "fb_id" )
        self.objectIsChanged = true
    }

    func addUserName( name: String ) {
        userObject.setValue( name, forKey: "username" )
        self.userPreference.setValue( name, forKey: "username" )
        self.objectIsChanged = true
    }

    func addUserMail( mail: String ) {
        userObject.setValue( mail, forKey: "email" )
        self.userPreference.setValue( mail, forKey: "email" )
        self.objectIsChanged = true
    }

    // This user has registered on Parse
    // Update the objectId in app
    func updateLocalObjectId( objectId: String ) {

        userObject.deleteInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in

            self.userPreference.setValue( objectId, forKey: "UserID" )
            self.userObject.objectId = objectId
            self.objectIdStatus = true
            self.objectIsChanged = true

        }

    }

    func updateUserStatus( status: String ) {
        userObject.setValue( status, forKey: "status" )
        self.userPreference.setValue( status, forKey: "status" )
        self.objectIsChanged = true
    }

    // Update the username in app
    func updateLocalUsername( name: String ) {
        self.userPreference.setValue( name, forKey: "username" )
    }

    func updateLocalMail( mail: String ) {
        self.userPreference.setValue( mail, forKey: "email" )
    }

    func updateEnterDate( date: String ) {
        self.userPreference.setValue( date, forKey: "enterDate" )
        let userEnterArray = self.split2Int( date )
        userObject.setValue( userEnterArray[0], forKey: "yearOfEnterDate" )
        userObject.setValue( userEnterArray[1], forKey: "monthOfEnterDate" )
        userObject.setValue( userEnterArray[2], forKey: "dateOfEnterDate" )
        self.objectIsChanged = true
    }

    func updateServiceDays( days: Int ) {
        userObject.setValue( days, forKey: "serviceDays" )
        self.objectIsChanged = true
    }

    func updateDiscountDays( days: Int ) {
        userObject.setValue( days, forKey: "discountDays" )
        self.objectIsChanged = true
    }

    func updateWeekendFixed( fixed: Bool ) {
        self.userPreference.setBool( fixed, forKey: "autoWeekendFixed" )
        userObject.setValue( fixed, forKey: "weekendDischarge" )
        self.objectIsChanged = true
    }

    func updateAnimationSetting( animation: Bool ) {
        self.userPreference.setBool( animation, forKey: "countdownAnimation" )
//        userObject.setValue( animation, forKey: "countdownAnimation" )
//        self.objectIsChanged = true
    }

    func updatePublicProfile( public_show: Bool ) {
        self.userPreference.setBool( public_show, forKey: "publicProfile" )
        userObject.setValue( public_show, forKey: "publicProfile" )
        self.objectIsChanged = true
    }

    // Save local data to Parse
    func save() {

        if self.objectIsChanged {

            self.userPreference.setBool( false, forKey: "dayAnimated" )
            self.objectIsChanged = false

            if self.objectIdStatus {
                userObject.saveEventually()
            }

        }

    }

    // There is not completed task at last time, continue to do it
    func uploadAllData() {

        if let fbid = self.userPreference.stringForKey("fb_id") {
            userObject.setValue( fbid, forKey: "fb_id" )
        }
        if let name = self.userPreference.stringForKey("username") {
            userObject.setValue( name, forKey: "username" )
        }
        if let mail = self.userPreference.stringForKey("email") {
            userObject.setValue( mail, forKey: "email" )
        }
        if let userStatus = self.userPreference.stringForKey("status") {
            userObject.setValue( userStatus, forKey: "status" )
        }
        if let userEnterDate: NSString = self.userPreference.stringForKey("enterDate") {
            let userEnterArray = self.split2Int(userEnterDate)
            userObject.setValue( userEnterArray[0], forKey: "yearOfEnterDate" )
            userObject.setValue( userEnterArray[1], forKey: "monthOfEnterDate" )
            userObject.setValue( userEnterArray[2], forKey: "dateOfEnterDate" )
        }
        // stringForKey could be nil and integerForKey couldn't
        if self.userPreference.valueForKey("serviceDays") != nil {
            userObject.setValue( self.userPreference.integerForKey("serviceDays"), forKey: "serviceDays" )
        }
        if self.userPreference.valueForKey("discountDays") != nil {
            userObject.setValue( self.userPreference.integerForKey("discountDays"), forKey: "discountDays" )
        }
        userObject.setValue( self.userPreference.boolForKey("autoWeekendFixed"), forKey: "weekendDischarge" )
        userObject.setValue( self.userPreference.boolForKey("publicProfile"), forKey: "publicProfile" )

        self.objectIsChanged = true
        // Save to Parse
        self.save()

    }

    // Call this after app gets the login result from facebook
    func storeFacebookInfo( info: AnyObject, syncCompletion: ((messageContent: String, newStatus: String, newEnterDate: String, newServiceDays: Int, newDiscountDays: Int, newWeekendFixed: Bool, newPublicProfile: Bool) -> Void), newUserTask: () -> Void ) {

        if let FBID = info.valueForKey("id") {
            // Search parse data by FBID, check whether there is matched data.
            let fbIdQuery = PFQuery(className: "User")
            fbIdQuery.whereKey( "fb_id", equalTo: FBID )
            fbIdQuery.findObjectsInBackgroundWithBlock{ (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {

                    self.addUserFBID( FBID as! String )

                    if objects!.count > 0 {
                        // User has registerd.
                        if let user = objects!.first {

                            if let userID = user.objectId {
                                self.updateLocalObjectId( userID )
                            }
                            if let username = user.valueForKey("username") {
                                self.updateLocalUsername(username as! String)
                            }
                            if let userMail = user.valueForKey("email") {
                                self.updateLocalMail( userMail as! String )
                            }

                            // Make message of detail data
                            var messageContent = ""
                            var newEnterDate = ""
                            var newServiceDays: Int = -1
                            var newDiscountDays: Int = -1
                            var newStatus = ""
                            var newWeekendFixed: Bool = false
                            var newPublicProfile: Bool = true

                            if user.valueForKey("status") != nil {
                                newStatus = user.valueForKey("status") as! String
                            }
                            if let year = user.valueForKey("yearOfEnterDate") {
                                let month = ( (user.valueForKey("monthOfEnterDate") as! Int) < 10 ? "0" : "" ) + String(user.valueForKey("monthOfEnterDate")!)
                                let date = ( (user.valueForKey("dateOfEnterDate") as! Int) < 10 ? "0" : "" ) + String(user.valueForKey("dateOfEnterDate")!)
                                // Store data
                                newEnterDate = "\(year) / \(month) / \(date)"
                                messageContent += "入伍日期：\(newEnterDate)\n"
                            }
                            if let service = user.valueForKey("serviceDays") {
                                // Store data
                                newServiceDays = service as! Int
                                let serviceStr: String = CalculateHelper().switchPeriod( String(service) )
                                messageContent += "役期天數：\(serviceStr)\n"
                            }
                            if let discount = user.valueForKey("discountDays") {
                                // Store data
                                newDiscountDays = discount as! Int
                                messageContent += "折抵天數：\(discount)天"
                            }
                            if let weekendFixed = user.valueForKey("weekendDischarge") {
                                newWeekendFixed = weekendFixed as! Bool
                            }
                            if let publicProfile = user.valueForKey("publicProfile") {
                                newPublicProfile = publicProfile as! Bool
                            }

                            syncCompletion( messageContent: messageContent, newStatus: newStatus, newEnterDate: newEnterDate, newServiceDays: newServiceDays, newDiscountDays: newDiscountDays, newWeekendFixed: newWeekendFixed, newPublicProfile: newPublicProfile)

                        }
                    } else {
                        // New user
                        // Update user email, name .... by objectId

                        if let userName = info.valueForKey("name") {
                            self.addUserName( userName as! String )
                        }
                        if let userMail = info.valueForKey("email") {
                            self.addUserMail( userMail as! String )
                        }
                        self.save()

                        // Remove old view or nothing
                        newUserTask()
                    }

                }
            }
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

                userObject.setValue( userEnterArray[0], forKey: "yearOfEnterDate" )
                userObject.setValue( userEnterArray[1], forKey: "monthOfEnterDate" )
                userObject.setValue( userEnterArray[2], forKey: "dateOfEnterDate" )
            }
            if let userService = userPreference.stringForKey("serviceDays") {
                userObject.setValue( Int(userService)!, forKey: "serviceDays" )
            }
            if let userDiscount = userPreference.stringForKey("discountDays") {
                userObject.setValue( Int(userDiscount)!, forKey: "discountDays" )
            }

            userObject.saveInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
                if success {
                    self.userPreference.setValue( self.userObject.objectId, forKey: "UserID" )
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
