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

    init() {
        self.dateFormatter.dateFormat = "yyyy / MM / dd"
        self.dateFormatter.timeZone = NSTimeZone.localTimeZone()
        calendar!.timeZone = NSTimeZone.localTimeZone()
//println( NSTimeZone.localTimeZone() )
        var tempTimeString = dateFormatter.stringFromDate( NSDate() )
        self.currentDate = dateFormatter.dateFromString( tempTimeString )

        if self.isSettingAllDone() {
            self.updateDate()
        }
//        self.dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    }

    func isSettingAllDone() -> Bool {

        // Only ""enterDate"" & ""serviceDays""
        // Don't judge ""discountDays""

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
println(enterDate)
        let userServiceDays = userPreference.stringForKey("serviceDays")!
        dayComponent.year = 1
        dayComponent.day = userServiceDays == "1y" ? -1 : 14

        self.defaultRetireDate = calendar!.dateByAddingComponents( dayComponent, toDate: enterDate, options: nil)!
        // 預定退伍日 - defaultRetireDate

        var userDiscountDays: Int = 0

        if let discountDayString = userPreference.stringForKey("discountDays") {
            userDiscountDays = discountDayString.toInt()!
        } else {
            self.userPreference.setObject( "0", forKey: "discountDays" )
        }
        dayComponent.year = 0
        dayComponent.day = userDiscountDays*(-1)
        self.realRetireDate = calendar!.dateByAddingComponents( dayComponent, toDate: defaultRetireDate, options: nil)!
        // 折抵後退伍日 - realRetireDate

        let cal = NSCalendar.currentCalendar()
        let unit: NSCalendarUnit = .CalendarUnitDay
        self.remainedDays = cal.components(unit, fromDate: currentDate!, toDate: realRetireDate!, options: nil)
        // 剩餘幾天 - remainedDays
        self.passedDays = cal.components(unit, fromDate: enterDate!, toDate: currentDate!, options: nil)
        // 已過天數 - passedDays
        // widget 那邊似乎時區有問題，不過算了ㄏㄏ
        self.wholeServiceDays = cal.components( unit, fromDate: enterDate!, toDate: realRetireDate!, options: nil)

        self.weekendComponent = calendar!.components( .CalendarUnitWeekday, fromDate: realRetireDate! )
    }

    func getRetireDate() -> String {
        return dateFormatter.stringFromDate( realRetireDate )
    }

    func getPassedDays() -> Int {
        return self.passedDays.day
    }

    func getRemainedDays() -> Int {
        return self.fixWeekend( remainedDays.day )
    }

    func getCurrentProgress() -> Double {
        return Double( wholeServiceDays.day - self.fixWeekend( remainedDays.day ) ) / Double( wholeServiceDays.day )*100
    }

    func fixWeekend( var originalDays: Int ) -> Int {

        if weekendComponent.weekday == 1 {
            originalDays -= 2
        } else if weekendComponent.weekday == 7 {
            originalDays -= 1
        }

        return originalDays

    }

}