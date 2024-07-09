//
//  Reactions.swift
//  ISMChatSdk
//
//  Created by Rasika on 19/04/24.
//

import Foundation

public struct ISMChat_Reactions: Codable {
    public let sentAt : Double?
    public let messageId: String?
    public let conversationId : String?
    public let userProfileImageUrl : String?
    public let userName : String?
    public let userIdentifier : String?
    public let userId : String?
    public let privateOneToOne : Bool?
    public let action : String?
    public let conversationTitle : String?
    public let conversationImageUrl : String?
    public let reactionsCount : Int?
    public let reactionType : String?
}
