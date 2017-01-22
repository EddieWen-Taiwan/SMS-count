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
