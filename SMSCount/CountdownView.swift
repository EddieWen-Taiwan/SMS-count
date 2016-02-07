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
    var textLabel = UILabel()

    convenience init(view: UIView) {
        self.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height-44-49))

        self.addDaysLabel()
        self.addTextLabel()
    }

    private func addDaysLabel() {

        self.dayLabel = UILabel(frame: CGRectMake(0, 0, self.frame.width, 60))
        self.dayLabel.center = self.center
        self.dayLabel.text = "0"
        self.dayLabel.font = UIFont(name: "Verdana", size: 74)
        self.dayLabel.textColor = UIColor.whiteColor()
        self.dayLabel.textAlignment = .Center

        self.addSubview( self.dayLabel )

    }

    private func addTextLabel() {

        self.textLabel = UILabel(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.height-44-49)/2+30+78, UIScreen.mainScreen().bounds.width, 23))
        self.textLabel.text = "剩餘天數"
        self.textLabel.font = UIFont(name: "PingFangTC-Regular", size: 16)
        self.textLabel.textColor = UIColor.whiteColor()
        self.textLabel.textAlignment = .Center

        self.addSubview( self.textLabel )

    }

    func setRemainedDays( days: Int ) {

        

    }

}
