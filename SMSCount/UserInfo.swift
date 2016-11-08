//
//  UserInfo.swift
//  SMSCount
//
//  Created by Eddie on 10/26/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import Parse

class UserInfo { // Save userInfomation to Parse

    let userPreference = UserDefaults( suiteName: "group.EddieWen.SMSCount" )!

    var objectIsChanged: Bool
    var objectIdStatus: Bool
    let userObject = PFObject(className: SecretCode.classNameInParse)

    init() {
        // Initialize
        self.objectIsChanged = false
        self.objectIdStatus = false

        if userPreference.string(forKey: "UserID") != nil {
            self.userObject.objectId = userPreference.string(forKey: "UserID")
            self.objectIdStatus = true
        }

        // Note to parse this is iOS
        self.userObject.setValue( "iOS", forKey: "platform" )
    }

    // From Facebook API
    // Add user infomation: ID, name, email
    func addUserFBID( _ fbid: String ) {

        checkObjectId()
        
        userPreference.setValue( fbid, forKey: "fb_id" )
        userObject.setValue( fbid, forKey: "fb_id" )
        objectIsChanged = true
    }

    func addUserName( _ name: String ) {
        userPreference.setValue( name, forKey: "username" )
        userObject.setValue( name, forKey: "username" )
        objectIsChanged = true
    }

    func addUserMail( _ mail: String ) {
        userPreference.setValue( mail, forKey: "email" )
        userObject.setValue( mail, forKey: "email" )
        objectIsChanged = true
    }

    // This user has registered on Parse
    // Update the objectId in app
    func updateLocalObjectId( _ objectId: String ) {

        userObject.deleteInBackground{ (success: Bool, error: Error?) in

            self.userPreference.setValue( objectId, forKey: "UserID" )
            self.userObject.objectId = objectId
            self.objectIsChanged = true
            self.objectIdStatus = true

        }

    }

    func updateUserStatus( _ status: String ) {
        userPreference.setValue( status, forKey: "status" )
        userObject.setValue( status, forKey: "status" )
        objectIsChanged = true
    }

    // Update the username in app
    func updateLocalUsername( _ name: String ) {
        userPreference.setValue( name, forKey: "username" )
    }

    func updateLocalMail( _ mail: String ) {
        userPreference.setValue( mail, forKey: "email" )
    }

    func updateEnterDate( _ date: String ) {
        userPreference.setValue( date, forKey: "enterDate" )
        let userEnterArray = split2Int( date as NSString )
        userObject.setValue( userEnterArray[0], forKey: "yearOfEnterDate" )
        userObject.setValue( userEnterArray[1], forKey: "monthOfEnterDate" )
        userObject.setValue( userEnterArray[2], forKey: "dateOfEnterDate" )
        objectIsChanged = true
    }

    func updateServiceDays( _ days: Int ) {
        userObject.setValue( days, forKey: "serviceDays" )
        objectIsChanged = true
    }

    func updateDiscountDays( _ days: Int ) {
        userObject.setValue( days, forKey: "discountDays" )
        objectIsChanged = true
    }

    func updateWeekendFixed( _ fixed: Bool ) {
        userPreference.set( fixed, forKey: "autoWeekendFixed" )
        userObject.setValue( fixed, forKey: "weekendDischarge" )
        objectIsChanged = true
    }

    func updateAnimationSetting( _ animation: Bool ) {
        userPreference.set( animation, forKey: "countdownAnimation" )
//        userObject.setValue( animation, forKey: "countdownAnimation" )
//        objectIsChanged = true
    }

    func updatePublicProfile( _ public_show: Bool ) {
        userPreference.set( public_show, forKey: "publicProfile" )
        userObject.setValue( public_show, forKey: "publicProfile" )
        objectIsChanged = true
    }

    // Save local data to Parse
    func save() {

        if objectIsChanged {

            userPreference.set( false, forKey: "dayAnimated" )
            objectIsChanged = false

            if objectIdStatus {
                userObject.saveEventually()
            }

        }

    }

    // There is not completed task at last time, continue to do it
    func uploadAllData() {

        if let fbid = userPreference.string(forKey: "fb_id") {
            userObject.setValue( fbid, forKey: "fb_id" )
        }
        if let name = userPreference.string(forKey: "username") {
            userObject.setValue( name, forKey: "username" )
        }
        if let mail = userPreference.string(forKey: "email") {
            userObject.setValue( mail, forKey: "email" )
        }
        if let userStatus = userPreference.string(forKey: "status") {
            userObject.setValue( userStatus, forKey: "status" )
        }
        if let userEnterDate: NSString = userPreference.string(forKey: "enterDate") as NSString? {
            let userEnterArray = split2Int(userEnterDate)
            userObject.setValue( userEnterArray[0], forKey: "yearOfEnterDate" )
            userObject.setValue( userEnterArray[1], forKey: "monthOfEnterDate" )
            userObject.setValue( userEnterArray[2], forKey: "dateOfEnterDate" )
        }
        // stringForKey could be nil and integerForKey couldn't
        if userPreference.value(forKey: "serviceDays") != nil {
            userObject.setValue( userPreference.integer(forKey: "serviceDays"), forKey: "serviceDays" )
        }
        if userPreference.value(forKey: "discountDays") != nil {
            userObject.setValue( userPreference.integer(forKey: "discountDays"), forKey: "discountDays" )
        }
        userObject.setValue( userPreference.bool(forKey: "autoWeekendFixed"), forKey: "weekendDischarge" )
        userObject.setValue( userPreference.bool(forKey: "publicProfile"), forKey: "publicProfile" )

        objectIsChanged = true
        // Save to Parse
        save()

    }

    // Call this after app gets the login result from facebook
    func storeFacebookInfo( _ info: AnyObject, syncCompletion: @escaping ((_ messageContent: String, _ newStatus: String, _ newEnterDate: String, _ newServiceDays: Int, _ newDiscountDays: Int, _ newWeekendFixed: Bool, _ newPublicProfile: Bool) -> Void), newUserTask: @escaping () -> Void ) {

        if let FBID = info.value(forKey: "id") {
            // Search parse data by FBID, check whether there is matched data.
            let fbIdQuery = PFQuery(className: SecretCode.classNameInParse)
                fbIdQuery.whereKey( "fb_id", equalTo: FBID )
            fbIdQuery.findObjectsInBackground{ (objects: [PFObject]?, error: Error?) -> Void in
                if error == nil {

                    self.addUserFBID( FBID as! String )

                    if objects!.count > 0 {
                        // User has registerd.
                        if let user = objects!.first {

                            if let userID = user.objectId {
                                self.updateLocalObjectId( userID )
                            }
                            if let username = user.value(forKey: "username") {
                                self.updateLocalUsername(username as! String)
                            }
                            if let userMail = user.value(forKey: "email") {
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

                            if user.value(forKey: "status") != nil {
                                newStatus = user.value(forKey: "status") as! String
                            }
                            if let year = user.value(forKey: "yearOfEnterDate") {
                                let month = ( (user.value(forKey: "monthOfEnterDate") as! Int) < 10 ? "0" : "" ) + String(describing: user.value(forKey: "monthOfEnterDate")!)
                                let date = ( (user.value(forKey: "dateOfEnterDate") as! Int) < 10 ? "0" : "" ) + String(describing: user.value(forKey: "dateOfEnterDate")!)
                                // Store data
                                newEnterDate = "\(year) / \(month) / \(date)"
                                messageContent += "入伍日期：\(newEnterDate)\n"
                            }
                            if let service = user.value(forKey: "serviceDays") {
                                // Store data
                                newServiceDays = service as! Int
                                let serviceStr: String = CalculateHelper().switchPeriod( String(describing: service) )
                                messageContent += "役期天數：\(serviceStr)\n"
                            }
                            if let discount = user.value(forKey: "discountDays") {
                                // Store data
                                newDiscountDays = discount as! Int
                                messageContent += "折抵天數：\(discount)天"
                            }
                            if let weekendFixed = user.value(forKey: "weekendDischarge") {
                                newWeekendFixed = weekendFixed as! Bool
                            }
                            if let publicProfile = user.value(forKey: "publicProfile") {
                                newPublicProfile = publicProfile as! Bool
                            }

                            syncCompletion( messageContent, newStatus, newEnterDate, newServiceDays, newDiscountDays, newWeekendFixed, newPublicProfile)

                        }
                    } else {
                        // New user
                        // Update user email, name .... by objectId

                        if let userName = info.value(forKey: "name") {
                            self.addUserName( userName as! String )
                        }
                        if let userMail = info.value(forKey: "email") {
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

    fileprivate func checkObjectId() {
        if !objectIdStatus { registerNewUser() }
    }

    // Register a new user data in Parse
    // And save objectId in local userPreference
    func registerNewUser() {

        if Reachability().isConnectedToNetwork() {

            if let userEnter: NSString = userPreference.string(forKey: "enterDate") as NSString? {
                let userEnterArray = split2Int(userEnter)

                userObject.setValue( userEnterArray[0], forKey: "yearOfEnterDate" )
                userObject.setValue( userEnterArray[1], forKey: "monthOfEnterDate" )
                userObject.setValue( userEnterArray[2], forKey: "dateOfEnterDate" )
            }
            if let userService = userPreference.string(forKey: "serviceDays") {
                userObject.setValue( Int(userService)!, forKey: "serviceDays" )
            }
            if let userDiscount = userPreference.string(forKey: "discountDays") {
                userObject.setValue( Int(userDiscount)!, forKey: "discountDays" )
            }

            userObject.saveInBackground(block: { (success: Bool, error: Error?) in
                if success {
                    self.userPreference.setValue( self.userObject.objectId, forKey: "UserID" )
                    self.objectIdStatus = true
                }
            })

        }

    }

    fileprivate func split2Int( _ string: NSString ) -> NSArray {
        var splitArray = [Int]()

        if let year = Int( string.substring(to: 4) ) {
            splitArray.append( year )
        }
        if let month = Int( string.substring(with: NSMakeRange(7, 2)) ) {
            splitArray.append( month )
        }
        if let date = Int( string.substring(from: 12) ) {
            splitArray.append( date )
        }

        return splitArray as NSArray
    }

}
