//
//  PercentageViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/13.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet var stageText: UILabel!

    // Detail
    @IBOutlet var passedDaysLabel: UILabel!
    @IBOutlet var finalRetireDateLabel: UILabel!
    @IBOutlet var retireDateBottomConstraint: NSLayoutConstraint!
    @IBOutlet var retireDateView: UIView!
    @IBOutlet var retireDateLabel: UILabel!

    let calculateHelper = CalculateHelper()
    let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!

    let screenHeight = UIScreen.mainScreen().bounds.height

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.updateStageText()

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "repeat-image")!)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if calculateHelper.isSettingAllDone() {
            // OK
            calculateHelper.updateDate()
            self.passedDaysLabel.text = String( calculateHelper.getPassedDays() )

            if calculateHelper.isRetireDateFixed() {
                self.finalRetireDateLabel.text = calculateHelper.getFixedRetireDate()
                self.retireDateBottomConstraint.constant = 60
                self.retireDateView.hidden = false
                self.retireDateLabel.text = calculateHelper.getRetireDate()
            } else {
                self.finalRetireDateLabel.text = calculateHelper.getRetireDate()
                self.retireDateBottomConstraint.constant = 0
                self.retireDateView.hidden = true
            }

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
