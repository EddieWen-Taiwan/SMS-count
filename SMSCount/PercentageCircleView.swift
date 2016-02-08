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

    var circleCenter: CGPoint = CGPoint(x: 0, y: 0)
    var circleRadius: CGFloat = 0.0
    var mainWidth: CGFloat = 0.0
    var mainHeight: CGFloat = 0.0

    var percentageLabel = UILabel()

    convenience init() {
        self.init(frame: CGRectMake(0, 0, 180, 180))

        self.mainWidth = UIScreen.mainScreen().bounds.width
        self.mainHeight = (UIScreen.mainScreen().bounds.height-44-49)

        self.circleRadius = frame.size.width/2
        self.circleCenter = CGPoint(x: mainWidth/2, y: mainHeight/2)

        let fullCircleLayer = self.drawFullCircle()
        self.layer.addSublayer(fullCircleLayer)

        self.addPercentageLabel()
    }

    private func addPercentageLabel() {

        self.percentageLabel.textColor = UIColor.whiteColor()
        self.percentageLabel.font = UIFont(name: "Verdana", size: 44)

        self.addSubview( self.percentageLabel )

    }

    func setPercentage( value: String ) {

        self.percentageLabel.text = value
        self.percentageLabel.sizeToFit()
        self.percentageLabel.center = CGPoint(x: mainWidth/2-10, y: mainHeight/2+4)

        self.addSymbolLabel()
    }

    private func addSymbolLabel() {

        let x = mainWidth/2-10+self.percentageLabel.frame.width/2
        let y = mainHeight/2-2
        let symbol = UILabel(frame: CGRectMake(x,y,0,0))
            symbol.textColor = UIColor.redColor()
            symbol.font = UIFont(name: "Verdana", size: 24)
            symbol.text = "%"
            symbol.sizeToFit()

        self.addSubview( symbol )

    }

    // The full basic circle
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
    func addPercentageCircle( percent: Double ) {

        let angleArray: [CGFloat] = self.calculateAngle( percent )
        // Use UIBezierPath as an easy way to create the CGPath for the layer.
        // The path should be the entire circle.
        let circlePath = UIBezierPath(arcCenter: circleCenter, radius: circleRadius, startAngle: angleArray[0], endAngle: angleArray[1], clockwise: true)
        let circleLayer = self.drawBasicCircle()
            circleLayer.path = circlePath.CGPath

        let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!
        if userPreference.boolForKey("countdownAnimation") {
            circleLayer.strokeEnd = 0.0
            self.animateCircle( circleLayer, percent: percent )
        }

        // Add the circleLayer to the view's layer's sublayers
        self.layer.addSublayer(circleLayer)
    }

    private func calculateAngle( var percent: Double ) -> [CGFloat] {
        if percent > 1 {
            percent = 1
        } else if percent < 0 {
            percent = 0
        }
        // get currentPercentage
        var angleArray = [CGFloat]()
        angleArray.append( CGFloat( M_PI*(0.5)*(-1) ) ) // START
        angleArray.append( CGFloat( M_PI*2*( percent ) - M_PI*(0.5) ) ) // END

        return angleArray
    }

    // The process circle
    private func drawBasicCircle() -> CAShapeLayer {
        let circleLayer = CAShapeLayer()
            circleLayer.fillColor = UIColor.clearColor().CGColor
            circleLayer.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).CGColor
            circleLayer.lineWidth = 5
            circleLayer.strokeEnd = 1.0

        return circleLayer
    }

    // Show animation
    private func animateCircle( circleLayer: CAShapeLayer, percent: Double ) {
        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the right value when the animation ends.
        circleLayer.strokeEnd = 1.0

        // Do the actual animation
        let animation = self.makeAnimation()
        circleLayer.addAnimation(animation, forKey: "animateCircle")
    }

    // Make animation effect
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
