//
//  LocalNoteficationManager.swift
//  Tendy
//
//  Created by Shaya Fredman on 25/09/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit
import UserNotifications
import Foundation
import MobileCoreServices


class LocalNoteficationManager: NSObject {

    final class var sharedInstance : LocalNoteficationManager {
        struct Static {
            static var instance : LocalNoteficationManager?
        }
        if !(Static.instance != nil) {
            Static.instance = LocalNoteficationManager()
            
        }
        return Static.instance!
    }

    func addChatNotification(data: [AnyHashable: Any]){
        // ["sender": ijEIzYS7iAXg7SfbYzS7QWfUisI2, "deleted": , "imageUrl": , "dateAdded": 1506422795181, "key": -KuxmurDaOIs_JP1Be5y, "text": גיגג]
        if let senderId = data["sender"] as? String{
            if senderId != ServerController.currentUserId{
                ServerController.getOnceChatPartner(id: senderId, function: { (partnerDic:[String : AnyObject]?, error) in

//                })
//                ServerController.getChatPartner(id: senderId) { (partnerDic:[String : AnyObject]?) in
                    if partnerDic != nil{
                        let partner = ChatPartners(dic:partnerDic)
                        var body = ""
                        if partner.status == "invited"{
                            // body = partner.profile.username
                            body = partner.profile.gender == "woman" ? "wants_female".localized  : "wants_male".localized
                            body += " " + "wants_to_chat".localized
                        }else{
                            if let imageUrl = data["imageUrl"] as? String{
                                if imageUrl != ""{
                                    body = partner.profile.gender == "woman" ? "femaleSentImage".localized  : "maleSentImage".localized
                                }else if let text = data["text"] as? String{
                                    body = text
                                }
                            }else if let text = data["text"] as? String{
                                body = text
                            }
                            
                        }
                        self.scheduleLocalNotification(title: partner.profile.username, body: body, _data: partnerDic!, type: "Chat", id: senderId, imageStringUrl: partner.profile.imageUrl)
                    }
                })
            }
        }
        
    }
    
    func addDiscoveryNotification(profileDiscoveryNumber: Int){
        self.scheduleLocalNotification(title: "\("tendi_found_1_s_people_around_you1".localized) \(profileDiscoveryNumber) \("tendi_found_1_s_people_around_you2".localized)", body: "", _data: nil, type: "Discovery", id: "DiscoveryNotification", imageStringUrl: nil)
    }

    
    func scheduleLocalNotification(title:String,body:String,_data: [AnyHashable: Any]?,type:String, id :String, imageStringUrl:String?) {
        // 1
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = body == "" ? "" : title
            content.subtitle = body == "" ? title : ""
            content.body = body == "" ? " " : body
            content.categoryIdentifier = type
            if _data != nil{
                content.userInfo = _data!
            }
           // content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber//increases the icon badge number
            
          if imageStringUrl != nil{
            
            let image=UIImage()
            var dataImage=Data()
            var imageName = ""
            image.setImgwithUrl(imageStringUrl!, completion: { (exist, image) in
                if let data = UIImagePNGRepresentation(image) {
                    dataImage = data
                    imageName = "image.png"
                }else if let data = UIImageJPEGRepresentation(image, 1){
                    dataImage = data
                    imageName = "image.jpeg"
                }
                let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
                
                // Create a destination URL.
                let targetURL = tempDirectoryURL.appendingPathComponent(imageName)
                
                do {
                    try dataImage.write(to: targetURL, options: [])
                    
                    let options = [UNNotificationAttachmentOptionsTypeHintKey: kUTTypeImage]
                    if let attachment = try? UNNotificationAttachment(identifier: "", url: targetURL, options: options) {
                        content.attachments = [attachment]
                        // 3
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.000001, repeats: false)
                        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                        
                        // 4
                        DispatchQueue.main.async {
                            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                                if error != nil{
                                    //                                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                                    //                                        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
                                    print(error.debugDescription)
                                }
                            })
                        }
                    }
                } catch let error as NSError {
                    print("Could not write file", error.localizedDescription)
                }
            })
                
                /*
                URLSession.shared.downloadTask(withResumeData: dataImage, completionHandler: { (location, response, error) in
                    if error == nil{
                        
                        if let location = location {
                            let options = [UNNotificationAttachmentOptionsTypeHintKey: kUTTypeImage]
                            if let attachment = try? UNNotificationAttachment(identifier: "", url: location, options: options) {
                                content.attachments = [attachment]
                                // 3
                                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.000001, repeats: false)
                                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                                
                                // 4
                                DispatchQueue.main.async {
                                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                                        if error != nil{
                                            //                                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                                            //                                        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
                                            print(error.debugDescription)
                                        }
                                    })
                                }
                            }
                        }
                    }
                }).resume()
            })*/
 
            
            /*
            guard let url = URL(string: imageStringUrl!) else { return }
            URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) in
                if error == nil{
                    if let location = location {
                        let options = [UNNotificationAttachmentOptionsTypeHintKey: kUTTypePNG]
                        if let attachment = try? UNNotificationAttachment(identifier: "", url: location, options: options) {
                            content.attachments = [attachment]
                            // 3
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.0001, repeats: false)
                            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                            
                            // 4
                            DispatchQueue.main.async {
                               // DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                                    if error != nil{
//                                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
//                                        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
                                       // print(error.debugDescription)
                                        print("send chat notification fail")
                                    }
                                })
                            }
                        }
                    }
                }
                }).resume()*/
          }else{
            
            // 3
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.000001, repeats: false)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            
            // 4
            DispatchQueue.main.async {
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                    if error != nil{
                    print(error.debugDescription)
                    }
                })
            }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func silentNotification(){
        let content = UNMutableNotificationContent()
        content.title = ""
        content.body = ""
//        content.userInfo = ["aa":"aa"]
        content.categoryIdentifier = "discoveryAria"
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "discoveryAria", content: content, trigger: trigger)
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                if error != nil{
                    print(error.debugDescription)
                }
            })
        }
        
        
//        let localNotification = UILocalNotification()
//        localNotification.fireDate = date
//        localNotification.repeatInterval = NSCalendar.Unit.minute
//        localNotification.alertBody = ""
//        localNotification.category = "note.reminder"
//        localNotification.userInfo = ["type":"note.reminder","noteId": noteId,"notificationSnoozeID" : notificationSnoozeID]
//        UIApplication.shared.scheduleLocalNotification(localNotification)
//        // Request to reload table view data
//        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadData"), object: self)
    }
}
