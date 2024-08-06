//
//  ISMChatConversationDB.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift


public class ConversationDB: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) public var conversationId: String
    
    @Persisted public var updatedAt :Double = 00
    @Persisted public var unreadMessagesCount :Int = -1
    @Persisted public var membersCount :Int = -1
    @Persisted public var lastMessageSentAt :Int = -1
    @Persisted public var createdAt :Double = 00
    
    @Persisted public var mode :String = ""
    @Persisted public var conversationTitle :String = ""
    @Persisted public var conversationImageUrl :String = ""
    @Persisted public var createdBy :String = ""
    @Persisted public var createdByUserName :String = ""
    
    @Persisted public var privateOneToOne :Bool = false
    @Persisted public var messagingDisabled :Bool = false
    @Persisted public var isGroup :Bool = false
    @Persisted public var typing :Bool = false
    @Persisted public var isDelete :Bool = false
    @Persisted public var userIds :RealmSwift.List<String>
    
    @Persisted public var opponentDetails :UserDB?
    @Persisted public var config : ConfigDB?
    
    @Persisted public var lastReadAt :RealmSwift.List<MessagesDB>
    
    @Persisted public var lastMessageDetails :LastMessageDB?
    @Persisted public var deletedMessage : Bool = false
    @Persisted var metaData : ConversationMetaData?
    
    public override class func primaryKey() -> String? {
        return "conversationId"
    }
}

class ConversationMetaData : Object, ObjectKeyIdentifiable {
    @Persisted var chatStatus : String?
    @Persisted var profileType : String?
}


public class ConfigDB : Object, ObjectKeyIdentifiable{
    @Persisted(primaryKey: true) public var id: ObjectId
    
    @Persisted public var typingEvents : Bool?
    @Persisted public var readEvents : Bool?
    @Persisted public var pushNotifications : Bool?
}
