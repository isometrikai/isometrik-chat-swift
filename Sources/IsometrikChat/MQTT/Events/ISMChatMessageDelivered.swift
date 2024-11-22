//
//  MessageDelivered.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 26/04/23.
//

import Foundation

public struct ISMChatMessageDelivered: Codable {
    public let sentAt : Double?
    public let messageId: String?
    public let body : String?
    public let senderIdentifier : String?
    public let senderProfileImageUrl : String?
    public let conversationId : String?
    public let updatedAt : Double?
    public let senderName : String?
    public let senderId : String?
    public let metaData : ISMChatMetaData?
    public let customType : String?
    public let userProfileImageUrl : String?
    public let userName : String?
    public let userIdentifier : String?
    public let userId : String?
    public let privateOneToOne : Bool?
    public var messageIds : [String]? = []
    public let action : String?
    public let attachments : [ISMChatAttachment]?
    public let parentMessageId : String?
    public let senderInfo : ISMChatSenderInfo?
    public let notificationBody : String?
    public let memberName : String?
    public let memberProfileImageUrl : String?
    public let memberIdentifier : String?
    public let memberId : String?
    public let initiatorProfileImageUrl : String?
    public let initiatorName: String?
    public let initiatorIdentifier: String?
    public let initiatorId: String?
    public let conversationTitle : String?
    public let conversationImageUrl : String?
    public let members : [ISMChatMembers]?
    public let details : ISMChatUpdateMessageDetail?
    public let mentionedUsers : [ISMChatMentionedUser]?
    public let reactions : [String : [String]]?
    public let meetingId : String?
}


public struct ISMChatSenderInfo : Codable{
    let userId : String?
    let senderName : String?
}

public struct ISMChatUpdateMessageDetail : Codable{
    public var body : String?
    public var searchableTags : [String]?
    public var customType : String?
    public var metaData : ISMChatMetaData?
}

public struct ISMChatMembers : Codable{
    public var memberProfileImageUrl : String?
    public var memberName : String?
    public var memberIdentifier: String?
    public var memberId : String?
}
