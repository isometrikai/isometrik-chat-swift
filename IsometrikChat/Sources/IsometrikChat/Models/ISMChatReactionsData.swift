//
//  ISMReactions.swift
//  ISMChatSdk
//
//  Created by Rasika on 22/04/24.
//

import Foundation

public struct ISMChatReactionsData : Codable{
    public var msg : String?
    public var reactions : [ISMChatReactionsDetails]?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msg = try? container.decode(String.self, forKey: .msg)
        reactions = try? container.decode([ISMChatReactionsDetails].self, forKey: .reactions)
    }
}


public struct ISMChatReactionsDetails : Codable{
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
