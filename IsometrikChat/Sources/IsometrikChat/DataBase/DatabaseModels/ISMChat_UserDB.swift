//
//  ISMChat_UserDB.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift

class UserDB : Object, ObjectKeyIdentifiable{

    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var userProfileImageUrl : String?
    @Persisted var userName : String?
    @Persisted var userIdentifier : String?
    @Persisted var online : Bool?
    @Persisted var userId : String?
    @Persisted var lastSeen : Double?
   
}
