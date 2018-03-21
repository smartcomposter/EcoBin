//
//  SelectionViewController.swift
//  EcoBin
//
//  Created by Muhammad Hassaan Khawar on 2018-02-20.
//  Copyright © 2018 EcoBin. All rights reserved.
//

import UIKit

class SelectionViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var compostBinSlider: UISlider!
    @IBOutlet weak var fruitSlider: UISlider!
    @IBOutlet weak var vegetableSlider: UISlider!
    @IBOutlet weak var breadSlider: UISlider!
    @IBOutlet weak var meatSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        Helper.setupView(view: nextButton)
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func compostBinSliderChanged(_ sender: Any) {
        print("compostBinSlider: \(compostBinSlider.value)")
    }
    
    @IBAction func fruitSliderChanged(_ sender: Any) {
        print("fruitSlider: \(fruitSlider.value)")
    }
    
    @IBAction func vegetableSliderChanged(_ sender: Any) {
        print("vegetableSlider: \(vegetableSlider.value)")
    }
    
    @IBAction func breadSliderChanged(_ sender: Any) {
        print("breadSlider: \(breadSlider.value)")
    }
    
    @IBAction func meatSliderChanged(_ sender: Any) {
        print("meatSlider: \(meatSlider.value)")
    }
}
