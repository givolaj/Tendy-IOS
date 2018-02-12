//
//  SuperViewController.swift
//  Tendy
//
//  Created by ATN on 30/07/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import FontAwesome_swift
import UIKit
import SWRevealViewController
import FontAwesome_swift

class SuperRevealViewController: SuperViewController,SWRevealViewControllerDelegate{
    
    var tapGestureRecognizer:UITapGestureRecognizer!
    var viewAboveReveal:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden=false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func reavelViewControllerSettings(){
        if self.revealViewController() != nil{
        if AppDelegate.isRTL{
            let rightViewController = self.revealViewController().rearViewController
            if rightViewController != nil{
                self.revealViewController().rearViewController = nil
                self.revealViewController().rightViewController = rightViewController
            }
            self.revealViewController().rightViewRevealOverdraw = 1
            leftBarBtn("",fontAwesome: .bars , actionStr:  "rightRevealToggle:",target: revealViewController())
            setAppName()
            self.revealViewController().rightViewRevealWidth = UIScreen.main.bounds.size.width - 100
        }else{
            self.revealViewController().rearViewRevealOverdraw = 1
            leftBarBtn("",fontAwesome: .bars , actionStr:  "revealToggle:",target: revealViewController())
            setAppName()
           self.revealViewController().rearViewRevealWidth = UIScreen.main.bounds.size.width - 100
        }
        revealViewController().delegate=self

        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        self.revealViewController().frontViewShadowOffset = CGSize(width: 0, height: 0)
        self.revealViewController().frontViewShadowOpacity = 0.0
        self.revealViewController().frontViewShadowRadius = 0.0
        }
    }
    
    func reavelViewControllerFirstSettings(){
        leftBarBtn("",fontAwesome: .bars , actionStr:  "revealToggle:",target: revealViewController())
        setAppName()
    }
    
    func setAppName(){
        let appName = UILabel(frame: CGRect( x: 0,y: 0,width: 60 ,height: 30))
        appName.font = UIFont(name: C.Font.fontRegular, size: 17)!
        appName.textColor = UIColor.white
        appName.textAlignment = .center
        appName.backgroundColor = UIColor.clear
        appName.text = "appName".localized
        self.navigationItem.rightBarButtonItems=[UIBarButtonItem(customView: appName)]
    }

    
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        var menuToFront = false
        if AppDelegate.isRTL{
            menuToFront = position == FrontViewPosition.left ? false : true
        }else{
           menuToFront = position == FrontViewPosition.left ? false : true
        }
        
        if (menuToFront) {
            viewAboveReveal.isHidden = false
            self.view.endEditing(true)
            self.view.bringSubview(toFront: viewAboveReveal)
            if let tabBarController = self.revealViewController().frontViewController as? UITabBarController{
                tabBarController.tabBar.isUserInteractionEnabled = false
            }
        }
        else{
            viewAboveReveal.isHidden = true
            if self.revealViewController() != nil{
                if let tabBarController = self.revealViewController().frontViewController as? UITabBarController{
                    tabBarController.tabBar.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if(self.revealViewController() != nil){
            reavelViewControllerSettings()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
}
