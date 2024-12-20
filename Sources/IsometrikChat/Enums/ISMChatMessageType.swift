//
//  ISMMessageType.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 03/04/23.
//

import Foundation

public enum ISMChatMessageType {
    case text
    /// A message with attributed text.
    case attributedText
    /// A photo message.
    case photo
    /// A video message.
    case video
    /// A location message.
    case location
    /// An emoji message.
    case emoji
    /// An audio message.
    case audio
    /// A contact message.
    case contact
    /// A link preview message.
    case linkPreview
    /// An document message.
    case document
    
    case gif
    case sticker
    
    case blockUser
    
    case unblockUser
    
    case conversationTitleUpdate
    // only for grp
    case conversationImageUpdated
    
    case conversationCreated
    case membersAdd   // added by admin
    case memberLeave // remove by self
    case membersRemove //remove by admin
    
    case addAdmin
    case removeAdmin
    case conversationSettingsUpdated
    
    case VideoCall
    case AudioCall
    case GroupCall
    
    case reaction
    
    case post
    case Product
    case ProductLink
    case SocialLink
    case CollectionLink
    case paymentRequest
}
