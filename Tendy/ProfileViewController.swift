///
//  ProfileViewController.swift
//  Tendy
//
//  Created by ATN on 31/07/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit
import DLRadioButton
import FirebaseDatabase
import Firebase
import FontAwesome_swift
import SWRevealViewController

class ProfileViewController: SuperRevealViewController,UITabBarControllerDelegate{
    
    var profile:Profile=Profile()
    var firstRealProfile = false
    var firstProfile = false
    var fromMenu = false
    
    
    @IBOutlet weak var topViewTopSpace: NSLayoutConstraint!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblChangeImg: UILabel!
    @IBOutlet weak var topBackBlackConst: NSLayoutConstraint!
    @IBOutlet weak var conHeightSecond: NSLayoutConstraint!
    @IBOutlet weak var lblSecondRealProfile: UILabel!
    @IBOutlet weak var btnMan: DLRadioButton!
    @IBOutlet weak var btnWoman: DLRadioButton!
    @IBOutlet weak var btnOther: DLRadioButton!
    @IBOutlet weak var viewUnenableChangeGender: UIView!
    @IBOutlet weak var imgProfile: RoundButton!
    @IBOutlet weak var txtFldName: UnderLineTextField!
    @IBOutlet weak var txtFldAge: UnderLineTextField!
    @IBOutlet weak var txtFldProfession: UnderLineTextField!
    @IBOutlet weak var txtFldAboutMe: UnderLineTextField!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var blackBackground: UILabel!
    @IBOutlet var toolbarDatePicker: UIToolbar!
    @IBOutlet weak var barBtnSelectDate: UIBarButtonItem!
    @IBOutlet weak var barBtnCancelDate: UIBarButtonItem!
    @IBAction func tapSelectDate(_ sender: UIBarButtonItem) {
        setTextOnTxt()
        closeDatePickerKeyboard()
    }
    @IBAction func tapCancelDate(_ sender: UIBarButtonItem) {
        closeDatePickerKeyboard()
    }
    var datePicker = UIDatePicker()
    
    @IBAction func tapBack(_ sender: UIButton) {
        back()
    }
    @IBOutlet weak var viewReveal: UIView!
    
    //constarin to ipad
    @IBOutlet weak var conImageProfileWidth: NSLayoutConstraint!
    @IBOutlet weak var conBtnManHeight: NSLayoutConstraint!
    @IBOutlet weak var conTxfNameBootom: NSLayoutConstraint!
    @IBOutlet weak var conTxfAgeBottom: NSLayoutConstraint!
    @IBOutlet weak var conTxfProfesionBottom: NSLayoutConstraint!
    @IBOutlet weak var conTxfAboutMeBootom: NSLayoutConstraint!
    @IBOutlet weak var conViewBlackBackGroundHeight: NSLayoutConstraint!
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let firstVcNav=(viewController as! UINavigationController).viewControllers[0]
        if(profile.identifier=="" && !(firstVcNav is ProfileViewController)){
            //showAlertView(C.Alert.requiredMainProfile)
            showAlertRequiredMainProfile()
            return false
        }
        return true
    }
    
    var requiredFieldsFullRealProfile:Bool{
        //לגירסה של אפל
        //return (gender != nil && !txtFldName.text!.isEmpty && !txtFldAge.text!.isEmpty) ? true : false
        return (gender != nil && !txtFldName.text!.isEmpty) ? true : false
    }
    
    var requiredFieldsFull:Bool{
        return (gender != nil && !txtFldName.text!.isEmpty) ? true : false
    }
    
    var  changedProfileValues: Bool{
        return (txtFldAge.text==profile.age && txtFldName.text==profile.username && txtFldAboutMe.text==profile.something && txtFldProfession.text==profile.profession) && gender==profile.gender && changedImage==false ?  false : true
    }
    
    var gender:String?{
        return (btnWoman.isSelected) ? Gender( rawValue: btnWoman.tag)!.description :(btnMan.isSelected) ? Gender(rawValue:  btnMan.tag)!.description : (btnOther.isSelected) ? Gender(rawValue:  btnOther.tag)!.description : nil
    }
    
    @IBAction func btnSaveClick(_ sender: Any) {
        firstRealProfile ? requiredFieldsFullRealProfile ? editProfileAndSave() : showAlertView(C.Alert.setRequiredFiledsRealProfile) : requiredFieldsFull ? editProfileAndSave() : showAlertView(C.Alert.setRequiredFiledsProfile)
        // requiredFieldsFull ? editProfileAndSave() : showAlertView(C.Alert.setRequiredFiledsProfile)
    }
    
    func editProfileAndSave(){
        //        if currentReachabilityStatus != .notReachable{
        
        if(changedProfileValues || !saved ){
            self.showNativeActivityIndicator()
            btnSave.isEnabled = false
            editProfile()
            saved=false
            profile.pushToken = ServerController.deviceToken
            profile.deviceType = DeviceTypeEnum.iphone.rawValue
            ServerController.saveImgProfie(image: imgProfile.image(for: .normal), profile: profile,function: saveReturn)
            // ServerController.saveImgProfie(image: changedImage==true ? image:nil, profile: profile,function: saveReturn)
        }
        //        }else{
        //            self.showAlertViewNoInternent()
        //        }
    }
    
    override func saveReturn(_ error: Error?, _ ref: DatabaseReference) {
        self.hideNativeActivityIndicator()
        btnSave.isEnabled = true
        var goBack = false
        if error != nil{
            super.failed()
        }else{
            //  succeeded(showAlert:true)
            succeeded(showAlert:true,function: {
                // super.saveReturn(error, ref)
                if(!(self.profile is RealProfile)){
                    ServerController.currentMainProfile = self.profile
                }else{//5/11/17
                    goBack = true
                    ServerController.currentPrivateProfile = self.profile
                }
                //11/12/17
//                if self.firstRealProfile == true{
//                    ServerController.appDelegate.goToFirstProfile()
//                }else
                    if self.firstProfile == true{
                    self.firstProfile = false
                    DispatchQueue.main.async {
                        //  DispatchQueue.global(qos: .background).async {
                        super.reavelViewControllerSettings()
                    }
                    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    ServerController.appDelegate.registerToNotifications(UIApplication.shared)
                    ServerController.appDelegate.startDiscoveryTimer()
                }else{
                    // back()
                }
                if goBack{
                    self.back()
                }else{
                    if let tabBar = ((ServerController.appDelegate.window?.rootViewController) as? SWRevealViewController)?.frontViewController as? UITabBarController{
                        tabBar.selectedIndex = 2
                        //   tabBar.select
                    }
                }
            })
        }
    }
    
    func editProfile(){
        profile.gender=gender!
        profile.username=txtFldName.text!
        profile.something=txtFldAboutMe.text!
        profile.age=txtFldAge.text!
        profile.profession=txtFldProfession.text!
        profile.identifier=Auth.auth().currentUser!.uid
    }
    
    override func reavelViewControllerSettings(){

        let btnIcon = AppDelegate.isRTL ? FontAwesome.chevronRight : FontAwesome.chevronLeft
        (profile is RealProfile) ? leftBarBtn(fontAwesome: btnIcon , actionStr: "back"): firstProfile ? setMainNavigation() : super.reavelViewControllerSettings()
    }
    
    func setMainNavigation(){
        leftBarBtn("", fontAwesome: .bars, actionStr: "showAlertRequiredMainProfile", target: self)
        setAppName()
    }
    
    func showAlertRequiredMainProfile(){
        showAlertView(C.Alert.requiredMainProfile)
    }
    
    func back(){
        //goToPageMain()
        //self.navigationController?.popViewController(animated: true)
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    override func saveImgUrl(_ tag: Int ){
        changedImage=true
    }
    
    override func notificationReceived(data: [String: AnyObject]) {
        if (data["sender"] as? String) != nil{
            LocalNoteficationManager.sharedInstance.addChatNotification(data: data)
        }
        print(data)
    }
    
    
    override func viewDidLoad() {
        viewAboveReveal = viewReveal
        firstProfile = ServerController.currentMainProfile == nil ? true : false
        
        super.viewDidLoad()
        self.tabBarController?.delegate=self
        self.navigationController?.isNavigationBarHidden = false
        btnMan.tag=Gender.man.rawValue
        btnWoman.tag=Gender.woman.rawValue
        btnOther.tag=Gender.other.rawValue
        //04/01/2018
        let btnIcon = AppDelegate.isRTL ? FontAwesome.chevronRight : FontAwesome.chevronLeft
        btnBack.textFontAwesome(btnIcon)
        conHeightSecond.constant = 0
        
        self.navigationController?.isNavigationBarHidden = false
        firstRealProfile == false ? setProfile() : setFirstRealProfile()
        
        if DeviceType.IS_IPAD {
            setIpadConstrains()
        }
        
        viewUnenableChangeGender.isHidden = true//לגירסה של אפל
        btnMan.iconColor = UIColor.exGreen//לגירסה של אפל
        btnMan.indicatorColor = UIColor.exGreen//לגירסה של אפל
        btnWoman.iconColor = UIColor.exGreen//לגירסה של אפל
        btnWoman.indicatorColor = UIColor.exGreen//לגירסה של אפל
        btnOther.iconColor = UIColor.exGreen//לגירסה של אפל
        btnOther.indicatorColor = UIColor.exGreen//לגירסה של אפל
    }
    
    func setIpadConstrains(){
        let newConImageProfileWidth = conImageProfileWidth.constraintWithMultiplier(0.2)
        self.view!.removeConstraint(conImageProfileWidth)
        conImageProfileWidth = newConImageProfileWidth
        self.view!.addConstraint(conImageProfileWidth)
        
        conBtnManHeight.constant = 30
        conTxfNameBootom.constant = 18
        conTxfAgeBottom.constant = 18
        conTxfProfesionBottom.constant = 18
        conTxfAboutMeBootom.constant = 12
        self.view!.layoutIfNeeded()
    }
    
    func setIpadRealProfileConstrain(){
        let newConViewBlackBackGroundHeight = conViewBlackBackGroundHeight.constraintWithMultiplier(0.12)
        self.view!.removeConstraint(conViewBlackBackGroundHeight)
        conViewBlackBackGroundHeight = newConViewBlackBackGroundHeight
        self.view!.addConstraint(conViewBlackBackGroundHeight)
        lblSecondRealProfile.font = lblSecondRealProfile.font.withSize(13)
        self.view!.layoutIfNeeded()
    }
    
    func setIphon5RealProfileConstrain(){
        let newConViewBlackBackGroundHeight = conViewBlackBackGroundHeight.constraintWithMultiplier(0.18)
        self.view!.removeConstraint(conViewBlackBackGroundHeight)
        conViewBlackBackGroundHeight = newConViewBlackBackGroundHeight
        self.view!.addConstraint(conViewBlackBackGroundHeight)
        lblSecondRealProfile.font = lblSecondRealProfile.font.withSize(14)
        self.view!.layoutIfNeeded()
    }
    
    func setRealProfileLocalizedStrings(){
        setLocalizedStrings()
        self.title = "Real profile".localized
        txtFldName.placeholder = "Name".localized
        txtFldAge.placeholder = "Birthday date".localized
        barBtnCancelDate.title = "Cancel".localized
        barBtnSelectDate.title = "OK".localized
        lblChangeImg.text = ""
    }
    
    func setLocalizedStrings(){
        // self.title="Login".localized
        lblSecondRealProfile.text = "Second Real Profile Title".localized
        lblChangeImg.text = "change profile picture".localized
        txtFldName.placeholder = "nickname".localized
        txtFldAge.placeholder = "Age".localized
        txtFldProfession.placeholder = "Profession".localized
        txtFldAboutMe.placeholder = "Something about me".localized
        btnMan.setTitle("man".localized, for: .normal)
        btnWoman.setTitle("woman".localized, for: .normal)
        btnOther.setTitle("other".localized, for: .normal)
        btnSave.setTitle("SAVE".localized, for: .normal)
    }
    
    @IBAction func btnManClick(_ sender: Any) {
        changeGender()
        
    }
    
    @IBAction func btnWomanClick(_ sender: Any) {
        changeGender()
    }
    
    @IBAction func btnOtherClick(_ sender: Any) {
        changeGender()
    }
    
    var manImage:UIImage{
        return  (profile is RealProfile) ?
            #imageLiteral(resourceName: "default_profile_image"):#imageLiteral(resourceName: "Asset 11")
        //        return  (profile is RealProfile) ?
        //           // #imageLiteral(resourceName: "default_profile_image"):#imageLiteral(resourceName: "Asset 1")
    }
    
    var womanImage:UIImage{
        return   (profile is RealProfile) ?
            //            #imageLiteral(resourceName: "girl-82"):#imageLiteral(resourceName: "girl-84")
            #imageLiteral(resourceName: "girl-82"):#imageLiteral(resourceName: "femme")
    }
    
    func changeGender(){
        if(profile.identifier==""){
            changedImage=true
            //image = (btnMan.isSelected==true) ? manImage : womanImage
            image = (btnWoman.isSelected==true) ? womanImage : manImage
            imgProfile.setImage(image, for: .normal)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        if !firstRealProfile{
        //            firstProfile ? leftBarBtn("", fontAwesome: .bars, actionStr: "showAlertRequiredMainProfile", target: self) : super.reavelViewControllerSettings()
        //        }
        if !firstRealProfile{
            reavelViewControllerSettings()
        }
        //        if !firstProfile{
        //            super.viewWillAppear(animated)
        //        }
        tabBarY()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabBarY()
    }
    
    func setFirstRealProfile(){
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -100, to: Date())
        datePicker.minimumDate = minDate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let someDateTime = formatter.date(from: "1990/01/01")
        datePicker.date = someDateTime!
        txtFldAge.inputAccessoryView = toolbarDatePicker
        txtFldAge.inputView = datePicker
 
        profile.username=(Auth.auth().currentUser?.displayName) != nil ? (Auth.auth().currentUser?.displayName)! : ""
        txtFldName.text = profile.username
        changedImage=true
        
        //        btnMan.isSelected=true//לגירסה של אפל
        btnOther.isSelected=true//לגירסה של אפל

        
        if(Auth.auth().currentUser!.photoURL != nil){
            //print(Auth.auth().currentUser?.photoURL)
            imgProfile.setImgwithUrl((Auth.auth().currentUser?.photoURL?.absoluteString)!)
            
            // image=manImage
        }else{
            imgProfile.setImage(#imageLiteral(resourceName: "default_profile_image"), for: .normal)

        }
        image=manImage
        setRealProfileLocalizedStrings()
        
        conHeightSecond.constant = 0
        
        viewUnenableChangeGender.isHidden = true
        //        btnMan.isEnabled = true
        //        btnWoman.isEnabled = true
        //        btnOther.isEnabled = true
        btnMan.iconColor = UIColor.exGreen
        btnMan.indicatorColor = UIColor.exGreen
        btnWoman.iconColor = UIColor.exGreen
        btnWoman.indicatorColor = UIColor.exGreen
        btnOther.iconColor = UIColor.exGreen
        btnOther.indicatorColor = UIColor.exGreen
        
        let alertController = UIAlertController(title: "wellcom".localized, message: "first_profile-msg".localized , preferredStyle: .alert)
        let okAction = UIAlertAction(title: "GO".localized, style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        alertController.addAction(okAction)
        
        DispatchQueue.main.async(execute: {
            self.present(alertController, animated: true, completion: nil)
        })
        //self.navigationController?.isNavigationBarHidden = true
    }
    
    
    func setProfile(){
        if currentReachabilityStatus != .notReachable{
            if firstProfile{
                conHeightSecond.constant = 0
                //ServerController.getCurrentProfile(function: serverReturn)
                setLocalizedStrings()
                if let currentPrivateProfile = ServerController.currentPrivateProfile{
                    profile.age = currentPrivateProfile.age != "" ? currentPrivateProfile.age.stringBirthdadyToAge() : ""
                    profile.gender = currentPrivateProfile.gender
                    txtFldAge.text=profile.age
                    setBtnsGender()
                    changedImage=true
                    image = (btnWoman.isSelected==true) ? womanImage : manImage
                    imgProfile.setImage(image,for:.normal)
       
                }else{//11/12/17
                    btnOther.isSelected=true
                }
                let alertController = UIAlertController(title: nil, message: "successfully_enrolled".localized , preferredStyle: .alert)
                let okAction = UIAlertAction(title: "GO".localized, style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    //                    self.showNativeActivityIndicator()
                    //                    (self.profile is RealProfile)  ? self.setCurrentRealProfile() : self.setCurrentProfile()
                }
                alertController.addAction(okAction)
                
                DispatchQueue.main.async(execute: {
                    self.present(alertController, animated: true, completion: nil)
                })
            }else{
                self.showNativeActivityIndicator()
                (profile is RealProfile)  ? setCurrentRealProfile() : setCurrentProfile()
            }
        }else{
            //self.showAlertViewNoInternent()//04/01/2018
            self.showAlertViewNoInternent {
                self.setProfile()
            }
        }
    }
    
    func  serverReturn(dic: [String : AnyObject]?){
        self.hideNativeActivityIndicator()
        //btnSave.isEnabled = true
        if dic != nil{
            profile.jsonToObject( jsonDictionary: dic)
            
            if(profile.identifier==""){
                if( profile is RealProfile){
                    if(Auth.auth().currentUser?.photoURL != nil){
                        profile.imageUrl=(Auth.auth().currentUser?.photoURL?.path)!
                    }
                    if(Auth.auth().currentUser?.displayName != nil){
                        profile.username=(Auth.auth().currentUser?.displayName)!
                    }
                    
                }
                changedImage=true
                //btnMan.isSelected=true//לגירסה של אפל
                btnOther.isSelected=true//לגירסה של אפל
                image=manImage
                
            }
            else{
                if(profile is RealProfile==false){
                    ServerController.currentMainProfile=profile
                    DispatchQueue.main.async {
                        //  DispatchQueue.global(qos: .background).async {
                        super.reavelViewControllerSettings()
                    }
                    //firstProfile = false
                }
            }
            setProfileValues()
        }else{
            if let currentPrivateProfile = ServerController.currentPrivateProfile{
                profile.age = currentPrivateProfile.age != "" ? currentPrivateProfile.age.stringBirthdadyToAge() : ""
                profile.gender = currentPrivateProfile.gender
                txtFldAge.text=profile.age
                setBtnsGender()
                changedImage=true
                image = (btnWoman.isSelected==true) ? womanImage : manImage
                imgProfile.setImage(image,for:.normal)

            }else{
                setFirstRealProfile()
            }
        }
    }
    
    func setCurrentRealProfile(){
        conHeightSecond.constant = /*80*/0//לגירסה של אפל
        imgProfile.setImage(#imageLiteral(resourceName: "default_profile_image"), for: .normal)

        ServerController.getRealCurrentProfile(function: serverReturn)
        //topBackBlackConst.constant=0
        setRealProfileLocalizedStrings()
//        txtFldName.isEnabled = false//לגירסה של אפל
//        txtFldAge.isEnabled = false//לגירסה של אפל
        let btnIcon = AppDelegate.isRTL ? FontAwesome.chevronRight : FontAwesome.chevronLeft
        btnBack.textFontAwesome(btnIcon)
        lblTitle.text = "Real profile".localized
        
        if DeviceType.IS_IPAD {
            setIpadRealProfileConstrain()
        }else if DeviceType.IS_IPHONE_5{
            setIphon5RealProfileConstrain()
        }
        
        datePicker.datePickerMode = .date//לגירסה של אפל
        datePicker.maximumDate = Date()//לגירסה של אפל
        let calendar = Calendar.current//לגירסה של אפל
        let minDate = calendar.date(byAdding: .year, value: -100, to: Date())//לגירסה של אפל
        datePicker.minimumDate = minDate//לגירסה של אפל
        let formatter = DateFormatter()//לגירסה של אפל
        formatter.dateFormat = "yyyy/MM/dd"//לגירסה של אפל
        let someDateTime = formatter.date(from: "1990/01/01")//לגירסה של אפל
        datePicker.date = someDateTime!//לגירסה של אפל
        txtFldAge.inputAccessoryView = toolbarDatePicker//לגירסה של אפל
        txtFldAge.inputView = datePicker//לגירסה של אפל
    }
    
    func setCurrentProfile(){
        conHeightSecond.constant = 0
        ServerController.getCurrentProfile(function: serverReturn)
        setLocalizedStrings()
    }
    
    func  setProfileValues(){
        txtFldName.text=profile.username
        txtFldAboutMe.text=profile.something
        txtFldAge.text=profile.age
        txtFldProfession.text=profile.profession
//        let imgUrl = profile.imageUrl
//        imgProfile.setImgwithUrl(profile.imageUrl)
        imgProfile.setImgwithUrl(profile.imageUrl, contentMode: .center)

        setBtnsGender()
    }
    
    func setBtnsGender(){
        if(profile.gender==Gender.man.description){
            btnMan.isSelected=true
        }
        else if(profile.gender==Gender.woman.description){
            btnWoman.isSelected=true
        }else if(profile.gender==Gender.other.description){
            btnOther.isSelected=true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func setviewUp(_ animYhight: CGFloat) {
        super.setviewUp(animYhight)

    }
    
    override   func keyboardWillHide(_ notification: Notification) {
        // super.keyboardWillHide(notification)
        self.view.endEditing(true)
        self.view!.frame = CGRect(x: self.view!.frame.origin.x, y: 0, width: self.view!.frame.size.width, height: self.view!.frame.size.height)
        tabBarY()
    }
    
    var jumpView = false
    var toJump:CGFloat = 0
    func tabBarY(){
        if(view.frame.origin.y==0 && fromMenu == false){
            let y = (self.navigationController?.navigationBar.frame.size.height)!+UIApplication.shared.statusBarFrame.height
            self.tabBarController?.tabBar.frame.origin.y = y
            self.tabBarController?.tabBar.frame.size.height = 80
            
//            self.topViewTopSpace.constant = 100
        }else if fromMenu == true{

        }
    }
    
    func closeDatePickerKeyboard(){
        txtFldAge.resignFirstResponder()
        txtFldAge.superview?.resignFirstResponder()
    }
    
    func setTextOnTxt(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        txtFldAge.text = "\(dateFormatter.string(from: datePicker.date))"
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !firstRealProfile && textField == txtFldAge{
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 3 // Bool
        }
        if textField == txtFldProfession || textField == txtFldAboutMe{
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 35 // Bool
        }
        return true
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
