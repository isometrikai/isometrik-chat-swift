//
//  ISMContacts.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 19/10/23.
//

import Foundation
import Contacts

public struct ISMChat_Contacts: Identifiable {
    public let id: UUID
    public let contact: CNContact
    public var selected : Bool = false
}


public struct ISMChat_PhoneContact : Codable{
    public var id : UUID
    public var displayName : String?
    public var phones : [ISMChat_Phone]?
    public var imageUrl : String?
    public var imageData : Data?
    public init(id: UUID, displayName: String, phones: [ISMChat_Phone],imageUrl : String,imageData : Data) {
        self.id = id
        self.displayName = displayName
        self.phones = phones
        self.imageUrl = imageUrl
        self.imageData = imageData
    }
}


public struct ISMChat_Phone : Codable{
    public var number : String?
    public init(number: String) {
        self.number = number
    }
}
