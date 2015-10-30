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

    let dataObject1 = [ "2015 / 06 / 25", 2, 27, "2016 / 05 / 28 Sat.", "2016 / 05 / 27 Fri." ]
    let dataObject2 = [ "2014 / 10 / 30", 3, 27, "2015 / 10 / 17 Sat.", "2015 / 10 / 16 Fri." ]
    let dataObject3 = [ "2015 / 08 / 06", 3,  9, "2016 / 08 / 11 Thu.", "2016 / 08 / 11 Thu." ]
    var dataOriginal: [AnyObject] = []

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        helper = CalculateHelper()
        self.userPreference = NSUserDefaults( suiteName: "group.EddieWen.SMSCount" )

        if self.userPreference.stringForKey("enterDate") != nil {
            self.dataOriginal.append( self.userPreference.stringForKey("enterDate")! )
        } else {
            self.dataOriginal.append( "X" )
        }

        if self.userPreference.stringForKey("serviceDays") != nil {
            self.dataOriginal.append( self.userPreference.integerForKey("serviceDays") )
        } else {
            self.dataOriginal.append( -1 )
        }

        if self.userPreference.stringForKey("discountDays") != nil {
            self.dataOriginal.append( self.userPreference.integerForKey("discountDays") )
        } else {
            self.dataOriginal.append( -1 )
        }

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

        if dataOriginal[0] as! String != "X" {
            self.userPreference.setObject( dataOriginal[0] as! String, forKey: "enterDate" )
        } else {
            self.userPreference.setObject( nil, forKey: "enterDate" )
        }

        if dataOriginal[1] as! Int != -1 {
            self.userPreference.setInteger( dataOriginal[1] as! Int, forKey: "serviceDays" )
        } else {
            self.userPreference.setObject( nil, forKey: "serviceDays" )
        }

        if dataOriginal[2] as! Int != -1 {
            self.userPreference.setInteger( dataOriginal[2] as! Int, forKey: "discountDays" )
        } else {
            self.userPreference.setObject( nil, forKey: "discountDays" )
        }

    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testRetire() {

        // test Group #1
        self.userPreference.setObject( dataObject1[0], forKey: "enterDate" )
        self.userPreference.setObject( dataObject1[1], forKey: "serviceDays" )
        self.userPreference.setObject( dataObject1[2], forKey: "discountDays" )

        helper.updateDate()

        XCTAssertEqual( helper.getRetireDate(), dataObject1[3], "RetireDate is wrong. #1" )
        XCTAssertEqual( helper.getFixedRetireDate(), dataObject1[4], "FixedRetireDate is wrong. #1" )

        // test Group #2
        self.userPreference.setObject( dataObject2[0], forKey: "enterDate" )
        self.userPreference.setObject( dataObject2[1], forKey: "serviceDays" )
        self.userPreference.setObject( dataObject2[2], forKey: "discountDays" )

        helper.updateDate()

        XCTAssertEqual( helper.getRetireDate(), dataObject2[3], "RetireDate is wrong. #2" )
        XCTAssertEqual( helper.getFixedRetireDate(), dataObject2[4], "FixedRetireDate is wrong. #2" )

        // test Group #3
        self.userPreference.setObject( dataObject3[0], forKey: "enterDate" )
        self.userPreference.setObject( dataObject3[1], forKey: "serviceDays" )
        self.userPreference.setObject( dataObject3[2], forKey: "discountDays" )

        helper.updateDate()

        XCTAssertEqual( helper.getRetireDate(), dataObject3[3], "RetireDate is wrong. #3" )
        XCTAssertEqual( helper.getFixedRetireDate(), dataObject3[4], "FixedRetireDate is wrong. #3" )

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
