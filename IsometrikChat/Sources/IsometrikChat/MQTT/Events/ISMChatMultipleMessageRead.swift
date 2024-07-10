//
//  MultipleMessageRead.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 27/04/23.
//

import Foundation


public struct ISMChatMultipleMessageRead : Codable{
    public let userProfileImageUrl : String?
    public let userName : String?
    public let userIdentifier : String?
    public let userId : String?
    public let sentAt : Double?
    public let numberOfMessages : Int?
    public let lastReadAt : Double?
    public let conversationId : String?
    public let action : String?
    public let messageId : String?
}
