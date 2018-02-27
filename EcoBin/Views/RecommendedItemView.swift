//
//  RecommendedItemView.swift
//  EcoBin
//
//  Created by Muhammad Hassaan Khawar on 2018-02-26.
//  Copyright © 2018 EcoBin. All rights reserved.
//

import UIKit

class RecommendedItemView: UIView {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        
    }
    
    func setTitle(title: String, State state: Bool) {
        label.text = title
        label.alpha = state ? 1.0 : 0.5;
    }
    
}
