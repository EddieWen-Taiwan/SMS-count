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

    var status: String = ""

    convenience init( width: CGFloat, height: CGFloat, status: String ) {

        self.init(frame: CGRect(x: 0, y: 0, width: width, height: height))

        self.viewWidth = width
        self.viewHeight = height

        self.backgroundColor = UIColor.white

        self.status = status

        self.addIconView()
        self.addTitleLabel()

    }

    fileprivate func addIconView() {

        let iconView = UIImageView(frame: CGRect(x: viewWidth/2-24, y: viewHeight/2-50, width: 48, height: 48))
            iconView.image = {
                switch status {
                    case "facebook":
                        return UIImage(named: "person-pin")!
                    case "public":
                        return UIImage(named: "setting-pin")!
                    case "no-friends":
                        return UIImage()
                    default:
                        return UIImage(named: "internet-pin")!
                }
            }()

        self.addSubview(iconView)

    }

    fileprivate func addTitleLabel() {

        let titleLabel = UILabel(frame: CGRect(x: 0, y: viewHeight/2, width: viewWidth, height: 30))
            titleLabel.text = {
                switch status {
                    case "facebook":
                        return "尚未登入臉書帳號"
                    case "public":
                        return "社群設定為不公開"
                    case "no-friends":
                        return "目前沒有好友使用"
                    default:
                        return "目前沒有網路連線"
                }
            }()
            titleLabel.font = UIFont(name: "PingFangTC-Regular", size: 15)
            titleLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.38)
            titleLabel.textAlignment = .center

        self.addSubview(titleLabel)

    }

}
