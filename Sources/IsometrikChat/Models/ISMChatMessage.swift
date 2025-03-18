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
    private func createSenderInfo() -> ISMChatUserDB {
        return ISMChatUserDB(
            userId: self.senderInfo?.userId ?? "",
            userProfileImageUrl: self.senderInfo?.userProfileImageUrl ?? "",
            userName: self.senderInfo?.userName ?? "",
            userIdentifier: self.senderInfo?.userIdentifier ?? "",
            online: self.senderInfo?.online ?? false,
            lastSeen: self.senderInfo?.lastSeen ?? 0,
            metaData: ISMChatUserMetaDataDB(
                userId: self.senderInfo?.metaData?.userId ?? "",
                userType: self.senderInfo?.metaData?.userType ?? 0,
                isStarUser: self.senderInfo?.metaData?.isStarUser ?? false,
                userTypeString: self.senderInfo?.metaData?.userTypeString ?? ""
            )
        )
    }

    private func createMentionedUsers() -> [ISMChatMentionedUserDB] {
        return self.mentionedUsers?.map {
            ISMChatMentionedUserDB(
                wordCount: $0.wordCount ?? 0,
                userId: $0.userId ?? "",
                order: $0.order ?? 0
            )
        } ?? []
    }

    private func createDeliveryStatus(for members: [ISMChatUserStatus]?) -> [ISMChatMessageDeliveryStatusDB] {
        return members?.map {
            ISMChatMessageDeliveryStatusDB(userId: $0.userId, timestamp: $0.timestamp)
        } ?? []
    }

    private func createContacts() -> [ISMChatContactDB] {
        return self.metaData?.contacts?.map {
            ISMChatContactDB(
                contactName: $0.contactName,
                contactIdentifier: $0.contactIdentifier,
                contactImageUrl: $0.contactImageUrl
            )
        } ?? []
    }

    private func createPaymentRequestMembers() -> [ISMChatPaymentRequestMembersDB] {
        return self.metaData?.paymentRequestedMembers?.map {
            ISMChatPaymentRequestMembersDB(
                userId: $0.userId,
                userName: $0.userName,
                status: $0.status,
                statusText: $0.statusText,
                appUserId: $0.appUserId,
                userProfileImage: $0.userProfileImage,
                declineReason: $0.declineReason
            )
        } ?? []
    }

    private func createInviteMembers() -> [ISMChatPaymentRequestMembersDB] {
        return self.metaData?.inviteMembers?.map {
            ISMChatPaymentRequestMembersDB(
                userId: $0.userId,
                userName: $0.userName,
                status: $0.status,
                statusText: $0.statusText,
                appUserId: $0.appUserId,
                userProfileImage: $0.userProfileImage,
                declineReason: $0.declineReason
            )
        } ?? []
    }

    private func createMetaData(contacts: [ISMChatContactDB], paymentRequestMembers: [ISMChatPaymentRequestMembersDB], inviteMembers: [ISMChatPaymentRequestMembersDB]) -> ISMChatMetaDataDB {
        return ISMChatMetaDataDB(
            locationAddress: self.metaData?.locationAddress,
            contacts: contacts,
            captionMessage: self.metaData?.captionMessage,
            isBroadCastMessage: self.metaData?.isBroadCastMessage,
            product: self.metaData?.product != nil ? ISMChatProductDB(
                productId: self.metaData?.product?.productId,
                productUrl: self.metaData?.product?.productUrl,
                productCategoryId: self.metaData?.product?.productCategoryId
            ) : nil,
            paymentRequestedMembers: paymentRequestMembers, inviteMembers: inviteMembers
        )
    }

    private func createMembers() -> [ISMChatLastMessageMemberDB] {
        return self.members?.map {
            ISMChatLastMessageMemberDB(
                memberProfileImageUrl: $0.memberProfileImageUrl,
                memberName: $0.memberName,
                memberIdentifier: $0.memberIdentifier,
                memberId: $0.memberId
            )
        } ?? []
    }

    private func createAttachments() -> [ISMChatAttachmentDB] {
        return self.attachments?.map {
            ISMChatAttachmentDB(
                attachmentType: $0.attachmentType ?? 0,
                extensions: $0.extensions ?? "",
                mediaId: $0.mediaId ?? "",
                mediaUrl: $0.mediaUrl ?? "",
                mimeType: $0.mimeType ?? "",
                name: $0.name ?? "",
                size: $0.size ?? 0,
                thumbnailUrl: $0.thumbnailUrl ?? "",
                latitude: $0.latitude ?? 0,
                longitude: $0.longitude ?? 0,
                title: $0.title ?? "",
                address: $0.address ?? "",
                caption: $0.caption ?? ""
            )
        } ?? []
    }

    private func createReactions() -> [ISMChatReactionDB] {
        return self.reactions?.compactMap { (key, users) -> ISMChatReactionDB? in
            return users.isEmpty ? nil : ISMChatReactionDB(reactionType: key, users: users)
        } ?? []
    }

    private func createCallDurations() -> [ISMChatMeetingDuration] {
        return self.callDurations?.map {
            ISMChatMeetingDuration(memberId: $0.memberId ?? "", durationInMilliseconds: $0.durationInMilliseconds ?? 0)
        } ?? []
    }
    
    public func toMessageDB() -> ISMChatMessagesDB {
        let senderInfo = createSenderInfo()
        let mentionedUsers = createMentionedUsers()
        let deliveredToValue = createDeliveryStatus(for: self.deliveredTo)
        let readByValue = createDeliveryStatus(for: self.readBy)
        let contactsValue = createContacts()
        let paymentRequestMembersValue = createPaymentRequestMembers()
        let inviteMembersValue = createInviteMembers()
        let metaData = createMetaData(contacts: contactsValue, paymentRequestMembers: paymentRequestMembersValue, inviteMembers: inviteMembersValue)
        let membersValue = createMembers()
        let attachmentValue = createAttachments()
        let reactionsValue = createReactions()
        let callDurationValue = createCallDurations()
        let config = ISMChatMeetingConfig(pushNotifications: self.config?.pushNotifications)
        
        let messageId = self.messageId ?? ""
        let sentAt = self.sentAt ?? 0
        let body = self.body ?? ""
        let userName = self.userName ?? ""
        let userIdentifier = self.userIdentifier ?? ""
        let userId = self.userId ?? ""
        let userProfileImageUrl = self.senderInfo?.userProfileImageUrl ?? ""
        let deliveredToAll = self.deliveredToAll ?? false
        let readByAll = self.readByAll ?? false
        let customType = self.customType ?? ""
        let action = self.action ?? ""
        let readBy = readByValue
        let deliveredTo = deliveredToValue
        let messageType = self.messageType ?? 0
        let parentMessageId = self.parentMessageId ?? ""
        let metaDataJsonString = self.metaDataJsonString ?? ""
        let attachments = attachmentValue
        let initiatorIdentifier = self.initiatorIdentifier ?? ""
        let initiatorId = self.initiatorId ?? ""
        let initiatorName = self.initiatorName ?? ""
        let conversationId = self.conversationId ?? ""
        let msgSyncStatus = ""
        let placeName = ""
        let reactionType = ""
        let reactionsCount = self.reactions?.count
        let members = membersValue
        let deletedMessage = false
        let memberName = self.memberName ?? ""
        let memberId = self.memberId ?? ""
        let memberIdentifier = self.memberIdentifier ?? ""
        let messageUpdated = self.messageUpdated ?? false
        let reactions = reactionsValue
        let missedByMembers = self.missedByMembers ?? []
        let meetingId = self.meetingId ?? ""
        let callDurations = callDurationValue
        let audioOnly = self.audioOnly ?? false
        let autoTerminate = self.autoTerminate ?? false
        let groupcastId = self.groupcastId

        return ISMChatMessagesDB(
            messageId: messageId,
            sentAt: sentAt,
            senderInfo: senderInfo,
            body: body,
            userName: userName,
            userIdentifier: userIdentifier,
            userId: userId,
            userProfileImageUrl: userProfileImageUrl,
            mentionedUsers: mentionedUsers,
            deliveredToAll: deliveredToAll,
            readByAll: readByAll,
            customType: customType,
            action: action,
            readBy: readBy,
            deliveredTo: deliveredTo,
            messageType: messageType,
            parentMessageId: parentMessageId,
            metaData: metaData,
            metaDataJsonString: metaDataJsonString,
            attachments: attachments,
            initiatorIdentifier: initiatorIdentifier,
            initiatorId: initiatorId,
            initiatorName: initiatorName,
            conversationId: conversationId,
            msgSyncStatus: msgSyncStatus,
            placeName: placeName,
            reactionType: reactionType,
            reactionsCount: reactionsCount,
            members: members,
            deletedMessage: deletedMessage,
            memberName: memberName,
            memberId: memberId,
            memberIdentifier: memberIdentifier,
            messageUpdated: messageUpdated,
            reactions: reactions,
            missedByMembers: missedByMembers,
            meetingId: meetingId,
            callDurations: callDurations,
            audioOnly: audioOnly,
            autoTerminate: autoTerminate,
            config: config,
            groupcastId: groupcastId
        )
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
    public var inviteTimestamp : Double?
    public var inviteRescheduledTimestamp : Double?
    public var inviteLocation : LocationData?
    public var inviteMembers : [PaymentRequestedMembers]?
    public var groupCastId : String?
    public var status : Int?
    
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
        inviteTimestamp : Double? = nil,
        inviteRescheduledTimestamp : Double? = nil,
        inviteLocation : LocationData? = nil,
        inviteMembers : [PaymentRequestedMembers]? = nil,
        groupCastId : String? = nil,
        status : Int? = nil
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
        self.groupCastId = groupCastId
        self.status = status
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
        inviteTitle = try? container.decode(String.self, forKey: .inviteTitle)
        inviteTimestamp = try? container.decode(Double.self, forKey: .inviteTimestamp)
        inviteRescheduledTimestamp = try? container.decode(Double.self, forKey: .inviteRescheduledTimestamp)
        inviteLocation = try? container.decode(LocationData.self, forKey: .inviteLocation)
        inviteMembers = try? container.decode([PaymentRequestedMembers].self, forKey: .inviteMembers)
        groupCastId = try? container.decode(String.self, forKey: .groupCastId)
        status = try? container.decode(Int.self, forKey: .status)
    }
}

public struct LocationData : Codable{
    public var name : String?
    public var latitude: Double?
    public var longitude: Double?
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
    public var userId : String?
    public var userName : String?
    public var status : Int?
    public var statusText : String?
    public var appUserId : String?
    public var userProfileImage : String?
    public var declineReason : String?
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
