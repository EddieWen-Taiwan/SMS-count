//
//  PercentageViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/13.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet var userSticker: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!

    // Detail
    @IBOutlet var passedDaysLabel: UILabel!
    @IBOutlet var finalRetireDateLabel: UILabel!
    @IBOutlet var retireDateBottomConstraint: NSLayoutConstraint!
    @IBOutlet var retireDateView: UIView!
    @IBOutlet var retireDateLabel: UILabel!

    var calculateHelper = CalculateHelper()
    let reachability = Reachability()

    // Download data from Parse in FriendsTableVC
    var downloadFromParse: Bool

    required init?(coder aDecoder: NSCoder) {
        self.downloadFromParse = false

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "repeat-image")!)

        if calculateHelper.settingStatus {

            refreshData()

        } else {
            // switch to settingViewController ?
        }

        showUserInfo()
    }

    func refreshData() {
        passedDaysLabel.text = String( calculateHelper.getPassedDays() )

        if calculateHelper.isRetireDateFixed() {
            finalRetireDateLabel.text = calculateHelper.getFixedRetireDate()
            retireDateBottomConstraint.constant = 60
            retireDateView.hidden = false
            retireDateLabel.text = calculateHelper.getRetireDate()
        } else {
            finalRetireDateLabel.text = calculateHelper.getRetireDate()
            retireDateBottomConstraint.constant = 0
            retireDateView.hidden = true
        }
    }

    func showUserInfo() {
        if let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount") {

            if let fbid = userPreference.stringForKey("fb_id") {
                if reachability.isConnectedToNetwork() {
                    // Download Facebook profile
                    // API url : http://graph.facebook.com/100001967509786/picture?type=large

                    downloadImageWithID(fbid)
                }
            }

            if let username = userPreference.stringForKey("username") {
                usernameLabel.text = username
            }

            if let userStatus = userPreference.stringForKey("status") {
                statusLabel.text = userStatus
            }

        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Check whether user logged in with FB in FriendsTVC
        if downloadFromParse {
            downloadFromParse = false

            // Reinit
            calculateHelper = CalculateHelper()
            if calculateHelper.settingStatus {
                refreshData()
            }

            // Check sticker, name and status
            showUserInfo()
        }
    }

    func downloadImageWithID( fbid: String ) {
        if let url = NSURL(string: "http://graph.facebook.com/\(fbid)/picture?type=large") {
            reachability.getImageFromUrl(url) { (data, response, error) in
                if let data = data {

                    dispatch_async( dispatch_get_main_queue() ) { () -> Void in
                        self.userSticker.image = UIImage(data: data)
                    }

                }
            }
        }
    }

}
