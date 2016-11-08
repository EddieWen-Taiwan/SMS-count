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
    
    let dateFormatter = DateFormatter()
    let userPreference = UserDefaults( suiteName: "group.EddieWen.SMSCount" )!

    var userInfo = UserInfo()
    let calculateHelper = CalculateHelper()

    var containerVC: SettingTableViewController?

    required init?(coder aDecoder: NSCoder) {
        self.serviceDaysPickerDataSource = ["四個月","四個月五天","一年","一年十五天","三年"]
        self.discountDaysPickerDataSource = ["0 天","1 天","2 天","3 天","4 天","5 天","6 天","7 天","8 天","9 天","10 天","11 天",
            "12 天","13 天","14 天","15 天","16 天","17 天","18 天","19 天","20 天","21 天","22 天","23 天","24 天","25 天","26 天","27 天","28 天","29 天","30 天"]
        self.dateFormatter.dateFormat = "yyyy / MM / dd"
        self.dateFormatter.timeZone = TimeZone.autoupdatingCurrent

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        datepickerElement.datePickerMode = UIDatePickerMode.date
        serviceDaysPickerElement.dataSource = self
        serviceDaysPickerElement.delegate = self
        discountDaysPickerElement.dataSource = self
        discountDaysPickerElement.delegate = self

        let pressOnScreenMask = UITapGestureRecognizer( target: self, action: #selector(dismissScreenMask) )
        screenMask.addGestureRecognizer( pressOnScreenMask )

        containerVC = self.childViewControllers.first as? SettingTableViewController

        // About FB login button
        if FBSDKAccessToken.current() == nil {
            FBLoginView.isHidden = false
            topConstraint.constant = 20
            // FB Login
            self.view.layoutIfNeeded()

            let loginView = FBSDKLoginButton()
            FBLoginView.addSubview( loginView )
            loginView.frame = CGRect( x: 0, y: 0, width: FBLoginView.frame.width, height: FBLoginView.frame.height )
            loginView.readPermissions = [ "public_profile", "email", "user_friends" ]
            loginView.delegate = self

            // Disable publicSwitch
            containerVC?.publicSwitch.isEnabled = false
        } else {
            // If there is FBtoken, then set UISwitch value depends on value in UserDefault
            if userPreference.bool(forKey: "publicProfile") {
                containerVC?.publicSwitch.setOn(true, animated: false)
            }
        }

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        userInfo.save()
    }

    func showPickerView() {

        screenMask.isHidden = false
        UIView.animate( withDuration: 0.4, animations: {
            self.screenMask.alpha = 0.6
            // show PickerView
            self.view.layoutIfNeeded()
            // hide Tabbar
            self.tabBarController?.tabBar.frame.origin.y = self.view.frame.height
        })

    }

    @IBAction func dateDoneIsPressed(_ sender: AnyObject) {

        let newSelectDate = dateFormatter.string(from: datepickerElement.date)

        containerVC?.enterDateLabel.text = newSelectDate

        userInfo.updateEnterDate( newSelectDate )

        dismissRelativeViews()

    }

    @IBAction func serviceDaysDoneIsPressed(_ sender: AnyObject) {

        if userPreference.value(forKey: "serviceDays") == nil {
            userPreference.set( 0, forKey: "serviceDays" )
        }

        containerVC?.serviceDaysLabel.text = calculateHelper.switchPeriod( userPreference.string(forKey: "serviceDays")! )

        userInfo.updateServiceDays( userPreference.integer(forKey: "serviceDays") )

        dismissRelativeViews()

    }

    @IBAction func discountDaysDoneIsPressed(_ sender: AnyObject) {

        if userPreference.value(forKey: "discountDays") == nil {
            userPreference.set( 0, forKey: "discountDays" )
        }

        containerVC?.discountDaysLabel.text = userPreference.string(forKey: "discountDays")

        userInfo.updateDiscountDays( userPreference.integer(forKey: "discountDays") )

        dismissRelativeViews()

    }

    func dismissScreenMask() {
        dismissRelativeViews()

        if screenMask.tag == 2 {
            if let oldService = containerVC?.serviceDaysLabel.text , containerVC?.serviceDaysLabel.text != "" {
                let oldService = calculateHelper.switchPeriod( oldService )
                userPreference.set( Int(oldService)!, forKey: "serviceDays" )
            } else {
                userPreference.removeObject( forKey: "serviceDays" )
            }
        }
        if screenMask.tag == 3 {
            if let oldDiscount = containerVC?.discountDaysLabel.text , containerVC?.discountDaysLabel.text != "" {
                userPreference.set( Int(oldDiscount)!, forKey: "discountDays" )
            } else {
                userPreference.removeObject( forKey: "discountDays" )
            }
        }
    }

    fileprivate func dismissRelativeViews() {
        datepickerViewBottomConstraint.constant = -200
        serviceDaysPickerViewBottomConstraint.constant = -200
        discountDaysPickerViewBottomConstraint.constant = -200

        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.screenMask.alpha = 0
            // show Tabbar
            self.tabBarController?.tabBar.frame.origin.y = self.view.frame.height-50
        }, completion: { finish in
            self.screenMask.isHidden = true;
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embed" {
            if let settingTable = segue.destination as? SettingTableViewController {
                settingTable.parentVC = self
            }
        }
    }

    // *************** \\
    //      FBSDK      \\
    // *************** \\
    
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            // Process error
        } else if result.isCancelled {
            // Handle cancellations
        } else {
            // Navigate to other view

            // Enable UISwitch
            containerVC?.publicSwitch.isEnabled = true
            if userPreference.bool(forKey: "publicProfile") {
                containerVC?.publicSwitch.setOn(true, animated: false)
            }

            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"])
            _ = graphRequest?.start(completionHandler: { connection, result, error in

                if error == nil {
                    // Hide FB login button
                    self.FBLoginView.isHidden = true
                    self.topConstraint.constant = -70

                    self.userInfo.storeFacebookInfo( result as AnyObject, syncCompletion: { messageContent, newStatus, newEnterDate, newServiceDays, newDiscountDays, newWeekendFixed, newPublicProfile in

                        // Ask user whether to download data from Parse or not
                        let syncAlertController = UIAlertController(title: "是否將資料同步至APP？", message: messageContent, preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "是", style: .default, handler: { (action) in
                            // Status
                            if newStatus != "" {
                                self.userPreference.set( newStatus, forKey: "status")
                                self.containerVC?.statusLabel.text = newStatus
                            }
                            // EnterDate
                            if newEnterDate != "" {
                                self.userPreference.set( newEnterDate, forKey: "enterDate")
                                self.containerVC?.enterDateLabel.text = newEnterDate
                            }
                            // ServiceDays
                            if newServiceDays != -1 {
                                self.userPreference.set( newServiceDays, forKey: "serviceDays")
                                self.containerVC?.serviceDaysLabel.text = self.calculateHelper.switchPeriod( String(newServiceDays) )
                            }
                            // DiscountDays
                            if newDiscountDays != -1 {
                                self.userPreference.set( newDiscountDays, forKey: "discountDays")
                                self.containerVC?.discountDaysLabel.text = String(newDiscountDays)
                            }
                            self.userPreference.set( newWeekendFixed, forKey: "autoWeekendFixed" )
                            self.containerVC?.autoWeekendSwitch.setOn( newWeekendFixed, animated: true )
                            self.userPreference.set( newPublicProfile, forKey: "publicProfile" )
                            self.containerVC?.publicSwitch.setOn( newPublicProfile, animated: true )
                        })
                        let noAction = UIAlertAction(title: "否", style: .cancel, handler: { (action) in
                            self.userInfo.uploadAllData()
                        })
                        syncAlertController.addAction(yesAction)
                        syncAlertController.addAction(noAction)

                        self.present(syncAlertController, animated: true, completion: nil)
                    }, newUserTask: {})

                }

            }) // --- graphRequest
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }

    // MARK: These are the functions for UIPickerView
    func numberOfComponents(in pickerView : UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == serviceDaysPickerElement ? serviceDaysPickerDataSource.count : discountDaysPickerDataSource.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == serviceDaysPickerElement ? serviceDaysPickerDataSource[row] : discountDaysPickerDataSource[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        userPreference.set( row, forKey: pickerView == serviceDaysPickerElement ? "serviceDays" : "discountDays" )
    }

}
