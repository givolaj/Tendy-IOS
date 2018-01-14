//
//  UnderLineTextFild.swift
//  Tendy
//
//  Created by ATN on 30/07/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit

@IBDesignable class UnderLineTextField: UITextField {
    
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: newValue!])
        }
    }
    
    
    var bottomBorderHeight : Float  = 1
    @IBInspectable var bottomBorderColor: UIColor? {
        get {
            return self.bottomBorderColor
        }
        set {
            self.borderStyle = .none
            self.layer.backgroundColor = UIColor.extLightlightGray.cgColor
            self.layer.masksToBounds = false
            self.layer.shadowColor = newValue?.cgColor
            self.layer.shadowOffset = CGSize(width: 0.0, height: Double(bottomBorderHeight))
            self.layer.shadowOpacity = bottomBorderHeight
            self.layer.shadowRadius = 0.0
        }
    }
    
    
    
}


