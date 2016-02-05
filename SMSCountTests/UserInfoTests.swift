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

    var fb_id: String!
    var username: String!
    var email: String!
    var status: String!
    var enterDate: String!
    var serviceDays: Int!
    var discountDays: Int!
    var autoWeekendFixed: Bool!
    var countdownAnimation: Bool!
    var publicProfile: Bool!

    let userDefault = NSUserDefaults( suiteName: "group.EddieWen.SMSCount" )!
    var info: UserInfo!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.info = UserInfo()
        self.info.objectIsChanged = false

        self.fb_id = self.userDefault.stringForKey("fb_id")
        self.username = self.userDefault.stringForKey("username")
        self.email = self.userDefault.stringForKey("email")
        self.status = self.userDefault.stringForKey("status")
        self.enterDate = self.userDefault.stringForKey("enterDate")
        self.serviceDays = self.userDefault.integerForKey("serviceDays")
        self.discountDays = self.userDefault.integerForKey("discountDays")
        self.autoWeekendFixed = self.userDefault.boolForKey("autoWeekendFixed")
        self.countdownAnimation = self.userDefault.boolForKey("countdownAnimation")
        self.publicProfile = self.userDefault.boolForKey("publicProfile")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.userDefault.setValue( self.fb_id, forKey: "fb_id" )
        self.userDefault.setValue( self.username, forKey: "username" )
        self.userDefault.setValue( self.email, forKey: "email" )
        self.userDefault.setValue( self.status, forKey: "status" )
        self.userDefault.setValue( self.enterDate, forKey: "enterDate" )
        self.userDefault.setInteger( self.serviceDays, forKey: "serviceDays" )
        self.userDefault.setInteger( self.discountDays, forKey: "discountDays" )
        self.userDefault.setBool( self.autoWeekendFixed, forKey: "autoWeekendFixed" )
        self.userDefault.setBool( self.countdownAnimation, forKey: "countdownAnimation" )
        self.userDefault.setBool( self.publicProfile, forKey: "publicProfile" )

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

        XCTAssertEqual( self.userDefault.stringForKey("fb_id"), fbid_1 )
        XCTAssertEqual( self.info.userObject.valueForKey("fb_id") as? String, fbid_1 )
        XCTAssertTrue( self.info.objectIsChanged )

    }

    func testAddUserName() {

        let name = "Robot"
        self.info.addUserName( name )

        XCTAssertEqual( self.userDefault.stringForKey("username"), name )
        XCTAssertEqual( self.info.userObject.valueForKey("username") as? String, name )
        XCTAssertTrue( self.info.objectIsChanged )

    }

    func testAddUserMail() {

        let mail = "service@smscount.lol"
        self.info.addUserMail( mail )

        XCTAssertEqual( self.userDefault.stringForKey("email"), mail )
        XCTAssertEqual( self.info.userObject.valueForKey("email") as? String, mail )
        XCTAssertTrue( self.info.objectIsChanged )

    }

    func testUpdateUserStatus() {

        let status = "Hello, SMSCount"
        self.info.updateUserStatus( status )

        XCTAssertEqual( self.userDefault.stringForKey("status"), status )
        XCTAssertEqual( self.info.userObject.valueForKey("status") as? String, status )
        XCTAssertTrue( self.info.objectIsChanged )

    }

    func testUpdateLocalUsername() {

        let name = "Robot II"
        self.info.updateLocalUsername( name )

        XCTAssertEqual( self.userDefault.stringForKey("username"), name )

    }

    func testUpdateLocalMail() {

        let mail = "no-reply@smscount.lol"
        self.info.updateLocalMail( mail )

        XCTAssertEqual( self.userDefault.stringForKey("email"), mail )

    }

    func testUpdateEnterDate() {

        let date = "2015 / 12 / 17"
        self.info.updateEnterDate( date )

        XCTAssertEqual( self.userDefault.stringForKey("enterDate"), date )
        XCTAssertEqual( self.info.userObject.valueForKey("yearOfEnterDate") as? Int, 2015 )
        XCTAssertEqual( self.info.userObject.valueForKey("monthOfEnterDate") as? Int, 12 )
        XCTAssertEqual( self.info.userObject.valueForKey("dateOfEnterDate") as? Int, 17 )
        XCTAssertTrue( self.info.objectIsChanged )

    }

}
