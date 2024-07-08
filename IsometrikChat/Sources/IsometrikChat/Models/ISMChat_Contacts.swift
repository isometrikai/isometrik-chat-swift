//
//  ISMContacts.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 19/10/23.
//

import Foundation
import Contacts

struct ISMChat_Contacts: Identifiable {
    let id: UUID
    let contact: CNContact
    var selected : Bool = false
}


struct ISMChat_PhoneContact : Codable{
    var id : UUID
    var displayName : String?
    var phones : [ISMChat_Phone]?
    var imageUrl : String?
    var imageData : Data?
    init(id: UUID, displayName: String, phones: [ISMChat_Phone],imageUrl : String,imageData : Data) {
        self.id = id
        self.displayName = displayName
        self.phones = phones
        self.imageUrl = imageUrl
        self.imageData = imageData
    }
}


struct ISMChat_Phone : Codable{
    var number : String?
    init(number: String) {
        self.number = number
    }
}
