//
//  PercentageViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/13.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet var statusLabel: UILabel!

    // Detail
    @IBOutlet var passedDaysLabel: UILabel!
    @IBOutlet var finalRetireDateLabel: UILabel!
    @IBOutlet var retireDateBottomConstraint: NSLayoutConstraint!
    @IBOutlet var retireDateView: UIView!
    @IBOutlet var retireDateLabel: UILabel!

    @IBOutlet var userSticker: UIImageView!
    var stickerIsDownloaded: Bool = false
    @IBOutlet var usernameLabel: UILabel!

    let calculateHelper = CalculateHelper()
    let reachability = Reachability()

    let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!
    let screenHeight = UIScreen.mainScreen().bounds.height

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

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
                // API url : http://graph.facebook.com/100001967509786/picture?type=large

                self.downloadImage( NSURL(string: "http://graph.facebook.com/\(fbid)/picture?type=large")! )
            }
        }

        // If user can't log out ....
        if let username = self.userPreference.stringForKey("username") {
            self.usernameLabel.text = username
        }

        if let userStatus = self.userPreference.stringForKey("status") {
            self.statusLabel.text = userStatus
        }
    }

    func downloadImage( url: NSURL ) {
        reachability.getImageFromUrl(url) { (data, response, error) in

            if data == nil {
                // Have to do nothing
            } else {
                dispatch_async( dispatch_get_main_queue() ) { () -> Void in
                    self.userSticker.image = UIImage(data: data!)
                }
                self.stickerIsDownloaded = true
            }

        }
    }

}
