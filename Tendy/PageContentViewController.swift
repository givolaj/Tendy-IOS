//
//  PageContentViewController.swift
//  Tendy
//
//  Created by ATN on 30/07/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblLine: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCenterText: UILabel!
    var imageFile = ""
    var titleText = ""
    var centerText = ""
    var textColor :UIColor!
    var lineColor :UIColor!
    var pageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        img.image=UIImage(named: imageFile)
        lblTitle.text=titleText
        lblCenterText.text=centerText
        lblTitle.textColor=textColor
        lblCenterText.textColor=textColor
        lblLine.backgroundColor=lineColor
        lblTitle.txtRows()
        lblCenterText.txtRows()
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            lblCenterText.font = lblCenterText.font.withSize(14)
            lblTitle.font = lblTitle.font.withSize(25)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
}
