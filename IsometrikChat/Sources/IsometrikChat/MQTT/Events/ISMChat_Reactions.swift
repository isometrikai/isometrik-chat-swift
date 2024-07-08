//
//  Reactions.swift
//  ISMChatSdk
//
//  Created by Rasika on 19/04/24.
//

import Foundation

public struct ISMChat_Reactions: Codable {
    let sentAt : Double?
    let messageId: String?
    let conversationId : String?
    let userProfileImageUrl : String?
    let userName : String?
    let userIdentifier : String?
    let userId : String?
    let privateOneToOne : Bool?
    let action : String?
    let conversationTitle : String?
    let conversationImageUrl : String?
    let reactionsCount : Int?
    let reactionType : String?
}
