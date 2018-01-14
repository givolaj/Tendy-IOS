
//  SObject.swift
//  Buildi
//
//  Created by Shaya Fredman on 11/1/16.
//  Copyright © 2016 bfmobile. All rights reserved.
//
import UIKit
var projectName="Buildi"

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
extension Array {
    var ElementType: Element.Type {
        return Element.self
    }
    func instanceObject<T: SObject>() -> T? {
        return T()
    }
    
    public func getArrayTypeInstance<T>(_ arr:Array<T>) -> T {
        return arr.getTypeInstance()
    }
    
    public func getTypeInstance<T>() -> T {
        let nsobjectype : NSObject.Type = T.self as! NSObject.Type
        let nsobject: NSObject = nsobjectype.init()
        return nsobject as! T
    }
}

class SObject : NSObject {
    
    func getTypeOfPropertydynamicType(_ name:String)->Any.Type?
    {
        for property in Mirror(reflecting: self).children {
            if property.label == name
            {
                return  type(of: property.value )
            }
        }
        return nil
    }
    
    func getTypeOfPropertyVal(_ name:String)->Any?
    {
        let type: Mirror = Mirror(reflecting:self)
        for child in type.children {
            if child.label == name
            {
                return child.value
            }
        }
        return nil
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject {
        return type(of: self).init()
    }
    
    required  override init() {
        super.init()
    }
    
    init(jsonString:String) {
        super.init()
        jsonToObject(jsonString)
    }
    //=
    init(dic:[String:AnyObject]?) {
        super.init()
        jsonToObject( jsonDictionary: dic)
    }
    //=
    func isJsonVal(_ val:Any)->Bool
    {
        if (val is Bool || val is Int || val is Float || val is String || val is NSArray || val is NSDictionary)
        {
            return true
        }
        return false
    }
    func toJson()->String
    {
    let dictionary = toDict()
    if let theJSONData = try? JSONSerialization.data(
        withJSONObject: dictionary,
        options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .utf8)
            print("JSON string = \(theJSONText!)")
        return theJSONText!
    }
        return ""
    }
    
    func toDict() -> [String:AnyObject] {
        
        var dict = [String:AnyObject]()
        var otherSelf = Mirror(reflecting: self)
        //dict=getMirrorDic(miror: otherSelf)
        //  dict.update(other: getMirrorDic(miror: otherSelf))
        repeat {
            
            dict.update(other: getMirrorDic(miror: otherSelf))
            otherSelf = otherSelf.superclassMirror!
        } while (otherSelf.superclassMirror != nil)
        
        return dict
        
    }
    
    func getMirrorDic(miror:Mirror)-> [String:AnyObject]
    {
        var dict = [String:AnyObject]()
        
        for child in miror.children {
            if let key = child.label {
                dict[key] = child.value as AnyObject
            }
        }
        return dict
    }
    
    func toDictMan() -> [String:AnyObject] {
        var dict = [String:AnyObject]()
        let otherSelf = Mirror(reflecting: self)
        for child in otherSelf.children {
            if let key = child.label {
                dict[key] = child.value as AnyObject
            }
        }
        
        //
        //        let otherSuperSelf = Mirror(reflecting: self.superclass!)
        //       if(otherSuperSelf != nil)
        //        {
        //            return super.toDict()
        //        }
        return dict
    }
    
    func jsonToObject(_ jsonString:String?=nil, jsonDictionary :[String : AnyObject]?=nil)
    {
        let jsonDictionary = (jsonString != nil) ? getJsonObj(jsonString) as? [String : AnyObject] :  jsonDictionary
        
        if(jsonDictionary != nil)
        {
            var obj =  self
            setValue(jsonDictionary! ,obj:&obj )
        }
    }
    
    
    
    func dicToArrayObject(dic:[String:[String : AnyObject]]?=nil)->[SObject]
    {
        
        let jsonArrayDictionary:[[String : AnyObject]]? = (dic != nil ) ? Array(dic!.values) : nil
        return arrDicToArrObj(jsonArrayDictionary: jsonArrayDictionary)
    }
    
    func jsonToArrayObject(_ jsonString:String?=nil,jsonArrayDictionary:[[String : AnyObject]]?=nil)->[SObject]
    {
        
        let jsonArrayDictionary = (jsonString != nil) ? getJsonObj(jsonString) as? [[String : AnyObject]] :  jsonArrayDictionary
        
        return arrDicToArrObj(jsonArrayDictionary: jsonArrayDictionary)
        
    }
    
    private func arrDicToArrObj(jsonArrayDictionary:[[String : AnyObject]]?=nil)->[SObject]
    {
        var arr=[SObject]()
        if(jsonArrayDictionary != nil)
        {
            for dic in jsonArrayDictionary!
            {
                var obj =  self.copy()as! SObject
                setValue(dic, obj: &obj)
                arr.append(obj)
            }
        }
        return arr
    }
    
    private func getJsonObj(_ jsonString:String?=nil)->Any?
    {
        var jsonObj:Any?
        if(jsonString != nil)
        {
            let data = jsonString!.data(using: String.Encoding.utf8)
            do {
                jsonObj  =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)}
            catch
            {
            }
            
        }
        return jsonObj
    }
    
    func setValue(_ jsonDictionary:[String:AnyObject],obj:inout SObject)
    {
        for keyValue in jsonDictionary {
            let keyName = keyValue.0 as String
            if (obj.responds(to: NSSelectorFromString(keyName))) {
                
                let  value:AnyObject? = getValue(keyName :keyName, keyValue: keyValue.1 as AnyObject)
                obj.setValue(value , forKey: keyName)
            }
        }
        
    }
    
    private func getValue(keyName:String , keyValue:AnyObject)->AnyObject?
    {
        let anyobjectype : Any.Type? = self.getTypeOfPropertydynamicType(keyName)
        var  value:AnyObject?=keyValue
        if(value!.description=="<null>") {
            value=nil
        }
        else
            if(anyobjectype is SObject.Type)
            {
                value = valueSObject(anyobjectype: anyobjectype, keyValue: keyValue)
            }
            else
            {
                value=valueArrSObject(keyName: keyName, keyValue: keyValue)
                
        }
        return value
    }
    
    private func  valueArrSObject(keyName : String,keyValue:AnyObject?)->AnyObject?
    {
        var value=keyValue
        if let array = getTypeOfPropertyVal(keyName)  as? NSArray as? [SObject]{
            if(array.count>0)
            {
                value = (type(of: array[0])).init().jsonToArrayObject(jsonArrayDictionary:keyValue as? [[String : AnyObject]]) as AnyObject?
                
            }
        }
        return value
    }
    
    private func  valueSObject(anyobjectype : Any.Type?,keyValue:AnyObject)->SObject
    {
        let value = (anyobjectype as! SObject.Type).init()
        (keyValue is [String : AnyObject]) ? value.jsonToObject(jsonDictionary: keyValue as? [String : AnyObject]) :  value.jsonToObject(keyValue.description)
        return value
    }
}

