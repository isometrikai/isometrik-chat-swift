//
//  ISMChat_MetaDataDB.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift

class MetaDataDB : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var locationAddress : String?
    @Persisted var replyMessage : ReplyMessageDB?
    @Persisted var contacts : RealmSwift.List<ContactDB>
    @Persisted var captionMessage : String?
    @Persisted var isBroadCastMessage : Bool?
}


class ContactDB : Object, ObjectKeyIdentifiable {
    @Persisted var contactName : String?
    @Persisted var contactIdentifier : String?
    @Persisted var contactImageUrl : String?
}

class ReplyMessageDB : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var parentMessageId : String?
    @Persisted var parentMessageBody : String?
    @Persisted var parentMessageUserId : String?
    @Persisted var parentMessageUserName : String?
    @Persisted var parentMessageMessageType : String?
    @Persisted var parentMessageAttachmentUrl : String?
    @Persisted var parentMessageInitiator : Bool?
    @Persisted var parentMessagecaptionMessage : String?
}
