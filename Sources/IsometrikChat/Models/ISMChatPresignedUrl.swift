//
//  ISMPresignedUrlModel.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 10/03/23.
//

import Foundation

public struct ISMChatPresignedUrl : Codable{
    var presignedUrls : [ISMChatPresignedUrlDetail]?
    var msg : String?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        presignedUrls = try? container.decode([ISMChatPresignedUrlDetail].self, forKey: .presignedUrls)
        msg = try? container.decode(String.self, forKey: .msg)
    }
}

public struct ISMChatPresignedUrlDetail : Codable{
    public var ttl : Int?
    public var thumbnailUrl : String?
    public var thumbnailPresignedUrl : String?
    public var mediaUrl : String?
    public var mediaPresignedUrl : String?
    public var mediaId : String?
    public var presignedUrl : String?
    public var name : String = ""
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ttl = try? container.decode(Int.self, forKey: .ttl)
        thumbnailUrl = try? container.decode(String.self, forKey: .thumbnailUrl)
        thumbnailPresignedUrl = try? container.decode(String.self, forKey: .thumbnailPresignedUrl)
        mediaUrl = try? container.decode(String.self, forKey: .mediaUrl)
        mediaPresignedUrl = try? container.decode(String.self, forKey: .mediaPresignedUrl)
        mediaId = try? container.decode(String.self, forKey: .mediaId)
        presignedUrl = try? container.decode(String.self, forKey: .presignedUrl)
    }
    public init(mediaUrl : String,mediaId : String){
        self.mediaId = mediaId
        self.mediaId = mediaUrl
    }
}
