//
//  ISMChat_AttachmentsDB.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift

class AttachmentDB : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var attachmentType : Int = 0
    @Persisted var extensions : String = ""
    @Persisted var mediaId: Int = 0
    @Persisted var mediaUrl  : String = ""
    @Persisted var mimeType : String = ""
    @Persisted var name : String = ""
    @Persisted var size : Int = 0
    @Persisted var thumbnailUrl : String = ""
    //Location
    @Persisted var latitude : Double = 0.0
    @Persisted var longitude : Double = 0.0
    @Persisted var title : String = ""
    @Persisted var address : String = ""
    
}
