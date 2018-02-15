//
//  PhoneFormatterKit.swift
//  app
//
//  Created by Erez on 09/07/2017.
//  Copyright © 2017 Drupe. All rights reserved.
//

import Foundation
import PhoneNumberKit




public class PhoneFormatterKit {

    //MARK: singleton
    
    private let m_phoneNumberKit = PhoneNumberKit()
    private let m_region: String
    
    public static let shared: PhoneFormatterKit = {
        let instance = PhoneFormatterKit()
        
        return instance
    }()
    
    
    
    init() {
        
        m_region = PhoneNumberKit.defaultRegionCode()
        
//        m_region = "GB"//"GB"//"IL"
    }
    
    
    
    func formatE164(_ number: String) -> String
    {
        
        var phoneNumber = number
        do {
            let phoneNumberObj = try m_phoneNumberKit.parse(number, ignoreType: true)
            let e164Format = m_phoneNumberKit.format(phoneNumberObj, toType: .e164)
            phoneNumber = e164Format
            print("phoneNumber2")
        }
        catch let e{
            print("formatE164 - Generic parser error \(number), \(e)")
        }
        return phoneNumber
    }
    
    
    
    func formatLocal(_ number: String) -> String
    {
        var phoneNumber = number
        do {
            let phoneNumberObj = try m_phoneNumberKit.parse(number, ignoreType: true)
            let localFormat = m_phoneNumberKit.format(phoneNumberObj, toType: .national)
            phoneNumber = localFormat
            
        }
        catch let e{
            print("formatLocal - Generic parser error \(number), \(e)")
        }
        return phoneNumber
    }
    

    func isPhoneNumber(_ number: String) -> Bool
    {
        print("isPhoneNumber")

        var isPhoneNumber = true
        do {
            _ = try m_phoneNumberKit.parse(number, ignoreType: false)

            isPhoneNumber = true
        }
        catch {
            print("\(number) is NOT a phone number")
            isPhoneNumber = false
        }
        return isPhoneNumber
    }
    
    
    
    func formatObject(_ number: String) -> PhoneNumber?
    {
        
        var phoneNumberObj:PhoneNumber? = nil
        do {
            phoneNumberObj = try m_phoneNumberKit.parse(number, ignoreType: true)
        }
        catch let e{
            print("formatObject - Generic parser error \(number), \(e)")
        }
        return phoneNumberObj
    }
}
