//
//  ISMChatUserDB.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 26/02/25.
//

import Foundation
import SwiftData

@Model
public class ISMChatAttachmentDB {
    @Attribute(.unique) public var id: UUID = UUID()
    public var attachmentType : Int = 0
    public var extensions : String = ""
    public var mediaId: String = ""
    public var mediaUrl  : String = ""
    public var mimeType : String = ""
    public var name : String = ""
    public var size : Int = 0
    public var thumbnailUrl : String = ""
    //Location
    public var latitude : Double = 0.0
    public var longitude : Double = 0.0
    public var title : String = ""
    public var address : String = ""
    public var caption : String = ""
    public init(attachmentType: Int? = nil, extensions: String? = nil, mediaId: String? = nil, mediaUrl: String? = nil, mimeType: String? = nil, name: String? = nil, size: Int? = nil, thumbnailUrl: String? = nil, latitude: Double? = nil, longitude: Double? = nil, title: String? = nil, address: String? = nil, caption: String? = nil) {
        self.attachmentType = attachmentType ?? 0
        self.extensions = extensions ?? ""
        self.mediaId = mediaId ?? ""
        self.mediaUrl = mediaUrl ?? ""
        self.mimeType = mimeType ?? ""
        self.name = name ?? ""
        self.size = size ?? 0
        self.thumbnailUrl = thumbnailUrl ?? ""
        self.latitude = latitude ?? 0
        self.longitude = longitude ?? 0
        self.title = title ?? ""
        self.address = address ?? ""
        self.caption = caption ?? ""
    }
}
