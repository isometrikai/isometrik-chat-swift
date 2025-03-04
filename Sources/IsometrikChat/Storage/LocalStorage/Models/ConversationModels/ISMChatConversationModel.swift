//
//  ISMChatConversationModel.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 25/02/25.
//

import SwiftData
import Foundation


@Model
public class ISMChatConversationDB: Identifiable {
    @Attribute(.unique) public var conversationId: String?
    public var updatedAt: Double
    public var unreadMessagesCount: Int
    public var membersCount: Int
    public var lastMessageSentAt: Int
    public var createdAt: Double
    public var mode: String
    public var conversationTitle: String
    public var conversationImageUrl: String
    public var createdBy: String
    public var createdByUserName: String
    public var privateOneToOne: Bool
    public var messagingDisabled: Bool
    public var isGroup: Bool
    public var typing : Bool = false
    public var userIds : [String] = []
    @Relationship(deleteRule: .cascade) public var opponentDetails : ISMChatUserDB?
    @Relationship(deleteRule: .cascade) public var config : ISMChatConfigDB?
    @Relationship(deleteRule: .cascade) public var lastMessageDetails : ISMChatLastMessageDB?
    public var deletedMessage : Bool = false
    @Relationship(deleteRule: .cascade) public var metaData : ISMChatConversationMetaData?
    public var metaDataJson : String?
    public var lastInputText : String?
    @Relationship(deleteRule: .cascade) public var messages: [ISMChatMessagesDB] = []

    public init(conversationId: String, updatedAt: Double, unreadMessagesCount: Int, membersCount: Int, lastMessageSentAt: Int, createdAt: Double, mode: String, conversationTitle: String, conversationImageUrl: String, createdBy: String, createdByUserName: String, privateOneToOne: Bool, messagingDisabled: Bool, isGroup: Bool, typing: Bool, userIds: [String], opponentDetails: ISMChatUserDB? = nil, config: ISMChatConfigDB? = nil, lastMessageDetails: ISMChatLastMessageDB? = nil, deletedMessage: Bool, metaData: ISMChatConversationMetaData? = nil, metaDataJson: String? = nil, lastInputText: String? = nil) {
        self.conversationId = conversationId
        self.updatedAt = updatedAt
        self.unreadMessagesCount = unreadMessagesCount
        self.membersCount = membersCount
        self.lastMessageSentAt = lastMessageSentAt
        self.createdAt = createdAt
        self.mode = mode
        self.conversationTitle = conversationTitle
        self.conversationImageUrl = conversationImageUrl
        self.createdBy = createdBy
        self.createdByUserName = createdByUserName
        self.privateOneToOne = privateOneToOne
        self.messagingDisabled = messagingDisabled
        self.isGroup = isGroup
        self.typing = typing
        self.userIds = userIds
        self.opponentDetails = opponentDetails
        self.config = config
        self.lastMessageDetails = lastMessageDetails
        self.deletedMessage = deletedMessage
        self.metaData = metaData
        self.metaDataJson = metaDataJson
        self.lastInputText = lastInputText
    }
}

@Model
public class ISMChatUserDB {
    @Attribute(.unique) public var userId: String
    public var userProfileImageUrl : String?
    public var userName : String?
    public var userIdentifier : String?
    public var online : Bool?
    public var lastSeen : Double?
    @Relationship(deleteRule: .cascade) public var metaData : ISMChatUserMetaDataDB?
    
    public init(userId: String, userProfileImageUrl: String? = nil, userName: String? = nil, userIdentifier: String? = nil, online: Bool? = nil, lastSeen: Double? = nil, metaData: ISMChatUserMetaDataDB? = nil) {
        self.userId = userId
        self.userProfileImageUrl = userProfileImageUrl
        self.userName = userName
        self.userIdentifier = userIdentifier
        self.online = online
        self.lastSeen = lastSeen
        self.metaData = metaData
    }
}

@Model
public class ISMChatUserMetaDataDB{
    @Attribute(.unique) public var id: UUID = UUID()
    public var userId : String?
    public var userType : Int? //1 - normal user, 9 -  business user
    public var isStarUser : Bool? //check if usertype == 1 if for both normal user and influencer
    public var userTypeString : String?
    
    public init(userId: String? = nil, userType: Int? = nil, isStarUser: Bool? = nil, userTypeString: String? = nil) {
        self.userId = userId
        self.userType = userType
        self.isStarUser = isStarUser
        self.userTypeString = userTypeString
    }
}


@Model
public class ISMChatConversationMetaData {
    public var chatStatus: String?
    public var membersIds: [String] = []
    
    public init(chatStatus: String? = nil, membersIds: [String]) {
        self.chatStatus = chatStatus
        self.membersIds = membersIds
    }
}


@Model
public class ISMChatConfigDB {
    @Attribute(.unique) public var id: UUID = UUID()
    
    public var typingEvents: Bool?
    public var readEvents: Bool?
    public var pushNotifications: Bool?

    public init(typingEvents: Bool? = nil, readEvents: Bool? = nil, pushNotifications: Bool? = nil) {
        self.typingEvents = typingEvents
        self.readEvents = readEvents
        self.pushNotifications = pushNotifications
    }
}

@Model
public class ISMChatLastMessageDB{
    @Attribute(.unique) public var id: UUID = UUID()
    
    public var sentAt : Double?
    public var updatedAt : Double?
    public var senderName : String?
    public var senderIdentifier : String?
    public var senderId : String?
    public var conversationId : String?
    public var body : String?
    public var messageId : String?
    public var customType : String?
    public var action : String?
    @Relationship(deleteRule: .cascade) public var metaData : ISMChatMetaDataDB?
    public var metaDataJsonString : String?
    @Relationship(deleteRule: .cascade) public var deliveredTo : [ISMChatMessageDeliveryStatusDB]
    @Relationship(deleteRule: .cascade) public var readBy : [ISMChatMessageDeliveryStatusDB]
    public var msgSyncStatus : String = ""
    public var reactionType : String = ""
    public var userId : String = ""
    public var userIdentifier : String?
    public var userName : String?
    public var userProfileImageUrl : String?
    @Relationship(deleteRule: .cascade) public var members : [ISMChatLastMessageMemberDB]
    public var memberName : String = ""
    public var memberId : String = ""
    public var messageDeleted : Bool = false
    public var initiatorName : String?
    public var initiatorId : String?
    public var initiatorIdentifier : String?
    public var deletedMessage : Bool = false
    //callkit
    public var meetingId : String?
    public var missedByMembers : [String]
    @Relationship(deleteRule: .cascade) public var callDurations : [ISMChatMeetingDuration]
    
    public init(sentAt: Double? = nil, updatedAt: Double? = nil, senderName: String? = nil, senderIdentifier: String? = nil, senderId: String? = nil, conversationId: String? = nil, body: String? = nil, messageId: String? = nil, customType: String? = nil, action: String? = nil, metaData: ISMChatMetaDataDB? = nil, metaDataJsonString: String? = nil, deliveredTo: [ISMChatMessageDeliveryStatusDB], readBy: [ISMChatMessageDeliveryStatusDB], msgSyncStatus: String, reactionType: String, userId: String, userIdentifier: String? = nil, userName: String? = nil, userProfileImageUrl: String? = nil, members: [ISMChatLastMessageMemberDB], memberName: String, memberId: String, messageDeleted: Bool, initiatorName: String? = nil, initiatorId: String? = nil, initiatorIdentifier: String? = nil, deletedMessage: Bool, meetingId: String? = nil, missedByMembers: [String], callDurations: [ISMChatMeetingDuration]) {
        self.sentAt = sentAt
        self.updatedAt = updatedAt
        self.senderName = senderName
        self.senderIdentifier = senderIdentifier
        self.senderId = senderId
        self.conversationId = conversationId
        self.body = body
        self.messageId = messageId
        self.customType = customType
        self.action = action
        self.metaData = metaData
        self.metaDataJsonString = metaDataJsonString
        self.deliveredTo = deliveredTo
        self.readBy = readBy
        self.msgSyncStatus = msgSyncStatus
        self.reactionType = reactionType
        self.userId = userId
        self.userIdentifier = userIdentifier
        self.userName = userName
        self.userProfileImageUrl = userProfileImageUrl
        self.members = members
        self.memberName = memberName
        self.memberId = memberId
        self.messageDeleted = messageDeleted
        self.initiatorName = initiatorName
        self.initiatorId = initiatorId
        self.initiatorIdentifier = initiatorIdentifier
        self.deletedMessage = deletedMessage
        self.meetingId = meetingId
        self.missedByMembers = missedByMembers
        self.callDurations = callDurations
    }
}

@Model
public class ISMChatLastMessageMemberDB{
    public var memberProfileImageUrl : String?
    public var memberName : String?
    public var memberIdentifier : String?
    public var memberId : String?
    public init(memberProfileImageUrl: String? = nil, memberName: String? = nil, memberIdentifier: String? = nil, memberId: String? = nil) {
        self.memberProfileImageUrl = memberProfileImageUrl
        self.memberName = memberName
        self.memberIdentifier = memberIdentifier
        self.memberId = memberId
    }
}

@Model
public class ISMChatMeetingDuration{
    public var memberId : String?
    public var durationInMilliseconds : Double?
    public init(memberId: String? = nil, durationInMilliseconds: Double? = nil) {
        self.memberId = memberId
        self.durationInMilliseconds = durationInMilliseconds
    }
}

@Model
public class ISMChatMessageDeliveryStatusDB{
    public var userId : String?
    public var timestamp : Double?
    public init(userId: String? = nil, timestamp: Double? = nil) {
        self.userId = userId
        self.timestamp = timestamp
    }
}
