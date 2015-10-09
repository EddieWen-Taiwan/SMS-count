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
    let documentURL = NSFileManager.defaultManager().URLsForDirectory( .DocumentDirectory, inDomains: .UserDomainMask )[0]
    let path: String
    var urlString = "http://i.imgur.com/"
    var currentMonth = "0"

    init(month: String) {
        NSLog("%@", "init")
        currentMonth = month
//        print(currentMonth)
        // update and svae image
        path = documentURL.URLByAppendingPathComponent("backgroundImage").path!
        urlString += "HOcvMMW.png"
self.downloadImage(NSURL(string: urlString)!)
    }

    private func downloadImage( url: NSURL ) {

        self.getImageFromUrl(url) { (data, response, error)  in
            dispatch_async( dispatch_get_main_queue() ) { () -> Void in
//                guard let data = data where error == nil else { return }
                print("Finished downloading \"\(url.URLByDeletingPathExtension!.lastPathComponent!)\".")

                self.saveImage( UIImage(data: data!)! )
                self.userPreference.setObject( self.currentMonth, forKey: "backgroundMonth" )
            }
        }
    }

    private func getImageFromUrl( url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void) ) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
        }.resume()
    }

    func currentImage() -> UIImage {
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            print("yes")
        }else {print("no")}
        
        print("\(path)")

        return UIImage(contentsOfFile: path)!
//        while let path = documentURL.URLByAppendingPathComponent("backgroundImage") {
        
//        }
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