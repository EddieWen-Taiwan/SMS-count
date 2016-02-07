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

    var animationIndex: Int = 0
    var animationArray = [String]() // [ 1, 2, ... 99, 100 ]
    var stageIndexArray = [Int]()

    convenience init(view: UIView) {
        self.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height-44-49))

        self.addDaysLabel()
        self.addTextLabel()
    }

    private func addDaysLabel() {

        self.dayLabel = UILabel(frame: CGRectMake(0, 0, self.frame.width, 60))
        self.dayLabel.center = self.center
        self.dayLabel.font = UIFont(name: "Verdana", size: 74)
        self.dayLabel.textColor = UIColor.whiteColor()
        self.dayLabel.textAlignment = .Center

        self.addSubview( self.dayLabel )

    }

    private func addTextLabel() {

        self.textLabel = UILabel(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.height-44-49)/2+30+78, UIScreen.mainScreen().bounds.width, 23))
        self.textLabel.font = UIFont(name: "PingFangTC-Regular", size: 16)
        self.textLabel.textColor = UIColor.whiteColor()
        self.textLabel.textAlignment = .Center

        self.addSubview( self.textLabel )

    }

    func setRemainedDays( days: Int ) {

        self.textLabel.text = days < 0 ? "自由天數" : "剩餘天數"

        // Set remainedDays
        if let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount") {
            if userPreference.boolForKey("countdownAnimation") == true && userPreference.boolForKey("dayAnimated") == false {
                // Run animation
                self.beReadyAndRunCountingAnimation( abs(days) )
            } else {
                // Animation was completed or User doesn't want animation
                self.dayLabel.text = String( abs(days) )
            }
        }

    }

    private func beReadyAndRunCountingAnimation( days: Int ) {

        // Animation setting
        self.animationIndex = 0
        self.animationArray.removeAll(keepCapacity: false) // Maybe it should be true
        if days < 100 {
            for var i = 0; i <= days; i++ {
                self.animationArray.append( String(i) )
            }
        } else {
            for var i = 1; i <= 95; i++ {
                self.animationArray.append( String( format: "%.f", Double( (days-3)*i )*0.01 ) )
            }
            for var i = 96; i <= 100; i++ {
                self.animationArray.append( String( days-(100-i) ) )
            }
        }

        let arrayLength = self.animationArray.count
        self.stageIndexArray[0] = Int( Double(arrayLength)*0.55 )
        self.stageIndexArray[1] = Int( Double(arrayLength)*0.75 )
        self.stageIndexArray[2] = Int( Double(arrayLength)*0.88 )
        self.stageIndexArray[3] = Int( Double(arrayLength)*0.94 )
        self.stageIndexArray[4] = Int( Double(arrayLength)*0.97 )
        self.stageIndexArray[5] = arrayLength-1

        self.dayLabel.text = "0"

        // Run animation
        NSTimer.scheduledTimerWithTimeInterval( 0.01, target: self, selector: Selector("daysAddingEffect:"), userInfo: "stage1", repeats: true )

    }

    private func daysAddingEffect( timer: NSTimer ) {

        switch( timer.userInfo! as! String ) {
        case "stage1":
            if self.animationIndex < self.stageIndexArray[0] {
                self.updateLabel()
            } else {
                timer.invalidate()
                NSTimer.scheduledTimerWithTimeInterval( 0.02, target: self, selector: "daysAddingEffect:", userInfo: "stage2", repeats: true )
            }

        case "stage2":
            if self.animationIndex < self.stageIndexArray[1] {
                self.updateLabel()
            } else {
                timer.invalidate()
                NSTimer.scheduledTimerWithTimeInterval( 0.04, target: self, selector: "daysAddingEffect:", userInfo: "stage3", repeats: true )
            }

        case "stage3":
            if self.animationIndex < self.stageIndexArray[2] {
                self.updateLabel()
            } else {
                timer.invalidate()
                NSTimer.scheduledTimerWithTimeInterval( 0.08, target: self, selector: "daysAddingEffect:", userInfo: "stage4", repeats: true )
            }

        case "stage4":
            if self.animationIndex < self.stageIndexArray[3] {
                self.updateLabel()
            } else {
                timer.invalidate()
                NSTimer.scheduledTimerWithTimeInterval( 0.16, target: self, selector: "daysAddingEffect:", userInfo: "stage5", repeats: true )
            }

        case "stage5":
            if self.animationIndex < self.stageIndexArray[4] {
                self.updateLabel()
            } else {
                timer.invalidate()
                NSTimer.scheduledTimerWithTimeInterval( 0.24, target: self, selector: "daysAddingEffect:", userInfo: "stage6", repeats: true )
            }

        case "stage6":
            if self.animationIndex < self.stageIndexArray[5] {
                self.updateLabel()
            } else {
                timer.invalidate()
                NSTimer.scheduledTimerWithTimeInterval( 0.32, target: self, selector: "daysAddingEffect:", userInfo: "stage7", repeats: true )
            }

        case "stage7":
            if self.animationIndex == self.stageIndexArray[5] {
                self.updateLabel()
            } else {
                timer.invalidate()

                let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!
                userPreference.setBool( true, forKey: "dayAnimated" )
            }

        default:
            break;
        }
    }

    private func updateLabel() {
        self.textLabel.text = self.animationArray[ self.animationIndex++ ]
    }

}
