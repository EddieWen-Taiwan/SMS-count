//
//  ViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/8.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var backRemainedDaysLabel: UILabel!
    @IBOutlet var screenShotScale: UIView!
    @IBOutlet var frontRemainedDaysLabel: UILabel!
    @IBOutlet var backgroundImage: UIImageView!

    @IBOutlet var retireDateLabel: UILabel!
    @IBOutlet var passedDaysLabel: UILabel!

    var loadingTimer: NSTimer!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var loadingImage: UIImageView!

    var animationIndex: Int = 0
    var animationArray = [ "" ]
    var stageIndexArray = [ 55, 75, 88, 94, 97, 99 ]
    var monthImage = "background_01"

    let countingClass = CountingDate()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let currentMonth = NSCalendar.currentCalendar().components( .CalendarUnitMonth, fromDate: NSDate() ).month
        let currentMonthStr = ( currentMonth < 10 ) ? "0" + String(currentMonth) : String( currentMonth )
        monthImage = "background_" + currentMonthStr
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.backgroundImage.image = UIImage(named: monthImage)
    }

    override func viewDidAppear(animated: Bool) {

        if countingClass.isSettingAllDone() {
            // OK
            countingClass.updateDate()
            if self.frontRemainedDaysLabel.text != String( countingClass.getRemainedDays() ) {
                var remainedDays = countingClass.getRemainedDays()
                self.backRemainedDaysLabel.text = String( remainedDays )

                self.retireDateLabel.text = countingClass.getRetireDate()

                self.passedDaysLabel.text = String( countingClass.getPassedDays() )

                // Timer Effect
                animationIndex = 0
                animationArray.removeAll(keepCapacity: false)
                if remainedDays < 100 && remainedDays > 0 {
                    for var i = 1; i <= remainedDays; i++ {
                        animationArray.append( String(i) )
                    }
                } else {
                    for var i = 1; i <= 97; i++ {
                        animationArray.append( String( format: "%.f", Double( (remainedDays-3)*i )*0.01 ) )
                    }
                    for var i = 98; i <= 100; i++ {
                        animationArray.append( String( remainedDays-(100-i) ) )
                    }
                }

                stageIndexArray[0] = Int( Double(animationArray.count)*0.55 )
                stageIndexArray[1] = Int( Double(animationArray.count)*0.75 )
                stageIndexArray[2] = Int( Double(animationArray.count)*0.88 )
                stageIndexArray[3] = Int( Double(animationArray.count)*0.94 )
                stageIndexArray[4] = Int( Double(animationArray.count)*0.97 )
                stageIndexArray[5] = animationArray.count-1

                var timer = NSTimer.scheduledTimerWithTimeInterval( 0.01, target: self, selector: Selector("daysAddingEffect:"), userInfo: "stage1", repeats: true )
            }
        } else {
            // switch to settingViewController ?
            // tabBarController?.selectedIndex = 2
        }

    }

    @IBAction func pressShareButton(sender: AnyObject) {

        let askAlertController = UIAlertController( title: "分享", message: "將進行螢幕截圖並分享至您的 Facebook，要繼續進行嗎？", preferredStyle: .Alert )
        let yesAction = UIAlertAction( title: "好", style: .Default, handler: {(action) -> Void in

            self.startLoadingAnimation()
            
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                // do some task
                sleep(1)
                // Create the UIImage
                // let mainWindowLayer = UIApplication.sharedApplication().keyWindow!.layer
                let mainWindowLayer = self.screenShotScale.layer
                UIGraphicsBeginImageContextWithOptions( CGSize( width: mainWindowLayer.frame.width, height: mainWindowLayer.frame.height ), true, UIScreen.mainScreen().scale )
                mainWindowLayer.renderInContext( UIGraphicsGetCurrentContext() )
                let screenShot = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                // Save it to the camera roll
                UIImageWriteToSavedPhotosAlbum( screenShot, nil, nil, nil )

                dispatch_async(dispatch_get_main_queue()) {
                    // update some UI

                    // Show images picker
                    self.showImagesPickerView()
                }
            }

        })
        let noAction = UIAlertAction( title: "取消", style: .Cancel, handler: nil )

        askAlertController.addAction( yesAction )
        askAlertController.addAction( noAction )

        self.presentViewController( askAlertController, animated: true, completion: nil )

    }

    // the following method is called to show the iOS image picker:
    func showImagesPickerView(){
        if UIImagePickerController.isSourceTypeAvailable( UIImagePickerControllerSourceType.SavedPhotosAlbum ) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false

            self.stopLoadingAnimation()

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

        func updateLabel() {
            self.frontRemainedDaysLabel.text = animationArray[ animationIndex++ ]
        }

        switch( timer.userInfo! as! String ) {
            case "stage1":
                if animationIndex < stageIndexArray[0] {
                    updateLabel()
                } else {
                    timer.invalidate()
                    var timer2 = NSTimer.scheduledTimerWithTimeInterval( 0.02, target: self, selector: "daysAddingEffect:", userInfo: "stage2", repeats: true )
                }

            case "stage2":
                if animationIndex < stageIndexArray[1] {
                    updateLabel()
                } else {
                    timer.invalidate()
                    var timer3 = NSTimer.scheduledTimerWithTimeInterval( 0.04, target: self, selector: "daysAddingEffect:", userInfo: "stage3", repeats: true )
                }
            
            case "stage3":
                if animationIndex < stageIndexArray[2] {
                    updateLabel()
                } else {
                    timer.invalidate()
                    var timer4 = NSTimer.scheduledTimerWithTimeInterval( 0.08, target: self, selector: "daysAddingEffect:", userInfo: "stage4", repeats: true )
                }

            case "stage4":
                if animationIndex < stageIndexArray[3] {
                    updateLabel()
                } else {
                    timer.invalidate()
                    var timer5 = NSTimer.scheduledTimerWithTimeInterval( 0.16, target: self, selector: "daysAddingEffect:", userInfo: "stage5", repeats: true )
            }

            case "stage5":
                if animationIndex < stageIndexArray[4] {
                    updateLabel()
                } else {
                    timer.invalidate()
                    var timer6 = NSTimer.scheduledTimerWithTimeInterval( 0.32, target: self, selector: "daysAddingEffect:", userInfo: "stage6", repeats: true )
            }

            case "stage6":
                if animationIndex < stageIndexArray[5] {
                    updateLabel()
                } else {
                    timer.invalidate()
                    var timer7 = NSTimer.scheduledTimerWithTimeInterval( 0.5, target: self, selector: "daysAddingEffect:", userInfo: "stage7", repeats: true )
            }

            case "stage7":
                if animationIndex == stageIndexArray[5] {
                    updateLabel()
                } else {
                    timer.invalidate()
                }

            default:
                break;
        }
    }

    func startLoadingAnimation() {
        println("start")
        self.loadingView.hidden = false
        self.loadingTimer = NSTimer.scheduledTimerWithTimeInterval( 0.1, target: self, selector: "updateLoadingStage:", userInfo: nil, repeats: true )
    }

    func updateLoadingStage( timer: NSTimer ) {
        println(loadingView.tag)
        switch( loadingView.tag ) {
            case 1:
                loadingImage.image = UIImage(named: "loader_spinner-2")
                loadingView.tag = 2
            case 2:
                loadingImage.image = UIImage(named: "loader_spinner-3")
                loadingView.tag = 3
            case 3:
                loadingImage.image = UIImage(named: "loader_spinner-4")
                loadingView.tag = 4
            case 4:
                loadingImage.image = UIImage(named: "loader_spinner-5")
                loadingView.tag = 5
            case 5:
                loadingImage.image = UIImage(named: "loader_spinner-6")
                loadingView.tag = 6
            case 6:
                loadingImage.image = UIImage(named: "loader_spinner-7")
                loadingView.tag = 7
            case 7:
                loadingImage.image = UIImage(named: "loader_spinner-8")
                loadingView.tag = 8
            case 8:
                loadingImage.image = UIImage(named: "loader_spinner-1")
                loadingView.tag = 1
            default:
                break;
        }
    }

    func stopLoadingAnimation() {
        println("stop")
        self.loadingView.hidden = true
        self.loadingTimer.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

