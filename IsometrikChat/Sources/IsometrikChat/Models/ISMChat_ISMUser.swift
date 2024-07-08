//
//  ISM_User.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 09/03/23.
//

import Foundation


struct ISMChat_SendMsg :  Codable{
//    var id: UUID?
    
    var messageId : String?
    var msg : String?
   
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messageId = try? container.decodeIfPresent(String.self, forKey: .messageId)
        msg = try? container.decodeIfPresent(String.self, forKey: .msg)
    }
}

struct ISMChat_User : Identifiable, Codable ,Hashable{
    var id : String {userId ?? ""}
    var visibility : Bool?
    var userProfileImageUrl : String?
    var userName : String?
    var userIdentifier : String?
    var updatedAt : Double?
    var online : Bool?
    var notification : Bool?
    var msg : String?
    var createdAt : Double?
    var userId : String?
    var timestamp : Double?
    var lastSeen : Double?
    var email : String?
    var metaData : ISMChat_UserMetaData?
    init(from decoder: Decoder) throws {
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
    init(userId : String? = nil,userName : String? = nil,userIdentifier : String? = nil, userProfileImage : String? = nil,metaData : ISMChat_UserMetaData? = nil){
        self.userId = userId
        self.userName = userName
        self.userIdentifier = userIdentifier
        self.userProfileImageUrl = userProfileImage
        self.metaData = metaData
    }
}

struct ISMChat_UserMetaData: Codable, Hashable {
    var about: String?
    var showlastSeen: Bool? 
    
    init(from decoder: Decoder) throws {
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

struct ISMChat_Users : Codable{
    var users : [ISMChat_User]? = []
    var pageToken : String?
    var msg : String?
    var conversationEligibleMembers : [ISMChat_User]? = []
    var groupcastEligibleMembers : [ISMChat_User]? = []
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        users = try? container.decodeIfPresent([ISMChat_User].self, forKey: .users)
        pageToken = try? container.decodeIfPresent(String.self, forKey: .pageToken)
        msg = try? container.decodeIfPresent(String.self, forKey: .msg)
        conversationEligibleMembers = try? container.decodeIfPresent([ISMChat_User].self, forKey: .conversationEligibleMembers)
        groupcastEligibleMembers = try? container.decodeIfPresent([ISMChat_User].self, forKey: .groupcastEligibleMembers)
    }
}
