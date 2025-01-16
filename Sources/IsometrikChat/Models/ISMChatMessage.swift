//
//  ISMMessage.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 09/03/23.
//

import Foundation
import ISMSwiftCall

public struct ISMChatMessages : Codable{
    public var messages : [ISMChatMessage]? = []
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messages = try? container.decode([ISMChatMessage].self, forKey: .messages)
    }
    public init(){
        
    }
}

public struct ISMChatMessage : Codable,Identifiable{
    public let id = UUID()
    public var sentAt : Double?
    public var senderInfo : ISMChatUser?
    public var body : String?
    public var messageId : String?
    public var mentionedUsers : [ISMChatMentionedUser]?
    public var deliveredToAll : Bool?
    public var readByAll : Bool?
    public var customType : String?
    public var action : String?
    public var readBy : [ISMChatUserStatus]?
    public var deliveredTo  : [ISMChatUserStatus]?
    public var messageType : Int?
    public var parentMessageId : String?
    public var metaData : ISMChatMetaData?
    public var metaDataJsonString : String?
    public var attachments : [ISMChatAttachment]?
    public var initiatorIdentifier : String?
    public var initiatorId : String?
    public var initiatorName : String?
    public var conversationId : String?
    public var groupcastId : String?
    public var userName : String?
    public var userIdentifier : String?
    public var userId : String?
    public var members : [ISMChatMemberAdded]?
    public var memberName : String?
    public var memberId : String?
    public var memberIdentifier : String?
    public var messageUpdated : Bool?
    public var reactions : [String: [String]]?
    //callkit params
    public var missedByMembers : [String]?
    public var meetingId : String?
    public var callDurations : [ISMCallMeetingDuration]?
    public var audioOnly : Bool?
    public var autoTerminate : Bool?
    public var config : ISMCallConfig?
    public var details : ISMChatUpdateMessageDetail?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        senderInfo = try? container.decode(ISMChatUser.self, forKey: .senderInfo)
        body = try? container.decode(String.self, forKey: .body)
        sentAt = try? container.decode(Double.self, forKey: .sentAt)
        messageId = try? container.decode(String.self, forKey: .messageId)
        mentionedUsers = try? container.decode([ISMChatMentionedUser].self, forKey: .mentionedUsers)
        deliveredToAll = try? container.decode(Bool.self, forKey: .deliveredToAll)
        readByAll = try? container.decode(Bool.self, forKey: .readByAll)
        customType = try? container.decode(String.self, forKey: .customType)
        action = try? container.decode(String.self, forKey: .action)
        readBy = try? container.decode([ISMChatUserStatus].self, forKey: .readBy)
        deliveredTo = try? container.decode([ISMChatUserStatus].self, forKey: .deliveredTo)
        messageType = try? container.decode(Int.self, forKey: .messageType)
        parentMessageId = try? container.decode(String.self, forKey: .parentMessageId)
        // Extract raw JSON string for metaData
        if let rawMetaData = try? container.decodeIfPresent(AnyCodable.self, forKey: .metaData) {
            let encoder = JSONEncoder()
            if let rawData = try? encoder.encode(rawMetaData),
               let jsonString = String(data: rawData, encoding: .utf8) {
                metaDataJsonString = jsonString
            }
        } else {
            metaDataJsonString = nil
        }
        metaData = try? container.decodeIfPresent(ISMChatMetaData.self, forKey: .metaData)
        attachments = try? container.decode([ISMChatAttachment].self, forKey: .attachments)
        initiatorIdentifier = try? container.decode(String.self, forKey: .initiatorIdentifier)
        initiatorId  = try? container.decode(String.self, forKey: .initiatorId)
        initiatorName  = try? container.decode(String.self, forKey: .initiatorName)
        conversationId = try? container.decode(String.self, forKey: .conversationId)
        groupcastId = try? container.decode(String.self, forKey: .groupcastId)
        userName = try? container.decode(String.self, forKey: .userName)
        userId = try? container.decode(String.self, forKey: .userId)
        userIdentifier = try? container.decode(String.self, forKey: .userIdentifier)
        members = try? container.decode([ISMChatMemberAdded].self, forKey: .members)
        memberName = try? container.decode(String.self, forKey: .memberName)
        memberId = try? container.decode(String.self, forKey: .memberId)
        memberIdentifier = try? container.decode(String.self, forKey: .memberIdentifier)
        messageUpdated = try? container.decode(Bool.self, forKey: .messageUpdated)
        reactions = try? container.decode([String: [String]].self, forKey: .reactions)
        
        missedByMembers = try? container.decode([String].self, forKey: .missedByMembers)
        meetingId  = try? container.decode(String.self, forKey: .meetingId)
        callDurations  = try? container.decode([ISMCallMeetingDuration].self, forKey: .callDurations)
        audioOnly  = try? container.decode(Bool.self, forKey: .audioOnly)
        autoTerminate  = try? container.decode(Bool.self, forKey: .autoTerminate)
        config  = try? container.decode(ISMCallConfig.self, forKey: .config)
        details  = try? container.decode(ISMChatUpdateMessageDetail.self, forKey: .details)
    }
    public init(sentAt : Double? = nil, body : String? = nil,messageId : String? = nil,mentionedUsers : [ISMChatMentionedUser]? = nil,metaData : ISMChatMetaData? = nil,metaDataJsonString : String? = nil,customType : String? = nil,initiatorIdentifier : String? = nil,action : String? = nil,attachment : [ISMChatAttachment]? = nil,conversationId : String? = nil,userId : String? = nil,userName : String? = nil,initiatorId : String? = nil,initiatorName : String? = nil,memberName : String? = nil,memberId : String? = nil, memberIdentifier : String? = nil,senderInfo : ISMChatUser? = nil,members : [ISMChatMemberAdded]? = nil,messageUpdated : Bool? = nil,reactions : [String: [String]]? = nil,missedByMembers : [String]? = nil,meetingId : String? = nil,callDurations : [ISMCallMeetingDuration]? = nil,audioOnly : Bool? = false,autoTerminate : Bool? = nil,config : ISMCallConfig? = nil,messageType : Int? = nil,details : ISMChatUpdateMessageDetail? = nil){
        self.sentAt = sentAt
        self.body = body
        self.messageId = messageId
        self.mentionedUsers = mentionedUsers
        self.metaData = metaData
        self.metaDataJsonString = metaDataJsonString
        self.customType = customType
        self.action = action
        self.initiatorIdentifier = initiatorIdentifier
        self.attachments = attachment
        self.conversationId = conversationId
        self.userId = userId
        self.userName = userName
        self.initiatorId = initiatorId
        self.initiatorName = initiatorName
        self.memberName = memberName
        self.memberId = memberId
        self.memberIdentifier = memberIdentifier
        self.senderInfo = senderInfo
        self.members = members
        self.messageUpdated = messageUpdated
        self.reactions = reactions
        self.missedByMembers = missedByMembers
        self.meetingId  = meetingId
        self.callDurations  = callDurations
        self.audioOnly  = audioOnly
        self.autoTerminate  = autoTerminate
        self.config  = config
        self.messageType = messageType
        self.details = details
    }
    public init(){
        
    }
}

public struct ISMChatUserStatus : Codable{
    var userId : String?
    var timestamp : Double?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try? container.decode(String.self, forKey: .userId)
        timestamp = try? container.decode(Double.self, forKey: .timestamp)
    }
}

public struct ISMChatMentionedUser : Codable {
    public var wordCount : Int?
    public var userId : String?
    public var order : Int?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        wordCount = try? container.decode(Int.self, forKey: .wordCount)
        userId = try? container.decode(String.self, forKey: .userId)
        order = try? container.decode(Int.self, forKey: .order)
    }
    public init(wordCount : Int? = nil,userId : String? = nil,order : Int? = nil){
        self.wordCount = wordCount
        self.userId = userId
        self.order = order
    }
}

//public struct ISMCallConfig: Codable {
//    let pushNotifications: Bool
//}

public struct ISMChatContactMetaData : Codable{
    public var contactName : String?
    public var contactIdentifier : String?
    public var contactImageUrl : String?
    public var contactImageData : Data?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        contactName = try? container.decode(String.self, forKey: .contactName)
        contactIdentifier = try? container.decode(String.self, forKey: .contactIdentifier)
        contactImageUrl = try? container.decode(String.self, forKey: .contactImageUrl)
        contactImageData = try? container.decode(Data.self, forKey: .contactImageData)
    }
    public init(contactName: String? = nil, contactIdentifier: String? = nil,contactImageUrl : String? = nil,contactImageData : Data? = nil){
        self.contactName = contactName
        self.contactIdentifier = contactIdentifier
        self.contactImageUrl = contactImageUrl
        self.contactImageData = contactImageData
    }
}

public struct ISMChatReplyMessageMetaData : Codable{
    public var parentMessageId : String?
    public var parentMessageBody : String?
    public var parentMessageUserId : String?
    public var parentMessageUserName : String?
    public var parentMessageMessageType : String?
    public var parentMessageAttachmentUrl : String?
    public var parentMessageInitiator : Bool?
    public var parentMessagecaptionMessage : String?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        parentMessageId = try? container.decode(String.self, forKey: .parentMessageId)
        parentMessageBody = try? container.decode(String.self, forKey: .parentMessageBody)
        parentMessageUserId = try? container.decode(String.self, forKey: .parentMessageUserId)
        parentMessageUserName = try? container.decode(String.self, forKey: .parentMessageUserName)
        parentMessageMessageType = try? container.decode(String.self, forKey: .parentMessageMessageType)
        parentMessageAttachmentUrl = try? container.decode(String.self, forKey: .parentMessageAttachmentUrl)
        parentMessageInitiator = try? container.decode(Bool.self, forKey: .parentMessageInitiator)
        parentMessagecaptionMessage = try? container.decode(String.self, forKey: .parentMessagecaptionMessage)
    }
    public init(parentMessageId : String? = nil, parentMessageBody : String? = nil, parentMessageUserId : String? = nil, parentMessageUserName : String? = nil, parentMessageMessageType : String? = nil, parentMessageAttachmentUrl : String? = nil, parentMessageInitiator : Bool? = nil,parentMessagecaptionMessage : String? = nil){
        self.parentMessageId = parentMessageId
        self.parentMessageBody = parentMessageBody
        self.parentMessageUserId = parentMessageUserId
        self.parentMessageUserName = parentMessageUserName
        self.parentMessageMessageType = parentMessageMessageType
        self.parentMessageAttachmentUrl = parentMessageAttachmentUrl
        self.parentMessageInitiator = parentMessageInitiator
        self.parentMessagecaptionMessage = parentMessagecaptionMessage
    }
}

public struct ISMChatMetaData: Codable {
    public var replyMessage: ISMChatReplyMessageMetaData?
    public var locationAddress: String?
    public var contacts: [ISMChatContactMetaData]?
    public var captionMessage: String?
    public var isBroadCastMessage: Bool?
    public var post: ISMChatPostMetaData?
    public var product: ISMChatProductMetaData?
    //productLink
    public var storeName: String?
    public var productName: String?
    public var bestPrice: Double?
    public var scratchPrice: Double?
    public var url: String?
    public var parentProductId: String?
    public var childProductId: String?
    public var entityType: String?
    public var productImage: String?
    
    //SOCIAL lINK
    public var thumbnailUrl : String?
    public var description : String?
    public var isVideoPost : Bool?
    public var socialPostId : String?
    
    public var collectionTitle : String?
    public var collectionDescription : String?
    public var productCount : Int?
    public var collectionImage : String?
    public var collectionId : String?
    
    //payment
    public var paymentRequestId : String?
    public var orderId : String?
    public var paymentRequestedMembers : [PaymentRequestedMembers]?
    public var requestAPaymentExpiryTime : Int?
    public var currencyCode : String?
    public var amount : Double?
    
    //dineInInvite
    public var inviteTitle : String?
    public var inviteTimestamp : String?
    public var inviteRescheduledTimestamp : String?
    public var inviteLocation : LocationData?
    public var inviteMembers : [PaymentRequestedMembers]?
    
    public var isSharedFromApp : Bool?
    
    public init(
        replyMessage: ISMChatReplyMessageMetaData? = nil,
        locationAddress: String? = nil,
        contacts: [ISMChatContactMetaData]? = nil,
        captionMessage: String? = nil,
        isBroadCastMessage: Bool? = nil,
        post: ISMChatPostMetaData? = nil,
        product: ISMChatProductMetaData? = nil,
        storeName: String? = nil,
        productName: String? = nil,
        bestPrice: Double? = nil,
        scratchPrice: Double? = nil,
        url: String? = nil,
        parentProductId: String? = nil,
        childProductId: String? = nil,
        entityType: String? = nil,
        productImage: String? = nil,
        thumbnailUrl : String? = nil,
        description : String? = nil,
        isVideoPost : Bool? = nil,
        socialPostId : String? = nil,
        collectionTitle : String? = nil,
        collectionDescription : String? = nil,
        productCount : Int? = nil,
        collectionImage : String? = nil,
        collectionId : String? = nil,
        isSharedFromApp : Bool? = nil,
        paymentRequestId : String? = nil,
        orderId : String? = nil,
        paymentRequestedMembers : [PaymentRequestedMembers]? = nil,
        requestAPaymentExpiryTime : Int? = nil,
        currencyCode : String? = nil,
        amount : Double? = nil,
        inviteTitle : String? = nil,
        inviteTimestamp : String? = nil,
        inviteRescheduledTimestamp : String? = nil,
        inviteLocation : LocationData? = nil,
        inviteMembers : [PaymentRequestedMembers]? = nil
    ) {
        self.replyMessage = replyMessage
        self.locationAddress = locationAddress
        self.contacts = contacts
        self.captionMessage = captionMessage
        self.isBroadCastMessage = isBroadCastMessage
        self.post = post
        self.product = product
        self.storeName = storeName
        self.productName = productName
        self.bestPrice = bestPrice
        self.scratchPrice = scratchPrice
        self.url = url
        self.parentProductId = parentProductId
        self.childProductId = childProductId
        self.entityType = entityType
        self.productImage = productImage
        self.thumbnailUrl = thumbnailUrl
        self.description = description
        self.isVideoPost = isVideoPost
        self.socialPostId = socialPostId
        self.collectionTitle = collectionTitle
        self.collectionDescription = collectionDescription
        self.productCount = productCount
        self.collectionImage = collectionImage
        self.collectionId = collectionId
        self.isSharedFromApp = isSharedFromApp
        self.paymentRequestId = paymentRequestId
        self.orderId = orderId
        self.paymentRequestedMembers = paymentRequestedMembers
        self.requestAPaymentExpiryTime = requestAPaymentExpiryTime
        self.currencyCode = currencyCode
        self.amount = amount
        self.inviteTitle = inviteTitle
        self.inviteTimestamp = inviteTimestamp
        self.inviteRescheduledTimestamp = inviteRescheduledTimestamp
        self.inviteLocation = inviteLocation
        self.inviteMembers = inviteMembers
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        replyMessage = try? container.decode(ISMChatReplyMessageMetaData.self, forKey: .replyMessage)
        locationAddress = try? container.decode(String.self, forKey: .locationAddress)
        contacts = try? container.decode([ISMChatContactMetaData].self, forKey: .contacts)
        captionMessage = try? container.decode(String.self, forKey: .captionMessage)
        isBroadCastMessage = try? container.decode(Bool.self, forKey: .isBroadCastMessage)
        post = try? container.decode(ISMChatPostMetaData.self, forKey: .post)
        product = try? container.decode(ISMChatProductMetaData.self, forKey: .product)
        storeName = try? container.decode(String.self, forKey: .storeName)
        productName = try? container.decode(String.self, forKey: .productName)
        bestPrice = try? container.decode(Double.self, forKey: .bestPrice)
        scratchPrice = try? container.decode(Double.self, forKey: .scratchPrice)
        url = try? container.decode(String.self, forKey: .url)
        parentProductId = try? container.decode(String.self, forKey: .parentProductId)
        childProductId = try? container.decode(String.self, forKey: .childProductId)
        entityType = try? container.decode(String.self, forKey: .entityType)
        productImage = try? container.decode(String.self, forKey: .productImage)
        thumbnailUrl = try? container.decode(String.self, forKey: .thumbnailUrl)
        description = try? container.decode(String.self, forKey: .description)
        isVideoPost = try? container.decode(Bool.self, forKey: .isVideoPost)
        socialPostId = try? container.decode(String.self, forKey: .socialPostId)
        collectionTitle = try? container.decode(String.self, forKey: .collectionTitle)
        collectionDescription = try? container.decode(String.self, forKey: .collectionDescription)
        productCount = try? container.decode(Int.self, forKey: .productCount)
        collectionImage = try? container.decode(String.self, forKey: .collectionImage)
        collectionId = try? container.decode(String.self, forKey: .collectionId)
        isSharedFromApp = try? container.decode(Bool.self, forKey: .isSharedFromApp)
        paymentRequestId = try? container.decode(String.self, forKey: .paymentRequestId)
        orderId = try? container.decode(String.self, forKey: .orderId)
        paymentRequestedMembers = try? container.decode([PaymentRequestedMembers].self, forKey: .paymentRequestedMembers)
        requestAPaymentExpiryTime = try? container.decode(Int.self, forKey: .requestAPaymentExpiryTime)
        currencyCode = try? container.decode(String.self, forKey: .currencyCode)
        amount = try? container.decode(Double.self, forKey: .amount)
    }
}

public struct LocationData : Codable{
    var name : String?
    var latitude: Double?
    var longitude: Double?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try? container.decode(String.self, forKey: .name)
        latitude = try? container.decode(Double.self, forKey: .latitude)
        longitude = try? container.decode(Double.self, forKey: .longitude)
    }
    public init(name : String? = nil,latitude : Double? = nil,longitude : Double? = nil){
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct PaymentRequestedMembers : Codable{
    var userId : String?
    var userName : String?
    var status : Int?
    var statusText : String?
    var appUserId : String?
    var userProfileImage : String?
    var declineReason : String?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try? container.decode(String.self, forKey: .userId)
        userName = try? container.decode(String.self, forKey: .userName)
        status = try? container.decode(Int.self, forKey: .status)
        statusText = try? container.decode(String.self, forKey: .statusText)
        appUserId = try? container.decode(String.self, forKey: .appUserId)
        userProfileImage = try? container.decode(String.self, forKey: .userProfileImage)
        declineReason = try? container.decode(String.self, forKey: .declineReason)
    }
    public init(userId : String? = nil,userName : String? = nil,status : Int? = nil,statusText : String? = nil,appUserId : String? = nil,userProfileImage : String? = nil,declineReason : String? = nil){
        self.userId = userId
        self.userName = userName
        self.status = status
        self.statusText = statusText
        self.appUserId = appUserId
        self.userProfileImage = userProfileImage
        self.declineReason = declineReason
    }
}

public struct PDPImageData : Codable{
    var small : String?
    var medium : String?
    var large : String?
    var extraLarge : String?
    var filePath : String?
    var altText : String?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        small = try? container.decode(String.self, forKey: .small)
        medium = try? container.decode(String.self, forKey: .medium)
        large = try? container.decode(String.self, forKey: .large)
        extraLarge = try? container.decode(String.self, forKey: .extraLarge)
        filePath = try? container.decode(String.self, forKey: .filePath)
        altText = try? container.decode(String.self, forKey: .altText)
    }
    public init(small : String? = nil,medium : String? = nil,large : String? = nil,extraLarge : String? = nil,filePath : String? = nil,altText : String? = nil){
        self.small  = small
        self.medium = medium
        self.large = large
        self.extraLarge = extraLarge
        self.filePath = filePath
        self.altText = altText
    }
}

public struct ISMChatPostMetaData : Codable{
    public var postId : String?
    public var postUrl : String?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        postId = try? container.decode(String.self, forKey: .postId)
        postUrl = try? container.decode(String.self, forKey: .postUrl)
    }
    public init(postId : String? = nil,postUrl : String? = nil){
        self.postId = postId
        self.postUrl = postUrl
    }
}

public struct ISMChatProductMetaData : Codable{
    public var productId : String?
    public var productUrl : String?
    public var productCategoryId : String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productId = try? container.decode(String.self, forKey: .productId)
        productUrl = try? container.decode(String.self, forKey: .productUrl)
        productCategoryId = try? container.decode(String.self, forKey: .productCategoryId)
    }
    public init(productId : String? = nil,productUrl : String? = nil,productCategoryId : String? = nil){
        self.productId = productId
        self.productUrl = productUrl
        self.productCategoryId = productCategoryId
    }
}


import Foundation

public struct AnyCodable: Codable {
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    // Decoding
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.value = NSNull()
        } else if let value = try? container.decode(Bool.self) {
            self.value = value
        } else if let value = try? container.decode(Int.self) {
            self.value = value
        } else if let value = try? container.decode(Double.self) {
            self.value = value
        } else if let value = try? container.decode(String.self) {
            self.value = value
        } else if let value = try? container.decode([AnyCodable].self) {
            self.value = value.map { $0.value }
        } else if let value = try? container.decode([String: AnyCodable].self) {
            self.value = value.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }

    // Encoding
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if let value = value as? [Any] {
            try container.encode(value.map { AnyCodable($0) })
        } else if let value = value as? [String: Any] {
            try container.encode(value.mapValues { AnyCodable($0) })
        } else if value is NSNull {
            try container.encodeNil()
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}

// Equatable
extension AnyCodable: Equatable {
    public static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case let (lhs as Bool, rhs as Bool):
            return lhs == rhs
        case let (lhs as Int, rhs as Int):
            return lhs == rhs
        case let (lhs as Double, rhs as Double):
            return lhs == rhs
        case let (lhs as String, rhs as String):
            return lhs == rhs
        case let (lhs as [AnyCodable], rhs as [AnyCodable]):
            return lhs == rhs
        case let (lhs as [String: AnyCodable], rhs as [String: AnyCodable]):
            return lhs == rhs
        case (is NSNull, is NSNull):
            return true
        default:
            return false
        }
    }
}

// CustomStringConvertible
extension AnyCodable: CustomStringConvertible {
    public var description: String {
        if let value = value as? CustomStringConvertible {
            return value.description
        }
        return String(describing: value)
    }
}
