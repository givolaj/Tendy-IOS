//
//  LoginViewController.swift
//  Tendy
//
//  Created by Shaya Fredman on 13/09/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import FontAwesome_swift
import FBSDKLoginKit

class LoginViewController: SuperViewController,UIDocumentInteractionControllerDelegate {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblConnectTitle: UILabel!
    @IBOutlet weak var btnPhon: UIButton!
    @IBAction func tapConnectByPhone(_ sender: UIButton) {
    }
    @IBOutlet weak var lblPhoneIcon: UILabel!
    @IBOutlet weak var lblOrTitle: UILabel!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBAction func tapConnectByFacebook(_ sender: UIButton) {
        self.showNativeActivityIndicator()
//        let parameters:[Any] = ["fields": "id,location,name,first_name,last_name,picture.type(large),email,birthday,gender,bio,relationship_status"]
//        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
//            if (error == nil){
//                print(result ?? <#default value#>)
//                result.valueForKey("email") as! String
//                result.valueForKey("id") as! String
//                result.valueForKey("name") as! String
//                result.valueForKey("first_name") as! String
//                result.valueForKey("last_name") as! String
//            }
//        })
        
        
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logOut()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                self.hideNativeActivityIndicator()
                UIApplication.shared.endIgnoringInteractionEvents()
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                UIApplication.shared.endIgnoringInteractionEvents()
                self.hideNativeActivityIndicator()
                return
            }
           
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            ServerController.loginWithCredential(credential, function: self.serverReturn)
        }
    }
    
    func getFBUserData(){
//            ["fields": "id, name, first_name, last_name, picture.type(large), email, gender, birthday"]
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "gender, birthday"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                   // print(result)
                    let user = Auth.auth().currentUser!
                    if let dic = result as? [String:String]{
                        let profile:RealProfile=RealProfile()
                        profile.gender=dic["gender"] != nil ? dic["gender"]! == "male" ? Gender.man.description : dic["gender"]! == "female" ? Gender.woman.description : Gender.other.description : Gender.other.description
                        profile.username=user.displayName != nil ? user.displayName! : ""
                        
//                        let bd = "11/30/1982".split(separator: "/")
//                        if bd.count == 3{
//                            profile.age = bd[1] + "/" + bd[0] + "/" + bd[2]
//                        }
                        
                        if let birthday = dic["birthday"] {
                            let bd = birthday.split(separator: "/")
                            if bd.count == 3{
//                                11/30/1982
                                profile.age = bd[1] + "/" + bd[0] + "/" + bd[2]
                            }
                        }
//                        profile.age=dic["birthday"] != nil ? dic["birthday"]! : ""
                        profile.identifier=user.uid
                        profile.pushToken = ServerController.deviceToken
                        profile.deviceType = DeviceTypeEnum.iphone.rawValue
                        if(user.photoURL != nil){
                            UIImage().downloadedFrom(link: (user.photoURL?.absoluteString)!, completion: { (isSuccess, image) in
                               self.creatFirstProfile(image: image, profile: profile)
                            })
                        }else{
                            self.creatFirstProfile(image: profile.gender == Gender.woman.description ? #imageLiteral(resourceName: "girl-82") : #imageLiteral(resourceName: "default_profile_image") , profile: profile)
                        }
                    }
                }else{
                    self.hideNativeActivityIndicator()
                }
            })
    }
    
    func creatFirstProfile(image:UIImage, profile:Profile){
        ServerController.saveImgProfie(image: image, profile: profile, function: { (error, ref) in
            ServerController.currentPrivateProfile=profile
            self.hideNativeActivityIndicator()
            UIApplication.shared.endIgnoringInteractionEvents()
            self.goToPageMain()
        })
    }
        
    @IBOutlet weak var lblFacebookIcon: UILabel!
    @IBOutlet weak var btnTermsAndConditions: UIButton!
    @IBAction func tapTermsAndConditions(_ sender: UIButton) {
        guard let url = Bundle.main.url(forResource:"terms", withExtension: "pdf")else {
            return
        }
                let documentInteractionController = UIDocumentInteractionController(url: url)
                documentInteractionController.delegate = self
                documentInteractionController.presentPreview(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSettings()
        setDegine()
        setLocalizedStrings()
        
        UIApplication.shared.applicationIconBadgeNumber=0
        // Do any additional setup after loading the view.
    }
    
    func navigationSettings(){
        self.navigationController?.isNavigationBarHidden=false
        navigationItem.hidesBackButton = true
    }
    
    func setDegine(){
        lblPhoneIcon.font = UIFont.fontAwesome(ofSize: 25)
        lblPhoneIcon.text = String.fontAwesomeIcon(name: .phone)
        lblFacebookIcon.font = UIFont.fontAwesome(ofSize: 25)
        lblFacebookIcon.text = String.fontAwesomeIcon(name: .facebookSquare)
        
        btnPhon.round()
        btnFacebook.round()
    }
    
    func setLocalizedStrings(){
        self.title="Login".localized
        lblTitle.text = "loginTitle".localized
        lblConnectTitle.text = "connectTitle".localized
        lblOrTitle.text = "Or".localized
        btnPhon.setTitle("PhoneNum".localized, for: .normal)
        btnFacebook.setTitle("facebook".localized, for: .normal)
        btnTermsAndConditions.setTitle("terms&condition".localized, for: .normal)
    }
    
    func serverReturn(_ user:User?,_ error:Error? ){
        if error == nil{
            loginSucced(user)
        }else{
            self.hideNativeActivityIndicator()
            UIApplication.shared.endIgnoringInteractionEvents()
            self.showAlertView(title:"ERROR".localized,error!.localizedDescription)
        }
       // error==nil ?  loginSucced(user ): self.showAlertView(title:"ERROR".localized,error!.localizedDescription)
    }
    
    func loginSucced(_ user:User?){
//        self.hideNativeActivityIndicator()//11/12/17
//        UIApplication.shared.endIgnoringInteractionEvents()
        //UserDefaults.standard.set( txtFldMail.text!, forKey:C.DataBase.Mail )
        UserDefaults.standard.set( user?.email , forKey:C.DataBase.Mail )
        UserDefaults.standard.set( (user?.uid)!, forKey:C.DataBase.Uid )
        ServerController.getOnceRealCurrentProfile { (dicPrivateProfile, error) in
            if error != nil{
                //self.showAlertViewNoInternent()//04/01/2018
//                self.showAlertViewNoInternent {
//                    self.loginSucced(user)
//                }
            }else{
                let privateProfile = RealProfile( dic: dicPrivateProfile)
                if privateProfile.identifier != ""{
                    ServerController.currentPrivateProfile=privateProfile
                    self.hideNativeActivityIndicator()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.goToPageMain()
                }else{
                    self.getFBUserData()//11/12/17
                }
                
            }
        }
        
//        goToPageMain()//11/12/17
        
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController{
        return self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
