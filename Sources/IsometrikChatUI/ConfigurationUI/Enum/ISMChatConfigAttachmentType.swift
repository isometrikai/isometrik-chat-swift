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
    case document
    case location
    case contact
    case sticker
    
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
