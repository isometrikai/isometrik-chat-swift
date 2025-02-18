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
    public let metaDataJson : String?
    public let customType : String?
    public let userProfileImageUrl : String?
    public let userName : String?
    public let userIdentifier : String?
    public let userId : String?
    public let privateOneToOne : Bool?
    public let messageIds : [String]?
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sentAt = try? container.decode(Double.self, forKey: .sentAt)
        messageId = try? container.decode(String.self, forKey: .messageId)
        body = try? container.decode(String.self, forKey: .body)
        senderIdentifier = try? container.decode(String.self, forKey: .senderIdentifier)
        senderProfileImageUrl = try? container.decode(String.self, forKey: .senderProfileImageUrl)
        conversationId = try? container.decode(String.self, forKey: .conversationId)
        updatedAt = try? container.decode(Double.self, forKey: .updatedAt)
        senderName = try? container.decode(String.self, forKey: .senderName)
        senderId = try? container.decode(String.self, forKey: .senderId)
        metaDataJson = {
            if let rawMetaData = try? container.decodeIfPresent(AnyCodable.self, forKey: .metaData) {
                let encoder = JSONEncoder()
                if let rawData = try? encoder.encode(rawMetaData),
                   let jsonString = String(data: rawData, encoding: .utf8) {
                    return jsonString
                }
            }
            return nil
        }()
        metaData = try? container.decodeIfPresent(ISMChatMetaData.self, forKey: .metaData)
        customType = try? container.decode(String.self, forKey: .customType)
        userProfileImageUrl = try? container.decode(String.self, forKey: .userProfileImageUrl)
        userName = try? container.decode(String.self, forKey: .userName)
        userIdentifier = try? container.decode(String.self, forKey: .userIdentifier)
        userId = try? container.decode(String.self, forKey: .userId)
        privateOneToOne = try? container.decode(Bool.self, forKey: .privateOneToOne)
        messageIds = (try? container.decode([String].self, forKey: .messageIds)) ?? []
        action = try? container.decode(String.self, forKey: .action)
        attachments = try? container.decode([ISMChatAttachment].self, forKey: .attachments)
        parentMessageId = try? container.decode(String.self, forKey: .parentMessageId)
        senderInfo = try? container.decode(ISMChatSenderInfo.self, forKey: .senderInfo)
        notificationBody = try? container.decode(String.self, forKey: .notificationBody)
        memberName = try? container.decode(String.self, forKey: .memberName)
        memberProfileImageUrl = try? container.decode(String.self, forKey: .memberProfileImageUrl)
        memberIdentifier = try? container.decode(String.self, forKey: .memberIdentifier)
        memberId = try? container.decode(String.self, forKey: .memberId)
        initiatorProfileImageUrl = try? container.decode(String.self, forKey: .initiatorProfileImageUrl)
        initiatorName = try? container.decode(String.self, forKey: .initiatorName)
        initiatorIdentifier = try? container.decode(String.self, forKey: .initiatorIdentifier)
        initiatorId = try? container.decode(String.self, forKey: .initiatorId)
        conversationTitle = try? container.decode(String.self, forKey: .conversationTitle)
        conversationImageUrl = try? container.decode(String.self, forKey: .conversationImageUrl)
        members = try? container.decode([ISMChatMembers].self, forKey: .members)
        details = try? container.decode(ISMChatUpdateMessageDetail.self, forKey: .details)
        mentionedUsers = try? container.decode([ISMChatMentionedUser].self, forKey: .mentionedUsers)
        reactions = try? container.decode([String: [String]].self, forKey: .reactions)
        meetingId = try? container.decode(String.self, forKey: .meetingId)
    }
    
    init(sentAt: Double? = nil, messageId: String? = nil, body: String? = nil, senderIdentifier: String? = nil, senderProfileImageUrl: String? = nil, conversationId: String? = nil, updatedAt: Double? = nil, senderName: String? = nil, senderId: String? = nil,metaDataJson: String? = nil, metaData: ISMChatMetaData? = nil, customType: String? = nil, userProfileImageUrl: String? = nil, userName: String? = nil, userIdentifier: String? = nil, userId: String? = nil, privateOneToOne: Bool? = nil, messageIds: [String]? = nil, action: String? = nil, attachments: [ISMChatAttachment]? = nil, parentMessageId: String? = nil, senderInfo: ISMChatSenderInfo? = nil, notificationBody: String? = nil, memberName: String? = nil, memberProfileImageUrl: String? = nil, memberIdentifier: String? = nil, memberId: String? = nil, initiatorProfileImageUrl: String? = nil, initiatorName: String? = nil, initiatorIdentifier: String? = nil, initiatorId: String? = nil, conversationTitle: String? = nil, conversationImageUrl: String? = nil, members: [ISMChatMembers]? = nil, details: ISMChatUpdateMessageDetail? = nil, mentionedUsers: [ISMChatMentionedUser]? = nil, reactions: [String : [String]]? = nil, meetingId: String? = nil) {
        self.sentAt = sentAt
        self.messageId = messageId
        self.body = body
        self.senderIdentifier = senderIdentifier
        self.senderProfileImageUrl = senderProfileImageUrl
        self.conversationId = conversationId
        self.updatedAt = updatedAt
        self.senderName = senderName
        self.senderId = senderId
        self.metaDataJson = metaDataJson
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
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try? container.decode(String.self, forKey: .userId)
        senderName = try? container.decode(String.self, forKey: .senderName)
    }
}

public struct ISMChatUpdateMessageDetail : Codable{
    public var body : String?
    public var searchableTags : [String]?
    public var customType : String?
    public var metaData : ISMChatMetaData?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        body = try? container.decode(String.self, forKey: .body)
        searchableTags = try? container.decode([String].self, forKey: .searchableTags)
        customType = try? container.decode(String.self, forKey: .customType)
        metaData = try? container.decode(ISMChatMetaData.self, forKey: .metaData)
    }
}

public struct ISMChatMembers : Codable{
    public var memberProfileImageUrl : String?
    public var memberName : String?
    public var memberIdentifier: String?
    public var memberId : String?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        memberProfileImageUrl = try? container.decode(String.self, forKey: .memberProfileImageUrl)
        memberName = try? container.decode(String.self, forKey: .memberName)
        memberIdentifier = try? container.decode(String.self, forKey: .memberIdentifier)
        memberId = try? container.decode(String.self, forKey: .memberId)
    }
}
