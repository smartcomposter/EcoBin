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
    
    func setTitle(title: String) {
        label.text = title
    }
    
}
