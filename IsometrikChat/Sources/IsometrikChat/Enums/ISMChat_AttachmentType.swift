//
//  ISMAttachmentType.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 10/05/23.
//

import Foundation

public enum ISMChat_AttachmentType : CaseIterable{
    case Image
    case Video
    case Audio
    case Document
    case Location
    case Sticker
    case Gif
    case AdminMessage
    public var type : Int{
        switch self {
        case .Image:
            return 0
        case .Video:
            return 1
        case .Audio:
            return 2
        case .Document:
            return 3
        case .Location:
            return 4
        case .Sticker:
            return 5
        case .Gif:
            return 6
        case .AdminMessage:
            return 7
        }
    }
}
