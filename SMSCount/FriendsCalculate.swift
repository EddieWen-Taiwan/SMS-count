//
//  FriendsCalculate.swift
//  SMSCount
//
//  Created by Eddie on 12/12/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import UIKit

class FriendsCalculate: CalculateHelper {

    func inputFriendData( enterDate: String?, serviceDays: Int?, discountDays: Int = 0, autoFixed: Bool = false ) -> Bool {

        self.valueEnterDate = enterDate != nil ? enterDate! : ""
        self.valueServiceDays = serviceDays != nil ? serviceDays! : -1
        self.valueDiscountDays = discountDays
        self.valueAutoFixed = autoFixed

        if super.isSettingAllDone() {
            super.updateDate()
            return true
        } else {
            return false
        }

    }

}
