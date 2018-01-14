//
//  ChatPartners.swift
//  Tendy
//
//  Created by ATN on 03/08/2017.
//  Copyright © 2017 ATN. All rights reserved.
//

import UIKit

enum State:String
{
    case haveInvited="haveInvited"
    case invited="invited"
    case connected="connected"
    case forever="forever"
    case blocked="blocked"
}

let CHAT_VALIDITY_INTERVAL:Double = 2 * 60 * 60 * 1000//שעתיים
//let CHAT_VALIDITY_INTERVAL:Double = 3 * 60 * 1000//3 דקות

class ChatPartners: SObject {
    var dateAdded:String=String()
    var lastVisited:UInt64=UInt64()
    var partner:String=String()
    var realProfile:Bool=false
    var status:String=String()
    var profile:Profile!
    {
        return Profile(jsonString: self.partner)
    }
}
