//
//  FirebaseHelper.swift
//  SMSCount
//
//  Created by Eddie on 1/11/2017.
//  Copyright © 2017 Wen. All rights reserved.
//

import FirebaseCore
import FirebaseDatabase

class FirebaseHelper {

    let ref = FIRDatabase.database().reference()
    let userPreference = UserDefaults( suiteName: "group.EddieWen.SMSCount" )!

    init() {
        
    }

    func update(key: String, _ value: Any) {

        if userPreference.value(forKey: "fb_id") != nil {

            let fbId = userPreference.string(forKey: "fb_id")!

            self.ref.child("User/\(fbId)/\(key)").setValue(value)

        }

    }

}
