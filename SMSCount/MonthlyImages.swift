//
//  BackImageUpdate.swift
//  SMSCount
//
//  Created by Eddie on 2015/10/9.
//  Copyright © 2015年 Wen. All rights reserved.
//

class MonthlyImages {

    let currentMonth: String

    init(month: String) {
        self.currentMonth = month
    }

    func setBackground( _ background: UIImageView ) {
        background.image = UIImage(named: self.currentMonth)
    }

}
