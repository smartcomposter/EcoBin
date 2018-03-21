//
//  Helper.swift
//  EcoBin
//
//  Created by Muhammad Hassaan Khawar on 2018-03-18.
//  Copyright © 2018 EcoBin. All rights reserved.
//

import UIKit

let LightGreen = UIColor(red: 201/255.0, green: 243/255.0, blue: 202/255.0, alpha: 1.0)
let DarkGreen = UIColor(red: 24/255.0, green: 166/255.0, blue: 43/255.0, alpha: 1.0)
let LightBlue = UIColor(red: 99/255.0, green: 169/255.0, blue: 252/255.0, alpha: 1.0)

extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}

class Helper : NSObject {
    static func setupView(view: UIView) {
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 10;
        view.clipsToBounds = true;
        view.backgroundColor = LightGreen
    }
}
