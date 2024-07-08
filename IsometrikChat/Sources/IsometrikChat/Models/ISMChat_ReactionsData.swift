//
//  ISMReactions.swift
//  ISMChatSdk
//
//  Created by Rasika on 22/04/24.
//

import Foundation

struct ISMChat_ReactionsData : Codable{
    var msg : String?
    var reactions : [ISMChat_ReactionsDetails]?
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msg = try? container.decode(String.self, forKey: .msg)
        reactions = try? container.decode([ISMChat_ReactionsDetails].self, forKey: .reactions)
    }
}


struct ISMChat_ReactionsDetails : Codable{
    var userProfileImageUrl : String?
    var userName : String?
    var userIdentifier : String?
    var userId : String?
    var online : Bool?
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userProfileImageUrl = try? container.decode(String.self, forKey: .userProfileImageUrl)
        userName = try? container.decode(String.self, forKey: .userName)
        userIdentifier = try? container.decode(String.self, forKey: .userIdentifier)
        userId = try? container.decode(String.self, forKey: .userId)
        online = try? container.decode(Bool.self, forKey: .online)
    }
}

//
//{
//  "reactions": [
//    {
//      "userProfileImageUrl": "https://res.cloudinary.com/demo/image/upload/sample.jpg",
//      "userName": "koko",
//      "userIdentifier": "jojo2@lolo.com",
//      "userId": "5fb4feb921a38e7b81fac663",
//      "online": false,
//      "metaData": {
//        "country": "India"
//      },
//      "lastSeen": -1
//    }
//  ],
//  "msg": "Reactions fetched successfully."
//}
