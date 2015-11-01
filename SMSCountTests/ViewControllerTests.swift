//
//  ViewControllerTests.swift
//  SMSCount
//
//  Created by Eddie on 11/1/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import XCTest
@testable import SMSCount

class ViewControllerTests: XCTestCase {

    var targetViewController: ViewController!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.targetViewController = storyboard.instantiateViewControllerWithIdentifier("ViewController") as! ViewController

        self.targetViewController.loadView()
        self.targetViewController.viewDidLoad()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testViewControllerExist() {
        XCTAssertNotNil( self.targetViewController, "ViewController is not existed." )
    }

    func test_SwitchView() {

        // Should do nothing
        self.targetViewController.currentDisplay = "running"
        self.targetViewController.switchView()
        XCTAssertEqual( self.targetViewController.currentDisplay, "running", "This function should do nothing." )

        // Display : day -> chart
        self.targetViewController.currentDisplay = "day"
        self.targetViewController.switchView()

        let dispatchTime = self.makeDispatchTime( 0.5 )
        dispatch_after( dispatchTime, dispatch_get_main_queue(), {
            XCTAssertEqual( self.targetViewController.currentDisplay, "chart", "It should be changed to 'chart'." )
        })

        // Display : chart -> day
        self.targetViewController.currentDisplay = "chart"
        self.targetViewController.switchView()
        dispatch_after( dispatchTime, dispatch_get_main_queue(), {
            XCTAssertEqual( self.targetViewController.currentDisplay, "day", "It should be changed to 'day'." )
        })

    }

    func test_CheckDaysAnimation() {

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }


    private func makeDispatchTime( second: Double ) -> dispatch_time_t {
        let delay = second * Double(NSEC_PER_SEC)
        return dispatch_time( DISPATCH_TIME_NOW, Int64(delay) )
    }

}
