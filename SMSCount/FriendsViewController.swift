//
//  FriendsViewController.swift
//  SMSCount
//
//  Created by Eddie on 12/3/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Request for friendKist
        let friendsRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields": "id"])
        friendsRequest.startWithCompletionHandler { (connection, result, error) -> Void in
            
            if error != nil {
                print("ERROR -------")
                print(error)
            } else {
                print("Friends list -------")
//                print(result)
                if let users = result.valueForKey("data") {
                    for user in users as! [AnyObject] {
                        print( user.valueForKey("id") )
                    }
                }
            }
            
        }
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
