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
    @Persisted public var product : ProductDB?
    
    
    // Product Link
    @Persisted public var storeName: String?
    @Persisted public var productName: String?
    @Persisted public var bestPrice: Double?
    @Persisted public var scratchPrice: Double?
    @Persisted public var url: String?
    @Persisted public var parentProductId: String?
    @Persisted public var childProductId: String?
    @Persisted public var entityType: String?
    @Persisted public var productImage: String?
    
    //social link
    @Persisted public var thumbnailUrl : String?
    @Persisted public var Description : String?
    @Persisted public var isVideoPost : Bool?
    @Persisted public var socialPostId : String?
}

public class PDPImageDB: Object, ObjectKeyIdentifiable {
    @Persisted public var small: String?
    @Persisted public var medium: String?
    @Persisted public var large: String?
    @Persisted public var extraLarge: String?
    @Persisted public var filePath: String?
    @Persisted public var altText: String?
}


public class PostDB: Object, ObjectKeyIdentifiable {
    @Persisted public var postId : String?
    @Persisted public var postUrl : String?
}

public class ProductDB: Object, ObjectKeyIdentifiable {
    @Persisted public var productId : String?
    @Persisted public var productUrl : String?
    @Persisted public var productCategoryId : String?
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
