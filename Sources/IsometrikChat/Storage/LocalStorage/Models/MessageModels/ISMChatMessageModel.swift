//
//  ISMChatMessageModel.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 26/02/25.
//

import SwiftData
import Foundation

@Model
public class ISMChatMessagesDB {
    @Attribute(.unique) public var id: UUID = UUID()
   public var messageId: String = ""
    
    public var sentAt : Double = 0
    @Relationship(deleteRule: .cascade) public var senderInfo : ISMChatUserDB?
    public var body : String = ""
    public var userName : String = ""
    public var userIdentifier : String = ""
    public var userId : String = ""
    public var userProfileImageUrl : String = ""
    @Relationship(deleteRule: .cascade) public var mentionedUsers : [ISMChatMentionedUserDB]
    public var deliveredToAll : Bool = false
    public var readByAll : Bool = false
    public var customType : String = ""
    public var action : String = ""
    @Relationship(deleteRule: .cascade) public var readBy : [ISMChatMessageDeliveryStatusDB]
    @Relationship(deleteRule: .cascade) public var deliveredTo  : [ISMChatMessageDeliveryStatusDB]
    public var messageType : Int = -1
    public var parentMessageId : String = ""
    @Relationship(deleteRule: .cascade) public var metaData : ISMChatMetaDataDB?
    public var metaDataJsonString : String?
    @Relationship(deleteRule: .cascade) public var attachments : [ISMChatAttachmentDB]
    public var initiatorIdentifier : String = ""
    public var initiatorId : String = ""
    public var initiatorName : String = ""
    public var conversationId : String = ""
    public var msgSyncStatus : String = ""
    public var placeName : String = ""
    public var reactionType : String = ""
    public var reactionsCount : Int?
    @Relationship(deleteRule: .cascade) public var members : [ISMChatLastMessageMemberDB]
    public var deletedMessage : Bool = false
    public var memberName : String = ""
    public var memberId : String = ""
    public var memberIdentifier : String = ""
    public var messageUpdated : Bool = false
    @Relationship(deleteRule: .cascade) public var reactions : [ISMChatReactionDB]
    public var missedByMembers : [String]
    public var meetingId  : String?
    @Relationship(deleteRule: .cascade) public var callDurations : [ISMChatMeetingDuration]
    public var audioOnly : Bool = false
    public var autoTerminate : Bool = false
    @Relationship(deleteRule: .cascade) public var config : ISMChatMeetingConfig?
    public var groupcastId : String?
    @Relationship(deleteRule: .nullify) public var conversation: ISMChatConversationDB?
    public init(messageId: String, sentAt: Double, senderInfo: ISMChatUserDB, body: String, userName: String, userIdentifier: String, userId: String, userProfileImageUrl: String, mentionedUsers: [ISMChatMentionedUserDB], deliveredToAll: Bool, readByAll: Bool, customType: String, action: String, readBy: [ISMChatMessageDeliveryStatusDB], deliveredTo: [ISMChatMessageDeliveryStatusDB], messageType: Int, parentMessageId: String, metaData: ISMChatMetaDataDB? = nil, metaDataJsonString: String? = nil, attachments: [ISMChatAttachmentDB], initiatorIdentifier: String, initiatorId: String, initiatorName: String, conversationId: String, msgSyncStatus: String, placeName: String, reactionType: String, reactionsCount: Int? = nil, members: [ISMChatLastMessageMemberDB], deletedMessage: Bool, memberName: String, memberId: String, memberIdentifier: String, messageUpdated: Bool, reactions: [ISMChatReactionDB], missedByMembers: [String], meetingId: String? = nil, callDurations: [ISMChatMeetingDuration], audioOnly: Bool, autoTerminate: Bool, config: ISMChatMeetingConfig? = nil, groupcastId: String? = nil) {
        self.messageId = messageId
        self.sentAt = sentAt
        self.senderInfo = senderInfo
        self.body = body
        self.userName = userName
        self.userIdentifier = userIdentifier
        self.userId = userId
        self.userProfileImageUrl = userProfileImageUrl
        self.mentionedUsers = mentionedUsers
        self.deliveredToAll = deliveredToAll
        self.readByAll = readByAll
        self.customType = customType
        self.action = action
        self.readBy = readBy
        self.deliveredTo = deliveredTo
        self.messageType = messageType
        self.parentMessageId = parentMessageId
        self.metaData = metaData
        self.metaDataJsonString = metaDataJsonString
        self.attachments = attachments
        self.initiatorIdentifier = initiatorIdentifier
        self.initiatorId = initiatorId
        self.initiatorName = initiatorName
        self.conversationId = conversationId
        self.msgSyncStatus = msgSyncStatus
        self.placeName = placeName
        self.reactionType = reactionType
        self.reactionsCount = reactionsCount
        self.members = members
        self.deletedMessage = deletedMessage
        self.memberName = memberName
        self.memberId = memberId
        self.memberIdentifier = memberIdentifier
        self.messageUpdated = messageUpdated
        self.reactions = reactions
        self.missedByMembers = missedByMembers
        self.meetingId = meetingId
        self.callDurations = callDurations
        self.audioOnly = audioOnly
        self.autoTerminate = autoTerminate
        self.config = config
        self.groupcastId = groupcastId
    }
}

@Model
public class ISMChatReactionDB{
    @Attribute(.unique) public var id: UUID = UUID()
    public var reactionType: String = ""
    public var users: [String]
    public init(reactionType: String, users: [String]) {
        self.reactionType = reactionType
        self.users = users
    }
}

@Model
public class ISMChatMentionedUserDB{
    public var wordCount : Int?
    public var userId : String?
    public var order : Int?
    public init(wordCount: Int? = nil, userId: String? = nil, order: Int? = nil) {
        self.wordCount = wordCount
        self.userId = userId
        self.order = order
    }
}

@Model
public class ISMChatMeetingConfig {
    public var pushNotifications: Bool?
    public init(pushNotifications: Bool? = nil) {
        self.pushNotifications = pushNotifications
    }
}
