//
//  MessageDelivered.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 26/04/23.
//

import Foundation

public struct ISMChat_MessageDelivered: Codable {
    let sentAt : Double?
    let messageId: String?
    let body : String?
    let senderIdentifier : String?
    let conversationId : String?
    let updatedAt : Double?
    let senderName : String?
    let senderId : String?
    let metaData : ISMChat_MetaData?
    let customType : String?
    let userProfileImageUrl : String?
    let userName : String?
    let userIdentifier : String?
    let userId : String?
    let privateOneToOne : Bool?
    var messageIds : [String]? = []
    let action : String?
    let attachments : [ISMChat_Attachment]?
    let parentMessageId : String?
    let senderInfo : ISMChat_SenderInfo?
    let notificationBody : String?
    let memberName : String?
    let memberProfileImageUrl : String?
    let memberIdentifier : String?
    let memberId : String?
    let initiatorProfileImageUrl : String?
    let initiatorName: String?
    let initiatorIdentifier: String?
    let initiatorId: String?
    let conversationTitle : String?
    let conversationImageUrl : String?
    let members : [ISMChat_Members]?
    let details : ISMChat_UpdateMessageDetail?
    let mentionedUsers : [ISMChat_MentionedUser]?
    let reactions : [String : [String]]?
    let meetingId : String?
}


public struct ISMChat_SenderInfo : Codable{
    let userId : String?
    let senderName : String?
}

public struct ISMChat_UpdateMessageDetail : Codable{
    let body : String?
    let searchableTags : [String]?
}

struct ISMChat_Members : Codable{
    var memberProfileImageUrl : String?
    var memberName : String?
    var memberIdentifier: String?
    var memberId : String?
}
