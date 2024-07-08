//
//  ISMChat_MediaDB.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift

class MediaDB : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var conversationId : String = ""
    @Persisted var groupcastId : String = ""
    @Persisted var attachmentType : Int = 0
    @Persisted var extensions : String = ""
    @Persisted var mediaId: Int = 0
    @Persisted var mediaUrl  : String = ""
    @Persisted var mimeType : String = ""
    @Persisted var name : String = ""
    @Persisted var size : Int = 0
    @Persisted var thumbnailUrl : String = ""
    @Persisted var customType : String = ""
    @Persisted var sentAt : Double = 0.0
    @Persisted var messageId : String = ""
    @Persisted var userName : String = ""
    @Persisted var caption : String = ""
}
