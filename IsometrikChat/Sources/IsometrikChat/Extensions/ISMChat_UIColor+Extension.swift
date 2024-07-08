//
//  UIColor+Extension.swift
//  ISMChatSdk
//
//  Created by Dheeraj Kumar Sharma on 16/10/23.
//

import UIKit
import SwiftUI

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(
            red: r / 255,
            green: g / 255,
            blue: b / 255,
            alpha: 1
        )
    }

    convenience init(red: Int, green: Int, blue: Int) {
        self.init(
            r: CGFloat(red),
            g: CGFloat(green),
            b: CGFloat(blue)
        )
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xff,
            green: (rgb >> 8) & 0xff,
            blue: rgb & 0xff
        )
    }
}


extension UIColor {
    convenience init(_ color: Color) {
        let components = color.cgColor?.components
        let r = components?[0] ?? 0
        let g = components?[1] ?? 0
        let b = components?[2] ?? 0
        let a = color.cgColor?.alpha ?? 1.0
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
