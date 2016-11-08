//
//  ViewController.swift
//  SMSCount
//
//  Created by Eddie on 2015/8/8.
//  Copyright (c) 2015年 Wen. All rights reserved.
//

import UIKit

class CountViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // BACK - for ScreenShot
    @IBOutlet var backRemainedDaysLabel: UILabel!
    @IBOutlet var backRemainedDaysWord: UILabel!
    @IBOutlet var screenShotScale: UIView!

    // FRONT
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var switchViewButton: UIView!
    @IBOutlet var imageOnSwitchBtn: UIImageView!
    var currentDisplay: String

    @IBOutlet var contentView: UIView!
    // RemainedDays
    var countdownView = CountdownView()

    // currentProcess %
    var circleView: PercentageCircleView!
    var isCircleDrawn: Bool

    var calculateHelper = CalculateHelper()
    var loadingView = LoadingView() // LoaingView while taking screenshot

    var downloadFromParse: Bool // Download data from Parse in FriendsTableVC

    required init?(coder aDecoder: NSCoder) {
        self.currentDisplay = "day"
        self.isCircleDrawn = false
        self.downloadFromParse = false

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        let switchGesture = UITapGestureRecognizer(target: self, action: #selector(switchView))
        switchViewButton.addGestureRecognizer( switchGesture )
        switchViewButton.layer.borderColor = UIColor.white.cgColor
        switchViewButton.layer.borderWidth = 2

        countdownView = CountdownView(view: view)
        contentView.addSubview( countdownView )

        circleView = PercentageCircleView()
        contentView.addSubview( circleView )

        // Prepare background image
        let currentMonth = (Calendar.current as NSCalendar).components( .month, from: Date() ).month
        let currentMonthStr = currentMonth! < 10 ? "0" + String(describing: currentMonth) : String(describing: currentMonth)
        MonthlyImages( month: currentMonthStr ).setBackground( backgroundImage )

        checkSetting()

    }

    func checkSetting() {

        if calculateHelper.settingStatus {

            prepareTextAndNumbers()

        } else {
            // switch to settingViewController ?
            // tabBarController?.selectedIndex = 2
        }

    }

    func prepareTextAndNumbers() {

        let newRemainedDays = calculateHelper.getRemainedDays()

        // For screenshot
        backRemainedDaysWord.text = newRemainedDays < 0 ? "自由天數" : "剩餘天數"
        backRemainedDaysLabel.text = String( abs(newRemainedDays) )

        // Start animation
        countdownView.setRemainedDays( newRemainedDays )

        setTextOfProcess()

    }

    func setTextOfProcess() {

        // Set currentProcess
        circleView.setPercentage( calculateHelper.getCurrentProgress() )

        // If user doesn't want animation, do it at this moment
        if let userPreference = UserDefaults(suiteName: "group.EddieWen.SMSCount") {
            if userPreference.bool(forKey: "countdownAnimation") == false {
                checkCircleAnimation(true)
            }
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Check whether user logged in with FB in FriendsTVC
        if downloadFromParse {
            downloadFromParse = false

            isCircleDrawn = false
            let userPreference = UserDefaults(suiteName: "group.EddieWen.SMSCount")!
            userPreference.set( false, forKey: "dayAnimated" )

            // Reinit
            calculateHelper = CalculateHelper()
            checkSetting()
        }
    }

    func switchView() {

        let switch2chart: Bool = currentDisplay == "day" ? true : false
        switchViewButton.backgroundColor = UIColor.white
        imageOnSwitchBtn.image = UIImage(named: switch2chart ? "date" : "chart" )

        UIView.animate( withDuration: 0.3, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.countdownView.alpha = switch2chart ? 0 : 1
            self.circleView.alpha = switch2chart ? 1 : 0
            self.switchViewButton.backgroundColor = UIColor(red: 103/255, green: 211/255, blue: 173/255, alpha: 1)
        }, completion: { finish in
            self.currentDisplay = switch2chart ? "chart" : "day"
            if self.calculateHelper.settingStatus {
                if switch2chart {
                    self.checkCircleAnimation(false)
                }
            }
        })

    }

    func checkCircleAnimation( _ force: Bool ) {
        if force || (currentDisplay == "chart" && isCircleDrawn == false) {
            circleView.addPercentageCircle()
            isCircleDrawn = true
        }
    }

    @IBAction func pressShareButton(_ sender: AnyObject) {

        let askAlertController = UIAlertController( title: "分享", message: "將製作分享圖片並可分享至其他平台，要繼續進行嗎？", preferredStyle: .alert )
        let yesAction = UIAlertAction( title: "確定", style: .default, handler: { action in

            // START
            self.loadingView = LoadingView(center: CGPoint(x: self.view.frame.width/2, y: (self.view.frame.height-44)/2))
            self.view.addSubview(self.loadingView)
            let indicator = self.loadingView.subviews.first as! UIActivityIndicatorView
                indicator.startAnimating()

            DispatchQueue.global().async {
                // do some task

                // Create the UIImage
                // let mainWindowLayer = UIApplication.sharedApplication().keyWindow!.layer
                let mainWindowLayer = self.screenShotScale.layer
                UIGraphicsBeginImageContextWithOptions( CGSize( width: mainWindowLayer.frame.width, height: mainWindowLayer.frame.height ), true, UIScreen.main.scale )
                mainWindowLayer.render( in: UIGraphicsGetCurrentContext()! )
                let screenShot = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                // Save it to the camera roll
                UIImageWriteToSavedPhotosAlbum( screenShot!, nil, nil, nil )

                sleep(1)

                DispatchQueue.main.async {
                    // update some UI

                    // Show images picker
                    self.showImagesPickerView()
                }
            }

        })
        let noAction = UIAlertAction( title: "取消", style: .cancel, handler: nil )

        askAlertController.addAction( yesAction )
        askAlertController.addAction( noAction )

        present( askAlertController, animated: true, completion: nil )

    }

    // the following method is called to show the iOS image picker:
    func showImagesPickerView() {
        if UIImagePickerController.isSourceTypeAvailable( UIImagePickerControllerSourceType.savedPhotosAlbum ) {
            let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
                imagePicker.allowsEditing = false

            // Remove loading animation
            self.view.subviews.forEach() {
                if $0 is LoadingView {
                    $0.removeFromSuperview()
                }
            }

            present( imagePicker, animated: true, completion: nil )
        }
    }

    // Once the User selects a photo, the following delegate method is called.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        // Hide imagePickerController
        dismiss( animated: false, completion: nil )

        let postImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let activityViewController = UIActivityViewController(activityItems: [postImage], applicationActivities: nil)

        present(activityViewController, animated: true, completion: nil)

    }

}
