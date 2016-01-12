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

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FBSDKLoginButtonDelegate {

    @IBOutlet var tableView: UITableView!
    var friendsObject: [PFObject] = []
    var getData: Bool = false

    let friendHelper = FriendsCalculate()
    let reachability = Reachability()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false

        if Reachability().isConnectedToNetwork() {
            // Request for friendList
            if FBSDKAccessToken.currentAccessToken() == nil {
                self.coverTableView("facebook")
            } else {
                self.requestFriendsList()
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

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.getData ? self.friendsObject.count : Int( self.tableView.bounds.height / 74 )
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendsTableViewCell

        if getData {

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

                if friendHelper.inputFriendData( entireDate, serviceDays: thisUser.valueForKey("serviceDays") as! Int, discountDays: thisUser.valueForKey("discountDays") as! Int, autoFixed: false ) {
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
    func coverTableView(situation: String = "") {

        let coverView = UIView(frame: self.view.frame)
            coverView.backgroundColor = UIColor.whiteColor()

        let iconView = UIImageView(frame: CGRectMake(self.view.frame.width/2-24, self.view.frame.height/2-70, 48, 48))
            iconView.image = UIImage(named: situation == "facebook" ? "person-pin" : "no-internet")
        coverView.addSubview(iconView)

        let titleLabel = UILabel(frame: CGRectMake(0, self.view.frame.height/2-20, self.view.frame.width, 30))
            titleLabel.text = situation == "facebook" ? "請先登入Facebook" : "目前沒有網路連線"
            titleLabel.font = UIFont(name: "PingFangTC", size: 15.0)
            titleLabel.textColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.38)
            titleLabel.textAlignment = NSTextAlignment.Center
        coverView.addSubview(titleLabel)

        if situation == "facebook" {
            let loginView = FBSDKLoginButton()
                loginView.frame = CGRectMake( 30, self.view.frame.height/2+30, self.view.frame.width-60, 50 )
                loginView.readPermissions = [ "public_profile", "email", "user_friends" ]
                loginView.delegate = self
            coverView.addSubview(loginView)
        }

        coverView.tag = 7

        self.view.addSubview(coverView)

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
                    // Remove coverView and reload tableView\
                    self.view.subviews.forEach({
                        if $0.tag == 7 {
                            $0.removeFromSuperview()
                        }
                    })

                    // And reload tableView
                    self.requestFriendsList()

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
                            userPreference.setBool( true, forKey: "downloadFromParse" )
                        })
                        let noAction = UIAlertAction(title: "否", style: .Cancel, handler: { (action) in
                            UserInfo().uploadAllData()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
