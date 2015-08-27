//
//  SettingViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/9.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class SettingViewController: BasicGestureViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet var mainCard: UIView!
    @IBOutlet var screenMask: UIView!

    @IBOutlet var enterDateLabel: UILabel!
    @IBOutlet var serviceDaysLabel: UILabel!
    @IBOutlet var discountDaysLabel: UILabel!

    @IBOutlet var datepickerView: UIView!
    @IBOutlet var datepickerElement: UIDatePicker!

    @IBOutlet var serviceDaysPickerView: UIView!
    @IBOutlet var serviceDaysPickerElement: UIPickerView!
    var serviceDaysPickerDataSource = [ "一年", "一年十五天" ]

    @IBOutlet var discountDaysPickerView: UIView!
    @IBOutlet var discountDaysPickerElement: UIPickerView!
    var discountDaysPickerDataSource = [ "0 天", "1 天", "2 天", "3 天", "4 天", "5 天", "6 天", "7 天", "8 天", "9 天", "10 天",  "11 天", "12 天", "13 天", "14 天", "15 天", "16 天", "17 天", "18 天", "19 天", "20 天", "21 天", "22 天", "23 天", "24 天", "25 天", "26 天", "27 天", "28 天", "29 天", "30 天" ]

    let dateFormatter = NSDateFormatter()
    let userPreference = NSUserDefaults( suiteName: "group.EddieWen.SMSCount" )!
    var screenHeight: CGFloat!
//    var rightSwipeGesture: UISwipeGestureRecognizer!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        dateFormatter.dateFormat = "yyyy / MM / dd"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: +28800)

//        rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: Selector("switchBetweenView:"))
//        rightSwipeGesture.direction = .Right
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        screenHeight = self.view.frame.height
        datepickerElement.datePickerMode = UIDatePickerMode.Date
        serviceDaysPickerElement.dataSource = self
        serviceDaysPickerElement.delegate = self
        discountDaysPickerElement.dataSource = self
        discountDaysPickerElement.delegate = self

        let pressOnScreenMask = UITapGestureRecognizer( target: self, action: "dismissScreenMask" )
        screenMask.addGestureRecognizer( pressOnScreenMask )

//        self.view.addGestureRecognizer(rightSwipeGesture)

        // make the shadow effect
        mainCard.layer.shadowOpacity = 0.15
        mainCard.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)

        if let userEnterDate = userPreference.stringForKey("enterDate") {
            enterDateLabel.text = userEnterDate
        }
        if let userServiceDays = userPreference.stringForKey("serviceDays") {
            serviceDaysLabel.text = userServiceDays == "1y" ? "一年" : "一年十五天"
        }
        if let userDiscountDays = userPreference.stringForKey("discountDays") {
            discountDaysLabel.text = userDiscountDays
        }

    }

    override func viewDidAppear(animated: Bool) {

        if discountDaysLabel.text == "" {

            if let userDiscountDays = userPreference.stringForKey("discountDays") {
                discountDaysLabel.text = userDiscountDays
            }

        }

    }

    @IBAction func editEnterDate(sender: AnyObject) {

        serviceDaysPickerView.frame.origin.y = screenHeight
        discountDaysPickerView.frame.origin.y = screenHeight
        screenMask.hidden = false

        showPickerView( datepickerView )

        if enterDateLabel.text != "" {
            var showDateOnPicker: String = enterDateLabel.text!
            datepickerElement.setDate( dateFormatter.dateFromString(showDateOnPicker)!, animated: false )
        }

    }

    @IBAction func editServiceDays(sender: AnyObject) {

        datepickerView.frame.origin.y = screenHeight
        discountDaysPickerView.frame.origin.y = screenHeight
        screenMask.hidden = false
        showPickerView( serviceDaysPickerView )

        if userPreference.stringForKey("serviceDays") != nil {
            var selectedRow = userPreference.stringForKey("serviceDays") == "1y" ? 0 : 1
            serviceDaysPickerElement.selectRow( selectedRow, inComponent: 0, animated: false )
        }

    }

    @IBAction func editDiscountDays(sender: AnyObject) {

        datepickerView.frame.origin.y = screenHeight
        serviceDaysPickerView.frame.origin.y = screenHeight
        screenMask.hidden = false
        showPickerView( discountDaysPickerView )

        if let selectedRow = userPreference.stringForKey("discountDays") {
            discountDaysPickerElement.selectRow( selectedRow.toInt()!, inComponent: 0, animated: false )
        }

    }

    func showPickerView( viewBeShow: UIView ) {

        UIView.animateWithDuration( 0.4, animations: {
            // show PickerView
            viewBeShow.frame.origin.y = self.screenHeight-200
            // hide Tabbar
            self.tabBarController?.tabBar.frame.origin.y = self.screenHeight
        })

    }

    @IBAction func dateDoneIsPressed(sender: AnyObject) {
        
        let newSelectDate = dateFormatter.stringFromDate(datepickerElement.date)

        enterDateLabel.text = newSelectDate
        userPreference.setObject( newSelectDate, forKey: "enterDate" )

        dismissScreenMask()

    }

    @IBAction func serviceDaysDoneIsPressed(sender: AnyObject) {

        if userPreference.stringForKey("serviceDays") == nil {
            userPreference.setObject( "1y", forKey: "serviceDays" )
        }

        serviceDaysLabel.text = userPreference.stringForKey("serviceDays") == "1y" ? "一年" : "一年十五天"

        dismissScreenMask()

    }

    @IBAction func discountDaysDoneIsPressed(sender: AnyObject) {

        if userPreference.stringForKey("discountDays") == nil {
            userPreference.setObject( "0", forKey: "discountDays" )
        }

        discountDaysLabel.text = userPreference.stringForKey("discountDays")

        dismissScreenMask()

    }

    func dismissScreenMask() {
        UIView.animateWithDuration( 0.4, animations: {
            // hide PickerView
            if self.datepickerView.frame.origin.y != self.screenHeight {
                self.datepickerView.frame.origin.y = self.screenHeight
            }
            if self.serviceDaysPickerView.frame.origin.y != self.screenHeight {
                self.serviceDaysPickerView.frame.origin.y = self.screenHeight
            }
            if self.discountDaysPickerView.frame.origin.y != self.screenHeight {
                self.discountDaysPickerView.frame.origin.y = self.screenHeight
            }
            // show Tabbar
            self.tabBarController?.tabBar.frame.origin.y = self.screenHeight-50
        })
        // 不做 trigger "done" 但下兩列會自動 update....
        screenMask.hidden = true;

        if serviceDaysLabel.text != "" {
            var serviceDay = serviceDaysLabel.text == "一年" ? "1y" : "1y15d"
            userPreference.setObject( serviceDay, forKey: "serviceDays" )
        } else {
            userPreference.removeObjectForKey( "serviceDays" )
        }
        if discountDaysLabel.text != "" {
            userPreference.setObject( discountDaysLabel.text, forKey: "discountDays" )
        } else {
            userPreference.removeObjectForKey( "discountDays" )
        }
    }

//    func switchBetweenView(sender: UISwipeGestureRecognizer) {
//
//        tabBarController?.selectedIndex = 1
//
//    }

    // MARK: These are the functions for UIPickerView
    func numberOfComponentsInPickerView(pickerView : UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ( pickerView == serviceDaysPickerElement ) ? serviceDaysPickerDataSource.count : discountDaysPickerDataSource.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return ( pickerView == serviceDaysPickerElement ) ? serviceDaysPickerDataSource[row] : discountDaysPickerDataSource[row]
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == serviceDaysPickerElement {
            var days: String = row == 0 ? "1y" : "1y15d"
            userPreference.setObject( days, forKey: "serviceDays" )
        } else if pickerView == discountDaysPickerElement {
            userPreference.setObject( row, forKey: "discountDays" )
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
