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

    var mainLayer: CALayer!
    var circleRadius: CGFloat = 0.0
    var circleCenter: CGPoint = CGPoint(x: 0, y: 0)

    convenience init(view: UIView) {
        self.init(frame: view.frame)

        self.mainLayer = view.layer
        self.circleRadius = frame.size.width/2
        self.circleCenter = CGPoint(x: Int(circleRadius), y: Int(circleRadius))

        let fullCircleLayer = self.drawFullCircle()
        self.mainLayer.addSublayer(fullCircleLayer)
    }

    private func drawFullCircle() -> CAShapeLayer {
        let circleLayer = CAShapeLayer()
            circleLayer.fillColor = UIColor.clearColor().CGColor
            circleLayer.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3).CGColor
            circleLayer.lineWidth = 1.0
            circleLayer.strokeEnd = 1.0

        let circleBackPath = UIBezierPath(arcCenter: circleCenter, radius: circleRadius, startAngle: 0.0, endAngle: CGFloat(M_PI*2), clockwise: true)
            circleLayer.path = circleBackPath.CGPath

        return circleLayer
    }

    // Layer2 : Percentage
    func addPercentageCircle( var percent: Double ) {

        if percent > 1 {
            percent = 1
        } else if percent < 0 {
            percent = 0
        }
        // get currentPercentage
        let startAngle = CGFloat( M_PI*(0.5)*(-1) )
        let endAngle = CGFloat( M_PI*2*( percent ) - M_PI*(0.5) )
        
        // Use UIBezierPath as an easy way to create the CGPath for the layer.
        // The path should be the entire circle.
        let circlePath = UIBezierPath(arcCenter: circleCenter, radius: circleRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        let circleLayer = self.drawBasicCircle()
            circleLayer.path = circlePath.CGPath

        let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!
        if userPreference.boolForKey("countdownAnimation") {
            circleLayer.strokeEnd = 0.0
            self.animateCircle( circleLayer, percent: percent )
        }

        // Add the circleLayer to the view's layer's sublayers
        self.mainLayer.addSublayer(circleLayer)
    }

    private func drawBasicCircle() -> CAShapeLayer {

        let circleLayer = CAShapeLayer()
            circleLayer.fillColor = UIColor.clearColor().CGColor
            circleLayer.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).CGColor
            circleLayer.lineWidth = 5
            circleLayer.strokeEnd = 1.0

        return circleLayer

    }

    func animateCircle( circleLayer: CAShapeLayer, percent: Double ) {
        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the right value when the animation ends.
        circleLayer.strokeEnd = 1.0

        // Do the actual animation
        let animation = self.makeAnimation()
        circleLayer.addAnimation(animation, forKey: "animateCircle")
    }

    private func makeAnimation() -> CABasicAnimation {
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")
            // Set the animation duration appropriately
            animation.duration = 0.5
            // Animate from 0 (no circle) to 1 (full circle)
            animation.fromValue = 0
            animation.toValue = 1
            // Do a linear animation (i.e. the speed of the animation stays the same)
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)

        return animation
    }

}
