//
//  ViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/8.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // <<Back>> - about ScreenShot
    @IBOutlet var backRemainedDaysLabel: UILabel!
    @IBOutlet var backRemainedDaysWord: UILabel!
    @IBOutlet var screenShotScale: UIView!

    // <<Front>>
    @IBOutlet var backgroundImage: UIImageView!
    var monthImage = "background_01"
    var currentDisplay = "day"
    @IBOutlet var switchViewButton: UIView!
    @IBOutlet var imageOnSwitchBtn: UIImageView!


    // RemainedDays
    @IBOutlet var remainedView: UIView!
    @IBOutlet var frontRemainedDaysLabel: UILabel!
    @IBOutlet var frontRemainedDaysWord: UILabel!
    var animationIndex: Int = 0
    var animationArray = [ "" ]
    var stageIndexArray = [ 55, 75, 88, 94, 97, 99 ]
    var isDaysJumped: Bool = false

    // currentProcess %
    @IBOutlet var pieChartView: UIView!
    @IBOutlet var percentageLabel: UILabel!
    var isCircleDrawn: Bool = false

    // LoaingView after screenshot
    @IBOutlet var loadingView: UIView!
    @IBOutlet var loadingActivity: UIActivityIndicatorView!

    let countingClass = CountingDate()
    var circleView: PercentageCircleView!
    var screenHeight = UIScreen.mainScreen().bounds.height
    var screenWidth = UIScreen.mainScreen().bounds.width
    var settingStatus: Bool = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let currentMonth = NSCalendar.currentCalendar().components( .Month, fromDate: NSDate() ).month
        let currentMonthStr = ( currentMonth < 10 ) ? "0" + String(currentMonth) : String( currentMonth )
        monthImage = "background_" + currentMonthStr
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.backgroundImage.image = UIImage(named: monthImage)
        let switchGesture = UITapGestureRecognizer(target: self, action: "switchView")
        self.switchViewButton.addGestureRecognizer( switchGesture )
        self.switchViewButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.switchViewButton.layer.borderWidth = 2

        circleView = PercentageCircleView( view: self.pieChartView )
        self.pieChartView.addSubview( circleView )
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        settingStatus = countingClass.isSettingAllDone() ? true : false

        if self.settingStatus {
            // OK
            countingClass.updateDate()
            // RemainedDays
            if self.frontRemainedDaysLabel.text != String( countingClass.getRemainedDays() ) {
                var remainedDays = countingClass.getRemainedDays()
                if remainedDays < 0 {
                    remainedDays *= (-1)
                    self.backRemainedDaysWord.text = "自由天數"
                    self.frontRemainedDaysWord.text = "自由天數"
                } else {
                    self.backRemainedDaysWord.text = "剩餘天數"
                    self.frontRemainedDaysWord.text = "剩餘天數"
                }
                self.backRemainedDaysLabel.text = String( remainedDays )

                // Timer Effect
                animationIndex = 0
                animationArray.removeAll(keepCapacity: false)
                if remainedDays < 100 {
                    for var i = 0; i <= remainedDays; i++ {
                        animationArray.append( String(i) )
                    }
                } else {
                    for var i = 1; i <= 95; i++ {
                        animationArray.append( String( format: "%.f", Double( (remainedDays-3)*i )*0.01 ) )
                    }
                    for var i = 96; i <= 100; i++ {
                        animationArray.append( String( remainedDays-(100-i) ) )
                    }
                }

                stageIndexArray[0] = Int( Double(animationArray.count)*0.55 )
                stageIndexArray[1] = Int( Double(animationArray.count)*0.75 )
                stageIndexArray[2] = Int( Double(animationArray.count)*0.88 )
                stageIndexArray[3] = Int( Double(animationArray.count)*0.94 )
                stageIndexArray[4] = Int( Double(animationArray.count)*0.97 )
                stageIndexArray[5] = animationArray.count-1

                self.isDaysJumped = false
                self.frontRemainedDaysLabel.text = "0"
                self.checkDaysAnimation()
            }
            // currentProcess
            let currentProcess = countingClass.getCurrentProgress()
            let currentProcessString = String( format: "%.1f", currentProcess )
            if self.percentageLabel.text != currentProcessString {
                self.percentageLabel.text = currentProcessString
                self.isCircleDrawn = false
                self.checkCircleAnimation()
            }

        } else {
            // switch to settingViewController ?
            // tabBarController?.selectedIndex = 2
        }

    }

    func daysAddingEffect( timer: NSTimer ) {

        func updateLabel() {
            self.frontRemainedDaysLabel.text = self.animationArray[ self.animationIndex++ ]
        }

        switch( timer.userInfo! as! String ) {
            case "stage1":
                if animationIndex < stageIndexArray[0] {
                    updateLabel()
                } else {
                    timer.invalidate()
                    NSTimer.scheduledTimerWithTimeInterval( 0.02, target: self, selector: "daysAddingEffect:", userInfo: "stage2", repeats: true )
                }

            case "stage2":
                if animationIndex < stageIndexArray[1] {
                    updateLabel()
                } else {
                    timer.invalidate()
                    NSTimer.scheduledTimerWithTimeInterval( 0.04, target: self, selector: "daysAddingEffect:", userInfo: "stage3", repeats: true )
                }
            
            case "stage3":
                if animationIndex < stageIndexArray[2] {
                    updateLabel()
                } else {
                    timer.invalidate()
                    NSTimer.scheduledTimerWithTimeInterval( 0.08, target: self, selector: "daysAddingEffect:", userInfo: "stage4", repeats: true )
                }

            case "stage4":
                if animationIndex < stageIndexArray[3] {
                    updateLabel()
                } else {
                    timer.invalidate()
                    NSTimer.scheduledTimerWithTimeInterval( 0.16, target: self, selector: "daysAddingEffect:", userInfo: "stage5", repeats: true )
                }

            case "stage5":
                if animationIndex < stageIndexArray[4] {
                    updateLabel()
                } else {
                    timer.invalidate()
                    NSTimer.scheduledTimerWithTimeInterval( 0.32, target: self, selector: "daysAddingEffect:", userInfo: "stage6", repeats: true )
                }

            case "stage6":
                if animationIndex < stageIndexArray[5] {
                    updateLabel()
                } else {
                    timer.invalidate()
                    NSTimer.scheduledTimerWithTimeInterval( 0.5, target: self, selector: "daysAddingEffect:", userInfo: "stage7", repeats: true )
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

    func switchView() {

        if self.currentDisplay != "running" {
            
            let currentIsDay: Bool = ( self.currentDisplay == "day" ) ? true : false
            self.switchViewButton.backgroundColor = UIColor.whiteColor()
            self.imageOnSwitchBtn.image = UIImage(named: currentIsDay ? "date" : "chart" )
            self.currentDisplay = "runnung"

            UIView.animateWithDuration( 0.3, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.remainedView.alpha = currentIsDay ? 0 : 1
                self.pieChartView.alpha = currentIsDay ? 1 : 0
                self.switchViewButton.backgroundColor = UIColor(red: 103/255, green: 211/255, blue: 173/255, alpha: 1)
            }, completion: { finish in
                self.currentDisplay = currentIsDay ? "chart" : "day"
                if self.settingStatus {
                    if currentIsDay {
                        self.checkCircleAnimation()
                    } else {
                        self.checkDaysAnimation()
                    }
                }
            })

        }

    }

    func checkDaysAnimation() {
        if self.currentDisplay == "day" && self.isDaysJumped != true {
            NSTimer.scheduledTimerWithTimeInterval( 0.01, target: self, selector: Selector("daysAddingEffect:"), userInfo: "stage1", repeats: true )
            self.isDaysJumped = true
        }
    }

    func checkCircleAnimation() {
        if self.currentDisplay == "chart" && self.isCircleDrawn != true {
            self.circleView.animateCircle( (self.percentageLabel.text! as NSString).doubleValue*(0.01) )
            self.isCircleDrawn = true
        }
    }

    @IBAction func pressShareButton(sender: AnyObject) {

        let askAlertController = UIAlertController( title: "分享", message: "將製作分享圖片並分享至您的 Facebook，要繼續進行嗎？", preferredStyle: .Alert )
        let yesAction = UIAlertAction( title: "好", style: .Default, handler: {(action) -> Void in

            // START
            self.loadingView.hidden = false
            self.loadingActivity.startAnimating()

            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async( dispatch_get_global_queue( priority, 0 ) ) {
                // do some task
                sleep(1)
                // Create the UIImage
                // let mainWindowLayer = UIApplication.sharedApplication().keyWindow!.layer
                let mainWindowLayer = self.screenShotScale.layer
                UIGraphicsBeginImageContextWithOptions( CGSize( width: mainWindowLayer.frame.width, height: mainWindowLayer.frame.height ), true, UIScreen.mainScreen().scale )
                mainWindowLayer.renderInContext( UIGraphicsGetCurrentContext()! )
                let screenShot = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                // Save it to the camera roll
                UIImageWriteToSavedPhotosAlbum( screenShot, nil, nil, nil )

                dispatch_async( dispatch_get_main_queue() ) {
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
    func showImagesPickerView() {
        if UIImagePickerController.isSourceTypeAvailable( UIImagePickerControllerSourceType.SavedPhotosAlbum ) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false

            // STOP
            self.loadingView.hidden = true
            self.loadingActivity.stopAnimating()

            self.presentViewController( imagePicker, animated: true, completion: nil )
        }
    }

    // Once the User selects a photo, the following delegate method is called.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let photo = FBSDKSharePhoto()
        photo.image = info[UIImagePickerControllerOriginalImage] as! UIImage
        photo.userGenerated = true

        let content = FBSDKSharePhotoContent()
        content.photos = [photo]

        FBSDKShareDialog.showFromViewController( self, withContent: content, delegate: nil )

        dismissViewControllerAnimated( true, completion: nil )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}