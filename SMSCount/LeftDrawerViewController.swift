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

    var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet var countRow: UIView!
    @IBOutlet var settingRow: UIView!
    @IBOutlet var teamRow: UIView!

    init() {
        super.init(nibName: "LeftDrawer", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func goMainTabBarController(sender: AnyObject) {
        let rootViewController = self.mainStoryborad.instantiateViewControllerWithIdentifier("TabBarController")

        self.switchRowBackground(0)
        self.switchRootViewController(rootViewController)
    }

    @IBAction func goSettingViewController(sender: AnyObject) {
        let rootViewController = self.settingStoryboard.instantiateViewControllerWithIdentifier("NavigationOfSettingVC")

        self.switchRowBackground(1)
        self.switchRootViewController(rootViewController)
    }

    @IBAction func goTeamViewController(sender: AnyObject) {

        self.switchRowBackground(2)
    }

    func switchRootViewController( rootViewController: UIViewController ) {

        self.appDelegate.drawerController.centerViewController = rootViewController
        self.appDelegate.drawerController.toggleDrawerSide( DrawerSide.Left, animated: true, completion: { (success: Bool) -> Void in
//            print(success)
        })

    }

    func switchRowBackground( row: Int ) {

        self.countRow.backgroundColor = UIColor.clearColor()
        self.settingRow.backgroundColor = UIColor.clearColor()
        self.teamRow.backgroundColor = UIColor.clearColor()

        switch row {
            case 0:
                self.countRow.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
            case 1:
                self.settingRow.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
            case 2:
                self.teamRow.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
            default:
                break
        }
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
