//
//  CreateConversation.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 26/04/23.
//

import Foundation

public struct ISMChatCreateConversation: Codable, Hashable {
    public let action: String?
    public let timestamp: Double?
    public let streamId: String?
    public let moderatorsCount: Int?
    public let moderatorName: String?
    public let moderatorProfilePic: String?
    public let moderatorId: String?
    public let initiatorName: String?
    public let initiatorId: String?
    public let moderatorIdentifier: String?
    public let conversationId : String?
}
