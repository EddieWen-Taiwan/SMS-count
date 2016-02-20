//
//  FriendsCalculate.swift
//  SMSCount
//
//  Created by Eddie on 12/12/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import UIKit

class FriendsCalculate: CalculateHelper {

    func inputFriendData( enterDate: String, serviceDays: Int, discountDays: Int, autoFixed: Bool ) -> Bool {

        self.valueEnterDate = enterDate
        self.valueServiceDays = serviceDays
        self.valueDiscountDays = discountDays
        self.valueAutoFixed = autoFixed

        if self.valueEnterDate == "" || self.valueServiceDays == -1 {
            return false
        } else {
            super.calculateData()
            return true
        }

    }

}
