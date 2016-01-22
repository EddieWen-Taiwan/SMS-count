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

        self.init(frame: CGRectMake(0, 0, width, height))

        self.viewWidth = width
        self.viewHeight = height

        self.backgroundColor = UIColor.whiteColor()

        self.status = status

        self.addIconView()
        self.addTitleLabel()

    }

    func addIconView() {

        let iconView = UIImageView(frame: CGRectMake(self.viewWidth/2-24, self.viewHeight/2-50, 48, 48))
            iconView.image = {
                switch self.status {
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

    func addTitleLabel() {

        let titleLabel = UILabel(frame: CGRectMake(0, self.viewHeight/2, self.viewWidth, 30))
            titleLabel.text = {
                switch self.status {
                    case "facebook":
                        return "尚未登入臉書帳號"
                    case "public":
                        return "查看好友列表需公開使用者"
                    case "no-friends":
                        return "沒有其他好友使用"
                    default:
                        return "目前沒有網路連線"
                }
            }()
            titleLabel.font = UIFont(name: "PingFangTC-Regular", size: 15)
            titleLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.38)
            titleLabel.textAlignment = .Center

        self.addSubview(titleLabel)

    }

}
