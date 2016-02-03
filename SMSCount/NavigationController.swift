//
//  NavigationController.swift
//  SMSCount
//
//  Created by Eddie on 12/4/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import UIKit
import DrawerController

class NavigationController: UINavigationController {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Add shadow to navigation bar
        self.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.navigationBar.layer.shadowOpacity = 0.4

        // Set style of NavigationBar
        self.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        // Add LeftBarItem and title
        let drawerItem = UIBarButtonItem(image: UIImage(named: "DrawerList"), style: UIBarButtonItemStyle.Done, target: self, action: "toggleDrawer")
        let childVC = self.childViewControllers.first!
        childVC.navigationItem.setLeftBarButtonItem( drawerItem, animated: true )

    }

    // Switch drawer Open / Close
    func toggleDrawer() {
        self.appDelegate.drawerController.toggleLeftDrawerSideAnimated( true, completion: nil )
    }

    func markDownload() {
        let countVC = self.tabBarController?.viewControllers![0].childViewControllers.first! as! CountViewController
        countVC.downloadFromParse = true
        let profileVC = self.tabBarController?.viewControllers![1].childViewControllers.first! as! ProfileViewController
        profileVC.downloadFromParse = true
    }

}
