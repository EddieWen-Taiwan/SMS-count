//
//  FriendsCalculate.swift
//  SMSCount
//
//  Created by Eddie on 12/12/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import UIKit

class FriendsCalculate: CalculateHelper {

    func inputFriendData( _ enterDate: String, serviceDays: Int, discountDays: Int, autoFixed: Bool ) -> Bool {

        valueEnterDate = enterDate
        valueServiceDays = serviceDays
        valueDiscountDays = discountDays
        valueAutoFixed = autoFixed

        if valueEnterDate == "" || valueServiceDays == -1 {
            return false
        } else {
            super.calculateData()
            return true
        }

    }

}
