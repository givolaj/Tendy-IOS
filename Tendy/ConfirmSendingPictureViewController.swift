//
//  ConfirmSendingPictureViewController.swift
//  Tendy
//
//  Created by Shaya Fredman on 27/12/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit
protocol SendImageDelegate {
    func okSendImage()
}

class ConfirmSendingPictureViewController: SuperViewController/*UIViewController*//*,UIGestureRecognizerDelegate*/{

    var partnerId = ""
    override func notificationReceived(data: [String: AnyObject]) {
        if let senderId = data["sender"] as? String{
            if senderId != partnerId{
                LocalNoteficationManager.sharedInstance.addChatNotification(data: data)
            }
        }
        //  {"text":"עןהלבו","key":"-KutEzRPTOT9RIL0P-ss","dateAdded":"1506346529369","imageUrl":"","sender":"ijEIzYS7iAXg7SfbYzS7QWfUisI2","deleted":""}
        print(data)
    }
    
    var sendImageDelegate:SendImageDelegate! = nil
    var myImage = UIImage()
    
    @IBOutlet weak var viewObjects: UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBAction func tapClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblOkSend: UILabel!
    @IBOutlet weak var btnSend: RoundButton!
    @IBAction func tapSend(_ sender: RoundButton) {
        self.dismiss(animated: true) {
            self.sendImageDelegate.okSendImage()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let strSend = NSAttributedString(string: String.fontAwesomeIcon(name: .send), attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 20) ,NSForegroundColorAttributeName: UIColor.white])
        btnSend.setAttributedTitle(strSend,for: .normal)
        btnSend.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        
        let strClode = NSAttributedString(string: String.fontAwesomeIcon(name: .times), attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 20) ,NSForegroundColorAttributeName: UIColor.white])
        btnClose.setAttributedTitle(strClode,for: .normal)
        lblOkSend.text = "confirm image".localized
        
//        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.dismiss(sender:)))
//        gesture.delegate = self
//         self.backgroundView.addGestureRecognizer(gesture)
        imageView.image = myImage
        self.view.backgroundColor = UIColor.colorWithHexString("000000", alpha: 0.5)
//        self.view.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    
//    func dismiss(sender:UITapGestureRecognizer){
//        self.dismiss(animated: true, completion: nil)
//        // do other task
//    }
//
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
////        if viewObjects.frame.contains(gestureRecognizer.location(in: self.view)){
////        if viewObjects.frame.contains((touch.view?.frame)!){
////        if (touch.view?.frame.contains(viewObjects.frame))!{
//        if viewObjects.frame.contains(touch.location(in: self.view)){
//            return false
//        }
//        return true
////        if (touch.view?.isDescendant(of: viewObjects))!{
////            return true
////        }
////        return false
//    }

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
