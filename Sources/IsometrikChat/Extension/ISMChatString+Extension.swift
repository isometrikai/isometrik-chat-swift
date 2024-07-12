//
//  String.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 03/03/23.
//

import Foundation
import UIKit

extension String {
    public func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating public func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    public func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}
extension String {
    public var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}


extension String{
    public func getContactJson() -> [[String : AnyHashable]]?{
        if let data = self.data(using: .utf8) {
            do {
                // Parse the JSON data
                let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: AnyHashable]]
                
                if let jsonArray = jsonArray {
                    return jsonArray
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        return nil
    }
}
