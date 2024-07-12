//
//  TypingEvent.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 26/04/23.
//

import Foundation

public struct ISMChatTypingEvent: Codable, Hashable {
    public let action : String?
    public let sentAt : Double?
    public let userId : String?
    public let conversationId : String?
    public let userName : String?
}
