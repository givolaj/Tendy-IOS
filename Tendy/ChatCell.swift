//
//  ChatCell.swift
//  Tendy
//
//  Created by ATN on 02/08/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit
import NSDate_TimeAgo
class ChatCell: UITableViewCell {
    
    @IBOutlet weak var wImgConst: NSLayoutConstraint!
    @IBOutlet weak var hImgConst: NSLayoutConstraint!
    @IBOutlet weak var imgLeadConst: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var imgBackGround: RoundShadowView!
    var chat:Chat?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateConstraint() {
        if(imgLeadConst != nil)
        {
            imgLeadConst.isActive=false
        }
        
        if(trailingConstraint != nil && self.constraints.contains(trailingConstraint))
        {
            trailingConstraint.isActive=false
            self.removeConstraint(trailingConstraint)
        }
        if(leadingConstraint != nil && self.constraints.contains(leadingConstraint))
        {
            leadingConstraint.isActive=false
            self.removeConstraint(leadingConstraint)
        }
        
        (!isme) ? leading():traling()
        
    }
    var isme:Bool
    {
        return  chat?.sender==ServerController.currentUserId
        
    }
    func leading()
    {
        leadingConstraint = NSLayoutConstraint(item: imgBackGround, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 4)
        
        leadingConstraint.isActive=true
        self.addConstraint(leadingConstraint!)
    }
    
    func traling()
    {
        trailingConstraint  = NSLayoutConstraint(item: imgBackGround, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -4)
        trailingConstraint.isActive=true
        self.addConstraint(trailingConstraint!)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setCell(chat:Chat)
    {
        
        selectionStyle = .none
        self.chat=chat
        if (chat.text.range(of:"wants_to_stay_in_touch".localized) != nil){
            //imgBackGround.shadowLayer.fillColor = UIColor.colorWithHexString("E6E6E6").cgColor
            imgBackGround.shadowLayer.fillColor = UIColor.chatSpecial.cgColor
        }else{
            //imgBackGround.shadowLayer.fillColor =  (isme) ? UIColor.white.cgColor :  UIColor.exGreenBubble.cgColor
            imgBackGround.shadowLayer.fillColor =  (isme) ? UIColor.chatMe.cgColor :  UIColor.chatPartner.cgColor
        }
        img.cornerRadius(8, isCornerNum: true)
        lblText.text=chat.text
        lblText.txtRows()
        lblDate.text=chat.dateAdded.stringToDate()?.timeAgo()
        updateConstraint()
        //img.setImgwithUrl(chat.imageUrl)
        
        img.setImgwithUrl(chat.imageUrl, toSave: true,imageName:chat.key)
        //img.setImgwithUrl(chat.imageUrl, contentMode: .scaleToFill)
       // hImgConst.constant =  (chat.imageUrl != "") ? 100:3
//        hImgConst.constant =  (chat.imageUrl != "") ? 150:3
        hImgConst.constant =  (chat.imageUrl != "") ? 230:3
        wImgConst.constant=hImgConst.constant
        
        
    }
}
