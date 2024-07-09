//
//  ISM_ConversationDetail_Model.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 14/03/23.
//

import Foundation


public struct ISMChat_ConversationDetail : Codable{
    public var msg : String?
    public var conversationDetails : ISMChat_ConversationInDetail?
    public var users : [ISMChat_User]?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msg = try? container.decode(String.self, forKey: .msg)
        conversationDetails = try? container.decode(ISMChat_ConversationInDetail.self, forKey: .conversationDetails)
        users = try? container.decode([ISMChat_User].self, forKey: .users)
    }
}

public struct ISMChat_ConversationInDetail : Codable{
    public var opponentDetails : ISMChat_User?
    public var messagingDisabled : Bool?
    public var usersOwnDetails : ISMChat_UserOwnDetail?
    public var updatedAt : Double?
    public var privateOneToOne : Bool?
    public var membersCount : Int?
    public var members : [ISMChat_GroupMember]? = []
    public var lastMessageSentAt : Double?
    public var isGroup : Bool?
    public var createdByUserName : String?
    public var createdByUserImageUrl : String?
    public var createdBy : String?
    public var createdAt : Double?
    public var conversationType : Int?
    public var conversationTitle : String?
    public var conversationImageUrl : String?
    public var config : ISMChat_ConfigConversation?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        opponentDetails = try? container.decode(ISMChat_User.self, forKey: .opponentDetails)
        messagingDisabled = try? container.decode(Bool.self, forKey: .messagingDisabled)
        usersOwnDetails = try? container.decode(ISMChat_UserOwnDetail.self, forKey: .usersOwnDetails)
        updatedAt = try? container.decode(Double.self, forKey: .updatedAt)
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
        members = try? container.decode([ISMChat_GroupMember].self, forKey: .members)
        config = try? container.decode(ISMChat_ConfigConversation.self, forKey: .config)
    }
}

public struct ISMChat_ConfigConversation : Codable{
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

public struct ISMChat_UserOwnDetail : Codable{
    public var memberId : String?
    public var isAdmin : Bool?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        memberId = try? container.decode(String.self, forKey: .memberId)
        isAdmin = try? container.decode(Bool.self, forKey: .isAdmin)
    }
}

public struct ISMChat_GroupMember : Codable, Identifiable, Hashable{
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

public struct ISMChat_MemberAdded : Codable, Hashable{
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
