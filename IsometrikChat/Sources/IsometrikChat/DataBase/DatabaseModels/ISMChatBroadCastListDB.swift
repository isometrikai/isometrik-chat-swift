//
//  ISMChatBroadCastListDB.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift

public class BroadCastListDB: Object, ObjectKeyIdentifiable {
    @Persisted public var groupcastId: String?
    @Persisted public var membersCount : Int?
    @Persisted public var groupcastTitle : String?
    @Persisted public var groupcastImageUrl : String?
    @Persisted public var customType : String?
    @Persisted public var createdBy : String?
    @Persisted public var createdAt : Double?
    @Persisted public var metaData : BroadCastMetaDataDB?
    @Persisted public var isDelete : Bool = false
}

public class BroadCastMetaDataDB : Object, ObjectKeyIdentifiable {
    @Persisted public var membersDetail : RealmSwift.List<BroadCastMemberDetailDB>
}

public class BroadCastMemberDetailDB : Object, ObjectKeyIdentifiable {
    @Persisted public var memberId : String?
    @Persisted public var memberName : String?
}
