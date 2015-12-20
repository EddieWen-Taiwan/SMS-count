//
//  SettingTableViewController.swift
//  SMSCount
//
//  Created by Eddie on 12/20/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {

    @IBOutlet var statusLabel: UILabel!

    let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")

    override func viewDidLoad() {
        super.viewDidLoad()

        if let status = self.userPreference?.stringForKey("status") {
            self.statusLabel.text = status
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? 3 : 1
    }

}
