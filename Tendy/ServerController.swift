//
//  Tendy
//
//  Created by ATN on 31/07/2017.
//  Copyright © 2017 ATN. All rights reserved.
//
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import CoreBluetooth
import UserNotifications
//import Alamofire


class ServerController{
    static var ref: DatabaseReference!
    static var currentMainProfile:Profile?
    static var currentPrivateProfile:Profile?
    static var deviceToken:String = ""
    static var interntWasConnect = false
    static let appDelegate  = UIApplication.shared.delegate as! AppDelegate
    static var currentUserId:String{
        return (Auth.auth().currentUser?.uid)!
    }
    
    static var isLoggedIn:Bool{
        return Auth.auth().currentUser != nil
    }
    
    static var currentmillisAppStart:Double = 0
    
    static func login(_ mail:String,password:String,controller:UIViewController?=nil, function: @escaping (_ user:User?,_ error:Error? )->())
    {
        Auth.auth().signIn(withEmail: mail, password: password) { (user, error) in
            function(user, error)
        }
    }
    
    static func loginWithCredential(_ credential:AuthCredential,controller:UIViewController?=nil, function: @escaping (_ user:User?,_ error:Error? )->())
    {
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.loginWithCredential(credential, controller: controller, function: function)
        }){
        Auth.auth().signIn(with: credential) { (user, error) in
            function(user, error)
        }
        }
    }
    
    
    static func register(_ mail:String,password:String,_ name:String,controller:UIViewController?=nil, function: @escaping (_ user:User?,_ error:Error? )->())
    {
        //if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.register(mail, password: password, name, controller: controller, function: function)
        }){
        Auth.auth().createUser(withEmail: mail, password: password) { (user, errorRegister) in
            let profile=RealProfile()
            profile.username=name
            // profile.identifier=currentUserId
            if(errorRegister != nil)
            {
                function(user, errorRegister)
                
            }
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = name
            changeRequest?.commitChanges { (error) in
                function(user, errorRegister)
                
            }
        }
        }
    }
    
    static func saveObject(key:String,tblName:String,dic:[String:AnyObject],function: @escaping (_ error:Error?,_ ref:DatabaseReference )->())
    {
        //if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.saveObject(key: key, tblName: tblName, dic: dic, function: function)
        }){
        ref = Database.database().reference()
        let childUpdates = ["/\(tblName)/\(key)": dic]
        ref.updateChildValues(childUpdates, withCompletionBlock: { (error, ref) in
            function(error,ref)
        })
        }
    }
    
    static func getProfiles(function: @escaping ([String : AnyObject]?)->()){
        getObject(name: C.DataBase.profiles,id: "" ,function: function)
    }
    
    static func getProfile(ProfileId:String, function: @escaping ([String : AnyObject]?)->())
    {
        getObject(name: C.DataBase.profiles,id: ProfileId ,function: function)
    }
    
    static func getOnceProfile(ProfileId:String, function: @escaping ([String : AnyObject]?)->())
    {
        getObject(name: C.DataBase.profiles,id: ProfileId ,function: function)
    }
    
    static func getChatPartners(function: @escaping ([String : AnyObject]?)->())
    {
        getObject(name: C.DataBase.chatPartners,id: currentUserId ,function: function)
    }
    
    static func getChatPartnersWithRef(function: @escaping ([String : AnyObject]?,DatabaseReference?)->())
    {
         getObjectReturnRef(name:  C.DataBase.chatPartners, id: currentUserId, function: function)
    }
    static func getChatPartner(id:String, function: @escaping ([String : AnyObject]?)->())
    {
        getObject(name: C.DataBase.chatPartners,id: "\(currentUserId)/\(id)" ,function: function)
    }
    
    static func getChatsPartnerWithRef(id:String,function: @escaping ([String : AnyObject]?,DatabaseReference?)->())
    {
        getObjectReturnRef(name:  C.DataBase.chatPartners, id: "\(currentUserId)/\(id)", function: function)
    }
    
    static func getOnceChatPartner(id:String, function: @escaping ([String : AnyObject]?,Error?)->())
    {
        getObjectWithoutListener(name: C.DataBase.chatPartners,id: "\(currentUserId)/\(id)" ,function: function)
       // getObject(name: C.DataBase.chatPartners,id: "\(currentUserId)/\(id)" ,function: function)
    }
    
    static func getChatPartnerStateAndProfile(id:String, function: @escaping ([String : AnyObject]?, Error?)->())
    {
        getObjectWithoutListener(name: C.DataBase.chatPartners, id: "\(id)/\(currentUserId)", function: function)
        //getObject(name: C.DataBase.chatPartners,id: "\(id)/\(currentUserId)" ,function: function)
    }
    static func setChatPartnerPrivateProfile(profile: Profile,status:State, function: @escaping (_ error:Error?,_ ref:DatabaseReference )->())
    {
        saveChatPrtnerBuddy(profile: profile,isPrivate:true, statusGet: status, function: function)
    }
    
    static func getChats(buddy:String,function: @escaping ([String : AnyObject]?)->())
    {
        getObject(name: C.DataBase.chats,id:getChatId( buddy: buddy),function: function)
    }
    
    static func getChatsWithRef(buddy:String,function: @escaping ([String : AnyObject]?,DatabaseReference?)->())
    {
        getObjectReturnRef(name:  C.DataBase.chats, id: getChatId( buddy: buddy), function: function)
    }
    
    static func getOnceChats(buddy:String,function: @escaping ([String : AnyObject]?,Error?)->())
    {
        getObjectWithoutListener(name: C.DataBase.chats, id: getChatId( buddy: buddy), function: function)
        //getObject(name: C.DataBase.chats,id:getChatId( buddy: buddy),function: function)
    }
    
    static func getObject(name:String,id:String,function: @escaping ([String : AnyObject]?)->())
    {
      //  if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.getObject(name: name, id: id, function: function)
        }){
        let ref = Database.database().reference(withPath: name+"/"+id)
        ref.observe(DataEventType.value, with: { (snapshot) in
            if let dic = snapshot.value as? [String : AnyObject]{
                function(dic)
            }else{
                function(nil)
            }
//            let dict = snapshot.value as? [String : AnyObject] ?? nil
//            function(dict)
        }){ (error) in
            print(error.localizedDescription)
        }
        }
        
    }
    
    static func getObjectReturnRef(name:String,id:String,function: @escaping ([String : AnyObject]?,DatabaseReference?)->())
    {
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.getObjectReturnRef(name: name, id: id, function: function)
        }){
            let ref = Database.database().reference(withPath: name+"/"+id)
            ref.observe(DataEventType.value, with: { (snapshot) in
                if let dic = snapshot.value as? [String : AnyObject]{
                    function(dic,ref)
                }else{
                    function(nil,nil)
                }
                //            let dict = snapshot.value as? [String : AnyObject] ?? nil
                //            function(dict)
            }){ (error) in
                print(error.localizedDescription)
            }
        }
        
    }
    
    static func getObjectWithoutListener(name:String,id:String,function: @escaping ([String : AnyObject]? ,Error? )->()){
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.getObjectWithoutListener(name: name, id: id, function: function)
        }){
        let ref = Database.database().reference(withPath: name+"/"+id)
        ref.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let dict = snapshot.value as? [String : AnyObject] ?? nil
            function(dict,nil)
        }) { (error) in
            function(nil,error)
            print(error.localizedDescription)
        }
        }
    }
    
    static func getFieldWithoutListener(name:String,id:String,function: @escaping (String? ,Error? )->()){
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.getFieldWithoutListener(name: name, id: id, function: function)
        }){
        let ref = Database.database().reference(withPath: name+"/"+id)
        ref.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let string = snapshot.value as? String
            function(string,nil)
        }) { (error) in
            function(nil,error)
            print(error.localizedDescription)
        }
        }
    }
    
    static func removeAllObservers(){
       Database.database().reference().removeAllObservers()
    }
    
    static func removeTableObservers(name:String){
         Database.database().reference(withPath: name).removeAllObservers()
    }
    
    static func removeChatListObservers(){
        removeTableObservers(name: C.DataBase.chats)
    }
    
    static func  saveImgProfie(image:UIImage?,profile:Profile,function: @escaping (_ error:Error?,_ ref:DatabaseReference )->())
    {
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.saveImgProfie(image: image, profile: profile, function: function)
        }){
        profile.pushToken = ServerController.deviceToken
        profile.deviceType = DeviceTypeEnum.iphone.rawValue
        if(image==nil)
        {
            saveProfile(profile: profile,function: function)
        }
        else
        {
            let data :NSData = UIImageJPEGRepresentation(image!, 0.8)! as NSData
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            let imgName=(profile is RealProfile) ? currentUserId+"real" : currentUserId
            Storage.storage().reference().child("profileImages").child(imgName).putData(data as Data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    saveProfile(profile: profile,function: function)
                    return
                }else{
                    let downloadURL = metaData!.downloadURL()!.absoluteString
                    profile.imageUrl=downloadURL
                    saveProfile(profile: profile,function: function)
                }
            }
        }
        }
    }
    
    static func saveChatPartner(profile:Profile, status:State,function: @escaping (_ error:Error?,_ ref:DatabaseReference )->()){
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.saveChatPartner(profile: profile, status: status, function: function)
        }){
        saveChatPrtnerBuddy(profile: profile,statusGet: status, function: function)
        if(status  != .forever){
            saveChatPrtnerCurrent( profile: profile,status: status, function: function)
            
        }
        }
    }
    
    static private func saveChatPrtnerCurrent(profile:Profile, status:State,function: @escaping (_ error:Error?,_ ref:DatabaseReference )->()){
        var tblName=C.DataBase.chatPartners
        let key=profile.identifier
        tblName=C.DataBase.chatPartners+"/"+currentUserId
        let chatPartner=ChatPartners()
        chatPartner.partner=profile.toJson()
        //chatPartner.dateAdded=(Date().timeIntervalSince1970 ).description
        chatPartner.dateAdded=String(UInt64(Date().timeIntervalSince1970*1000 - ServerController.currentmillisAppStart))
        chatPartner.lastVisited=UInt64(Date().timeIntervalSince1970*1000 - ServerController.currentmillisAppStart)
        chatPartner.status=status.rawValue
        
        saveObject(key: key, tblName: tblName, dic: chatPartner.toDict(), function: function)
    }
    
    static private func saveChatPrtnerBuddy(profile:Profile,isPrivate:Bool=false,statusGet:State,function: @escaping (_ error:Error?,_ ref:DatabaseReference )->())
    {
        var status = statusGet
        var tblName=C.DataBase.chatPartners
        let key=currentUserId
        tblName=C.DataBase.chatPartners+"/"+profile.identifier
        let chatPartner=ChatPartners()
        if(isPrivate==false)
        {
            chatPartner.partner=currentMainProfile!.toJson()
            chatPartner.realProfile=false
        }
        else
        {
            chatPartner.partner=currentPrivateProfile!.toJson()
            chatPartner.realProfile=true
        }
        //chatPartner.dateAdded=(Date().timeIntervalSince1970).description
        //Int((CHAT_VALIDITY_INTERVAL - (Date().timeIntervalSince1970*1000 + ServerController.currentmillisAppStart - dateDouble!))/1000)
        chatPartner.dateAdded=String(UInt64(Date().timeIntervalSince1970*1000 - ServerController.currentmillisAppStart))
        chatPartner.lastVisited=UInt64(Date().timeIntervalSince1970*1000 - ServerController.currentmillisAppStart)
        if(status==State.haveInvited)
        {
            status=State.invited
        }
        
        chatPartner.status=status.rawValue
        
        saveObject(key: key, tblName: tblName, dic: chatPartner.toDict(), function: function)
    }
    static func saveImgChat(image:UIImage?,chat:Chat,buddy:String,function: @escaping (_ error:Error?,_ ref:DatabaseReference )->())
    {
        //if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.saveImgChat(image: image, chat: chat, buddy: buddy, function: function)
        }){
        if(image==nil)
        {
            saveChat(chat: chat,buddy: buddy,function: function)
        }
        else
        {
            let data :NSData = UIImageJPEGRepresentation(image!, 0.8)! as NSData
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            Storage.storage().reference().child("chatImages").child(getChatId(buddy: buddy)).child(String(UInt64(Date().timeIntervalSince1970*1000 - ServerController.currentmillisAppStart))).putData(data as Data, metadata: metaData){(metaData,error) in
                //Storage.storage().reference().child("chatImages").child(getChatId(buddy: buddy)).child((Date().timeIntervalSince1970 ).description).putData(data as Data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    saveChat(chat: chat,buddy: buddy, function: function)
                    return
                }else{
                    let downloadURL = metaData!.downloadURL()!.absoluteString
                    chat.imageUrl=downloadURL
                    saveChat(chat: chat,buddy: buddy,function: function)
                }
            }
        }
        }
    }
    
    static func saveImg(image:UIImage,profile:Profile,function: @escaping (_ error:Error?,_ ref:DatabaseReference )->())
    {
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.saveImg(image: image, profile: profile, function: function)
        }){
        profile.pushToken = ServerController.deviceToken
        profile.deviceType = DeviceTypeEnum.iphone.rawValue
        let data :NSData = UIImageJPEGRepresentation(image, 0.8)! as NSData
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        Storage.storage().reference().child("profileImages").child(currentUserId).putData(data as Data, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                saveProfile(profile: profile,function: function)
                return
            }else{
                let downloadURL = metaData!.downloadURL()!.absoluteString
                profile.imageUrl=downloadURL
                
                saveProfile(profile: profile,function: function)
            }
        }
        }
        
    }
    
    static func forgotPassword(mail:String,function: @escaping (_ error:Error?)->())
    {
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.forgotPassword(mail: mail, function: function)
        }){
        Auth.auth().sendPasswordReset(withEmail: mail) { error in
            function(error)
        }
        }
    }
    
    static func saveProfile(profile:Profile,function: @escaping (_ error:Error?,_ ref:DatabaseReference )->())
    {
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.saveProfile(profile: profile, function: function)
        }){
        let  tblName = (profile is RealProfile) ? C.DataBase.realProfiles : C.DataBase.profiles
        profile.pushToken = ServerController.deviceToken
        profile.deviceType = DeviceTypeEnum.iphone.rawValue
        saveObject(key:currentUserId
        , tblName:  tblName,dic: profile.toDict()) { (error, ref) in
            if (profile is RealProfile)
            {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = profile.username
                changeRequest?.photoURL=URL(string: profile.imageUrl)
                changeRequest?.commitChanges { (error) in
                }
            }
            function(error,ref)
        }
        }
    }
    
    static func getCurrentProfile(function: @escaping ([String : AnyObject]?)->())    {
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.getCurrentProfile(function: function)
        }){
        getObject(name: C.DataBase.profiles, id: currentUserId ,function: function )
        }
    }
    
    static func getRealCurrentProfile(function: @escaping ([String : AnyObject]?)->())    {
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.getRealCurrentProfile(function: function)
        }){
        getObject(name: C.DataBase.realProfiles, id: currentUserId ,function: function )
        }
    }
    
    static func getOnceRealCurrentProfile(function: @escaping ([String : AnyObject]?,Error?)->())    {
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.getOnceRealCurrentProfile(function: function)
        }){
        getObjectWithoutListener(name: C.DataBase.realProfiles, id: currentUserId ,function: function )
        }
    }
    
    static func getOnceCurrentProfile(function: @escaping ([String : AnyObject]?,Error?)->())    {
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.getOnceCurrentProfile(function: function)
        }){
        getObjectWithoutListener(name: C.DataBase.profiles, id: currentUserId ,function: function )
        }
    }
    
    static func addDate()
    {
        let ref=Database.database().reference(withPath:"dd")
        // Tell the server to set the current timestamp at this location.
        ref.setValue(ServerValue.timestamp())
        
        // Read the value at the given location. It will now have the time.
        ref.observe(.value, with: {
            snap in
            if let t = snap.value as? TimeInterval {
                // Cast the value to an NSTimeInterval
                // and divide by 1000 to get seconds.
                print(NSDate(timeIntervalSince1970: t))
            }
        })
    }
    
    static func getChatId(buddy:String) ->String{
        let me:String=currentUserId
        let  CHAT_ID_SEPARATOR="____"
        var chatId = "";
        if (me>buddy) {
            chatId = buddy + CHAT_ID_SEPARATOR + me;
        } else {
            chatId = me + CHAT_ID_SEPARATOR + buddy;
        }
        chatId = chatId.replacingOccurrences(of: ".",with: "_");
        return chatId;
    }
    
    static func saveDisplayRealProfile(memberID:String,function: @escaping (_ error:Error?,_ ref:DatabaseReference )->()){
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.saveDisplayRealProfile(memberID: memberID, function: function)
        }){
        let ref = Database.database().reference().child(C.DataBase.chatPartners+"/"+memberID+"/"+currentUserId+"/partner")
        ref.setValue(currentPrivateProfile!.toJson(), withCompletionBlock: { (error, ref) in
            let ref = Database.database().reference().child(C.DataBase.chatPartners+"/"+memberID+"/"+currentUserId+"/realProfile")
            ref.setValue(true, withCompletionBlock: { (error, ref) in
                function(error, ref)
            })
            
        })
        }
    }
    
    static func saveDeletedMsg(memberID:String,msgKey:String, otherPartnerDeleted:String = "",function: @escaping (_ error:Error?,_ ref:DatabaseReference )->()){
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.saveDeletedMsg(memberID: memberID, msgKey: msgKey, otherPartnerDeleted:otherPartnerDeleted, function: function)
        }){
            let tblName=C.DataBase.chats+"/"+getChatId( buddy: memberID)+"/"+msgKey+"/deleted"
            let ref = Database.database().reference().child(tblName)
            ref.setValue("\(otherPartnerDeleted)_\(currentUserId)", withCompletionBlock: { (error, ref) in
                    function(error, ref)
            })
        }
    }

    
    static func saveChat(chat:Chat,buddy:String,function: @escaping (_ error:Error?,_ ref:DatabaseReference )->()){
        var tblName=C.DataBase.chats
        let key = Database.database().reference().child(C.DataBase.chats).child(getChatId( buddy: buddy)).childByAutoId().key
        chat.key=key
        chat.dateAdded=String(UInt64(Date().timeIntervalSince1970*1000 - ServerController.currentmillisAppStart))
        //chat.dateAdded=(Date().timeIntervalSince1970 ).description
        
        tblName=C.DataBase.chats+"/"+getChatId( buddy: buddy)
        //saveObject(key: key, tblName: tblName, dic: chat.toDict(), function: function)
        saveObject(key: key, tblName: tblName, dic: chat.toDict()) { (error, ref) in
            
            let ref = Database.database().reference().child(C.DataBase.chatPartners+"/"+currentUserId+"/"+buddy+"/lastVisited")
            ref.setValue(UInt64(Date().timeIntervalSince1970*1000 - ServerController.currentmillisAppStart), withCompletionBlock: { (error, ref) in
                let ref = Database.database().reference().child(C.DataBase.chatPartners+"/"+buddy+"/"+currentUserId+"/lastVisited")
                ref.setValue(UInt64(Date().timeIntervalSince1970*1000 - ServerController.currentmillisAppStart), withCompletionBlock: { (error, ref) in
                    function(error, ref)
                })
            })
        }
    }
    
    static func updateToken(deviceToken:String){
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.updateToken(deviceToken: deviceToken)
        }){
        self.deviceToken = deviceToken
//        if currentPrivateProfile != nil{
//            let ref = Database.database().reference().child(C.DataBase.realProfiles + "/" + currentUserId + "/pushToken")
//            ref.setValue(deviceToken, withCompletionBlock: { (error, ref) in
                if currentMainProfile != nil{
                    let ref = Database.database().reference().child(C.DataBase.profiles + "/" + currentUserId + "/pushToken")
                    ref.setValue(deviceToken, withCompletionBlock: { (error, ref) in
                        let ref = Database.database().reference().child(C.DataBase.profiles + "/" + currentUserId + "/deviceType")
                        ref.setValue(DeviceTypeEnum.iphone.rawValue, withCompletionBlock: { (error, ref) in
                            //function(error, ref)
                        })
                    })
               }
//            })
//        }
        }
    }
    
    static func saveTwoPartnersStatus(partnerId:String,newStatus:String,function: @escaping (_ error:Error?,_ ref:DatabaseReference )->()){
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.saveTwoPartnersStatus(partnerId: partnerId, newStatus: newStatus, function: function)
        }){
        let ref = Database.database().reference().child(C.DataBase.chatPartners + "/" + currentUserId + "/" + partnerId+"/status")
        ref.setValue(newStatus, withCompletionBlock: { (error, ref) in
            let ref = Database.database().reference().child(C.DataBase.chatPartners + "/" + partnerId + "/" + currentUserId + "/status")
            ref.setValue(newStatus, withCompletionBlock: { (error, ref) in
                function(error, ref)
            })
        })
        }
    }
    
    static func savePartnerStatus(partnerId1:String,partnerId2:String,newStatus:String,function: @escaping (_ error:Error?,_ ref:DatabaseReference )->()){
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.savePartnerStatus(partnerId1: partnerId1, partnerId2: partnerId2, newStatus: newStatus, function: function)
        }){
        let ref = Database.database().reference().child(C.DataBase.chatPartners + "/" + partnerId1 + "/" + partnerId2+"/status")
        ref.setValue(newStatus, withCompletionBlock: { (error, ref) in
            function(error, ref)
        })
        }
    }
    
    static func getPartnerStatus(partnerId1:String,partnerId2:String,function: @escaping (String?)->()){
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.getPartnerStatus(partnerId1: partnerId1, partnerId2: partnerId2, function: function)
        }){
        let ref = Database.database().reference().child(C.DataBase.chatPartners + "/" + partnerId1 + "/" + partnerId2 + "/status")
        ref.observeSingleEvent(of: DataEventType.value, with:{ (snapshot) in
            let status = snapshot.value as? String ?? nil
            if status == State.forever.rawValue{
                let ref = Database.database().reference().child(C.DataBase.chatPartners+"/"+partnerId1+"/"+partnerId2+"/dateAdded")
                ref.setValue("", withCompletionBlock: { (error, ref) in
                    let ref = Database.database().reference().child(C.DataBase.chatPartners+"/"+partnerId2+"/"+partnerId1+"/dateAdded")
                    ref.setValue("", withCompletionBlock: { (error, ref) in
                        function(status)
                    })
                })
                
            }else{
                function(status)
            }
        })
        }
        
        //        ref.observe(DataEventType.value, with: { (snapshot) in
        //            let dict = snapshot.value as? [String : AnyObject] ?? nil
        //            function(dict)
        //        })
    }
    
    //MARK: Delete
    static func removeObject(key:String,tblName:String,function: @escaping (_ error:Error?,_ ref:DatabaseReference )->()){
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.removeObject(key: key, tblName: tblName, function: function)
        }){
        ref = Database.database().reference().child("/\(tblName)/\(key)")
        ref.removeValue { (error, ref) in
            function(error,ref)
        }
        }
    }
    
    static func deleteChatPartner(partnerId:String,function: @escaping (_ error:Error?,_ ref:DatabaseReference )->()){
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [partnerId])
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [partnerId])
            //    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        } else {
            // Fallback on earlier versions
        }
        if var chatBadge = UserDefaults.standard.object(forKey: C.userDef.chatBadges) as? [String:Int]{
            if chatBadge[partnerId] != nil{
                chatBadge.removeValue(forKey: partnerId)
                UserDefaults.standard.set(chatBadge, forKey: C.userDef.chatBadges)
                UserDefaults.standard.synchronize()
            }
        }
//        if appDelegate.checkInternt(){//04/01/2018
        if (appDelegate.checkInternt {
            ServerController.deleteChatPartner(partnerId: partnerId, function: function)
        }){
        var tblName=C.DataBase.chatPartners
        let key=partnerId
        tblName=C.DataBase.chatPartners+"/"+currentUserId
        removeObject(key: key, tblName: tblName) { (error, ref) in
            var tblName=C.DataBase.chatPartners
            let key=currentUserId
            tblName=C.DataBase.chatPartners+"/"+partnerId
            removeObject(key: key, tblName: tblName) { (error, ref) in
                let tblName=C.DataBase.chats
                let key=getChatId(buddy: partnerId)
                removeObject(key: key, tblName: tblName, function: {(error, ref) in
                    function(error, ref)
                })
            }
        }
        }
    }
    
    //MARK: Currentmillis
    static func setCurrentmillisDif(){
        getCurrentmillis { (currentmillis) in
            if currentmillis != nil {
                //let milliSecs = CUnsignedLongLong((Date().timeIntervalSince1970)*1000)
                let milliSecs = Double((Date().timeIntervalSince1970)*1000)
                currentmillisAppStart = milliSecs - currentmillis!
            }else{
                setCurrentmillisDif()
            }
        }
    }
    
    
    static func getCurrentmillis(function:@escaping (_ currentmillis:Double?)->()){
        let url = URL(string: "http://pushserver.atnisrael.com/getcurrentmillis")
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if error == nil{
                let str = String(data: data!, encoding:String.Encoding.utf8)
                if let currentMillis = Double(str!){
                    function(currentMillis)
                }else{
                    function(nil)
                }
                //function(Double(str!)!)
            }else{
                function(nil)
            }
        }
        task.resume()
    }
    
    //MARK: -Send push
    static func sendPush(chat:Chat,partnerId:String,chatPartner:ChatPartners){
        getObjectWithoutListener(name: C.DataBase.profiles, id: partnerId) { (dic, error) in
            var pushToken = ""
            var message = ""
            var title = ""
            if let partnerPushToken = dic?["pushToken"] as? String{
                pushToken = partnerPushToken
            }
            if let partnerDeviceType = dic?["deviceType"] as? String{
                if partnerDeviceType == DeviceTypeEnum.iphone.rawValue{
                    if chatPartner.status == "invited"{
                        // body = partner.profile.username
                        message = chatPartner.profile.gender == "woman" ? "wants_female".localized  : "wants_male".localized
                        message += " " + "wants_to_chat".localized
                    }else{
                            if chat.imageUrl != ""{
                                message = chatPartner.profile.gender == "woman" ? "femaleSentImage".localized  : "maleSentImage".localized
                            }else{
                                message = chat.text
                            }
                        
                    }
                    title = chatPartner.profile.username
                }
            }
//        }
//        getFieldWithoutListener(name: C.DataBase.profiles, id: "\(partnerId)/pushToken") { (pushToken, error) in
            var jsonDic = [String:AnyObject]()
            jsonDic["serverKey"] = "AAAAn0yYjrE:APA91bEkPJx2sKPFhHb5syj-lYWBR7aP1DaXWyc_rjZEdhqXS5L5OlZPrUzhaQ7lwbJ0M6Njmgr_kvbqQ3nRAAW98ZKSL2XzonBT2q62m5QQhsJmj_VBeZ_HNSmXdZEGboDYqchPYlKZ" as AnyObject
            jsonDic["deviceToken"] = /*currentMainProfile?.pushToken as AnyObject*/pushToken as AnyObject
            jsonDic["message"] = message as AnyObject
            jsonDic["title"] = title as AnyObject
            jsonDic["apiKey"] = "abcd1234" as AnyObject
           // jsonDic["senderId"] = "4d9VF86dsmdy89cpyXI77v7US4h2" as AnyObject
            jsonDic["senderId"] = "684184866481" as AnyObject
            jsonDic["data"] = chat.toJson() as AnyObject
            connectionToService(jsonDictionary: jsonDic) { (resault) in
            }
            
        }
    }
    
    static  func connectionToService( jsonDictionary jsonDict: [String: AnyObject], function:@escaping (_ str:String)->()) {
        let request = setRequest( jsonDict: jsonDict)
        sendRequest(request: request as URLRequest, function: function)
        
    }
    
    private static func setRequest(jsonDict:[String: AnyObject])->NSMutableURLRequest{
        let url = URL(string: "http://pushserver.atnisrael.com/push")!
        
        let request = NSMutableURLRequest(url: url)
        var requestData=Data()
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            
            requestData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
            request.setValue("\(requestData.count)", forHTTPHeaderField: "Content-Length")
            request.httpBody = requestData
            
            let jsonString = NSString(data: requestData, encoding: String.Encoding.utf8.rawValue)! as String
            print("json",jsonString)
        }
        catch let error {
            print(error)
        }
        return request
    }
    
    
    
    private static func sendRequest(request:URLRequest, function:@escaping (_ str:String)->()){
        //  cont?.showNativeActivityIndicator()
        let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
            DispatchQueue.main.async(execute: { () -> Void in
                if error == nil {
                    //cont?.hideNativeActivityIndicator()
                    let str = String(data: data!, encoding:String.Encoding.utf8)
                    print("str:",str!.description)
                    function(str!)
                }
                else {
                    // cont?.hideNativeActivityIndicator()
                }
                
            })
        }
        task.resume()
    }
    
    
    //MARK: -InternentListiner
    static func setInternentListiner(function:@escaping ()->()){
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            // secondtInterntCheck = true
            if snapshot.value as? Bool ?? false {
                print("Connected")
                interntWasConnect = true
            } else {
                print("Not connected")
                if interntWasConnect{
                    function()
                }
                
            }
        })
        
        //        // since I can connect from multiple devices, we store each connection instance separately
        //        // any time that connectionsRef's value is null (i.e. has no children) I am offline
        //        let myConnectionsRef = Database.database().reference(withPath: "users/morgan/connections")
        //
        //        // stores the timestamp of my last disconnect (the last time I was seen online)
        //        let lastOnlineRef = Database.database().reference(withPath: "users/morgan/lastOnline")
        //
        //        let connectedRef = Database.database().reference(withPath: ".info/connected")
        //
        //        connectedRef.observe(.value, with: { snapshot in
        //            // only handle connection established (or I've reconnected after a loss of connection)
        //            guard let connected = snapshot.value as? Bool, connected else {
        //                return }
        //
        //            // add this device to my connections list
        //            let con = myConnectionsRef.childByAutoId()
        //
        //            // when this device disconnects, remove it.
        //            con.onDisconnectRemoveValue()
        //
        //            // The onDisconnect() call is before the call to set() itself. This is to avoid a race condition
        //            // where you set the user's presence to true and the client disconnects before the
        //            // onDisconnect() operation takes effect, leaving a ghost user.
        //
        //            // this value could contain info about the device or a timestamp instead of just true
        //            con.setValue(true)
        //            
        //            // when I disconnect, update the last time I was seen online
        //            lastOnlineRef.onDisconnectSetValue(ServerValue.timestamp())
        //        })
        
    }
    
}
