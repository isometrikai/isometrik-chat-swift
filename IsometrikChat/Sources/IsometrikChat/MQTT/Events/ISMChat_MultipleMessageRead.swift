//
//  MultipleMessageRead.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 27/04/23.
//

import Foundation


struct ISMChat_MultipleMessageRead : Codable{
    let userProfileImageUrl : String?
    let userName : String?
    let userIdentifier : String?
    let userId : String?
    let sentAt : Double?
    let numberOfMessages : Int?
    let lastReadAt : Double?
    let conversationId : String?
    let action : String?
    let messageId : String?
}
