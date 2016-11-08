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
    var valueOfPercentage: Double = 0

    let mainWidth: CGFloat = UIScreen.main.bounds.width
    let mainHeight: CGFloat = UIScreen.main.bounds.height-44-49

    var percentageLabel = UILabel()

    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 180, height: 180))

        self.circleRadius = frame.size.width/2
        self.circleCenter = CGPoint(x: mainWidth/2, y: mainHeight/2)

        // Hide this view at first
        self.alpha = 0

        let fullCircleLayer = drawFullCircle()
        self.layer.addSublayer(fullCircleLayer)

        addPercentageLabel()
    }

    fileprivate func addPercentageLabel() {

        percentageLabel.textColor = UIColor.white
        percentageLabel.font = UIFont(name: "Verdana", size: 44)

        self.addSubview( percentageLabel )

    }

    func setPercentage( _ value: Double ) {
        // Store it here, it will be easy later
        valueOfPercentage = value

        percentageLabel.text = String( format: "%.1f", value )
        percentageLabel.sizeToFit()
        percentageLabel.center = CGPoint(x: mainWidth/2-10, y: mainHeight/2+4)

        addSymbolLabel()
        addTextLabel()
    }

    // %
    fileprivate func addSymbolLabel() {

        let x = mainWidth/2-10+percentageLabel.frame.width/2
        let y = mainHeight/2-2
        let symbol = UILabel(frame: CGRect(x: x,y: y,width: 0,height: 0))
            symbol.textColor = UIColor.white
            symbol.font = UIFont(name: "Verdana", size: 24)
            symbol.text = "%"
            symbol.sizeToFit()

        self.addSubview( symbol )

    }

    // 退伍進度
    fileprivate func addTextLabel() {

        let text = UILabel(frame: CGRect( x: mainWidth/2-32, y: mainHeight/2+110, width: 64, height: 23 ))
            text.text = "退伍進度"
            text.textColor = UIColor.white
            text.font = UIFont(name: "PingFangTC-Regular", size: 16)

        self.addSubview( text )

    }

    // The full basic circle
    fileprivate func drawFullCircle() -> CAShapeLayer {
        let circleLayer = CAShapeLayer()
            circleLayer.fillColor = UIColor.clear.cgColor
            circleLayer.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3).cgColor
            circleLayer.lineWidth = 1.0
            circleLayer.strokeEnd = 1.0

        let circleBackPath = UIBezierPath(arcCenter: circleCenter, radius: circleRadius, startAngle: 0.0, endAngle: CGFloat(M_PI*2), clockwise: true)
            circleLayer.path = circleBackPath.cgPath

        return circleLayer
    }

    // Layer2 : Percentage
    func addPercentageCircle() {

        let angleArray: [CGFloat] = calculateAngle( valueOfPercentage*(0.01) )
        // Use UIBezierPath as an easy way to create the CGPath for the layer.
        // The path should be the entire circle.
        let circlePath = UIBezierPath(arcCenter: circleCenter, radius: circleRadius, startAngle: angleArray[0], endAngle: angleArray[1], clockwise: true)
        let circleLayer = drawBasicCircle()
            circleLayer.path = circlePath.cgPath

        let userPreference = UserDefaults(suiteName: "group.EddieWen.SMSCount")!
        if userPreference.bool(forKey: "countdownAnimation") {
            circleLayer.strokeEnd = 0.0
            animateCircle( circleLayer, percent: valueOfPercentage*(0.01) )
        }

        // Add the circleLayer to the view's layer's sublayers
        self.layer.addSublayer(circleLayer)
    }

    fileprivate func calculateAngle( _ percent: Double ) -> [CGFloat] {
        var cleanPercent = percent
        if cleanPercent > 1 {
            cleanPercent = 1
        } else if cleanPercent < 0 {
            cleanPercent = 0
        }

        // get currentPercentage
        var angleArray = [CGFloat]()
        angleArray.append( CGFloat( M_PI*(0.5)*(-1) ) ) // START
        angleArray.append( CGFloat( M_PI*2*( cleanPercent ) - M_PI*(0.5) ) ) // END

        return angleArray
    }

    // The process circle
    fileprivate func drawBasicCircle() -> CAShapeLayer {
        let circleLayer = CAShapeLayer()
            circleLayer.fillColor = UIColor.clear.cgColor
            circleLayer.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
            circleLayer.lineWidth = 5
            circleLayer.strokeEnd = 1.0

        return circleLayer
    }

    // Show animation
    fileprivate func animateCircle( _ circleLayer: CAShapeLayer, percent: Double ) {
        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the right value when the animation ends.
        circleLayer.strokeEnd = 1.0

        // Do the actual animation
        let animation = makeAnimation()
        circleLayer.add(animation, forKey: "animateCircle")
    }

    // Make animation effect
    fileprivate func makeAnimation() -> CABasicAnimation {
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
