
//  DiscoveryViewController.swift
//  Tendy
//
//  Created by ATN on 21/08/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit
import FirebaseDatabase
import UserNotifications

class DiscoveryViewController: SuperRevealViewController ,UITableViewDelegate,UITableViewDataSource,PPKControllerDelegate{
    
    //var  imgNoList:UIImage=#imageLiteral(resourceName: "no_chats")
    var imgNoList:UIImage=UIImage(named: "no chat image".localized)!
    var imgAnimation:UIImage!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var discoveryRef:DatabaseReference!
    @IBOutlet weak var imgBackGround: UIImageView!
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var viewReveal: UIView!
    @IBOutlet weak var viewDiscoveryOff: UIView!
    @IBOutlet weak var lblDiscoveryOff1: UILabel!
    @IBAction func tapDiscoveryOff(_ sender: UIButton) {
        appDelegate.startDiscoveryTimer()
        viewDiscoveryOff.isHidden = true
    }
    
    var arrProfile=[Profile]()
    var selectedMember:Profile?
    
    override func notificationReceived(data: [String: AnyObject]) {
        if (data["sender"] as? String) != nil{
            LocalNoteficationManager.sharedInstance.addChatNotification(data: data)
        }
        print(data)
    }

    
    
    override func viewDidLoad() {
        viewAboveReveal = viewReveal
        super.viewDidLoad()
        imgBackGround.image = UIImage.gif(name: "animation".localized)!
        lblDiscoveryOff1.text = "DiscoveryOff title 1".localized
        setDiscoveryStatus()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
//        var h=self.tabBarController?.tabBar.frame.size.height
//        var y=(self.navigationController?.navigationBar.frame.size.height)!+UIApplication.shared.statusBarFrame.height
//        self.tabBarController?.tabBar.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.size.width, height: h!)
        
        imgBackGround.image = UIImage.gif(name: "animation".localized)!
        tblList.isHidden = true
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(DiscoveryViewController.discoveryList), userInfo: nil, repeats: false)
        if let tabBarController = self.tabBarController as? CustomTabBarController{
            tabBarController.setTabBarFrame()
        }
        self.view.layoutIfNeeded()
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["DiscoveryNotification"])
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["DiscoveryNotification"])
       //    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        } else {
            // Fallback on earlier versions
        }
        self.navigationController?.isNavigationBarHidden=false
        setDiscoveryStatus()
        //discoveryList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.discoveryRef != nil{
            self.discoveryRef.removeAllObservers()
        }
    }
    
    func setDiscoveryStatus(){
        if !AppDelegate.discovery{
            viewDiscoveryOff.isHidden = false
        }else{
            viewDiscoveryOff.isHidden = true
        }
    }
    
    override func  viewWillLayoutSubviews() {
        if let tabBarController = self.tabBarController as? CustomTabBarController{
            tabBarController.setTabBarFrame()
        }
        self.view.layoutIfNeeded()
    }
    
    // MARK: - tableView
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showAlertView(title: "inviteTitle".localized, msg: "inviteText".localized + arrProfile[indexPath.row].username + "?", okButtonTitle: "inviteYes".localized, otherButtonTitle: "inviteNo".localized, okFunction: {
            self.selectedMember=self.arrProfile[indexPath.row]
            self.performSegue(withIdentifier: C.Segue.ChatDescoverySegue, sender:self.selectedMember)
        }) {}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if arrProfile.count == 0{
//            imgBackGround.image = UIImage.gif(name: "animation".localized)!
//            tblList.isHidden = true
//        }
        return arrProfile.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ListCell = tableView.dequeueReusableCell(withIdentifier: C.Cell.ListCell) as! ListCell
        cell.setCell( arrProfile[indexPath.row])
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func discoveryList(){
        ServerController.getChatPartnersWithRef(function: serverReturnChatPartners)
        //ServerController.getChatPartners(function: serverReturnChatPartners)
        //ServerController.getProfiles(function: serverReturnProfies)
    }
    
    func serverReturnChatPartners(arr:[String:AnyObject]?, dataBaseRef:DatabaseReference?){
        discoveryRef = dataBaseRef
       // let arrAllChatPartners=ChatPartners().dicToArrayObject( dic: arr as? [String:[String:AnyObject]]) as! [ChatPartners]

        //tblList.isHidden = false
        if let partnersAroundJson = UserDefaults.standard.value(forKey: C.userDef.partnersAroundJson) as? [String : [String:AnyObject]]{
            var newPartnersAroundJson = [String : [String:AnyObject]]()
            //print("NOW: --- \(Date())")
            for partnerAroundJson in partnersAroundJson {
                if let partnerDic = arr?[partnerAroundJson.key]  as? [String:AnyObject]{
                    let partner = ChatPartners(dic: partnerDic)
                    if partner.status != State.blocked.rawValue{//no bloked
                        if partner.dateAdded != ""{//no forever
                            let dateDouble = Double(partner.dateAdded)
                            var seconds:Double=1
                            if(dateDouble != nil){
                                seconds=CHAT_VALIDITY_INTERVAL - (Date().timeIntervalSince1970*1000 + ServerController.currentmillisAppStart - dateDouble!)
                            }
                            if seconds <= 0 {
                                ServerController.deleteChatPartner(partnerId: partner.profile.identifier, function: { (err, ref) in
                                    print("delete partener and chat!")
                                })
                            }
                        }
                    }
                }else if let partnerDiscoveredDate = partnerAroundJson.value["discoveredDate"] as? Date {
                    //print("to show?? : \(partnerAroundJson.key)  name: \(partnerAroundJson.value["username"]!) --- \(partnerDiscoveredDate)")
                    let calendar = Calendar.current
                    let newDate = calendar.date(byAdding: .minute, value: 5, to: partnerDiscoveredDate)
                    if newDate! > Date(){
                        newPartnersAroundJson[partnerAroundJson.key] = partnerAroundJson.value
                    }
                }
            }
            UserDefaults.standard.set(newPartnersAroundJson, forKey: C.userDef.partnersAroundJson)
            UserDefaults.standard.synchronize()
            let arrProfile=Profile().dicToArrayObject( dic: newPartnersAroundJson) as! [Profile]
            
            self.arrProfile=arrProfile
            tblList.reloadData()
            if self.arrProfile.count > 0 {
                imgBackGround.image = nil
                tblList.isHidden = false
            }else{
                imgBackGround.image = UIImage.gif(name: "animation".localized)!
                tblList.isHidden = true
            }
        }
    }
    
    
    func serverReturnProfies(arr:[String:AnyObject]?){
        let arrProfile=Profile().dicToArrayObject( dic: arr as? [String:[String:AnyObject]]) as! [Profile]
        self.arrProfile=arrProfile
       // parentList.loadList()
    }
    // MARK: - Navigation
    
    //   In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier==C.Segue.ChatDescoverySegue)
        {
            let chatViewController:ChatViewController = segue.destination as! ChatViewController
            chatViewController.member=sender as! Profile
            chatViewController.state=State.haveInvited
           
            chatViewController.hidesBottomBarWhenPushed = true
        }
    }


}
