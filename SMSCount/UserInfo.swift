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

    var objectIsChanged: Bool
    var objectIdStatus: Bool
    let userObject = PFObject(className: SecretCode.classNameInParse)

    init() {
        // Initialize
        self.objectIsChanged = false
        self.objectIdStatus = false

        if userPreference.stringForKey("UserID") != nil {
            self.userObject.objectId = userPreference.stringForKey("UserID")
            self.objectIdStatus = true
        }

        // Note to parse this is iOS
        self.userObject.setValue( "iOS", forKey: "platform" )
    }

    // From Facebook API
    // Add user infomation: ID, name, email
    func addUserFBID( fbid: String ) {

        checkObjectId()
        
        userPreference.setValue( fbid, forKey: "fb_id" )
        userObject.setValue( fbid, forKey: "fb_id" )
        objectIsChanged = true
    }

    func addUserName( name: String ) {
        userPreference.setValue( name, forKey: "username" )
        userObject.setValue( name, forKey: "username" )
        objectIsChanged = true
    }

    func addUserMail( mail: String ) {
        userPreference.setValue( mail, forKey: "email" )
        userObject.setValue( mail, forKey: "email" )
        objectIsChanged = true
    }

    // This user has registered on Parse
    // Update the objectId in app
    func updateLocalObjectId( objectId: String ) {

        userObject.deleteInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in

            self.userPreference.setValue( objectId, forKey: "UserID" )
            self.userObject.objectId = objectId
            self.objectIsChanged = true
            self.objectIdStatus = true

        }

    }

    func updateUserStatus( status: String ) {
        userPreference.setValue( status, forKey: "status" )
        userObject.setValue( status, forKey: "status" )
        objectIsChanged = true
    }

    // Update the username in app
    func updateLocalUsername( name: String ) {
        userPreference.setValue( name, forKey: "username" )
    }

    func updateLocalMail( mail: String ) {
        userPreference.setValue( mail, forKey: "email" )
    }

    func updateEnterDate( date: String ) {
        userPreference.setValue( date, forKey: "enterDate" )
        let userEnterArray = split2Int( date )
        userObject.setValue( userEnterArray[0], forKey: "yearOfEnterDate" )
        userObject.setValue( userEnterArray[1], forKey: "monthOfEnterDate" )
        userObject.setValue( userEnterArray[2], forKey: "dateOfEnterDate" )
        objectIsChanged = true
    }

    func updateServiceDays( days: Int ) {
        userObject.setValue( days, forKey: "serviceDays" )
        objectIsChanged = true
    }

    func updateDiscountDays( days: Int ) {
        userObject.setValue( days, forKey: "discountDays" )
        objectIsChanged = true
    }

    func updateWeekendFixed( fixed: Bool ) {
        userPreference.setBool( fixed, forKey: "autoWeekendFixed" )
        userObject.setValue( fixed, forKey: "weekendDischarge" )
        objectIsChanged = true
    }

    func updateAnimationSetting( animation: Bool ) {
        userPreference.setBool( animation, forKey: "countdownAnimation" )
//        userObject.setValue( animation, forKey: "countdownAnimation" )
//        objectIsChanged = true
    }

    func updatePublicProfile( public_show: Bool ) {
        userPreference.setBool( public_show, forKey: "publicProfile" )
        userObject.setValue( public_show, forKey: "publicProfile" )
        objectIsChanged = true
    }

    // Save local data to Parse
    func save() {

        if objectIsChanged {

            userPreference.setBool( false, forKey: "dayAnimated" )
            objectIsChanged = false

            if objectIdStatus {
                userObject.saveEventually()
            }

        }

    }

    // There is not completed task at last time, continue to do it
    func uploadAllData() {

        if let fbid = userPreference.stringForKey("fb_id") {
            userObject.setValue( fbid, forKey: "fb_id" )
        }
        if let name = userPreference.stringForKey("username") {
            userObject.setValue( name, forKey: "username" )
        }
        if let mail = userPreference.stringForKey("email") {
            userObject.setValue( mail, forKey: "email" )
        }
        if let userStatus = userPreference.stringForKey("status") {
            userObject.setValue( userStatus, forKey: "status" )
        }
        if let userEnterDate: NSString = userPreference.stringForKey("enterDate") {
            let userEnterArray = split2Int(userEnterDate)
            userObject.setValue( userEnterArray[0], forKey: "yearOfEnterDate" )
            userObject.setValue( userEnterArray[1], forKey: "monthOfEnterDate" )
            userObject.setValue( userEnterArray[2], forKey: "dateOfEnterDate" )
        }
        // stringForKey could be nil and integerForKey couldn't
        if userPreference.valueForKey("serviceDays") != nil {
            userObject.setValue( userPreference.integerForKey("serviceDays"), forKey: "serviceDays" )
        }
        if userPreference.valueForKey("discountDays") != nil {
            userObject.setValue( userPreference.integerForKey("discountDays"), forKey: "discountDays" )
        }
        userObject.setValue( userPreference.boolForKey("autoWeekendFixed"), forKey: "weekendDischarge" )
        userObject.setValue( userPreference.boolForKey("publicProfile"), forKey: "publicProfile" )

        objectIsChanged = true
        // Save to Parse
        save()

    }

    // Call this after app gets the login result from facebook
    func storeFacebookInfo( info: AnyObject, syncCompletion: ((messageContent: String, newStatus: String, newEnterDate: String, newServiceDays: Int, newDiscountDays: Int, newWeekendFixed: Bool, newPublicProfile: Bool) -> Void), newUserTask: () -> Void ) {

        if let FBID = info.valueForKey("id") {
            // Search parse data by FBID, check whether there is matched data.
            let fbIdQuery = PFQuery(className: SecretCode.classNameInParse)
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
        if !objectIdStatus { registerNewUser() }
    }

    // Register a new user data in Parse
    // And save objectId in local userPreference
    func registerNewUser() {

        if Reachability().isConnectedToNetwork() {

            if let userEnter: NSString = userPreference.stringForKey("enterDate") {
                let userEnterArray = split2Int(userEnter)

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

    private func split2Int( string: NSString ) -> NSArray {
        var splitArray = [Int]()

        if let year = Int( string.substringToIndex(4) ) {
            splitArray.append( year )
        }
        if let month = Int( string.substringWithRange(NSMakeRange(7, 2)) ) {
            splitArray.append( month )
        }
        if let date = Int( string.substringFromIndex(12) ) {
            splitArray.append( date )
        }

        return splitArray
    }

}
