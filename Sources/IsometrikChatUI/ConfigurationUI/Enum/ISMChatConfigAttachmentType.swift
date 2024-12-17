//
//  ISMChatAttachmentType.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 17/11/23.
//

import Foundation


public enum ISMChatConfigAttachmentType{
    case camera
    case gallery
    case contact
    case sticker
    case document
    case location
    
    public var name: String {
        switch self {
        case .camera:
            return "Camera"
        case .gallery:
            return "Gallery"
        case .document:
            return "Document"
        case .location:
            return "Location"
        case .contact:
            return "Contact"
        case .sticker:
            return "Sticker"
        }
    }
}
