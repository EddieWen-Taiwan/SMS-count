//
//  StatusViewController.swift
//  SMSCount
//
//  Created by Eddie on 11/4/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import UIKit

class StatusViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var statusTextField: UITextField!
    let userPreference = NSUserDefaults( suiteName: "group.EddieWen.SMSCount" )!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.statusTextField.delegate = self

        if let userStatus = self.userPreference.stringForKey("status") {
            self.statusTextField.text = userStatus
        }

        // Remove bottom border of navigation bar
        UINavigationBar.appearance().setBackgroundImage( UIImage(named: "standard-color"), forBarMetrics: .Default )
        UINavigationBar.appearance().shadowImage = UIImage()
    }

    @IBAction func dismissViewController(sender: AnyObject) {
        self.dismissViewControllerAnimated( true, completion: nil )
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 30
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
