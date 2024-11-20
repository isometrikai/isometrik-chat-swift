//
//  Color+Extension.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 20/03/23.
//

import Foundation
import SwiftUI

extension Color {
    
    struct Primary {
       
        static let gradientColor = Color(hex: "F3FEFF")
    }
    
    init?(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
        guard red >= 0 && red <= 255 else { return nil }
        guard green >= 0 && green <= 255 else { return nil }
        guard blue >= 0 && blue <= 255 else { return nil }
        
        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0)
    }
    
    init?(hex: String, transparency: CGFloat = 1) {
        var string = ""
        if hex.lowercased().hasPrefix("0x") {
            string =  hex.replacingOccurrences(of: "0x", with: "")
        } else if hex.hasPrefix("#") {
            string = hex.replacingOccurrences(of: "#", with: "")
        } else {
            string = hex
        }
        
        if string.count == 3 { // convert hex to 6 digit format if in short format
            var str = ""
            string.forEach { str.append(String(repeating: String($0), count: 2)) }
            string = str
        }
        
        guard let hexValue = Int(string, radix: 16) else { return nil }
        
        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }
        
        let red = (hexValue >> 16) & 0xff
        let green = (hexValue >> 8) & 0xff
        let blue = hexValue & 0xff
        self.init(red: red, green: green, blue: blue, transparency: trans)
    }
    
}



extension Color {
    //Login
    static public let onboardingPlaceholder = Color(hex: "#9EA4C3")
//    static public let black = Color.black
    static public let forgotpassword = Color(hex: "#294566")
    static public let border = Color(hex: "#DBDBDB")
    
    static public let login1 = Color(hex: "#A399F7")
    static public let login2 = Color(hex: "#7062E9")
    static public let redMessageCount = Color(hex: "#F15C46")
    static public let backgroundView = Color(hex: "#F3F6FB")
    static public let bluetype = Color(hex: "#00A2F3")
    static public let blue1 = Color(hex: "#007AFF")
    static public let header = Color(hex: "#E2E9F4")
    static public let listBackground = Color(hex: "#E8EFF9")
    static public let docBackground = Color(hex: "#E8EFF9")
    static public let primarypurple = Color(hex: "#7062E9")
    static public let audiobar = Color(hex: "#CBE3FF")
    static public let redType = Color(hex: "#DD3719")
}

extension Color {
    public init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}
