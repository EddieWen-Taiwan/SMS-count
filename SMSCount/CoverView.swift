//
//  CoverView.swift
//  SMSCount
//
//  Created by Eddie on 1/22/16.
//  Copyright © 2016 Wen. All rights reserved.
//

import UIKit

class CoverView: UIView {

    var viewWidth: CGFloat = 0.0
    var viewHeight: CGFloat = 0.0

    convenience init() {
        self.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.width-44-49))

        viewWidth = UIScreen.mainScreen().bounds.width
        viewHeight = UIScreen.mainScreen().bounds.height-44-49

    }

}
