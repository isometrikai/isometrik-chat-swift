//
//  ISMChat_ConversationDB.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift


class ConversationDB: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var conversationId: String
    
    @Persisted var updatedAt :Double = 00
    @Persisted var unreadMessagesCount :Int = -1
    @Persisted var membersCount :Int = -1
    @Persisted var lastMessageSentAt :Int = -1
    @Persisted var createdAt :Double = 00
    
    @Persisted var mode :String = ""
    @Persisted var conversationTitle :String = ""
    @Persisted var conversationImageUrl :String = ""
    @Persisted var createdBy :String = ""
    @Persisted var createdByUserName :String = ""
    
    @Persisted var privateOneToOne :Bool = false
    @Persisted var messagingDisabled :Bool = false
    @Persisted var isGroup :Bool = false
    @Persisted var typing :Bool = false
    @Persisted var isDelete :Bool = false
    @Persisted var userIds :RealmSwift.List<String>
    
    @Persisted var opponentDetails :UserDB?
    @Persisted var config : ConfigDB?
    
    @Persisted var lastReadAt :RealmSwift.List<MessagesDB>
    
    @Persisted var lastMessageDetails :LastMessageDB?
    @Persisted var deletedMessage : Bool = false
    
    override class func primaryKey() -> String? {
        return "conversationId"
    }
}


class ConfigDB : Object, ObjectKeyIdentifiable{
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var typingEvents : Bool?
    @Persisted var readEvents : Bool?
    @Persisted var pushNotifications : Bool?
}
