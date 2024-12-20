//
//  ISMChatUserDB.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift

public class UserDB : Object, ObjectKeyIdentifiable{

    @Persisted(primaryKey: true) public var id: ObjectId
    
    @Persisted public var userProfileImageUrl : String?
    @Persisted public var userName : String?
    @Persisted public var userIdentifier : String?
    @Persisted public var online : Bool?
    @Persisted public var userId : String?
    @Persisted public var lastSeen : Double?
    @Persisted public var metaData : UserMetaDataDB?
}

public class UserMetaDataDB : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: ObjectId
    @Persisted public var userId : String?
    @Persisted public var userType : Int? //1 - normal user, 9 -  business user
    @Persisted public var isStarUser : Bool? //check if usertype == 1 if for both normal user and influencer
    @Persisted public var userTypeString : String?
}
