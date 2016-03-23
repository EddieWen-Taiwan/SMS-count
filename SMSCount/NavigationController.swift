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
        navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        navigationBar.layer.shadowOpacity = 0.4

        // Set style of NavigationBar
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        // Add LeftBarItem and title
        let drawerItem = UIBarButtonItem(image: UIImage(named: "DrawerList"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(toggleDrawer))
        let childVC = self.childViewControllers.first!
        childVC.navigationItem.setLeftBarButtonItem( drawerItem, animated: true )

    }

    // Switch drawer Open / Close
    func toggleDrawer() {
        appDelegate.drawerController.toggleLeftDrawerSideAnimated( true, completion: nil )
    }

    func markDownload() {
        if let countVC = tabBarController?.viewControllers![0].childViewControllers.first! as? CountViewController {
            countVC.downloadFromParse = true
        }

        if let profileVC = tabBarController?.viewControllers![1].childViewControllers.first! as? ProfileViewController {
            profileVC.downloadFromParse = true
        }
    }

}
