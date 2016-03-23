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
    
    var dataSample = [AnyObject]( arrayLiteral:
        [ "2015 / 06 / 25", 2, 27, true, "2016 / 05 / 27 Fri.", true ],
        [ "2014 / 09 / 15", 3, 10, false, "2015 / 09 / 19 Sat.", false ],
        [ "2015 / 03 / 17", 4, 15, true, "2018 / 03 / 01 Thu.", false ],
        [ "2016 / 01 / 13", 0, 18, true, "2016 / 04 / 22 Fri.", true ]
    )

    let userDefault = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.userDefault.setValue("2015 / 06 / 25", forKey: "enterDate")
        self.userDefault.setInteger(2, forKey: "serviceDays")
        self.userDefault.setInteger(27, forKey: "discountDays")

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

    func testIsRetireDateFixed() {

        for i in 0 ..< self.dataSample.count {
            self.setDataSample( self.dataSample[i] )
            let helper = CalculateHelper()

            XCTAssertEqual( helper.isRetireDateFixed(), self.dataSample[i][5] as? Bool )
        }

    }

    func testGetRetireDate() {

        for i in 0 ..< self.dataSample.count {
            self.setDataSample( self.dataSample[i] )
            let helper = CalculateHelper()

            if helper.isRetireDateFixed() {
                XCTAssertEqual( helper.getFixedRetireDate(), self.dataSample[i][4] as? String )
            } else {
                XCTAssertEqual( helper.getRetireDate(), self.dataSample[i][4] as? String )
            }
        }

    }

    private func setDataSample( sample: AnyObject ) {
        self.userDefault.setValue( sample[0], forKey: "enterDate" )
        self.userDefault.setValue( sample[1], forKey: "serviceDays" )
        self.userDefault.setValue( sample[2], forKey: "discountDays" )
        self.userDefault.setValue( sample[3], forKey: "autoWeekendFixed" )
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
        
        self.userDefault.removeObjectForKey("enterDate")
        self.userDefault.removeObjectForKey("serviceDays")
        self.userDefault.removeObjectForKey("discountDays")

        // ONLY enterDate
        self.userDefault.setValue("2015 / 10 / 04", forKey: "enterDate")
        var helper = CalculateHelper()
        XCTAssertFalse( helper.settingStatus, "Only 'enterDate', it should be false." )

        self.userDefault.removeObjectForKey("enterDate")

        // ONLY serviceDays
        self.userDefault.setInteger(3, forKey: "serviceDays")
        helper = CalculateHelper()
        XCTAssertFalse( helper.settingStatus, "Only 'serviceDays', it should be false." )

        self.userDefault.removeObjectForKey("serviceDays")

        // ALL
        self.userDefault.setValue("2016 / 02 / 18", forKey: "enterDate")
        self.userDefault.setInteger(1, forKey: "serviceDays")
        self.userDefault.setInteger(15, forKey: "discountDays")
        XCTAssertTrue( CalculateHelper().settingStatus, "Both are set, it should be true.")

    }

}
