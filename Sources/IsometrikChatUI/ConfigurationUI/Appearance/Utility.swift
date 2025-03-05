//
//  Untitled.swift
//  IsometrikChat
//
//  Created by My Book on 05/03/25.
//

import Foundation

 public class Utility{
    
    class func getLanguage() -> Language {
        var language = Language([:])
        language.Name = "English"
        language.Code = "en"
        if UserDefaults.standard.string(forKey: "langCode") != nil {
            language.Name = UserDefaults.standard.string(forKey: "langName")!
            language.Code = UserDefaults.standard.string(forKey: "langCode")!
        }
        return language
    }
    
    class func getLocaleIdentifier() -> Locale {
        let langCode = Utility.getLanguage().Code
        var langIdentifier = Locale(identifier: "en_US")
        switch langCode {
        case "pl":
            langIdentifier = Locale(identifier: "pl_PL")
        case "tk":
            langIdentifier = Locale(identifier: "tk_TM")
        case "ru":
            langIdentifier = Locale(identifier: "ru_RU")
        case "am":
            langIdentifier = Locale(identifier: "am_ET")
        default:
            break
        }
        return langIdentifier
    }
    
    struct Language {
        
        var Name = ""
        var Code = ""
        init(_ data:[String:Any]) {
            if let dataFrom = data["langCode"] as? String {
                Code = dataFrom
            }
            if let dataFrom = data["lan_name"] as? String {
                Name = dataFrom
            }
        }
    }
}
