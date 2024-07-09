//
//  UserBlockAndUnblock.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 03/07/23.
//

import Foundation

public struct ISMChat_UserBlockAndUnblock : Codable{
    public var sentAt : Double?
    public var privateOneToOne : Bool?
    public var opponentProfileImageUrl : String?
    public var opponentName : String?
    public var opponentIdentifier : String?
    public var opponentId : String?
    public var messagingDisabled : Bool?
    public var initiatorProfileImageUrl : String?
    public var initiatorName : String?
    public var initiatorIdentifier : String?
    public var initiatorId : String?
    public var conversationTitle : String?
    public var conversationImageUrl : String?
    public var conversationId : String?
    public var action : String?
    public var messageId : String?
    public var userIdentifier : String?
}
