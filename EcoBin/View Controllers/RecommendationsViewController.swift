//
//  RecommendationsViewController.swift
//  EcoBin
//
//  Created by Muhammad Hassaan Khawar on 2018-02-26.
//  Copyright © 2018 EcoBin. All rights reserved.
//

import UIKit

class RecommendationsViewController: UIViewController {
    
    let recommendedItems : [String: Int] = ["10g Compost Starter" : 1,
                                           "1.5L Sawdust" : 1,
                                           "2L Water" : 1,
                                           "More Vegetables" : 0,
                                           "More Fruits" : 0]

    @IBOutlet weak var startCompostingButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var recommendationsStackView: UIStackView!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addRecommendedItems()
    }
    
    func setupView() {
        Helper.setupView(view: startCompostingButton)

    }

    func addRecommendedItems() {
        let sortedRecommendedItems = recommendedItems.sorted{ $0.value > $1.value }

        for (itemName, active) in sortedRecommendedItems {
            let recommendedItemView = Bundle.main.loadNibNamed("RecommendedItemView", owner: self, options: nil)?.first as? RecommendedItemView
            recommendedItemView?.setTitle(title: itemName, State: Bool(truncating: active as NSNumber))
            recommendationsStackView.addArrangedSubview(recommendedItemView!)
        }
        
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
