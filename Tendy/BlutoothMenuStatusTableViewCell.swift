//
//  BlutoothMenuStatusTableViewCell.swift
//  Tendy
//
//  Created by Shaya Fredman on 18/09/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit

class BlutoothMenuStatusTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setStatus(){
        if AppDelegate.discovery{
            lblStatus.text = "On".localized
            lblStatus.textColor = UIColor.exGreen
        }else{
            lblStatus.text = "Off".localized
            lblStatus.textColor = UIColor.exRed
        }
    }

}
