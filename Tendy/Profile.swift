//
//  Profile.swift
//  Tendy
//
//  Created by ATN on 03/08/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit

enum DeviceTypeEnum:String
{
    case iphone="iphone"
    case android="android"
}

class Profile: SObject {
    var username:String=String()
    var age:String=String()
    var profession:String=String()
    var something:String=String()
    var gender:String=String()
    var imageUrl:String=String()
    var lastEntry:String=String()
    var identifier:String=String()
    var pushToken:String=String()
    var deviceType:String = DeviceTypeEnum.android.rawValue
    
   // var discoveredDate:Date!
}

class RealProfile:Profile{}
