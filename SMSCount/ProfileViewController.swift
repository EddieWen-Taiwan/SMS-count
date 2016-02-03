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
    var stickerIsDownloaded: Bool
    @IBOutlet var usernameLabel: UILabel!

    var calculateHelper = CalculateHelper()
    let reachability = Reachability()

    let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!
    let screenHeight = UIScreen.mainScreen().bounds.height

    var downloadFromParse: Bool

    required init?(coder aDecoder: NSCoder) {
        self.stickerIsDownloaded = false
        self.downloadFromParse = false

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "repeat-image")!)

        if calculateHelper.isSettingAllDone() {

            self.refreshData()

        } else {
            // switch to settingViewController ?
        }

        self.showUserInfo()
    }

    func refreshData() {
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
    }

    func showUserInfo() {
        if let fbid = self.userPreference.stringForKey("fb_id") {
            if !self.stickerIsDownloaded && reachability.isConnectedToNetwork() {
                // Download Facebook profile
                // API url : http://graph.facebook.com/100001967509786/picture?type=large

                self.downloadImage( NSURL(string: "http://graph.facebook.com/\(fbid)/picture?type=large")! )
            }
        }

        if let username = self.userPreference.stringForKey("username") {
            self.usernameLabel.text = username
        }

        if let userStatus = self.userPreference.stringForKey("status") {
            self.statusLabel.text = userStatus
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Check whether user logged in with FB in FriendsTVC
        if self.downloadFromParse {
            self.downloadFromParse = false

            // Reinit
            calculateHelper = CalculateHelper()
            if calculateHelper.isSettingAllDone() {
                self.refreshData()
            }

            // Check sticker, name and status
            self.showUserInfo()
        }
    }

    func downloadImage( url: NSURL ) {
        reachability.getImageFromUrl(url) { (data, response, error) in

            if data != nil {

                dispatch_async( dispatch_get_main_queue() ) { () -> Void in
                    self.userSticker.image = UIImage(data: data!)
                }
                self.stickerIsDownloaded = true

            }

        }
    }

}
