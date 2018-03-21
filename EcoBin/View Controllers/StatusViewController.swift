//
//  StatusViewController.swift
//  EcoBin
//
//  Created by Muhammad Hassaan Khawar on 2018-03-19.
//  Copyright © 2018 EcoBin. All rights reserved.
//

import UIKit

class StatusViewController: UIViewController {
    
    @IBOutlet weak var finishCompostingButton: UIButton!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var completionTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        Helper.setupView(view: finishCompostingButton)
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func finishCompostingButtonPressed(_ sender: Any) {
        if let mainVC = presentingViewController as? MainViewController {
            mainVC.setupForCompostingStopped();
        }
        dismiss(animated: true, completion: nil)
    }
    
}
