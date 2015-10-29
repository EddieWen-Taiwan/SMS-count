//
//  SMSCountTests.swift
//  SMSCountTests
//
//  Created by Eddie on 10/29/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import XCTest
@testable import SMSCount

class SMSCountTests: XCTestCase {

    var helper: CalculateHelper!
    var userPreference: NSUserDefaults!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        helper = CalculateHelper()
        self.userPreference = NSUserDefaults( suiteName: "group.EddieWen.SMSCount" )!
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testSplit2Int() {

        let userinfo = UserInfo()
        var dateString = "2014 / 01 / 02"

        XCTAssertEqual( dateString.characters.count, 14, "date length is not correct." )

        var dateArray = userinfo.split2Int( dateString )

        XCTAssertEqual( dateArray[0] as? Int, 2014, "Year should be 2014, but is \(dateArray[0])" )
        XCTAssertEqual( dateArray[1] as? Int, 01, "Month should be 01, but is \(dateArray[1])" )
        XCTAssertEqual( dateArray[2] as? Int, 02, "Date should be 02, but is \(dateArray[2])" )

        dateString = "2015 / 06 / 25"

        XCTAssertEqual( dateString.characters.count, 14, "date length is not correct." )

        dateArray = userinfo.split2Int( dateString )

        XCTAssertEqual( dateArray[0] as? Int, 2015, "Year should be 2015, but is \(dateArray[0])" )
        XCTAssertEqual( dateArray[1] as? Int, 06, "Month should be 06, but is \(dateArray[1])" )
        XCTAssertEqual( dateArray[2] as? Int, 25, "Date should be 25, but is \(dateArray[2])" )

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
