//
//  ISMChatString+Extension.swift
//  IsometrikChat
//
//  Created by My Book on 31/01/25.
//
import SwiftUI
extension String {
    
    public func localized() -> String {
        
        if let bundlePath = Bundle.module.path(forResource: "Localizable", ofType: "strings", inDirectory: nil) {
            print("Localization file found at: \(bundlePath)")
            let url = URL(fileURLWithPath: bundlePath)
            if let content = try? String(contentsOf: url) {
                print("Localization file content:\n\(content)")
                let dict = parseLocalizableStrings(content: content)
                return dict[self] ?? self
            } else {
                print("Could not read localization file.")
                return self
            }
        } else {
            print("Localization file NOT found!")
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
