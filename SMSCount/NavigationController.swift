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

        // Remove bottom border of navigation bar
        self.navigationBar.setBackgroundImage( UIImage(named: "standard-color"), forBarMetrics: .Default )
        self.navigationBar.shadowImage = UIImage()

        // Add shadow to navigation bar
        self.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.navigationBar.layer.shadowOpacity = 0.4

        // Set style of NavigationBar
        self.navigationBar.barTintColor = UIColor(red: 255/255, green: 206/255, blue: 84/255, alpha: 1)
        self.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        // Add LeftBarItem and title
        let drawerItem = UIBarButtonItem(image: UIImage(named: "DrawerList"), style: UIBarButtonItemStyle.Done, target: self, action: "toggleDrawer")
        let childVC = self.childViewControllers.first!
        childVC.navigationItem.setLeftBarButtonItem( drawerItem, animated: true )
    }

    func toggleDrawer() {
        self.appDelegate.drawerController.toggleLeftDrawerSideAnimated( true, completion: nil )
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
