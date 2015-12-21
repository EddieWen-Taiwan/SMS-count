//
//  SettingViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/9.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Parse

class SettingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet var screenMask: UIView!
    @IBOutlet var FBLoginView: UIView!
    @IBOutlet var topConstraint: NSLayoutConstraint!

    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var enterDateLabel: UILabel!
    @IBOutlet var serviceDaysLabel: UILabel!
    @IBOutlet var discountDaysLabel: UILabel!

    @IBOutlet var datepickerView: UIView!
    @IBOutlet var datepickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var datepickerElement: UIDatePicker!

    @IBOutlet var serviceDaysPickerView: UIView!
    @IBOutlet var serviceDaysPickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var serviceDaysPickerElement: UIPickerView!
    var serviceDaysPickerDataSource = [ "四個月", "四個月五天", "一年", "一年十五天", "三年" ]

    @IBOutlet var discountDaysPickerView: UIView!
    @IBOutlet var discountDaysPickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var discountDaysPickerElement: UIPickerView!
    var discountDaysPickerDataSource = [ "0 天", "1 天", "2 天", "3 天", "4 天", "5 天", "6 天", "7 天", "8 天", "9 天", "10 天",  "11 天", "12 天", "13 天", "14 天", "15 天", "16 天", "17 天", "18 天", "19 天", "20 天", "21 天", "22 天", "23 天", "24 天", "25 天", "26 天", "27 天", "28 天", "29 天", "30 天" ]

    @IBOutlet var autoWeekendSwitch: UISwitch!

    let calculateHelper = CalculateHelper()
    let dateFormatter = NSDateFormatter()
    let userPreference = NSUserDefaults( suiteName: "group.EddieWen.SMSCount" )!

    var userInfo: UserInfo!

    var containerVC: SettingTableViewController?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        dateFormatter.dateFormat = "yyyy / MM / dd"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        datepickerElement.datePickerMode = UIDatePickerMode.Date
        serviceDaysPickerElement.dataSource = self
        serviceDaysPickerElement.delegate = self
        discountDaysPickerElement.dataSource = self
        discountDaysPickerElement.delegate = self

        let pressOnScreenMask = UITapGestureRecognizer( target: self, action: "dismissScreenMask" )
        screenMask.addGestureRecognizer( pressOnScreenMask )

        // About FB login button
        if FBSDKAccessToken.currentAccessToken() == nil {
            self.FBLoginView.hidden = false
            self.topConstraint.constant = 104
            // FB Login
            self.view.layoutIfNeeded()

            let loginView = FBSDKLoginButton()
            self.FBLoginView.addSubview( loginView )
            loginView.frame = CGRectMake( 0, 0, self.FBLoginView.frame.width, self.FBLoginView.frame.height )
            loginView.readPermissions = [ "public_profile", "email", "user_friends" ]
            loginView.delegate = self
        }

        self.userInfo = UserInfo()

        self.containerVC = self.childViewControllers.first as? SettingTableViewController
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if discountDaysLabel.text == "" {
            if let userDiscountDays = userPreference.stringForKey("discountDays") {
                discountDaysLabel.text = userDiscountDays
            }
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        userInfo.save()
    }

    @IBAction func editEnterDate(sender: AnyObject) {
    }

    @IBAction func editServiceDays(sender: AnyObject) {

        self.datepickerViewBottomConstraint.constant = -200
        self.discountDaysPickerViewBottomConstraint.constant = -200
        self.serviceDaysPickerViewBottomConstraint.constant = 0
        self.screenMask.tag = 2

        self.showPickerView()

        if let userServiceDays: Int = userPreference.integerForKey("serviceDays") {
            serviceDaysPickerElement.selectRow( userServiceDays, inComponent: 0, animated: false )
        }

    }

    @IBAction func editDiscountDays(sender: AnyObject) {

        self.datepickerViewBottomConstraint.constant = -200
        self.serviceDaysPickerViewBottomConstraint.constant = -200
        self.discountDaysPickerViewBottomConstraint.constant = 0
        self.screenMask.tag = 3

        self.showPickerView()

        if let selectedRow: Int = userPreference.integerForKey("discountDays") {
            discountDaysPickerElement.selectRow( selectedRow, inComponent: 0, animated: false )
        }

    }

    func showPickerView() {

        self.screenMask.hidden = false
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

        if let containerVC = self.containerVC {
            containerVC.enterDateLabel.text = newSelectDate
        }
        userInfo.updateEnterDate( newSelectDate )

        self.dismissRelativeViews()

    }

    @IBAction func serviceDaysDoneIsPressed(sender: AnyObject) {

        if self.userPreference.objectForKey("serviceDays") == nil {
            self.userPreference.setInteger( 0, forKey: "serviceDays" )
        }

        self.serviceDaysLabel.text = calculateHelper.switchPeriod( self.userPreference.stringForKey("serviceDays")! )
        userInfo.updateServiceDays( self.userPreference.integerForKey("serviceDays") )

        self.dismissRelativeViews()

    }

    @IBAction func discountDaysDoneIsPressed(sender: AnyObject) {

        if self.userPreference.objectForKey("discountDays") == nil {
            self.userPreference.setInteger( 0, forKey: "discountDays" )
        }

        self.discountDaysLabel.text = self.userPreference.stringForKey("discountDays")
        userInfo.updateDiscountDays( self.userPreference.integerForKey("discountDays") )

        self.dismissRelativeViews()

    }

    func dismissScreenMask() {
        self.dismissRelativeViews()

        if self.screenMask.tag == 2 {
            if serviceDaysLabel.text != "" {
                let newServiceDays = calculateHelper.switchPeriod(serviceDaysLabel.text!)
                userPreference.setObject( Int(newServiceDays), forKey: "serviceDays" )
            } else {
                userPreference.removeObjectForKey( "serviceDays" )
            }
        }
        if self.screenMask.tag == 3 {
            if discountDaysLabel.text != "" {
                let newDiscountDays = discountDaysLabel.text!
                userPreference.setInteger( Int(newDiscountDays)!, forKey: "discountDays" )
            } else {
                userPreference.removeObjectForKey( "discountDays" )
            }
        }
    }

    func dismissRelativeViews() {
        self.datepickerViewBottomConstraint.constant = -200
        self.serviceDaysPickerViewBottomConstraint.constant = -200
        self.discountDaysPickerViewBottomConstraint.constant = -200

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
            let settingTable = segue.destinationViewController as? SettingTableViewController
            settingTable?.parentVC = self
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

            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in

                if error == nil {
                    // Hide FB login button
                    self.FBLoginView.hidden = true
                    self.topConstraint.constant = 24
                    if let FBID = result.objectForKey("id") {

                        // Search parse data by FBID, check whether there is matched data.
                        let fbIdQuery = PFQuery(className: "UserT")
                        fbIdQuery.whereKey( "fb_id", equalTo: FBID )
                        fbIdQuery.findObjectsInBackgroundWithBlock{ (objects: [PFObject]?, error: NSError?) -> Void in
                            if error == nil {

                                self.userInfo.addUserFBID( FBID as! String )

                                if objects!.count > 0 {
                                    for user in objects! {
                                        // Update local objectId

                                        if let userID = user.objectId {
                                            self.userInfo.updateLocalObjectId( userID )
                                        }
                                        if let username = user.valueForKey("username") {
                                            self.userInfo.updateLocalUsername(username as! String)
                                        }
                                        if let userMail = user.valueForKey("email") {
                                            self.userInfo.updateLocalMail( userMail as! String )
                                        }

                                        // Make message of detail data
                                        var messageContent = ""
                                        var newEnterDate = ""
                                        var newServiceDays: Int = -1
                                        var newDiscountDays: Int = -1
                                        var newStatus = ""

                                        if user.valueForKey("status") != nil {
                                            newStatus = user.valueForKey("status") as! String
                                        }
                                        if let year = user.valueForKey("yearOfEnterDate") {
                                            let month = ( (user.valueForKey("monthOfEnterDate") as! Int) < 10 ? "0" : "" ) + String(user.valueForKey("monthOfEnterDate")!)
                                            let date = ( (user.valueForKey("dateOfEnterDate") as! Int) < 10 ? "0" : "" ) + String(user.valueForKey("dateOfEnterDate")!)
                                            // Store data
                                            newEnterDate = "\(year) / \(month) / \(date)"
                                            messageContent += "入伍日期：\(newEnterDate)\n"
                                        }
                                        if let service = user.valueForKey("serviceDays") {
                                            // Store data
                                            newServiceDays = service as! Int
                                            let serviceStr: String = self.calculateHelper.switchPeriod( String(service) )
                                            messageContent += "役期天數：\(serviceStr)\n"
                                        }
                                        if let discount = user.valueForKey("discountDays") {
                                            // Store data
                                            newDiscountDays = discount as! Int
                                            messageContent += "折抵天數：\(discount)天"
                                        }

                                        // Ask user whether to download data from Parse or not
                                        let syncAlertController = UIAlertController(title: "是否將資料同步至APP？", message: messageContent, preferredStyle: .Alert)
                                        let yesAction = UIAlertAction(title: "是", style: .Default, handler: { (action) in
                                            // Status
                                            if newStatus != "" {
                                                self.userPreference.setObject( newStatus, forKey: "status")
                                                self.statusLabel.text = newStatus
                                            }
                                            // EnterDate
                                            if newEnterDate != "" {
                                                self.userPreference.setObject( newEnterDate, forKey: "enterDate")
                                                self.enterDateLabel.text = newEnterDate
                                            }
                                            // ServiceDays
                                            if newServiceDays != -1 {
                                                self.userPreference.setInteger( newServiceDays, forKey: "serviceDays")
                                                self.serviceDaysLabel.text = self.calculateHelper.switchPeriod( String(newServiceDays) )
                                            }
                                            // DiscountDays
                                            if newDiscountDays != -1 {
                                                self.userPreference.setInteger( newDiscountDays, forKey: "discountDays")
                                                self.discountDaysLabel.text = String(newDiscountDays)
                                            }
                                        })
                                        let noAction = UIAlertAction(title: "否", style: .Cancel, handler: { (action) in
                                            self.userInfo.uploadAllData()
                                        })
                                        syncAlertController.addAction(yesAction)
                                        syncAlertController.addAction(noAction)

                                        self.presentViewController( syncAlertController, animated: true, completion: nil)

                                    }
                                } else {
                                    // Update user email, name .... by objectId

                                    if let userName = result.objectForKey("name") {
                                        self.userInfo.addUserName( userName as! String )
                                    }
                                    if let userMail = result.objectForKey("email") {
                                        self.userInfo.addUserMail( userMail as! String )
                                    }
                                    self.userInfo.save()
                                }

                            }
                        } // --- fbIdQuery

                    }
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
        let forKeyString = pickerView == serviceDaysPickerElement ? "serviceDays" : "discountDays"
        self.userPreference.setInteger( row, forKey: forKeyString )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
