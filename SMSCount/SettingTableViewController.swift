//
//  SettingTableViewController.swift
//  SMSCount
//
//  Created by Eddie on 12/20/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {

    @IBOutlet var enterDateLabel: UILabel!
    @IBOutlet var serviceDaysLabel: UILabel!
    @IBOutlet var discountDaysLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var autoWeekendSwitch: UISwitch!

    let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!

    var parentVC: SettingViewController?

    let calculateHelper = CalculateHelper()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let userEnterDate = self.userPreference.stringForKey("enterDate") {
            self.enterDateLabel.text = userEnterDate
        }
        if let userServiceDays = self.userPreference.stringForKey("serviceDays") {
            self.serviceDaysLabel.text = calculateHelper.switchPeriod( userServiceDays )
        }
        if let userDiscountDays = self.userPreference.stringForKey("discountDays") {
            self.discountDaysLabel.text = userDiscountDays
        }
        if let status = self.userPreference.stringForKey("status") {
            self.statusLabel.text = status
        }
        self.autoWeekendSwitch.transform = CGAffineTransformMakeScale(0.8, 0.8)
        self.autoWeekendSwitch.addTarget(self, action: "switchClick:", forControlEvents: .ValueChanged)
        if self.userPreference.boolForKey("autoWeekendFixed") {
            self.autoWeekendSwitch.setOn(true, animated: false)
        }
    }

    @IBAction func editEnterDate(sender: AnyObject) {

        if let parentVC = self.parentVC {
            parentVC.serviceDaysPickerViewBottomConstraint.constant = -200
            parentVC.discountDaysPickerViewBottomConstraint.constant = -200
            parentVC.datepickerViewBottomConstraint.constant = 0
            parentVC.screenMask.tag = 1

            parentVC.showPickerView()
        }

//        if let userEnterDate = userPreference.stringForKey("enterDate") {
//            datepickerElement.setDate( dateFormatter.dateFromString(userEnterDate)!, animated: false )
//        }

    }

    func switchClick( mySwitch: UISwitch ) {
        self.userPreference.setBool( mySwitch.on ? true : false, forKey: "autoWeekendFixed" )
    }

    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {

        if let statusVC = unwindSegue.sourceViewController as? StatusViewController {
            var userStatus = statusVC.statusTextField.text! as NSString
            if userStatus.length > 30 {
                userStatus = userStatus.substringToIndex(30)
            }
            self.statusLabel.text = userStatus as String
            if let parentVC = self.parentVC {
                parentVC.userInfo.updateUserStatus( userStatus as String )
            }
        }

    }

    // MARK: table view
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? 3 : 1
    }

}
