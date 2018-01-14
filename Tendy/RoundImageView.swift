//
//  RoundImageView.swift
//  Tendy
//
//  Created by ATN on 08/08/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit

class RoundImageView: UIImageView {
    
    
    
    @IBInspectable var isRound : Bool = true {
        didSet {
            if(isRound)
            {
                round()
            }
        }
    }
    @IBInspectable var borderColor : UIColor = UIColor.clear {
        didSet {
            border(borderColor)
        }
    }
    
    
    
    
    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            cornerRadius(cornerRadius)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        round()
    }
    
    func setupView()
    {
        round()
    }
    
    
    
}
