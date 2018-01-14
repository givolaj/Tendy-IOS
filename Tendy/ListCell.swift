//
//  ChatListCell.swift
//  Tendy
//
//  Created by ATN on 02/08/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell {
    
    @IBOutlet weak var lblNumNotifications: UILabel!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSomething: UILabel!
    @IBOutlet weak var lblProfileDetails: UILabel!
    @IBOutlet weak var imgProfile: RoundImageView!
    var timer=Timer()
    var chatPartners:ChatPartners!
    var profile:Profile!
    // var  fromChatList:Bool=Bool()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setCell(_ profileCellobj:SObject,num:Int?=0){
        (profileCellobj is Profile) ? setCellProfile(profileCellobj as! Profile) : setCellchatPartners(profileCellobj as! ChatPartners,num: num)
        
    }
    
    func setCellProfile(_ profile:Profile){
        self.profile=profile
        lblNumNotifications.isHidden=true
        lblTimer.isHidden=true
        lblDate.isHidden=true
        setlblTexts()
    }
    
    func setCellchatPartners(_ chatPartners:ChatPartners,num:Int?){
        let dateDouble = Double(chatPartners.dateAdded)
        if(dateDouble != nil){
            seconds=Int((CHAT_VALIDITY_INTERVAL - (Date().timeIntervalSince1970*1000 + ServerController.currentmillisAppStart - dateDouble!))/1000)
            if seconds <= 0{
                ServerController.deleteChatPartner(partnerId: chatPartners.profile.identifier, function: { (err, ref) in
                    print("delete partener and chat!")
                })

            }
           // lblDate.text =  chatPartners.dateAdded.stringToDateString()
        }

        //        let date = chatPartners.dateAdded.toDate()
        //        if(date != nil)
        //        {
        //            seconds=CHAT_VALIDITY_INTERVAL-Int(NSDate().timeIntervalSince(chatPartners.dateAdded.toDate()!))
        //            lblDate.text =  chatPartners.dateAdded.stringToDateString()
        //
        //        }
        self.chatPartners=chatPartners
        profile=chatPartners.profile
        setlblTexts()
        if(chatPartners.realProfile==false){
            lblName.text="nickname:".localized+lblName.text!
        }
        timer.invalidate()
        if(chatPartners.status != State.forever.rawValue){
            runTimer()
        }
        if(num != nil && num!>0){
            lblNumNotifications.text=num!.description
            setLblNotification()
        }
    }
    
    var seconds:Int=0
    
    func setLblNotification( ){
        lblNumNotifications.isHidden=false
        lblNumNotifications.border(borderWidth:3)
        //lblNumNotifications.round()
        lblNumNotifications.zoomInOut()
        
    }
    
    func  setlblTexts(){
        lblNumNotifications.isHidden=true
        lblSomething.text=profile.something
        //let gender = profile.gender == "man" ? "man".localized : "woman".localized
        let gender = profile.gender.localized
        lblProfileDetails.text=profile.age+" | "+gender+" | "+profile.profession
        lblName.text=profile.username
        imgProfile.setImgwithUrl(profile.imageUrl)
        lblTimer.text =  ""
        
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func updateTimer() {
        seconds -= 1
        if seconds == 0{
            ServerController.deleteChatPartner(partnerId: chatPartners.profile.identifier, function: { (err, ref) in
                print("delete partener and chat!")
            })
        }else if seconds > 0{
           lblTimer.text = timeString(time: TimeInterval(seconds))
        }
       // lblTimer.text = (seconds>0) ? timeString(time: TimeInterval(seconds)) : ""
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600 % 60
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}
