//
//  ShowImageViewController.swift
//  Tendy
//
//  Created by Shaya Fredman on 19/10/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit
import FontAwesome_swift

class ShowImageViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var backBtn: UIButton!
    @IBAction func tapBack(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    @IBOutlet weak var webView: UIWebView!
    
    var urlImage = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = URL (string: urlImage){
            let requestObj = URLRequest(url: url)
            webView.loadRequest(requestObj)
            webView.delegate = self
            webView.isOpaque = false
            webView.backgroundColor = UIColor.black
        }
        
        let btnIcon = AppDelegate.isRTL ? FontAwesome.chevronRight : FontAwesome.chevronLeft
        backBtn.textFontAwesome(btnIcon)
        backBtn.setTitleColor(UIColor.white, for: .normal)

        // Do any additional setup after loading the view.
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.showNativeActivityIndicator()
      //  UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.hideNativeActivityIndicator()
       // UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
      //  navigationTitle.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.hideNativeActivityIndicator()
//        self.dismiss(animated: false) {
//            ServerController.appDelegate.window?.rootViewController?.showAlertViewNoInternent()
//        }//04/01/2018
        self.dismiss(animated: false) {
            ServerController.appDelegate.window?.rootViewController?.showAlertViewNoInternent {
            }
        }
       // UIApplication.sharedApplication().networkActivityIndicatorVisible = false
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
