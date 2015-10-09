//
//  BackImageUpdate.swift
//  SMSCount
//
//  Created by Eddie on 2015/10/9.
//  Copyright © 2015年 Wen. All rights reserved.
//

//import Foundation

class MonthlyImages {

    let documentURL = NSFileManager.defaultManager().URLsForDirectory( .DocumentDirectory, inDomains: .UserDomainMask )[0]

    init() {
NSLog("%@", "init")
        // update and svae image
        if let imageURL = NSURL(string: "http://i.imgur.com/HOcvMMW.png") {
            self.downloadImage(imageURL)
        }

    }

    private func downloadImage( url: NSURL ) {
        print("Started downloading \"\(url.URLByDeletingPathExtension!.lastPathComponent!)\".")
        self.getImageFromUrl(url) { (data, response, error)  in
            dispatch_async( dispatch_get_main_queue() ) { () -> Void in
                guard let data = data where error == nil else { return }
                print("Finished downloading \"\(url.URLByDeletingPathExtension!.lastPathComponent!)\".")

                self.saveImage( UIImage(data: data)! )
            }
        }
    }

    private func getImageFromUrl( url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void) ) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
        }.resume()
    }

    func currentImage() -> UIImage {
        let path = documentURL.URLByAppendingPathComponent("backgroundImage").path!
        print("\(path)")

        return UIImage(contentsOfFile: path)!
    }

    // Get path for a file in the directory
    private func fileInDocumentsDirectory() -> String {
        return documentURL.URLByAppendingPathComponent("backgroundImage").path!
    }

    private func saveImage( image: UIImage ) -> Bool {
        let pngImageData = UIImagePNGRepresentation(image)!
        let result = pngImageData.writeToFile( self.fileInDocumentsDirectory(), atomically: true )

        return result
    }

}