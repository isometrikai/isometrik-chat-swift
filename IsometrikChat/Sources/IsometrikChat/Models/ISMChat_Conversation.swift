//
//  ISM_Conversation.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 09/03/23.
//

import Foundation

struct ISMChat_Conversations : Codable{
    var msg : String?
    var conversations : [ISMChat_ConversationsDetail]?
    var groupcasts : [ISMChat_BroadCastDetail]?
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msg = try? container.decode(String.self, forKey: .msg)
        conversations = try? container.decode([ISMChat_ConversationsDetail].self, forKey: .conversations)
        groupcasts = try? container.decode([ISMChat_BroadCastDetail].self, forKey: .groupcasts)
    }
}

struct ISMChat_BroadCastDetail : Identifiable, Codable{
    var id : String {groupcastId ?? ""}
    var membersCount : Int?
    var groupcastTitle : String?
    var groupcastImageUrl : String?
    var groupcastId : String?
    var customType : String?
    var createdBy : String?
    var createdAt : Double?
    var metaData : ISMChat_BroadMetadata?
    init(from decoder: Decoder) throws {
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

struct ISMChat_BroadMetadata : Codable{
    var membersDetail : [ISMChat_BroadCastMemberDetail] = []
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        membersDetail = try! container.decodeIfPresent([ISMChat_BroadCastMemberDetail].self, forKey: .membersDetail) ?? []
    }
}

struct ISMChat_BroadCastMemberDetail: Identifiable,Codable{
    var id = UUID()
    var memberId : String?
    var memberName : String?
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        memberId = try? container.decodeIfPresent(String.self, forKey: .memberId)
        memberName = try? container.decodeIfPresent(String.self, forKey: .memberName)
    }
}

struct ISMChat_ConversationsDetail : Identifiable, Codable{
    var id : String {opponentDetails?.userId ?? ""}
    var opponentDetails : ISMChat_User?
    var lastMessageDetails : ISMChat_LastMessage?
    var unreadMessagesCount : Int?
    var typing : Bool?
    var customType : String?
    var isGroup : Bool?
    var membersCount : Int?
    var lastMessageSentAt : Int?
    var createdAt : Double?
    var conversationTitle : String?
    var conversationImageUrl : String?
    var createdBy : String?
    var createdByUserName : String?
    var privateOneToOne : Bool?
    var conversationId : String?
    var members : [ISMChat_GroupMember]?
    var config : ISMChat_ConfigConversation?
    init(from decoder: Decoder) throws {
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
    init(opponentDetails : ISMChat_User? = nil,lastMessageDetails : ISMChat_LastMessage? = nil,unreadMessagesCount : Int? = nil,typing : Bool? = nil,customType : String? = nil,isGroup : Bool? = nil,membersCount : Int? = nil,lastMessageSentAt : Int? = nil,createdAt : Double? = nil,conversationTitle : String? = nil,conversationImageUrl : String? = nil,createdBy : String? = nil,createdByUserName : String? = nil,privateOneToOne : Bool? = nil,conversationId : String? = nil,members : [ISMChat_GroupMember]? = nil,config : ISMChat_ConfigConversation? = nil) {
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

struct ISMChat_LastMessage : Codable{
    var sentAt : Double?
    var updatedAt : Double?
    var senderName : String?
    var senderIdentifier : String?
    var userId : String?
    var userIdentifier : String?
    var userProfileImageUrl : String?
    var senderId : String?
    var conversationId : String?
    var body : String?
    var messageId : String?
    var customType : String?
    var action : String?
    var metaData : ISMChat_MetaData?
    var deliveredTo : [ISMChat_MessageDeliveryStatus]? = []
    var readBy : [ISMChat_MessageDeliveryStatus]? = []
    var conversationTitle : String?
    var conversationImageUrl : String?
    var reactionsCount : Int?
    var reactionType : String?
    var members : [ISMChat_MemberAdded]?
    var initiatorName : String?
    var initiatorId : String?
    var initiatorIdentifier : String?
    var memberName : String?
    var memberId : String?
    var messageDeleted : Bool? = false
    var userName : String?
    var details : ISMChat_MessageUpdatedDetail?
    var meetingId : String?
    var missedByMembers : [String]?
    var callDurations : [ISMCall_MeetingDuration]?
    init(from decoder: Decoder) throws {
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
    init(sentAt : Double? = nil,senderName : String? = nil,senderIdentifier : String? = nil,senderId : String? = nil, conversationId : String? = nil,body : String? = nil,messageId : String? = nil,deliveredToUser : String? = nil,timeStamp : Double? = nil,customType : String? = nil,messageDeleted : Bool? = nil,action : String? = nil,userId : String? = nil,initiatorId : String? = nil,memberName : String? = nil,initiatorName : String? = nil,memberId : String? = nil,userName : String? = nil,initiatorIdentifier : String? = nil,members : [ISMChat_MemberAdded]? = nil,userIdentifier : String? = nil,userProfileImageUrl : String? = nil,reactionType : String? = nil,meetingId : String? = nil,missedByMembers : [String]? = nil,callDurations : [ISMCall_MeetingDuration]? = nil){
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

struct ISMChat_CreateConversationResponse : Codable{
    var newConversation : Bool?
    var msg : String?
    var conversationId : String?
    var groupcastId : String?
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        newConversation = try? container.decode(Bool.self, forKey: .newConversation)
        msg = try? container.decode(String.self, forKey: .msg)
        conversationId = try? container.decode(String.self, forKey: .conversationId)
        groupcastId = try? container.decode(String.self, forKey: .groupcastId)
    }
}

struct ISMCall_MeetingDuration : Codable{
    var memberId : String?
    var durationInMilliseconds : Double?
    init(memberId: String? = nil, durationInMilliseconds: Double? = nil) {
        self.memberId = memberId
        self.durationInMilliseconds = durationInMilliseconds
    }
}

struct  ISMChat_MessageUpdatedDetail : Codable{
    var body : String?
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        body = try? container.decode(String.self, forKey: .body)
    }
}

struct ISMChat_MessageDeliveryStatus : Codable{
    var userId : String?
    var timestamp : Double?
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try? container.decode(String.self, forKey: .userId)
        timestamp = try? container.decode(Double.self, forKey: .timestamp)
    }
    init(userId : String? = nil,timestamp : Double? = nil){
        self.userId = userId
        self.timestamp = timestamp
    }
}
