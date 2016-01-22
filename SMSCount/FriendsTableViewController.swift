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

    var friendsObject: [PFObject] = []
    var getData: Bool = false

    var loadingView = LoadingView()

    let friendHelper = FriendsCalculate()
    let reachability = Reachability()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        tableView.allowsSelection = false

        self.checkEnvironment()
    }

    func checkEnvironment() {

        if Reachability().isConnectedToNetwork() {
            // If there is coverView
            self.removeCoverView()

            // Request for friendList
            if FBSDKAccessToken.currentAccessToken() == nil {
                self.coverTableView("facebook")
            } else {
                let userDefault = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!

                if userDefault.boolForKey("publicProfile") {
                    self.requestFriendsList()
                } else {
                    self.coverTableView("public")
                }
            }
        } else {
            // without Internet
            self.coverTableView("internet")
        }

    }

    // Request user friends list from Facebook and reload TableView
    func requestFriendsList() {
        let friendsRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields": "id"])
        friendsRequest.startWithCompletionHandler { (connection, result, error) -> Void in

            if error == nil {
                var friendArray: [String] = []
                if let users = result.valueForKey("data") {
                    for user in users as! [AnyObject] {
                        friendArray.append( user.valueForKey("id") as! String )
                    }
                }
                let friendsDetail = PFQuery(className: "User")
                friendsDetail.whereKey( "fb_id", containedIn: friendArray )
                friendsDetail.whereKey( "publicProfile", notEqualTo: false )
                friendsDetail.orderByDescending("updatedAt")
                friendsDetail.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                    if error == nil {
                        self.friendsObject = objects!
                        self.getData = true
                        self.tableView.reloadData()
                    }
                })
            }

        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.getData {
            if self.friendsObject.count == 0 {
                self.coverTableView("no-friends")
            }
            return self.friendsObject.count
        } else {
            return Int( (UIScreen.mainScreen().bounds.height-44-49)/2/74+1 )
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendsTableViewCell

        if self.getData {

            let thisUser = self.friendsObject[indexPath.row]
            // Configure the cell...

            if let userName: String = thisUser.valueForKey("username") as? String {
                cell.name.text = userName
            }
            if let userStatus: String = thisUser.valueForKey("status") as? String {
                cell.status.text = userStatus
            }
            // Sticker
            let fbid = thisUser.valueForKey("fb_id") as! String
            let url = NSURL(string: "http://graph.facebook.com/\(fbid)/picture?type=large")!
            self.reachability.getImageFromUrl(url) { (data, response, error) in
                if data != nil {
                    dispatch_async( dispatch_get_main_queue(), {
                        cell.sticker.image = UIImage(data: data!)
                    })
                }
            }

            if thisUser.valueForKey("yearOfEnterDate") != nil && thisUser.valueForKey("monthOfEnterDate") != nil && thisUser.valueForKey("dateOfEnterDate") != nil && thisUser.valueForKey("serviceDays") != nil {

                var entireDate = "\(thisUser.valueForKey("yearOfEnterDate")!) / "
                if (thisUser.valueForKey("monthOfEnterDate")! as! Int) < 10 {
                    entireDate += "0"
                }
                entireDate += String(thisUser.valueForKey("monthOfEnterDate")!) + " / "
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

        let viewWidth = self.view.frame.width
        let viewHeight = self.view.frame.height-44-49

        let coverView = UIView(frame: CGRectMake(0, 0, viewWidth, viewHeight))
            coverView.backgroundColor = UIColor.whiteColor()

        let iconView = UIImageView(frame: CGRectMake(viewWidth/2-24, viewHeight/2-50, 48, 48))
            iconView.image = {
                switch situation {
                    case "facebook":
                        return UIImage(named: "person-pin")!
                    case "public":
                        return UIImage(named: "setting-pin")!
                    case "no-friends":
                        return UIImage()
                    default:
                        return UIImage(named: "internet-pin")!
                }
            }()
        coverView.addSubview(iconView)

        let positionY = situation == "no-friends" ? viewHeight/2+15 : viewHeight/2
        let titleLabel = UILabel(frame: CGRectMake(0, positionY, viewWidth, 30))
            titleLabel.text = {
                switch situation {
                    case "facebook":
                        return "尚未登入臉書帳號"
                    case "public":
                        return "查看好友列表需公開使用者"
                    case "no-friends":
                        return "沒有其他好友使用"
                    default:
                        return "目前沒有網路連線"
                }
            }()
            titleLabel.font = UIFont(name: "PingFangTC-Regular", size: 15)
            titleLabel.textColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.38)
            titleLabel.textAlignment = NSTextAlignment.Center
        coverView.addSubview(titleLabel)

        // Button under title
        if situation == "facebook" {
            let loginView = FBSDKLoginButton()
                loginView.frame = CGRectMake( 30, viewHeight/2+55, viewWidth-60, 50 )
                loginView.readPermissions = [ "public_profile", "email", "user_friends" ]
                loginView.delegate = self
            coverView.addSubview(loginView)
        } else if situation == "internet" {
            let retryButton = UIButton(frame: CGRectMake( viewWidth/2-35, viewHeight/2+70, 70, 35 ))
                retryButton.setTitle("重試", forState: .Normal)
                retryButton.titleLabel?.font = UIFont(name: "PingFangTC-Regular", size: 13)
                retryButton.layer.cornerRadius = 3
                retryButton.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
                retryButton.addTarget(self, action: "retryInternet:", forControlEvents: .TouchUpInside)
            coverView.addSubview(retryButton)
        }

        coverView.tag = 7

        self.view.addSubview(coverView)

        if situation == "internet" {
            // Loading
            self.loadingView = LoadingView( center: CGPointMake( viewWidth/2, viewHeight/2 ) )
            self.loadingView.hidden = true

            self.view.addSubview( self.loadingView )
        }
    }

    func retryInternet(sender: UIButton) {

        self.loadingView.hidden = false
        let indicator = self.loadingView.subviews.first as! UIActivityIndicatorView
            indicator.startAnimating()

        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async( dispatch_get_global_queue(priority, 0) ) {
            sleep(1)
            dispatch_async( dispatch_get_main_queue() ) {
                self.loadingView.hidden = true
                indicator.stopAnimating()
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
                    UserInfo().storeFacebookInfo( result, completion: { (messageContent, newStatus, newEnterDate, newServiceDays, newDiscountDays, newWeekendFixed, newPublicProfile) -> Void in

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
                                self.removeCoverView()
                                self.requestFriendsList()
                            } else {
                                self.coverTableView("public")
                            }

                            let NC = self.parentViewController as! NavigationController
                            NC.markDownload()
                        })
                        let noAction = UIAlertAction(title: "否", style: .Cancel, handler: { (action) in
                            UserInfo().uploadAllData()

                            // Remove coverView and Reload TableView
                            self.removeCoverView()
                            self.requestFriendsList()
                        })
                        syncAlertController.addAction(yesAction)
                        syncAlertController.addAction(noAction)

                        self.presentViewController(syncAlertController, animated: true, completion: nil)

                    })
                }

            })

        }

    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }

    func removeCoverView() {
        self.view.subviews.forEach({
            if $0.tag == 7 {
                $0.removeFromSuperview()
            }
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
