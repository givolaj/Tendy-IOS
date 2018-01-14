//
//  ImagePickerViewController.swift
//  Buildi
//
//  Created by Shaya Fredman on 5/25/16.
//  Copyright © 2016 bfmobile. All rights reserved.
//

import UIKit
class ImagePickerViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate {
    
    var changedImage=false
    var image=UIImage()
    let imagePicker = UIImagePickerController()
    var imgUrl:String=""
    var imgUrlFault:String=""
    var numImagesInUpload=0
    let sheet: UIActionSheet = UIActionSheet()
    var showSheet=true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction  func btnImgClick(_ sender: AnyObject) {
        if(showSheet==true){
            sheet.addButton(withTitle: C.UI.cancel)
            sheet.addButton(withTitle: C.UI.camera)
            sheet.addButton(withTitle: C.UI.photoAlbum)
            sheet.tag=sender.tag
            sheet.cancelButtonIndex = 0
            self.view.endEditing(true)
            sheet.delegate = self
            sheet.show(in: self.view)
        }
    }
    
    
    func setImage(){
        let btn =  self.view.viewWithTag(sheet.tag) as! UIButton
        btn.setImage(image, for: UIControlState())
        btn.imageView!.scallFillImg()
        saveImgUrl(sheet.tag)
    }
    
    func imgToString()->String{
        let imageData:Data = UIImagePNGRepresentation(image)!
        return imageData.base64EncodedString(options: .lineLength64Characters)
    }
    
    func saveImgUrl(_ tag: Int ){
        numImagesInUpload+=1
        uploadToCloudinary(id: tag.description)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage]as? UIImage{
            self.image = image.resized(newWidth: 500)!
//            setImage()
//            dismiss(animated: true, completion: nil)
            dismiss(animated: true, completion: {
                self.setImage()
            })
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - actionSheetDelegate
    func actionSheet(_ sheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != 0{
            imagePicker.delegate = self
            
            if buttonIndex == 2{
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    imagePicker.sourceType = .photoLibrary
                }
            }else{
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    imagePicker.sourceType = .camera
                }
            }
            if UIImagePickerController.isSourceTypeAvailable(.camera) || UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                present(imagePicker, animated: true, completion:nil)
            }
        }else{}
    }
    
    func uploadToCloudinary(id:String){
    }
    
    func uploaderSuccess(_ result: [AnyHashable : Any]!, context: Any!) {
        let x = result["url"] as! String
        print("xxxx",x)
    }
}
