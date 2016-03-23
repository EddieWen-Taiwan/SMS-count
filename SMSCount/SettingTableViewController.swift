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
    @IBOutlet var animationSwitch: UISwitch!
    @IBOutlet var publicSwitch: UISwitch!

    let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!

    var parentVC: SettingViewController?

    let calculateHelper = CalculateHelper()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let userEnterDate = userPreference.stringForKey("enterDate") {
            enterDateLabel.text = userEnterDate
        }
        if let userServiceDays = userPreference.stringForKey("serviceDays") {
            serviceDaysLabel.text = calculateHelper.switchPeriod( userServiceDays )
        }
        if let userDiscountDays = userPreference.stringForKey("discountDays") {
            discountDaysLabel.text = userDiscountDays
        }
        if let status = userPreference.stringForKey("status") {
            statusLabel.text = status
        }

        // Resize UISwitch and add function
        func prepareSwitch( mySwitch: UISwitch ) {
            mySwitch.transform = CGAffineTransformMakeScale(0.8, 0.8)
            mySwitch.addTarget(self, action: #selector(switchClick), forControlEvents: .ValueChanged)
        }
        prepareSwitch( autoWeekendSwitch )
        if userPreference.boolForKey("autoWeekendFixed") {
            autoWeekendSwitch.setOn(true, animated: false)
        }
        prepareSwitch( animationSwitch )
        if userPreference.boolForKey("countdownAnimation") {
            animationSwitch.setOn(true, animated: false)
        }
        prepareSwitch( publicSwitch )
        // Its value was set in SettingVC

        // Add footer of TableView
        let footerBorder = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 0.5))
            footerBorder.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 40))
            footerView.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
            footerView.addSubview(footerBorder)
        tableView.tableFooterView = footerView
    }

    @IBAction func editEnterDate(sender: AnyObject) {

        if let parentVC = parentVC {
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

        if let parentVC = parentVC {
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

        if let parentVC = parentVC {
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

        if let parentVC = parentVC {
            switch mySwitch.tag {
                case 0:
                    parentVC.userInfo.updateWeekendFixed( newValue )
                case 1:
                    parentVC.userInfo.updateAnimationSetting( newValue )
                default: // 2
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
        statusLabel.text = newStatus
        if let parentVC = parentVC {
            parentVC.userInfo.updateUserStatus( newStatus as String )
        }
    }

    // MARK: table view
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 3
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let label = UILabel(frame: CGRectMake(20, 24, 48, 17))
            label.textColor = UIColor(red: 103/255, green: 211/255, blue: 173/255, alpha: 1)
            label.font = UIFont(name: "PingFangTC-Light", size: 12.0)
            label.text = {
                switch section {
                    case 0:
                        return "個人設定"
                    case 1:
                        return "一般設定"
                    default:
                        return "偏好設定"
                }
            }()

        let topBorder = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 0.5))
            topBorder.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)

        let bottomBorder = UIView(frame: CGRectMake(0, 50, tableView.frame.width, 0.5))
            bottomBorder.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)

        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 50))
            headerView.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
            headerView.addSubview(label)
            if section != 0 {
                headerView.addSubview(topBorder)
            }
            headerView.addSubview(bottomBorder)

        return headerView
    }

}
