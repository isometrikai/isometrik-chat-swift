//
//  ISMChatLastMessageDB.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift


public class LastMessageDB : Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) public var id: ObjectId
    
    @Persisted public var sentAt : Double?
    @Persisted public var updatedAt : Double?
    @Persisted public var senderName : String?
    @Persisted public var senderIdentifier : String?
    @Persisted public var senderId : String?
    @Persisted public var conversationId : String?
    @Persisted public var body : String?
    @Persisted public var messageId : String?
    @Persisted public var customType : String?
    @Persisted public var action : String?
    @Persisted public var metaData : MetaDataDB?
    @Persisted public var metaDataJsonString : String?
    @Persisted public var deliveredTo : RealmSwift.List<MessageDeliveryStatusDB>
    @Persisted public var readBy : RealmSwift.List<MessageDeliveryStatusDB>
    @Persisted public var msgSyncStatus : String = ""
    @Persisted public var reactionType : String = ""
    @Persisted public var userId : String = ""
    @Persisted public var userIdentifier : String?
    @Persisted public var userName : String?
    @Persisted public var userProfileImageUrl : String?
    @Persisted public var members : RealmSwift.List<LastMessageMemberDB>
    @Persisted public var memberName : String = ""
    @Persisted public var memberId : String = ""
    @Persisted public var messageDeleted : Bool = false
    @Persisted public var initiatorName : String?
    @Persisted public var initiatorId : String?
    @Persisted public var initiatorIdentifier : String?
    @Persisted public var deletedMessage : Bool = false
    //callkit
    @Persisted public var meetingId : String?
    @Persisted public var missedByMembers : List<String>
    @Persisted public var callDurations : List<ISMMeetingDuration>
}

public class LastMessageMemberDB : Object, ObjectKeyIdentifiable{
    @Persisted public var memberProfileImageUrl : String?
    @Persisted public var memberName : String?
    @Persisted public var memberIdentifier : String?
    @Persisted public var memberId : String?
}

public class ISMMeetingDuration : Object, Identifiable{
    @Persisted public var memberId : String?
    @Persisted public var durationInMilliseconds : Double?
}

public class MessageDeliveryStatusDB : Object, ObjectKeyIdentifiable{
    @Persisted public var userId : String?
    @Persisted public var timestamp : Double?
}
