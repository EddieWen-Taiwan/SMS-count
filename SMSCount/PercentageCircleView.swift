//
//  PercentageCircleView.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/14.
//  Copyright (c) 2015年 Wen. All rights reserved.
//
//  FROM : stackoverflow.com/questions/26578023/animate-drawing-of-a-circle

import UIKit

class PercentageCircleView: UIView {

    let circleLayer = CAShapeLayer()
    let circleRadius = CGFloat(100)

    override init(frame: CGRect) {
        super.init(frame: frame)

        let circleBackLayer = CAShapeLayer()
        circleBackLayer.fillColor = UIColor.clearColor().CGColor
        circleBackLayer.strokeColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1).CGColor
        circleBackLayer.lineWidth = 1.0
        circleBackLayer.strokeEnd = 1.0

        let circleBackPath = UIBezierPath(arcCenter: CGPoint(x: 100, y: 100), radius: circleRadius, startAngle: 0.0, endAngle: CGFloat(M_PI*2), clockwise: true)
        circleBackLayer.path = circleBackPath.CGPath
        layer.addSublayer(circleBackLayer)

        // Setup the CAShapeLayer with the path, colors, and line width
        circleLayer.fillColor = UIColor.clearColor().CGColor
        circleLayer.strokeColor = UIColor(red: 255/255, green: 140/255, blue: 66/255, alpha: 100/100).CGColor

        circleLayer.lineWidth = 5

        // Don't draw the circle initially
        circleLayer.strokeEnd = 0.0

        // Add the circleLayer to the view's layer's sublayers
        layer.addSublayer(circleLayer)
    }

    func animateCircle( percent: Double ) {
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")

        // Set the animation duration appropriately
        animation.duration = 0.5

        // Animate from 0 (no circle) to 1 (full circle)
        animation.fromValue = 0
        animation.toValue = 1

        // Do a linear animation (i.e. the speed of the animation stays the same)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)

        // get currentPercentage
        let startAngle = CGFloat( M_PI*(0.5)*(-1) )
        let endAngle = CGFloat( M_PI*2*( percent ) - M_PI*(0.5) )
        
        // Use UIBezierPath as an easy way to create the CGPath for the layer.
        // The path should be the entire circle.
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 100, y: 100), radius: circleRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        circleLayer.path = circlePath.CGPath
        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the right value when the animation ends.
        circleLayer.strokeEnd = 1.0

        // Do the actual animation
        circleLayer.addAnimation(animation, forKey: "animateCircle")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
