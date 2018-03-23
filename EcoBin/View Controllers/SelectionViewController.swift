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
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if let recommendationsVC = self.storyboard?.instantiateViewController(withIdentifier: "RecommendationsViewController") as? RecommendationsViewController {
            recommendationsVC.compostBinSliderState = getSliderState(slider: compostBinSlider)
            recommendationsVC.fruitSliderState = getSliderState(slider: fruitSlider)
            recommendationsVC.vegetableSliderState = getSliderState(slider: vegetableSlider)
            recommendationsVC.breadSliderState = getSliderState(slider: breadSlider)
            recommendationsVC.meatSliderState = getSliderState(slider: meatSlider)
            present(recommendationsVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func compostBinSliderChanged(_ sender: Any) {
        sliderValueChanged(slider: compostBinSlider)
    }
    
    @IBAction func fruitSliderChanged(_ sender: Any) {
        sliderValueChanged(slider: fruitSlider)
    }
    
    @IBAction func vegetableSliderChanged(_ sender: Any) {
        sliderValueChanged(slider: vegetableSlider)
    }
    
    @IBAction func breadSliderChanged(_ sender: Any) {
        sliderValueChanged(slider: breadSlider)
    }
    
    @IBAction func meatSliderChanged(_ sender: Any) {
        sliderValueChanged(slider: meatSlider)
    }
    
    func getSliderState(slider: UISlider) -> SliderState {
        if (slider.value < 0.33) {
            return .Low
        } else if (slider.value < 0.66) {
            return .Medium
        } else {
            return .High
        }
    }

    func sliderValueChanged(slider: UISlider) {
        if (slider.value < 0.33) {
            slider.setValue(0, animated: true)
        } else if (slider.value < 0.66) {
            slider.setValue(0.5, animated: true)
        } else {
            slider.setValue(1, animated: true)
        }
    }
}
