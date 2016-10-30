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

    var parentVC: SettingTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        statusTextField.delegate = self

        if let userPreference = UserDefaults( suiteName: "group.EddieWen.SMSCount" ) {
            if let userStatus = userPreference.string(forKey: "status") {
                statusTextField.text = userStatus
            }
        }
    }

    @IBAction func dismissViewController(_ sender: AnyObject) {
        dismiss( animated: true, completion: nil )
    }

    @IBAction func saveNewStatus(_ sender: AnyObject) {
        var newStatus = (statusTextField.text ?? "") as NSString
        if newStatus.length > 30 {
            newStatus = newStatus.substring(to: 30) as NSString
        }
        parentVC?.updateNewStatusFromStatusVC( newStatus as String )
        dismiss( animated: true, completion: nil )
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 30
    }

}
