//
//  LeftDrawerViewController.swift
//  SMSCount
//
//  Created by Eddie on 11/29/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import UIKit
import DrawerController

class LeftDrawerViewController: UIViewController {

    var storyborad: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goMainTabBarController(sender: AnyObject) {
        let rootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController")

        self.switchRootViewController(rootViewController!)
    }

    @IBAction func goFriendListController(sender: AnyObject) {
        let rootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("FriendListController")

        self.switchRootViewController(rootViewController!)
    }

    func switchRootViewController( rootViewController: UIViewController ) {

        self.appDelegate.drawerController.centerViewController = rootViewController
        self.appDelegate.drawerController.toggleDrawerSide( DrawerSide.Left, animated: true, completion: { (success: Bool) -> Void in
            print(success)
            print("Done")
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
