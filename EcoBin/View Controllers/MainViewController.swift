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
    
    var bleManager: BLEManagable = BLEManager()
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var moistureLabel: UILabel!
    @IBOutlet weak var compostingButton: UIButton!
    @IBOutlet weak var instructionsButton: UIButton!
    @IBOutlet weak var compostBetterButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var troubleshootingButton: UIButton!
    @IBOutlet weak var mainLabelView: UIView!
    @IBOutlet weak var smallLabelOne: UILabel!
    @IBOutlet weak var smallLabelTwo: UILabel!
    
    var currentCompostingState = CompostingState.Stopped
    var startTime = TimeInterval()
    var timer = Timer()
    
    override func viewDidLoad() {
        bleManager.addDelegate(self)
        setupInitialView()
        
        temperatureLabel.text = "ERROR"
    }
    
    deinit {
        bleManager.removeDelegate(self)
    }
    
    func setupInitialView() {
        setupButton(button: instructionsButton)
        setupButton(button: compostBetterButton)
        setupButton(button: settingsButton)
        setupButton(button: troubleshootingButton)
        mainLabelView.layer.borderWidth = 1;
        mainLabelView.layer.borderColor = UIColor.black.cgColor
        setupViewForCompostingStopped()
    }
    
    func setupButton(button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
    }
    
    func setupViewForCompostingStopped() {
        currentCompostingState = .Stopped
        compostingButton.setTitle("Start Composting", for: .normal)
        smallLabelOne.isHidden = true
        smallLabelTwo.text = "Device ID: ABCDE12345"
        stopTimer()
    }
    
    func setupViewForCompostingStarted() {
        currentCompostingState = .Started
        compostingButton.setTitle("Stop Composting", for: .normal)
        smallLabelOne.isHidden = false
        smallLabelOne.text = "Current Time: 00:00:00"
        smallLabelTwo.text = "Predicted Time: 12:00:00"
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
        smallLabelOne.text = "Current Time: \(strHours):\(strMinutes):\(strSeconds)"
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        bleManager.startScanning()
        bleManager.sendData()
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        bleManager.disconnectPeripheral()
    }
    
    @IBAction func compostingButtonPressed(_ sender: Any) {
        if (currentCompostingState == .Stopped) {
            let selectionVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectionViewController") as! SelectionViewController
            present(selectionVC, animated: true, completion: nil)
        } else {
            setupViewForCompostingStopped()
        }
    }
    
    @IBAction func instructionsButtonPressed(_ sender: Any) {
    }
    
    @IBAction func compostBetterButtonPressed(_ sender: Any) {
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
    }
    
    @IBAction func troubleshootingButtonPressed(_ sender: Any) {
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
//        print(dataString)
        if (dataString.containsIgnoringCase(find: "temp")) {
            self.temperatureLabel.text = dataString + "℃"
        } else if (dataString.containsIgnoringCase(find: "moisture")) {
            moistureLabel.text = dataString
        }
    }
}

extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}
