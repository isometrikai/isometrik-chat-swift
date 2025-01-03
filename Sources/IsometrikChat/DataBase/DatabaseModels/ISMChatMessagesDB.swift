//
//  ISMChatMessagesDB.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift

public class MessagesDB: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) public var id: ObjectId
    
    @Persisted public var sentAt : Double = 0
    @Persisted public var senderInfo : UserDB?
    @Persisted public var body : String = ""
    @Persisted public var userName : String = ""
    @Persisted public var userIdentifier : String = ""
    @Persisted public var userId : String = ""
    @Persisted public var userProfileImageUrl : String = ""
    @Persisted public var messageId : String = ""
    @Persisted public var mentionedUsers : RealmSwift.List<MentionedUserDB>
    @Persisted public var deliveredToAll : Bool = false
    @Persisted public var readByAll : Bool = false
    @Persisted public var customType : String = ""
    @Persisted public var action : String = ""
    @Persisted public var readBy : RealmSwift.List<MessageDeliveryStatusDB>
    @Persisted public var deliveredTo  : RealmSwift.List<MessageDeliveryStatusDB>
    @Persisted public var messageType : Int = -1
    @Persisted public var parentMessageId : String = ""
    @Persisted public var metaData : MetaDataDB?
    @Persisted public var metaDataJsonString : String?
    @Persisted public var attachments : RealmSwift.List<AttachmentDB>
    @Persisted public var initiatorIdentifier : String = ""
    @Persisted public var initiatorId : String = ""
    @Persisted public var initiatorName : String = ""
    @Persisted public var conversationId : String = ""
    @Persisted public var msgSyncStatus : String = ""
    @Persisted public var placeName : String = ""
    @Persisted public var reactionType : String = ""
    @Persisted public var reactionsCount : Int?
    @Persisted public var isDelete : Bool = false
    @Persisted public var members : RealmSwift.List<LastMessageMemberDB>
    @Persisted public var deletedMessage : Bool = false
    @Persisted public var memberName : String = ""
    @Persisted public var memberId : String = ""
    @Persisted public var memberIdentifier : String = ""
    @Persisted public var messageUpdated : Bool = false
    @Persisted public var reactions : List<ReactionDB>
    @Persisted public var missedByMembers : List<String>
    @Persisted public var meetingId  : String?
    @Persisted public var callDurations : List<ISMMeetingDuration>
    @Persisted public var audioOnly : Bool = false
    @Persisted public var autoTerminate : Bool = false
    @Persisted public var config : ISMMeetingConfig?
    @Persisted public var groupcastId : String?
}

public class ReactionDB: Object, Identifiable{
    @Persisted public var id = UUID()
    @Persisted public var reactionType: String = ""
    @Persisted public var users: List<String>
}

public class MentionedUserDB : Object, ObjectKeyIdentifiable{
    @Persisted public var wordCount : Int?
    @Persisted public var userId : String?
    @Persisted public var order : Int?
}

public class ISMMeetingConfig : Object, Identifiable{
    @Persisted public var pushNotifications: Bool?
}
