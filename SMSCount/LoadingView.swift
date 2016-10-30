//
//  LoadingView.swift
//  SMSCount
//
//  Created by Eddie on 1/22/16.
//  Copyright © 2016 Wen. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    convenience init(center: CGPoint) {
        self.init(frame: CGRect(x: 0,y: 0,width: 80,height: 80))

        self.center = center
        self.layer.cornerRadius = 20
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)

        let indicator = addActivityIndicator()
        self.addSubview( indicator )
    }

    // Add UIActivityIndicator in UIView center
    fileprivate func addActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            activityIndicator.center = CGPoint(x: 40, y: 40)

        return activityIndicator
    }

}
