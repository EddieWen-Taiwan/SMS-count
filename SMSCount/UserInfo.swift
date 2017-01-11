//
//  UserInfo.swift
//  SMSCount
//
//  Created by Eddie on 10/26/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import Parse

/**
 * Save userInfomation to Firebase
 */
class UserInfo {

    let firebaseHelper = FirebaseHelper()

    let userPreference = UserDefaults( suiteName: "group.EddieWen.SMSCount" )!

    // Initialize
    init() {
    }

    // From Facebook API
    // Add user infomation: ID, name, email
    func addUserFBID( _ fbid: String ) {
        userPreference.setValue( fbid, forKey: "fb_id" )
    }

    func updateUserStatus( _ status: String ) {
        userPreference.setValue( status, forKey: "status" )
        firebaseHelper.update(key: "status", status)
    }

    // Update the username in app
    func updateUsername( _ name: String ) {
        userPreference.setValue( name, forKey: "username" )
        firebaseHelper.update(key: "name", name)
    }

    func updateMail( _ mail: String ) {
        userPreference.setValue( mail, forKey: "email" )
        firebaseHelper.update(key: "email", mail)
    }

    func updateEnterDate( _ date: String ) {
        userPreference.setValue( date, forKey: "enterDate" )
        let userEnterArray = split2Int( date as NSString )
        firebaseHelper.update(key: "year", userEnterArray[0])
        firebaseHelper.update(key: "month", userEnterArray[1])
        firebaseHelper.update(key: "date", userEnterArray[2])
    }

    func updateServiceDays( _ days: Int ) {
        firebaseHelper.update(key: "serviceDaysIndex", days)
    }

    func updateDiscountDays( _ days: Int ) {
        firebaseHelper.update(key: "discountDays", days)
    }

    func updateWeekendFixed( _ fixed: Bool ) {
        userPreference.set( fixed, forKey: "autoWeekendFixed" )
        firebaseHelper.update(key: "isWeekendDischarge", userPreference.bool(forKey: "autoWeekendFixed"))
    }

    func updatePublicProfile( _ public_show: Bool ) {
        userPreference.set( public_show, forKey: "publicProfile" )
        firebaseHelper.update(key: "isPublicProfile", userPreference.bool(forKey: "publicProfile"))
    }

    func updateAnimationSetting( _ animation: Bool ) {
        userPreference.set( animation, forKey: "countdownAnimation" )
    }

    /**
     * upload all data to Firebase, fbId as key
     * don't call this function without fbId
     */
    func uploadAllData(_ fbid: String) {

        if let name = userPreference.string(forKey: "username") {
            firebaseHelper.update(key: "name", name)
        }
        if let mail = userPreference.string(forKey: "email") {
            firebaseHelper.update(key: "email", mail)
        }
        if let userStatus = userPreference.string(forKey: "status") {
            firebaseHelper.update(key: "status", userStatus)
        }
        if let userEnterDate: NSString = userPreference.string(forKey: "enterDate") as NSString? {
            let userEnterArray = split2Int(userEnterDate)
            firebaseHelper.update(key: "year", userEnterArray[0])
            firebaseHelper.update(key: "month", userEnterArray[1])
            firebaseHelper.update(key: "date", userEnterArray[2])
        }
        // stringForKey could be nil and integerForKey couldn't
        if userPreference.value(forKey: "serviceDays") != nil {
            firebaseHelper.update(key: "serviceDaysIndex", userPreference.integer(forKey: "serviceDays"))
        }
        if userPreference.value(forKey: "discountDays") != nil {
            firebaseHelper.update(key: "discountDays", userPreference.integer(forKey: "discountDays"))
        }
        firebaseHelper.update(key: "isWeekendDischarge", userPreference.bool(forKey: "autoWeekendFixed"))
        firebaseHelper.update(key: "isPublicProfile", userPreference.bool(forKey: "publicProfile"))
        firebaseHelper.update(key: "platform", "iOS")

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
                                self.addUserFBID( userID )
                            }
                            if let username = user.value(forKey: "username") {
                                self.updateUsername(username as! String)
                            }
                            if let userMail = user.value(forKey: "email") {
                                self.updateMail( userMail as! String )
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
                            self.updateUsername( userName as! String )
                        }
                        if let userMail = info.value(forKey: "email") {
                            self.updateMail( userMail as! String )
                        }

                        // Remove old view or nothing
                        newUserTask()
                    }

                }
            }
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
