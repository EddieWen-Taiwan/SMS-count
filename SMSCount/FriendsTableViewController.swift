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
import FirebaseCore
import FirebaseDatabase

class FriendsTableViewController: UITableViewController, FBSDKLoginButtonDelegate {

    var friendsObject = [FIRDataSnapshot]()
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

                var friendIdArray = [String]()

                if let json = result as? [String: Any] {
                    if let friendArray = json["data"] as? Array<Any> {
                        for case let friend as [String: String] in friendArray {
                            if let fId = friend["id"] {
                                friendIdArray.append(fId)
                            }
                        }
                    }
                }
                
                self.getFriendsInfomation(friendIdArray)
            }

        })

        connection.start()
    }

    func getFriendsInfomation( _ idArray: [String] ) {

        let ref = FIRDatabase.database().reference()

        for id in idArray {
            ref.child("User/\(id)").observeSingleEvent(of: .value, with: { (snapshot) in

                /**
                 * this user id is not existed in Firebase
                 */
                guard snapshot.exists() else {
                    return
                }

                self.friendsObject.append(snapshot)
                self.getData = true
                self.tableView.reloadData()

            })
        }
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
            }

            return friendsObject.count
        }

        return Int( (UIScreen.main.bounds.height-44-49)/2/74+1 )
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendsTableViewCell

        if getData {

            let userSnapshot = friendsObject[(indexPath as NSIndexPath).row].value as! Dictionary<String, AnyObject>
            // Configure the cell...

            cell.name.text = userSnapshot["name"] as? String
            cell.name.backgroundColor = UIColor.clear

            cell.status.text = userSnapshot["status"] as? String
            cell.status.backgroundColor = UIColor.clear

            // User Facebook Sticker
            if let fbid = userSnapshot["fbId"] {
                let url = URL(string: "http://graph.facebook.com/\(fbid)/picture?type=large")!
                reachability.getImageFromUrl(url) { data, response, error in
                    if data != nil {
                        DispatchQueue.main.async {
                            cell.sticker.image = UIImage(data: data!)
                        }
                    }
                }
            }

            /**
             * Calculate this friend's data
             */
            guard let year = userSnapshot["year"] else {
                return cell
            }
            guard let month = userSnapshot["month"] else {
                return cell
            }
            guard let date = userSnapshot["date"] else {
                return cell
            }
            guard let serviceIndex = userSnapshot["serviceDaysIndex"] as? Int else {
                return cell
            }

            var entireDate = "\(year) / "

            if (month as! Int) < 10 {
                entireDate += "0"
            }
            entireDate += "\(month) / "

            if (date as! Int) < 10 {
                entireDate += "0"
            }
            entireDate += "\(date)"

            if friendHelper.inputFriendData( entireDate, serviceDays: serviceIndex, discountDays: userSnapshot["discountDays"] as? Int ?? 0, autoFixed: userSnapshot["isWeekendDischarge"] as? Bool ?? false ) {
                if friendHelper.getRemainedDays() >= 0 {
                    cell.preTextLabel.text = "剩餘"
                    cell.dayNumber.text = String( friendHelper.getRemainedDays() )
                } else {
                    cell.preTextLabel.text = "自由"
                    cell.dayNumber.text = String( friendHelper.getRemainedDays()*(-1) )
                }
            }

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

                if error != nil {
                    print("Error : \(error)")
                    return
                }

                guard let result = result as? Dictionary<String, String> else {
                    return
                }

                if let newFbId = result["id"] {
                    let userInfo = UserInfo()
                    userInfo.addUserFBID(newFbId)

                    if let mail = result["email"] {
                        userInfo.updateMail(mail)
                    }
                    if let name = result["name"] {
                        userInfo.updateUsername(name)
                    }
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
