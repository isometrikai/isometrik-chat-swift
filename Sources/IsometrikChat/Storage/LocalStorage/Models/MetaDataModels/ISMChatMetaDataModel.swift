//
//  File.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 25/02/25.
//

import Foundation
import SwiftData

@Model
public class ISMChatMetaDataDB{
    public var locationAddress : String?
    @Relationship(deleteRule: .cascade) public var replyMessage : ISMChatReplyMessageDB?
    @Relationship(deleteRule: .cascade) public var contacts : [ISMChatContactDB]?
    public var captionMessage : String?
    public var isBroadCastMessage : Bool?
    @Relationship(deleteRule: .cascade) public var post : ISMChatPostDB?
    @Relationship(deleteRule: .cascade) public var product : ISMChatProductDB?
    
    
    // Product Link
    public var storeName: String?
    public var productName: String?
    public var bestPrice: Double?
    public var scratchPrice: Double?
    public var url: String?
    public var parentProductId: String?
    public var childProductId: String?
    public var entityType: String?
    public var productImage: String?
    
    //social link
    public var thumbnailUrl : String?
    public var DescriptionValue : String?
    public var isVideoPost : Bool?
    public var socialPostId : String?
    
    //collection link
    public var collectionTitle : String?
    public var collectionDescription : String?
    public var productCount : Int?
    public var collectionImage : String?
    public var collectionId : String?
    
    //payment
    public var paymentRequestId : String?
    public var orderId : String?
    @Relationship(deleteRule: .cascade) public var paymentRequestedMembers : [ISMChatPaymentRequestMembersDB]?
    public var requestAPaymentExpiryTime : Int?
    public var currencyCode : String?
    public var amount : Double?
    
    //dineInInvite
    public var inviteTitle : String?
    public var inviteTimestamp : Double?
    public var inviteRescheduledTimestamp : Double?
    @Relationship(deleteRule: .cascade) public var inviteLocation : ISMChatLocationDB?
    @Relationship(deleteRule: .cascade) public var inviteMembers : [ISMChatPaymentRequestMembersDB]?
    public var groupCastId : String?
    public var status : Int?
    
    public init(locationAddress: String? = nil, replyMessage: ISMChatReplyMessageDB? = nil, contacts: [ISMChatContactDB]? = nil, captionMessage: String? = nil, isBroadCastMessage: Bool? = nil, post: ISMChatPostDB? = nil, product: ISMChatProductDB? = nil, storeName: String? = nil, productName: String? = nil, bestPrice: Double? = nil, scratchPrice: Double? = nil, url: String? = nil, parentProductId: String? = nil, childProductId: String? = nil, entityType: String? = nil, productImage: String? = nil, thumbnailUrl: String? = nil, Description: String? = nil, isVideoPost: Bool? = nil, socialPostId: String? = nil, collectionTitle: String? = nil, collectionDescription: String? = nil, productCount: Int? = nil, collectionImage: String? = nil, collectionId: String? = nil, paymentRequestId: String? = nil, orderId: String? = nil, paymentRequestedMembers: [ISMChatPaymentRequestMembersDB]? = nil, requestAPaymentExpiryTime: Int? = nil, currencyCode: String? = nil, amount: Double? = nil, inviteTitle: String? = nil, inviteTimestamp: Double? = nil, inviteRescheduledTimestamp: Double? = nil, inviteLocation: ISMChatLocationDB? = nil, inviteMembers: [ISMChatPaymentRequestMembersDB]? = nil, groupCastId: String? = nil, status: Int? = nil) {
        self.locationAddress = locationAddress
        self.replyMessage = replyMessage
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
        self.DescriptionValue = Description
        self.isVideoPost = isVideoPost
        self.socialPostId = socialPostId
        self.collectionTitle = collectionTitle
        self.collectionDescription = collectionDescription
        self.productCount = productCount
        self.collectionImage = collectionImage
        self.collectionId = collectionId
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
        self.groupCastId = groupCastId
        self.status = status
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        // Basic properties
        dict["locationAddress"] = locationAddress
        dict["captionMessage"] = captionMessage
        dict["isBroadCastMessage"] = isBroadCastMessage
        dict["storeName"] = storeName
        dict["productName"] = productName
        dict["bestPrice"] = bestPrice
        dict["scratchPrice"] = scratchPrice
        dict["url"] = url
        dict["parentProductId"] = parentProductId
        dict["childProductId"] = childProductId
        dict["entityType"] = entityType
        dict["productImage"] = productImage
        dict["thumbnailUrl"] = thumbnailUrl
        dict["DescriptionValue"] = DescriptionValue
        dict["isVideoPost"] = isVideoPost
        dict["socialPostId"] = socialPostId
        dict["collectionTitle"] = collectionTitle
        dict["collectionDescription"] = collectionDescription
        dict["productCount"] = productCount
        dict["collectionImage"] = collectionImage
        dict["collectionId"] = collectionId
        dict["paymentRequestId"] = paymentRequestId
        dict["orderId"] = orderId
        dict["requestAPaymentExpiryTime"] = requestAPaymentExpiryTime
        dict["currencyCode"] = currencyCode
        dict["amount"] = amount
        dict["inviteTitle"] = inviteTitle
        dict["inviteTimestamp"] = inviteTimestamp
        dict["inviteRescheduledTimestamp"] = inviteRescheduledTimestamp
        dict["groupCastId"] = groupCastId
        dict["status"] = status
        
        // Handle Relationships by converting them to dictionary or array of dictionaries
        if let replyMessage = replyMessage {
            dict["replyMessage"] = replyMessage.toDictionary()
        }
        
        if let contacts = contacts {
            dict["contacts"] = contacts.map { $0.toDictionary() }
        }
        
        if let post = post {
            dict["post"] = post.toDictionary()
        }
        
        if let product = product {
            dict["product"] = product.toDictionary()
        }
        
        if let paymentRequestedMembers = paymentRequestedMembers {
            dict["paymentRequestedMembers"] = paymentRequestedMembers.map { $0.toDictionary() }
        }
        
        if let inviteLocation = inviteLocation {
            dict["inviteLocation"] = inviteLocation.toDictionary()
        }
        
        if let inviteMembers = inviteMembers {
            dict["inviteMembers"] = inviteMembers.map { $0.toDictionary() }
        }
        
        return dict
    }

}

@Model
public class ISMChatLocationDB{
    public var name: String?
    public var latitude: Double?
    public var longitude: Double?
    public init(name: String? = nil, latitude: Double? = nil, longitude: Double? = nil) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]

        dict["name"] = name
        dict["latitude"] = latitude
        dict["longitude"] = longitude

        return dict
    }
}

@Model
public class ISMChatPaymentRequestMembersDB{
    public var userId: String?
    public var userName: String?
    public var status: Int?
    public var statusText: String?
    public var appUserId : String?
    public var userProfileImage : String?
    public var declineReason : String?
    public init(userId: String? = nil, userName: String? = nil, status: Int? = nil, statusText: String? = nil, appUserId: String? = nil, userProfileImage: String? = nil, declineReason: String? = nil) {
        self.userId = userId
        self.userName = userName
        self.status = status
        self.statusText = statusText
        self.appUserId = appUserId
        self.userProfileImage = userProfileImage
        self.declineReason = declineReason
    }
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]

        dict["userId"] = userId
        dict["userName"] = userName
        dict["status"] = status
        dict["statusText"] = statusText
        dict["appUserId"] = appUserId
        dict["userProfileImage"] = userProfileImage
        dict["declineReason"] = declineReason

        return dict
    }

}


@Model
public class ISMChatPostDB {
    public var postId : String?
    public var postUrl : String?
    public init(postId: String? = nil, postUrl: String? = nil) {
        self.postId = postId
        self.postUrl = postUrl
    }
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]

        dict["postId"] = postId
        dict["postUrl"] = postUrl

        return dict
    }
}

@Model
public class ISMChatProductDB{
    public var productId : String?
    public var productUrl : String?
    public var productCategoryId : String?
    public init(productId: String? = nil, productUrl: String? = nil, productCategoryId: String? = nil) {
        self.productId = productId
        self.productUrl = productUrl
        self.productCategoryId = productCategoryId
    }
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]

        dict["productId"] = productId
        dict["productUrl"] = productUrl
        dict["productCategoryId"] = productCategoryId

        return dict
    }
}

@Model
public class ISMChatContactDB{
    public var contactName : String?
    public var contactIdentifier : String?
    public var contactImageUrl : String?
    public init(contactName: String? = nil, contactIdentifier: String? = nil, contactImageUrl: String? = nil) {
        self.contactName = contactName
        self.contactIdentifier = contactIdentifier
        self.contactImageUrl = contactImageUrl
    }
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]

        dict["contactName"] = contactName
        dict["contactIdentifier"] = contactIdentifier
        dict["contactImageUrl"] = contactImageUrl

        return dict
    }
}

@Model
public class ISMChatReplyMessageDB {
    public var parentMessageId : String?
    public var parentMessageBody : String?
    public var parentMessageUserId : String?
    public var parentMessageUserName : String?
    public var parentMessageMessageType : String?
    public var parentMessageAttachmentUrl : String?
    public var parentMessageInitiator : Bool?
    public var parentMessagecaptionMessage : String?
    public init(parentMessageId: String? = nil, parentMessageBody: String? = nil, parentMessageUserId: String? = nil, parentMessageUserName: String? = nil, parentMessageMessageType: String? = nil, parentMessageAttachmentUrl: String? = nil, parentMessageInitiator: Bool? = nil, parentMessagecaptionMessage: String? = nil) {
        self.parentMessageId = parentMessageId
        self.parentMessageBody = parentMessageBody
        self.parentMessageUserId = parentMessageUserId
        self.parentMessageUserName = parentMessageUserName
        self.parentMessageMessageType = parentMessageMessageType
        self.parentMessageAttachmentUrl = parentMessageAttachmentUrl
        self.parentMessageInitiator = parentMessageInitiator
        self.parentMessagecaptionMessage = parentMessagecaptionMessage
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        dict["parentMessageId"] = parentMessageId
        dict["parentMessageBody"] = parentMessageBody
        dict["parentMessageUserId"] = parentMessageUserId
        dict["parentMessageUserName"] = parentMessageUserName
        dict["parentMessageMessageType"] = parentMessageMessageType
        dict["parentMessageAttachmentUrl"] = parentMessageAttachmentUrl
        dict["parentMessageInitiator"] = parentMessageInitiator
        dict["parentMessagecaptionMessage"] = parentMessagecaptionMessage

        return dict
    }

}
