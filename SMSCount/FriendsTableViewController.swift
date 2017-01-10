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
            if FBSDKAccessToken.current() == nil {
                coverTableView("facebook")
            } else {
                let userPreference = UserDefaults(suiteName: "group.EddieWen.SMSCount")!

                if userPreference.bool(forKey: "publicProfile") {
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
        let connection = FBSDKGraphRequestConnection()
        connection.add(friendsRequest, completionHandler: { (connection, result, error) in

            if error == nil {

                do {

                    var friendArray = [String]()
                    let fbResult = try JSONSerialization.jsonObject(with: result as! Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    if let users = fbResult.value(forKey: "data") {
                        for user in users as! [AnyObject] {
                            friendArray.append( user.value(forKey: "id") as! String )
                        }
                    }

                    self.getFriendsInfomation( friendArray )

                } catch {
                    print(error)
                }
            }

        })

        connection.start()
    }

    func getFriendsInfomation( _ friends: [String] ) {
        let friendsDetail = PFQuery(className: "User")
            friendsDetail.whereKey( "fb_id", containedIn: friends )
            friendsDetail.whereKey( "publicProfile", notEqualTo: false )
            friendsDetail.order(byDescending: "updatedAt")
        friendsDetail.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                self.friendsObject = objects!
                self.getData = true
                self.tableView.reloadData()
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if getData {
            if friendsObject.count == 0 {
                coverTableView("no-friends")
                return 0
            } else {
                return friendsObject.count
            }
        } else {
            return Int( (UIScreen.main.bounds.height-44-49)/2/74+1 )
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendsTableViewCell

        if getData {

            let thisUser = friendsObject[(indexPath as NSIndexPath).row]
            // Configure the cell...

            if let userName: String = thisUser.value(forKey: "username") as? String {
                cell.name.text = userName
            }
            cell.status.text = thisUser.value(forKey: "status") as? String ?? ""

            // Sticker
            let fbid = thisUser.value(forKey: "fb_id") as! String
            let url = URL(string: "http://graph.facebook.com/\(fbid)/picture?type=large")!
            reachability.getImageFromUrl(url) { data, response, error in
                if data != nil {
                    DispatchQueue.main.async {
                        cell.sticker.image = UIImage(data: data!)
                    }
                }
            }

            // Calculate this friend's data
            if thisUser.value(forKey: "yearOfEnterDate") != nil && thisUser.value(forKey: "monthOfEnterDate") != nil && thisUser.value(forKey: "dateOfEnterDate") != nil && thisUser.value(forKey: "serviceDays") != nil {

                var entireDate = "\(thisUser.value(forKey: "yearOfEnterDate")!) / "
                if (thisUser.value(forKey: "monthOfEnterDate")! as! Int) < 10 {
                    entireDate += "0"
                }
                entireDate += "\(thisUser.value(forKey: "monthOfEnterDate")!) / "
                if (thisUser.value(forKey: "dateOfEnterDate")! as! Int) < 10 {
                    entireDate += "0"
                }
                entireDate += String(describing: thisUser.value(forKey: "dateOfEnterDate")!)

                if friendHelper.inputFriendData( entireDate, serviceDays: thisUser.value(forKey: "serviceDays") as! Int, discountDays: thisUser.value(forKey: "discountDays") as? Int ?? 0, autoFixed: thisUser.value(forKey: "weekendDischarge") as? Bool ?? false ) {
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
            cell.name.backgroundColor = UIColor.clear
            cell.status.backgroundColor = UIColor.clear

        }

        return cell
    }

    // Add a UIView to cover TableView with something wrong
    func coverTableView( _ situation: String ) {

        let viewWidth = UIScreen.main.bounds.width
        let viewHeight = UIScreen.main.bounds.height-44-49

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
            loadingView = LoadingView( center: CGPoint( x: viewWidth/2, y: viewHeight/2 ) )
            loadingView.isHidden = true

            self.view.addSubview( loadingView )
        }

    }

    fileprivate func makeFBLoginButton( _ vw: CGFloat, vh: CGFloat ) -> FBSDKLoginButton {
        let btn = FBSDKLoginButton()
            btn.frame = CGRect( x: 30, y: vh/2+55, width: vw-60, height: 50 )
            btn.readPermissions = [ "public_profile", "email", "user_friends" ]
            btn.delegate = self

        return btn
    }

    fileprivate func makeRetryButton( _ vw: CGFloat, vh: CGFloat ) -> UIButton {
        let btn = UIButton(frame: CGRect( x: vw/2-35, y: vh/2+70, width: 70, height: 35 ))
            btn.setTitle("重試", for: UIControlState())
            btn.titleLabel?.font = UIFont(name: "PingFangTC-Regular", size: 13)
            btn.layer.cornerRadius = 3
            btn.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
            btn.addTarget(self, action: #selector(retryInternet), for: .touchUpInside)

        return btn
    }

    func retryInternet(_ sender: UIButton) {

        loadingView.isHidden = false
        let indicator = loadingView.subviews.first as! UIActivityIndicatorView
            indicator.startAnimating()

        DispatchQueue.global().async {
            sleep(1)
            DispatchQueue.main.async {
                self.checkEnvironment()
            }
        }

    }

    // *************** \\
    //      FBSDK      \\
    // *************** \\

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {

        if error != nil {
            // Process error
        } else if result.isCancelled {
            // Handle cancellations
        } else {

            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"])
            _ = graphRequest?.start(completionHandler: { (connection, result, error) -> Void in

                if error == nil {
                    UserInfo().storeFacebookInfo( result as AnyObject, syncCompletion: { messageContent, newStatus, newEnterDate, newServiceDays, newDiscountDays, newWeekendFixed, newPublicProfile in

                        // Ask user whether to download data from Parse or not
                        let syncAlertController = UIAlertController(title: "是否將資料同步至APP？", message: messageContent, preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "是", style: .default, handler: { (action) in
                            let userPreference = UserDefaults(suiteName: "group.EddieWen.SMSCount")!
                            // Status
                            if newStatus != "" {
                                userPreference.set( newStatus, forKey: "status")
                            }
                            // EnterDate
                            if newEnterDate != "" {
                                userPreference.set( newEnterDate, forKey: "enterDate")
                            }
                            // ServiceDays
                            if newServiceDays != -1 {
                                userPreference.set( newServiceDays, forKey: "serviceDays")
                            }
                            // DiscountDays
                            if newDiscountDays != -1 {
                                userPreference.set( newDiscountDays, forKey: "discountDays")
                            }
                            userPreference.set( newWeekendFixed, forKey: "autoWeekendFixed" )
                            userPreference.set( newPublicProfile, forKey: "publicProfile" )

                            if newPublicProfile {
                                // Remove coverView and Reload TableView
                                self.removeOldViews()
                                self.requestFriendsListFromFacebook()
                            } else {
                                self.coverTableView("public")
                            }

                            let NC = self.parent as! NavigationController
                            NC.markDownload()
                        })
                        let noAction = UIAlertAction(title: "否", style: .cancel, handler: { (action) in
                            // UserInfo().uploadAllData()

                            // Remove coverView and Reload TableView
                            self.removeOldViews()
                            self.requestFriendsListFromFacebook()
                        })
                        syncAlertController.addAction(yesAction)
                        syncAlertController.addAction(noAction)

                        self.present(syncAlertController, animated: true, completion: nil)

                    }, newUserTask: {
                        self.removeOldViews()
                        self.requestFriendsListFromFacebook()
                    })
                }

            })

        }

    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
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
