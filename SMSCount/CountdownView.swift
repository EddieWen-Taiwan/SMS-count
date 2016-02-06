//
//  CountdownView.swift
//  SMSCount
//
//  Created by Eddie on 2/6/16.
//  Copyright © 2016 Wen. All rights reserved.
//

import UIKit

class CountdownView: UIView {

    var dayLabel = UILabel()

    convenience init(view: UIView) {
        self.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height-44-49))

        self.addDaysLabel()
    }

    func addDaysLabel() {

        self.dayLabel = UILabel(frame: CGRectMake(0, 0, self.frame.width, 60))
        self.dayLabel.center = self.center
        self.dayLabel.text = "0"
        self.dayLabel.font = UIFont(name: "Verdana", size: 74)
        self.dayLabel.textColor = UIColor.whiteColor()
        self.dayLabel.textAlignment = .Center

        self.addSubview( self.dayLabel )

    }
}
