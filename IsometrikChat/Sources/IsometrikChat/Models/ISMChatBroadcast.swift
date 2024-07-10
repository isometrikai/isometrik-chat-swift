//
//  ISMChatBroadcast.swift
//  ISMChatSdk
//
//  Created by Rasika on 04/06/24.
//

import Foundation


public struct ISMChatBroadCastMembers : Codable{
    public var msg : String?
    public var membersCount : Int?
    public var members : [ISMChatBroadcastMemberDetail]?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msg = try? container.decode(String.self, forKey: .msg)
        membersCount = try? container.decode(Int.self, forKey: .membersCount)
        members = try? container.decode([ISMChatBroadcastMemberDetail].self, forKey: .members)
    }
}


public struct ISMChatBroadcastMemberDetail : Identifiable, Codable{
    public var id = UUID().uuidString
    public var memberId : String?
    public var memberInfo : ISMChatUser?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        memberId = try? container.decode(String.self, forKey: .memberId)
        memberInfo = try? container.decode(ISMChatUser.self, forKey: .memberInfo)
    }
}
