//
//  CountingDate.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/13.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class CalculateHelper {

    fileprivate let userPreference = UserDefaults( suiteName: "group.EddieWen.SMSCount" )!
    fileprivate let dateFormatter = DateFormatter()
    fileprivate var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    fileprivate var dayComponent = DateComponents()
    fileprivate var weekendComponent = DateComponents()

    // Original data
    var valueEnterDate: String
    var valueServiceDays: Int
    var valueDiscountDays: Int
    var valueAutoFixed: Bool

    // Outcome
    fileprivate var enterDate: Date!
    fileprivate var currentDate: Date!
    fileprivate var defaultRetireDate: Date!
    fileprivate var realRetireDate: Date!
    fileprivate var remainedDays: DateComponents!
    fileprivate var passedDays: DateComponents!
    fileprivate var wholeServiceDays: DateComponents!
    fileprivate var days2beFixed: Int = 0

    // For other ViewControllers
    var settingStatus: Bool = false

    init() {

        self.valueEnterDate = userPreference.string(forKey: "enterDate") ?? ""
        self.valueServiceDays = userPreference.string(forKey: "serviceDays") != nil ? userPreference.integer(forKey: "serviceDays") : -1
        self.valueDiscountDays = userPreference.string(forKey: "discountDays") != nil ? userPreference.integer(forKey: "discountDays") : -1
        self.valueAutoFixed = userPreference.bool(forKey: "autoWeekendFixed")

        self.dateFormatter.dateFormat = "yyyy / MM / dd"
        self.dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        self.calendar.timeZone = TimeZone.autoupdatingCurrent
        
        let tempTimeString = self.dateFormatter.string( from: Date() )
        self.currentDate = self.dateFormatter.date( from: tempTimeString )

        // calculate data automaticlly
        if isSettingAllDone() {
            calculateData()
        }
    }

    fileprivate func isSettingAllDone() -> Bool {

        settingStatus = valueEnterDate == "" || valueServiceDays == -1 ? false : true
        return settingStatus

    }

    func calculateData() {

        enterDate = dateFormatter.date( from: valueEnterDate )!
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

        defaultRetireDate = (calendar as NSCalendar).date(byAdding: dayComponent, to: enterDate, options: [])!
        // 預定退伍日 - defaultRetireDate

        if valueDiscountDays == -1 {
            userPreference.set( 0, forKey: "discountDays" )
            valueDiscountDays = 0
        }
        dayComponent.year = 0
        dayComponent.month = 0
        dayComponent.day = valueDiscountDays*(-1)
        realRetireDate = (calendar as NSCalendar).date(byAdding: dayComponent, to: defaultRetireDate, options: [])!
        // 折抵後退伍日 - realRetireDate

        let cal = Calendar.current
        let unit: NSCalendar.Unit = .day
        remainedDays = (cal as NSCalendar).components(unit, from: currentDate!, to: realRetireDate!, options: [])
        // 剩餘幾天 - remainedDays
        passedDays = (cal as NSCalendar).components(unit, from: enterDate!, to: currentDate!, options: [])
        // 已過天數 - passedDays
        wholeServiceDays = (cal as NSCalendar).components(unit, from: enterDate!, to: realRetireDate!, options: [])

        weekendComponent = (calendar as NSCalendar).components( .weekday, from: realRetireDate! )
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
            fixedRetireDate = (calendar as NSCalendar).date(byAdding: dayComponent, to: fixedRetireDate!, options: [])!
        }
        return dateFormatter.string( from: fixedRetireDate! ) + switchWeekday( weekendComponent.weekday! - days2beFixed )
    }

    func getRetireDate() -> String {
        return dateFormatter.string( from: realRetireDate ) + switchWeekday( weekendComponent.weekday! )
    }

    func getPassedDays() -> Int {
        return passedDays.day!
    }

    func getRemainedDays() -> Int {
        return remainedDays.day! - days2beFixed
    }

    func getCurrentProgress() -> Double {
        let total_days = wholeServiceDays.day! - days2beFixed
        return Double( passedDays.day! ) / Double( total_days )*100
    }

    func switchPeriod( _ period: String ) -> String {
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

    fileprivate func switchWeekday( _ weekday: Int ) -> String {
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

    fileprivate func fixWeekend() {

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
