//
//  RecommendationsViewController.swift
//  EcoBin
//
//  Created by Muhammad Hassaan Khawar on 2018-02-26.
//  Copyright © 2018 EcoBin. All rights reserved.
//

import UIKit

enum SliderState : Int {
    case Low = 1
    case Medium = 3
    case High = 5
}

class RecommendationsViewController: UIViewController {
    
    let fruitCNRatio = 25
    let vegetableCNRatio = 20
    let riceCNRatio = 15
    let meatCNRatio = 5

    @IBOutlet weak var startCompostingButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var recommendationsStackView: UIStackView!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    
    var compostBinSliderState : SliderState!
    var fruitSliderState : SliderState!
    var vegetableSliderState : SliderState!
    var breadSliderState : SliderState!
    var meatSliderState : SliderState!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        determineRecommendations()
    }
    
    func setupView() {
        Helper.setupView(view: startCompostingButton)
    }

    func determineRecommendations() {
        var waterRecommendation = ""
        var compostStaterRecommendation = ""
        
        switch compostBinSliderState {
        case .Low:
            waterRecommendation = "1 L of Water"
            compostStaterRecommendation = "1 Cup of Compost Starter"
        case .Medium:
            waterRecommendation = "2 L of Water"
            compostStaterRecommendation = "2 Cups of Compost Starter"
        case .High:
            waterRecommendation = "3 L of Water"
            compostStaterRecommendation = "3 Cups of Compost Starter"
        default:
            break
        }
        
        let numerator = (fruitSliderState.rawValue * fruitCNRatio) + (vegetableSliderState.rawValue * vegetableCNRatio) + (breadSliderState.rawValue * riceCNRatio) + (meatSliderState.rawValue * meatCNRatio)
        let denominator = fruitSliderState.rawValue + vegetableSliderState.rawValue + breadSliderState.rawValue + meatSliderState.rawValue

        let n = Double((30 * denominator - numerator)) / 120.0
        let poundsOfPaper = n * 0.5
        let pounds = String(format: "%.2f", poundsOfPaper)
        let paperRecommendation = "\(pounds) lb of Paper"
        
        addRecommendedItem(recommendation: waterRecommendation)
        addRecommendedItem(recommendation: compostStaterRecommendation)
        addRecommendedItem(recommendation: paperRecommendation)
    }
    
    func addRecommendedItem(recommendation: String) {
        let recommendedItemView = Bundle.main.loadNibNamed("RecommendedItemView", owner: self, options: nil)?.first as? RecommendedItemView
        recommendedItemView?.setTitle(title: recommendation)
        recommendationsStackView.addArrangedSubview(recommendedItemView!)
        
        stackViewHeightConstraint.constant = CGFloat(recommendationsStackView.arrangedSubviews.count*30);
        stackViewHeightConstraint.isActive = true
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startCompostingButtonPressed(_ sender: Any) {
        if let mainVC = presentingViewController?.presentingViewController as? MainViewController {
            mainVC.dismiss(animated: true, completion: nil)
            mainVC.setupForCompostingStarted()
        }
    }
}
