//
//  FriendsViewController.swift
//  SMSCount
//
//  Created by Eddie on 12/3/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import UIKit
import Parse
import FBSDKLoginKit

class FriendsTableViewController: UITableViewController, FBSDKLoginButtonDelegate {

    var friendsObject = [PFObject]()
    var getData: Bool

    var loadingView = LoadingView()

    let friendHelper = FriendsCalculate()
    let reachability = Reachability()

    required init?(coder aDecoder: NSCoder) {
        self.getData = false

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        tableView.allowsSelection = false

        checkEnvironment()
    }

    // Make sure all everything required is okay, or add coverView
    func checkEnvironment() {

        // If there is coverView
        removeOldViews()

        if Reachability().isConnectedToNetwork() {
            // Request for friendList
            if FBSDKAccessToken.currentAccessToken() == nil {
                coverTableView("facebook")
            } else {
                let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!

                if userPreference.boolForKey("publicProfile") {
                    requestFriendsListFromFacebook()
                } else {
                    coverTableView("public")
                }
            }
        } else {
            // without Internet
            coverTableView("internet")
        }

    }

    // Request user friends list from Facebook and reload TableView
    func requestFriendsListFromFacebook() {
        let friendsRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields": "id"])
        friendsRequest.startWithCompletionHandler { connection, result, error in

            if error == nil {
                var friendArray = [String]()
                if let users = result.valueForKey("data") {
                    for user in users as! [AnyObject] {
                        friendArray.append( user.valueForKey("id") as! String )
                    }
                }
                self.getFriendsInfomation( friendArray )
            }

        }
    }

    func getFriendsInfomation( friends: [String] ) {
        let friendsDetail = PFQuery(className: "User")
            friendsDetail.whereKey( "fb_id", containedIn: friends )
            friendsDetail.whereKey( "publicProfile", notEqualTo: false )
            friendsDetail.orderByDescending("updatedAt")
        friendsDetail.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                self.friendsObject = objects!
                self.getData = true
                self.tableView.reloadData()
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if getData {
            if friendsObject.count == 0 {
                coverTableView("no-friends")
                return 0
            } else {
                return friendsObject.count
            }
        } else {
            return Int( (UIScreen.mainScreen().bounds.height-44-49)/2/74+1 )
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendsTableViewCell

        if getData {

            let thisUser = friendsObject[indexPath.row]
            // Configure the cell...

            if let userName: String = thisUser.valueForKey("username") as? String {
                cell.name.text = userName
            }
            cell.status.text = thisUser.valueForKey("status") as? String ?? ""

            // Sticker
            let fbid = thisUser.valueForKey("fb_id") as! String
            let url = NSURL(string: "http://graph.facebook.com/\(fbid)/picture?type=large")!
            reachability.getImageFromUrl(url) { data, response, error in
                if data != nil {
                    dispatch_async( dispatch_get_main_queue() ) {
                        cell.sticker.image = UIImage(data: data!)
                    }
                }
            }

            // Calculate this friend's data
            if thisUser.valueForKey("yearOfEnterDate") != nil && thisUser.valueForKey("monthOfEnterDate") != nil && thisUser.valueForKey("dateOfEnterDate") != nil && thisUser.valueForKey("serviceDays") != nil {

                var entireDate = "\(thisUser.valueForKey("yearOfEnterDate")!) / "
                if (thisUser.valueForKey("monthOfEnterDate")! as! Int) < 10 {
                    entireDate += "0"
                }
                entireDate += "\(thisUser.valueForKey("monthOfEnterDate")!) / "
                if (thisUser.valueForKey("dateOfEnterDate")! as! Int) < 10 {
                    entireDate += "0"
                }
                entireDate += String(thisUser.valueForKey("dateOfEnterDate")!)

                if friendHelper.inputFriendData( entireDate, serviceDays: thisUser.valueForKey("serviceDays") as! Int, discountDays: thisUser.valueForKey("discountDays") as? Int ?? 0, autoFixed: thisUser.valueForKey("weekendDischarge") as? Bool ?? false ) {
                    if friendHelper.getRemainedDays() >= 0 {
                        cell.preTextLabel.text = "剩餘"
                        cell.dayNumber.text = String( friendHelper.getRemainedDays() )
                    } else {
                        cell.preTextLabel.text = "自由"
                        cell.dayNumber.text = String( friendHelper.getRemainedDays()*(-1) )
                    }
                }

            }

            // Clean default background-color
            cell.name.backgroundColor = UIColor.clearColor()
            cell.status.backgroundColor = UIColor.clearColor()

        }

        return cell
    }

    // Add a UIView to cover TableView with something wrong
    func coverTableView( situation: String ) {

        let viewWidth = UIScreen.mainScreen().bounds.width
        let viewHeight = UIScreen.mainScreen().bounds.height-44-49

        let coverView = CoverView(width: viewWidth, height: viewHeight, status: situation)

        // Button under title
        if situation == "facebook" {
            let loginView = makeFBLoginButton( viewWidth, vh: viewHeight )
            coverView.addSubview(loginView)
        } else if situation == "internet" {
            let retryButton = makeRetryButton( viewWidth, vh: viewHeight )
            coverView.addSubview(retryButton)
        }

        self.view.addSubview(coverView)

        if situation == "internet" {
            // Loading
            loadingView = LoadingView( center: CGPointMake( viewWidth/2, viewHeight/2 ) )
            loadingView.hidden = true

            self.view.addSubview( loadingView )
        }

    }

    private func makeFBLoginButton( vw: CGFloat, vh: CGFloat ) -> FBSDKLoginButton {
        let btn = FBSDKLoginButton()
            btn.frame = CGRectMake( 30, vh/2+55, vw-60, 50 )
            btn.readPermissions = [ "public_profile", "email", "user_friends" ]
            btn.delegate = self

        return btn
    }

    private func makeRetryButton( vw: CGFloat, vh: CGFloat ) -> UIButton {
        let btn = UIButton(frame: CGRectMake( vw/2-35, vh/2+70, 70, 35 ))
            btn.setTitle("重試", forState: .Normal)
            btn.titleLabel?.font = UIFont(name: "PingFangTC-Regular", size: 13)
            btn.layer.cornerRadius = 3
            btn.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
            btn.addTarget(self, action: #selector(retryInternet), forControlEvents: .TouchUpInside)

        return btn
    }

    func retryInternet(sender: UIButton) {

        loadingView.hidden = false
        let indicator = loadingView.subviews.first as! UIActivityIndicatorView
            indicator.startAnimating()

        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async( dispatch_get_global_queue(priority, 0) ) {
            sleep(1)
            dispatch_async( dispatch_get_main_queue() ) {
                self.checkEnvironment()
            }
        }

    }

    // *************** \\
    //      FBSDK      \\
    // *************** \\

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {

        if error != nil {
            // Process error
        } else if result.isCancelled {
            // Handle cancellations
        } else {

            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in

                if error == nil {
                    UserInfo().storeFacebookInfo( result, syncCompletion: { messageContent, newStatus, newEnterDate, newServiceDays, newDiscountDays, newWeekendFixed, newPublicProfile in

                        // Ask user whether to download data from Parse or not
                        let syncAlertController = UIAlertController(title: "是否將資料同步至APP？", message: messageContent, preferredStyle: .Alert)
                        let yesAction = UIAlertAction(title: "是", style: .Default, handler: { (action) in
                            let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!
                            // Status
                            if newStatus != "" {
                                userPreference.setObject( newStatus, forKey: "status")
                            }
                            // EnterDate
                            if newEnterDate != "" {
                                userPreference.setObject( newEnterDate, forKey: "enterDate")
                            }
                            // ServiceDays
                            if newServiceDays != -1 {
                                userPreference.setInteger( newServiceDays, forKey: "serviceDays")
                            }
                            // DiscountDays
                            if newDiscountDays != -1 {
                                userPreference.setInteger( newDiscountDays, forKey: "discountDays")
                            }
                            userPreference.setBool( newWeekendFixed, forKey: "autoWeekendFixed" )
                            userPreference.setBool( newPublicProfile, forKey: "publicProfile" )

                            if newPublicProfile {
                                // Remove coverView and Reload TableView
                                self.removeOldViews()
                                self.requestFriendsListFromFacebook()
                            } else {
                                self.coverTableView("public")
                            }

                            let NC = self.parentViewController as! NavigationController
                            NC.markDownload()
                        })
                        let noAction = UIAlertAction(title: "否", style: .Cancel, handler: { (action) in
                            UserInfo().uploadAllData()

                            // Remove coverView and Reload TableView
                            self.removeOldViews()
                            self.requestFriendsListFromFacebook()
                        })
                        syncAlertController.addAction(yesAction)
                        syncAlertController.addAction(noAction)

                        self.presentViewController(syncAlertController, animated: true, completion: nil)

                    }, newUserTask: {
                        self.removeOldViews()
                        self.requestFriendsListFromFacebook()
                    })
                }

            })

        }

    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }

    func removeOldViews() {
        self.view.subviews.forEach({
            if $0 is CoverView || $0 is LoadingView {
                $0.removeFromSuperview()
            }
        })
    }

}
