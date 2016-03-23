//
//  SettingViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/9.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class SettingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet var screenMask: UIView!
    @IBOutlet var FBLoginView: UIView!
    @IBOutlet var topConstraint: NSLayoutConstraint!

    @IBOutlet var datepickerView: UIView!
    @IBOutlet var datepickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var datepickerElement: UIDatePicker!

    @IBOutlet var serviceDaysPickerView: UIView!
    @IBOutlet var serviceDaysPickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var serviceDaysPickerElement: UIPickerView!
    let serviceDaysPickerDataSource: [String]

    @IBOutlet var discountDaysPickerView: UIView!
    @IBOutlet var discountDaysPickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var discountDaysPickerElement: UIPickerView!
    let discountDaysPickerDataSource: [String]

    @IBOutlet var autoWeekendSwitch: UISwitch!
    
    let dateFormatter = NSDateFormatter()
    let userPreference = NSUserDefaults( suiteName: "group.EddieWen.SMSCount" )!

    var userInfo = UserInfo()
    let calculateHelper = CalculateHelper()

    var containerVC: SettingTableViewController?

    required init?(coder aDecoder: NSCoder) {
        self.serviceDaysPickerDataSource = ["四個月","四個月五天","一年","一年十五天","三年"]
        self.discountDaysPickerDataSource = ["0 天","1 天","2 天","3 天","4 天","5 天","6 天","7 天","8 天","9 天","10 天", "11 天",
            "12 天","13 天","14 天","15 天","16 天","17 天","18 天","19 天","20 天","21 天","22 天","23 天","24 天","25 天","26 天","27 天","28 天","29 天","30 天"]
        self.dateFormatter.dateFormat = "yyyy / MM / dd"
        self.dateFormatter.timeZone = NSTimeZone.localTimeZone()

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        datepickerElement.datePickerMode = UIDatePickerMode.Date
        serviceDaysPickerElement.dataSource = self
        serviceDaysPickerElement.delegate = self
        discountDaysPickerElement.dataSource = self
        discountDaysPickerElement.delegate = self

        let pressOnScreenMask = UITapGestureRecognizer( target: self, action: #selector(dismissScreenMask) )
        screenMask.addGestureRecognizer( pressOnScreenMask )

        containerVC = self.childViewControllers.first as? SettingTableViewController

        // About FB login button
        if FBSDKAccessToken.currentAccessToken() == nil {
            FBLoginView.hidden = false
            topConstraint.constant = 20
            // FB Login
            self.view.layoutIfNeeded()

            let loginView = FBSDKLoginButton()
            FBLoginView.addSubview( loginView )
            loginView.frame = CGRectMake( 0, 0, FBLoginView.frame.width, FBLoginView.frame.height )
            loginView.readPermissions = [ "public_profile", "email", "user_friends" ]
            loginView.delegate = self

            // Disable publicSwitch
            containerVC?.publicSwitch.enabled = false
        } else {
            // If there is FBtoken, then set UISwitch value depends on value in UserDefault
            if userPreference.boolForKey("publicProfile") {
                containerVC?.publicSwitch.setOn(true, animated: false)
            }
        }

    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        userInfo.save()
    }

    func showPickerView() {

        screenMask.hidden = false
        UIView.animateWithDuration( 0.4, animations: {
            self.screenMask.alpha = 0.6
            // show PickerView
            self.view.layoutIfNeeded()
            // hide Tabbar
            self.tabBarController?.tabBar.frame.origin.y = self.view.frame.height
        })

    }

    @IBAction func dateDoneIsPressed(sender: AnyObject) {

        let newSelectDate = dateFormatter.stringFromDate(datepickerElement.date)

        containerVC?.enterDateLabel.text = newSelectDate

        userInfo.updateEnterDate( newSelectDate )

        dismissRelativeViews()

    }

    @IBAction func serviceDaysDoneIsPressed(sender: AnyObject) {

        if userPreference.valueForKey("serviceDays") == nil {
            userPreference.setInteger( 0, forKey: "serviceDays" )
        }

        containerVC?.serviceDaysLabel.text = calculateHelper.switchPeriod( userPreference.stringForKey("serviceDays")! )

        userInfo.updateServiceDays( userPreference.integerForKey("serviceDays") )

        dismissRelativeViews()

    }

    @IBAction func discountDaysDoneIsPressed(sender: AnyObject) {

        if userPreference.valueForKey("discountDays") == nil {
            userPreference.setInteger( 0, forKey: "discountDays" )
        }

        containerVC?.discountDaysLabel.text = userPreference.stringForKey("discountDays")

        userInfo.updateDiscountDays( userPreference.integerForKey("discountDays") )

        dismissRelativeViews()

    }

    func dismissScreenMask() {
        dismissRelativeViews()

        if screenMask.tag == 2 {
            if let oldService = containerVC?.serviceDaysLabel.text where containerVC?.serviceDaysLabel.text != "" {
                let oldService = calculateHelper.switchPeriod( oldService )
                userPreference.setInteger( Int(oldService)!, forKey: "serviceDays" )
            } else {
                userPreference.removeObjectForKey( "serviceDays" )
            }
        }
        if screenMask.tag == 3 {
            if let oldDiscount = containerVC?.discountDaysLabel.text where containerVC?.discountDaysLabel.text != "" {
                userPreference.setInteger( Int(oldDiscount)!, forKey: "discountDays" )
            } else {
                userPreference.removeObjectForKey( "discountDays" )
            }
        }
    }

    private func dismissRelativeViews() {
        datepickerViewBottomConstraint.constant = -200
        serviceDaysPickerViewBottomConstraint.constant = -200
        discountDaysPickerViewBottomConstraint.constant = -200

        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.screenMask.alpha = 0
            // show Tabbar
            self.tabBarController?.tabBar.frame.origin.y = self.view.frame.height-50
        }, completion: { finish in
            self.screenMask.hidden = true;
        })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embed" {
            if let settingTable = segue.destinationViewController as? SettingTableViewController {
                settingTable.parentVC = self
            }
        }
    }

    // *************** \\
    //      FBSDK      \\
    // *************** \\
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if error != nil {
            // Process error
        } else if result.isCancelled {
            // Handle cancellations
        } else {
            // Navigate to other view

            // Enable UISwitch
            containerVC?.publicSwitch.enabled = true
            if userPreference.boolForKey("publicProfile") {
                containerVC?.publicSwitch.setOn(true, animated: false)
            }

            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"])
            graphRequest.startWithCompletionHandler({ connection, result, error in

                if error == nil {
                    // Hide FB login button
                    self.FBLoginView.hidden = true
                    self.topConstraint.constant = -70

                    self.userInfo.storeFacebookInfo( result, syncCompletion: { messageContent, newStatus, newEnterDate, newServiceDays, newDiscountDays, newWeekendFixed, newPublicProfile in

                        // Ask user whether to download data from Parse or not
                        let syncAlertController = UIAlertController(title: "是否將資料同步至APP？", message: messageContent, preferredStyle: .Alert)
                        let yesAction = UIAlertAction(title: "是", style: .Default, handler: { (action) in
                            // Status
                            if newStatus != "" {
                                self.userPreference.setObject( newStatus, forKey: "status")
                                self.containerVC?.statusLabel.text = newStatus
                            }
                            // EnterDate
                            if newEnterDate != "" {
                                self.userPreference.setObject( newEnterDate, forKey: "enterDate")
                                self.containerVC?.enterDateLabel.text = newEnterDate
                            }
                            // ServiceDays
                            if newServiceDays != -1 {
                                self.userPreference.setInteger( newServiceDays, forKey: "serviceDays")
                                self.containerVC?.serviceDaysLabel.text = self.calculateHelper.switchPeriod( String(newServiceDays) )
                            }
                            // DiscountDays
                            if newDiscountDays != -1 {
                                self.userPreference.setInteger( newDiscountDays, forKey: "discountDays")
                                self.containerVC?.discountDaysLabel.text = String(newDiscountDays)
                            }
                            self.userPreference.setBool( newWeekendFixed, forKey: "autoWeekendFixed" )
                            self.containerVC?.autoWeekendSwitch.setOn( newWeekendFixed, animated: true )
                            self.userPreference.setBool( newPublicProfile, forKey: "publicProfile" )
                            self.containerVC?.publicSwitch.setOn( newPublicProfile, animated: true )
                        })
                        let noAction = UIAlertAction(title: "否", style: .Cancel, handler: { (action) in
                            self.userInfo.uploadAllData()
                        })
                        syncAlertController.addAction(yesAction)
                        syncAlertController.addAction(noAction)

                        self.presentViewController(syncAlertController, animated: true, completion: nil)
                    }, newUserTask: {})

                }

            }) // --- graphRequest
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }

    // MARK: These are the functions for UIPickerView
    func numberOfComponentsInPickerView(pickerView : UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == serviceDaysPickerElement ? serviceDaysPickerDataSource.count : discountDaysPickerDataSource.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == serviceDaysPickerElement ? serviceDaysPickerDataSource[row] : discountDaysPickerDataSource[row]
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        userPreference.setInteger( row, forKey: pickerView == serviceDaysPickerElement ? "serviceDays" : "discountDays" )
    }

}
