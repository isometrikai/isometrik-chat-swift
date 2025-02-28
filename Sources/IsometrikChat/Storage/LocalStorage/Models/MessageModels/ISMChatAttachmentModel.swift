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
    public init(id: UUID, attachmentType: Int, extensions: String, mediaId: String, mediaUrl: String, mimeType: String, name: String, size: Int, thumbnailUrl: String, latitude: Double, longitude: Double, title: String, address: String, caption: String) {
        self.id = id
        self.attachmentType = attachmentType
        self.extensions = extensions
        self.mediaId = mediaId
        self.mediaUrl = mediaUrl
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
