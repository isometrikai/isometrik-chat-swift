//
//  ISMAttachment.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 22/05/23.
//

import Foundation

struct ISMChat_Attachment : Codable{
    var attachmentType : Int?
    var extensions : String?
    var mediaId: Int?
    var mediaUrl  : String?
    var mimeType : String?
    var name : String?
    var size : Int?
    var thumbnailUrl : String?
    var latitude : Double?
    var longitude : Double?
    var title : String?
    var address : String?
    var caption : String?
    init(from decoder: Decoder) throws {
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
    init(attachmentType : Int? = nil,extensions : String? = nil,mediaId : Int? = nil,mediaUrl : String? = nil,mimeType : String? = nil,name : String? = nil,size : Int? = nil,thumbnailUrl : String? = nil,latitude : Double? = nil,longitude : Double? = nil,title : String? = nil,address : String? = nil,caption : String? = nil) {
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
