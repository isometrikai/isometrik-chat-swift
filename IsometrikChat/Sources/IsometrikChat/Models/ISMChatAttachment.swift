//
//  ISMAttachment.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 22/05/23.
//

import Foundation

public struct ISMChatAttachment : Codable{
    public var attachmentType : Int?
    public var extensions : String?
    public var mediaId: Int?
    public var mediaUrl  : String?
    public var mimeType : String?
    public var name : String?
    public var size : Int?
    public var thumbnailUrl : String?
    public var latitude : Double?
    public var longitude : Double?
    public var title : String?
    public var address : String?
    public var caption : String?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        attachmentType = try? container.decode(Int.self, forKey: .attachmentType)
        extensions = try? container.decode(String.self, forKey: .extensions)
        mediaId = try? container.decode(Int.self, forKey: .mediaId)
        mediaUrl = try? container.decode(String.self, forKey: .mediaUrl)
        mimeType = try? container.decode(String.self, forKey: .mimeType)
        name = try? container.decode(String.self, forKey: .name)
        size = try? container.decode(Int.self, forKey: .size)
        thumbnailUrl = try? container.decode(String.self, forKey: .thumbnailUrl)
        latitude = try? container.decode(Double.self, forKey: .latitude)
        longitude = try? container.decode(Double.self, forKey: .longitude)
        title = try? container.decode(String.self, forKey: .title)
        address = try? container.decode(String.self, forKey: .address)
        caption = try? container.decode(String.self, forKey: .caption)
    }
    public init(attachmentType : Int? = nil,extensions : String? = nil,mediaId : Int? = nil,mediaUrl : String? = nil,mimeType : String? = nil,name : String? = nil,size : Int? = nil,thumbnailUrl : String? = nil,latitude : Double? = nil,longitude : Double? = nil,title : String? = nil,address : String? = nil,caption : String? = nil) {
        self.attachmentType = attachmentType
        self.extensions = extensions
        self.mediaId = mediaId
        self.mediaUrl  = mediaUrl
        self.mimeType = mimeType
        self.name = name
        self.size = size
        self.thumbnailUrl = thumbnailUrl
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
        self.address = address
        self.caption = caption
    }
}
