//
//  ISMChatConversationTypeConfig.swift
//  ISMChatSdk
//
//  Created by Rasika on 27/06/24.
//

import Foundation

public enum ISMChatConversationTypeConfig{
    case OneToOneConversation
    case GroupConversation
    case BroadCastConversation
    public var name: String {
        switch self {
        case .OneToOneConversation:
            return "One to One Conversation"
        case .GroupConversation:
            return "Group Conversation"
        case .BroadCastConversation:
            return "BroadCast"
        }
    }
}
