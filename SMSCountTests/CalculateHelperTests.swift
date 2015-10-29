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

    func testCalculate() {
        
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

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
