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

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let userinfo = UserInfo()
        var dateString = "2014 / 01 / 02"

        XCTAssertEqual( dateString.characters.count, 14, "date length is not correct." )

//        userinfo

//        XCTAssertEqual( dateArray[0], 2014, "Year should be 2014, but is " )
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
