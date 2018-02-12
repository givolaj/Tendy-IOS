




import UIKit
import FontAwesome_swift
import ImageIO
import UserNotifications


extension String
{
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func localized(withComment:String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: withComment)
    }
    
    func stringToDate()->NSDate?
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat="dd/MM/yyyy H:mm:ss"
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        dateFormatter.locale = Locale(identifier: "us")
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        //let date = Date(timeIntervalSince1970:Double(self)!)
        let date = Date(timeIntervalSince1970:(Double(self)!-ServerController.currentmillisAppStart)/1000)
        dateFormatter.timeZone = NSTimeZone.local
        if(date != nil)
        {
            let timeStamp = dateFormatter.string(from: date)
            dateFormatter.dateFormat="dd/MM/yyyy H:mm:ss"
            return  dateFormatter.date(from: timeStamp) as NSDate?
        }
        return nil
    }
    
    func stringToDateString()->String
    {
        // let date = Date(timeIntervalSince1970:Double(self)!)
        let date = Date(timeIntervalSince1970:(Double(self)!-ServerController.currentmillisAppStart)/1000)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local//(name: "UTC") as TimeZone!
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = Locale.current//(identifier: "us")
        dateFormatter.dateFormat = "dd/MM/yyyy H:mm:ss"
        return dateFormatter.string(from: date)
        
    }
    func toDate()->Date?
    {
        if(self.isEmpty)
        {
            return nil
        }
        //return Date(timeIntervalSince1970:Double(self)!)
        return Date(timeIntervalSince1970:(Double(self)!-ServerController.currentmillisAppStart)/1000)
    }
    
    var isEmpty:Bool
    {
        var text=trimmingCharacters(in: CharacterSet.whitespaces)
        text = text.trimmingCharacters(in: CharacterSet.newlines)
        var text1=trimmingCharacters(in: CharacterSet.newlines)
        text1 = text.trimmingCharacters(in: CharacterSet.whitespaces)
        return (characters.count>0&&text != "" && text1 != "" &&
            trimmingCharacters(in: CharacterSet.whitespaces) != "" && text.trimmingCharacters(in: CharacterSet.newlines) != "") ? false:true
        
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func convertToAnyObjectDictionary() -> [String: AnyObject]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func stringToShortDate()->Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.date(from: self)!
    }
    
    func stringBirthdadyToAge()->String{
        let now = Date()
        let birthday: Date = stringToShortDate()
        let calendar = Calendar.current
        
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        let age = ageComponents.year!
        return String(age)
    }
    
    func replace(target: String, withString: String) -> String{
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
}
extension UIButton
{
    func textFontAwesome(_ fontAwesome:FontAwesome)
    {
        let font = UIFont.fontAwesome(ofSize: 20)
        let text = String.fontAwesomeIcon(name: fontAwesome)
        let str = NSAttributedString(string: text, attributes: [NSFontAttributeName: font ,NSForegroundColorAttributeName: UIColor.extLightGray])
        self.setAttributedTitle(str, for: .normal)
    }
}

extension Dictionary{
    func convertToJson()->[String:String]?{
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            
            let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
            // here "decoded" is of type `Any`, decoded from JSON data
            
            // you can now cast it with the right type
            if let dictFromJSON = decoded as? [String:String] {
                // use dictFromJSON
                return dictFromJSON
            }
            return nil
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

extension UIViewController
{
    

    func showNativeActivityIndicator()
    {
        view.showNativeActivityIndicator(activityIndicatorStyle: .whiteLarge, beginIgnoringInteractionEvents: true)
    }
    func hideNativeActivityIndicator(){
        view.hideNativeActivityIndicator()
    }
    
    func viewUp(_ heigthKeyboard:CGFloat) {
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        //let navigetionBarHeight = self.navigationController!.navigationBar.frame.size.height
        var navigetionBarHeight = self.navigationController?.navigationBar.frame.size.height
        if( navigetionBarHeight==nil)
        {
            navigetionBarHeight=0
        }
        let newY = -heigthKeyboard+statusBarHeight+navigetionBarHeight!
        UIView.beginAnimations(nil, context:nil)
        UIView.setAnimationDuration(0.3)
        self.view!.frame = CGRect(x: self.view!.frame.origin.x, y: newY > 0 ? 0 : newY , width: self.view!.frame.size.width, height: self.view!.frame.size.height)
        UIView.commitAnimations()
    }
    
    func viewDown(y:CGFloat=0) {
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        var navigetionBarHeight = self.navigationController?.navigationBar.frame.size.height
        if( navigetionBarHeight==nil)
        {
            navigetionBarHeight=0
        }
        self.view.endEditing(true)
        //UIView.beginAnimations(nil, context:nil)
        //UIView.setAnimationDuration(0.3)
        self.view!.frame = CGRect(x: self.view!.frame.origin.x, y: statusBarHeight + navigetionBarHeight!, width: self.view!.frame.size.width, height: self.view!.frame.size.height)
        //UIView.commitAnimations()
        
        /*
         //  let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
         //  var navigetionBarHeight = self.navigationController?.navigationBar.frame.size.height
         //  if( navigetionBarHeight==nil)
         //  {
         //      navigetionBarHeight=0
         //  }
         self.view.endEditing(true)
         UIView.beginAnimations(nil, context:nil)
         UIView.setAnimationDuration(0.3)
         self.view!.frame = CGRect(x: self.view!.frame.origin.x, y: y, width: self.view!.frame.size.width, height: self.view!.frame.size.height)
         UIView.commitAnimations()
         */
    }
    
    func showAlertView(title:String="",_ str:String,function: @escaping ()->()={}){
        let alertController = UIAlertController(title: title, message: str, preferredStyle: UIAlertControllerStyle.alert)
        // let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
        //}
        let okAction = UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            function()
        }
        //alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        //alertController.setBackgroundColor(backgroundColor: UIColor.red)//צבע רקע
        //okAction.setValue(UIColor.red, forKey: "titleTextColor")//צבע טקסט בכפתורים
        
        alertController.show()
        
        //הוספת תמונה
//        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
//        imageView.image = #imageLiteral(resourceName: "icon")
//        alertController.view.addSubview(imageView)

        //UIApplication.shared.keyWindow?.rootViewController!.present(alertController, animated: false, completion: nil)
    }
    
    func showAlertViewNoInternent(){
        let alertController = UIAlertController(title: "Problem".localized, message: "No Internet connection found".localized, preferredStyle: UIAlertControllerStyle.alert)
        // let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
        //}
        let okAction = UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            exit(0)
        }
        //alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.hideNativeActivityIndicator()
        DispatchQueue.main.async {
            alertController.show()
            //ServerController.appDelegate.window?.rootViewController?.present(alertController, animated: false, completion: nil)
        }
    }
    
    func showAlertViewNoInternent(okFunction:@escaping ()->()){
        let alertController = UIAlertController(title: "Problem".localized, message: "No Internet connection found".localized, preferredStyle: UIAlertControllerStyle.alert)
        // let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
        //}
        let okAction = UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            okFunction()
        }
        //alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.hideNativeActivityIndicator()
        DispatchQueue.main.async {
            alertController.show()
            //ServerController.appDelegate.window?.rootViewController?.present(alertController, animated: false, completion: nil)
        }
    }
    
    func showAlertView(title:String="",msg:String="",okButtonTitle:String="OK".localized,otherButtonTitle:String="",okFunction:@escaping ()->(),otherFunction:@escaping ()->()){
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        // let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
        //}
        let okAction = UIAlertAction(title:okButtonTitle, style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            okFunction()
        }
        //alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        let otherAction = UIAlertAction(title:otherButtonTitle, style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            otherFunction()
        }
        //alertController.addAction(cancelAction)
        alertController.addAction(otherAction)
//        if #available(iOS 9.0, *) {
//            alertController.preferredAction = okAction
//        }
        alertController.show()
        //UIApplication.shared.keyWindow?.rootViewController!.present(alertController, animated: false, completion: nil)
    }
    
    func showAlertView(title:String?="",msg:String="",okButtonTitle:String="OK".localized,okFunction:@escaping ()->()){
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title:okButtonTitle, style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            alertController.dismiss(animated: true, completion: nil)
            okFunction()
        }
        alertController.addAction(okAction)
        alertController.show()
        //UIApplication.shared.keyWindow?.rootViewController!.present(alertController, animated: false, completion: nil)
    }
}

extension UIImage
{
    func resized(newWidth: CGFloat) -> UIImage?{
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage =  UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    class func imageWithUrl(_ url:String?)->UIImage? {
        if(url != nil)
        {
            let url = URL(string:url!)
            let data = try? Data(contentsOf: url!)
            return  UIImage(data: data!)
        }
        return UIImage()
    }
    convenience init(url:String?) {
        self.init()
        if(url != nil)
        {
            let url = URL(string:url!)
            let data = try? Data(contentsOf: url!)
            (data: data!)
        }
        
    }
    
    func downloadedFrom(link: String, completion: @escaping (_ exist:Bool,_ image:UIImage)->()) {
        guard let url = URL(string: link) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                
                let image = UIImage(data: data)
                
                else { return }
                imgesDic[link]=image
                completion(false,image)
            }.resume()
    }
    
    //  func setImgwithUrl(_ link: String, contentMode mode: UIViewContentMode = .scaleAspectFill,completion: @escaping (_ exist:Bool)->()={_ in }) {
    func setImgwithUrl(_ link: String, completion: @escaping (_ exist:Bool,_ image:UIImage)->()={_ in }) {
        if(imgesDic[link]==nil){
            downloadedFrom(link: link, completion: completion)
        }
        else{
            let image=imgesDic[link]
            completion(true, image!)
        }
    }
    
    //   //GIFT
    //        public class func gifImageWithData(_ data: Data) -> UIImage? {
    //            guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
    //                print("image doesn't exist")
    //                return nil
    //            }
    //
    //            return UIImage.animatedImageWithSource(source)
    //        }
    //
    //        public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
    //            guard let bundleURL = URL(string: gifUrl)
    //                else {
    //                    print("image named \"\(gifUrl)\" doesn't exist")
    //                    return nil
    //            }
    //            guard let imageData = try? Data(contentsOf: bundleURL) else {
    //                print("image named \"\(gifUrl)\" into NSData")
    //                return nil
    //            }
    //
    //            return gifImageWithData(imageData)
    //        }
    //
    //        public class func gifImageWithName(_ name: String) -> UIImage? {
    //            guard let bundleURL = Bundle.main
    //                .url(forResource: name, withExtension: "gif") else {
    //                    print("SwiftGif: This image named \"\(name)\" does not exist")
    //                    return nil
    //            }
    //            guard let imageData = try? Data(contentsOf: bundleURL) else {
    //                print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
    //                return nil
    //            }
    //
    //            return gifImageWithData(imageData)
    //        }
    
}


extension UIImageView
{
    func scallFillImg()
    {
        contentMode = UIViewContentMode.scaleAspectFill
        clipsToBounds=true
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFill, toSave:Bool, imageName:String ,completion: @escaping (_ exist:Bool)->()) {
        contentMode = mode
        clipsToBounds=true
        
        image=UIImage()
        guard let url = URL(string: link) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            self.hideNativeActivityIndicator()
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                
                let image = UIImage(data: data)
                
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
                imgesDic[link]=image
                completion(false)
                self.contentMode = mode
                
            }
            if toSave{
                //DispatchQueue.global(qos: .background).async {
                CustomPhotoAlbum.sharedInstance.save(image: image,imageName: imageName)
                //CustomPhotoAlbum.sharedInstance.saveImage(image: image,imageName: imageName)
                //}
            }
            }.resume()
    }
    
  //  func setImgwithUrl(_ link: String, contentMode mode: UIViewContentMode = .scaleAspectFill,completion: @escaping (_ exist:Bool)->()={_ in }) {
    func setImgwithUrl(_ link: String, contentMode mode: UIViewContentMode = .scaleAspectFill, toSave:Bool = false ,imageName:String = "" ,completion: @escaping (_ exist:Bool)->()={_ in }) {
        //self.image=UIImage()
        if(imgesDic[link]==nil){
            downloadedFrom(link: link, contentMode: mode,toSave: toSave,imageName: imageName,completion: completion)
        }
        else{
            DispatchQueue.main.async() { () -> Void in
               self.image=imgesDic[link]
                if toSave{
                    //DispatchQueue.global(qos: .background).async {
                    CustomPhotoAlbum.sharedInstance.save(image: self.image!,imageName: imageName)
                    //CustomPhotoAlbum.sharedInstance.saveImage(image: image!,imageName: imageName)
                    //}
                }
            }
//            if toSave{
//                //DispatchQueue.global(qos: .background).async {
//                    CustomPhotoAlbum.sharedInstance.save(image: self.image!,imageName: imageName)
//                //CustomPhotoAlbum.sharedInstance.saveImage(image: image!,imageName: imageName)
//                //}
//            }
            contentMode = mode
            clipsToBounds=true
            completion(true)
        }
    }
}
extension UINavigationBar {
    
    //    func hideBottomHairline() {
    //        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
    //        navigationBarImageView!.isHidden = true
    //    }
    //
    //    fileprivate func hairlineImageViewInNavigationBar(_ view: UIView) -> UIImageView? {
    //        if view.isKind(of: UIImageView.self) && view.bounds.height <= 1.0 {
    //            return (view as! UIImageView)
    //        }
    //
    //        let subviews = (view.subviews as [UIView])
    //        for subview: UIView in subviews {
    //            if let imageView: UIImageView = hairlineImageViewInNavigationBar(subview) {
    //                return imageView
    //            }
    //        }
    //
    //        return nil
    //    }
    
}

extension UILabel
{
    func txtRows()
    {
        lineBreakMode = .byWordWrapping
        numberOfLines=0
        sizeToFit()
    }
}

extension UITextField {
    
    var isEmpty:Bool
    {
        return (text==nil) ? false : text!.isEmpty
    }
    
}
extension UIView
{
    
    func zoomInOut()
    {
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.3) {
                            self.transform = CGAffineTransform.identity
                        }
        })
    }
    
    @nonobjc static var ACTIVITY_INDICATOR_VIEW_TAG = 123456
    func showNativeActivityIndicator(activityIndicatorStyle:UIActivityIndicatorViewStyle=UIActivityIndicatorViewStyle.white,beginIgnoringInteractionEvents:Bool=false,clr:UIColor=UIColor.exDarkGray) {
        self.hideNativeActivityIndicator()
        let avToShow: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle:activityIndicatorStyle)
        avToShow.center = CGPoint(x: (self.frame.size.width) / 2, y: (self.frame.size.height) / 2)
        avToShow.tag = UIView.ACTIVITY_INDICATOR_VIEW_TAG
        avToShow.color = clr
        DispatchQueue.main.async(execute: {
        self.addSubview(avToShow)
        avToShow.startAnimating()
        if(beginIgnoringInteractionEvents==true)
        {
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
        })
    }
    
    func hideNativeActivityIndicator(_ cont: UIViewController?=nil,view:UIView?=nil) {
        DispatchQueue.main.async() { () -> Void in
            if(self.viewWithTag(UIView.ACTIVITY_INDICATOR_VIEW_TAG) != nil)
            {
                let showedAv: UIActivityIndicatorView = (self.viewWithTag(UIView.ACTIVITY_INDICATOR_VIEW_TAG) as! UIActivityIndicatorView)
                showedAv.removeFromSuperview()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    func shadow()
    {
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 1.0
    }
    func round()
    {
        layer.cornerRadius=self.frame.size.height/2
        clipsToBounds=true
    }
    
    func border(_ clr:UIColor=UIColor.white,borderWidth:CGFloat=1)
    {
        layer.borderColor=clr.cgColor
        layer.borderWidth=borderWidth
        clipsToBounds=true
    }
    
    func cornerRadius(_ num:CGFloat=0.45,isCornerNum:Bool=false)
    {
        if(isCornerNum)
        {
            layer.cornerRadius=num
        }
        else
        {
            layer.cornerRadius=self.frame.height*num
        }
        clipsToBounds=true
    }
    
    func createImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
        
        
//        let rect: CGRect = self.frame
//        //let rect: CGRect = CGRect(origin: CGPoint.zero, size: CGSize(width: 150, height: 150))
//        UIGraphicsBeginImageContext(rect.size)
//        if let context: CGContext = UIGraphicsGetCurrentContext(){
//            self.layer.render(in: context)
//            if let img = UIGraphicsGetImageFromCurrentImageContext(){
//        UIGraphicsEndImageContext()
//                return img
//            }
//        }
//        return nil
    }
    
    
}
extension UITableView
{
    func backClearClr(_ cell:UITableViewCell)
    {
        cell.backgroundColor=UIColor.clear
        cell.contentView.backgroundColor=UIColor.clear
        backgroundColor=UIColor.clear
        
    }
    
        func scrollToBottom()
        {
            if (self.contentSize.height>self.frame.size.height)
            {
                self.contentOffset=CGPoint(x: 0, y: self.contentSize.height-self.frame.size.height)
            }
            else
            {
                //self.contentOffset=CGPoint(x: 0,y: self.contentSize.height-self.frame.size.height)
                //self.frame = CGRect(origin: CGPoint(x:0,y:self.frame.size.height-self.contentSize.height), size:  self.frame.size)
                self.contentOffset=CGPoint(x: 0,y: 0)
            }
    }
}

extension UIColor{
    //MARK: - colorWithHex
    static func colorWithHexString (_ hex:String, alpha:CGFloat=1) -> UIColor {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    static  var  exDarkGray: UIColor
    {
        return colorWithHexString("#37474F")
    }
    static  var  exGreenBubble: UIColor
    {
        return colorWithHexString("#E0F2F1")
    }
    static  var  chatMe: UIColor
    {
        return colorWithHexString("#dcf8c6")
    }
    static  var  chatPartner: UIColor
    {
        return colorWithHexString("#ece5dd")
    }
    static  var  chatSpecial: UIColor
    {
        return colorWithHexString("#f0f0f0")
    }
    static  var  extWhite: UIColor
    {
        return colorWithHexString("#fdfefe")
    }
    
    static  var  exGreen: UIColor
    {
        return colorWithHexString("#009688")
    }
    
    static var exRed: UIColor
    {
        return colorWithHexString("#A80E04")
    }
    
    static  var  extLightGray: UIColor
    {
        return colorWithHexString("#90A4AE")
    }
    static  var  extLightGrayAlpha: UIColor
    {
        return colorWithHexString("#90A4AE",alpha: 0.4)
    }
    static  var  extLightlightGray: UIColor
    {
        return colorWithHexString("#ECEFF1")
    }
    
    static  var  extYellow: UIColor
    {
        return colorWithHexString("#FFCA28")
    }
    
    //הצבעים של אנדרואיד
//    <color name="yellow">#FFCA28</color>
//    <color name="light_gray">#b0b0b0</color>
//    <color name="medium_gray">#888888</color>
//    <color name="darkGray">#37474F</color>
//    <color name="gray">#525252</color>
//    <color name="green">#009688</color>
//    <color name="red">#c05050</color>
//    <color name="darkGreen">#007766</color>
//    <color name="white">#fdfefe</color>
//    <color name="black">#2a2a2a</color>
//    <color name="chatMe">#dcf8c6</color>
//    <color name="chatSpecial">#f0f0f0</color>
//    <color name="chatPartner">#ece5dd</color>
//    <color name="reallyBlack">#111111</color>
//    <color name="orange">#FFA500</color>
}
extension UIButton
{
    func resizeImage(newWidth:CGFloat)   {
        self.setImage(self.imageView!.image!.resized(newWidth: newWidth), for: .normal)
    }
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFill,completion: @escaping (_ exist:Bool)->()) {
        self.imageView!.contentMode = mode
        //self.setBackgroundImage(UIImage(), for: .normal)
        //setImage(UIImage(), for: .normal)
        guard let url = URL(string: link) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            self.hideNativeActivityIndicator()
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                
                var image = UIImage(data: data)

                
                else { return }
            DispatchQueue.main.async() { () -> Void in
                image = image.imageResize(sizeChange: self.imageView!.frame.size)
                
                self.setImage(image, for: .normal)
                //self.setBackgroundImage(image, for: .normal)
                imgesDic[link]=image
                completion(false)
            }
            }.resume()
    }
    
    func setImgwithUrl(_ link: String, contentMode mode: UIViewContentMode = .scaleAspectFill,completion: @escaping (_ exist:Bool)->()={_ in }) {
        //func setImgwithUrl(_ link: String, contentMode mode: UIViewContentMode = .scaleToFill,completion: @escaping (_ exist:Bool)->()={_ in }) {
        self.contentVerticalAlignment = .fill
        self.contentHorizontalAlignment = .fill
        if(imgesDic[link]==nil)
        {
            downloadedFrom(link: link, contentMode: mode,completion: completion)
        }
        else{
            DispatchQueue.main.async() { () -> Void in
                //self.setBackgroundImage(imgesDic[link], for: .normal)
                self.setImage(imgesDic[link], for: .normal)
                
                self.imageView!.contentMode = mode
                
                completion(true)
            }
        }
    }
    
//    func setImage(image: UIImage?, inFrame frame: CGRect?, forState state: UIControlState){
//        self.setImage(image, for: state)
//        
//        if let frame = frame{
//            self.imageEdgeInsets = UIEdgeInsets(
//                top: frame.minY - self.frame.minY,
//                left: frame.minX - self.frame.minX,
//                bottom: self.frame.maxY - frame.maxY,
//                right: self.frame.maxX - frame.maxX
//            )
//        }
//    }
}
var imgesDic=[String:UIImage]()


//MARK: -InternetConnection
import SystemConfiguration


protocol Utilities {
}

extension NSObject:Utilities{
    
    
    enum ReachabilityStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }
    
    var currentReachabilityStatus: ReachabilityStatus {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }
        
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }
    
    func checkInternt()->Bool{
        if currentReachabilityStatus == .notReachable{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            //DispatchQueue.main.async {
                appDelegate.window?.rootViewController?.showAlertViewNoInternent()
            //}
            return false
        }
        return true
    }
    
    func checkInternt(okFunction:@escaping ()->())->Bool{//04/01/2018
        if currentReachabilityStatus == .notReachable{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            //DispatchQueue.main.async {
            appDelegate.window?.rootViewController?.showAlertViewNoInternent {
                okFunction()
            }
            //}
            return false
        }
        return true
    }
    
}

extension UIApplication {
    
    static func topViewController(base: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}

enum UIUserInterfaceIdiom : Int
{
    case Unspecified
    case Phone
    case Pad
}

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    //static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD = ScreenSize.SCREEN_MAX_LENGTH <= 480
}

@available(iOS 10.0, *)
extension UNNotificationAttachment {
    static func create(identifier: String, image: UIImage, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileIdentifier = identifier+".png"
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
            guard let imageData = UIImagePNGRepresentation(image) else {
                return nil
            }
            try imageData.write(to: fileURL)
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            return imageAttachment        } catch {
                print("error " + error.localizedDescription)
        }
        return nil
    }
}

public extension UIAlertController {
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindowLevelAlert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
    
    func changeFont(view: UIView, font:UIFont) {
        for item in view.subviews {
            if item.isKind(of: UICollectionView.self) {
                let col = item as! UICollectionView
                for  row in col.subviews{
                    changeFont(view: row, font: font)
                }
            }
            if item.isKind(of: UILabel.self) {
                let label = item as! UILabel
                label.font = font
            }else {
                changeFont(view: item, font: font)
            }
            
        }
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let font = UIFont(name: C.Font.fontRegular, size: 17)!
        changeFont(view: self.view, font: font )
    }
    
    func setBackgroundColor(backgroundColor:UIColor){
        let subView = view.subviews.first!
        let alertContentView = subView.subviews.first!
        for subview in alertContentView.subviews {
            subview.backgroundColor = backgroundColor
        }
       // alertContentView.backgroundColor = backgroundColor
    }
    
    
    
}

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}
