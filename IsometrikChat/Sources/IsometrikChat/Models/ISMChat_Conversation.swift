//
//  ISM_Conversation.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 09/03/23.
//

import Foundation

public struct ISMChat_Conversations : Codable{
    public var msg : String?
    public var conversations : [ISMChat_ConversationsDetail]?
    public var groupcasts : [ISMChat_BroadCastDetail]?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msg = try? container.decode(String.self, forKey: .msg)
        conversations = try? container.decode([ISMChat_ConversationsDetail].self, forKey: .conversations)
        groupcasts = try? container.decode([ISMChat_BroadCastDetail].self, forKey: .groupcasts)
    }
}

public struct ISMChat_BroadCastDetail : Identifiable, Codable{
    public var id : String {groupcastId ?? ""}
    public var membersCount : Int?
    public var groupcastTitle : String?
    public var groupcastImageUrl : String?
    public var groupcastId : String?
    public var customType : String?
    public var createdBy : String?
    public var createdAt : Double?
    public var metaData : ISMChat_BroadMetadata?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        membersCount = try? container.decodeIfPresent(Int.self, forKey: .membersCount)
        groupcastTitle = try? container.decodeIfPresent(String.self, forKey: .groupcastTitle)
        groupcastImageUrl = try? container.decodeIfPresent(String.self, forKey: .groupcastImageUrl)
        groupcastId = try? container.decodeIfPresent(String.self, forKey: .groupcastId)
        customType = try? container.decodeIfPresent(String.self, forKey: .customType)
        createdBy = try? container.decodeIfPresent(String.self, forKey: .createdBy)
        createdAt = try? container.decodeIfPresent(Double.self, forKey: .createdAt)
        metaData = try? container.decodeIfPresent(ISMChat_BroadMetadata.self, forKey: .metaData)
    }
}

public struct ISMChat_BroadMetadata : Codable{
    public var membersDetail : [ISMChat_BroadCastMemberDetail] = []
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        membersDetail = try! container.decodeIfPresent([ISMChat_BroadCastMemberDetail].self, forKey: .membersDetail) ?? []
    }
}

public struct ISMChat_BroadCastMemberDetail: Identifiable,Codable{
    public var id = UUID()
    public var memberId : String?
    public var memberName : String?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        memberId = try? container.decodeIfPresent(String.self, forKey: .memberId)
        memberName = try? container.decodeIfPresent(String.self, forKey: .memberName)
    }
}

public struct ISMChat_ConversationsDetail : Identifiable, Codable{
    public var id : String {opponentDetails?.userId ?? ""}
    public var opponentDetails : ISMChat_User?
    public var lastMessageDetails : ISMChat_LastMessage?
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
    public var members : [ISMChat_GroupMember]?
    public var config : ISMChat_ConfigConversation?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        opponentDetails = try? container.decodeIfPresent(ISMChat_User.self, forKey: .opponentDetails)
        lastMessageDetails = try? container.decodeIfPresent(ISMChat_LastMessage.self, forKey: .lastMessageDetails)
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
        members = try? container.decodeIfPresent([ISMChat_GroupMember].self, forKey: .members)
        config = try? container.decodeIfPresent(ISMChat_ConfigConversation.self, forKey: .config)
    }
    public init(opponentDetails : ISMChat_User? = nil,lastMessageDetails : ISMChat_LastMessage? = nil,unreadMessagesCount : Int? = nil,typing : Bool? = nil,customType : String? = nil,isGroup : Bool? = nil,membersCount : Int? = nil,lastMessageSentAt : Int? = nil,createdAt : Double? = nil,conversationTitle : String? = nil,conversationImageUrl : String? = nil,createdBy : String? = nil,createdByUserName : String? = nil,privateOneToOne : Bool? = nil,conversationId : String? = nil,members : [ISMChat_GroupMember]? = nil,config : ISMChat_ConfigConversation? = nil) {
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
    }
}

public struct ISMChat_LastMessage : Codable{
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
    public var metaData : ISMChat_MetaData?
    public var deliveredTo : [ISMChat_MessageDeliveryStatus]? = []
    public var readBy : [ISMChat_MessageDeliveryStatus]? = []
    public var conversationTitle : String?
    public var conversationImageUrl : String?
    public var reactionsCount : Int?
    public var reactionType : String?
    public var members : [ISMChat_MemberAdded]?
    public var initiatorName : String?
    public var initiatorId : String?
    public var initiatorIdentifier : String?
    public var memberName : String?
    public var memberId : String?
    public var messageDeleted : Bool? = false
    public var userName : String?
    public var details : ISMChat_MessageUpdatedDetail?
    public var meetingId : String?
    public var missedByMembers : [String]?
    public var callDurations : [ISMCall_MeetingDuration]?
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
        metaData = try? container.decode(ISMChat_MetaData.self, forKey: .metaData)
        deliveredTo = try? container.decode([ISMChat_MessageDeliveryStatus].self, forKey: .deliveredTo)
        readBy = try? container.decode([ISMChat_MessageDeliveryStatus].self, forKey: .readBy)
        conversationTitle = try? container.decode(String.self, forKey: .conversationTitle)
        conversationImageUrl = try? container.decode(String.self, forKey: .conversationImageUrl)
        reactionsCount = try? container.decode(Int.self, forKey: .reactionsCount)
        reactionType = try? container.decode(String.self, forKey: .reactionType)
        members = try? container.decode([ISMChat_MemberAdded].self, forKey: .members)
        initiatorName = try? container.decode(String.self, forKey: .initiatorName)
        initiatorId  = try? container.decode(String.self, forKey: .initiatorId)
        initiatorIdentifier  = try? container.decode(String.self, forKey: .initiatorIdentifier)
        memberName = try? container.decode(String.self, forKey: .memberName)
        memberId = try? container.decode(String.self, forKey: .memberId)
        userName = try? container.decode(String.self, forKey: .userName)
        details = try? container.decode(ISMChat_MessageUpdatedDetail.self, forKey: .details)
        meetingId = try? container.decode(String.self, forKey: .meetingId)
        missedByMembers = try? container.decode([String].self, forKey: .missedByMembers)
        callDurations = try? container.decode([ISMCall_MeetingDuration].self, forKey: .callDurations)
    }
    public init(sentAt : Double? = nil,senderName : String? = nil,senderIdentifier : String? = nil,senderId : String? = nil, conversationId : String? = nil,body : String? = nil,messageId : String? = nil,deliveredToUser : String? = nil,timeStamp : Double? = nil,customType : String? = nil,messageDeleted : Bool? = nil,action : String? = nil,userId : String? = nil,initiatorId : String? = nil,memberName : String? = nil,initiatorName : String? = nil,memberId : String? = nil,userName : String? = nil,initiatorIdentifier : String? = nil,members : [ISMChat_MemberAdded]? = nil,userIdentifier : String? = nil,userProfileImageUrl : String? = nil,reactionType : String? = nil,meetingId : String? = nil,missedByMembers : [String]? = nil,callDurations : [ISMCall_MeetingDuration]? = nil){
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

public struct ISMChat_CreateConversationResponse : Codable{
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

public struct ISMCall_MeetingDuration : Codable{
    public var memberId : String?
    public var durationInMilliseconds : Double?
    public init(memberId: String? = nil, durationInMilliseconds: Double? = nil) {
        self.memberId = memberId
        self.durationInMilliseconds = durationInMilliseconds
    }
}

public struct  ISMChat_MessageUpdatedDetail : Codable{
    public var body : String?
    public  init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        body = try? container.decode(String.self, forKey: .body)
    }
}

public struct ISMChat_MessageDeliveryStatus : Codable{
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
