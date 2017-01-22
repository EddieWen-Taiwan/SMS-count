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
    var stageIndexArray = Array(repeating: 0, count: 6)

    convenience init(view: UIView) {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-44-49))

        self.addDaysLabel()
        self.addTextLabel()
    }

    fileprivate func addDaysLabel() {

        dayLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 60))
        dayLabel.center = self.center
        dayLabel.font = UIFont(name: "Verdana", size: 74)
        dayLabel.textColor = UIColor.white
        dayLabel.textAlignment = .center

        self.addSubview( dayLabel )

    }

    fileprivate func addTextLabel() {

        textLabel = UILabel(frame: CGRect(x: 0, y: (UIScreen.main.bounds.height-44-49)/2+110, width: UIScreen.main.bounds.width, height: 23))
        textLabel.font = UIFont(name: "PingFangTC-Regular", size: 16)
        textLabel.textColor = UIColor.white
        textLabel.textAlignment = .center

        self.addSubview( textLabel )

    }

    func setRemainedDays( _ days: Int ) {

        textLabel.text = days < 0 ? "自由天數" : "剩餘天數"

        // Set remainedDays
        if let userPreference = UserDefaults(suiteName: "group.EddieWen.SMSCount") {
            if userPreference.bool(forKey: "countdownAnimation") == true && userPreference.bool(forKey: "dayAnimated") == false {
                // Run animation
                beReadyAndRunCountingAnimation( abs(days) )
            } else {
                // Animation was completed or User doesn't want animation
                dayLabel.text = String( abs(days) )
            }
        }

    }

    fileprivate func beReadyAndRunCountingAnimation( _ days: Int ) {

        // Animation setting
        animationIndex = 0
        animationArray.removeAll(keepingCapacity: false) // Maybe it should be true

        if days < 100 {
            for i in 0 ... days {
                animationArray.append( String(i) )
            }
        } else {
            for i in 1 ... 95 {
                animationArray.append( String( format: "%.f", Double( (days-3)*i )*0.01 ) )
            }
            for i in 96 ... 100 {
                animationArray.append( String( days-(100-i) ) )
            }
        }

        let arrayLength = animationArray.count
        stageIndexArray.removeAll(keepingCapacity: true)
        stageIndexArray.append( Int( Double(arrayLength)*0.55 ) )
        stageIndexArray.append( Int( Double(arrayLength)*0.75 ) )
        stageIndexArray.append( Int( Double(arrayLength)*0.88 ) )
        stageIndexArray.append( Int( Double(arrayLength)*0.94 ) )
        stageIndexArray.append( Int( Double(arrayLength)*0.97 ) )
        stageIndexArray.append( arrayLength-1 )

        dayLabel.text = "0"

        // Run animation
        startNextTimer(1)

    }

    func daysAddingEffect( _ timer: Timer ) {

        if let info = timer.userInfo as? Dictionary<String,Int> {
            if let currentStage = info["index"] {
                // Final stage(special)
                if currentStage == 7 {
                    if animationIndex == stageIndexArray[5] {
                        updateLabel()
                    } else {
                        timer.invalidate()

                        if let userPreference = UserDefaults(suiteName: "group.EddieWen.SMSCount") {
                            userPreference.set( true, forKey: "dayAnimated" )
                        }
                    }
                } else {
                // Normal stage
                    if animationIndex < stageIndexArray[currentStage-1] {
                        updateLabel()
                    } else {
                        timer.invalidate()
                        startNextTimer( currentStage+1 )
                    }
                }
            }
        }

    }

    fileprivate func startNextTimer( _ stage: Int ) {
        let intervalArray = [ 0.01, 0.02, 0.04, 0.08, 0.16, 0.24, 0.32 ]
        let info: Dictionary<String,Int> = [ "index": stage ]

        Timer.scheduledTimer( timeInterval: intervalArray[stage-1], target: self, selector: #selector(daysAddingEffect), userInfo: info, repeats: true )
    }

    fileprivate func updateLabel() {
        dayLabel.text = animationArray[ animationIndex ]
        animationIndex += 1
    }

}
