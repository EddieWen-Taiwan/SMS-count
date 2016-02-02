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
    @IBOutlet var publicSwitch: UISwitch!

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

        // Resize UISwitch and add function
        func prepareSwitch( mySwitch: UISwitch ) {
            mySwitch.transform = CGAffineTransformMakeScale(0.8, 0.8)
            mySwitch.addTarget(self, action: "switchClick:", forControlEvents: .ValueChanged)
        }
        prepareSwitch(self.autoWeekendSwitch)
        if self.userPreference.boolForKey("autoWeekendFixed") {
            self.autoWeekendSwitch.setOn(true, animated: false)
        }
        prepareSwitch(self.publicSwitch)

        // Add footer of TableView
        let footerBorder = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 0.5))
            footerBorder.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 40))
            footerView.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
            footerView.addSubview(footerBorder)
        self.tableView.tableFooterView = footerView
    }

    @IBAction func editEnterDate(sender: AnyObject) {

        if let parentVC = self.parentVC {
            parentVC.serviceDaysPickerViewBottomConstraint.constant = -200
            parentVC.discountDaysPickerViewBottomConstraint.constant = -200
            parentVC.datepickerViewBottomConstraint.constant = 0
            parentVC.screenMask.tag = 1

            parentVC.showPickerView()

            if let userEnterDate = userPreference.stringForKey("enterDate") {
                parentVC.datepickerElement.setDate( parentVC.dateFormatter.dateFromString(userEnterDate)!, animated: false )
            }
        }

    }

    @IBAction func editServiceDays(sender: AnyObject) {

        if let parentVC = self.parentVC {
            parentVC.datepickerViewBottomConstraint.constant = -200
            parentVC.discountDaysPickerViewBottomConstraint.constant = -200
            parentVC.serviceDaysPickerViewBottomConstraint.constant = 0
            parentVC.screenMask.tag = 2

            parentVC.showPickerView()

            if let userServiceDays: Int = userPreference.integerForKey("serviceDays") {
                parentVC.serviceDaysPickerElement.selectRow( userServiceDays, inComponent: 0, animated: false )
            }
        }

    }

    @IBAction func editDiscountDays(sender: AnyObject) {

        if let parentVC = self.parentVC {
            parentVC.datepickerViewBottomConstraint.constant = -200
            parentVC.serviceDaysPickerViewBottomConstraint.constant = -200
            parentVC.discountDaysPickerViewBottomConstraint.constant = 0
            parentVC.screenMask.tag = 3

            parentVC.showPickerView()

            if let selectedRow: Int = userPreference.integerForKey("discountDays") {
                parentVC.discountDaysPickerElement.selectRow( selectedRow, inComponent: 0, animated: false )
            }
        }

    }

    func switchClick( mySwitch: UISwitch ) {
        let newValue: Bool = mySwitch.on ? true : false

        if let parentVC = self.parentVC {
            if mySwitch.tag == 0 {
                parentVC.userInfo.updateWeekendFixed( newValue )
            } else {
                parentVC.userInfo.updatePublicProfile( newValue )
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StatusVC" {
            if let statusVC = segue.destinationViewController as? StatusViewController {
                statusVC.parentVC = self
            }
        }
    }

    func updateNewStatusFromStatusVC( newStatus: String ) {
        print(newStatus)
    }

    // MARK: table view
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1
            case 1:
                return 3
            default:
                return 2
        }
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let label = UILabel(frame: CGRectMake(20, 24, 48, 17))
        label.textColor = UIColor(red: 103/255, green: 211/255, blue: 173/255, alpha: 1)
        label.font = UIFont(name: "PingFangTC-Light", size: 12.0)
        switch section {
            case 0:
                label.text = "個人設定"
            case 1:
                label.text = "一般設定"
            default:
                label.text = "偏好設定"
        }

        let topBorder = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 0.5))
        topBorder.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        let bottomBorder = UIView(frame: CGRectMake(0, 50, tableView.frame.width, 0.5))
        bottomBorder.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)

        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 50))
        headerView.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        if section != 0 {
            headerView.addSubview(topBorder)
        }
        headerView.addSubview(bottomBorder)
        headerView.addSubview(label)

        return headerView
    }
}
