//
//  ISMChat_MessagesDB.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift

class MessagesDB: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var sentAt : Double = 0
    @Persisted var senderInfo : UserDB?
    @Persisted var body : String = ""
    @Persisted var userName : String = ""
    @Persisted var userIdentifier : String = ""
    @Persisted var userId : String = ""
    @Persisted var userProfileImageUrl : String = ""
    @Persisted var messageId : String = ""
    @Persisted var mentionedUsers : RealmSwift.List<MentionedUserDB>
    @Persisted var deliveredToAll : Bool = false
    @Persisted var readByAll : Bool = false
    @Persisted var customType : String = ""
    @Persisted var action : String = ""
    @Persisted var readBy : RealmSwift.List<MessageDeliveryStatusDB>
    @Persisted var deliveredTo  : RealmSwift.List<MessageDeliveryStatusDB>
    @Persisted var messageType : Int = -1
    @Persisted var parentMessageId : String = ""
    @Persisted var metaData : MetaDataDB?
    @Persisted var attachments : RealmSwift.List<AttachmentDB>
    @Persisted var initiatorIdentifier : String = ""
    @Persisted var initiatorId : String = ""
    @Persisted var initiatorName : String = ""
    @Persisted var conversationId : String = ""
    @Persisted var msgSyncStatus : String = ""
    @Persisted var placeName : String = ""
    @Persisted var reactionType : String = ""
    @Persisted var reactionsCount : Int?
    @Persisted var isDelete : Bool = false
    @Persisted var members : RealmSwift.List<LastMessageMemberDB>
    @Persisted var deletedMessage : Bool = false
    @Persisted var memberName : String = ""
    @Persisted var memberId : String = ""
    @Persisted var memberIdentifier : String = ""
    @Persisted var messageUpdated : Bool = false
    @Persisted var reactions : List<ReactionDB>
    @Persisted var missedByMembers : List<String>
    @Persisted var meetingId  : String?
    @Persisted var callDurations : List<ISMMeetingDuration>
    @Persisted var audioOnly : Bool = false
    @Persisted var autoTerminate : Bool = false
    @Persisted var config : ISMMeetingConfig?
    @Persisted var groupcastId : String?
}

class ReactionDB: Object, Identifiable{
    @Persisted var id = UUID()
    @Persisted var reactionType: String = ""
    @Persisted var users: List<String>
}

class MentionedUserDB : Object, ObjectKeyIdentifiable{
    @Persisted var wordCount : Int?
    @Persisted var userId : String?
    @Persisted var order : Int?
}

class ISMMeetingConfig : Object, Identifiable{
    @Persisted var pushNotifications: Bool?
}
