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
    init(sentAt: Double? = nil, messageId: String? = nil, body: String? = nil, senderIdentifier: String? = nil, senderProfileImageUrl: String? = nil, conversationId: String? = nil, updatedAt: Double? = nil, senderName: String? = nil, senderId: String? = nil, metaData: ISMChatMetaData? = nil, customType: String? = nil, userProfileImageUrl: String? = nil, userName: String? = nil, userIdentifier: String? = nil, userId: String? = nil, privateOneToOne: Bool? = nil, messageIds: [String]? = nil, action: String? = nil, attachments: [ISMChatAttachment]? = nil, parentMessageId: String? = nil, senderInfo: ISMChatSenderInfo? = nil, notificationBody: String? = nil, memberName: String? = nil, memberProfileImageUrl: String? = nil, memberIdentifier: String? = nil, memberId: String? = nil, initiatorProfileImageUrl: String? = nil, initiatorName: String? = nil, initiatorIdentifier: String? = nil, initiatorId: String? = nil, conversationTitle: String? = nil, conversationImageUrl: String? = nil, members: [ISMChatMembers]? = nil, details: ISMChatUpdateMessageDetail? = nil, mentionedUsers: [ISMChatMentionedUser]? = nil, reactions: [String : [String]]? = nil, meetingId: String? = nil) {
        self.sentAt = sentAt
        self.messageId = messageId
        self.body = body
        self.senderIdentifier = senderIdentifier
        self.senderProfileImageUrl = senderProfileImageUrl
        self.conversationId = conversationId
        self.updatedAt = updatedAt
        self.senderName = senderName
        self.senderId = senderId
        self.metaData = metaData
        self.customType = customType
        self.userProfileImageUrl = userProfileImageUrl
        self.userName = userName
        self.userIdentifier = userIdentifier
        self.userId = userId
        self.privateOneToOne = privateOneToOne
        self.messageIds = messageIds
        self.action = action
        self.attachments = attachments
        self.parentMessageId = parentMessageId
        self.senderInfo = senderInfo
        self.notificationBody = notificationBody
        self.memberName = memberName
        self.memberProfileImageUrl = memberProfileImageUrl
        self.memberIdentifier = memberIdentifier
        self.memberId = memberId
        self.initiatorProfileImageUrl = initiatorProfileImageUrl
        self.initiatorName = initiatorName
        self.initiatorIdentifier = initiatorIdentifier
        self.initiatorId = initiatorId
        self.conversationTitle = conversationTitle
        self.conversationImageUrl = conversationImageUrl
        self.members = members
        self.details = details
        self.mentionedUsers = mentionedUsers
        self.reactions = reactions
        self.meetingId = meetingId
    }
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
