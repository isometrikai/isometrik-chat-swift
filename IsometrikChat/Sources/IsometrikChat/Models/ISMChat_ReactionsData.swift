//
//  ISMReactions.swift
//  ISMChatSdk
//
//  Created by Rasika on 22/04/24.
//

import Foundation

public struct ISMChat_ReactionsData : Codable{
    public var msg : String?
    public var reactions : [ISMChat_ReactionsDetails]?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msg = try? container.decode(String.self, forKey: .msg)
        reactions = try? container.decode([ISMChat_ReactionsDetails].self, forKey: .reactions)
    }
}


public struct ISMChat_ReactionsDetails : Codable{
    public var userProfileImageUrl : String?
    public var userName : String?
    public var userIdentifier : String?
    public var userId : String?
    public var online : Bool?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userProfileImageUrl = try? container.decode(String.self, forKey: .userProfileImageUrl)
        userName = try? container.decode(String.self, forKey: .userName)
        userIdentifier = try? container.decode(String.self, forKey: .userIdentifier)
        userId = try? container.decode(String.self, forKey: .userId)
        online = try? container.decode(Bool.self, forKey: .online)
    }
}
