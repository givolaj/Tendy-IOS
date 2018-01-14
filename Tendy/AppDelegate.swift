
//
//  AppDelegate.swift
//  Tendy
//
//  Created by ATN on 30.7.2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit
import SWRevealViewController
import Firebase
import FBSDKCoreKit
import UserNotifications
import FirebaseMessaging
import FirebaseInstanceID
//import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate/*,CBCentralManagerDelegate*/ {
    
    var window: UIWindow?
    
    var discoveryTimer = Timer()
    static var discovery = false
    static var isRTL = false
    var mainVC:SWRevealViewController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        navigationSettings()
        tabBarSettings()
        FirebaseApp.configure()
        registerToNotifications(application)
        //PPKController.enableWithConfiguration("<YOUR APPLICATION KEY>", observer:self)
        ((UserDefaults.standard.object(forKey: C.DataBase.Uid)) != nil) ? goToPageMain():goToPageLogin()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        ServerController.setCurrentmillisDif()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: NSNotification.Name.InstanceIDTokenRefresh,
                                               object: nil)
        //fatalError()
        UIApplication.shared.applicationIconBadgeNumber = 0
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
//        let myCentralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: "myCentralManagerIdentifier"])
       // var centralManagerIdentifiers = launchOptions![.bluetoothCentrals]
        return true
    }
    
//    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
//        let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [Any]
////        var serviceUUIDIndex: Int = peripheral.services.indexOfObject(passingTest: {(_ obj: CBService, _ index: Int, _ stop: Bool) -> Bool in
////            return obj.uuid.isEqual(myServiceUUIDString)
////        })
//    }
//
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
////        var serviceUUIDIndex: Int = peripheral.services.indexOfObject(passingTest: {(_ obj: CBService, _ index: Int, _ stop: Bool) -> Bool in
////            return obj.uuid.isEqual(myServiceUUIDString)
////        })
//    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        //LocalNoteficationManager.sharedInstance.silentNotification()
        completionHandler(.newData)
    }
    
    func navigationSettings(){
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = UIColor.exDarkGray
        UINavigationBar.appearance().titleTextAttributes=[NSFontAttributeName: UIFont(name: C.Font.fontRegular, size: 20)! , NSForegroundColorAttributeName:UIColor.extYellow]
    }
    
    func tabBarSettings(){
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().clipsToBounds = true
        UITabBar.appearance().tintColor = UIColor.extYellow
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: C.Font.fontRegular, size: 15)! ,NSForegroundColorAttributeName: UIColor.extLightGray], for:.normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: C.Font.fontRegular, size: 15)! ,NSForegroundColorAttributeName: UIColor.extYellow], for:.selected)
        UITabBar.appearance().selectionIndicatorImage = getImageWithColorPosition(color: UIColor.extYellow, size: CGSize(width:(self.window?.frame.size.width)!/3,height: /*49*/80), lineSize: CGSize(width:(self.window?.frame.size.width)!/3, height:3))
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10)
        // UITabBarItem.appearance().imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func getImageWithColorPosition(color: UIColor, size: CGSize, lineSize: CGSize) -> UIImage {
        let rect = CGRect(x:0, y: 0, width: size.width, height: size.height)
        let rectLine = CGRect(x:0, y:size.height-lineSize.height-0.5,width: lineSize.width,height: lineSize.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.setFill()
        UIRectFill(rect)
        color.setFill()
        UIRectFill(rectLine)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    
    func goToPageLogin(){
        //  registerNotification()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nav =  (UserDefaults.standard.object(forKey: C.userDef.showInstructions)) == nil ? mainStoryboard.instantiateViewController(withIdentifier: "NavViewController") as! UINavigationController : mainStoryboard.instantiateViewController(withIdentifier: "NavViewController-Login") as! UINavigationController
        // let nav = mainStoryboard.instantiateViewController(withIdentifier: "NavViewController") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = nav
        self.window!.rootViewController = nav
        self.window!.makeKeyAndVisible()
        stopDiscoveryTimer()
    }
    
//    func goToPageMain(){
//        ServerController.getOnceRealCurrentProfile { (dicPrivateProfile, error) in
//            if error != nil{
//                self.window?.rootViewController?.showAlertViewNoInternent()
//            }else{
//                let privateProfile = RealProfile( dic: dicPrivateProfile)
//                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
//                if(privateProfile.identifier != ""){
//                    ServerController.currentPrivateProfile=privateProfile
////                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)//11/12/17
////                    let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController//11/12/17
//                    ServerController.getOnceCurrentProfile { (dicProfile, error) in
//                        self.mainVC = mainVC
//                        //self.window?.rootViewController?.hideNativeActivityIndicator()
//                        self.window!.rootViewController = mainVC
//                        self.window!.makeKeyAndVisible()
//                        if error != nil{
//                            self.window?.rootViewController?.showAlertViewNoInternent()
//                        }else{
//                            let profile = Profile(dic: dicProfile)
//                            if(profile.identifier != ""){//not first profileview
//                                ServerController.currentMainProfile=profile
//                                //self.window?.rootViewController?.hideNativeActivityIndicator()
//                                if let tabbar = mainVC.frontViewController as? UITabBarController{
//                                        tabbar.selectedIndex = 2
//                                }
//                                self.registerToNotifications(UIApplication.shared)
//                                // mainVC.navigationController?.addChildViewController(<#T##childController: UIViewController##UIViewController#>)
//                                self.startDiscoveryTimer()
//                            }
//                    }
//                    }
//                }else{
//                    //self.window?.rootViewController?.hideNativeActivityIndicator()
//
//                    self.mainVC = mainVC
//                    //self.window?.rootViewController?.hideNativeActivityIndicator()
//                    self.window!.rootViewController = mainVC
//                    self.window!.makeKeyAndVisible()
//
////                    self.goToRealProfile()//11/12/17
//                }
//            }
//        }
//    }
    
    func goToPageMain(){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        ServerController.getOnceCurrentProfile { (dicProfile, error) in
            self.mainVC = mainVC
            //self.window?.rootViewController?.hideNativeActivityIndicator()
            
//            self.window!.rootViewController = mainVC
//            self.window!.makeKeyAndVisible()
            if error != nil{
//                self.window?.rootViewController?.showAlertViewNoInternent()//04/01/2018
                self.window?.rootViewController?.showAlertViewNoInternent {
                    self.goToPageMain()
                }
            }else{
                let profile = Profile(dic: dicProfile)
                if(profile.identifier != ""){//not first profileview
                    self.window!.rootViewController = mainVC
                    self.window!.makeKeyAndVisible()
                    ServerController.currentMainProfile=profile
                    //self.window?.rootViewController?.hideNativeActivityIndicator()
                    if let tabbar = mainVC.frontViewController as? UITabBarController{
                        tabbar.selectedIndex = 2
                    }
                    
                    ServerController.getOnceRealCurrentProfile { (dicPrivateProfile, error) in
                        if error != nil{
                            //                self.window?.rootViewController?.showAlertViewNoInternent()//04/01/2018
                            self.window?.rootViewController?.showAlertViewNoInternent {
                                self.goToPageMain()
                            }
                        }else{
                            let privateProfile = RealProfile( dic: dicPrivateProfile)
                            if(privateProfile.identifier != ""){
                                ServerController.currentPrivateProfile=privateProfile
                            }
                        }
                    }
                    self.registerToNotifications(UIApplication.shared)
                    self.startDiscoveryTimer()
                }else{
                    ServerController.getOnceRealCurrentProfile { (dicPrivateProfile, error) in
                        if error != nil{
                            //                self.window?.rootViewController?.showAlertViewNoInternent()//04/01/2018
                            self.window?.rootViewController?.showAlertViewNoInternent {
                                self.goToPageMain()
                            }
                        }else{
                            let privateProfile = RealProfile( dic: dicPrivateProfile)
                            if(privateProfile.identifier != ""){
                                ServerController.currentPrivateProfile=privateProfile
                            }
                            self.mainVC = mainVC
                            self.window!.rootViewController = mainVC
                            self.window!.makeKeyAndVisible()
                        }
                    }
                    
                    
                }
            }
        }
    }
    
    func returnToMain(){
        self.window!.rootViewController = mainVC
        self.window!.makeKeyAndVisible()
    }
    
    func goToFirstProfile(){
        ServerController.getOnceRealCurrentProfile { (dicPrivateProfile, error) in
            if error != nil{
              //  self.window?.rootViewController?.showAlertViewNoInternent()//04/01/2018
                self.window?.rootViewController?.showAlertViewNoInternent {
                    self.goToFirstProfile()
                }
            }else{
                let privateProfile = RealProfile( dic: dicPrivateProfile)
                    ServerController.currentPrivateProfile=privateProfile
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                    self.window!.rootViewController = mainVC
                    self.window!.makeKeyAndVisible()
            }
        }
    }

    
    func goToDiscoveryPage(){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        //                    ServerController.setInternentListiner {
        //                        mainVC.showAlertViewNoInternent()
        //                    }
        self.window!.rootViewController = mainVC
        self.window!.makeKeyAndVisible()
        if let tabbar = mainVC.frontViewController as? UITabBarController{
            tabbar.selectedIndex = 2
        }
        // mainVC.navigationController?.addChildViewController(<#T##childController: UIViewController##UIViewController#>)
        self.startDiscoveryTimer()
        
        /*//11/12/17
        ServerController.getOnceRealCurrentProfile { (dicPrivateProfile, error) in
            if error != nil{
                self.window?.rootViewController?.showAlertViewNoInternent()
            }else{
                let privateProfile = RealProfile( dic: dicPrivateProfile)
                if(privateProfile.identifier != ""){
                    ServerController.currentPrivateProfile=privateProfile
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
//                    ServerController.setInternentListiner {
//                        mainVC.showAlertViewNoInternent()
//                    }
                    self.window!.rootViewController = mainVC
                    self.window!.makeKeyAndVisible()
                    if let tabbar = mainVC.frontViewController as? UITabBarController{
                        tabbar.selectedIndex = 2
                    }
                    // mainVC.navigationController?.addChildViewController(<#T##childController: UIViewController##UIViewController#>)
                    self.startDiscoveryTimer()
                }
            }
        }*/
    }
    
    func goToDiscoveryPage_Back(){//אם האפליקציה ברקע ונמחק הפרטנר לציטוט שהיה פתוח א״א לעשות הקודם ...
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        //                    ServerController.setInternentListiner {
        //                        mainVC.showAlertViewNoInternent()
        //                    }
        self.window!.rootViewController = mainVC
        self.window!.makeKeyAndVisible()
        if let tabbar = mainVC.frontViewController as? UITabBarController{
            tabbar.selectedIndex = 2
        }
        
    }
    
//    func goToChatPage(data:[AnyHashable: Any]){
//        ServerController.getOnceRealCurrentProfile { (dicPrivateProfile, error) in
//            if error != nil{
//                self.window?.rootViewController?.showAlertViewNoInternent()
//            }else{
//                let privateProfile = RealProfile( dic: dicPrivateProfile)
//                if(privateProfile.identifier != ""){
//                    ServerController.currentPrivateProfile=privateProfile
//                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                    let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
////                    ServerController.setInternentListiner {
////                        mainVC.showAlertViewNoInternent()
////                    }
//                    self.window!.rootViewController = mainVC
//                    self.window!.makeKeyAndVisible()
//                    if let tabbar = mainVC.frontViewController as? UITabBarController{
//                        tabbar.selectedIndex = 1
//                        let chatVC = mainStoryboard.instantiateViewController(withIdentifier: "ChatViewController")as! ChatViewController
//                        //ServerController.getChatPartner(id: senderId) { (partnerDic:[String : AnyObject]?) in
//                        // if partnerDic != nil{
//                        let partner = ChatPartners(dic:data as? [String : AnyObject])
//                        chatVC.member=partner.profile
//                        chatVC.state=State(rawValue: partner.status)
//                        chatVC.myChatPartner=partner
//
//                        chatVC.hidesBottomBarWhenPushed = true
//                        if let nav = tabbar.selectedViewController as? UINavigationController{
//                            nav.isNavigationBarHidden=true
//                            nav.pushViewController(chatVC, animated: false)
//                            nav.isNavigationBarHidden=true
//                            //  nav.addChildViewController(chatVC)
//                        }
//                        self.startDiscoveryTimer()
//                        //                            self.window!.rootViewController = mainVC
//                        //                            self.window!.makeKeyAndVisible()
//                        // }
//                        //}
//                        //                    chatVC.member=(sender as! ChatPartners).profile
//                        //                    chatVC.state=State(rawValue: (sender as! ChatPartners).status)
//                        //                    chatVC.myChatPartner=sender as! ChatPartners
//                        //
//                        //                    if let nav = tabbar.selectedViewController as? UINavigationController{
//                        //                    nav.addChildViewController(chatVC)
//                        //                    }
//                    }
//                    //                self.startDiscoveryTimer()
//                }
//            }
//        }
//    }
    
    func goToChatPage(data:[AnyHashable: Any]){
        
        ServerController.getOnceCurrentProfile { (dicProfile, error) in
            if error != nil{
                //self.window?.rootViewController?.showAlertViewNoInternent()//04/01/2018
                self.window?.rootViewController?.showAlertViewNoInternent {
                    self.goToChatPage(data: data)
                }
            }else{
                let profile = Profile( dic: dicProfile)
                if(profile.identifier != ""){
                    ServerController.currentMainProfile=profile
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                    self.window!.rootViewController = mainVC
                    self.window!.makeKeyAndVisible()
                    if let tabbar = mainVC.frontViewController as? UITabBarController{
                        tabbar.selectedIndex = 1
                        let chatVC = mainStoryboard.instantiateViewController(withIdentifier: "ChatViewController")as! ChatViewController
                        let partner = ChatPartners(dic:data as? [String : AnyObject])
                        chatVC.member=partner.profile
                        chatVC.state=State(rawValue: partner.status)
                        chatVC.myChatPartner=partner
                        
                        chatVC.hidesBottomBarWhenPushed = true
                        if let nav = tabbar.selectedViewController as? UINavigationController{
                            nav.isNavigationBarHidden=true
                            nav.pushViewController(chatVC, animated: false)
                            nav.isNavigationBarHidden=true
                        }
                        self.startDiscoveryTimer()
                    }
                }
            }
        }
    }
    
    func goToRealProfile(){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "RealProfileNavigation") as! UINavigationController
//        ServerController.setInternentListiner {
//            mainVC.showAlertViewNoInternent()
//        }
        self.window!.rootViewController = mainVC
        self.window!.makeKeyAndVisible()
        (mainVC.viewControllers[0] as! ProfileViewController).profile=RealProfile()
        (mainVC.viewControllers[0] as! ProfileViewController).firstRealProfile = true
        //  startDiscoveryTimer()
    }
    
    
    func startDiscoveryTimer(){
        // discoveryTimer.fire()
        //LocalNoteficationManager.sharedInstance.silentNotification()
        discoveryTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(AppDelegate.discoveryBlutooth), userInfo: nil, repeats: true)
        //discoveryBlutooth()
        P2PKit_Blutooth.sharedInstance.firstEnable()
        P2PKit_Blutooth.sharedInstance.startDiscovery()
        AppDelegate.discovery = true
    }
    
    func stopDiscoveryTimer(){
        discoveryTimer.invalidate()
        //P2PKit_Blutooth.sharedInstance.enabled()
        //P2PKit_Blutooth.sharedInstance.stopDiscovery()
        P2PKit_Blutooth.sharedInstance.disable()
        AppDelegate.discovery = false
        //PPKController.stopDiscovery()
    }
    
    func discoveryBlutooth(){
//        print("TIKKK")
        P2PKit_Blutooth.sharedInstance.enabled()
        P2PKit_Blutooth.sharedInstance.stopDiscovery()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            P2PKit_Blutooth.sharedInstance.startDiscovery()
        })
        
        //P2PKit_Blutooth.sharedInstance.stopDiscovery()
        //PPKController.stopDiscovery()
        //PPKController.startDiscovery(withDiscoveryInfo: ServerController.currentUserId.data(using: .utf8), stateRestoration: false)
        //PPKController.pushNewDiscoveryInfo("Hello again!".data(using: .utf8))
    }
    
    func sendPushToScan(){
        if AppDelegate.discovery == true && UIApplication.shared.applicationState == UIApplicationState.background {
        discoveryBlutooth()
        print("discoveryAria push get")
        var jsonDic = [String:AnyObject]()
        jsonDic["serverKey"] = "AAAAn0yYjrE:APA91bEkPJx2sKPFhHb5syj-lYWBR7aP1DaXWyc_rjZEdhqXS5L5OlZPrUzhaQ7lwbJ0M6Njmgr_kvbqQ3nRAAW98ZKSL2XzonBT2q62m5QQhsJmj_VBeZ_HNSmXdZEGboDYqchPYlKZ" as AnyObject
        jsonDic["deviceToken"] = ServerController.deviceToken as AnyObject
        jsonDic["message"] = "" as AnyObject
        jsonDic["title"] = "" as AnyObject
        jsonDic["apiKey"] = "abcd1234" as AnyObject
        // jsonDic["senderId"] = "4d9VF86dsmdy89cpyXI77v7US4h2" as AnyObject
        jsonDic["senderId"] = "684184866481" as AnyObject
        let dictionary = ["categoryIdentifier":"discoveryAria"]
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: dictionary,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .utf8)
            print("JSON string = \(theJSONText!)")
            jsonDic["data"] = theJSONText as AnyObject
        }else{
        jsonDic["data"] = "" as AnyObject
        }
        jsonDic["delay"] = "120000" as AnyObject//2 דקות
//            jsonDic["delay"] = "60000" as AnyObject//דקה
        ServerController.connectionToService(jsonDictionary: jsonDic){ (resault) in
        }
        }
    }
    
    func registerToNotifications(_ application: UIApplication) {
        CustomPhotoAlbum.sharedInstance
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        connectToFcm()
    }
    

    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = InstanceID.instanceID().token() {
            ServerController.updateToken(deviceToken: refreshedToken)
            print("Firebase registration token: \(refreshedToken)")
        }
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func connectToFcm() {
        // Won't connect since there is no token
        guard InstanceID.instanceID().token() != nil else {
            return
        }
        
        if ServerController.currentMainProfile == nil{
            UIApplication.shared.unregisterForRemoteNotifications()
//            InstanceID.instanceID().deleteID(handler: { (error) in
//            })
        }
        
        // Disconnect previous FCM connection if it exists.
        //Messaging.messaging().disconnect()
        /*
        Messaging.messaging().shouldEstablishDirectChannel = false
        if ServerController.currentPrivateProfile != nil{
        Messaging.messaging().shouldEstablishDirectChannel = true
        }*/
//        Messaging.messaging().connect { (error) in
//            if error != nil {
//                print("Unable to connect with FCM. \(error?.localizedDescription ?? "")")
//            } else {
//                print("Connected to FCM.")
//            }
//        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass device token to auth
        Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.prod)//dis
//        Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.sandbox)//dev
        // ServerController.deviceToken = deviceToken.base64EncodedString()
        if let token = Messaging.messaging().fcmToken{
            ServerController.updateToken(deviceToken: token)
            print("Firebase registration token: \(token)")
        }
        // Messaging.messaging().apnsToken = deviceToken
        
        // Further handling of the device token if needed by the app
        // ...
    }
    
//    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
//        print("Firebase registration token: \(fcmToken)")
//        //ServerController.deviceToken = fcmToken
//        ServerController.updateToken(deviceToken: fcmToken)
//    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification notification: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        let alert = UIAlertController(title: "כל הכבוד!!", message: "הגיעה נוטיפיקציה!!!", preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "סיים", style: UIAlertActionStyle.default, handler: nil))
//        alert.show()
        notificationReceived(notificationInfo: notification)
        completionHandler(.newData)
        //        if Auth.auth().canHandleNotification(notification) {
        //            notificationReceived(notificationInfo: notification)
        //            completionHandler(UIBackgroundFetchResult.noData)
        //            return
        //        }
        // This notification is not auth related, developer should handle it.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        notificationReceived(notificationInfo: userInfo)
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        //        if let messageID = userInfo[gcmMessageIDKey] {
        //            print("Message ID: \(messageID)")
        //        }
        
        // Print full message.
        print(userInfo)
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        UserDefaults.standard.set(CustomPhotoAlbum.imagesDownloaded, forKey: C.userDef.imagesDownloaded)
        UserDefaults.standard.synchronize()
        
//        let app = UIApplication.shared
//        //create new uiBackgroundTask
//        var bgTask: UIBackgroundTaskIdentifier!
//        bgTask = app.beginBackgroundTask(expirationHandler: {() -> Void in
//            app.endBackgroundTask(bgTask)
//            bgTask = UIBackgroundTaskInvalid
//        })
//        //and create new timer with async call:
//        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
//            //run function methodRunAfterBackground
//            var t = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.methodRunAfterBackground), userInfo: nil, repeats: true)
//            RunLoop.current.add(t, forMode: .defaultRunLoopMode)
//            RunLoop.current.run()
//        })
        runBackgroundTask(20)
        sendPushToScan()

        //    stopDiscoveryTimer()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func runBackgroundTask(_ time: Int) -> Void {
        //check if application is in background mode
        if UIApplication.shared.applicationState == .background {
            let app = UIApplication.shared
            //create new uiBackgroundTask
            var bgTask: UIBackgroundTaskIdentifier!
            //create UIBackgroundTaskIdentifier and create tackground task, which starts after time
            bgTask = app.beginBackgroundTask(expirationHandler: {() -> Void in
                app.endBackgroundTask(bgTask)
                bgTask = UIBackgroundTaskInvalid
            })
            DispatchQueue.global(qos: .default).async(execute: {() -> Void in
                
                let t = Timer.scheduledTimer(timeInterval: TimeInterval(exactly: time) ?? 0.0, target: self, selector: #selector(self.startTrackingBg), userInfo: nil, repeats: false)
                RunLoop.current.add(t, forMode: .defaultRunLoopMode)
                RunLoop.current.run()
                
            })
        }
    }
    var locationStarted = false
    func startTrackingBg() {
        //write background time remaining
       // print(String(format: "backgroundTimeRemaining: %.0f", UIApplication.shared.backgroundTimeRemaining))
        print("Tik\(Date())")
        //set default time
        var time: Int = 60
        //if locationManager is ON
        if locationStarted == true {
            //stop update location
//            locationManager.stopUpdatingLocation()
            locationStarted = false
        }
        else {
            //start updating location
//            locationManager.startUpdatingLocation()
            locationStarted = true
            //ime how long the application will update your location
            time = 5
        }
        runBackgroundTask(time)
    }
    
    func methodRunAfterBackground(){
        print("Tik\(Date())")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
//        let pre = Locale.preferredLanguages[0]
//        Auth.auth().languageCode = "fr"
        if (application.userInterfaceLayoutDirection == .rightToLeft) {
            AppDelegate.isRTL = true
        }
        connectToFcm()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
//        if #available(iOS 10.0, *) {
//            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["discoveryAria"])
//            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["discoveryAria"])
//            //    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
//        }
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    
    func notificationReceived(notificationInfo: [AnyHashable: Any]) {
        if let encodedString = notificationInfo["data"] as? String{
            let decodedString = encodedString.removingPercentEncoding!
            if var dict = decodedString.convertToAnyObjectDictionary(){
                //            if (dict["notificationType"] as? String) != nil{
                //                localNotificationReceived(notificationInfo: dict)
                //            }else{
                if UIApplication.shared.applicationState == UIApplicationState.active {
                    if let sWRevealViewController = self.window?.rootViewController as? SWRevealViewController{
                        if let superViewController = ((sWRevealViewController.frontViewController as? UITabBarController)?.selectedViewController as? UINavigationController)?.viewControllers.last as? SuperViewController{
                            superViewController.notificationReceived(data: dict)
                        }
                    }
                }else {
                    if (dict["sender"] as? String) != nil{//chat
                        LocalNoteficationManager.sharedInstance.addChatNotification(data: dict)
                    }else{
                        if let categoryIdentifier = dict["categoryIdentifier"] as? String{
                            if categoryIdentifier == "discoveryAria"{
                                sendPushToScan()
                            }
                    }
                    }
                }
            }
        }
    }
    
    func localNotificationReceived(data:[AnyHashable: Any], type: String, applicationState:UIApplicationState) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if type == "Chat"{
            goToChatPage(data: data)
            /*
            if applicationState == .inactive{
                goToChatPage(data: data)
            }else{
                if let tabbar = ((ServerController.appDelegate.window?.rootViewController) as? SWRevealViewController)?.frontViewController as? UITabBarController{
                    let chatVC = mainStoryboard.instantiateViewController(withIdentifier: "ChatViewController")as! ChatViewController
                    //ServerController.getChatPartner(id: senderId) { (partnerDic:[String : AnyObject]?) in
                    // if partnerDic != nil{
                    let partner = ChatPartners(dic:data as? [String : AnyObject])
                    chatVC.member=partner.profile
                    chatVC.state=State(rawValue: partner.status)
                    chatVC.myChatPartner=partner
                    
                    chatVC.hidesBottomBarWhenPushed = true
                    if let nav = tabbar.selectedViewController as? UINavigationController{
                        nav.isNavigationBarHidden=true
                        nav.pushViewController(chatVC, animated: false)
                        nav.isNavigationBarHidden=true
                        //  nav.addChildViewController(chatVC)
                    }
                }
            }*/
        }else{
            goToDiscoveryPage()
        }
        
        // }
    }
    
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let alert = UIAlertController(title: "כל הכבוד!!", message: "הגיעה נוטיפיקציה!!!", preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "סיים", style: UIAlertActionStyle.default, handler: nil))
//        alert.show()
        if notification.request.content.categoryIdentifier == "Chat" || notification.request.content.categoryIdentifier == "Discovery"{
            completionHandler([UNNotificationPresentationOptions.alert])
        }else if notification.request.content.categoryIdentifier == "discoveryAria"{
            print("discoveryAria")
        }else{
            let userInfo = notification.request.content.userInfo
            notificationReceived(notificationInfo: userInfo)
        }
        /*
        if UIApplication.shared.applicationState == UIApplicationState.inactive {
            let userInfo = notification.request.content.userInfo
            notificationReceived(notificationInfo: userInfo)
        }else{
             let userInfo = notification.request.content.userInfo
            notificationReceived(notificationInfo: userInfo)
        }
        completionHandler([UNNotificationPresentationOptions.alert])/*completionHandler([])*/
 */
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if response.notification.request.content.categoryIdentifier == "Chat" || response.notification.request.content.categoryIdentifier == "Discovery"{
            //let notificationInfo = response.notification.request.content.userInfo
            localNotificationReceived(data: userInfo, type: response.notification.request.content.categoryIdentifier, applicationState: UIApplication.shared.applicationState)
//            completionHandler()
        }else if response.notification.request.content.categoryIdentifier == "discoveryAria"{
             print("discoveryAria")
        }else{
    
            //let userInfo = response.notification.request.content.userInfo
            if UIApplication.shared.applicationState != .active{
                if let type = userInfo["gcm.notification.categoryIdentifier"] as? String{
                    if type == "Chat"{
                        if let dataString = userInfo["data"] as? String{
                            if var dict = dataString.convertToAnyObjectDictionary(){
                                if let senderId = dict["sender"] as? String{
                                ServerController.getOnceChatPartner(id: senderId, function: { (partnerDic:[String : AnyObject]?, error) in
                                     if partnerDic != nil{
                                        self.localNotificationReceived(data: partnerDic!, type: type, applicationState: UIApplication.shared.applicationState)
                                    }
                                })
                            }
                        }
                        }
//                        localNotificationReceived(data: userInfo, type: type, applicationState: UIApplication.shared.applicationState)
//                        completionHandler()
                    }
                }
            }else{
            notificationReceived(notificationInfo: userInfo)
//            completionHandler()
            }
        }
        completionHandler()
        /*
        
//        let alert = UIAlertController(title: "כל הכבוד!!", message: "הגיעה נוטיפיקציה!!!", preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "סיים", style: UIAlertActionStyle.default, handler: nil))
//        alert.show()
        if response.notification.request.content.categoryIdentifier !=  "" {
            let notificationInfo = response.notification.request.content.userInfo
            localNotificationReceived(data: notificationInfo, type: response.notification.request.content.categoryIdentifier, applicationState: UIApplication.shared.applicationState)
        }
        
        
        //        let notificationInfo = response.notification.request.content.userInfo
        //        let encodedString = notificationInfo["data"] as! String
        //        let decodedString = encodedString.removingPercentEncoding!
        //        if let dict = decodedString.convertToAnyObjectDictionary(){
        //            localNotificationReceived(notificationInfo: dict)
        //        }
        //notificationReceived(notificationInfo: notificationInfo)
        completionHandler()*/
    }
    
    
}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {//נסוי
        print("Firebase registration token: \(fcmToken)")
        //ServerController.deviceToken = fcmToken
        ServerController.updateToken(deviceToken: fcmToken)
    }
    // Receive data message on iOS 10 devices while app is in the foreground.
    func application(received remoteMessage: MessagingRemoteMessage) {
        let alert = UIAlertController(title: "עוד לא...", message: "הגיעה הודעה", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "נסה שוב", style: UIAlertActionStyle.default, handler: nil))
        alert.show()
        //notificationReceived(notificationInfo: remoteMessage.appData)
        print(remoteMessage.appData)
    }
}

