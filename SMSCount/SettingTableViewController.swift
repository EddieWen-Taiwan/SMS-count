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

    let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!

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
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? 3 : 1
    }

}
