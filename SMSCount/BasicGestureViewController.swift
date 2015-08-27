//
//  BasicGestureViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/27.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class BasicGestureViewController: UIViewController {

    var leftSwipeGesture: UISwipeGestureRecognizer!
    var rightSwipeGesture: UISwipeGestureRecognizer!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: Selector("switchBetweenView:"))
        leftSwipeGesture.direction = .Left
        rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: Selector("switchBetweenView:"))
        rightSwipeGesture.direction = .Right
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.view.addGestureRecognizer(leftSwipeGesture)
        self.view.addGestureRecognizer(rightSwipeGesture)
    }

    func switchBetweenView(sender: UISwipeGestureRecognizer) {

        println(self.restorationIdentifier)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
