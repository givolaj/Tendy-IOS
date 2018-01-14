//
//  LoginRegisterViewController.swift
//  Tendy
//
//  Created by ATN on 30/07/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import FontAwesome_swift

class LoginRegisterViewController: SuperViewController {
    
    @IBOutlet weak var txFldUserName: UnderLineTextField!
    @IBOutlet weak var txtFldMail: UnderLineTextField!
    @IBOutlet weak var txtFldPassword: UnderLineTextField!
    @IBOutlet weak var txtFldOKPassword: UnderLineTextField!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var btnLoginRegister: UIButton!
    @IBOutlet weak var btnLoginRegistrConst: NSLayoutConstraint!
    @IBOutlet weak var btnloginWithFacebook: UIButton!
    @IBOutlet weak var lblFacebookIcon: UILabel!
    @IBOutlet weak var lblLoginToPacebookTitle: UILabel!
    var islogin=true
    
    @IBAction func forgotPasswordClick(_ sender: Any) {
        ServerController.forgotPassword(mail: txtFldMail.text!) { (error) in
             error==nil ? self.showAlertView(C.Alert.resetPassword) : self.showAlertView(title:"ERROR".localized,error!.localizedDescription)
        }
    }
    
    @IBAction func loginRegisterClick(_ sender: Any) {
        isSetAllFields() ? next(): self.showAlertView(C.Alert.setAllFileds)
    }
    
    @IBAction func statusClick(_ sender: Any) {
        changeStatus()
        (islogin) ? loginSetings():registerSettings()
    }
    
    @IBAction func loginWithFacebookClick(_ sender: UIButton) {
        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture.type(large)"])
        let _ = request?.start(completionHandler: { (connection, result, error) in
            guard let userInfo = result as? [String: Any] else { return } //handle the error
            
            //The url is nested 3 layers deep into the result so it's pretty messy
            if let imageURL = ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                //Download image from imageURL
            }
        })
        
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            ServerController.loginWithCredential(credential, function: self.serverReturn)
        }
        
//        let fbLoginManager = FBSDKLoginManager()
//        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
//            if let error = error {
//                print("Failed to login: \(error.localizedDescription)")
//                return
//            }
//            guard let accessToken = FBSDKAccessToken.current() else {
//                print("Failed to get access token")
//                return
//            }
//            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
//            ServerController.loginWithCredential(credential, function: self.serverReturn)
//        }

    }
    
    func isSetAllFields()->Bool{
        return ((!txtFldMail.isEmpty) && (!txtFldPassword.isEmpty))&&(islogin || !islogin && !txtFldOKPassword.isEmpty && !txFldUserName.isEmpty)
    }
    
    func next(){
        (islogin) ? login() : register()
    }
    
    func login(){
        ServerController.login(self.txtFldMail.text!, password: self.txtFldPassword.text!, function: serverReturn)
    }
    
    func register(){
        if(txtFldPassword.text==txtFldOKPassword.text){
        ServerController.register(self.txtFldMail.text!, password: self.txtFldPassword.text!,txFldUserName.text!, function: serverReturnRegister)
        }
        else{
            showAlertView(C.Alert.passwordOk)
        }
    }
    
    func changeStatus(){
        islogin = !islogin
        btnForgotPassword.isHidden = !btnForgotPassword.isHidden
        txtFldOKPassword.isHidden = !txtFldOKPassword.isHidden
        txFldUserName.isHidden = !txFldUserName.isHidden
    }
    
    func registerSettings(){
        btnLoginRegister.setTitle("REGISTER".localized,for: .normal)
        btnStatus.setTitle("have an account? sign in!".localized,for: .normal)
        btnLoginRegistrConst.constant=120
        self.title="Register".localized
    }
    
    func loginSetings(){
        btnLoginRegister.setTitle("LOGIN".localized,for: .normal)
        btnStatus.setTitle("don't have an account? register!".localized,for: .normal)
        btnLoginRegistrConst.constant=30
        self.title="Login".localized
    }
    
    func serverReturn(_ user:User?,_ error:Error? ){
        error==nil ?  loginSucced(user ): self.showAlertView(title:"ERROR".localized,error!.localizedDescription)
    }
    
    func serverReturnRegister(_ user:User?,_ error:Error? ){
        error==nil ?   registerSucced(user ): self.showAlertView(title:"ERROR".localized,error!.localizedDescription)

    }

    func registerSucced(_ user:User?){
        loginSucced(user )
        showAlertView( C.Alert.registerSucceed)

    }
    
    func loginSucced(_ user:User?){
        //UserDefaults.standard.set( txtFldMail.text!, forKey:C.DataBase.Mail )
        UserDefaults.standard.set( user?.email , forKey:C.DataBase.Mail )
        UserDefaults.standard.set( (user?.uid)!, forKey:C.DataBase.Uid )
        goToPageMain()

    }
    
    func navigationSettings(){
        self.navigationController?.isNavigationBarHidden=false
        navigationItem.hidesBackButton = true
    }
    
    func testLogin(){
        txtFldPassword.text="123456"
        txtFldMail.text="tami@gmail.com"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSettings()
        testLogin()
        lblFacebookIcon.font = UIFont.fontAwesome(ofSize: 25)
        lblFacebookIcon.text = String.fontAwesomeIcon(name: .facebookSquare)
        
        setLocalizedStrings()
    }
    
    func setLocalizedStrings(){
        self.title="Login".localized
        txtFldMail.placeholder = "Email".localized
        txtFldPassword.placeholder = "Password".localized
        btnForgotPassword.setTitle("Forgot your password".localized, for: .normal)
        lblLoginToPacebookTitle.text = "Login with facebook".localized
        txtFldOKPassword.placeholder = "Password Again".localized
        txFldUserName.placeholder = "Name".localized
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
