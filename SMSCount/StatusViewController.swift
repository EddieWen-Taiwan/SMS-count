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

    var parentVC: SettingTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.statusTextField.delegate = self

        if let userStatus = self.userPreference.stringForKey("status") {
            self.statusTextField.text = userStatus
        }
    }

    @IBAction func dismissViewController(sender: AnyObject) {
        self.dismissViewControllerAnimated( true, completion: nil )
    }

    @IBAction func saveNewStatus(sender: AnyObject) {
        
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 30
    }

}
