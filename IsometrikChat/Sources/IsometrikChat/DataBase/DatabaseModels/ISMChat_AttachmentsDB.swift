//
//  ISMChat_AttachmentsDB.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift

public class AttachmentDB : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: ObjectId
    
    @Persisted public var attachmentType : Int = 0
    @Persisted public var extensions : String = ""
    @Persisted public var mediaId: Int = 0
    @Persisted public var mediaUrl  : String = ""
    @Persisted public var mimeType : String = ""
    @Persisted public var name : String = ""
    @Persisted public var size : Int = 0
    @Persisted public var thumbnailUrl : String = ""
    //Location
    @Persisted public var latitude : Double = 0.0
    @Persisted public var longitude : Double = 0.0
    @Persisted public var title : String = ""
    @Persisted public var address : String = ""
    
}
