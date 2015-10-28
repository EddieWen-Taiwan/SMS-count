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

    @IBOutlet var userSticker: UIImageView!
    var stickerIsDownloaded: Bool = false

    let calculateHelper = CalculateHelper()
    let reachability = Reachability()

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

        if let fbid = self.userPreference.stringForKey("fb_id") {
            if !self.stickerIsDownloaded && reachability.isConnectedToNetwork() {
                // Download Facebook profile
                self.stickerIsDownloaded = true
            }
        }

    }
    
    private func downloadImage( url: NSURL, backgroundImage: UIImageView ) {
        reachability.getImageFromUrl(url) { (data, response, error)  in
            
//            if data == nil {
//                backgroundImage.backgroundColor = UIColor(patternImage: UIImage(named: "default-background")!)
//                backgroundImage.alpha = 1
//            } else {
//                dispatch_async( dispatch_get_main_queue() ) { () -> Void in
//                    self.saveImage( UIImage(data: data!)! )
//                    self.userPreference.setObject( self.currentMonth, forKey: "backgroundMonth" )
//                    backgroundImage.image = UIImage(data: data!)
//                    
//                    UIView.animateWithDuration( 1, animations: {
//                        backgroundImage.alpha = 1
//                    })
//                }
//            }
            
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
