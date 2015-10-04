//
//  PercentageViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/13.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet var profileHeightConstraint: NSLayoutConstraint!
    @IBOutlet var stageText: UILabel!

    // Detail
    @IBOutlet var enterDateLabel: UILabel!
    @IBOutlet var serviceDaysLabel: UILabel!
    @IBOutlet var discountDaysLabel: UILabel!
    @IBOutlet var passedDaysLabel: UILabel!
    @IBOutlet var remainedDaysLabel: UILabel!
    @IBOutlet var finalRetireDateLabel: UILabel!
    @IBOutlet var retireDateLabel: UILabel!


    let countingClass = CountingDate()
    let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!

    let screenHeight = UIScreen.mainScreen().bounds.height

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.profileHeightConstraint.constant = self.screenHeight-64-50-100
        self.updateStageText()
    }

    override func viewDidAppear(animated: Bool) {

        if countingClass.isSettingAllDone() {
            // OK
            countingClass.updateDate()
            self.enterDateLabel.text =  countingClass.getEnterDate()
            self.serviceDaysLabel.text = countingClass.switchPeriod( self.userPreference.stringForKey("serviceDays")! )
            self.discountDaysLabel.text = self.userPreference.stringForKey("discountDays")
            self.passedDaysLabel.text = String( countingClass.getPassedDays() )
            self.remainedDaysLabel.text = String( countingClass.getRemainedDays() )
            self.finalRetireDateLabel.text = countingClass.getFixedRetireDate()

        } else {
            // switch to settingViewController ?
        }

    }

    func updateStageText() {
        let songArray = [ "替代役青年們夢想起飛", "像螞蟻默默做自己", "沒有懷疑沒有怨言", "愛心服務責任紀律" ]
        self.stageText.text = songArray[ Int( arc4random_uniform(4) ) ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
