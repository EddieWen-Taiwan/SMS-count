//
//  BackImageUpdate.swift
//  SMSCount
//
//  Created by Eddie on 2015/10/9.
//  Copyright © 2015年 Wen. All rights reserved.
//

//import Foundation

class MonthlyImages {

    let userPreference = NSUserDefaults( suiteName: "group.EddieWen.SMSCount" )!
    let path: String
    var urlString = "http://i.imgur.com/"
    var currentMonth = "0"

    init(month: String, background: UIImageView) {
        currentMonth = month

        // update and svae image
        let documentURL = NSFileManager.defaultManager().URLsForDirectory( .DocumentDirectory, inDomains: .UserDomainMask )[0]
        path = documentURL.URLByAppendingPathComponent("backgroundImage").path!

        if !self.isMonthMatch() {
            print("have to download new one")
            urlString += "HOcvMMW.png"
            self.downloadImage( NSURL(string: urlString)!, backgroundImage: background )
        }
    }

    private func downloadImage( url: NSURL, backgroundImage: UIImageView ) {
        self.getImageFromUrl(url) { (data, response, error)  in
            dispatch_async( dispatch_get_main_queue() ) { () -> Void in
                print("Finished downloading \"\(url.URLByDeletingPathExtension!.lastPathComponent!)\".")

                self.saveImage( UIImage(data: data!)! )
                self.userPreference.setObject( self.currentMonth, forKey: "backgroundMonth" )
                backgroundImage.image = UIImage(data: data!)
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