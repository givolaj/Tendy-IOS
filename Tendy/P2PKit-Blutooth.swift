//
//  P2PKit-Blutooth.swift
//  Tendy
//
//  Created by Shaya Fredman on 23/08/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit
import SWRevealViewController

class P2PKit_Blutooth :NSObject, PPKControllerDelegate{
    final class var sharedInstance : P2PKit_Blutooth {
        struct Static {
            static var instance : P2PKit_Blutooth?
        }
        if !(Static.instance != nil) {
            Static.instance = P2PKit_Blutooth()
            
        }
        return Static.instance!
    }
    
    var blutoothConnect = false
    var blutoothAlertShow = false
    var isShowedBlutoothAlert = false//dont show alet more then once
    
    func firstEnable(){
        if !PPKController.isEnabled(){
         PPKController.enable(withConfiguration: "16321ccfa0254c2b87d5f2673f386eee", observer: self)
        }
    }
    
    func enabled(){
        if blutoothConnect == true{
            if !PPKController.isEnabled(){
                PPKController.enable(withConfiguration: "16321ccfa0254c2b87d5f2673f386eee", observer: self)
            }
        }else{
            if blutoothAlertShow == false && isShowedBlutoothAlert == false{
                blutoothAlertShow = true
                isShowedBlutoothAlert = true
                UIApplication.topViewController()?.showAlertWith(title: "ERROR".localized, message: "Turn on the Blutooth".localized, buttons: ["OK".localized,"Cancel".localized], completion: { (btnNum) in
                    if btnNum == 0{
                        self.blutoothAlertShow = false
                        let url = URL(string: "App-Prefs:root=Bluetooth")
                        let app = UIApplication.shared
                        app.openURL(url!)
                    }else if btnNum == 1{
                        self.blutoothAlertShow = false
                    }
                })
                
                
                
            }
        }
    }
    
    func disable() {
        if PPKController.isEnabled(){
            stopDiscovery()
            PPKController.disable()
        }
//        else{
//            enabled()
//            stopDiscovery()
//        }
    }
    
    func startDiscovery(){
        //if PPKController.discoveryState() == .running{
        //    PPKController.pushNewDiscoveryInfo(ServerController.currentUserId.data(using: .utf8))
       // }
       // else{
        if(ServerController.isLoggedIn)
        {
            PPKController.startDiscovery(withDiscoveryInfo: ServerController.currentUserId.data(using: .utf8), stateRestoration: true)
        }
    }
    
    func stopDiscovery(){
        //if PPKController.discoveryState() != .stopped{
            PPKController.stopDiscovery()
       // }
    }
    
    func isEnabled() -> Bool {
        return PPKController.isEnabled()
    }
    
    func enableProximityRanging(){
        PPKController.enableProximityRanging()
    }
    
    // MARK: - PPKControllerDelegate
    func ppkControllerInitialized() {
        //  nearbyPeersViewController.setup()
    }
    
    func ppkControllerFailedWithError(_ error: PPKErrorCode) {
        var description: String!
        switch error {
        case .invalidAppKey:
            description = "Invalid app key"
        case .invalidBundleId:
            description = "Invalid bundle ID"
        case .incompatibleClientVersion:
            description = "Incompatible p2pkit (SDK) version, please update"
        default:
            description = "Unknown error"
        }
    }
    
    func discoveryStateChanged(_ state: PPKDiscoveryState) {
        if state == .stopped {
            // nearbyPeersViewController.removeNodesForAllPeers()
        }
        else if state == .unauthorized {
            // showErrorDialog("p2pkit cannot run because it is missing a user permission", withRetryBlock: nil)
        }
        else if state == .unsupported {
            // showErrorDialog("p2pkit is not supported on this device", withRetryBlock: nil)
        }
        
    }
    
    //PPKControllerDelegate
    func peerDiscovered(_ peer: PPKPeer) {
        if let discoveryInfo = peer.discoveryInfo {
            let discoveryInfoString = String(data: discoveryInfo, encoding: .utf8)!
            print("\(peer.peerID) is here with discovery info: \(discoveryInfoString)")
            DispatchQueue.global(qos: .background).async {
                self.getBluttothData(userId: discoveryInfoString)
            }
        }
    }
    
    func getBluttothData(userId:String){
        if userId != ServerController.currentUserId{
            //ServerController.getChatPartner(id: userId) { (partner:[String : AnyObject]?) in
                ServerController.getOnceChatPartner(id: userId) { (partner:[String : AnyObject]?, error:Error?) in
                if partner == nil{
                    var newProfileDiscoveryNumber = 0
                    ServerController.getProfile(ProfileId: userId, function: { ( profile:[String : AnyObject]?) in
                        if profile != nil{
//                            DispatchQueue.main.async {
//                                print("discovery user : \(userId) is name: \(profile!["username"]!)")
//                            }
                            if var partnersAroundJson = UserDefaults.standard.value(forKey: C.userDef.partnersAroundJson) as? [String : [String:AnyObject]]{
                                //profile?["DiscoveredDate"] = NSDate()
                                if partnersAroundJson[userId] == nil{
                                   newProfileDiscoveryNumber = partnersAroundJson.count + 1
                                   //LocalNoteficationManager.sharedInstance.addDiscoveryNotification(profileDiscoveryNumber: partnersAroundJson.count + 1)
                                }
                                partnersAroundJson[userId] = profile
                                partnersAroundJson[userId]?["discoveredDate"] = NSDate()
                                UserDefaults.standard.set(partnersAroundJson, forKey: C.userDef.partnersAroundJson)
                                UserDefaults.standard.synchronize()
                               // LocalNoteficationManager.sharedInstance.addDiscoveryNotification(profileDiscoveryNumber: partnersAroundJson.count)
                                /*
                                 if let chatPartener = partnersAroundJson[userId]{
                                 partnersAroundJson[userId] = profile
                                 }else{
                                 
                                 }
                                 */
                                //    let partnersAroundArrDic = partnersAroundJson.convertToAnyObjectDictionary()
                            }else{//First profile dicoverd
                                var partnersAroundJson = [String : [String:AnyObject]]()
                                partnersAroundJson[userId] = profile
                                partnersAroundJson[userId]?["discoveredDate"] = NSDate()
                                UserDefaults.standard.set(partnersAroundJson, forKey: C.userDef.partnersAroundJson)
                                UserDefaults.standard.synchronize()
                                newProfileDiscoveryNumber = 1
                                //LocalNoteficationManager.sharedInstance.addDiscoveryNotification(profileDiscoveryNumber: 1)
                            }
                        }
                       // let appDelegate  = UIApplication.shared.delegate as! AppDelegate
                        let discoveryViewController = ((((ServerController.appDelegate.window?.rootViewController) as? SWRevealViewController)?.frontViewController as? UITabBarController)?.selectedViewController as? UINavigationController)?.viewControllers.last as? DiscoveryViewController
                        if  discoveryViewController != nil && UIApplication.shared.applicationState == .active{
                            DispatchQueue.main.async {
                                discoveryViewController?.discoveryList()
                            }
                        }else{
                            if newProfileDiscoveryNumber > 0{
                                if self.isEnabled(){
                                LocalNoteficationManager.sharedInstance.addDiscoveryNotification(profileDiscoveryNumber: newProfileDiscoveryNumber)
                                }
                            }
                        }
                        //                    if let sWRevealViewController = self.window?.rootViewController as? SWRevealViewController{
                        //                        (((sWRevealViewController).frontViewController as! UINavigationController).viewControllers.last as! DiscoveryViewController)
                        //                    }
                        
                    })
                    
                }else{
                    // print("user exsit in ChatPartner: \(userId) is name: \(partner!["username"]!)")
                    let partner = ChatPartners(dic: partner)
                    if partner.status != State.blocked.rawValue{//no bloked
                        if partner.dateAdded != ""{//no forever
                            let dateDouble = Double(partner.dateAdded)
                            var seconds:Double=1
                            if(dateDouble != nil){
                                seconds=CHAT_VALIDITY_INTERVAL - (Date().timeIntervalSince1970*1000 + ServerController.currentmillisAppStart - dateDouble!)
                            }
                            if seconds <= 0 {
//                                ServerController.deleteChatPartner(partnerId: partner.profile.identifier, function: { (err, ref) in
//                                    print("delete partener and chat!")
//                                })
                                
                                ServerController.deleteChatPartner(partnerId: userId, function: { (err, ref) in
                                    print("delete partener and chat!")
                                })
                            }
                        }
                    }
                    print("user exsit in ChatPartner: \(userId)")
                }
            }
            
        }
    }
    
    func peerLost(_ peer: PPKPeer) {
        print("\(peer.peerID) is no longer here")
    }
    
    func discoveryInfoUpdated(for peer: PPKPeer) {
        if let discoveryInfo = peer.discoveryInfo {
            let discoveryInfoString = String(data: discoveryInfo, encoding: .utf8)!
            print("\(peer.peerID) has updated discovery info: \(discoveryInfoString)")
        }
    }
    
    
    
    func proximityStrengthChanged(for peer: PPKPeer) {
        if (peer.proximityStrength.rawValue > PPKProximityStrength.weak.rawValue) {
            print("\(peer.peerID) is in range, do something with it")
        }
        else {
            print("\(peer.peerID) is not yet in range")
        }
    }
    
    func discoveryStateChanged(state:PPKDiscoveryState){
        
    }
    
    
    func messageReceived(_message :NSData , fromNearbyPeer _peer: PPKPeer){
        
    }
    
    
}
