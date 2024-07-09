//
//  ISMMediaType.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 03/04/23.
//

import Foundation

public enum ISMChat_MediaType : CaseIterable{
    case Text
    case Image
    case File
    case Video
    case Voice
    case Location
    case sticker
    case gif
    case Contact
    case ReplyText
    case Block
    case Unblock
    case VideoCall
    case AudioCall
    public var value : String{
        switch self {
        case .Text:
            return "AttachmentMessage:Text"
        case .Image:
            return "AttachmentMessage:Image"
        case .File:
            return "AttachmentMessage:File"
        case .Video:
            return "AttachmentMessage:Video"
        case .Voice:
            return "AttachmentMessage:Audio"
        case .Location:
            return "AttachmentMessage:Location"
        case .sticker:
            return "AttachmentMessage:Sticker"
        case .gif:
            return "AttachmentMessage:Gif"
        case .ReplyText:
            return "AttachmentMessage:Reply"
        case .Block:
            return "block"
        case .Unblock:
            return "unblock"
        case .Contact:
            return "AttachmentMessage:Contact"
        case .VideoCall:
            return "VideoCall"
        case .AudioCall:
            return "AudioCall"
        }
    }
}
