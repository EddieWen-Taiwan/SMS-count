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
        self.calendar!.timeZone = NSTimeZone.localTimeZone()
        
        let tempTimeString = self.dateFormatter.stringFromDate( NSDate() )
        self.currentDate = self.dateFormatter.dateFromString( tempTimeString )

        // calculate data automaticlly
        if isSettingAllDone() {
            calculateData()
        }
    }

    private func isSettingAllDone() -> Bool {

        settingStatus = valueEnterDate == "" || valueServiceDays == -1 ? false : true
        return settingStatus

    }

    func calculateData() {

        enterDate = dateFormatter.dateFromString( valueEnterDate )!
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

        defaultRetireDate = calendar!.dateByAddingComponents(dayComponent, toDate: enterDate, options: [])!
        // 預定退伍日 - defaultRetireDate

        if valueDiscountDays == -1 {
            userPreference.setInteger( 0, forKey: "discountDays" )
            valueDiscountDays = 0
        }
        dayComponent.year = 0
        dayComponent.month = 0
        dayComponent.day = valueDiscountDays*(-1)
        realRetireDate = calendar!.dateByAddingComponents(dayComponent, toDate: defaultRetireDate, options: [])!
        // 折抵後退伍日 - realRetireDate

        let cal = NSCalendar.currentCalendar()
        let unit: NSCalendarUnit = .Day
        remainedDays = cal.components(unit, fromDate: currentDate!, toDate: realRetireDate!, options: [])
        // 剩餘幾天 - remainedDays
        passedDays = cal.components(unit, fromDate: enterDate!, toDate: currentDate!, options: [])
        // 已過天數 - passedDays
        wholeServiceDays = cal.components(unit, fromDate: enterDate!, toDate: realRetireDate!, options: [])

        weekendComponent = calendar!.components( .Weekday, fromDate: realRetireDate! )
        fixWeekend()
    }

    func isRetireDateFixed() -> Bool {
        if valueAutoFixed {
            if getRetireDate() != getFixedRetireDate() {
                return true
            }
        }
        return false
    }

    func getFixedRetireDate() -> String {
        var fixedRetireDate = realRetireDate
        if days2beFixed > 0 {
            dayComponent.year = 0
            dayComponent.month = 0
            dayComponent.day = days2beFixed*(-1)
            fixedRetireDate = calendar!.dateByAddingComponents(dayComponent, toDate: fixedRetireDate, options: [])!
        }
        return dateFormatter.stringFromDate( fixedRetireDate ) + switchWeekday( weekendComponent.weekday - days2beFixed )
    }

    func getRetireDate() -> String {
        return dateFormatter.stringFromDate( realRetireDate ) + switchWeekday( weekendComponent.weekday )
    }

    func getPassedDays() -> Int {
        return passedDays.day
    }

    func getRemainedDays() -> Int {
        return remainedDays.day - days2beFixed
    }

    func getCurrentProgress() -> Double {
        let total_days = wholeServiceDays.day - days2beFixed
        return Double( passedDays.day ) / Double( total_days )*100
    }

    func switchPeriod( period: String ) -> String {
        switch period {
            case "0": return "四個月"
            case "1": return "四個月五天"
            case "2": return "一年"
            case "3": return "一年十五天"
            case "4": return "三年"
            case "四個月": return "0"
            case "四個月五天": return "1"
            case "一年": return "2"
            case "一年十五天": return "3"
            case "三年": return "4"
            default: return ""
        }
    }

    private func switchWeekday( weekday: Int ) -> String {
        switch weekday {
            case 1: return " Sun."
            case 2: return " Mon."
            case 3: return " Tue."
            case 4: return " Wed."
            case 5: return " Thu."
            case -1, 6: return " Fri."
            case 7: return " Sat."
            default: return ""
        }
    }

    private func fixWeekend() {

        days2beFixed = 0

        if valueAutoFixed {
            if weekendComponent.weekday == 1 {
                days2beFixed = 2
            } else if weekendComponent.weekday == 7 {
                days2beFixed = 1
            }
        }

    }

}