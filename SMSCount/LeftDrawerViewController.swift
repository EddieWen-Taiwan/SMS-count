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

    let mainStoryborad = UIStoryboard(name: "Main", bundle: nil)
    let settingStoryboard = UIStoryboard(name: "Setting", bundle: nil)

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet var countRow: UIView!
    @IBOutlet var settingRow: UIView!

    convenience init() {
        self.init(nibName: "LeftDrawer", bundle: nil)
    }
    
    @IBAction func goMainTabBarController(sender: AnyObject) {
        let rootViewController = mainStoryborad.instantiateViewControllerWithIdentifier("TabBarController")

        switchRowBackground(0)
        switchRootViewController(rootViewController)
    }

    @IBAction func goSettingViewController(sender: AnyObject) {
        let rootViewController = settingStoryboard.instantiateViewControllerWithIdentifier("NavigationOfSettingVC")

        switchRowBackground(1)
        switchRootViewController(rootViewController)
    }

    func switchRootViewController( rootViewController: UIViewController ) {

        appDelegate.drawerController.centerViewController = rootViewController
        appDelegate.drawerController.toggleDrawerSide( DrawerSide.Left, animated: true, completion: nil)

    }

    func switchRowBackground( row: Int ) {

        if row == 0 {
            countRow.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
            settingRow.backgroundColor = UIColor.clearColor()
        } else {
            countRow.backgroundColor = UIColor.clearColor()
            settingRow.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        }

    }

}
