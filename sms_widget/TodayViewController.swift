//
//  TodayViewController.swift
//  SMS_Widget
//
//  Created by Eddie on 2015/8/20.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet var remainedDaysLabel: UILabel!
    @IBOutlet var warningLabel: UILabel!

    @IBOutlet var firstWord: UILabel!
    @IBOutlet var secondWord: UILabel!

    let countingClass = CountingDate()
    var updateResult: NCUpdateResult = NCUpdateResult.NoData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.checkCurrentData()
    }
    
    func checkCurrentData() {

        if countingClass.isSettingAllDone() {

            correctDataShow( true )
            countingClass.updateDate()
            let remainedDays = countingClass.getRemainedDays()
        
            if remainedDaysLabel.text != String( remainedDays ) {
                remainedDaysLabel.text = String( remainedDays )
                updateResult = NCUpdateResult.NewData
            }

        } else {
            correctDataShow( false )
        }
        
    }

    func correctDataShow( status: Bool ) {

        if status {

            remainedDaysLabel.hidden = false
            firstWord.hidden = false
            secondWord.hidden = false

            warningLabel.hidden = true

        } else {

            warningLabel.hidden = false

            remainedDaysLabel.hidden = true
            firstWord.hidden = true
            secondWord.hidden = true

        }

    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        let newWidgetMargin = UIEdgeInsets(top: defaultMarginInsets.top, left: defaultMarginInsets.left, bottom: 5.0, right: defaultMarginInsets.right)
        return newWidgetMargin
    }

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(updateResult)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
