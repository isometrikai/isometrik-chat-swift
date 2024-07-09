//
//  MessageDelivered.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 26/04/23.
//

import Foundation

public struct ISMChat_MessageDelivered: Codable {
    public let sentAt : Double?
    public let messageId: String?
    public let body : String?
    public let senderIdentifier : String?
    public let conversationId : String?
    public let updatedAt : Double?
    public let senderName : String?
    public let senderId : String?
    public let metaData : ISMChat_MetaData?
    public let customType : String?
    public let userProfileImageUrl : String?
    public let userName : String?
    public let userIdentifier : String?
    public let userId : String?
    public let privateOneToOne : Bool?
    public var messageIds : [String]? = []
    public let action : String?
    public let attachments : [ISMChat_Attachment]?
    public let parentMessageId : String?
    public let senderInfo : ISMChat_SenderInfo?
    public let notificationBody : String?
    public let memberName : String?
    public let memberProfileImageUrl : String?
    public let memberIdentifier : String?
    public let memberId : String?
    public let initiatorProfileImageUrl : String?
    public let initiatorName: String?
    public let initiatorIdentifier: String?
    public let initiatorId: String?
    public let conversationTitle : String?
    public let conversationImageUrl : String?
    public let members : [ISMChat_Members]?
    public let details : ISMChat_UpdateMessageDetail?
    public let mentionedUsers : [ISMChat_MentionedUser]?
    public let reactions : [String : [String]]?
    public let meetingId : String?
}


public struct ISMChat_SenderInfo : Codable{
    let userId : String?
    let senderName : String?
}

public struct ISMChat_UpdateMessageDetail : Codable{
    public let body : String?
    public let searchableTags : [String]?
}

public struct ISMChat_Members : Codable{
    public var memberProfileImageUrl : String?
    public var memberName : String?
    public var memberIdentifier: String?
    public var memberId : String?
}
