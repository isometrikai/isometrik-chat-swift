//
//  UniqueIdentifierManager.swift
//  Shopr
//
//  Created by Rasika on 30/01/24.
//  Copyright © 2024 Rahul Sharma. All rights reserved.
//

import Foundation
import UIKit

class UniqueIdentifierManager {
    static let shared = UniqueIdentifierManager()
    private let service = "com.appscrip.chatsdk.deviceid"
    private let account = "userDeviceId"
    
    func getUniqueIdentifier() -> String {
        if let identifier = retrieveIdentifierFromKeychain() {
            return identifier
        } else {
            let newIdentifier = generateUniqueIdentifier()
            saveIdentifierToKeychain(identifier: newIdentifier)
            return newIdentifier
        }
    }
    
    private func generateUniqueIdentifier() -> String {
        // Generate a unique identifier using identifierForVendor
        if let vendorIdentifier = UIDevice.current.identifierForVendor?.uuidString {
            return vendorIdentifier
        } else {
            return UUID().uuidString
        }
    }
    
    func saveIdentifierToKeychain(identifier: String) {
        guard let data = identifier.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
     func retrieveIdentifierFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data, let identifier = String(data: data, encoding: .utf8) {
            return identifier
        } else {
            return nil
        }
    }
}
