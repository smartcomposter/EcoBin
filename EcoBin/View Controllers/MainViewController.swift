//
//  MainViewController.swift
//  EcoBin
//
//  Created by Muhammad Hassaan Khawar on 2018-01-29.
//  Copyright © 2018 EcoBin. All rights reserved.
//

import UIKit

enum CompostingState {
    case Started
    case Stopped
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var compostingButton: UIButton!
    @IBOutlet weak var instructionsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var troubleshootingButton: UIButton!
    @IBOutlet weak var mainLabelView: UIView!
    @IBOutlet weak var smallLabelOne: UILabel!
    @IBOutlet weak var smallLabelTwo: UILabel!

    var bleManager: BLEManagable = BLEManager()
    var statusVC : StatusViewController?
    var startTime = TimeInterval()
    var timer = Timer()
    var statusBarShouldBeHidden = false
    
    var currentCompostingState : CompostingState = .Stopped {
        didSet {
            if (currentCompostingState == .Stopped) {
                bleManager.sendData(text: "0")
            } else {
                bleManager.sendData(text: "1")
            }
        }
    }
    
    override func viewDidLoad() {
        bleManager.addDelegate(self)
        setupInitialView()
        
        temperatureLabel.text = "ERROR"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateStatusBar(shouldHide: false)
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    deinit {
        bleManager.removeDelegate(self)
    }
    
    func setupInitialView() {
        Helper.setupView(view: instructionsButton)
        Helper.setupView(view: settingsButton)
        Helper.setupView(view: troubleshootingButton)
        Helper.setupView(view: mainLabelView)
        
        smallLabelTwo.text = "Device ID: ABCDE12345"
        setupForCompostingStopped()
    }
    
    func setupForCompostingStopped() {
        currentCompostingState = .Stopped
        compostingButton.setTitle("Start Composting", for: .normal)
        smallLabelOne.isHidden = true
        stopTimer()
    }
    
    func setupForCompostingStarted() {
        bleManager.startScanning()
        currentCompostingState = .Started
        compostingButton.setTitle("View Status", for: .normal)
        smallLabelOne.isHidden = false
        smallLabelOne.text = "Elapsed Time: 00:00:00"
        startTimer()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    @objc func updateTimer() {
        //Find the difference between current time and start time.
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        var elapsedTime: TimeInterval = currentTime - startTime
        
        //calculate the hours in elapsed time.
        let hours = UInt8(elapsedTime / 60.0 / 60.0)
        elapsedTime -= (TimeInterval(hours) * 60 * 60)
        
        //calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
//        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        let strHours = String(format: "%02d", hours)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
//        let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        smallLabelOne.text = "Elapsed Time: \(strHours):\(strMinutes):\(strSeconds)"
        if (statusVC != nil) {
            statusVC?.elapsedTimeLabel.text = "\(strHours):\(strMinutes):\(strSeconds)"
        }
    }
    
    func updateStatusBar(shouldHide : Bool) {
        statusBarShouldBeHidden = shouldHide
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        bleManager.startScanning()
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        bleManager.disconnectPeripheral()
    }
    
    @IBAction func compostingButtonPressed(_ sender: Any) {
        bleManager.startScanning()
        if (currentCompostingState == .Stopped) {
            if let selectionVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectionViewController") as? SelectionViewController {
                present(selectionVC, animated: true, completion: nil)
            }
        } else {
            if (statusVC == nil) {
                if let tempStatusVC = self.storyboard?.instantiateViewController(withIdentifier: "StatusViewController") as? StatusViewController {
                    statusVC = tempStatusVC
                }
            }
            if (statusVC != nil) {
                present(statusVC!, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func instructionsButtonPressed(_ sender: Any) {
        if let instructionsVC = self.storyboard?.instantiateViewController(withIdentifier: "InstructionsViewController") as? InstructionsViewController {
            present(instructionsVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        if let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController {
            present(settingsVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func troubleshootingButtonPressed(_ sender: Any) {
        if let webVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController {
            updateStatusBar(shouldHide: true)
            webVC.urlString = "https://smartcomposter.github.io/#troubleshooting"
            present(webVC, animated: true, completion: nil)
        }
    }
}

// MARK: BLEManagerDelegate
extension MainViewController: BLEManagerDelegate {
    
    func bleManagerDidConnect(_ manager: BLEManagable) {
        self.temperatureLabel.textColor = UIColor.green
    }
    func bleManagerDidDisconnect(_ manager: BLEManagable) {
        self.temperatureLabel.textColor = UIColor.red
    }
    func bleManager(_ manager: BLEManagable, receivedDataString dataString: String) {
        if (dataString.containsIgnoringCase(find: "temp")) {
            let data = dataString.replacingOccurrences(of: "temp: ", with: "")
            self.temperatureLabel.text = dataString + "℃"
            if (statusVC != nil) {
                statusVC?.temperatureLabel.text = data + "℃"
            }
        }
    }
}
