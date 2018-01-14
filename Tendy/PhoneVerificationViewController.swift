//
//  PhoneVerificationViewController.swift
//  Tendy
//
//  Created by Shaya Fredman on 13/09/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit
import Firebase

class PhoneVerificationViewController: SuperViewController {
    
    var verificationID = ""
    var codeTimer = Timer()
    var secondsToSend = 0
    var credential:PhoneAuthCredential!
    var alertControllerEnterCode:UIAlertController!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtPhone: UnderLineTextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBAction func tapSend(_ sender: UIButton) {
        if secondsToSend > 0{
            self.showAlertView(title:"Problem".localized,"problem alert".localized)
            return
        }
       sendCode()
    }

    @IBOutlet weak var btnEnterCode: UIButton!
    @IBAction func tapEnterCode(_ sender: UIButton) {
        if secondsToSend > 0{
            showAlertEnterCode()
        }else{
            sendCode()
        }
    }
    
    func sendCode(){
        var phone  = self.txtPhone.text!
        if phone.characters.count != 10{
             self.showAlertView(title:"Problem".localized,"Invalide phone".localized)
            return
        }
        phone.remove(at: phone.startIndex)
        phone = "+972" + phone
        self.showNativeActivityIndicator()
        PhoneAuthProvider.provider().verifyPhoneNumber(phone) { (verificationID, error) in
            if let error = error {
                self.hideNativeActivityIndicator()
//                self.showAlertView(title:"ERROR".localized,error.localizedDescription)
                self.showAlertView(title:"ERROR".localized,"TryLater".localized)
                return
            }else{
                self.verificationID = verificationID != nil ? verificationID! : ""
                self.startTimer()
                self.hideNativeActivityIndicator()
                self.showAlertEnterCode()
            }
        }
    }
    
    func showAlertEnterCode(){
        var inputTextField=UITextField()
        alertControllerEnterCode = UIAlertController(title: "Code sent title".localized, message: "Code sent massege".localized, preferredStyle: .alert)
        alertControllerEnterCode.addTextField { textField -> Void in
            inputTextField = textField
            inputTextField.keyboardType = .numberPad
            inputTextField.placeholder = "enter code holder".localized
        }
        let okAction = UIAlertAction(title: "GO".localized, style: UIAlertActionStyle.default) {
            UIAlertAction in
            if(inputTextField.text?.isEmpty)!{
                self.showAlertView(title: "Problem".localized, msg: "problem code".localized, okFunction: {
                    DispatchQueue.main.async(execute: {
                        self.present(self.alertControllerEnterCode, animated: true, completion: nil)
                    })
                })
               // self.showAlertView(title:"Problem".localized,"problem code".localized)
            }else{
                if inputTextField.text?.count != 6{
                    self.showAlertView(title: "Problem".localized, msg: "problem code".localized, okFunction: {
                        DispatchQueue.main.async(execute: {
                            self.present(self.alertControllerEnterCode, animated: true, completion: nil)
                        })
                    })
                    return
                }
                self.showNativeActivityIndicator()
//                let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationID,verificationCode: inputTextField.text!)//04/01/2018
                self.credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationID,verificationCode: inputTextField.text!)
                ServerController.loginWithCredential(self.credential, function: self.serverReturn)
            }
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            inputTextField.resignFirstResponder()
        }
        alertControllerEnterCode.addAction(okAction)
        alertControllerEnterCode.addAction(cancelAction)
        if #available(iOS 9.0, *) {
            alertControllerEnterCode.preferredAction = okAction
        }
        DispatchQueue.main.async(execute: {
            self.present(self.alertControllerEnterCode, animated: true, completion: nil)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSettings()
        backBarBtn()
        btnEnterCode.titleLabel!.textAlignment = .center
        btnSend.round()
        // txtPhone.text = "0585612178"//אילה
        //txtPhone.text = "0529647147"//iphone5
        //txtPhone.text = "0503371563"//iphone6+
        // Do any additional setup after loading the view.
        setLocalizedStrings()
    }
    
    func setLocalizedStrings(){
        self.title="Phone Verification".localized
        lblTitle.text = "Verification title".localized
        txtPhone.placeholder = "Enter your phone number".localized
        btnSend.setTitle("SEND MESSAGE".localized, for: .normal)
        btnEnterCode.setTitle("Enter code title".localized, for: .normal)
    }
    
    func navigationSettings(){
        //self.navigationController?.isNavigationBarHidden=false
        navigationItem.hidesBackButton = false
    }
    
    func serverReturn(_ user:User?,_ error:Error? ){
        self.hideNativeActivityIndicator()
       // error==nil ?  loginSucced(user ):  DispatchQueue.main.async(execute: { self.showAlertView(title:"ERROR".localized,error!.localizedDescription)})
        
//        error==nil ?  loginSucced(user ): error.debugDescription.contains("Network error") ? self.showAlertViewNoInternent() :
//        DispatchQueue.main.async(execute: {self.showAlertView(title: "Problem".localized, msg: "problem code".localized, okFunction: {
//            DispatchQueue.main.async(execute: {
//                self.present(self.alertControllerEnterCode, animated: true, completion: nil)
//            })
//        })
//        })//04/01/2018
        error==nil ?  loginSucced(user ): error.debugDescription.contains("Network error") ? self.showAlertViewNoInternent {
            ServerController.loginWithCredential(self.credential, function: self.serverReturn)
            } :
            DispatchQueue.main.async(execute: {self.showAlertView(title: "Problem".localized, msg: "problem code".localized, okFunction: {
                DispatchQueue.main.async(execute: {
                    self.present(self.alertControllerEnterCode, animated: true, completion: nil)
                })
            })
            })
    }
    
    func loginSucced(_ user:User?){
        //UserDefaults.standard.set( txtFldMail.text!, forKey:C.DataBase.Mail )
        UserDefaults.standard.set( user?.email , forKey:C.DataBase.Mail )
        UserDefaults.standard.set( (user?.uid)!, forKey:C.DataBase.Uid )
//        ServerController.getRealCurrentProfile(function: serverReturnRealProfile)//11/12/17
        goToPageMain()//11/12/17
    }
    
    func  serverReturnRealProfile(dicPrivateProfile: [String : AnyObject]?){
        self.hideNativeActivityIndicator()
        let privateProfile = RealProfile( dic: dicPrivateProfile)
        ServerController.currentPrivateProfile=privateProfile
        if(privateProfile.identifier != ""){
            goToPageMain()
        }
        else{
            goToRealProfile()
        }
    }
    
    func startTimer(){
        codeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(PhoneVerificationViewController.timerTeak), userInfo: nil, repeats: true)
        secondsToSend = 60
    }
    
    func timerTeak(){
        if secondsToSend > 0{
            btnEnterCode.setTitle("didn't get title1".localized + String(secondsToSend) + "didn't get title2".localized, for: .normal)
            secondsToSend -= 1
        }else{
            btnEnterCode.setTitle("Enter code title".localized, for: .normal)
            codeTimer.invalidate()
        }
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
