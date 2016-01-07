//
//  FriendsViewController.swift
//  SMSCount
//
//  Created by Eddie on 12/3/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import UIKit
import Parse

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    var friendsObject: [PFObject] = []
    var getData: Bool = false

    let friendHelper = FriendsCalculate()
    let reachability = Reachability()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.coverTableView()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false

        if Reachability().isConnectedToNetwork() {
            // Request for friendList
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
                    friendsDetail.orderByDescending("updatedAt")
                    friendsDetail.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                        if error == nil {
//                            print(objects)
                            self.friendsObject = objects!
                            self.getData = true
                            self.tableView.reloadData()
                        }
                    })
                }

            }
        } else {
            // without Internet
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
                    cell.dayNumber.text = String( friendHelper.getRemainedDays() )
                }

            }

            // Clean default background-color
            cell.name.backgroundColor = UIColor.clearColor()
            cell.status.backgroundColor = UIColor.clearColor()

        }

        return cell
    }

    func coverTableView(situation: String = "") {

        let coverView = UIView(frame: self.view.frame)
        coverView.backgroundColor = UIColor.whiteColor()

        let iconView = UIImageView(frame: CGRectMake(self.view.frame.width/2-24, self.view.frame.height/2-50, 48, 48))
        iconView.image = UIImage(named: "person-pin")
        coverView.addSubview(iconView)

        let titleLabel = UILabel(frame: CGRectMake(0, self.view.frame.height/2, self.view.frame.width, 30))
        titleLabel.text = "請先登入Facebook"
        titleLabel.font = UIFont(name: "PingFangTC", size: 16.0)
        titleLabel.textColor = UIColor(red: 158/255, green: 158/255, blue: 158/255, alpha: 1)
        titleLabel.textAlignment = NSTextAlignment.Center
        coverView.addSubview(titleLabel)

        self.view.addSubview(coverView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
