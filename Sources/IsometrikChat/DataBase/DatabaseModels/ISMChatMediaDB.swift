//
//  ISMChatMediaDB.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift

public class MediaDB : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: ObjectId
    
    @Persisted public var conversationId : String = ""
    @Persisted public var groupcastId : String = ""
    @Persisted public var attachmentType : Int = 0
    @Persisted public var extensions : String = ""
    @Persisted public var mediaId: String = ""
    @Persisted public var mediaUrl  : String = ""
    @Persisted public var mimeType : String = ""
    @Persisted public var name : String = ""
    @Persisted public var size : Int = 0
    @Persisted public var thumbnailUrl : String = ""
    @Persisted public var customType : String = ""
    @Persisted public var sentAt : Double = 0.0
    @Persisted public var messageId : String = ""
    @Persisted public var userName : String = ""
    @Persisted public var caption : String = ""
    @Persisted public var isDelete : Bool = false
}
