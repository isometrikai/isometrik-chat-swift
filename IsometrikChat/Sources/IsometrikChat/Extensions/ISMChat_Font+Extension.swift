//
//  Font+Extension.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 24/04/23.
//

import Foundation
import UIKit
import SwiftUI

extension UIFont {

    class func regular(size: CGFloat) -> UIFont {
        return UIFont(name: "ProductSans-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    class func medium(size: CGFloat) -> UIFont {
        return UIFont(name: "ProductSans-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }
//
//    class func semibold(size: CGFloat) -> UIFont {
//        return UIFont(name: "HelveticaNeue-SemiBold", size: size)
//    }

    class func bold(size: CGFloat) -> UIFont {
        return UIFont(name: "ProductSans-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
//
//    class func extrabold(size: CGFloat) -> UIFont {
//        return UIFont(name: "HelveticaNeue-ExtraBold", size: size)
//    }

//    class func light(size: CGFloat) -> UIFont {
//        return UIFont(name: "HelveticaNeue-Light", size: size)
//    }
}

//enum FontName : CaseIterable{
//    case regular
//    case medium
//    case bold
//    var name : String{
//        switch self{
//        case .regular:
//            return "HelveticaNeue-Regular"
//        case .medium:
//            return "HelveticaNeue-Medium"
//        case .bold:
//            return "HelveticaNeue-Bold"
//        }
//    }
//}





extension Font {
    static func light(size: CGFloat) -> Font {
        return Font.custom("ProductSans-Light", size: size)
    }

    static func regular(size: CGFloat) -> Font {
        return Font.custom("ProductSans-Regular", size: size)
    }

    static func medium(size: CGFloat) -> Font {
        return Font.custom("ProductSans-Medium", size: size)
    }
    
    static func bold(size: CGFloat) -> Font {
        return Font.custom("ProductSans-Bold", size: size)
    }
    
    static func italic(size: CGFloat) -> Font {
        return Font.custom("ProductSans-Italic", size: size)
    }
}
