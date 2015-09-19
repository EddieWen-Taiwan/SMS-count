//
//  PercentageViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/13.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class PercentageViewController: UIViewController {

    @IBOutlet var stageText: UILabel!
    @IBOutlet var pieChartView: UIView!
    @IBOutlet var percentageLabel: UILabel!
    @IBOutlet var percentSymbol: UILabel!

    @IBOutlet var backgroundImage: UIImageView!
    var monthImage = "background_01"

    let countingClass = CountingDate()

    // Create a new CircleView
    var circleView: PercentageCircleView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let currentMonth = NSCalendar.currentCalendar().components( .Month, fromDate: NSDate() ).month
        let currentMonthStr = ( currentMonth < 10 ) ? "0" + String(currentMonth) : String( currentMonth )
        monthImage = "background_" + currentMonthStr
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        self.backgroundImage.image = UIImage(named: monthImage)

        circleView = PercentageCircleView( frame: self.pieChartView.frame )
        self.pieChartView.addSubview( circleView )
    }

    override func viewDidAppear(animated: Bool) {

        if countingClass.isSettingAllDone() {
            // OK
            percentSymbol.hidden = false

            countingClass.updateDate()
            let currentProgress = countingClass.getCurrentProgress()
            let currentProgressString = String( format: "%.1f", currentProgress )
            if percentageLabel.text != currentProgressString {
                percentageLabel.text = currentProgressString
                drawPercentageChart()
                self.updateStageText( currentProgress )
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

    func updateStageText( process: Double ) {
        var stageText = ""
        if process < 0 {
            stageText = "尚未入伍"
        } else if process >= 100 {
            stageText = "恭喜退伍啦"
        }
        let processInt = Int( floor(process/10) )
        switch( processInt ) {
            case 0:
                stageText = ""
            case 1:
                stageText = "菜鳥兵"
            case 2:
                stageText = ""
            case 3:
                stageText = ""
            case 4:
                stageText = ""
            case 5:
                stageText = ""
            case 6:
                stageText = ""
            case 7:
                stageText = ""
            case 8:
                stageText = ""
            case 9:
                stageText = ""
            default:
                break
        }
        self.stageText.text = stageText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
