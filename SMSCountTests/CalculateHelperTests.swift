//
//  CalculateHelperTests.swift
//  SMSCount
//
//  Created by Eddie on 10/29/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import XCTest
@testable import SMSCount

class CalculateHelperTests: XCTestCase {

    var helper: CalculateHelper!
    var userPreference: NSUserDefaults!

    let dataObject1 = [ "2015 / 06 / 25", 2, 27, "2016 / 06 / 28", "2016 / 06 / 27" ]
    let dataObject2 = [ "2014 / 10 / 30", 3, 27, "2015 / 10 / 17", "2015 / 10 / 16" ]
    let dataObject3 = [ "2015 / 08 / 06", 3, 9, "2016 / 08 / 11", "2016 / 08 / 11" ]

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        helper = CalculateHelper()
        self.userPreference = NSUserDefaults( suiteName: "group.EddieWen.SMSCount" )
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testRetireDate() {

    }

    func testFixedRetireDate() {

    }

    func testIsSettingAllDone() {

        var enterDate: String = "XX"
        var serviceDays: Int = -1

        if self.userPreference.stringForKey("enterDate") != nil {
            enterDate = self.userPreference.stringForKey("enterDate")!
        }
        if self.userPreference.stringForKey("serviceDays") != nil {
            serviceDays = self.userPreference.integerForKey("serviceDays")
        }

        self.userPreference.setObject( nil, forKey: "enterDate" )
        self.userPreference.setObject( nil, forKey: "serviceDays" )
        XCTAssertFalse( helper.isSettingAllDone(), "It should be False" )

        self.userPreference.setObject( "2015 / 06 / 25", forKey: "enterDate" )
        XCTAssertFalse( helper.isSettingAllDone(), "It should be False" )

        self.userPreference.setObject( nil, forKey: "enterDate" )
        self.userPreference.setObject( 3, forKey: "serviceDays" )
        XCTAssertFalse( helper.isSettingAllDone(), "It should be False" )

        self.userPreference.setObject( "2015 / 06 / 25", forKey: "enterDate" )
        self.userPreference.setObject( 1, forKey: "serviceDays" )
        XCTAssertTrue( helper.isSettingAllDone(), "It should be True" )

        if enterDate != "XX" {
            self.userPreference.setObject( enterDate, forKey: "enterDate" )
        }
        if serviceDays != -1 {
            self.userPreference.setObject( serviceDays, forKey: "serviceDays" )
        }
    }

    func testSwitchPeriod() {

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

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
