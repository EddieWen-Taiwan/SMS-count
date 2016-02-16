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
    var stageIndexArray = Array(count: 6, repeatedValue: 0)

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

        self.textLabel = UILabel(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.height-44-49)/2+110, UIScreen.mainScreen().bounds.width, 23))
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
            for i in 1 ... days {
                self.animationArray.append( String(i) )
            }
        } else {
            for i in 1 ... 95 {
                self.animationArray.append( String( format: "%.f", Double( (days-3)*i )*0.01 ) )
            }
            for i in 96 ... 100 {
                self.animationArray.append( String( days-(100-i) ) )
            }
        }

        let arrayLength = self.animationArray.count
        self.stageIndexArray.removeAll(keepCapacity: true)
        self.stageIndexArray.append( Int( Double(arrayLength)*0.55 ) )
        self.stageIndexArray.append( Int( Double(arrayLength)*0.75 ) )
        self.stageIndexArray.append( Int( Double(arrayLength)*0.88 ) )
        self.stageIndexArray.append( Int( Double(arrayLength)*0.94 ) )
        self.stageIndexArray.append( Int( Double(arrayLength)*0.97 ) )
        self.stageIndexArray.append( arrayLength-1 )

        self.dayLabel.text = "0"

        // Run animation
        self.startNextTimer(1)

    }

    func daysAddingEffect( timer: NSTimer ) {

        if let info = timer.userInfo as? Dictionary<String,Int> {
            if let currentStage = info["index"] {
                // Final stage(special)
                if currentStage == 7 {
                    if self.animationIndex == self.stageIndexArray[5] {
                        self.updateLabel()
                    } else {
                        timer.invalidate()

                        if let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount") {
                            userPreference.setBool( true, forKey: "dayAnimated" )
                        }
                    }
                } else {
                // Normal stage
                    if self.animationIndex < self.stageIndexArray[currentStage-1] {
                        self.updateLabel()
                    } else {
                        timer.invalidate()
                        self.startNextTimer( currentStage+1 )
                    }
                }
            }
        }

    }

    private func startNextTimer( stage: Int ) {
        let intervalArray = [ 0.01, 0.02, 0.04, 0.08, 0.16, 0.24, 0.32 ]
        let info: Dictionary<String,Int> = [ "index": stage ]

        NSTimer.scheduledTimerWithTimeInterval( intervalArray[stage-1], target: self, selector: Selector("daysAddingEffect:"), userInfo: info, repeats: true )
    }

    private func updateLabel() {
        self.dayLabel.text = self.animationArray[ self.animationIndex++ ]
    }

}
