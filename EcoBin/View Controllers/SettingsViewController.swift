//
//  SettingsViewController.swift
//  EcoBin
//
//  Created by Muhammad Hassaan Khawar on 2018-03-09.
//  Copyright © 2018 EcoBin. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        closeButton.layer.borderWidth = 1
        closeButton.layer.borderColor = UIColor.black.cgColor
        closeButton.layer.cornerRadius = closeButton.frame.size.width/2
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
