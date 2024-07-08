//
//  ISMChat_LastMessageDB.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift


class LastMessageDB : Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var sentAt : Double?
    @Persisted var updatedAt : Double?
    @Persisted var senderName : String?
    @Persisted var senderIdentifier : String?
    @Persisted var senderId : String?
    @Persisted var conversationId : String?
    @Persisted var body : String?
    @Persisted var messageId : String?
    @Persisted var customType : String?
    @Persisted var action : String?
    @Persisted var metaData : MetaDataDB?
    @Persisted var deliveredTo : RealmSwift.List<MessageDeliveryStatusDB>
    @Persisted var readBy : RealmSwift.List<MessageDeliveryStatusDB>
    @Persisted var msgSyncStatus : String = ""
    @Persisted var reactionType : String = ""
    @Persisted var userId : String = ""
    @Persisted var userIdentifier : String?
    @Persisted var userName : String?
    @Persisted var userProfileImageUrl : String?
    @Persisted var members : RealmSwift.List<LastMessageMemberDB>
    @Persisted var memberName : String = ""
    @Persisted var memberId : String = ""
    @Persisted var messageDeleted : Bool = false
    @Persisted var initiatorName : String?
    @Persisted var initiatorId : String?
    @Persisted var initiatorIdentifier : String?
    @Persisted var deletedMessage : Bool = false
    //callkit
    @Persisted var meetingId : String?
    @Persisted var missedByMembers : List<String>
    @Persisted var callDurations : List<ISMMeetingDuration>
}

class LastMessageMemberDB : Object, ObjectKeyIdentifiable{
    @Persisted var memberProfileImageUrl : String?
    @Persisted var memberName : String?
    @Persisted var memberIdentifier : String?
    @Persisted var memberId : String?
}

class ISMMeetingDuration : Object, Identifiable{
    @Persisted var memberId : String?
    @Persisted var durationInMilliseconds : Double?
}

class MessageDeliveryStatusDB : Object, ObjectKeyIdentifiable{
    @Persisted var userId : String?
    @Persisted var timestamp : Double?
}
