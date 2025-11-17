//
//  ISMChatString+Extension.swift
//  IsometrikChat
//
//  Created by My Book on 31/01/25.
//
import Foundation
import UIKit
import SwiftUI
extension String {
    
    func localized() -> String {
        let language = Utility.getLanguage().Code
//        let language = ISMChatSdkUI.getInstance().preferredLanguage
        guard let bundlePath = Bundle.module.path(forResource: language, ofType: "lproj"),
              let localizationFilePath = Bundle(path: bundlePath)?.path(forResource: "Localizable", ofType: "strings") else {
            print("Localization file NOT found!")
            return self
        }
        
//        print("Localization file found at: \(localizationFilePath)")
        
        do {
            let content = try String(contentsOfFile: localizationFilePath, encoding: .utf8)
//            print("Localization file content:\n\(content)")
            let dict = parseLocalizableStrings(content: content)
            return dict[self] ?? self
        } catch {
            print("Could not read localization file: \(error)")
            return self
        }
    }

    
    func parseLocalizableStrings(content: String) -> [String: String] {
        var localizedDict = [String: String]()
        
        let lines = content.split(separator: "\n")
        let regexPattern = #"\"(.+?)\"\s*=\s*\"(.+?)\";"#
        
        let regex = try? NSRegularExpression(pattern: regexPattern, options: [])
        
        for line in lines {
            if let match = regex?.firstMatch(in: String(line), options: [], range: NSRange(location: 0, length: line.utf16.count)) {
                let keyRange = Range(match.range(at: 1), in: line)!
                let valueRange = Range(match.range(at: 2), in: line)!
                
                let key = String(line[keyRange])
                let value = String(line[valueRange])
                
                localizedDict[key] = value
            }
        }
        
        return localizedDict
    }
}

extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
