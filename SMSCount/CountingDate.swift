//
//  CountingDate.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/13.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class CountingDate {

    let userPreference = NSUserDefaults( suiteName: "group.EddieWen.SMSCount" )!
    let dateFormatter = NSDateFormatter()
    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    var dayComponent = NSDateComponents()
    var weekendComponent = NSDateComponents()

    var enterDate: NSDate!
    var currentDate: NSDate!
    var defaultRetireDate: NSDate!
    var realRetireDate: NSDate!
    var remainedDays: NSDateComponents!
    var passedDays: NSDateComponents!
    var wholeServiceDays: NSDateComponents!
    var days2beFixed: Int = 0

    init() {
        self.dateFormatter.dateFormat = "yyyy / MM / dd"
        self.dateFormatter.timeZone = NSTimeZone.localTimeZone()
        calendar!.timeZone = NSTimeZone.localTimeZone()

        let tempTimeString = dateFormatter.stringFromDate( NSDate() )
        self.currentDate = dateFormatter.dateFromString( tempTimeString )

        if self.isSettingAllDone() {
            self.updateDate()
        }
    }

    func isSettingAllDone() -> Bool {

        if self.userPreference.stringForKey("enterDate") == nil {
            return false
        }
        if self.userPreference.stringForKey("serviceDays") == nil {
            return false
        }
        return true

    }

    func updateDate() {

        self.enterDate = dateFormatter.dateFromString( userPreference.stringForKey("enterDate")! )!
        // 入伍日 - enterDate

        // v1.1 -> v1.2 dataFormat is change
        if let userServiceDays = self.userPreference.stringForKey("serviceDays") {
            if userServiceDays == "1y" {
                self.userPreference.setObject( 2, forKey: "serviceDays" )
            } else if userServiceDays == "1y15d" {
                self.userPreference.setObject( 3, forKey: "serviceDays" )
            }
        }

        let userServiceDays: Int = userPreference.integerForKey("serviceDays")
        switch( userServiceDays ) {
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
            default:
                // as value = 4
                dayComponent.year = 3
                dayComponent.month = 0
                dayComponent.day = -1
        }

        self.defaultRetireDate = calendar!.dateByAddingComponents(dayComponent, toDate: enterDate, options: [])!
        // 預定退伍日 - defaultRetireDate

        var userDiscountDays: Int = 0

        if let discountDayString = userPreference.stringForKey("discountDays") {
            userDiscountDays = Int(discountDayString)!
        } else {
            self.userPreference.setObject( "0", forKey: "discountDays" )
        }
        dayComponent.year = 0
        dayComponent.month = 0
        dayComponent.day = userDiscountDays*(-1)
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
        if userPreference.boolForKey("autoWeekendFixed") {
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
        switch(period) {
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
        switch( weekday ) {
            case -1:
                return " Fri."
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
            case 6:
                return " Fri."
            case 7:
                return " Sat."
            default:
                return " ."
        }
    }

    private func fixWeekend() {

        self.days2beFixed = 0

        if userPreference.boolForKey("autoWeekendFixed") {
            if self.weekendComponent.weekday == 1 {
                self.days2beFixed = 2
            } else if self.weekendComponent.weekday == 7 {
                self.days2beFixed = 1
            }
        }

    }

}