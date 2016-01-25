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
        self.init(frame: CGRectMake(0,0,80,80))

        self.center = center
        self.layer.cornerRadius = 20
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)

        let indicator = self.addActivityIndicator()
        self.addSubview( indicator )
    }

    // Add UIActivityIndicator in UIView center
    private func addActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            activityIndicator.center = CGPointMake(40, 40)

        return activityIndicator
    }

}
