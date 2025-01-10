//
//  ISMConversationDetailModel.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 14/03/23.
//

import Foundation


public struct ISMChatConversationDetail : Codable{
    public var msg : String?
    public var conversationDetails : ISMChatConversationInDetail?
    public var users : [ISMChatUser]?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msg = try? container.decode(String.self, forKey: .msg)
        conversationDetails = try? container.decode(ISMChatConversationInDetail.self, forKey: .conversationDetails)
        users = try? container.decode([ISMChatUser].self, forKey: .users)
    }
}

public struct ISMChatConversationInDetail : Codable{
    public var opponentDetails : ISMChatUser?
    public var messagingDisabled : Bool?
    public var usersOwnDetails : ISMChatUserOwnDetail?
    public var updatedAt : Double?
    public var customType : String?
    public var privateOneToOne : Bool?
    public var membersCount : Int?
    public var members : [ISMChatGroupMember]? = []
    public var lastMessageSentAt : Double?
    public var isGroup : Bool?
    public var createdByUserName : String?
    public var createdByUserImageUrl : String?
    public var createdBy : String?
    public var createdAt : Double?
    public var conversationType : Int?
    public var conversationTitle : String?
    public var conversationImageUrl : String?
    public var config : ISMChatConfigConversation?
    public var metaDataJson : String?
    public var metaData : ISMChatUserMetaData?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        opponentDetails = try? container.decode(ISMChatUser.self, forKey: .opponentDetails)
        messagingDisabled = try? container.decode(Bool.self, forKey: .messagingDisabled)
        usersOwnDetails = try? container.decode(ISMChatUserOwnDetail.self, forKey: .usersOwnDetails)
        updatedAt = try? container.decode(Double.self, forKey: .updatedAt)
        customType = try? container.decode(String.self, forKey: .customType)
        privateOneToOne = try? container.decode(Bool.self, forKey: .privateOneToOne)
        membersCount = try? container.decode(Int.self, forKey: .membersCount)
        lastMessageSentAt = try? container.decode(Double.self, forKey: .lastMessageSentAt)
        isGroup = try? container.decode(Bool.self, forKey: .isGroup)
        createdByUserName = try? container.decode(String.self, forKey: .createdByUserName)
        createdByUserImageUrl = try? container.decode(String.self, forKey: .createdByUserImageUrl)
        createdBy = try? container.decode(String.self, forKey: .createdBy)
        createdAt = try? container.decode(Double.self, forKey: .createdAt)
        conversationType = try? container.decode(Int.self, forKey: .conversationType)
        conversationTitle = try? container.decode(String.self, forKey: .conversationTitle)
        conversationImageUrl = try? container.decode(String.self, forKey: .conversationImageUrl)
        members = try? container.decode([ISMChatGroupMember].self, forKey: .members)
        config = try? container.decode(ISMChatConfigConversation.self, forKey: .config)
        // Extract raw JSON string for metaData
        if let rawMetaData = try? container.decodeIfPresent(AnyCodable.self, forKey: .metaData) {
            let encoder = JSONEncoder()
            if let rawData = try? encoder.encode(rawMetaData),
               let jsonString = String(data: rawData, encoding: .utf8) {
                metaDataJson = jsonString
            }
        } else {
            do {
                let rawMetaData = try container.decode(AnyCodable.self, forKey: .metaData)
                print("Decoded rawMetaData: \(rawMetaData)")
            } catch {
                print("Failed to decode metaData: \(error)")
            }
            metaDataJson = nil
        }
        metaData = try? container.decode(ISMChatUserMetaData.self, forKey: .metaData)
        metaDataJson = try? container.decode(String.self, forKey: .metaData)
    }
}

public struct ISMChatConfigConversation : Codable{
    public var typingEvents : Bool?
    public var readEvents : Bool?
    public var pushNotifications : Bool?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        typingEvents = try? container.decode(Bool.self, forKey: .typingEvents)
        readEvents = try? container.decode(Bool.self, forKey: .readEvents)
        pushNotifications = try? container.decode(Bool.self, forKey: .pushNotifications)
    }
}

public struct ISMChatUserOwnDetail : Codable{
    public var memberId : String?
    public var isAdmin : Bool?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        memberId = try? container.decode(String.self, forKey: .memberId)
        isAdmin = try? container.decode(Bool.self, forKey: .isAdmin)
    }
}

public struct ISMChatGroupMember : Codable, Identifiable, Hashable{
    public var id = UUID()
    public var userProfileImageUrl : String?
    public var userName : String?
    public var userIdentifier : String?
    public var userId : String?
    public var online : Bool?
    public var lastSeen : Double?
    public var isAdmin: Bool?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userProfileImageUrl = try? container.decode(String.self, forKey: .userProfileImageUrl)
        userName = try? container.decode(String.self, forKey: .userName)
        userIdentifier = try? container.decode(String.self, forKey: .userIdentifier)
        userId = try? container.decode(String.self, forKey: .userId)
        online = try? container.decode(Bool.self, forKey: .online)
        lastSeen = try? container.decode(Double.self, forKey: .lastSeen)
        isAdmin = try? container.decode(Bool.self, forKey: .isAdmin)
    }
    public init(userProfileImageUrl : String? = nil,userName : String? = nil,userIdentifier : String? = nil,userId : String? = nil,online : Bool? = nil,lastSeen : Double? = nil,isAdmin : Bool? = nil){
        self.userProfileImageUrl = userProfileImageUrl
        self.userName = userName
        self.userIdentifier = userIdentifier
        self.userId = userId
        self.online = online
        self.lastSeen = lastSeen
        self.isAdmin = isAdmin
    }
}

public struct ISMChatMemberAdded : Codable, Hashable{
    public var memberProfileImageUrl : String?
    public var memberName : String?
    public var memberIdentifier : String?
    public var memberId : String?
    public var isPublishing : Bool?
    public var isAdmin: Bool?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        memberProfileImageUrl = try? container.decode(String.self, forKey: .memberProfileImageUrl)
        memberName = try? container.decode(String.self, forKey: .memberName)
        memberIdentifier = try? container.decode(String.self, forKey: .memberIdentifier)
        memberId = try? container.decode(String.self, forKey: .memberId)
        isPublishing = try? container.decode(Bool.self, forKey: .isPublishing)
        isAdmin = try? container.decode(Bool.self, forKey: .isAdmin)
    }
    public init(memberProfileImageUrl : String? = nil,memberName : String? = nil,memberIdentifier : String? = nil,memberId : String? = nil,isPublishing : Bool? = nil,isAdmin : Bool? = nil){
        self.memberProfileImageUrl = memberProfileImageUrl
        self.memberName = memberName
        self.memberIdentifier = memberIdentifier
        self.memberId = memberId
        self.isPublishing = isPublishing
        self.isAdmin = isAdmin
    }
}
