//
//  ChatPatnersViewController.swift
//  Tendy
//
//  Created by ATN on 21/08/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit
import UserNotifications


class ChatPatnersViewController: SuperRevealViewController,UITableViewDelegate,UITableViewDataSource{
    var chatBadge=[String:Int]()
    var displayBadges=[String:Int]()
   // var  imgNoList:UIImage=#imageLiteral(resourceName: "no_chats")
    var  imgNoList:UIImage=UIImage(named: "no chat image".localized)!
    @IBOutlet weak var imgBackGround: UIImageView!
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var viewReveal: UIView!
    var arrProfile=[ChatPartners]()
    var selectedChatPartner:ChatPartners?
    
    override func notificationReceived(data: [String: AnyObject]) {
        if (data["sender"] as? String) != nil{
                LocalNoteficationManager.sharedInstance.addChatNotification(data: data)
        }
        print(data)
    }
    
    override func viewDidLoad() {
        viewAboveReveal = viewReveal
        super.viewDidLoad()
        getChatPadge()
        
        getChatList()
        
    }
    
    func getChatPadge(){
        if(UserDefaults.standard.object(forKey: C.userDef.chatBadges) != nil){
            chatBadge=UserDefaults.standard.object(forKey: C.userDef.chatBadges) as! [String:Int]
            loadList()
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tabBarController = self.tabBarController as? CustomTabBarController{
            tabBarController.setTabBarFrame()
        }
        displayBadges=[String:Int]()
        setBadges()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for index in 0...arrProfile.count {
            if let cell = tblList.cellForRow(at: IndexPath(row: index, section: 0))as? ListCell{
                cell.timer.invalidate()
            }
        }
        super.viewWillDisappear(animated)
    }
    
    override func  viewWillLayoutSubviews() {
        if let tabBarController = self.tabBarController as? CustomTabBarController{
            tabBarController.setTabBarFrame()
        }
    }
    
    func loadList(){
        imgBackGround.image = nil
        self.view.bringSubview(toFront: tblList)
        //self.view.bringSubview(toFront: viewReveal)
        if(arrProfile.count==0){
            setNoPartners()
        }
        tblList.reloadData()
    }
    
    
    func setNoPartners(){
        imgBackGround.image = imgNoList
        self.view.bringSubview(toFront: imgBackGround)
       // self.view.bringSubview(toFront: viewReveal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getChatList(){
        showNativeActivityIndicator()
        ServerController.getChatPartners(function: serverReturnChats)
    }
    
//    func filterChatPartners(){
//        arrProfile =  arrProfile.filter { (chatPartner:ChatPartners) -> Bool in
//            let dateDouble = Double(chatPartner.dateAdded)
//            var seconds:Double=1
//            if(dateDouble != nil){
//                seconds=CHAT_VALIDITY_INTERVAL - (Date().timeIntervalSince1970*1000 + ServerController.currentmillisAppStart - dateDouble!)
//            }
////            if seconds <= 0 {
////                ServerController.deleteChatPartner(partnerId: chatPartner.profile.identifier, function: { (err, ref) in
////                    print("finish")
////                })
////            }
//            return  chatPartner.status != State.blocked.rawValue&&seconds>0//||chatPartner.status == State.forever.rawValue
//        }
//    }
    
    func filterChatPartners()-> [ChatPartners]{
        var arrProfileFilter = [ChatPartners]()
        for partner in arrProfile{
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
                    }else{
                        arrProfileFilter.append(partner)//haveInvited, invited, connected
                    }
                }else{
                    arrProfileFilter.append(partner)//forever
                }
            }
        }
        return arrProfileFilter
    }
    
    
    func serverReturnChats(arr:[String:AnyObject]?){
        hideNativeActivityIndicator()
        arrProfile=ChatPartners().dicToArrayObject( dic: arr as? [String:[String:AnyObject]]) as! [ChatPartners]
        arrProfile = filterChatPartners()
        arrProfile.sort { (c1, c2) -> Bool in
            //if( c1.lastVisited.toDate() != nil && c2.lastVisited.toDate() != nil){
                return c1.lastVisited>c2.lastVisited
            //}
            //return  true
        }
//        arrProfile.sort { (c1, c2) -> Bool in
//            if( c1.dateAdded.toDate() != nil && c2.dateAdded.toDate() != nil){
//                return c1.dateAdded.toDate()!>c2.dateAdded.toDate()!
//            }
//            return  true
//        }
      //  filterChatPartners()
        loadList()
        setBadges()
    }
    
    func  setBadges(){
        for partner in arrProfile{
            getChatsNum(chatPartner: partner)
        }
    }
    
    func getChatsNum(chatPartner:ChatPartners){
        //ServerController.getChats(buddy:chatPartner.profile.identifier,function: serverReturn)
        ServerController.getOnceChats(buddy: chatPartner.profile.identifier, function: serverReturn)
    }
    
    func serverReturn(arr:[String:AnyObject]?,error:Error?){
        let list = Chat().dicToArrayObject( dic: arr as? [String:[String:AnyObject]]) as! [Chat]
        var chatProfile=""
        for chat in list{
            if(chat.sender != ServerController.currentUserId){
                chatProfile=chat.sender
            }
        }
        getChatPadge()
        let minus=((chatBadge[chatProfile]) != nil) ? chatBadge[chatProfile]! : 0
        displayBadges[chatProfile]=list.count-minus
        //  saveUserDef()
        self.loadList()
    }
    
    func saveUserDef(){
        // UserDefaults.standard.set(chatBadge, forKey: C.userDef.chatBadges)
        // UserDefaults.standard.synchronize()
    }
    // MARK: - tableView
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedChatPartner = arrProfile[indexPath.row]
        displayBadges[arrProfile[indexPath.row].profile.identifier]=0
        performSegue(withIdentifier: C.Segue.ChatSegue, sender:selectedChatPartner)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrProfile.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ListCell = tableView.dequeueReusableCell(withIdentifier: C.Cell.ListCell) as! ListCell
        cell.setCell( arrProfile[indexPath.row],num:displayBadges[arrProfile[indexPath.row].profile.identifier])
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        (cell as! ListCell).timer.invalidate()
//    }
    
    
    // MARK: - Navigation
    
    //   In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        if segue.identifier==C.Segue.ChatListContainerSegue {
        //            parentList=segue.destination as! ListViewController
        //            setList()
        //        }
        if(segue.identifier==C.Segue.ChatSegue)
        {
            let chatViewController:ChatViewController = segue.destination as! ChatViewController
            chatViewController.member=(sender as! ChatPartners).profile
            chatViewController.state=State(rawValue: (sender as! ChatPartners).status)
            chatViewController.myChatPartner=sender as! ChatPartners
            
            chatViewController.hidesBottomBarWhenPushed = true
        }
    }
    
    
}
