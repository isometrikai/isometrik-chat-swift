//
//  ISM_ConversationDetail_Model.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 14/03/23.
//

import Foundation


struct ISMChat_ConversationDetail : Codable{
    var msg : String?
    var conversationDetails : ISMChat_ConversationInDetail?
    var users : [ISMChat_User]?
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msg = try? container.decode(String.self, forKey: .msg)
        conversationDetails = try? container.decode(ISMChat_ConversationInDetail.self, forKey: .conversationDetails)
        users = try? container.decode([ISMChat_User].self, forKey: .users)
    }
}

struct ISMChat_ConversationInDetail : Codable{
    var opponentDetails : ISMChat_User?
    var messagingDisabled : Bool?
    var usersOwnDetails : ISMChat_UserOwnDetail?
    var updatedAt : Double?
    var privateOneToOne : Bool?
    var membersCount : Int?
    var members : [ISMChat_GroupMember]? = []
    var lastMessageSentAt : Double?
    var isGroup : Bool?
    var createdByUserName : String?
    var createdByUserImageUrl : String?
    var createdBy : String?
    var createdAt : Double?
    var conversationType : Int?
    var conversationTitle : String?
    var conversationImageUrl : String?
    var config : ISMChat_ConfigConversation?
    init(from decoder: Decoder) throws {
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

struct ISMChat_ConfigConversation : Codable{
    var typingEvents : Bool?
    var readEvents : Bool?
    var pushNotifications : Bool?
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        typingEvents = try? container.decode(Bool.self, forKey: .typingEvents)
        readEvents = try? container.decode(Bool.self, forKey: .readEvents)
        pushNotifications = try? container.decode(Bool.self, forKey: .pushNotifications)
    }
}

struct ISMChat_UserOwnDetail : Codable{
    var memberId : String?
    var isAdmin : Bool?
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        memberId = try? container.decode(String.self, forKey: .memberId)
        isAdmin = try? container.decode(Bool.self, forKey: .isAdmin)
    }
}

struct ISMChat_GroupMember : Codable, Identifiable, Hashable{
    var id = UUID()
    var userProfileImageUrl : String?
    var userName : String?
    var userIdentifier : String?
    var userId : String?
    var online : Bool?
    var lastSeen : Double?
    var isAdmin: Bool?
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userProfileImageUrl = try? container.decode(String.self, forKey: .userProfileImageUrl)
        userName = try? container.decode(String.self, forKey: .userName)
        userIdentifier = try? container.decode(String.self, forKey: .userIdentifier)
        userId = try? container.decode(String.self, forKey: .userId)
        online = try? container.decode(Bool.self, forKey: .online)
        lastSeen = try? container.decode(Double.self, forKey: .lastSeen)
        isAdmin = try? container.decode(Bool.self, forKey: .isAdmin)
    }
    init(userProfileImageUrl : String? = nil,userName : String? = nil,userIdentifier : String? = nil,userId : String? = nil,online : Bool? = nil,lastSeen : Double? = nil,isAdmin : Bool? = nil){
        self.userProfileImageUrl = userProfileImageUrl
        self.userName = userName
        self.userIdentifier = userIdentifier
        self.userId = userId
        self.online = online
        self.lastSeen = lastSeen
        self.isAdmin = isAdmin
    }
}

struct ISMChat_MemberAdded : Codable, Hashable{
    var memberProfileImageUrl : String?
    var memberName : String?
    var memberIdentifier : String?
    var memberId : String?
    var isPublishing : Bool?
    var isAdmin: Bool?
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        memberProfileImageUrl = try? container.decode(String.self, forKey: .memberProfileImageUrl)
        memberName = try? container.decode(String.self, forKey: .memberName)
        memberIdentifier = try? container.decode(String.self, forKey: .memberIdentifier)
        memberId = try? container.decode(String.self, forKey: .memberId)
        isPublishing = try? container.decode(Bool.self, forKey: .isPublishing)
        isAdmin = try? container.decode(Bool.self, forKey: .isAdmin)
    }
    init(memberProfileImageUrl : String? = nil,memberName : String? = nil,memberIdentifier : String? = nil,memberId : String? = nil,isPublishing : Bool? = nil,isAdmin : Bool? = nil){
        self.memberProfileImageUrl = memberProfileImageUrl
        self.memberName = memberName
        self.memberIdentifier = memberIdentifier
        self.memberId = memberId
        self.isPublishing = isPublishing
        self.isAdmin = isAdmin
    }
}
