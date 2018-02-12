//
//  MenuViewController.swift
//  Tendy
//
//  Created by ATN on 31/07/2017.
//  Copyright © 2017 ATN. All rights reserved.
//



import UIKit
import Foundation
import UIKit
import Firebase
import FirebaseAuth
import SWRevealViewController
import MessageUI
import UserNotifications

class MenuViewController: SuperViewController ,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,MFMailComposeViewControllerDelegate{
    
    @IBOutlet weak var lblMail: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var tblMenu: UITableView!
    @IBOutlet weak var lblIconMail: UILabel!
    @IBOutlet weak var lblIconUser: UILabel!
    @IBOutlet weak var btnImg: RoundButton!
    @IBOutlet weak var lblVersion: UILabel!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var discoveryViewController:DiscoveryViewController!
    
    //var  arrMenu=["Account settings","log out"]
    var  arrMenu=["Account settings".localized,"Discovery state".localized,"Support".localized,"Log out".localized]
//    "Account settings" = "הגדרות חשבון";
//    "Discovery state" = "מצב נראות";
//    "On" = "גלוי";
//    "Off" = "חבוי";
//    "Support" = "פנה לתמיכה";
//    "Log out" = "התנתק";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.exDarkGray
        tblMenu.tableFooterView = UIView(frame: .zero)
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            lblVersion.text = "version".localized + " " + version
        }
         if DeviceType.IS_IPAD {
            tblMenu.rowHeight = 55
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if discoveryViewController == nil{
            if let sWRevealViewController = appDelegate.window?.rootViewController as? SWRevealViewController{
                if let tabBarController = sWRevealViewController.frontViewController as? CustomTabBarController{
                    if let navigationController = tabBarController.selectedViewController as? UINavigationController{
                        if let vc = navigationController.viewControllers.last as? DiscoveryViewController{
                            discoveryViewController = vc
                        }
                    }
                }
            }
        }
        tblMenu.reloadData()
        setProfile()
    }
    
    
    func setProfile(){
        //lblName.text=Auth.auth().currentUser?.displayName
        let font = UIFont.fontAwesome(ofSize: 20)
        var text = String.fontAwesomeIcon(name: .user)
        lblIconUser.attributedText =  NSAttributedString(string: text, attributes: [NSFontAttributeName: font ,NSForegroundColorAttributeName: UIColor.white])
        text = String.fontAwesomeIcon(name: .envelope)
        lblIconMail.attributedText =  NSAttributedString(string: text, attributes: [NSFontAttributeName: font ,NSForegroundColorAttributeName: UIColor.white])
        lblMail.text = UserDefaults.standard.object(forKey:C.DataBase.Mail ) as? String
//      if(Auth.auth().currentUser!.photoURL != nil){
//        //btnImg.setImgwithUrl((Auth.auth().currentUser!.photoURL?.absoluteString)!)
//        btnImg.setImgwithUrl((Auth.auth().currentUser?.photoURL?.absoluteString)!, contentMode: .scaleToFill)
//        }
        if ServerController.currentPrivateProfile != nil{
            lblName.text = ServerController.currentPrivateProfile!.username
            btnImg.setImgwithUrl(ServerController.currentPrivateProfile!.imageUrl)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func removeObjectUserDefaults(){
        try! Auth.auth().signOut()
        UserDefaults.standard.removeObject(forKey: C.DataBase.Uid)
        UserDefaults.standard.removeObject(forKey: C.DataBase.Mail)
        UserDefaults.standard.removeObject(forKey: C.userDef.chatBadges)
        UserDefaults.standard.removeObject(forKey: C.userDef.partnersAroundJson)
        UserDefaults.standard.synchronize()
    }
    
    func supportActivity(){
//        let shareText = "Checkout my latest app #coolapp"
//        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
//        // exclude some activity types from the list (optional)
//        activityViewController.excludedActivityTypes = [ UIActivityType.mail]
//        present(activityViewController, animated: true, completion: nil)
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["atn.tendi@gmail.com"])
            mail.setSubject("Support request - \(ServerController.currentUserId)")
          //  mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func showAlert(){
        DispatchQueue.main.async(execute: {
        self.showAlertView(title: "Log out".localized, msg: "log out mesg".localized, otherButtonTitle: "Cancel".localized , okFunction: {
            DispatchQueue.main.async(execute: {
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                appDelegate.goToPageLogin()
                ServerController.appDelegate.goToPageLogin()
                ServerController.appDelegate.stopDiscoveryTimer()
                ServerController.currentMainProfile = nil
                ServerController.currentPrivateProfile = nil
                UIApplication.shared.unregisterForRemoteNotifications()
                InstanceID.instanceID().deleteID(handler: { (error) in
                   // InstanceID.instanceID().token()
                })
                //Messaging.messaging().shouldEstablishDirectChannel = false
                if #available(iOS 10.0, *) {
                    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                } else {
                    // Fallback on earlier versions
                }
                ServerController.removeAllObservers()
                self.removeObjectUserDefaults()
                //UIApplication.shared.applicationIconBadgeNumber=0
            })
        }, otherFunction: {})})
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if arrMenu[indexPath.row]=="Discovery state".localized {
            AppDelegate.discovery ? appDelegate.stopDiscoveryTimer() : appDelegate.startDiscoveryTimer()
            let cell = tableView.cellForRow(at: indexPath) as! BlutoothMenuStatusTableViewCell
            cell.setStatus()
            discoveryViewController?.setDiscoveryStatus()
        }else if arrMenu[indexPath.row]=="Support".localized {
            supportActivity()
        }else if arrMenu[indexPath.row]=="Log out".localized {
            showAlert()
        }else{
            DispatchQueue.main.async(execute: {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let profileVC = mainStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            profileVC.fromMenu = true
            profileVC.profile=RealProfile()

            self.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            self.present(profileVC, animated: false, completion: nil)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if arrMenu[indexPath.row] == "Discovery state".localized{
            let cell = tableView.dequeueReusableCell(withIdentifier: "BlutoothMenuStatusTableViewCell") as! BlutoothMenuStatusTableViewCell
            cell.lblTitle.text = "Discovery state".localized
            cell.setStatus()
            return cell
        }
//        let cell = tableView.dequeueReusableCell(withIdentifier: C.Cell.MenuCell)!
//        cell.textLabel!.text=arrMenu[indexPath.row]
//        cell.separatorInset.bottom = 100
        let cell = tableView.dequeueReusableCell(withIdentifier: C.Cell.MenuCell) as! MenuCell
        cell.lblTitle.text=arrMenu[indexPath.row]
        //cell.separatorInset.bottom = 100
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier==C.Segue.RealProfileSegue)
        {
           (( segue.destination as! UINavigationController).viewControllers[0] as! ProfileViewController).profile=RealProfile()
        }
        
    }
    
    
    
}

