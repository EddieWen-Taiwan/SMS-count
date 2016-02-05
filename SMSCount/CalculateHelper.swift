//
//  CountingDate.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/13.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class CalculateHelper {

    private let userPreference = NSUserDefaults( suiteName: "group.EddieWen.SMSCount" )!
    private let dateFormatter = NSDateFormatter()
    private let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    private var dayComponent = NSDateComponents()
    private var weekendComponent = NSDateComponents()

    // Original data
    var valueEnterDate: String
    var valueServiceDays: Int
    var valueDiscountDays: Int
    var valueAutoFixed: Bool

    // Outcome
    private var enterDate: NSDate!
    private var currentDate: NSDate!
    private var defaultRetireDate: NSDate!
    private var realRetireDate: NSDate!
    private var remainedDays: NSDateComponents!
    private var passedDays: NSDateComponents!
    private var wholeServiceDays: NSDateComponents!
    private var days2beFixed: Int = 0

    // For other ViewControllers
    var settingStatus: Bool = false

    init() {

        self.valueEnterDate = userPreference.stringForKey("enterDate") ?? ""
        self.valueServiceDays = userPreference.stringForKey("serviceDays") != nil ? userPreference.integerForKey("serviceDays") : -1
        self.valueDiscountDays = userPreference.stringForKey("discountDays") != nil ? userPreference.integerForKey("discountDays") : -1
        self.valueAutoFixed = userPreference.boolForKey("autoWeekendFixed")

        self.dateFormatter.dateFormat = "yyyy / MM / dd"
        self.dateFormatter.timeZone = NSTimeZone.localTimeZone()
        calendar!.timeZone = NSTimeZone.localTimeZone()
        
        let tempTimeString = dateFormatter.stringFromDate( NSDate() )
        self.currentDate = dateFormatter.dateFromString( tempTimeString )

        // calculate data automaticlly
        if self.isSettingAllDone() {
            self.calculateData()
        }
    }

    func isSettingAllDone() -> Bool {

        self.settingStatus = self.valueEnterDate == "" || self.valueServiceDays == -1 ? false : true

        return self.settingStatus

    }

    func calculateData() {

        self.enterDate = dateFormatter.dateFromString( self.valueEnterDate )!
        // 入伍日 - enterDate

        switch valueServiceDays {
            case 0:
                dayComponent.year = 0
                dayComponent.month = 4
                dayComponent.day = -1
            case 1:
                dayComponent.year = 0
                dayComponent.month = 4
                dayComponent.day = 5-1
            case 2:
                dayComponent.year = 1
                dayComponent.month = 0
                dayComponent.day = -1
            case 3:
                dayComponent.year = 1
                dayComponent.month = 0
                dayComponent.day = 15-1
            default: // as value = 4
                dayComponent.year = 3
                dayComponent.month = 0
                dayComponent.day = -1
        }

        self.defaultRetireDate = calendar!.dateByAddingComponents(dayComponent, toDate: enterDate, options: [])!
        // 預定退伍日 - defaultRetireDate

        if self.valueDiscountDays == -1 {
            userPreference.setInteger( 0, forKey: "discountDays" )
            self.valueDiscountDays = 0
        }
        dayComponent.year = 0
        dayComponent.month = 0
        dayComponent.day = self.valueDiscountDays*(-1)
        self.realRetireDate = calendar!.dateByAddingComponents(dayComponent, toDate: defaultRetireDate, options: [])!
        // 折抵後退伍日 - realRetireDate

        let cal = NSCalendar.currentCalendar()
        let unit: NSCalendarUnit = .Day
        self.remainedDays = cal.components(unit, fromDate: currentDate!, toDate: realRetireDate!, options: [])
        // 剩餘幾天 - remainedDays
        self.passedDays = cal.components(unit, fromDate: enterDate!, toDate: currentDate!, options: [])
        // 已過天數 - passedDays
        self.wholeServiceDays = cal.components(unit, fromDate: enterDate!, toDate: realRetireDate!, options: [])

        self.weekendComponent = calendar!.components( .Weekday, fromDate: realRetireDate! )
        self.fixWeekend()
    }

    func isRetireDateFixed() -> Bool {
        if self.valueAutoFixed {
            if self.getRetireDate() != self.getFixedRetireDate() {
                return true
            }
        }
        return false
    }

    func getFixedRetireDate() -> String {
        var fixedRetireDate = self.realRetireDate
        if self.days2beFixed > 0 {
            dayComponent.year = 0
            dayComponent.month = 0
            dayComponent.day = self.days2beFixed*(-1)
            fixedRetireDate = calendar!.dateByAddingComponents(dayComponent, toDate: fixedRetireDate, options: [])!
        }
        return dateFormatter.stringFromDate( fixedRetireDate ) + switchWeekday( weekendComponent.weekday - self.days2beFixed )
    }

    func getRetireDate() -> String {
        return dateFormatter.stringFromDate( self.realRetireDate ) + switchWeekday( weekendComponent.weekday )
    }

    func getPassedDays() -> Int {
        return self.passedDays.day
    }

    func getRemainedDays() -> Int {
        return remainedDays.day - self.days2beFixed
    }

    func getCurrentProgress() -> Double {
        let total_days = wholeServiceDays.day - self.days2beFixed
        return Double( self.passedDays.day ) / Double( total_days )*100
    }

    func switchPeriod( period: String ) -> String {
        var output: String = ""
        switch period {
            case "0":
                output = "四個月"
            case "1":
                output = "四個月五天"
            case "2":
                output = "一年"
            case "3":
                output = "一年十五天"
            case "4":
                output = "三年"
            case "四個月":
                output = "0"
            case "四個月五天":
                output = "1"
            case "一年":
                output = "2"
            case "一年十五天":
                output = "3"
            case "三年":
                output = "4"
            default:
                output = "."
        }
        return output
    }

    private func switchWeekday( weekday: Int ) -> String {
        switch weekday {
            case 1:
                return " Sun."
            case 2:
                return " Mon."
            case 3:
                return " Tue."
            case 4:
                return " Wed."
            case 5:
                return " Thu."
            case -1, 6:
                return " Fri."
            case 7:
                return " Sat."
            default:
                return " "
        }
    }

    private func fixWeekend() {

        self.days2beFixed = 0

        if self.valueAutoFixed {
            if self.weekendComponent.weekday == 1 {
                self.days2beFixed = 2
            } else if self.weekendComponent.weekday == 7 {
                self.days2beFixed = 1
            }
        }

    }

}