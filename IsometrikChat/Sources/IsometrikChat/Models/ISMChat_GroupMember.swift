//
//  ISMGroupMember.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 27/07/23.
//

import Foundation

public struct ISMGroupMember : Codable{
    public var msg : String?
    public var conversationMembers : [ISMChat_GroupMember]?
    public var membersCount : Int?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msg = try? container.decodeIfPresent(String.self, forKey: .msg)
        conversationMembers = try? container.decodeIfPresent([ISMChat_GroupMember].self, forKey: .conversationMembers)
        membersCount = try? container.decodeIfPresent(Int.self, forKey: .membersCount)
    }
}
