//
//  ISMChatMetaDataDB.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift

public class MetaDataDB : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: ObjectId
    @Persisted public var locationAddress : String?
    @Persisted public var replyMessage : ReplyMessageDB?
    @Persisted public var contacts : RealmSwift.List<ContactDB>
    @Persisted public var captionMessage : String?
    @Persisted public var isBroadCastMessage : Bool?
    @Persisted public var post : PostDB?
    @Persisted public var product : ProductDB?
    
    
    // Product Link
    @Persisted public var storeName: String?
    @Persisted public var productName: String?
    @Persisted public var bestPrice: Double?
    @Persisted public var scratchPrice: Double?
    @Persisted public var url: String?
    @Persisted public var parentProductId: String?
    @Persisted public var childProductId: String?
    @Persisted public var entityType: String?
    @Persisted public var productImage: String?
    
    //social link
    @Persisted public var thumbnailUrl : String?
    @Persisted public var Description : String?
    @Persisted public var isVideoPost : Bool?
    @Persisted public var socialPostId : String?
    
    //collection link
    @Persisted public var collectionTitle : String?
    @Persisted public var collectionDescription : String?
    @Persisted public var productCount : Int?
    @Persisted public var collectionImage : String?
    @Persisted public var collectionId : String?
    
    //payment
    @Persisted public var paymentRequestId : String?
    @Persisted public var orderId : String?
    @Persisted public var status : Int?
    @Persisted public var requestAPaymentExpiryTime : Int?
    @Persisted public var currencyCode : String?
    @Persisted public var amount : Double?
    
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]

        // Add simple properties conditionally
        if let locationAddress = locationAddress {
            dictionary["locationAddress"] = locationAddress
        }
        if let captionMessage = captionMessage {
            dictionary["captionMessage"] = captionMessage
        }
        if let isBroadCastMessage = isBroadCastMessage {
            dictionary["isBroadCastMessage"] = isBroadCastMessage
        }
        if let storeName = storeName {
            dictionary["storeName"] = storeName
        }
        if let productName = productName {
            dictionary["productName"] = productName
        }
        if let bestPrice = bestPrice {
            dictionary["bestPrice"] = bestPrice
        }
        if let scratchPrice = scratchPrice {
            dictionary["scratchPrice"] = scratchPrice
        }
        if let url = url {
            dictionary["url"] = url
        }
        if let parentProductId = parentProductId {
            dictionary["parentProductId"] = parentProductId
        }
        if let childProductId = childProductId {
            dictionary["childProductId"] = childProductId
        }
        if let entityType = entityType {
            dictionary["entityType"] = entityType
        }
        if let productImage = productImage {
            dictionary["productImage"] = productImage
        }
        if let thumbnailUrl = thumbnailUrl {
            dictionary["thumbnailUrl"] = thumbnailUrl
        }
        if let Description = Description {
            dictionary["Description"] = Description
        }
        if let isVideoPost = isVideoPost {
            dictionary["isVideoPost"] = isVideoPost
        }
        if let socialPostId = socialPostId {
            dictionary["socialPostId"] = socialPostId
        }
        if let collectionTitle = collectionTitle {
            dictionary["collectionTitle"] = collectionTitle
        }
        if let collectionDescription = collectionDescription {
            dictionary["collectionDescription"] = collectionDescription
        }
        if let productCount = productCount {
            dictionary["productCount"] = productCount
        }
        if let collectionImage = collectionImage {
            dictionary["collectionImage"] = collectionImage
        }
        if let collectionId = collectionId {
            dictionary["collectionId"] = collectionId
        }
        if let paymentRequestId = paymentRequestId {
            dictionary["paymentRequestId"] = paymentRequestId
        }
        if let orderId = orderId {
            dictionary["orderId"] = orderId
        }
        if let status = status {
            dictionary["status"] = status
        }
        if let requestAPaymentExpiryTime = requestAPaymentExpiryTime {
            dictionary["requestAPaymentExpiryTime"] = requestAPaymentExpiryTime
        }
        if let currencyCode = currencyCode {
            dictionary["currencyCode"] = currencyCode
        }
        if let amount = amount {
            dictionary["amount"] = amount
        }

        // Add nested objects conditionally
        if let replyMessage = replyMessage {
            dictionary["replyMessage"] = replyMessage.toDictionary()
        }
        if let post = post {
            dictionary["post"] = post.toDictionary()
        }
        if let product = product {
            dictionary["product"] = product.toDictionary()
        }

        // Add list of objects (convert each to a dictionary)
        if !contacts.isEmpty {
            dictionary["contacts"] = contacts.map { $0.toDictionary() }
        }

        return dictionary
    }
}

public class PDPImageDB: Object, ObjectKeyIdentifiable {
    @Persisted public var small: String?
    @Persisted public var medium: String?
    @Persisted public var large: String?
    @Persisted public var extraLarge: String?
    @Persisted public var filePath: String?
    @Persisted public var altText: String?
}


public class PostDB: Object, ObjectKeyIdentifiable {
    @Persisted public var postId : String?
    @Persisted public var postUrl : String?
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let postId = postId {
            dictionary["postId"] = postId
        }
        if let postUrl = postUrl {
            dictionary["postUrl"] = postUrl
        }
        return dictionary
    }
}

public class ProductDB: Object, ObjectKeyIdentifiable {
    @Persisted public var productId : String?
    @Persisted public var productUrl : String?
    @Persisted public var productCategoryId : String?
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let productId = productId {
            dictionary["productId"] = productId
        }
        if let productUrl = productUrl {
            dictionary["productUrl"] = productUrl
        }
        if let productCategoryId = productCategoryId {
            dictionary["productCategoryId"] = productCategoryId
        }
        return dictionary
    }
}


public class ContactDB : Object, ObjectKeyIdentifiable {
    @Persisted public var contactName : String?
    @Persisted public var contactIdentifier : String?
    @Persisted public var contactImageUrl : String?
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let contactName = contactName {
            dictionary["contactName"] = contactName
        }
        if let contactIdentifier = contactIdentifier {
            dictionary["contactIdentifier"] = contactIdentifier
        }
        if let contactImageUrl = contactImageUrl {
            dictionary["contactImageUrl"] = contactImageUrl
        }
        return dictionary
    }
}

public class ReplyMessageDB : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: ObjectId
    @Persisted public var parentMessageId : String?
    @Persisted public var parentMessageBody : String?
    @Persisted public var parentMessageUserId : String?
    @Persisted public var parentMessageUserName : String?
    @Persisted public var parentMessageMessageType : String?
    @Persisted public var parentMessageAttachmentUrl : String?
    @Persisted public var parentMessageInitiator : Bool?
    @Persisted public var parentMessagecaptionMessage : String?
    
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let parentMessageId = parentMessageId {
            dictionary["parentMessageId"] = parentMessageId
        }
        if let parentMessageBody = parentMessageBody {
            dictionary["parentMessageBody"] = parentMessageBody
        }
        if let parentMessageUserId = parentMessageUserId {
            dictionary["parentMessageUserId"] = parentMessageUserId
        }
        if let parentMessageUserName = parentMessageUserName {
            dictionary["parentMessageUserName"] = parentMessageUserName
        }
        if let parentMessageMessageType = parentMessageMessageType {
            dictionary["parentMessageMessageType"] = parentMessageMessageType
        }
        if let parentMessageAttachmentUrl = parentMessageAttachmentUrl {
            dictionary["parentMessageAttachmentUrl"] = parentMessageAttachmentUrl
        }
        if let parentMessageInitiator = parentMessageInitiator {
            dictionary["parentMessageInitiator"] = parentMessageInitiator
        }
        if let parentMessagecaptionMessage = parentMessagecaptionMessage {
            dictionary["parentMessagecaptionMessage"] = parentMessagecaptionMessage
        }
        return dictionary
    }
}
