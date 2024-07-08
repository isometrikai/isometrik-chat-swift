//
//  ISMChat_Broadcast.swift
//  ISMChatSdk
//
//  Created by Rasika on 04/06/24.
//

import Foundation


struct ISMChat_BroadCastMembers : Codable{
    var msg : String?
    var membersCount : Int?
    var members : [ISMChat_BroadcastMemberDetail]?
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msg = try? container.decode(String.self, forKey: .msg)
        membersCount = try? container.decode(Int.self, forKey: .membersCount)
        members = try? container.decode([ISMChat_BroadcastMemberDetail].self, forKey: .members)
    }
}


struct ISMChat_BroadcastMemberDetail : Identifiable, Codable{
    var id = UUID().uuidString
    var memberId : String?
    var memberInfo : ISMChat_User?
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        memberId = try? container.decode(String.self, forKey: .memberId)
        memberInfo = try? container.decode(ISMChat_User.self, forKey: .memberInfo)
    }
}
