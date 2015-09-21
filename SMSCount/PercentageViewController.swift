//
//  PercentageViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/13.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class PercentageViewController: UIViewController {

    @IBOutlet var profileHeightConstraint: NSLayoutConstraint!
    @IBOutlet var serviceCard: UIView!
    @IBOutlet var stageText: UILabel!
    
    let countingClass = CountingDate()

    let screenHeight = UIScreen.mainScreen().bounds.height

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.profileHeightConstraint.constant = self.screenHeight-64-50-100
        self.updateStageText()
        self.serviceCard.layer.borderWidth = 1
        self.serviceCard.layer.borderColor = UIColor(red: 103/255, green: 211/255, blue: 173/255, alpha: 1).CGColor
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
