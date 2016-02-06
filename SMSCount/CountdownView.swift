//
//  CountdownView.swift
//  SMSCount
//
//  Created by Eddie on 2/6/16.
//  Copyright © 2016 Wen. All rights reserved.
//

import UIKit

class CountdownView: UIView {

    convenience init(view: UIView) {
        self.init(frame: CGRectMake(0, 0, view.frame.width, view.frame.height-44-49))
    }

}
