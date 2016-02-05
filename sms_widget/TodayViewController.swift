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

    let calculateHelper = CalculateHelper()
    var updateResult: NCUpdateResult = NCUpdateResult.NoData

    var isUserRetired: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.checkCurrentData()
    }

    func checkCurrentData() {

        if calculateHelper.settingStatus {

            self.correctDataShow( true )

            // Check whether should run countdown animation
            var shouldBeUpdated: Bool = false
            let newRemainedDays = calculateHelper.getRemainedDays()

            if newRemainedDays >= 0 {
                if self.isUserRetired {
                    shouldBeUpdated = true
                    self.isUserRetired = false
                } else {
                    if self.remainedDaysLabel.text != String( newRemainedDays ) {
                        shouldBeUpdated = true
                    }
                }
            } else {
                if self.isUserRetired {
                    if self.remainedDaysLabel.text != String( newRemainedDays*(-1) ) {
                        shouldBeUpdated = true
                    }
                } else {
                    shouldBeUpdated = true
                    self.isUserRetired = true
                }
            }

            if shouldBeUpdated {
                if newRemainedDays >= 0 {
                    self.firstWord.text = "還有"
                    self.remainedDaysLabel.text = String( newRemainedDays )
                } else {
                    self.firstWord.text = "自由"
                    self.remainedDaysLabel.text = String( newRemainedDays*(-1) )
                }

                self.updateResult = NCUpdateResult.NewData
            }

        } else {
            self.correctDataShow( false )
        }

    }

    func correctDataShow( status: Bool ) {

        if status {

            remainedDaysLabel.hidden = false
            firstWord.hidden = false
            secondWord.hidden = false

            warningLabel.hidden = true

        } else {

            remainedDaysLabel.hidden = true
            firstWord.hidden = true
            secondWord.hidden = true

            warningLabel.hidden = false

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

        completionHandler( self.updateResult )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
