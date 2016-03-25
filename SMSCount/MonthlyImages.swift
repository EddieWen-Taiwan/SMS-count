//
//  BackImageUpdate.swift
//  SMSCount
//
//  Created by Eddie on 2015/10/9.
//  Copyright © 2015年 Wen. All rights reserved.
//

class MonthlyImages {

    let userPreference = NSUserDefaults( suiteName: "group.EddieWen.SMSCount" )!
    let path: String
    let currentMonth: String

    let reachability = Reachability()

    init(month: String) {
        self.currentMonth = month

        // update and save image
        let documentURL = NSFileManager.defaultManager().URLsForDirectory( .DocumentDirectory, inDomains: .UserDomainMask )[0]
        self.path = documentURL.URLByAppendingPathComponent("backgroundImage").path!
    }

    func setBackground( background: UIImageView ) {
        if currentMonth == userPreference.stringForKey("backgroundMonth") {
            background.image = UIImage(contentsOfFile: path)
        } else {
            background.alpha = 0

            if reachability.isConnectedToNetwork() {
                let urlString = "http://smscount.lol/app/backgroundImg/" + currentMonth
                downloadImage( NSURL(string: urlString)!, backgroundImage: background )
            }
        }
    }

    private func downloadImage( url: NSURL, backgroundImage: UIImageView ) {
        reachability.getImageFromUrl(url) { data, response, error in

            if let data = data {
                dispatch_async( dispatch_get_main_queue() ) {
                    self.saveImage( UIImage(data: data)! )
                    self.userPreference.setObject( self.currentMonth, forKey: "backgroundMonth" )
                    backgroundImage.image = UIImage(data: data)

                    UIView.animateWithDuration( 1, animations: {
                        backgroundImage.alpha = 1
                    })
                }
            } else {
                backgroundImage.backgroundColor = UIColor(patternImage: UIImage(named: "default-background")!)
                backgroundImage.alpha = 1
            }

        }
    }

    private func saveImage( image: UIImage ) {
        let pngImageData = UIImagePNGRepresentation(image)!
        if NSFileManager.defaultManager().fileExistsAtPath( path ) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath( path )
            } catch {}
        }
        pngImageData.writeToFile( path, atomically: true )
    }

}