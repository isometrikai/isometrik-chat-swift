//
//  ISM_PresignedUrl_Model.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 10/03/23.
//

import Foundation

struct ISMChat_PresignedUrl : Codable{
    var presignedUrls : [ISMChat_PresignedUrlDetail]?
    var msg : String?
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        presignedUrls = try? container.decode([ISMChat_PresignedUrlDetail].self, forKey: .presignedUrls)
        msg = try? container.decode(String.self, forKey: .msg)
    }
}

struct ISMChat_PresignedUrlDetail : Codable{
    var ttl : Int?
    var thumbnailUrl : String?
    var thumbnailPresignedUrl : String?
    var mediaUrl : String?
    var mediaPresignedUrl : String?
    var mediaId : String?
    var presignedUrl : String?
    var name : String = ""
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ttl = try? container.decode(Int.self, forKey: .ttl)
        thumbnailUrl = try? container.decode(String.self, forKey: .thumbnailUrl)
        thumbnailPresignedUrl = try? container.decode(String.self, forKey: .thumbnailPresignedUrl)
        mediaUrl = try? container.decode(String.self, forKey: .mediaUrl)
        mediaPresignedUrl = try? container.decode(String.self, forKey: .mediaPresignedUrl)
        mediaId = try? container.decode(String.self, forKey: .mediaId)
        presignedUrl = try? container.decode(String.self, forKey: .presignedUrl)
    }
}
