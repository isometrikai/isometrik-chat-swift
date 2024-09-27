//
//  ISMSearchTags.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 07/11/23.
//

import Foundation

enum ISMChatSearchTags : CaseIterable{
    case text
    case photo
    case video
    case audio
    case file
    case location
    case contact
    case sticker
    case gif
    case whiteboard
    case forward
    case post
    case product
    var value : String{
        switch self {
        case .text:
            return "/@text"
        case .photo:
            return "/@photo"
        case .video:
            return "/@video"
        case .audio:
            return "/@audio"
        case .file:
            return "/@file"
        case .location:
            return "/@location"
        case .contact:
            return "/@contact"
        case .sticker:
            return "/@sticker"
        case .gif:
            return "/@gif"
        case .whiteboard:
            return "/@whiteboard"
        case .forward:
            return "/@forward"
        case .post:
            return "/@post"
        case .product:
            return "/@product"
        }
    }
}
