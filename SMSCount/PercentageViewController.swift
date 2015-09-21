//
//  PercentageViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/13.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class PercentageViewController: UIViewController {

    @IBOutlet var checkMyHeight: UIView!
    @IBOutlet var profileHeightConstraint: NSLayoutConstraint!
    @IBOutlet var stageText: UILabel!
    @IBOutlet var pieChartView: UIView!
    @IBOutlet var percentageLabel: UILabel!
    @IBOutlet var percentSymbol: UILabel!
    
    let countingClass = CountingDate()

    let screenHeight = UIScreen.mainScreen().bounds.height

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //        self.backgroundImage.image = UIImage(named: monthImage)
        self.updateStageText()
    }

    override func viewDidLayoutSubviews() {
        if self.profileHeightConstraint.constant != self.checkMyHeight.bounds.height-100 {
            self.profileHeightConstraint.constant = self.checkMyHeight.bounds.height-100
        }
    }

    override func viewDidAppear(animated: Bool) {

        if countingClass.isSettingAllDone() {
            // OK

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
