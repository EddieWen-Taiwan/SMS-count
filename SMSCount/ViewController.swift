//
//  ViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/8.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var remainedDaysLabel: UILabel!
    @IBOutlet var screenShotScale: UIView!
    @IBOutlet var screenShotWrapper: UIView!

    var animationIndex: Int = 0
    var animationArray = [ "" ]

    let countingClass = CountingDate()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {

        if countingClass.isSettingAllDone() {
            // OK
            countingClass.updateDate()
            if remainedDaysLabel.text != String( countingClass.getRemainedDays() ) {
                var remainedDays = countingClass.getRemainedDays()

                // Timer Effect
                let animationInterval: Double = 0.01
                animationIndex = 0
                animationArray.removeAll(keepCapacity: false)
                for var i = 1; i <= 100; i++ {
                    animationArray.append( String( format: "%.f", Double(remainedDays*i)*animationInterval ) )
                }

                var timer = NSTimer.scheduledTimerWithTimeInterval( animationInterval, target: self, selector: Selector("daysAddingEffect:"), userInfo: "stage1", repeats: true )
            }
        }

    }

    @IBAction func pressShareButton(sender: AnyObject) {

        let askAlertController = UIAlertController( title: "分享", message: "將進行螢幕截圖並分享至您的 Facebook，要繼續進行嗎？", preferredStyle: .Alert )
        let yesAction = UIAlertAction( title: "好", style: .Default, handler: {(action) -> Void in

            if FBSDKAccessToken.currentAccessToken() == nil {

                let fbLogin = FBSDKLoginManager()
                fbLogin.logInWithReadPermissions( ["public_profile", "email"], handler: {( result: FBSDKLoginManagerLoginResult!, error: NSError! ) -> Void in

                    var loginStatus = "success"

                    if error != nil {
                        loginStatus = "error"
                    } else if result.isCancelled {
                        loginStatus = "cancelled"
                    }

                    if loginStatus == "success" {

                        let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest( graphPath: "me", parameters: ["fields": "name, email"] )
                        graphRequest.startWithCompletionHandler( {(connect, result, error) -> Void in

                            if error != nil {
                                println( "Error is \(error)" )
                            } else {
                                println( "Fetched user: \(result)" )
                                // To save user data

                                var username: String = result.valueForKey("name") == nil ? "" : result.valueForKey("name") as! String
                                var usermail: String = result.valueForKey("email") == nil ? "" : result.valueForKey("email") as! String
                                var fb_id: String = result.valueForKey("id") == nil ? "" : result.valueForKey("id") as! String

                                if Reachability().isConnectedToNetwork() {
                                    self.saveUserData( username, mail: usermail, fbid: fb_id )
                                }
                            }

                        })

                        self.getScreenShot()

                    } else {

                        var alertMessage = loginStatus == "error" ? "請稍候再次嘗試" : "您取消了分享"
                        let wrongAlertController = UIAlertController( title: "分享", message: alertMessage, preferredStyle: .Alert )
                        let cancelAction = UIAlertAction( title: "確定", style: .Default, handler: nil )
                        wrongAlertController.addAction( cancelAction )

                        self.presentViewController( wrongAlertController, animated: true, completion: nil )

                    }

                })

            } else {
                // Login already
                self.getScreenShot()
            }

        })
        let noAction = UIAlertAction( title: "取消", style: .Cancel, handler: nil )

        askAlertController.addAction( yesAction )
        askAlertController.addAction( noAction )

        self.presentViewController( askAlertController, animated: true, completion: nil )

    }

    func getScreenShot() {

        screenShotWrapper.hidden = false

        // Create the UIImage
        // let mainwindowLayer = UIApplication.sharedApplication().keyWindow!.layer
        let mainWindowLayer = screenShotScale.layer
        UIGraphicsBeginImageContextWithOptions( CGSize( width: mainWindowLayer.frame.width, height: mainWindowLayer.frame.height ), true, UIScreen.mainScreen().scale )
        mainWindowLayer.renderInContext( UIGraphicsGetCurrentContext() )
        let screenShot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        screenShotWrapper.hidden = true

        // Save it to the camera roll
        UIImageWriteToSavedPhotosAlbum( screenShot, nil, nil, nil )

        // Show images picker
        self.showImagesPickerView()

    }

    // the following method is called to show the iOS image picker:
    func showImagesPickerView(){
        if UIImagePickerController.isSourceTypeAvailable( UIImagePickerControllerSourceType.SavedPhotosAlbum ) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            self.presentViewController( imagePicker, animated: true, completion: nil )
        }
    }

    // Once the User selects a photo, the following delegate method is called.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let photo = FBSDKSharePhoto()
        photo.image = info[UIImagePickerControllerOriginalImage] as! UIImage
        photo.userGenerated = true

        let content = FBSDKSharePhotoContent()
        content.photos = [photo]

        FBSDKShareDialog.showFromViewController( self, withContent: content, delegate: nil )

        dismissViewControllerAnimated( true, completion: nil )
    }

    func daysAddingEffect( timer: NSTimer ) {
        switch( timer.userInfo! as! String ) {
            case "stage1":
                if animationIndex < 50 {
                    self.remainedDaysLabel.text = animationArray[ animationIndex ]
                    self.animationIndex++
                } else {
                    timer.invalidate()
                    var timer2 = NSTimer.scheduledTimerWithTimeInterval( 0.05, target: self, selector: "daysAddingEffect:", userInfo: "stage2", repeats: true )
                }

            case "stage2":
                if animationIndex < 85 {
                    self.remainedDaysLabel.text = animationArray[ animationIndex ]
                    self.animationIndex++
                } else {
                    timer.invalidate()
                    var timer3 = NSTimer.scheduledTimerWithTimeInterval( 0.1, target: self, selector: "daysAddingEffect:", userInfo: "stage3", repeats: true )
                }
            
            case "stage3":
                if animationIndex < 100 {
                    self.remainedDaysLabel.text = animationArray[ animationIndex ]
                    self.animationIndex++
                } else {
                    timer.invalidate()
                }

            default:
                break;
        }
    }

    func saveUserData( name: String, mail: String, fbid: String ) {

        let httpRequest = NSMutableURLRequest( URL: NSURL( string: "http://eddiewen.me/sms_count/addUserFromApp.php" )! )
        let postString = "mail=\(mail)&name=\(name)&fbid=\(fbid)"

        httpRequest.HTTPMethod = "POST"
        httpRequest.HTTPBody = postString.dataUsingEncoding( NSUTF8StringEncoding, allowLossyConversion: true )

        let addUserTask = NSURLSession.sharedSession().dataTaskWithRequest( httpRequest ) { ( response, data, error ) in

            if error != nil {
                println("Error : \(error).")
            }
//            let servResponse = NSString( data: response, encoding: NSUTF8StringEncoding )!

        }
        addUserTask.resume()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

