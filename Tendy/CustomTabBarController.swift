//
//  ViewController.swift
//  Tendy
//
//  Created by Shaya Fredman on 28/08/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {

    var tabBarFrame:CGRect!
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.tabBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.tabBar.frame.size.height)
        
//        Navigation bar - 44pts
//        Status bar - 20pts
//        Tab bar - 49pts.
       // let h = self.tabBar.frame.size.height
        let h:CGFloat = 80
        
        var y:CGFloat = 64
        let height = UIScreen.main.bounds.size.height
        if (height == 812.0){
            y = 88
        }
        tabBarFrame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.size.width, height: h)

        self.tabBar.items?[0].title = "Profile".localized
        self.tabBar.items?[1].title = "Chats".localized
        self.tabBar.items?[2].title = "Discovery".localized
    }
    
    func setTabBarFrame(){
        self.tabBar.frame = tabBarFrame
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
