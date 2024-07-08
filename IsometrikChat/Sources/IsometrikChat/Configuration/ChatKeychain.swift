//
//  ChatKeychain.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 22/02/23.
//

import Foundation
import KeychainAccess
import UIKit

class ChatKeychain {
    
    let keychain = Keychain(service: "com.ISMChatSdk.app")
    
    static var shared: ChatKeychain = {
        let instance = ChatKeychain()
        return instance
    }()
    
    var deviceToken : String? {
        set {
            keychain["deviceToken"] = newValue
        }
               
        get {
            return keychain["deviceToken"]
        }
    }
    
    
    var authToken : String? {
        set {
            keychain["authToken"] = newValue
        }
        
        get {
            return keychain["authToken"]
        }
    }
  
    var userEmailAddress : String? {
        set {
            keychain["email"] = newValue
        }
        
        get {
            return keychain["email"]
        }
    }
    
    var userAbout : String? {
        set {
            keychain["about"] = newValue
        }
        
        get {
            return keychain["about"]
        }
    }
    
    var userId : String? {
        set {
            keychain["userId"] = newValue
        }
        
        get {
            return keychain["userId"]
        }
    }
    
    var userName : String? {
        set {
            keychain["userName"] = newValue
        }
        
        get {
            return keychain["userName"]
        }
    }
    
    var userProfile : String? {
        set {
            keychain["userProfile"] = newValue
        }
        
        get {
            return keychain["userProfile"]
        }
    }
    
    var notificationsOn : Bool? {
        
        set {
            if let val = newValue {
                keychain["notificationsOn"] = String(val)
            } else {
                keychain["notificationsOn"] = nil
            }
        }
        
        get {
            if let strVal = keychain["notificationsOn"] {
                return Bool(strVal)
            } else {
                return nil
            }
        }
    }
    
    func save(authorizationResponse : LoginData) {
        clear()
        userId = authorizationResponse.userId
        authToken = authorizationResponse.userToken
    }
    
    func clear() {
        keychain["authToken"] = nil
        keychain["deviceToken"] = nil
        keychain["email"] = nil
        keychain["userId"] = nil
        keychain["userName"] = nil
        keychain["userProfile"] = nil
        keychain["about"] = nil
    }
}

struct LoginData : Codable{
    var userToken : String?
    var userId : String?
    var msg : String?
}
