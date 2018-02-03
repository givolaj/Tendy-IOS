//
//  ChatViewController.swift
//  Tendy
//
//  Created by ATN on 02/08/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SWRevealViewController
import FontAwesome_swift
import UserNotifications

class ChatViewController: SuperViewController,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,SendImageDelegate {
    
    @IBOutlet weak var heightNavigationViewCons: NSLayoutConstraint!
    @IBOutlet weak var topHelperViewConst: NSLayoutConstraint!
    @IBOutlet weak var topNavConst: NSLayoutConstraint!
    var tblMenuTag=111
    var state:State?
    var partnerChatPartner:ChatPartners?
    var myChatPartner:ChatPartners?
    var myProfileInPartner:ChatPartners?
    var arrMenu=["profileShown".localized,"enablePrivteProfile".localized,"block".localized]
    var tblMenu=UITableView()
    var arrChats=[Chat]()
    var member:Profile!//הפרטנר
    var timer:Timer=Timer()
    var chatBadge=[String:Int]()
    var viewHeight:CGFloat = 0.0
    var lastChat:Chat!
    var isKeyboardOpen = false
    var viewCurrentFrame = CGRect()
    var txtMessagePlaceHolder = "write_a_msg".localized
    var chatRef:DatabaseReference!
    var partnerRef:DatabaseReference!
    var sendImage = false
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var lblSomethingPartnerProfile: UILabel!
    @IBOutlet weak var lblNamePartnerProfile: UILabel!
    @IBOutlet weak var lblTextPartnerProfile: UILabel!
    @IBOutlet weak var imgPartnerProfile: RoundImageView!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var lblSomthingDisplayForPartner: UILabel!
    @IBOutlet weak var viewDisplayForPartner: UIView!
    @IBOutlet weak var viewMyProfile: UIView!
    @IBOutlet weak var lblNameDisplayForPartner: UILabel!
    @IBOutlet weak var lblTextDisplayForPartner: UILabel!
    @IBOutlet weak var imgDisplayForPartner: UIImageView!
    @IBOutlet weak var btnTimerText: UIButton!
    @IBOutlet weak var btnTimer: UIButton!
    @IBOutlet weak var viewTimer: UIView!
    @IBOutlet weak var widthContLblTimer: NSLayoutConstraint!
    @IBOutlet weak var topConst: NSLayoutConstraint!
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    
    @IBOutlet weak var txtVMessageText: UITextView!
    @IBOutlet weak var btnSend: RoundButton!
    @IBOutlet weak var txtVMessage: UITextView!
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var firstChatEnableView: UIView!
    @IBOutlet weak var btnOkEnable: UIButton!
    @IBOutlet weak var lblWantsToTalk: UILabel!
    var navigationViewHeight:CGFloat = 0.0
    var screenWidth = UIScreen.main.bounds.width
    
    var firstGetPatrner = true
    var partnerDeleted = false
    
    var longPressRecognizerDeleteMsg:UILongPressGestureRecognizer!
    
    var  toSendValues: Bool{
        //return txtVMessageText.text.isEmpty && changedImage==false ?  false : true
        return (txtVMessageText.textColor == UIColor.lightGray || txtVMessageText.text.isEmpty) && changedImage==false ?  false : true
    }
    
    var  constTop:CGFloat{
        return (viewTimer.isHidden) ? 0 :viewTimer.frame.size.height
    }
    
    
    @IBAction func btnBackClick(_ sender: Any) {
        back()
    }
    
    @IBAction func btnMenuClick(_ sender: Any) {
        menu()
    }
    
    @IBAction func btnShowPartnerProfileClick(_ sender: UIButton) {
        if myChatPartner == nil{
            self.firstGetPatrner = true
        }
        let imageVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowImageViewController") as! ShowImageViewController
        imageVC.urlImage = member.imageUrl
        self.present(imageVC, animated: false, completion: nil)
    }
    //MARK: enableChat
    
    @IBAction func btnOkEnableClick(_ sender: Any) {
        ServerController.saveTwoPartnersStatus(partnerId: member.identifier, newStatus: State.connected.rawValue) { (error, ref) in
            if(error == nil){
                self.state = .connected
                self.txtMessagePlaceHolder = "write_a_msg".localized
                self.firstChatInvitedSet()
            }
        }
        //        ServerController.saveChatPartner( profile: member, status: State.connected) { (error, ref) in
        //            if(error == nil){
        //                self.state = .connected
        //                self.firstChatInvitedSet()
        //            }
        //        }
    }
    
    func firstChatInvitedSet(){
        firstChatEnableView.isHidden=( state == .invited ) ? false : true
        lblWantsToTalk.text = member.gender == Gender.woman.description ? member.username + " " + "wants_female".localized + " "  + "wants_to_chat".localized : member.username + " " + "wants_male".localized + " " + "wants_to_chat".localized
        // lblWantsToTalk.text = member.username + " " + "wants to chat with you".localized
        tblList.isHidden = !firstChatEnableView.isHidden
        txtVMessageText.isEditable=firstChatEnableView.isHidden
        btnCamera.isEnabled=firstChatEnableView.isHidden
    }
    
    override func notificationReceived(data: [String: AnyObject]) {
        if let senderId = data["sender"] as? String{
            if senderId != member.identifier{
                LocalNoteficationManager.sharedInstance.addChatNotification(data: data)
            }
        }
        //  {"text":"עןהלבו","key":"-KutEzRPTOT9RIL0P-ss","dateAdded":"1506346529369","imageUrl":"","sender":"ijEIzYS7iAXg7SfbYzS7QWfUisI2","deleted":""}
        print(data)
    }
    
    //MARK: keyboard
    
    override func setviewUp(_ kbSize: CGFloat) {

        //        navigationViewHeight = (self.view!.frame.size.height)*0.2 - (self.view!.frame.size.height-kbSize)*0.2
        navigationViewHeight = (viewHeight)*0.2 - (viewHeight-kbSize)*0.2
        
        //UIView.animate(withDuration: 1) {
        //        self.view!.frame = CGRect(x: self.view!.frame.origin.x, y: 0, width: self.view!.frame.size.width, height: self.view!.frame.size.height-kbSize)
         viewCurrentFrame = CGRect(x: self.view!.frame.origin.x, y: 0, width: self.view!.frame.size.width, height: viewHeight-kbSize)
        self.view!.frame = viewCurrentFrame
        self.heightNavigationViewCons.constant = self.navigationViewHeight
        //    }
        // UIView.commitAnimations()
        
        tblMenu.isHidden=true
        //  topConst.constant=kbSize
        
        if(arrChats.count>0){
            DispatchQueue.main.async {
                self.tblList.scrollToRow(at: IndexPath(item:self.arrChats.count-1, section: 0), at: .bottom, animated: false)
                //self.tblList.scrollToBottom()
                // self.tblList.scrollToRow(at: IndexPath(item:self.arrChats.count-1, section: 0), at: .bottom, animated: true)
                
            }
        }
        isKeyboardOpen = true
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        super.keyboardWillHide(notification)
        self.view.endEditing(true)
        var info: [AnyHashable: Any] = notification.userInfo!
        let kbSize: CGSize = ((info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size)!
        heightNavigationViewCons.constant = 0
        viewCurrentFrame = CGRect(x: self.view!.frame.origin.x, y: 0, width: self.view!.frame.size.width, height: self.view!.frame.size.height+kbSize.height)
        self.view!.frame = viewCurrentFrame
        isKeyboardOpen = false
        //topHelperViewConst.constant = 0
        
        ////        bottomConst.constant = -20
        //
        //        self.view!.frame = CGRect(x: self.view!.frame.origin.x, y: topY, width: self.view!.frame.size.width, height: self.view!.frame.size.height)
        //      //  topConst.constant=constTop
        //        topNavConst.constant=0
    }
    
    func addTapHideKeyboard(){
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        // tap.cancelsTouchesInView = false
        tblList.addGestureRecognizer(tapGesture)
    }
    
    func hideKeyboard() {
        txtVMessageText.resignFirstResponder()
        tblList.endEditing(true)
        viewDisplayForPartner.isHidden=true
    }
    
    @IBAction func btnHideDisplayProfileClick(_ sender: Any) {
        viewDisplayForPartner.isHidden=true
    }
    
    //MARK: viewDidLoad-Settings
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //getPatner()
        getChatList()
        settings()
        addTapHideKeyboard()
        firstChatInvitedSet()
        setChatBadges()
        tblMenuSetting()
        btnMenu.imageView?.contentMode = .scaleAspectFit
        viewHeight = self.view!.frame.size.height
        viewCurrentFrame = self.view!.frame
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [member.identifier])
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [member.identifier])
        } else {
            // Fallback on earlier versions
        }
        
        let tap=UITapGestureRecognizer()
        tap.delegate = self
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        longPressRecognizerDeleteMsg = UILongPressGestureRecognizer(target: self, action: #selector(ChatViewController.deletMsg(_:)))
        longPressRecognizerDeleteMsg.cancelsTouchesInView = false
        //self.tblList.addGestureRecognizer(longPressRecognizerDeleteMsg)
        txtMessagePlaceHolder = "write_a_msg".localized
        txtVMessageText.text = txtMessagePlaceHolder
        txtVMessageText.textColor = UIColor.lightGray
        
        
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            lblNameDisplayForPartner.font = lblNameDisplayForPartner.font.withSize(14)
            btnTimerText.titleLabel?.font = btnTimerText.titleLabel?.font.withSize(14)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // tblMenu.frame=CGRect(x: 0, y: navigationView.frame.size.height, width: 200, height: 50*3)
        
        tblMenu.frame=CGRect(x: AppDelegate.isRTL == true ? 0 : screenWidth - 200, y: btnMenu.frame.origin.y + btnMenu.frame.size.height + 5, width: 200, height: 50*3)
    }
    
        override func viewWillAppear(_ animated: Bool) {
            getPatner()
//            self.hidesBottomBarWhenPushed = true
//            self.navigationController?.isNavigationBarHidden=true
          //  self.navigationController?.isNavigationBarHidden=true
        }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        timer.invalidate()
        
        if self.partnerRef != nil{
            self.partnerRef.removeAllObservers()
        }
        
        //  let height: CGFloat = 0 //whatever height you want
        //  let bounds = self.navigationController!.navigationBar.bounds
        // self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
        // self.tabBarController?.tabBar.isHidden=false
        //self.navigationController?.hidesBottomBarWhenPushed = false
        self.hidesBottomBarWhenPushed = false
        self.navigationController?.isNavigationBarHidden=false
        //        if let tabBarController = self.tabBarController as? CustomTabBarController{
        //            tabBarController.setTabBarFrame()
        //        }
    }
    
    
    func setChatBadges(){
        if(UserDefaults.standard.object(forKey: C.userDef.chatBadges) != nil){
            chatBadge=UserDefaults.standard.object(forKey: C.userDef.chatBadges) as! [String:Int]
        }
    }
    
    func saveUserDef(){
        UserDefaults.standard.set(chatBadge, forKey: C.userDef.chatBadges)
        UserDefaults.standard.synchronize()
    }
    
    func tblMenuSetting(){
        tblMenu.delegate=self
        tblMenu.dataSource=self
        tblMenu.isHidden=true
        tblMenu.isScrollEnabled = false
        
        tblMenu.shadow()
        //        tblMenu.layer.shadowOffset = CGSize(width:0,height: 0)
        //        tblMenu.layer.shadowColor = UIColor.darkGray.cgColor
        //        tblMenu.layer.shadowRadius = 4
        //        tblMenu.layer.shadowOpacity = 1
        //        tblMenu.layer.masksToBounds = false
        //        tblMenu.clipsToBounds = false
    }
    
    func back(){
        //ServerController.removeChatListObservers()
        if self.chatRef != nil{
            self.chatRef.removeAllObservers()
        }
        if self.partnerRef != nil{
            self.partnerRef.removeAllObservers()
        }
        if UIApplication.shared.keyWindow!.rootViewController as? SWRevealViewController != nil {
            let tababarController = (UIApplication.shared.keyWindow!.rootViewController as! SWRevealViewController).frontViewController as! UITabBarController
            if(tababarController.selectedIndex != 1 && arrChats.count>0){
                tababarController.selectedIndex = 1
                //                DispatchQueue.main.async {
                //                    self.navigationController?.popViewController(animated: true)
                //                }
            }
            //            else{
            //                DispatchQueue.main.async {
            //                    self.navigationController?.popViewController(animated: true)
            //                }
            //            }
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                //                if self.navigationController == nil{
                //                    ServerController.appDelegate.goToDiscoveryPage_Back()
                //                  print(self.navigationController == nil ? "back :navigation nil" : "back")
                //                }
                
            }
        }
        
    }
    
    func menu(){
        self.view.endEditing(true)
        tblMenu.isHidden = !tblMenu.isHidden
    }
    
    func setDisplayPartnerNavigationView(){
        lblNamePartnerProfile.text=member.username
        if(myChatPartner==nil || myChatPartner?.realProfile==false){
            lblNamePartnerProfile.text="nickname:".localized+lblNamePartnerProfile.text!
        }else{
            navigationView.backgroundColor = UIColor.exGreen
        }
        lblTextPartnerProfile.text=member.age+" | "+member.gender.localized+" | "+member.profession
        lblSomethingPartnerProfile.text=member.something
        imgPartnerProfile.setImgwithUrl(member.imageUrl)
        //imgPartnerProfile.setImgwithUrl(member.imageUrl, contentMode: .scaleToFill)
    }
    
    func settings(){
        //btnMenu.isHidden=true
        setDisplayPartnerNavigationView()
        // self.tabBarController?.tabBar.isHidden=true
        
        self.navigationController?.isNavigationBarHidden=true
        // leftBarBtn(fontAwesome: .chevronLeft , actionStr: "back")
        let btnIcon = AppDelegate.isRTL ? FontAwesome.chevronRight : FontAwesome.chevronLeft
        btnBack.textFontAwesome(btnIcon)
        btnBack.setTitleColor(UIColor.white, for: .normal)
        //  btnMenu.textFontAwesome(.plus)
        // btnMenu.setImage(UIImage(named: "more-18"), for: .normal)
        //  btnMenu.setBackgroundImage(UIImage(named: "more-18"), for: .normal)
        
        //rightBarBtn(fontAwesome: .plus , actionStr: "menu")
        txtVMessage.border(UIColor.exGreen)
        txtVMessage.cornerRadius()
        txtVMessage.shadow()
        let font = UIFont.fontAwesome(ofSize: 20)
        var text = String.fontAwesomeIcon(name: .camera)
        let str = NSAttributedString(string: text, attributes: [NSFontAttributeName: font ,NSForegroundColorAttributeName: UIColor.extLightGray])
        btnCamera.setAttributedTitle(str, for: .normal)
        text = String.fontAwesomeIcon(name: .send)
        let strSend = NSAttributedString(string: text, attributes: [NSFontAttributeName: font ,NSForegroundColorAttributeName: UIColor.white])
        btnSend.setAttributedTitle(strSend,for: .normal)
        btnSend.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        tblList.rowHeight = UITableViewAutomaticDimension
        tblList.estimatedRowHeight = 20
        tblList.backgroundColor=UIColor.clear
        tblMenu.rowHeight=50
        tblMenu.tag=tblMenuTag
        self.view.addSubview(tblMenu)
    }
    
    override func viewDidLayoutSubviews() {
//        self.hidesBottomBarWhenPushed = true
        self.navigationController?.isNavigationBarHidden=true
        self.view!.frame = viewCurrentFrame
        if self.arrChats.count > 0{
            //  DispatchQueue.main.async {
            self.tblList.scrollToRow(at: IndexPath(item:self.arrChats.count-1, section: 0), at: .bottom, animated: false)
            // self.tblList.scrollToBottom()
            // }
        }   qa      
    }
    
    //MARK: - SaveTalkForever
    
    func sendSaveTalkChat(){
        
  ServerController.getChatPartnerStateAndProfile(id: self.member.identifier, function: { (dic:[String:AnyObject]?, error:Error?) in
            let partner = ChatPartners(dic:dic)
            self.myProfileInPartner = partner
            let chat=Chat()
            //chat.text="אני רוצה להשאר בקשר"
            //chat.text = (ServerController.currentMainProfile?.username)! + "wants_to_stay_in_touch".localized
            chat.text = partner.profile.username + "wants_to_stay_in_touch".localized
            chat.sender=ServerController.currentUserId
            self.lastChat = chat
            ServerController.saveImgChat(image:nil , chat: chat, buddy: self.member.identifier, function: self.saveReturn)
        })
//        let chat=Chat()
//        //chat.text="אני רוצה להשאר בקשר"
//        //chat.text = (ServerController.currentMainProfile?.username)! + "wants_to_stay_in_touch".localized
//        chat.text = (self.partnerChatPartner?.profile.username)! + "wants_to_stay_in_touch".localized
//        chat.sender=ServerController.currentUserId
//        lastChat = chat
//        ServerController.saveImgChat(image:nil , chat: chat, buddy: self.member.identifier, function: self.saveReturn)
    }
    
    func saveTalkForever(){
        self.showAlertView(title: "requestFriendshipTitle".localized, msg: "requestFriendshipText1".localized + member.username + "requestFriendshipText2".localized, okButtonTitle: "Yes".localized, otherButtonTitle: "No".localized, okFunction: {
            ServerController.savePartnerStatus(partnerId1:ServerController.currentUserId , partnerId2: self.member.identifier, newStatus: State.forever.rawValue) { (error, ref) in
                if(error == nil){
                    ServerController.getPartnerStatus(partnerId1: self.member.identifier, partnerId2: ServerController.currentUserId, function: { (partnerStatus: String?) in
                        self.sendSaveTalkChat()
                        if partnerStatus == State.forever.rawValue{
                            ServerController.getOnceChatPartner(id: self.member.identifier, function: { (dic:[String : AnyObject]?,error:Error?) in
                                self.partnerChatPartner = ChatPartners(dic:dic)
                                self.state=State( rawValue: (self.partnerChatPartner?.status)!)
                                self.txtMessagePlaceHolder = "write_a_msg".localized
                                self.setDisplayMeAndPartnerForever()
                            })
                        }
                        
                    })
                }
            }
        }) {}
    }
    
    @IBAction func btnRequestSaveTalkClick(_ sender: Any) {
        if (state == .connected){
            saveTalkForever()
        }else if state == .haveInvited || state == .invited{
            self.showAlertView(title: "issue".localized, "required Enable Talk".localized)
        }
        
        // (state != .invited) ? saveTalkForever() : showAlertView(C.Alert.requiredEnableTalk)
    }
    
    //MARK: chekPartnerForever
    
    var isMeAndPartnerForever:Bool{
        return self.partnerChatPartner!.status == State.forever.rawValue && self.state == .forever
    }
    
    func setDisplayMeAndPartnerForever(){
        self.timer.invalidate()
        self.viewTimer.isHidden=true
        if(self.topConst.constant==0){
            self.topConst.constant=self.constTop
        }
    }
    
    func   serverReturnMyChatPartner(dic:[String:AnyObject]?){
        let myChatPartner=ChatPartners(dic:dic)
        self.state=State( rawValue: myChatPartner.status)
        txtMessagePlaceHolder = state == .haveInvited ? "waiting_for_invitation".localized : "write_a_msg".localized
        (isMeAndPartnerForever) ?  setDisplayMeAndPartnerForever() : self.starTimer()
    }
    
    func getMyChatPartner(){
        ServerController.getChatPartner(id: self.member.identifier, function: serverReturnMyChatPartner)
    }
    
    func serverReturnPartnerStateAndProfile(dic:[String:AnyObject]?, error:Error?){
        self.partnerChatPartner = ChatPartners(dic:dic)
        myProfileInPartner = self.partnerChatPartner
        getMyChatPartner()
    }
    
    func getPartnerChatPartnerStateAndProfile(){
        // if(partnerChatPartner == nil)
        // {
        ServerController.getChatPartnerStateAndProfile(id: self.member.identifier, function: serverReturnPartnerStateAndProfile)
        //  }
    }
    
    func checkPatnerForever(){
        getPartnerChatPartnerStateAndProfile()
    }
    
    // Mark: - setTimer
    
    var seconds:Int{
        if myChatPartner?.dateAdded != nil && myChatPartner?.dateAdded != ""{
            let dateDouble = Double((myChatPartner?.dateAdded)!)
            if(dateDouble != nil){
                return Int((CHAT_VALIDITY_INTERVAL - (Date().timeIntervalSince1970*1000 + ServerController.currentmillisAppStart - dateDouble!))/1000)
            }
        }
        return 0
    }
    
    func setTimeText(){
        let min = seconds/60 + 1
        //   print("tik chat \nseconds: \(seconds)\nmin: \(min)\n")
        if seconds < 0{
            if self.partnerDeleted == false{
                self.deletPartner()
                self.partnerDeleted = true
            }
            return
        }else{
            btnTimerText.setTitle("\("stay".localized) \(min) \("stay_in_touch".localized)", for: .normal)
        }
        //btnTimerText.setTitle("נשארו \(min) דקות. בקש שמירת קשר.", for: .normal)
        let allWidth=viewTimer.frame.size.width
        let dev:CGFloat =  CGFloat(seconds)/CGFloat(CHAT_VALIDITY_INTERVAL/1000)
        //btnTimer.backgroundColor = (dev>0.375) ? UIColor.exGreen : (dev > 0.25) ? UIColor.orange : UIColor.red
        btnTimer.backgroundColor = (min>45) ? UIColor.exGreen : (min>20) ? UIColor.orange : UIColor.red
        widthContLblTimer.constant = -allWidth + dev*allWidth
    }
    
    func deletPartner(){
        //self.firstGetPatrner = true
        if partnerDeleted == false{
            DispatchQueue.main.async(execute: {
                self.view.endEditing(true)
                self.timer.invalidate()
                
                if let chatViewController = ((((ServerController.appDelegate.window?.rootViewController) as? SWRevealViewController)?.frontViewController as? UITabBarController)?.selectedViewController as? UINavigationController)?.viewControllers.last as? ChatViewController{//בדיקה אם היוזר שהולך להמחק הוא מי שמצוטט איתו כרגע
                    if chatViewController.member.identifier == self.member.identifier{
                        DispatchQueue.main.async {
//                            self.partnerDeleted = true
                            print("delete partener and chat! - alert")
                            //if self.partnerDeleted == false{
//                                DispatchQueue.main.async(execute: {
                                    self.partnerDeleted = true
//                                })
                            if self.partnerRef != nil{
                                self.partnerRef.removeAllObservers()
                            }
                            self.showAlertView(title: "time_over_title".localized, msg: "time_over_text".localized, okFunction: {
                                DispatchQueue.main.async(execute: {
                                    self.back()
                                    self.partnerDeleted = true
                                    print("back")
                                })
                                
                                ServerController.deleteChatPartner(partnerId: self.member.identifier, function: { (err, ref) in
                                    print("delete partener and chat!")
                                })
                            })
                           // }
//                            self.partnerDeleted = true
                        }
                        return
                    }
                }
                //else{
               
                ServerController.deleteChatPartner(partnerId: self.member.identifier, function: { (err, ref) in
                    print("delete partener and chat!")
                })
                // }
            })
        }
    }
    
    func topCostSetWithTimerText(){
        if(topConst.constant==0){
            topConst.constant+=viewTimer.frame.size.height
        }
    }
    
    func setTimerBar(){
        if(arrChats.count>0){
            (state != .forever) ? starTimer() : checkPatnerForever()
        }
        else{
            self.viewTimer.isHidden=true
        }
    }
    
    func starTimer(){
        timer.invalidate()
        self.viewTimer.isHidden=false
        timer=Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(setTimeText), userInfo: nil, repeats: true)
        topCostSetWithTimerText()
        
    }
    //MARK: getChats
    
    func getChatList(){
        ServerController.getChatsWithRef(buddy: member.identifier) { (dic, ref) in
            self.serverReturn(arr: dic)
            self.chatRef = ref
            //ref?.removeAllObservers()
        }
        //ServerController.getChats(buddy:member.identifier,function: serverReturn)
    }
    
    //    func getMyPartnerFromMe(){
    //        ServerController.getChatPartner(id: member.identifier) { (dic:[String : AnyObject]?) in
    //            if dic != nil{
    //               print("")
    //            }else{
    //               print("")
    //            }
    //        }
    //    }
    
    func getPatner(){
        
        ServerController.getChatsPartnerWithRef(id: member.identifier) { (dic:[String : AnyObject]?, dataBaseRef) in
            self.partnerRef = dataBaseRef
//        }
//        ServerController.getChatPartner(id: member.identifier) { (dic:[String : AnyObject]?) in
            if dic != nil{
                self.myChatPartner = ChatPartners(dic:dic)
                self.member = self.myChatPartner?.profile
                self.state=State(rawValue: (self.myChatPartner?.status)!)
                self.txtMessagePlaceHolder = self.state == .haveInvited ? "waiting_for_invitation".localized : "write_a_msg".localized
                if !self.isKeyboardOpen{
                    if self.sendImage == false{
                        self.txtVMessageText.text = self.txtVMessageText.textColor == UIColor.lightGray ? self.txtMessagePlaceHolder : self.txtVMessageText.text
                    }
                }
                
//                if self.sendImage == false{
//                self.txtVMessageText.text = self.txtVMessageText.text == "" ? "" : self.txtMessagePlaceHolder
//                }
                if self.state == State.blocked{
                    DispatchQueue.main.async {
                        self.showAlertView(title: "issue".localized, msg: "youve_been_blocked".localized, okButtonTitle:"GO".localized, okFunction: {
                            DispatchQueue.main.async(execute: {
                                if self.chatRef != nil{
                                    self.chatRef.removeAllObservers()
                                }
                                if self.partnerRef != nil{
                                    self.partnerRef.removeAllObservers()
                                }
                                self.navigationController?.popViewController(animated: true)
                            })
                        })
                    }
                    // ServerController.removeChatListObservers()
                    //                    if self.chatRef != nil{
                    //                        self.chatRef.removeAllObservers()
                    //                    }
                    //                    self.navigationController?.popViewController(animated: true)
                }
                self.firstChatInvitedSet()
                DispatchQueue.main.async {
                    self.setDisplayPartnerNavigationView()
                }
                //self.viewDisplayForPartner.isHidden=false
                //self.setDisplayForPartner(chatPartner: self.myChatPartner!)
            }else{
                if self.firstGetPatrner == false{
                    if self.partnerDeleted == false{
                    self.deletPartner()
                    self.partnerDeleted = true
                    }
                }
            }
            self.firstGetPatrner = false
        }
    }
    
    var chatsNum = 0
    func serverReturn(arr:[String:AnyObject]?){
        chatBadge[member.identifier]=arr?.count
        saveUserDef()
        arrChats=Chat().dicToArrayObject( dic: arr as? [String:[String:AnyObject]]) as! [Chat]
        chatsNum = arrChats.count
        //print("chats count befor filter - \(arrChats.count)")
        arrChats = arrChats.filter({ (chat) -> Bool in
            if chat.deleted.contains(ServerController.currentUserId){
                return false
            }
            return true
        })
        //print("chats count after filter - \(arrChats.count)")
        //        if(arrChats.count==0) {
        //            setNoChats()
        //        }
        //        else{
        //            btnMenu.isHidden=false
        //        }
        //
        arrChats.sort { (c1, c2) -> Bool in  c1.dateAdded.toDate()!<c2.dateAdded.toDate()! }
        tblList.reloadData()
        //DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
        if self.arrChats.count > 0{
            DispatchQueue.main.async {
                self.tblList.scrollToRow(at: IndexPath(item:self.arrChats.count-1, section: 0), at: .bottom, animated: false)
                //self.tblList.scrollToBottom()
            }
        }
        // })
        setTimerChat()
    }
    
    func  setTimerChat(){
        timer.invalidate()
        setTimerBar()
        
    }
    
    func setNoChats(){
        btnMenu.isHidden=true
        //  showAlertView("no messages")
    }
    
    //MARK: tableview
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        tblMenu.isHidden=true
        if(tableView.tag==tblMenuTag){
            switch indexPath.row {
            case 0:
                profileDisplayforPartner()
                break
            case 1:
                displayPrivateProfileToPartner()
                break
            case 2:
                showAlert()
                
                break
            default: break
            }
        }else{
            if (tableView.cellForRow(at: indexPath) as? ChatCell) != nil{
                if arrChats[indexPath.row].imageUrl != ""{
                    let imageVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowImageViewController") as! ShowImageViewController
                    imageVC.urlImage = arrChats[indexPath.row].imageUrl
                    self.present(imageVC, animated: false, completion: nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tableView.tag==tblMenuTag) ? arrMenu.count : arrChats.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView.tag==tblMenuTag){
            let cell = UITableViewCell()
            cell.textLabel!.text=arrMenu[indexPath.row]
            return cell
        }
        else{
            let cell:ChatCell = tableView.dequeueReusableCell(withIdentifier: C.Cell.ChatCell) as! ChatCell
            tableView.backClearClr(cell)
            cell.setCell(chat: arrChats[indexPath.row])
            let longPressRecognizerDeleteMsg = UILongPressGestureRecognizer(target: self, action: #selector(ChatViewController.deletMsg(_:)))
            longPressRecognizerDeleteMsg.cancelsTouchesInView = false
            cell.addGestureRecognizer(longPressRecognizerDeleteMsg)
            return cell
        }
    }
    
    //MARK: profile display
    func saveDisplayRealProfile(){
        //let image = viewMyProfile.createImage()
        //let lastName = self.partnerChatPartner!.profile.username
        ServerController.saveDisplayRealProfile(memberID: self.member.identifier) { (error, ref) in
            //ServerController.getOnceRealCurrentProfile(function: serverReturnRealProfile)
            ServerController.getChatPartnerStateAndProfile(id: self.member.identifier, function:  { (dic:[String : AnyObject]?, error:Error?) in
                self.partnerChatPartner = ChatPartners(dic:dic)
                self.myProfileInPartner = self.partnerChatPartner
            })
            
            //שולח הודעה א שתף אותך בפרופיל הפרטי שלו
//            let chat=Chat()
//            chat.sender=ServerController.currentUserId
//            chat.text = self.partnerChatPartner?.profile.gender == "woman" ? "\"\(lastName)\" \("FemaleSharingPrivateProfile".localized)" : "\"\(lastName)\" \("MaleSharingPrivateProfile".localized)"
//            ServerController.saveImgChat(image: nil , chat: chat, buddy: self.self.member.identifier, function: { (error, dic) in
//                self.hideNativeActivityIndicator()
//                super.saveReturn(error, ref,false)
//            })
//
            //שולח את התמונה של הפרופיל...
//            if image != nil{
//                self.image = image!
//                self.changedImage=true
//                let chat =  self.crateChat()
//                self.showNativeActivityIndicator()
//                ServerController.saveImgChat(image: image , chat: chat, buddy: self.self.member.identifier, function: { (error, dic) in
//                    self.hideNativeActivityIndicator()
//                    super.saveReturn(error, ref,false)
//                })
//            }
        }
    }
    
    func  serverReturnRealProfile(dicPrivateProfile: [String : AnyObject]?,error:Error?){
        //let privateProfile = RealProfile( dic: dicPrivateProfile)
        /*
    //    if (self.partnerChatPartner == nil || self.partnerChatPartner?.realProfile==false){
            ServerController.getChatPartnerStateAndProfile(id: self.member.identifier, function:  { (dic:[String : AnyObject]?, error:Error?) in
                self.partnerChatPartner = ChatPartners(dic:dic)
               // if(self.partnerChatPartner?.realProfile==false){
                    let privateProfile = RealProfile( dic: dicPrivateProfile)
                    //ServerController.currentPrivateProfile=privateProfile
                    if(privateProfile.identifier != ""){
                        self.showAlertPrivateProfile()
                    }
                    else{
                        self.showAlertView("אין לך פרופיל פרטי....")
                    }
                //}
            })
 */
    }
    
    func displayPrivateProfileToPartner(){
        if ServerController.currentPrivateProfile == nil{
            self.showAlertView(title: "Problem".localized, "cant_share_real_before_create".localized)
        }else{
        if state == .haveInvited && myChatPartner == nil{//לפני ההודעה הראשונה
            self.showAlertView(title:  "issue".localized, "cant_share_real_before_writing_a_message".localized)
        }else{
            // ServerController.getRealCurrentProfile(function: serverReturnRealProfile)
            self.showAlertPrivateProfile()
            //ServerController.getOnceRealCurrentProfile(function: serverReturnRealProfile)
        }
        }
        
        //        if (state == .connected || state == .forever ){
        //            ServerController.getRealCurrentProfile(function: serverReturnRealProfile)
        //        }else if state == .haveInvited{
        //            print("haveInvited")
        //            if myChatPartner == nil{//לפני ההודעה הראשונה
        //                self.showAlertView(title:  "issue".localized, "cant_share_real_before_writing_a_message".localized)
        //            }else{
        //                ServerController.getRealCurrentProfile(function: serverReturnRealProfile)
        //            }
        //
        //        }else if state == .invited{
        //            print("invited")
        //        }
        
        //        if (state == .connected || state == .forever ){
        //           ServerController.getRealCurrentProfile(function: serverReturnRealProfile)
        //        }else if state == .haveInvited{
        //            print("haveInvited")
        //            if myChatPartner == nil{//לפני ההודעה הראשונה
        //                self.showAlertView(title:  "issue".localized, "cant_share_real_before_writing_a_message".localized)
        //            }
        //
        //        }else if state == .invited{
        //            print("invited")
        //        }
        
        //        ServerController.getRealCurrentProfile(function: serverReturnRealProfile)
    }
    
    func profileDisplayforPartner(hidenView:Bool = false){
        ServerController.getChatPartnerStateAndProfile(id: self.member.identifier, function: { (dic:[String:AnyObject]?, error:Error?) in
            if hidenView == false{
            self.view.bringSubview(toFront: self.viewDisplayForPartner)
            }
            if dic != nil{
                let chatPartner=ChatPartners(dic:dic)
                self.viewDisplayForPartner.isHidden=hidenView/*false*/
                self.setDisplayForPartner(chatPartner: chatPartner)
                self.self.myProfileInPartner = chatPartner
            }else{
                self.viewDisplayForPartner.isHidden=hidenView/*false*/
                self.setDisplayForPartner(profile: ServerController.currentMainProfile!)
            }
        })
    }
    
    func setDisplayForPartner(chatPartner:ChatPartners){
        let profile=chatPartner.profile
        lblTextDisplayForPartner.text=profile!.age+" | "+profile!.gender.localized+" | "+profile!.profession
        lblNameDisplayForPartner.text=profile!.username
        if(chatPartner.realProfile==false){
            lblNameDisplayForPartner.text="nickname:".localized+lblNameDisplayForPartner.text!
        }
        imgDisplayForPartner.setImgwithUrl(profile!.imageUrl)
        //imgDisplayForPartner.setImgwithUrl(profile!.imageUrl, contentMode: .scaleToFill)
        
        lblSomthingDisplayForPartner.text=profile!.something
        
    }
    
    func setDisplayForPartner(profile:Profile){
        lblTextDisplayForPartner.text=profile.age+" | "+profile.gender.localized+" | "+profile.profession
        lblNameDisplayForPartner.text=profile.username
        if state == .haveInvited && myChatPartner == nil{//לפני ההודעה הראשונה
            lblNameDisplayForPartner.text="nickname:".localized+lblNameDisplayForPartner.text!
        }else{
            if(myChatPartner?.realProfile==false){
                lblNameDisplayForPartner.text="nickname:".localized+lblNameDisplayForPartner.text!
            }
        }
        //if(myChatPartner?.realProfile==false){
        // lblNameDisplayForPartner.text="nickname:".localized+lblNameDisplayForPartner.text!
        // }
        imgDisplayForPartner.setImgwithUrl(profile.imageUrl)
        //imgDisplayForPartner.setImgwithUrl(profile!.imageUrl, contentMode: .scaleToFill)
        lblSomthingDisplayForPartner.text=profile.something
    }
    
    func showAlertPrivateProfile(){
        let alertController = UIAlertController(title: "share_real_identity".localized, message: "real_details_text".localized, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes".localized, style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            self.saveDisplayRealProfile()
        }
        let cancelAction = UIAlertAction(title: "No".localized, style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            ///let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //let main = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
            // self.present(main, animated: false, completion: nil)
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async(execute: {
            self.present(alertController, animated: true, completion: nil)
        })
        
    }
    
    func showAlert(){//blocked
        if state == .haveInvited && myChatPartner == nil{//לפני ההודעה הראשונה
            self.showAlertView(title:  "issue".localized, "cant_block_before_inviting".localized)
        }else{
            let alertController = UIAlertController(title: "warning".localized, message: "sure_you_want_to_delete1".localized + member.username + "sure_you_want_to_delete2".localized, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Yes".localized, style: UIAlertActionStyle.default) {
                UIAlertAction in
                NSLog("OK Pressed")
                ServerController.saveTwoPartnersStatus(partnerId: self.member.identifier, newStatus: State.blocked.rawValue, function: { (error, ref) in
                    if self.chatRef != nil{
                        self.chatRef.removeAllObservers()
                    }
                    if self.partnerRef != nil{
                        self.partnerRef.removeAllObservers()
                    }
                    self.navigationController?.popViewController(animated: true)
                })
            }
            let cancelAction = UIAlertAction(title: "No".localized, style: UIAlertActionStyle.cancel) {
                UIAlertAction in
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            DispatchQueue.main.async(execute: {
                self.present(alertController, animated: true, completion: nil)
            })
            
        }
        
        
        //        if (state == .connected || state == .forever ){
        //            let alertController = UIAlertController(title: "warning".localized, message: "sure_you_want_to_delete1".localized + member.username + "sure_you_want_to_delete2".localized, preferredStyle: .alert)
        //            let okAction = UIAlertAction(title: "Yes".localized, style: UIAlertActionStyle.default) {
        //                UIAlertAction in
        //                NSLog("OK Pressed")
        //                ServerController.saveTwoPartnersStatus(partnerId: self.member.identifier, newStatus: State.blocked.rawValue, function: { (error, ref) in
        //                    self.navigationController?.popViewController(animated: true)
        //                })
        //            }
        //            let cancelAction = UIAlertAction(title: "No".localized, style: UIAlertActionStyle.cancel) {
        //                UIAlertAction in
        //            }
        //            alertController.addAction(okAction)
        //            alertController.addAction(cancelAction)
        //
        //            DispatchQueue.main.async(execute: {
        //                self.present(alertController, animated: true, completion: nil)
        //            })
        //        }else if state == .haveInvited{
        //            print("haveInvited")
        //            if myChatPartner == nil{//לפני ההודעה הראשונה
        //                self.showAlertView(title:  "issue".localized, "cant_block_before_inviting".localized)
        //            }
        //
        //        }else if state == .invited{
        //            print("invited")
        //        }
        
    }
    
    
    //MARK: image peaker
    override func setImage() {
//        saveImgUrl(sheet.tag)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let confirmSendingPictureVC =  mainStoryboard.instantiateViewController(withIdentifier: "ConfirmSendingPictureViewController") as! ConfirmSendingPictureViewController
        confirmSendingPictureVC.sendImageDelegate = self
        confirmSendingPictureVC.myImage = image
        confirmSendingPictureVC.partnerId = member.identifier
        confirmSendingPictureVC.modalPresentationStyle = .overCurrentContext
//        confirmSendingPictureVC.modalTransitionStyle = .crossDissolve
        
        self.present(confirmSendingPictureVC, animated: true, completion: nil)
    }
    
    override func saveImgUrl(_ tag: Int ){
        changedImage=true
        btnSendClick(UIButton())
        
    }
    
    override func btnImgClick(_ sender: AnyObject) {
        super.btnImgClick(sender)
    }
    
    //MARK:  SendImageDelegate
    func okSendImage(){
        saveImgUrl(sheet.tag)
    }
    
    //MARK:Save chat
    @IBAction func btnSendClick(_ sender: Any) {
        if state == .haveInvited && chatsNum == 5{
            let alertController = UIAlertController(title: "", message: "You can not send more than five messages while chat invitations will not be approved".localized , preferredStyle: .alert)
            let okAction = UIAlertAction(title: "GO".localized, style: UIAlertActionStyle.default) {
                UIAlertAction in
            }
            alertController.addAction(okAction)
            
            DispatchQueue.main.async(execute: {
                self.present(alertController, animated: true, completion: nil)
            })
        }else{
        if changedImage == true{
            self.showNativeActivityIndicator()
        }
        if(toSendValues || !saved ){
            btnSend.isEnabled = false
            let chat =  crateChat()
            sendImage = changedImage
            //            if isKeyboardOpen{
            //                txtVMessageText.text = changedImage==false ? "" : txtVMessageText.text
            //                txtVMessageText.textColor = UIColor.black
            //            }else{
            //                //txtVMessageText.text = state == .invited ? "waiting_for_invitation".localized : "write_a_msg".localized
            //                txtMessagePlaceHolder = state == .haveInvited ? "waiting_for_invitation".localized : "write_a_msg".localized
            //                if changedImage==false{
            //                txtVMessageText.text = txtMessagePlaceHolder
            //                txtVMessageText.textColor = UIColor.lightGray
            //                }
            //            }
            
            if isKeyboardOpen{
                if sendImage == false{
                    txtVMessageText.text = ""
                    txtVMessageText.textColor = UIColor.black
                }
            }else{
                txtMessagePlaceHolder = state == .haveInvited ? "waiting_for_invitation".localized : "write_a_msg".localized
                if sendImage == false{
                    txtVMessageText.text = txtMessagePlaceHolder
                    txtVMessageText.textColor = UIColor.lightGray
                }
            }
            
            //            if isKeyboardOpen{
            //                txtVMessageText.text = ""
            //                txtVMessageText.textColor = UIColor.black
            //            }else{
            //                txtVMessageText.text = state == .haveInvited ? "waiting_for_invitation".localized : "write_a_msg".localized
            //                txtVMessageText.text = txtMessagePlaceHolder
            //                txtVMessageText.textColor = UIColor.lightGray
            //            }
            
            if(arrChats.count==0){
                ServerController.saveChatPartner( profile: member,  status: .haveInvited , function: { (error, ref) in
                    self.profileDisplayforPartner(hidenView: true)
                })
            }
            saved=false
            lastChat = chat
            ServerController.saveImgChat(image:changedImage==true ? image:nil , chat: chat, buddy: member.identifier, function: saveReturn)
        }
        
        //        let chat =  crateChat()
        //        if(arrChats.count==0){
        //            ServerController.saveChatPartner( profile: member,  status: .haveInvited , function: { (error, ref) in})
        //        }
        //        if(toSendValues || !saved ){
        //            saved=false
        //            lastChat = chat
        //            ServerController.saveImgChat(image:changedImage==true ? image:nil , chat: chat, buddy: member.identifier, function: saveReturn)
        //            //txtVMessageText.text=""
        //        }
        }
    }
    
    override func saveReturn(_ error: Error?, _ ref: DatabaseReference,_ showAlert:Bool=false) {
        self.hideNativeActivityIndicator()
        super.saveReturn(error, ref,false)
        btnSend.isEnabled = true
        if error == nil{
            //            if isKeyboardOpen{
            //                txtVMessageText.text = sendImage==false ? "" : txtVMessageText.text
            //                txtVMessageText.textColor = UIColor.black
            //            }else{
            //                //txtVMessageText.text = state == .invited ? "waiting_for_invitation".localized : "write_a_msg".localized
            //                txtMessagePlaceHolder = state == .haveInvited ? "waiting_for_invitation".localized : "write_a_msg".localized
            //                if sendImage==false{
            //                    txtVMessageText.text = txtMessagePlaceHolder
            //                    txtVMessageText.textColor = UIColor.lightGray
            //                }
            //            }
            //            if isKeyboardOpen{
            //                txtVMessageText.text = changedImage==false ? "" : txtVMessageText.text
            //                txtVMessageText.textColor = UIColor.black
            //            }else{
            //                //txtVMessageText.text = state == .invited ? "waiting_for_invitation".localized : "write_a_msg".localized
            //                txtMessagePlaceHolder = state == .haveInvited ? "waiting_for_invitation".localized : "write_a_msg".localized
            //                if changedImage==false{
            //                    txtVMessageText.text = txtMessagePlaceHolder
            //                    txtVMessageText.textColor = UIColor.lightGray
            //                }
            //            }
            
            if isKeyboardOpen{
                if sendImage == false{
                //txtVMessageText.text = ""
                //txtVMessageText.textColor = UIColor.black
                }else{
                    sendImage = false
                }
            }else{
                txtMessagePlaceHolder = state == .haveInvited ? "waiting_for_invitation".localized : "write_a_msg".localized
                if sendImage == false{
                //txtVMessageText.text = txtMessagePlaceHolder
                //txtVMessageText.textColor = UIColor.lightGray
                }else{
                    sendImage = false
                }
            }
            
            
//            if isKeyboardOpen{
//                txtVMessageText.text = ""
//                txtVMessageText.textColor = UIColor.black
//            }else{
//                txtVMessageText.text = state == .haveInvited ? "waiting_for_invitation".localized : "write_a_msg".localized
//                txtVMessageText.text = txtMessagePlaceHolder
//                txtVMessageText.textColor = UIColor.lightGray
//            }
            if self.myProfileInPartner == nil{
            ServerController.getChatPartnerStateAndProfile(id: self.member.identifier, function: { (dic:[String:AnyObject]?, error:Error?) in
                let partner = ChatPartners(dic:dic)
                self.myProfileInPartner = partner
                ServerController.sendPush(chat: self.lastChat, partnerId: self.member.identifier, chatPartner: self.myProfileInPartner!)
            })
            }
            else{
                ServerController.sendPush(chat: lastChat, partnerId: member.identifier, chatPartner: self.myProfileInPartner!)
            }
         //   ServerController.sendPush(jsonData: lastChat.toJson(), partnerId: member.identifier)
        }
        //tblList.scrollToBottom()
        //        if arrChats.count > 0 {
        //            tblList.scrollToRow(at: IndexPath(item:arrChats.count-1, section: 0), at: .bottom, animated: true)
        //        }
    }
    
    
    func crateChat()->Chat {
        let c=Chat()
        c.sender=ServerController.currentUserId
        c.text = txtVMessageText.textColor == UIColor.lightGray ? "" : changedImage==true ? "" : txtVMessageText.text
        return c
    }
    
    //MARK:UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        let location = touch.location(in: gestureRecognizer.view)
        if !tblMenu.frame.contains(location) {
            tblMenu.isHidden = true
        }
        return true
    }
    
    func deletMsg(_ gesture: UILongPressGestureRecognizer){
        let alertController = UIAlertController(title: "warning".localized, message: "sure_you_want_to_delete_message".localized , preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes".localized, style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            if let cell = gesture.view as? ChatCell {
                if let indexPath = self.tblList.indexPath(for: cell){
                ServerController.saveDeletedMsg(memberID: self.member.identifier, msgKey: self.arrChats[indexPath.row].key, otherPartnerDeleted: self.arrChats[indexPath.row].deleted, function: { (err, dic) in
               })
            }
            }
            // if gesture.state == UIGestureRecognizerState.began {
//            let touchPoint = gesture.location(in: self.tblList)
//            if let indexPath = self.tblList.indexPathForRow(at: CGPoint(x: 0, y: touchPoint.y)) {
//                ServerController.saveDeletedMsg(memberID: self.member.identifier, msgKey: self.arrChats[indexPath.row].key, otherPartnerDeleted: self.arrChats[indexPath.row].deleted, function: { (err, dic) in
//                })
//
//                // your code here, get the row for the indexPath or do whatever you want
//            }
            //  }
        }
        let cancelAction = UIAlertAction(title: "No".localized, style: UIAlertActionStyle.cancel) {
            UIAlertAction in
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async(execute: {
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    
    //MARK:TextView delegate
    override func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            //   textView.text = "write_a_msg".localized
            textView.text = txtMessagePlaceHolder
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
