//
//  UserInfoTests.swift
//  SMSCount
//
//  Created by Eddie on 2/5/16.
//  Copyright © 2016 Wen. All rights reserved.
//

import XCTest
@testable import SMSCount

class UserInfoTests: XCTestCase {

    let userDefault = NSUserDefaults( suiteName: "group.EddieWen.SMSCount" )!
    var info: UserInfo!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.info = UserInfo()
        self.info.objectIsChanged = false
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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

    func testAddUserFBID() {

        let fbid_1 = "12345678"
        self.info.addUserFBID( fbid_1 )

        XCTAssertEqual(self.userDefault.stringForKey("fb_id"), fbid_1)
        XCTAssertEqual(self.info.userObject.valueForKey("fb_id") as? String, fbid_1)
        XCTAssertTrue(self.info.objectIsChanged)

    }

    func testAddUserName() {

        let name = "Robot"
        self.info.addUserName( name )

        XCTAssertEqual( self.userDefault.stringForKey("username"), name )
        XCTAssertEqual( self.info.userObject.valueForKey("username") as? String, name )
        XCTAssertTrue(self.info.objectIsChanged)

    }

}
