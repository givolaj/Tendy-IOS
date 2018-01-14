//
//  File.swift
//  Tendy
//
//  Created by ATN on 31/07/2017.
//  Copyright © 2017 ATN. All rights reserved.
//


//protocol EnumDescription  {
//    var description: String { get }
//}

enum Gender: Int{//, EnumDescription {
    case woman = 0
    case man = 1
    case other = 2
    var description: String {
        switch self {
        case .woman:
            return "woman"
        case .man:
            return "man"
        case .other:
            return "other"

        }
    }
}

struct C {
    
    struct Gender  {
        static let woman="woman"
        static let man="man"
        static let other="other"
    }
    
    struct DataBase  {
        static let Mail="Mail"
        static let Uid="Uid"
        static let profiles="profiles"
        static let realProfiles="realProfiles"
        static let chatPartners="chatPartners"
        static let chats="chats"
    }
    struct userDef {
        static let showInstructions="showInstructions"
        static let chatBadges="chatBadges"
        static let partnersAroundJson="partnersAroundJson"
        static let imagesDownloaded="imagesDownloaded"
    }
    struct Alert  {
        static let requiredEnableTalk="required Enable Talk".localized

        static let requiredMainProfile="fill_profile_first".localized
        static let registerSucceed="register succeed".localized
        static let setAllFileds="setAllFileds".localized
        static let setRequiredFileds="Set Required Fileds".localized
        static let succeeded="Succeeded".localized
        static let failed="Failed".localized
        static let passwordOk="confirm password dos'nt not match".localized
         static let resetPassword="sent reset to your mail".localized
        static let setRequiredFiledsRealProfile="cant_without_name".localized
        static let setRequiredFiledsProfile="cant_without_username".localized
        
    }
    
    struct Cell  {
        static let ChatCell="ChatCell"
        static let MyChatCell="MyChatCell"
        static let ListCell="ListCell"
        static let MenuCell="MenuCell"
    }
    
    struct Segue {
        static let ChatDescoverySegue="ChatDescoverySegue"
        static let ChatSegue="ChatSegue"
        static let RealProfileSegue="RealProfileSegue"
        static let ChatListContainerSegue="ChatListContainerSegue"
        static let DiscoveryListContainerSegue="DiscoveryListContainerSegue"
    }
    
    struct Font {
        static let fontRegular="OpenSansHebrew-Regular"
        static let fontBold="OpenSansHebrew-Bold"
        static let fontLight="OpenSansHebrew-Light"
    }
    
    struct UI {
        static let ok = "OK".localized
        static let cancel = "Cancel".localized
        static let choosePhoto = "Select a picture".localized
        static let camera = "Camera".localized
        static let photoAlbum = "Photo Album".localized
    }
    
}
