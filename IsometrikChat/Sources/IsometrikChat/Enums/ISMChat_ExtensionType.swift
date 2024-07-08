//
//  ISMExtensionType.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 10/05/23.
//

import Foundation

public enum ISMChat_ExtensionType : CaseIterable{
    case Image
    case Video
    case Audio
    case Document
    var type : String{
        switch self {
        case .Image:
            return "png"
        case .Video:
            return "mp4"
        case .Audio:
            return "m4a"
        case .Document:
            return "pdf"
        }
    }
}
