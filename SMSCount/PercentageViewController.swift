//
//  PercentageViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/13.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class PercentageViewController: BasicGestureViewController {

    @IBOutlet var percentageLabel: UILabel!
    @IBOutlet var percentSymbol: UILabel!

    let countingClass = CountingDate()

    // Create a new CircleView
    var circleView: PercentageCircleView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        var chartHeight = self.view.frame.height
        var chartWidth = chartHeight
        circleView = PercentageCircleView( frame: CGRectMake( (chartWidth-self.view.frame.width)/(-2), 0, chartWidth, chartHeight ) )
        self.view.addSubview( circleView )
    }

    override func viewDidAppear(animated: Bool) {

        if countingClass.isSettingAllDone() {
            // OK
            percentSymbol.hidden = false

            countingClass.updateDate()
            let currentProgress = String( format: "%.1f", countingClass.getCurrentProgress() )
            if percentageLabel.text != currentProgress {
                percentageLabel.text = currentProgress
                drawPercentageChart()
            }

        } else {
            percentSymbol.hidden = true
            // switch to settingViewController ?
        }

    }
    
    func drawPercentageChart() {
        // Animate the drawing of the circle over the course of 1 second
        circleView.animateCircle( countingClass.getCurrentProgress()*(0.01) )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
