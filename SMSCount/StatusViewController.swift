//
//  StatusViewController.swift
//  SMSCount
//
//  Created by Eddie on 11/4/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import UIKit

class StatusViewController: UIViewController {

    @IBOutlet var statusTextField: UITextField!
    let userPreference = NSUserDefaults( suiteName: "group.EddieWen.SMSCount" )!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let userStatus = self.userPreference.stringForKey("status") {
            self.statusTextField.text = userStatus
        }
    }

    @IBAction func saveTextFieldStatus(sender: AnyObject) {

        if self.statusTextField.text != "" {
            let userStatus = self.statusTextField.text

            self.userPreference.setObject( userStatus , forKey: "status" )

        } else {
            print("n")
        }
        // After saving
//        self.dismissViewControllerAnimated(true, completion: nil )
    }

    @IBAction func dismissViewController(sender: AnyObject) {
        self.dismissViewControllerAnimated( true, completion: nil )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }

}
