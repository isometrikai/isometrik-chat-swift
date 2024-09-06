//
//  ISMUser.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 09/03/23.
//

import Foundation


public struct ISMChatSendMsg :  Codable{
    public var messageId : String?
    public var msg : String?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messageId = try? container.decodeIfPresent(String.self, forKey: .messageId)
        msg = try? container.decodeIfPresent(String.self, forKey: .msg)
    }
}

public struct ISMChatUser : Identifiable, Codable ,Hashable{
    public var id : String {userId ?? ""}
    public var visibility : Bool?
    public var userProfileImageUrl : String?
    public var userName : String?
    public var userIdentifier : String?
    public var updatedAt : Double?
    public var online : Bool?
    public var notification : Bool?
    public var msg : String?
    public var createdAt : Double?
    public var userId : String?
    public var timestamp : Double?
    public var lastSeen : Double?
    public var email : String?
    public var metaData : ISMChatUserMetaData?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        visibility = try? container.decodeIfPresent(Bool.self, forKey: .visibility)
        userProfileImageUrl = try? container.decodeIfPresent(String.self, forKey: .userProfileImageUrl)
        userName = try? container.decodeIfPresent(String.self, forKey: .userName)
        userIdentifier = try? container.decodeIfPresent(String.self, forKey: .userIdentifier)
        updatedAt = try? container.decodeIfPresent(Double.self, forKey: .updatedAt)
        online = try? container.decodeIfPresent(Bool.self, forKey: .online)
        notification = try? container.decodeIfPresent(Bool.self, forKey: .notification)
        msg = try? container.decodeIfPresent(String.self, forKey: .msg)
        createdAt = try? container.decodeIfPresent(Double.self, forKey: .createdAt)
        userId = try? container.decodeIfPresent(String.self, forKey: .userId)
        timestamp = try? container.decodeIfPresent(Double.self, forKey: .timestamp)
        lastSeen = try? container.decodeIfPresent(Double.self, forKey: .lastSeen)
        email = try? container.decodeIfPresent(String.self, forKey: .email)
        metaData = try? container.decodeIfPresent(ISMChatUserMetaData.self, forKey: .metaData)
    }
    public init(userId : String? = nil,userName : String? = nil,userIdentifier : String? = nil, userProfileImage : String? = nil,metaData : ISMChatUserMetaData? = nil){
        self.userId = userId
        self.userName = userName
        self.userIdentifier = userIdentifier
        self.userProfileImageUrl = userProfileImage
        self.metaData = metaData
    }
}

public struct ISMChatUserMetaData: Codable, Hashable {
    public var about: String?
    public var showlastSeen: Bool?
    public var profilePic : String?
    public var userId : String?
    public var storeId : String?
    public var userType : Int?
    public var isStarUser : Bool?
    public var chatStatus : String?
    public var users : [ISMChatCustomUsers]?
    
    // flexCrew
    public var jobId : String?
    public var jobTitle : String?
    public var startDate : String?
    public var endDate : String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        about = try? container.decodeIfPresent(String.self, forKey: .about)
        
        // Decode showlastSeen, and set to true if nil
        if let showlastSeenValue = try? container.decodeIfPresent(Bool.self, forKey: .showlastSeen) {
            showlastSeen = showlastSeenValue
        } else {
            showlastSeen = true
        }
        profilePic = try? container.decodeIfPresent(String.self, forKey: .profilePic)
        userId = try? container.decodeIfPresent(String.self, forKey: .userId)
        storeId = try? container.decodeIfPresent(String.self, forKey: .storeId)
        userType = try? container.decodeIfPresent(Int.self, forKey: .userType)
        isStarUser = try? container.decodeIfPresent(Bool.self, forKey: .isStarUser)
        chatStatus = try? container.decodeIfPresent(String.self, forKey: .chatStatus)
        users = try? container.decodeIfPresent([ISMChatCustomUsers].self, forKey: .users)
        
        jobId = try? container.decodeIfPresent(String.self, forKey: .jobId)
        jobTitle = try? container.decodeIfPresent(String.self, forKey: .jobTitle)
        startDate = try? container.decodeIfPresent(String.self, forKey: .startDate)
        endDate = try? container.decodeIfPresent(String.self, forKey: .endDate)
    }
    public init(about : String? = nil,showlastSeen : Bool? = nil,profilePic : String? = nil, userId : String? = nil,storeId : String? = nil,userType : Int? = nil,isStarUser : Bool? = nil,chatStatus : String? = nil,users : [ISMChatCustomUsers]? = nil){
        self.about = about
        self.showlastSeen = showlastSeen
        self.profilePic = profilePic
        self.userId = userId
        self.storeId = storeId
        self.userType = userType
        self.isStarUser = isStarUser
        self.chatStatus = chatStatus
        self.users = users
    }
}

public struct ISMChatCustomUsers : Codable,Hashable{
    public var userId: String?
    public var isomatricChatUserId: String?
    public var userName: String?
    public var userProfilePic: String?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try? container.decodeIfPresent(String.self, forKey: .userId)
        isomatricChatUserId = try? container.decodeIfPresent(String.self, forKey: .isomatricChatUserId)
        userName = try? container.decodeIfPresent(String.self, forKey: .userName)
        userProfilePic = try? container.decodeIfPresent(String.self, forKey: .userProfilePic)
    }
}

public struct ISMChatUsers : Codable{
    public var users : [ISMChatUser]? = []
    public var pageToken : String?
    public var msg : String?
    public var conversationEligibleMembers : [ISMChatUser]? = []
    public var groupcastEligibleMembers : [ISMChatUser]? = []
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        users = try? container.decodeIfPresent([ISMChatUser].self, forKey: .users)
        pageToken = try? container.decodeIfPresent(String.self, forKey: .pageToken)
        msg = try? container.decodeIfPresent(String.self, forKey: .msg)
        conversationEligibleMembers = try? container.decodeIfPresent([ISMChatUser].self, forKey: .conversationEligibleMembers)
        groupcastEligibleMembers = try? container.decodeIfPresent([ISMChatUser].self, forKey: .groupcastEligibleMembers)
    }
}
