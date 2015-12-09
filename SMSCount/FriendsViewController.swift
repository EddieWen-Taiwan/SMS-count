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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        tableView.delegate = self
        tableView.dataSource = self

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
                    friendsDetail.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                        if error == nil {
                            print(objects)
                            self.friendsObject = objects!
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
        return self.friendsObject.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendsTableViewCell
        
//        let thisUser = self.userObject[indexPath.row]
//        // Configure the cell...
//        
//        if let userName: String = thisUser.valueForKey("username") as? String {
//            cell.userName.text = userName
//        } else {
//            cell.userName.text = ""
//        }
//        
//        cell.userStatus.text = thisUser.valueForKey("status") as? String
        
        return cell
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
