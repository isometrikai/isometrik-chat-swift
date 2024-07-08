//
//  UserBlockAndUnblock.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 03/07/23.
//

import Foundation

struct ISMChat_UserBlockAndUnblock : Codable{
    var sentAt : Double?
    var privateOneToOne : Bool?
    var opponentProfileImageUrl : String?
    var opponentName : String?
    var opponentIdentifier : String?
    var opponentId : String?
    var messagingDisabled : Bool?
    var initiatorProfileImageUrl : String?
    var initiatorName : String?
    var initiatorIdentifier : String?
    var initiatorId : String?
    var conversationTitle : String?
    var conversationImageUrl : String?
    var conversationId : String?
    var action : String?
    var messageId : String?
    var userIdentifier : String?
}
