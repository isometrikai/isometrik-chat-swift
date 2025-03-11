//
//  ISMChatMediaModel.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 26/02/25.
//
import Foundation
import SwiftData

@Model
public class ISMChatMediaDB{
    @Attribute(.unique) public var id: UUID = UUID()
    
     public var conversationId : String = ""
     public var groupcastId : String = ""
     public var attachmentType : Int = 0
     public var extensions : String = ""
     public var mediaId: String = ""
     public var mediaUrl  : String = ""
     public var mimeType : String = ""
     public var name : String = ""
     public var size : Int = 0
     public var thumbnailUrl : String = ""
     public var customType : String = ""
     public var sentAt : Double = 0.0
     public var messageId : String = ""
     public var userName : String = ""
     public var caption : String = ""
     public var isDelete : Bool = false
    
    public init(conversationId: String, groupcastId: String, attachmentType: Int, extensions: String, mediaId: String, mediaUrl: String, mimeType: String, name: String, size: Int, thumbnailUrl: String, customType: String, sentAt: Double, messageId: String, userName: String, caption: String, isDelete: Bool) {
        self.conversationId = conversationId
        self.groupcastId = groupcastId
        self.attachmentType = attachmentType
        self.extensions = extensions
        self.mediaId = mediaId
        self.mediaUrl = mediaUrl
        self.mimeType = mimeType
        self.name = name
        self.size = size
        self.thumbnailUrl = thumbnailUrl
        self.customType = customType
        self.sentAt = sentAt
        self.messageId = messageId
        self.userName = userName
        self.caption = caption
        self.isDelete = isDelete
    }
}
