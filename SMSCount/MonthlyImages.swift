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
    var currentMonth = "0"

    init(month: String, background: UIImageView) {
        currentMonth = month

        // update and svae image
        let documentURL = NSFileManager.defaultManager().URLsForDirectory( .DocumentDirectory, inDomains: .UserDomainMask )[0]
        path = documentURL.URLByAppendingPathComponent("backgroundImage").path!

        if self.isMonthMatch() {
            background.image = UIImage(contentsOfFile: path)
        } else {
            background.alpha = 0

            var urlString = "http://i.imgur.com/"
            switch currentMonth {
                case "01":
                    urlString += "EcF4PCU.png"
                    break
                case "02":
                    urlString += "2tAGwJN.png"
                    break
                case "03":
                    urlString += "pFUhPyd.png"
                    break
                case "04":
                    urlString += "4Qj4g64.png"
                    break
                case "05":
                    urlString += "bRMsY13.png"
                    break
                case "06":
                    urlString += "umSwCmz.png"
                    break
                case "07":
                    urlString += "kpDMmFD.png"
                    break
                case "08":
                    urlString += "mSGXZlD.png"
                    break
                case "09":
                    urlString += "OhZ2J6Q.png"
                    break
                case "10":
                    urlString += "aImI8Lr.png"
                    break
                case "11":
                    urlString += "4GFJfSt.png"
                    break
                default:
                    urlString += "c5A2WpA.png"
                    break
            }
            self.downloadImage( NSURL(string: urlString)!, backgroundImage: background )
        }
    }

    private func downloadImage( url: NSURL, backgroundImage: UIImageView ) {
        self.getImageFromUrl(url) { (data, response, error)  in
            dispatch_async( dispatch_get_main_queue() ) { () -> Void in
                self.saveImage( UIImage(data: data!)! )
                self.userPreference.setObject( self.currentMonth, forKey: "backgroundMonth" )
                backgroundImage.image = UIImage(data: data!)

                UIView.animateWithDuration( 1, animations: {
                    backgroundImage.alpha = 1
                })
            }
        }
    }

    private func getImageFromUrl( url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void) ) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
        }.resume()
    }

    private func saveImage( image: UIImage ) -> Bool {
        let pngImageData = UIImagePNGRepresentation(image)!
        let result = pngImageData.writeToFile( self.path, atomically: true )

        return result
    }

    private func isMonthMatch() -> Bool {
        let imageMonth = userPreference.stringForKey("backgroundMonth")
        return imageMonth == currentMonth ? true : false
    }

}