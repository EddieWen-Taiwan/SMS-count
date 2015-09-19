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
        var stageText: String  = ""
        if process < 0 {
            stageText = "尚未入伍"
        } else if process >= 100 {
            stageText = "呼～ 還好我退了"
        } else {
            switch( Int( floor(process/10) ) ) {
                case 0:
                    stageText = "扣你兩分有沒有問題"
                case 1:
                    stageText = "菜蟲掉滿地"
                case 2:
                    stageText = "菜蟲掉滿地"
                case 3:
                    stageText = "3"
                case 4:
                    stageText = "4"
                case 5:
                    stageText = "5"
                case 6:
                    stageText = "6"
                case 7:
                    stageText = "7"
                case 8:
                    stageText = "8"
                case 9:
                    stageText = "9"
                default:
                    stageText = "尚未入伍"
            }
            
        }
        self.stageText.text = stageText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
