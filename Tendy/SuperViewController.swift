//
//  SuperViewController.swift
//  Tendy
//
//  Created by ATN on 30/07/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FontAwesome_swift
import CoreBluetooth

class SuperViewController:ImagePickerViewController,UITextFieldDelegate,UITextViewDelegate,CBPeripheralManagerDelegate{
    var saved=true
    var topY=CGFloat(0)
    var myBTManager:CBPeripheralManager = CBPeripheralManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.extLightlightGray
        myBTManager.delegate = self
    }
    
    func succeeded(str:String=C.Alert.succeeded,showAlert:Bool=true,function: @escaping ()->()={})
    {
        saved=true
        changedImage=false
        if(showAlert) { showAlertView(str,function:function) }
    }
    
    func failed(str:String=C.Alert.failed,showAlert:Bool=true)
    {
        saved=false
        if(showAlert) {  showAlertView(str) }
    }
    
    func  saveReturn(_ error:Error?,_ ref:DatabaseReference ,_ showAlert:Bool=true)
    {
        (error) != nil ? failed() : succeeded(showAlert:showAlert)
    }
    
    func  saveReturn(_ error:Error?,_ ref:DatabaseReference )
    {
        saveReturn(error, ref,true)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField is UnderLineTextField)
        {
            (textField as! UnderLineTextField).bottomBorderHeight=2
            (textField as! UnderLineTextField).bottomBorderColor=UIColor.exGreen
        }
    }
    
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if(textField is UnderLineTextField)
        {
            (textField as! UnderLineTextField).bottomBorderHeight=1
            (textField as! UnderLineTextField).bottomBorderColor=UIColor.extLightGray
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.textAlignment = textField.textAlignment == NSTextAlignment.center ? .center : AppDelegate.isRTL == true ? .right : .left
        textField.resignFirstResponder()
        return true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        self.viewDown()
        //self.viewDown(y: CGFloat(topY))
    }
    
    
    var txtOriginY = CGFloat()
    var txtOriginH = CGFloat()
    func keyboardWillShow(_ notification: Notification) {
        var info: [AnyHashable: Any] = notification.userInfo!
        let kbSize: CGSize = ((info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size)!
        setviewUp(kbSize.height)
    }
    
    func setviewUp(_ animYhight:CGFloat){
     if txtOriginY+txtOriginH > UIScreen.main.bounds.size.height - animYhight{
         let newY = UIScreen.main.bounds.size.height-animYhight-txtOriginH
         let add = txtOriginY-newY + 2
          self.viewUp(add)
       }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func leftBarBtn(_ img:String="",fontAwesome:FontAwesome?=nil,actionStr:String!,target:UIViewController?=nil,text:String?=nil){
        let btn = barBtn(img,fontAwesome: fontAwesome , actionStr: actionStr,target:target,text: text)
        self.navigationItem.leftBarButtonItems=[UIBarButtonItem(customView: btn)]
    }
    
    func backBarBtn(){
        var icon = ""
        if AppDelegate.isRTL == true{
            icon = String.fontAwesomeIcon(name: .chevronRight)
        }else{
            icon = String.fontAwesomeIcon(name: .chevronLeft)
        }
        leftBarBtn(fontAwesome: FontAwesome(rawValue: icon), actionStr: "backBtnClick")
//        let btn = UIButton(frame:CGRect( x: 0,y: 0,width: 20 ,height: 20))
//        //btn.setBackgroundImage(UIImage(named: "backBtn"), for: UIControlState())
//        btn.titleLabel!.font = UIFont.fontAwesome(ofSize: 20)
//        if AppDelegate.isRTL == true{
//            btn.setTitle(String.fontAwesomeIcon(name: .chevronRight), for: .normal)
//        }else{
//            btn.setTitle(String.fontAwesomeIcon(name: .chevronLeft), for: .normal)
//        }
//        btn.setTitleColor(UIColor.white, for: .normal)
//        btn.backgroundColor = UIColor.clear
//        btn.addTarget(self, action:#selector(MainSuperViewController.backBtnClick) , for: .touchUpInside)
//        let menuButton = UIBarButtonItem(customView: btn)
//        self.navigationItem.leftBarButtonItems=[menuButton]
    }
    
    func backBtnClick(){
        if(self.navigationController != nil){
            self.navigationController!.popViewController(animated: true)
        }
        
    }

    
    func rightBarBtn(_ img:String="",fontAwesome:FontAwesome?=nil,actionStr:String!,target:UIViewController?=nil,text:String?=nil){
        let btn = barBtn(img,fontAwesome: fontAwesome , actionStr: actionStr,target:target,text: text)
        self.navigationItem.rightBarButtonItems=[UIBarButtonItem(customView: btn)]
    }
    
    func barBtn(_ img:String,fontAwesome:FontAwesome?=nil,actionStr:String!,target:UIViewController?=nil,text:String?=nil)->UIButton{
        var target = target
        if(target==nil){
            target=self
        }
        let btn = UIButton(frame:CGRect( x: 0,y: 0,width: 26 ,height: 20))
        if(text != nil){
            btn.setTitle(text!, for: UIControlState())
            btn.setTitleColor(UIColor.white, for: UIControlState())
            btn.frame=CGRect( x: 0,y: 0,width: 46 ,height: 30)
        }
        else{
            btn.setBackgroundImage(UIImage(named: img), for: UIControlState())
        }
        if(fontAwesome != nil){
            let font = UIFont.fontAwesome(ofSize: 20)
            let text = String.fontAwesomeIcon(name: fontAwesome!)
            btn.setTitle(text, for: .normal)
            let str = NSAttributedString(string: text, attributes: [NSFontAttributeName: font ,NSForegroundColorAttributeName: UIColor.extLightGray])
            btn.setAttributedTitle(str, for: .normal)
        }
        btn.addTarget(target, action:Selector(actionStr) , for: .touchUpInside)
        return btn
    }
    
    func goToPageMain(){
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        ServerController.appDelegate.goToPageMain()
    }
    
    func goToRealProfile(){
       // let appDelegate = UIApplication.shared.delegate as! AppDelegate
        ServerController.appDelegate.goToRealProfile()
    }
    
    func notificationReceived(data: [String: AnyObject] = [:]){}
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let navigetionBarHeight = (self.navigationController?.navigationBar.frame.size.height != nil) ?self.navigationController?.navigationBar.frame.size.height : 0
        if(textView.superview == self.view){
            txtOriginY = textView.frame.origin.y+statusBarHeight+navigetionBarHeight!
        }
        else{
            txtOriginY = textView.convert(textView.superview!.frame, to:nil).origin.y//+statusBarHeight+navigetionBarHeight//
        }
        txtOriginH = textView.frame.height
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let navigetionBarHeight = (self.navigationController?.navigationBar.frame.size.height != nil) ?self.navigationController?.navigationBar.frame.size.height : 0
        if(textField.superview == self.view){
            txtOriginY = textField.frame.origin.y+statusBarHeight+navigetionBarHeight!
        }
        else{
            txtOriginY = textField.convert(textField.superview!.frame, to:nil).origin.y
        }
        txtOriginH=textField.frame.height
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.textAlignment = textField.textAlignment == NSTextAlignment.center ? .center : AppDelegate.isRTL == true ? .right : .left
        //currentTxtFldEditing?.textAlignment = NSTextAlignment.right
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
    }
    
    //MARK: -CBPeripheralManagerDelegate
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager){
        
        
        P2PKit_Blutooth.sharedInstance.blutoothConnect = peripheral.state == .poweredOn ? true : false
        
    }
}
