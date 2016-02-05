//
//  CalculateHelperTests.swift
//  SMSCount
//
//  Created by Eddie on 2/4/16.
//  Copyright © 2016 Wen. All rights reserved.
//

import XCTest
@testable import SMSCount

class CalculateHelperTests: XCTestCase {

    var originEnterDate: String = ""
    var originServiceDays: Int = 0
    var originDiscountDays: Int = 0

    let userDefault = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.originEnterDate = self.userDefault.stringForKey("enterDate")!
        self.originServiceDays = self.userDefault.integerForKey("serviceDays")
        self.originDiscountDays = self.userDefault.integerForKey("discountDays")

        self.removeDefaultValue()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.userDefault.setValue(self.originEnterDate, forKey: "enterDate")
        self.userDefault.setInteger(self.originServiceDays, forKey: "serviceDays")
        self.userDefault.setInteger(self.originDiscountDays, forKey: "discountDays")

        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

    func testSwitchPeriod() {

        let helper = CalculateHelper()
        XCTAssertEqual( helper.switchPeriod("0"), "四個月" )
        XCTAssertEqual( helper.switchPeriod("1"), "四個月五天" )
        XCTAssertEqual( helper.switchPeriod("2"), "一年" )
        XCTAssertEqual( helper.switchPeriod("3"), "一年十五天" )
        XCTAssertEqual( helper.switchPeriod("4"), "三年" )
        XCTAssertEqual( helper.switchPeriod("四個月"), "0" )
        XCTAssertEqual( helper.switchPeriod("四個月五天"), "1" )
        XCTAssertEqual( helper.switchPeriod("一年"), "2" )
        XCTAssertEqual( helper.switchPeriod("一年十五天"), "3" )
        XCTAssertEqual( helper.switchPeriod("三年"), "4" )

        XCTAssertNotEqual( helper.switchPeriod("2"), "三年" )
        XCTAssertNotEqual( helper.switchPeriod("一年十五天"), "0" )
        XCTAssertNotEqual( helper.switchPeriod("abc"), "三年" )

    }

    func testIsSettingAllDone() {

        self.userDefault.setValue("2015/10/04", forKey: "enterDate")
        XCTAssertFalse( CalculateHelper().isSettingAllDone(), "Only 'enterDate', it should be false." )

        self.removeDefaultValue()

        self.userDefault.setInteger(3, forKey: "serviceDays")
        XCTAssertFalse( CalculateHelper().isSettingAllDone(), "Only 'serviceDays', it should be false." )

        self.removeDefaultValue()

        self.userDefault.setValue("2015/05/11", forKey: "enterDate")
        self.userDefault.setInteger(1, forKey: "serviceDays")
        XCTAssertTrue( CalculateHelper().isSettingAllDone(), "Both are set, it should be true.")

        self.removeDefaultValue()

    }

    private func removeDefaultValue() {
        self.userDefault.removeObjectForKey("enterDate")
        self.userDefault.removeObjectForKey("serviceDays")
        self.userDefault.removeObjectForKey("discountDays")
    }

}
