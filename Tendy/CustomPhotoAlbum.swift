//
//  CustomPhotoAlbum.swift
//  Tendy
//
//  Created by Shaya Fredman on 22/10/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit
import Foundation
import Photos

class CustomPhotoAlbum: NSObject {
    static let albumName = "Tendy"
    static let sharedInstance = CustomPhotoAlbum()
    static var imagesDownloaded=[String:String]()

    var assetCollection: PHAssetCollection!

    override init() {
        super.init()
        if let imagesDownloadedDic = UserDefaults.standard.object(forKey: C.userDef.imagesDownloaded) as? [String:String]{
            CustomPhotoAlbum.imagesDownloaded = imagesDownloadedDic
        }

//        if let assetCollection = fetchAssetCollectionForAlbum() {
//            self.assetCollection = assetCollection
//            return
//        }

//        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
//            UIApplication.topViewController()?.showAlertView(msg: "UsedPhotos".localized, okButtonTitle: "OK".localized, okFunction: {
//                PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
//                    ()
//                })
//            })
//
////            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
////                ()
////            })
//        }

        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }

        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
//            if let assetCollection = fetchAssetCollectionForAlbum() {
//                self.assetCollection = assetCollection
//                return
//            }
            self.createAlbum()
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
//            UIApplication.topViewController()?.showAlertView(msg: "UsedPhotos".localized, okButtonTitle: "OK".localized, okFunction: {
//                PHPhotoLibrary.requestAuthorization(self.requestAuthorizationHandler)
//            })
        }
    }

    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            // ideally this ensures the creation of the photo album even if authorization wasn't prompted till after init was done
            print("trying again to create the album")
            self.createAlbum()
        } else {
            print("should really prompt the user to let them know it's failed")
        }
    }

    func createAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)   // create an asset collection with the album name
        }) { success, error in
            if success {
                self.assetCollection = self.fetchAssetCollectionForAlbum()
            } else {
                print("error \(error)")
            }
        }
    }

    func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }

    func save(image: UIImage,imageName:String) {

        var localIdentifier = ""
        if CustomPhotoAlbum.imagesDownloaded[imageName] == nil{
            if assetCollection == nil {
                return                          // if there was an error upstream, skip the save
            }
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            //assetPlaceHolder?.localIdentifier = imageName
            //albumChangeRequest?.title = imageName
            PHAssetResourceCreationOptions.accessibilityAssistiveTechnologyFocusedIdentifiers()
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest!.addAssets(enumeration)
            print(assetPlaceHolder?.localIdentifier)
            localIdentifier = (assetPlaceHolder?.localIdentifier)!
            CustomPhotoAlbum.imagesDownloaded[imageName] = assetPlaceHolder?.localIdentifier

        }, completionHandler: { (resalt, error) in
            if resalt == true{
               // CustomPhotoAlbum.imagesDownloaded[imageName] = localIdentifier
            }else{
                CustomPhotoAlbum.imagesDownloaded.removeValue(forKey: imageName)
                //CustomPhotoAlbum.sharedInstance.save(image: image,imageName:imageName)
            }
            print(resalt)
            print(error.debugDescription)
        })
        }
    }
    
    var manager = PHImageManager.default()
    
    func retrieveImageWithIdentifer(localIdentifier:String, completion: @escaping (_ image:UIImage?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        let fetchResults = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: fetchOptions)
        
        if fetchResults.count > 0 {
            if let imageAsset = fetchResults.object(at: 0) as? PHAsset {
                let requestOptions = PHImageRequestOptions()
                requestOptions.deliveryMode = .highQualityFormat
                manager.requestImage(for: imageAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, info) -> Void in
                    completion(image)
                })
            } else {
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }
}


    
//    func mytry(image:UIImage){
//        var jpeg: Data? = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(image as! CMSampleBuffer)
//        var source: CGImageSource = nil
//        source = CGImageSourceCreateWithData((jpeg as? CFDataRef), nil)
//        //get all the metadata in the image
//        var metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [AnyHashable: Any]
//        //make the metadata dictionary mutable so we can add properties to it
//        var metadataAsMutable = metadata
//        var EXIFDictionary = (metadataAsMutable?[(kCGImagePropertyExifDictionary as? String)])
//        var GPSDictionary = (metadataAsMutable?[(kCGImagePropertyGPSDictionary as? String)])
//        if EXIFDictionary == nil {
//            //if the image does not have an EXIF dictionary (not all images do), then create one for us to use
//            EXIFDictionary = [AnyHashable: Any]()
//        }
//        if GPSDictionary == nil {
//            GPSDictionary = [AnyHashable: Any]()
//        }
//        //Setup GPS dict
////        GPSDictionary?[(kCGImagePropertyGPSLatitude as? String)] = lat
////        GPSDictionary?[(kCGImagePropertyGPSLongitude as? String)] = lon
////        GPSDictionary?[(kCGImagePropertyGPSLatitudeRef as? String)] = lat_ref
////        GPSDictionary?[(kCGImagePropertyGPSLongitudeRef as? String)] = lon_ref
////        GPSDictionary?[(kCGImagePropertyGPSAltitude as? String)] = alt
////        GPSDictionary?[(kCGImagePropertyGPSAltitudeRef as? String)] = Int(alt_ref)
////        GPSDictionary?[(kCGImagePropertyGPSImgDirection as? String)] = heading
////        GPSDictionary?[(kCGImagePropertyGPSImgDirectionRef as? String)] = "\(headingRef)"
////        EXIFDictionary?[(kCGImagePropertyExifUserComment as? String)] = xml
//        //add our modified EXIF data back into the image’s metadata
//        metadataAsMutable?[(kCGImagePropertyExifDictionary as? String)] = EXIFDictionary
//        metadataAsMutable?[(kCGImagePropertyGPSDictionary as? String)] = GPSDictionary
//        var UTI: CFString = CGImageSourceGetType(source)!
//        //this is the type of image (e.g., public.jpeg)
//        //this will be the data CGImageDestinationRef will write into
//        var dest_data = Data()
//        var destination: CGImageDestination = CGImageDestinationCreateWithData((dest_data as! CFMutableData), UTI, 1, nil)!
//        if destination == nil {
//            print("***Could not create image destination ***")
//        }
//        //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
//        CGImageDestinationAddImageFromSource(destination, source, 0, (metadataAsMutable as! CFDictionary))
//        //tell the destination to write the image data and metadata into our data object.
//        //It will return false if something goes wrong
//        var success = false
//        success = CGImageDestinationFinalize(destination)
//        if !success {
//            print("***Could not create data from image destination ***")
//        }
//        //now we have the data ready to go, so do whatever you want with it
//        //here we just write it to disk at the same path we were passed
//        //dest_data.write(toFile: file, atomically: true)
//        //cleanup
//    }
//}


    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        dismiss(animated: true) { _ in }
//        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
//        var metadata = info[UIImagePickerControllerMediaMetadata] as? [AnyHashable: Any]
//        // set image name and keywords in IPTC metadata
//        let iptcKey = kCGImagePropertyIPTCDictionary as? String
//        var iptcMetadata = metadata[iptcKey] as? [AnyHashable: Any]
//        iptcMetadata[(kCGImagePropertyIPTCObjectName as? String)] = "Image Title"
//        iptcMetadata[(kCGImagePropertyIPTCKeywords as? String)] = "some keywords"
//        metadata[iptcKey] = iptcMetadata
//        // set image description in TIFF metadata
//
//        var tiffKey = kCGImagePropertyTIFFDictionary as? String
//        var tiffMetadata = metadata[tiffKey]
//        tiffMetadata[(kCGImagePropertyTIFFImageDescription as? String)] = "Description for image"
//        // only visible in iPhoto when IPTCObjectName is set
//        metadata[tiffKey] = tiffMetadata
//        // save image to camera roll
//        var library = ALAssetsLibrary()
//        library.writeImage(toSavedPhotosAlbum: image.cgImage, metadata: metadata, completionBlock: nil)
//}


//class CustomPhotoAlbum{
//
//    static let albumName = "Tendy"
//    static let sharedInstance = CustomPhotoAlbum()
//    static var imagesDownloaded=[String:String]()
//
//    var assetCollection: PHAssetCollection!
//
//    init() {
//
//        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
//
//            let fetchOptions = PHFetchOptions()
//            fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
//            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
//
//            if let firstObject: AnyObject = collection.firstObject {
//                return firstObject as! PHAssetCollection
//            }
//
//            return nil
//        }
//
//        if let assetCollection = fetchAssetCollectionForAlbum() {
//            self.assetCollection = assetCollection
//            return
//        }
//
//        PHPhotoLibrary.shared().performChanges({
//            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)
//        }) { success, _ in
//            if success {
//                self.assetCollection = fetchAssetCollectionForAlbum()
//            }
//        }
//    }
//
//    func saveImage(image: UIImage,imageName:String) {
//        if CustomPhotoAlbum.imagesDownloaded[imageName] == nil{
//        if assetCollection == nil {
//            return   // If there was an error upstream, skip the save.
//        }
//        PHPhotoLibrary.shared().performChanges({
//            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
//            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
//            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
//            albumChangeRequest?.addAssets([assetPlaceholder] as NSFastEnumeration)
//            print(assetPlaceholder?.localIdentifier)
//            CustomPhotoAlbum.imagesDownloaded[imageName] = assetPlaceholder?.localIdentifier
//        }) { (resault, err) in
//            print(err.debugDescription)
//        }
////        PHPhotoLibrary.shared().performChanges({
////            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
////            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
////            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
////            albumChangeRequest?.addAssets([assetPlaceholder] as! NSFastEnumeration)
////            //albumChangeRequest?.addAssets([assetPlaceholder])
////        }, completionHandler: nil)
//    }
//}
//}

