//
//  NavigationController.swift
//  SMSCount
//
//  Created by Eddie on 12/4/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.navigationBar.barTintColor = UIColor.redColor()

        let drawerItem = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: "test")
        self.childViewControllers.first?.navigationItem.setLeftBarButtonItem( drawerItem, animated: true )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func test() {
        print("OOOO")
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
