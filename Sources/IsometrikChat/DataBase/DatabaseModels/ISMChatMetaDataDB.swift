//
//  ISMChatMetaDataDB.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift

public class MetaDataDB : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: ObjectId
    @Persisted public var locationAddress : String?
    @Persisted public var replyMessage : ReplyMessageDB?
    @Persisted public var contacts : RealmSwift.List<ContactDB>
    @Persisted public var captionMessage : String?
    @Persisted public var isBroadCastMessage : Bool?
    @Persisted public var post : PostDB?
}

public class PostDB: Object, ObjectKeyIdentifiable {
    @Persisted public var postId : String?
    @Persisted public var postUrl : String?
}


public class ContactDB : Object, ObjectKeyIdentifiable {
    @Persisted public var contactName : String?
    @Persisted public var contactIdentifier : String?
    @Persisted public var contactImageUrl : String?
}

public class ReplyMessageDB : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: ObjectId
    @Persisted public var parentMessageId : String?
    @Persisted public var parentMessageBody : String?
    @Persisted public var parentMessageUserId : String?
    @Persisted public var parentMessageUserName : String?
    @Persisted public var parentMessageMessageType : String?
    @Persisted public var parentMessageAttachmentUrl : String?
    @Persisted public var parentMessageInitiator : Bool?
    @Persisted public var parentMessagecaptionMessage : String?
}
