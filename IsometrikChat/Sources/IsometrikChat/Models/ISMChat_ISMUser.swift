//
//  ISM_User.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 09/03/23.
//

import Foundation


public struct ISMChat_SendMsg :  Codable{
//    var id: UUID?
    
    public var messageId : String?
    public var msg : String?
   
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messageId = try? container.decodeIfPresent(String.self, forKey: .messageId)
        msg = try? container.decodeIfPresent(String.self, forKey: .msg)
    }
}

public struct ISMChat_User : Identifiable, Codable ,Hashable{
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
    public var metaData : ISMChat_UserMetaData?
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
        metaData = try? container.decodeIfPresent(ISMChat_UserMetaData.self, forKey: .metaData)
    }
    public init(userId : String? = nil,userName : String? = nil,userIdentifier : String? = nil, userProfileImage : String? = nil,metaData : ISMChat_UserMetaData? = nil){
        self.userId = userId
        self.userName = userName
        self.userIdentifier = userIdentifier
        self.userProfileImageUrl = userProfileImage
        self.metaData = metaData
    }
}

public struct ISMChat_UserMetaData: Codable, Hashable {
    public var about: String?
    public var showlastSeen: Bool?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        about = try? container.decodeIfPresent(String.self, forKey: .about)
        
        // Decode showlastSeen, and set to true if nil
        if let showlastSeenValue = try? container.decodeIfPresent(Bool.self, forKey: .showlastSeen) {
            showlastSeen = showlastSeenValue
        } else {
            showlastSeen = true
        }
    }
}

public struct ISMChat_Users : Codable{
    public var users : [ISMChat_User]? = []
    public var pageToken : String?
    public var msg : String?
    public var conversationEligibleMembers : [ISMChat_User]? = []
    public var groupcastEligibleMembers : [ISMChat_User]? = []
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        users = try? container.decodeIfPresent([ISMChat_User].self, forKey: .users)
        pageToken = try? container.decodeIfPresent(String.self, forKey: .pageToken)
        msg = try? container.decodeIfPresent(String.self, forKey: .msg)
        conversationEligibleMembers = try? container.decodeIfPresent([ISMChat_User].self, forKey: .conversationEligibleMembers)
        groupcastEligibleMembers = try? container.decodeIfPresent([ISMChat_User].self, forKey: .groupcastEligibleMembers)
    }
}
