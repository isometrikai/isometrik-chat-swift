//
//  ISMChatBroadCastListDB.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift

class BroadCastListDB: Object, ObjectKeyIdentifiable {
    @Persisted var groupcastId: String?
    @Persisted var membersCount : Int?
    @Persisted var groupcastTitle : String?
    @Persisted var groupcastImageUrl : String?
    @Persisted var customType : String?
    @Persisted var createdBy : String?
    @Persisted var createdAt : Double?
    @Persisted var metaData : BroadCastMetaDataDB?
    @Persisted var isDelete : Bool = false
}

class BroadCastMetaDataDB : Object, ObjectKeyIdentifiable {
    @Persisted var membersDetail : RealmSwift.List<BroadCastMemberDetailDB>
}

class BroadCastMemberDetailDB : Object, ObjectKeyIdentifiable {
    @Persisted var memberId : String?
    @Persisted var memberName : String?
}
