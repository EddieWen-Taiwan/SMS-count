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

        // Note to parse this is iOS
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

        userObject.deleteInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in

            self.userPreference.setObject( objectId, forKey: "UserID" )
            self.userObject.objectId = objectId
            self.objectIdStatus = true
            self.objectIsChanged = true

        }

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

    func updateWeekendFixed( fixed: Bool ) {
        self.userPreference.setBool( fixed, forKey: "autoWeekendFixed" )
        userObject.setObject( fixed, forKey: "weekendDischarge" )
        self.objectIsChanged = true
    }

    func updatePublicProfile( public_show: Bool ) {
        self.userPreference.setBool( public_show, forKey: "publicProfile" )
        userObject.setObject( public_show, forKey: "publicProfile" )
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
        // stringForKey could be nil and integerForKey couldn't
        if self.userPreference.stringForKey("serviceDays") != nil {
            userObject.setObject( self.userPreference.integerForKey("serviceDays"), forKey: "serviceDays" )
        }
        if self.userPreference.stringForKey("discountDays") != nil {
            userObject.setObject( self.userPreference.integerForKey("discountDays"), forKey: "discountDays" )
        }
        userObject.setObject( self.userPreference.boolForKey("autoWeekendFixed"), forKey: "weekendDischarge" )
        userObject.setObject( self.userPreference.boolForKey("publicProfile"), forKey: "publicProfile" )

        self.objectIsChanged = true
        // Save to Parse
        self.save()

    }

    // Call this after app gets the login result from facebook
    func storeFacebookInfo( info: AnyObject, completion: ((messageContent: String, newStatus: String, newEnterDate: String, newServiceDays: Int, newDiscountDays: Int, newWeekendFixed: Bool, newPublicProfile: Bool) -> Void) ) {

        if let FBID = info.valueForKey("id") {
            // Search parse data by FBID, check whether there is matched data.
            let fbIdQuery = PFQuery(className: "UserT")
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
                            var newPublicProfile: Bool = false

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

                            completion( messageContent: messageContent, newStatus: newStatus, newEnterDate: newEnterDate, newServiceDays: newServiceDays, newDiscountDays: newDiscountDays, newWeekendFixed: newWeekendFixed, newPublicProfile: newPublicProfile)

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
