//
//  ISMConversation.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 09/03/23.
//

import Foundation
import ISMSwiftCall

public struct ISMChatConversations : Codable{
    public var msg : String?
    public var conversations : [ISMChatConversationsDetail]?
    public var groupcasts : [ISMChatBroadCastDetail]?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msg = try? container.decode(String.self, forKey: .msg)
        conversations = try? container.decode([ISMChatConversationsDetail].self, forKey: .conversations)
        groupcasts = try? container.decode([ISMChatBroadCastDetail].self, forKey: .groupcasts)
    }
}

public struct ISMChatBroadCastDetail : Identifiable, Codable{
    public var id : String {groupcastId ?? ""}
    public var membersCount : Int?
    public var groupcastTitle : String?
    public var groupcastImageUrl : String?
    public var groupcastId : String?
    public var customType : String?
    public var createdBy : String?
    public var createdAt : Double?
    public var metaData : ISMChatBroadMetadata?
    public var updatedAt : Int?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        membersCount = try? container.decodeIfPresent(Int.self, forKey: .membersCount)
        groupcastTitle = try? container.decodeIfPresent(String.self, forKey: .groupcastTitle)
        groupcastImageUrl = try? container.decodeIfPresent(String.self, forKey: .groupcastImageUrl)
        groupcastId = try? container.decodeIfPresent(String.self, forKey: .groupcastId)
        customType = try? container.decodeIfPresent(String.self, forKey: .customType)
        createdBy = try? container.decodeIfPresent(String.self, forKey: .createdBy)
        createdAt = try? container.decodeIfPresent(Double.self, forKey: .createdAt)
        metaData = try? container.decodeIfPresent(ISMChatBroadMetadata.self, forKey: .metaData)
        updatedAt = try? container.decodeIfPresent(Int.self, forKey: .updatedAt)
    }
}

public struct ISMChatBroadMetadata : Codable{
    public var membersDetail : [ISMChatBroadCastMemberDetail] = []
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        membersDetail = try! container.decodeIfPresent([ISMChatBroadCastMemberDetail].self, forKey: .membersDetail) ?? []
    }
}

public struct ISMChatBroadCastMemberDetail: Identifiable,Codable{
    public var id = UUID()
    public var memberId : String?
    public var memberName : String?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        memberId = try? container.decodeIfPresent(String.self, forKey: .memberId)
        memberName = try? container.decodeIfPresent(String.self, forKey: .memberName)
    }
}

public struct ISMChatConversationsDetail : Identifiable, Codable{
    public var id : String {opponentDetails?.userId ?? ""}
    public var opponentDetails : ISMChatUser?
    public var lastMessageDetails : ISMChatLastMessage?
    public var unreadMessagesCount : Int?
    public var typing : Bool?
    public var customType : String?
    public var isGroup : Bool?
    public var membersCount : Int?
    public var lastMessageSentAt : Int?
    public var createdAt : Double?
    public var conversationTitle : String?
    public var conversationImageUrl : String?
    public var createdBy : String?
    public var createdByUserName : String?
    public var privateOneToOne : Bool?
    public var conversationId : String?
    public var members : [ISMChatGroupMember]?
    public var config : ISMChatConfigConversation?
    public var metaData : ISMChatUserMetaData?
    public var metaDataJson : String?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        opponentDetails = try? container.decodeIfPresent(ISMChatUser.self, forKey: .opponentDetails)
        lastMessageDetails = try? container.decodeIfPresent(ISMChatLastMessage.self, forKey: .lastMessageDetails)
        unreadMessagesCount = try? container.decodeIfPresent(Int.self, forKey: .unreadMessagesCount)
        typing = try? container.decodeIfPresent(Bool.self, forKey: .typing)
        customType = try? container.decodeIfPresent(String.self, forKey: .customType)
        isGroup = try? container.decodeIfPresent(Bool.self, forKey: .isGroup)
        membersCount = try? container.decodeIfPresent(Int.self, forKey: .membersCount)
        lastMessageSentAt = try? container.decodeIfPresent(Int.self, forKey: .lastMessageSentAt)
        createdAt = try? container.decodeIfPresent(Double.self, forKey: .createdAt)
        conversationTitle = try? container.decodeIfPresent(String.self, forKey: .conversationTitle)
        conversationImageUrl = try? container.decodeIfPresent(String.self, forKey: .conversationImageUrl)
        createdBy = try? container.decodeIfPresent(String.self, forKey: .createdBy)
        createdByUserName = try? container.decodeIfPresent(String.self, forKey: .createdByUserName)
        privateOneToOne = try? container.decodeIfPresent(Bool.self, forKey: .privateOneToOne)
        conversationId = try? container.decodeIfPresent(String.self, forKey: .conversationId)
        members = try? container.decodeIfPresent([ISMChatGroupMember].self, forKey: .members)
        config = try? container.decodeIfPresent(ISMChatConfigConversation.self, forKey: .config)
        // Extract raw JSON string for metaData
        if let rawMetaData = try? container.decodeIfPresent(AnyCodable.self, forKey: .metaData) {
            let encoder = JSONEncoder()
            if let rawData = try? encoder.encode(rawMetaData),
               let jsonString = String(data: rawData, encoding: .utf8) {
                metaDataJson = jsonString
            }
        } else {
            metaDataJson = nil
        }
        metaData = try? container.decodeIfPresent(ISMChatUserMetaData.self, forKey: .metaData)
        metaDataJson = try? container.decodeIfPresent(String.self, forKey: .metaData)
    }
    public init(opponentDetails : ISMChatUser? = nil,lastMessageDetails : ISMChatLastMessage? = nil,unreadMessagesCount : Int? = nil,typing : Bool? = nil,customType : String? = nil,isGroup : Bool? = nil,membersCount : Int? = nil,lastMessageSentAt : Int? = nil,createdAt : Double? = nil,conversationTitle : String? = nil,conversationImageUrl : String? = nil,createdBy : String? = nil,createdByUserName : String? = nil,privateOneToOne : Bool? = nil,conversationId : String? = nil,members : [ISMChatGroupMember]? = nil,config : ISMChatConfigConversation? = nil,metaData : ISMChatUserMetaData? = nil,metaDataJson: String? = nil) {
        self.opponentDetails = opponentDetails
        self.lastMessageDetails = lastMessageDetails
        self.unreadMessagesCount = unreadMessagesCount
        self.typing = typing
        self.customType = customType
        self.isGroup = isGroup
        self.membersCount = membersCount
        self.lastMessageSentAt = lastMessageSentAt
        self.createdAt = createdAt
        self.conversationTitle = conversationTitle
        self.conversationImageUrl = conversationImageUrl
        self.createdBy = createdBy
        self.createdByUserName = createdByUserName
        self.privateOneToOne = privateOneToOne
        self.conversationId = conversationId
        self.members = members
        self.config = config
        self.metaData = metaData
        self.metaDataJson = metaDataJson
    }
}

public struct ISMChatLastMessage : Codable{
    public var sentAt : Double?
    public var updatedAt : Double?
    public var senderName : String?
    public var senderIdentifier : String?
    public var userId : String?
    public var userIdentifier : String?
    public var userProfileImageUrl : String?
    public var senderId : String?
    public var conversationId : String?
    public var body : String?
    public var messageId : String?
    public var customType : String?
    public var action : String?
    public var metaData : ISMChatMetaData?
    public var deliveredTo : [ISMChatMessageDeliveryStatus]? = []
    public var readBy : [ISMChatMessageDeliveryStatus]? = []
    public var conversationTitle : String?
    public var conversationImageUrl : String?
    public var reactionsCount : Int?
    public var reactionType : String?
    public var members : [ISMChatMemberAdded]?
    public var initiatorName : String?
    public var initiatorId : String?
    public var initiatorIdentifier : String?
    public var memberName : String?
    public var memberId : String?
    public var messageDeleted : Bool? = false
    public var userName : String?
    public var details : ISMChatMessageUpdatedDetail?
    public var meetingId : String?
    public var missedByMembers : [String]?
    public var callDurations : [ISMCallMeetingDuration]?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sentAt = try? container.decode(Double.self, forKey: .sentAt)
        updatedAt = try? container.decode(Double.self, forKey: .updatedAt)
        senderName = try? container.decode(String.self, forKey: .senderName)
        senderIdentifier = try? container.decode(String.self, forKey: .senderIdentifier)
        userId = try? container.decode(String.self, forKey: .userId)
        userIdentifier = try? container.decode(String.self, forKey: .userIdentifier)
        userProfileImageUrl = try? container.decode(String.self, forKey: .userProfileImageUrl)
        senderId = try? container.decode(String.self, forKey: .senderId)
        conversationId = try? container.decode(String.self, forKey: .conversationId)
        body = try? container.decode(String.self, forKey: .body)
        messageId = try? container.decode(String.self, forKey: .messageId)
        customType = try? container.decode(String.self, forKey: .customType)
        action = try? container.decode(String.self, forKey: .action)
        metaData = try? container.decode(ISMChatMetaData.self, forKey: .metaData)
        deliveredTo = try? container.decode([ISMChatMessageDeliveryStatus].self, forKey: .deliveredTo)
        readBy = try? container.decode([ISMChatMessageDeliveryStatus].self, forKey: .readBy)
        conversationTitle = try? container.decode(String.self, forKey: .conversationTitle)
        conversationImageUrl = try? container.decode(String.self, forKey: .conversationImageUrl)
        reactionsCount = try? container.decode(Int.self, forKey: .reactionsCount)
        reactionType = try? container.decode(String.self, forKey: .reactionType)
        members = try? container.decode([ISMChatMemberAdded].self, forKey: .members)
        initiatorName = try? container.decode(String.self, forKey: .initiatorName)
        initiatorId  = try? container.decode(String.self, forKey: .initiatorId)
        initiatorIdentifier  = try? container.decode(String.self, forKey: .initiatorIdentifier)
        memberName = try? container.decode(String.self, forKey: .memberName)
        memberId = try? container.decode(String.self, forKey: .memberId)
        userName = try? container.decode(String.self, forKey: .userName)
        details = try? container.decode(ISMChatMessageUpdatedDetail.self, forKey: .details)
        meetingId = try? container.decode(String.self, forKey: .meetingId)
        missedByMembers = try? container.decode([String].self, forKey: .missedByMembers)
        callDurations = try? container.decode([ISMCallMeetingDuration].self, forKey: .callDurations)
    }
    public init(sentAt : Double? = nil,senderName : String? = nil,senderIdentifier : String? = nil,senderId : String? = nil, conversationId : String? = nil,body : String? = nil,messageId : String? = nil,deliveredToUser : String? = nil,timeStamp : Double? = nil,customType : String? = nil,messageDeleted : Bool? = nil,action : String? = nil,userId : String? = nil,initiatorId : String? = nil,memberName : String? = nil,initiatorName : String? = nil,memberId : String? = nil,userName : String? = nil,initiatorIdentifier : String? = nil,members : [ISMChatMemberAdded]? = nil,userIdentifier : String? = nil,userProfileImageUrl : String? = nil,reactionType : String? = nil,meetingId : String? = nil,missedByMembers : [String]? = nil,callDurations : [ISMCallMeetingDuration]? = nil){
        self.sentAt = sentAt
        self.senderName = senderName
        self.senderIdentifier = senderIdentifier
        self.senderId = senderId
        self.conversationId = conversationId
        self.body = body
        self.messageId = messageId
        self.customType = customType
        self.messageDeleted = messageDeleted
        self.action = action
        self.userId = userId
        self.userName = userName
        self.initiatorId = initiatorId
        self.initiatorName = initiatorName
        self.initiatorIdentifier = initiatorIdentifier
        self.memberId = memberId
        self.memberName = memberName
        self.members = members
        self.userIdentifier = userIdentifier
        self.userProfileImageUrl = userProfileImageUrl
        self.reactionType = reactionType
        self.meetingId = meetingId
        self.missedByMembers = missedByMembers
        self.callDurations = callDurations
    }
}

public struct ISMChatCreateConversationResponse : Codable{
    public var newConversation : Bool?
    public var msg : String?
    public var conversationId : String?
    public var groupcastId : String?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        newConversation = try? container.decode(Bool.self, forKey: .newConversation)
        msg = try? container.decode(String.self, forKey: .msg)
        conversationId = try? container.decode(String.self, forKey: .conversationId)
        groupcastId = try? container.decode(String.self, forKey: .groupcastId)
    }
}

//public struct ISMCallMeetingDuration : Codable{
//    public var memberId : String?
//    public var durationInMilliseconds : Double?
//    public init(memberId: String? = nil, durationInMilliseconds: Double? = nil) {
//        self.memberId = memberId
//        self.durationInMilliseconds = durationInMilliseconds
//    }
//}

public struct  ISMChatMessageUpdatedDetail : Codable{
    public var body : String?
    public var customType : String?
    public var metaData : ISMChatMetaData?
    public  init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        body = try? container.decode(String.self, forKey: .body)
        customType = try? container.decode(String.self, forKey: .customType)
        metaData = try? container.decode(ISMChatMetaData.self, forKey: .metaData)
    }
}

public struct ISMChatMessageDeliveryStatus : Codable{
    public var userId : String?
    public var timestamp : Double?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try? container.decode(String.self, forKey: .userId)
        timestamp = try? container.decode(Double.self, forKey: .timestamp)
    }
    public init(userId : String? = nil,timestamp : Double? = nil){
        self.userId = userId
        self.timestamp = timestamp
    }
}
