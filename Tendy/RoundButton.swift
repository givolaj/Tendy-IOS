
class RoundShadowView: UIImageView {
    
    var shadowLayer: CAShapeLayer=CAShapeLayer()
    var insert=false

    override func layoutSubviews() {
        super.layoutSubviews()
     //   if shadowLayer == nil {
            //insert=true
       // }
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
            shadowLayer.shadowColor = UIColor.darkGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            shadowLayer.shadowOpacity = 0.8
            shadowLayer.shadowRadius = 2
           if(insert==false)
           {
            layer.insertSublayer(shadowLayer, at: 0)
               insert=true
  
       }
        
       

    
    }
    
}

import UIKit

@IBDesignable class RoundButton: UIButton {
    
    
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
        // txtRows()
        round()
    }
}
