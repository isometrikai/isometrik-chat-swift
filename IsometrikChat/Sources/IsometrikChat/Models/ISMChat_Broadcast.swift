//
//  ISMChat_Broadcast.swift
//  ISMChatSdk
//
//  Created by Rasika on 04/06/24.
//

import Foundation


public struct ISMChat_BroadCastMembers : Codable{
    public var msg : String?
    public var membersCount : Int?
    public var members : [ISMChat_BroadcastMemberDetail]?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msg = try? container.decode(String.self, forKey: .msg)
        membersCount = try? container.decode(Int.self, forKey: .membersCount)
        members = try? container.decode([ISMChat_BroadcastMemberDetail].self, forKey: .members)
    }
}


public struct ISMChat_BroadcastMemberDetail : Identifiable, Codable{
    public var id = UUID().uuidString
    public var memberId : String?
    public var memberInfo : ISMChat_User?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        memberId = try? container.decode(String.self, forKey: .memberId)
        memberInfo = try? container.decode(ISMChat_User.self, forKey: .memberInfo)
    }
}
