//
//  PercentageViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/13.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class PercentageViewController: UIViewController {

    @IBOutlet var profileHeightConstraint: NSLayoutConstraint!
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
        self.profileHeightConstraint.constant = self.view.frame.height-64-50-100
        self.updateStageText()

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

    func updateStageText() {
        let songArray = [ "替代役青年們夢想起飛", "像螞蟻默默做自己", "愛心服務責任紀律", "沒有懷疑沒有怨言" ]
        self.stageText.text = songArray[ Int( arc4random_uniform(4) ) ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
