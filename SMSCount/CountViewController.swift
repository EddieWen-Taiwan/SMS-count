//
//  ViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/8.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit
import Parse

class CountViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // <<Back>> - about ScreenShot
    @IBOutlet var backRemainedDaysLabel: UILabel!
    @IBOutlet var backRemainedDaysWord: UILabel!
    @IBOutlet var screenShotScale: UIView!

    // <<Front>>
    @IBOutlet var backgroundImage: UIImageView!
    var currentMonthStr = "00"
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
//    var isUserRetired: Bool = false

    // currentProcess %
    @IBOutlet var pieChartView: UIView!
    @IBOutlet var percentageLabel: UILabel!
    var isCircleDrawn: Bool = false

    // LoaingView after screenshot
    @IBOutlet var loadingView: UIView!
    @IBOutlet var loadingActivity: UIActivityIndicatorView!

    var calculateHelper = CalculateHelper()
    var circleView: PercentageCircleView!

    var screenHeight = UIScreen.mainScreen().bounds.height
    var screenWidth = UIScreen.mainScreen().bounds.width

    var settingStatus: Bool = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let currentMonth = NSCalendar.currentCalendar().components( .Month, fromDate: NSDate() ).month
        currentMonthStr = currentMonth < 10 ? "0" + String(currentMonth) : String(currentMonth)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        let switchGesture = UITapGestureRecognizer(target: self, action: "switchView")
        self.switchViewButton.addGestureRecognizer( switchGesture )
        self.switchViewButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.switchViewButton.layer.borderWidth = 2

        circleView = PercentageCircleView( view: self.pieChartView )
        self.pieChartView.addSubview( circleView )

        _ = MonthlyImages( month: currentMonthStr, background: self.backgroundImage )

        self.settingStatus = calculateHelper.isSettingAllDone()

        if self.settingStatus {

            calculateHelper.updateDate()

            var newRemainedDays = calculateHelper.getRemainedDays()
            if newRemainedDays < 0 {
                newRemainedDays *= (-1)
                self.backRemainedDaysWord.text = "自由天數"
                self.frontRemainedDaysWord.text = "自由天數"
            } else {
                self.backRemainedDaysWord.text = "剩餘天數"
                self.frontRemainedDaysWord.text = "剩餘天數"
            }
            self.backRemainedDaysLabel.text = String( newRemainedDays )

            // Set remainedDays
            let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!
            if userPreference.boolForKey("dayAnimated") {
                // Animation was completed
                self.frontRemainedDaysLabel.text = String( newRemainedDays )
            } else {
                // Animation setting
                animationIndex = 0
                animationArray.removeAll(keepCapacity: false) // Maybe it should be true
                if newRemainedDays < 100 {
                    for var i = 0; i <= newRemainedDays; i++ {
                        animationArray.append( String(i) )
                    }
                } else {
                    for var i = 1; i <= 95; i++ {
                        animationArray.append( String( format: "%.f", Double( (newRemainedDays-3)*i )*0.01 ) )
                    }
                    for var i = 96; i <= 100; i++ {
                        animationArray.append( String( newRemainedDays-(100-i) ) )
                    }
                }

                let arrayLength = animationArray.count
                stageIndexArray[0] = Int( Double(arrayLength)*0.55 )
                stageIndexArray[1] = Int( Double(arrayLength)*0.75 )
                stageIndexArray[2] = Int( Double(arrayLength)*0.88 )
                stageIndexArray[3] = Int( Double(arrayLength)*0.94 )
                stageIndexArray[4] = Int( Double(arrayLength)*0.97 )
                stageIndexArray[5] = arrayLength-1

                self.frontRemainedDaysLabel.text = "0"
                NSTimer.scheduledTimerWithTimeInterval( 0.01, target: self, selector: Selector("daysAddingEffect:"), userInfo: "stage1", repeats: true )
            }

            // Set currentProcess
            let currentProcess = calculateHelper.getCurrentProgress()
            let currentProcessString = String( format: "%.1f", currentProcess )
            self.percentageLabel.text = currentProcessString

        } else {
            // switch to settingViewController ?
            // tabBarController?.selectedIndex = 2
            
            self.percentageLabel.text = "0"
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
                    NSTimer.scheduledTimerWithTimeInterval( 0.24, target: self, selector: "daysAddingEffect:", userInfo: "stage6", repeats: true )
                }

            case "stage6":
                if animationIndex < stageIndexArray[5] {
                    updateLabel()
                } else {
                    timer.invalidate()
                    NSTimer.scheduledTimerWithTimeInterval( 0.32, target: self, selector: "daysAddingEffect:", userInfo: "stage7", repeats: true )
                }

            case "stage7":
                if animationIndex == stageIndexArray[5] {
                    updateLabel()
                } else {
                    timer.invalidate()

                    let userPreference = NSUserDefaults(suiteName: "group.EddieWen.SMSCount")!
                    userPreference.setBool( true, forKey: "dayAnimated" )
                }

            default:
                break;
        }
    }

    func switchView() {

        let switch2chart: Bool = ( self.currentDisplay == "day" ) ? true : false
        self.switchViewButton.backgroundColor = UIColor.whiteColor()
        self.imageOnSwitchBtn.image = UIImage(named: switch2chart ? "date" : "chart" )

        UIView.animateWithDuration( 0.3, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.remainedView.alpha = switch2chart ? 0 : 1
            self.pieChartView.alpha = switch2chart ? 1 : 0
            self.switchViewButton.backgroundColor = UIColor(red: 103/255, green: 211/255, blue: 173/255, alpha: 1)
        }, completion: { finish in
            self.currentDisplay = switch2chart ? "chart" : "day"
            if self.settingStatus {
                if switch2chart {
                    self.checkCircleAnimation()
                }
            }
        })

    }

    func checkCircleAnimation() {
        if self.currentDisplay == "chart" && self.isCircleDrawn == false {
            self.circleView.animateCircle( (self.percentageLabel.text! as NSString).doubleValue*(0.01) )
            self.isCircleDrawn = true
        }
    }

    @IBAction func pressShareButton(sender: AnyObject) {

        let askAlertController = UIAlertController( title: "分享", message: "將製作分享圖片並可分享至其他平台，要繼續進行嗎？", preferredStyle: .Alert )
        let yesAction = UIAlertAction( title: "確定", style: .Default, handler: {(action) -> Void in

            // START
            self.loadingView.hidden = false
            self.loadingActivity.startAnimating()

            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async( dispatch_get_global_queue( priority, 0 ) ) {
                // do some task

                // Create the UIImage
                // let mainWindowLayer = UIApplication.sharedApplication().keyWindow!.layer
                let mainWindowLayer = self.screenShotScale.layer
                UIGraphicsBeginImageContextWithOptions( CGSize( width: mainWindowLayer.frame.width, height: mainWindowLayer.frame.height ), true, UIScreen.mainScreen().scale )
                mainWindowLayer.renderInContext( UIGraphicsGetCurrentContext()! )
                let screenShot = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                // Save it to the camera roll
                UIImageWriteToSavedPhotosAlbum( screenShot, nil, nil, nil )

                sleep(1)

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

            // Stop loading animation
            self.loadingView.hidden = true
            self.loadingActivity.stopAnimating()

            self.presentViewController( imagePicker, animated: true, completion: nil )
        }
    }

    // Once the User selects a photo, the following delegate method is called.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        // Hide imagePickerController
        dismissViewControllerAnimated( false, completion: nil )

        let postImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let activityViewController = UIActivityViewController(activityItems: [postImage], applicationActivities: nil)

        self.presentViewController(activityViewController, animated: true, completion: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}