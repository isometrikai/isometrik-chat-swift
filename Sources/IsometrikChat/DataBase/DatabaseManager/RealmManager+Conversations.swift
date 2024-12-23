//
//  RealmManagerConversations.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift

extension RealmManager {
    
    //MARK: - get all conversations count
    public func getOtherConversationCount() -> Int {
        let filteredOutConversations = conversations.filter { conversation in
            // Check if the user is a business user
            if conversation.createdBy != userData?.userId{
                if ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userProfileType == ISMChatUserProfileType.Bussiness.value {
                    // If user is a business user
                    if let metaData = conversation.opponentDetails?.metaData ,let ConversationMetaData = conversation.metaData{
                        // Check if opponent's profileType is not "user" or "influencer" or allowToMessage is true
                        if metaData.userType == 1 && ConversationMetaData.chatStatus == ISMChatStatus.Reject.value{
                            return true
                        }else{
                            return false
                        }
                    }
                    return false // Reject conversations with opponents other than "user" or "influencer"
                } else  if ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userProfileType == ISMChatUserProfileType.Influencer.value {
                    if let metaData = conversation.opponentDetails?.metaData ,let ConversationMetaData = conversation.metaData{
                        // Check if opponent's profileType is not "user" or allowToMessage is true
                        if metaData.userType == 1 && metaData.isStarUser != true && ConversationMetaData.chatStatus == ISMChatStatus.Reject.value{
                            return true
                        } else {
                            return false
                        }
                    }
                    return false
                } else {
                    return false
                }
            }else{
                //if created by me then it should be in primary list
                return false
            }
        }
        return filteredOutConversations.count
        
    }
    
    public func getOtherConversation() -> [ConversationDB] {
        let filteredOutConversations = conversations.filter { conversation in
            // Check if the user is a business user
            if conversation.createdBy != userData?.userId{
                if ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userProfileType == ISMChatUserProfileType.Bussiness.value {
                    // If user is a business user
                    if let metaData = conversation.opponentDetails?.metaData ,let ConversationMetaData = conversation.metaData{
                        // Check if opponent's profileType is not "user" or "influencer" or allowToMessage is true
                        if metaData.userType == 1 && ConversationMetaData.chatStatus == ISMChatStatus.Reject.value{
                            return true
                        }else{
                            return false
                        }
                    }
                    return false // Reject conversations with opponents other than "user" or "influencer"
                } else  if ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userProfileType == ISMChatUserProfileType.Influencer.value {
                    if let metaData = conversation.opponentDetails?.metaData ,let ConversationMetaData = conversation.metaData{
                        // Check if opponent's profileType is not "user" or allowToMessage is true
                        if metaData.userType == 1 && metaData.isStarUser != true && ConversationMetaData.chatStatus == ISMChatStatus.Reject.value{
                            return true
                        } else {
                            return false
                        }
                    }
                    return false
                } else {
                    return false
                }
            }else{
                //if created by me then it should be in primary list
                return false
            }
        }
        return filteredOutConversations
    }
    
    
    public func getPrimaryConversationCount() -> Int {
        let otherConversations = self.getOtherConversation()
        let primaryConversations = conversations.filter { conversation in
            !otherConversations.contains(where: { $0.id == conversation.id })
        }
        return primaryConversations.count
    }
    
    public func getPrimaryConversation() -> [ConversationDB] {
        let otherConversations = self.getOtherConversation()
        let primaryConversations = conversations.filter { conversation in
            !otherConversations.contains(where: { $0.id == conversation.id })
        }
        return primaryConversations
    }
    
    //MARK: - get all conversations count
    public func getConversationCount() -> Int {
        conversations.count
    }
    
    //MARK: - get all conversations
    public func getConversation() -> [ConversationDB] {
        conversations
    }
    
    //MARK: - get conversation id if already there for specific user
//    public func getConversationId(userId : String) -> String{
//        let conversation = conversations.first { con in
//            con.opponentDetails?.userId == userId
//        }
//        if conversation != nil{
//            return conversation?.conversationId ?? ""
//        }else{
//            return ""
//        }
//    }
    
    public func getConversationId(opponentUserId : String,myUserId : String) -> String{
        let conversation = conversations.first { con in
            con.opponentDetails?.userId == opponentUserId //&& (con.metaData?.membersIds.contains(myUserId) ?? false)
        }
        if conversation != nil{
            return conversation?.conversationId ?? ""
        }else{
            return ""
        }
    }
    
    public func saveLastInputTextInConversation(text : String,conversationId : String){
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@", conversationId))
                guard !taskToDelete.isEmpty else { return }
                try localRealm.write {
                    taskToDelete.first?.lastInputText = text
                }
            } catch {
                print("Error while saving last input text in  \(conversationId) to Realm: \(error)")
            }
        }
    }
    
    
    public func getLastInputTextInConversation(conversationId : String) -> String{
        let conversation = conversations.first { con in
            con.conversationId == conversationId
        }
        if conversation != nil{
            return conversation?.lastInputText ?? ""
        }else{
            return ""
        }
    }
    
    
    //MARK: - We check if conversation already exist in local DB, if yes updateit, else save/add
    public func manageConversationList(arr: [ISMChatConversationsDetail]) {
        if let localRealm = localRealm {
            for obj in arr {
                let taskToUpdate = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@", (obj.conversationId ?? "")))
                if taskToUpdate.isEmpty {
                    addConversation(obj: [obj])
                }else {
                    if (taskToUpdate.first?.id) != nil {
                        if taskToUpdate.first?.isDelete == false {
                            updateConversation(obj: obj)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Add conversation locally
    public func addConversation(obj: [ISMChatConversationsDetail]) {
        guard let localRealm = localRealm else { return }
        
        do {
            try localRealm.write {
                for value in obj {
                    
                    let conversation = ConversationDB()
                    conversation.conversationId = value.conversationId ?? ""
                    conversation.updatedAt = value.lastMessageDetails?.updatedAt ?? 0
                    conversation.unreadMessagesCount = value.unreadMessagesCount ?? 0
                    conversation.membersCount = value.membersCount ?? 0
                    conversation.lastMessageSentAt = value.lastMessageSentAt ?? 0
                    conversation.createdAt = value.createdAt ?? 0
                    conversation.mode = "mode"
                    conversation.conversationTitle = value.conversationTitle ?? ""
                    conversation.conversationImageUrl = value.conversationImageUrl ?? ""
                    conversation.createdBy = value.createdBy ?? ""
                    conversation.createdByUserName = value.createdByUserName ?? ""
                    conversation.privateOneToOne = value.privateOneToOne ?? false
                    conversation.messagingDisabled = false
                    conversation.isGroup = value.isGroup ?? false
                    
                    let metaData = ConversationMetaData()
                    metaData.chatStatus = value.metaData?.chatStatus
                    if let membersIds = value.metaData?.membersIds {
                        metaData.membersIds.append(objectsIn: membersIds)
                    }
                    conversation.metaData = metaData
                    
                    let config = ConfigDB()
                    config.typingEvents = value.config?.typingEvents
                    config.pushNotifications = value.config?.pushNotifications
                    config.readEvents = value.config?.readEvents
                    conversation.config = config
                    
                    let user = UserDB()
                    user.lastSeen = value.opponentDetails?.lastSeen ?? 0
                    user.online = value.opponentDetails?.online ?? false
                    user.userId = value.opponentDetails?.userId ?? ""
                    user.userIdentifier = value.opponentDetails?.userIdentifier ?? ""
                    user.userName = value.opponentDetails?.userName ?? ""
                    user.userProfileImageUrl = value.opponentDetails?.userProfileImageUrl ?? ""
                    
                    let opponentMetaData = UserMetaDataDB()
                    opponentMetaData.userId = value.opponentDetails?.metaData?.userId ?? ""
                    opponentMetaData.userType = value.opponentDetails?.metaData?.userType ?? 0
                    opponentMetaData.userTypeString = value.opponentDetails?.metaData?.userTypeString ?? ""
                    opponentMetaData.isStarUser = value.opponentDetails?.metaData?.isStarUser ?? false
                    
                    user.metaData = opponentMetaData
                    conversation.opponentDetails = user
                    
                    let lastMessage = LastMessageDB()
                    lastMessage.sentAt = value.lastMessageDetails?.sentAt ?? 0
                    lastMessage.updatedAt = value.lastMessageDetails?.updatedAt ?? 0
                    lastMessage.senderName = value.lastMessageDetails?.senderName ?? ""
                    lastMessage.senderIdentifier = value.lastMessageDetails?.senderIdentifier ?? ""
                    lastMessage.senderId = value.lastMessageDetails?.senderId ?? ""
                    lastMessage.conversationId = value.lastMessageDetails?.conversationId ?? ""
                    lastMessage.body = value.lastMessageDetails?.body ?? ""
                    lastMessage.messageId = value.lastMessageDetails?.messageId ?? ""
                    lastMessage.customType = value.lastMessageDetails?.customType ?? ""
                    lastMessage.action = value.lastMessageDetails?.action ?? ""
                    lastMessage.userId = value.lastMessageDetails?.userId ?? ""
                    lastMessage.reactionType = value.lastMessageDetails?.reactionType ?? ""
                    lastMessage.memberName = value.lastMessageDetails?.memberName ?? ""
                    lastMessage.memberId = value.lastMessageDetails?.memberId ?? ""
                    lastMessage.userName = value.lastMessageDetails?.userName ?? ""
                    lastMessage.initiatorName = value.lastMessageDetails?.initiatorName ?? ""
                    lastMessage.initiatorId = value.lastMessageDetails?.initiatorId ?? ""
                    lastMessage.initiatorIdentifier = value.lastMessageDetails?.initiatorIdentifier ?? ""
                    lastMessage.meetingId = value.lastMessageDetails?.meetingId ?? ""
                    
                    if let missedByMembers = value.lastMessageDetails?.missedByMembers {
                        lastMessage.missedByMembers.append(objectsIn: missedByMembers)
                    }
                    
                    if let callDurations = value.lastMessageDetails?.callDurations {
                        for duration in callDurations {
                            let meetingDuration = ISMMeetingDuration()
                            meetingDuration.memberId = duration.memberId
                            meetingDuration.durationInMilliseconds = duration.durationInMilliseconds ?? 0
                            lastMessage.callDurations.append(meetingDuration)
                        }
                    }
                    
                    if lastMessage.action == ISMChatActionType.messageDetailsUpdated.value {
                        lastMessage.body = value.lastMessageDetails?.details?.body ?? ""
                        lastMessage.customType = value.lastMessageDetails?.details?.customType
                        if value.lastMessageDetails?.details?.customType == ISMChatMediaType.ProductLink.value || value.lastMessageDetails?.details?.customType == ISMChatMediaType.SocialLink.value{
                            lastMessage.body = value.lastMessageDetails?.details?.metaData?.url ?? ""
                        }
                    }
                    
                    for member in value.lastMessageDetails?.members ?? [] {
                        let lastMessageMember = LastMessageMemberDB()
                        lastMessageMember.memberProfileImageUrl = member.memberProfileImageUrl ?? ""
                        lastMessageMember.memberName = member.memberName ?? ""
                        lastMessageMember.memberIdentifier = member.memberIdentifier ?? ""
                        lastMessageMember.memberId = member.memberId ?? ""
                        lastMessage.members.append(lastMessageMember)
                    }
                    
                    let messageMetaData = MetaDataDB()
                    
                    let replyMessage = ReplyMessageDB()
                    replyMessage.parentMessageId = value.lastMessageDetails?.metaData?.replyMessage?.parentMessageId ?? ""
                    replyMessage.parentMessageBody = value.lastMessageDetails?.metaData?.replyMessage?.parentMessageBody ?? ""
                    replyMessage.parentMessageUserId = value.lastMessageDetails?.metaData?.replyMessage?.parentMessageUserId ?? ""
                    replyMessage.parentMessageUserName = value.lastMessageDetails?.metaData?.replyMessage?.parentMessageUserName ?? ""
                    replyMessage.parentMessageMessageType = value.lastMessageDetails?.metaData?.replyMessage?.parentMessageMessageType ?? ""
                    replyMessage.parentMessageAttachmentUrl = value.lastMessageDetails?.metaData?.replyMessage?.parentMessageAttachmentUrl ?? ""
                    replyMessage.parentMessageInitiator = value.lastMessageDetails?.metaData?.replyMessage?.parentMessageInitiator ?? false
                    replyMessage.parentMessagecaptionMessage = value.lastMessageDetails?.metaData?.replyMessage?.parentMessagecaptionMessage ?? ""
                    
                    messageMetaData.replyMessage = replyMessage
                    messageMetaData.locationAddress = value.lastMessageDetails?.metaData?.locationAddress ?? ""
                    messageMetaData.captionMessage = value.lastMessageDetails?.metaData?.captionMessage ?? ""
                    
                    let post = PostDB()
                    post.postId = value.lastMessageDetails?.metaData?.post?.postId ?? ""
                    post.postUrl = value.lastMessageDetails?.metaData?.post?.postUrl ?? ""
                    messageMetaData.post = post
                    
                    let product = ProductDB()
                    product.productId = value.lastMessageDetails?.metaData?.product?.productId ?? ""
                    product.productUrl = value.lastMessageDetails?.metaData?.product?.productUrl ?? ""
                    product.productCategoryId = value.lastMessageDetails?.metaData?.product?.productCategoryId ?? ""
                    messageMetaData.product = product
                    
                    messageMetaData.isBroadCastMessage = value.lastMessageDetails?.metaData?.isBroadCastMessage ?? false
                    
                    messageMetaData.storeName = value.lastMessageDetails?.metaData?.storeName
                    messageMetaData.productName = value.lastMessageDetails?.metaData?.productName
                    messageMetaData.bestPrice = value.lastMessageDetails?.metaData?.bestPrice
                    messageMetaData.scratchPrice = value.lastMessageDetails?.metaData?.scratchPrice
                    messageMetaData.url = value.lastMessageDetails?.metaData?.url
                    messageMetaData.parentProductId = value.lastMessageDetails?.metaData?.parentProductId
                    messageMetaData.childProductId = value.lastMessageDetails?.metaData?.childProductId
                    messageMetaData.entityType = value.lastMessageDetails?.metaData?.entityType
                    messageMetaData.thumbnailUrl = value.lastMessageDetails?.metaData?.thumbnailUrl
                    messageMetaData.Description = value.lastMessageDetails?.metaData?.description
                    messageMetaData.isVideoPost = value.lastMessageDetails?.metaData?.isVideoPost
                    messageMetaData.socialPostId = value.lastMessageDetails?.metaData?.socialPostId
                    messageMetaData.productImage = value.lastMessageDetails?.metaData?.productImage
                    messageMetaData.collectionTitle = value.lastMessageDetails?.metaData?.collectionTitle
                    messageMetaData.collectionDescription = value.lastMessageDetails?.metaData?.collectionDescription
                    messageMetaData.productCount = value.lastMessageDetails?.metaData?.productCount
                    messageMetaData.collectionImage = value.lastMessageDetails?.metaData?.collectionImage
                    messageMetaData.collectionId = value.lastMessageDetails?.metaData?.collectionId
                    messageMetaData.paymentRequestId = value.lastMessageDetails?.metaData?.paymentRequestId
                    messageMetaData.orderId = value.lastMessageDetails?.metaData?.orderId
                    messageMetaData.status = value.lastMessageDetails?.metaData?.status
                    messageMetaData.friendPaymentRequestExpiryTime = value.lastMessageDetails?.metaData?.friendPaymentRequestExpiryTime
                    messageMetaData.currencyCode = value.lastMessageDetails?.metaData?.currencyCode
                    messageMetaData.amount = value.lastMessageDetails?.metaData?.amount
                    
                    
                    
                    
                    lastMessage.metaData = messageMetaData
                    
                    for delivered in value.lastMessageDetails?.deliveredTo ?? [] {
                        let deliveryStatus = MessageDeliveryStatusDB()
                        deliveryStatus.userId = delivered.userId ?? ""
                        deliveryStatus.timestamp = delivered.timestamp ?? 0
                        lastMessage.deliveredTo.append(deliveryStatus)
                    }
                    
                    for read in value.lastMessageDetails?.readBy ?? [] {
                        let readStatus = MessageDeliveryStatusDB()
                        readStatus.userId = read.userId ?? ""
                        readStatus.timestamp = read.timestamp ?? 0
                        lastMessage.readBy.append(readStatus)
                    }
                    
                    conversation.lastMessageDetails = lastMessage
                    localRealm.add(conversation)
                }
                getAllConversations()
            }
        } catch {
            print("Error adding task to Realm: \(error.localizedDescription)")
        }
    }
    
    //MARK: - update convertion if already exist in local db
    public func updateConversation(obj: ISMChatConversationsDetail) {
        if let localRealm = localRealm {
            do {
                let listToUpdate = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@  AND isDelete = %d", (obj.conversationId ?? ""), false))
                
                guard !listToUpdate.isEmpty else { return }
                try localRealm.write {
                    
                    listToUpdate.first?.updatedAt = obj.lastMessageDetails?.updatedAt ?? 00
                    listToUpdate.first?.unreadMessagesCount = obj.unreadMessagesCount ?? 0
                    listToUpdate.first?.membersCount = obj.membersCount ?? 0
                    listToUpdate.first?.lastMessageSentAt = obj.lastMessageSentAt ?? 0
                    listToUpdate.first?.createdAt = obj.createdAt ?? 00
                    listToUpdate.first?.mode = "need to set"
                    listToUpdate.first?.conversationTitle = obj.conversationTitle ?? ""
                    listToUpdate.first?.conversationImageUrl = obj.conversationImageUrl ?? ""
                    listToUpdate.first?.createdBy = obj.createdBy ?? ""
                    listToUpdate.first?.createdByUserName = obj.createdByUserName ?? ""
                    listToUpdate.first?.privateOneToOne = obj.privateOneToOne ?? false
                    listToUpdate.first?.messagingDisabled = false
                    listToUpdate.first?.isGroup = obj.isGroup ?? false
                    
                    let config = ConfigDB()
                    config.pushNotifications = obj.config?.pushNotifications
                    config.typingEvents = obj.config?.typingEvents
                    config.readEvents = obj.config?.readEvents
                    listToUpdate.first?.config = config
                    
                    listToUpdate.first?.opponentDetails?.lastSeen = obj.opponentDetails?.lastSeen ?? 00
                    listToUpdate.first?.opponentDetails?.online = obj.opponentDetails?.online
                    listToUpdate.first?.opponentDetails?.userId = obj.opponentDetails?.userId
                    listToUpdate.first?.opponentDetails?.userIdentifier = obj.opponentDetails?.userIdentifier
                    listToUpdate.first?.opponentDetails?.userName = obj.opponentDetails?.userName
                    listToUpdate.first?.opponentDetails?.userProfileImageUrl = obj.opponentDetails?.userProfileImageUrl
                    listToUpdate.first?.opponentDetails?.metaData?.userId = obj.opponentDetails?.metaData?.userId
                    listToUpdate.first?.opponentDetails?.metaData?.userType = obj.opponentDetails?.metaData?.userType
                    listToUpdate.first?.opponentDetails?.metaData?.userTypeString = obj.opponentDetails?.metaData?.userTypeString
                    listToUpdate.first?.opponentDetails?.metaData?.isStarUser = obj.opponentDetails?.metaData?.isStarUser
                    
                    listToUpdate.first?.lastMessageDetails?.sentAt = obj.lastMessageDetails?.sentAt
                    listToUpdate.first?.lastMessageDetails?.updatedAt = obj.lastMessageDetails?.updatedAt
                    listToUpdate.first?.lastMessageDetails?.senderName = obj.lastMessageDetails?.senderName
                    listToUpdate.first?.lastMessageDetails?.senderIdentifier = obj.lastMessageDetails?.senderIdentifier
                    listToUpdate.first?.lastMessageDetails?.senderId = obj.lastMessageDetails?.senderId
                    listToUpdate.first?.lastMessageDetails?.conversationId = obj.lastMessageDetails?.conversationId
                    listToUpdate.first?.lastMessageDetails?.body = obj.lastMessageDetails?.body ?? ""
                    listToUpdate.first?.lastMessageDetails?.messageId = obj.lastMessageDetails?.messageId
                    listToUpdate.first?.lastMessageDetails?.userId = obj.lastMessageDetails?.userId ?? ""
                    listToUpdate.first?.lastMessageDetails?.userIdentifier = obj.lastMessageDetails?.userIdentifier
                    listToUpdate.first?.lastMessageDetails?.userName = obj.lastMessageDetails?.userName
                    listToUpdate.first?.lastMessageDetails?.userProfileImageUrl = obj.lastMessageDetails?.userProfileImageUrl
                    listToUpdate.first?.lastMessageDetails?.initiatorId = obj.lastMessageDetails?.initiatorId
                    listToUpdate.first?.lastMessageDetails?.customType = obj.lastMessageDetails?.customType
                    listToUpdate.first?.lastMessageDetails?.action = obj.lastMessageDetails?.action
                    
                    if listToUpdate.first?.lastMessageDetails?.action == ISMChatActionType.messageDetailsUpdated.value{
                        listToUpdate.first?.lastMessageDetails?.body = obj.lastMessageDetails?.details?.body
                        listToUpdate.first?.lastMessageDetails?.customType = obj.lastMessageDetails?.details?.customType
                        if obj.lastMessageDetails?.details?.customType == ISMChatMediaType.ProductLink.value || obj.lastMessageDetails?.details?.customType == ISMChatMediaType.SocialLink.value{
                            listToUpdate.first?.lastMessageDetails?.body = obj.lastMessageDetails?.details?.metaData?.url ?? ""
                        }
                    }
                    
                    listToUpdate.first?.lastMessageDetails?.deliveredTo.removeAll()
                    listToUpdate.first?.lastMessageDetails?.readBy.removeAll()
                    
                    for obj in obj.lastMessageDetails?.deliveredTo ?? [] {
                        let deliverObj = MessageDeliveryStatusDB()
                        deliverObj.userId = obj.userId
                        deliverObj.timestamp = obj.timestamp
                        
                        listToUpdate.first?.lastMessageDetails?.deliveredTo.append(deliverObj)
                    }
                    
                    for obj in obj.lastMessageDetails?.readBy ?? [] {
                        let deliverObj = MessageDeliveryStatusDB()
                        deliverObj.userId = obj.userId
                        deliverObj.timestamp = obj.timestamp
                        
                        listToUpdate.first?.lastMessageDetails?.readBy.append(deliverObj)
                    }
                    
                    getAllConversations()
                }
            } catch {
                print("Error updating task \(obj.id) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - Get local conversations
    public func getAllConversations() {
        if let localRealm = localRealm {
            conversations =  Array(localRealm.objects(ConversationDB.self).where{$0.isDelete == false })
            conversations = conversations.sorted(by: { lhsData, rhsData in
                lhsData.lastMessageSentAt > rhsData.lastMessageSentAt
            })
            //remove broadcast list from conversationList
            let data = conversations.filter { conversation in
                return conversation.opponentDetails?.userId == nil && conversation.opponentDetails?.userName == nil
                && conversation.isGroup == false
            }
            conversations = conversations.filter { !data.contains($0) }
            storeConv = conversations
        }
    }
    
    //MARK: - delete conversation locally
    public func deleteConversation(convID: String) {
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@", convID))
                guard !taskToDelete.isEmpty else { return }
                try localRealm.write {
                    taskToDelete.first?.isDelete = true
                    getAllConversations()
                }
            } catch {
                print("Error deleting task \(convID) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - undo delete conversation
    public func undodeleteConversation(convID: String) {
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@ AND isDelete = %d", convID, true))
                guard !taskToDelete.isEmpty else { return }
                try localRealm.write {
                    taskToDelete.first?.isDelete = false
                }
            } catch {
                print("Error deleting task \(convID) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - Hard delete all conversations in local DB
    public func hardDeleteAll() {
        if let localRealm = localRealm {
            do {
                let obj = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "isDelete = %d", true))
                guard !obj.isEmpty else { return }
                try localRealm.write {
                    localRealm.delete(obj)
                }
            } catch {
                //                print("Error deleting task \(convID) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - hard delete single conversation
    public func hardConvDelete(convID:String) {
        if let localRealm = localRealm {
            do {
                let obj = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@", convID))
                guard !obj.isEmpty else { return }
                try localRealm.write {
                    localRealm.delete(obj)
                    self.getAllConversations()
                }
            } catch {
                print("Error deleting task \(convID) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - Get last message "sent time" for perticular conversation
    public func getlastMessageSentForConversation(conversationId: String) -> String {
        if let localRealm = localRealm {
            let msgs = (localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@ AND isDelete = %d", conversationId, false)))
            guard !msgs.isEmpty else { return ""}
            return msgs.last?.lastMessageSentAt.description ?? ""
        }
        return ""
    }
    
    //MARK: - Get last message "action" for perticular conversation
    public func getConversationListLastMessageAction(conversationId: String) -> String {
        guard let localRealm = localRealm else { return "" } // Ensure localRealm is not nil
        
        // Fetch conversation with the given conversationId and isDelete flag is false
        let conversation = localRealm.objects(ConversationDB.self)
            .filter("conversationId == %@ AND isDelete == false", conversationId)
            .first
        
        // Ensure conversation is not nil
        guard let lastMessageDetails = conversation?.lastMessageDetails else { return "" }
        
        // Return the action of the last message
        return lastMessageDetails.action ?? ""
    }
    
    //MARK: - update last message of conversation
    public func updateLastmsg(conId:String,msg: ISMChatLastMessage) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@  AND isDelete = %d", (conId ), false))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    
                    taskToUpdate.first?.lastMessageSentAt = Int(msg.sentAt ?? 00)
                    
                    taskToUpdate.first?.lastMessageDetails?.sentAt = msg.sentAt
                    taskToUpdate.first?.lastMessageDetails?.updatedAt = msg.updatedAt
                    taskToUpdate.first?.lastMessageDetails?.senderName = msg.senderName
                    taskToUpdate.first?.lastMessageDetails?.senderIdentifier = msg.senderIdentifier
                    taskToUpdate.first?.lastMessageDetails?.senderId = msg.senderId
                    taskToUpdate.first?.lastMessageDetails?.conversationId = msg.conversationId
                    taskToUpdate.first?.lastMessageDetails?.body = msg.body
                    taskToUpdate.first?.lastMessageDetails?.messageId = msg.messageId
                    taskToUpdate.first?.lastMessageDetails?.customType = msg.customType
                    taskToUpdate.first?.lastMessageDetails?.action = msg.action
                    taskToUpdate.first?.lastMessageDetails?.messageDeleted = msg.messageDeleted ?? false
                    taskToUpdate.first?.lastMessageDetails?.deletedMessage = msg.messageDeleted ?? false
                    taskToUpdate.first?.lastMessageDetails?.initiatorId = msg.initiatorId
                    taskToUpdate.first?.lastMessageDetails?.initiatorName = msg.initiatorName
                    taskToUpdate.first?.lastMessageDetails?.initiatorIdentifier = msg.initiatorIdentifier
                    taskToUpdate.first?.lastMessageDetails?.memberId = msg.memberId ?? ""
                    taskToUpdate.first?.lastMessageDetails?.memberName = msg.memberName ?? ""
                    taskToUpdate.first?.lastMessageDetails?.userId = msg.userId ?? ""
                    taskToUpdate.first?.lastMessageDetails?.userName = msg.userName
                    taskToUpdate.first?.lastMessageDetails?.userIdentifier = msg.userIdentifier
                    taskToUpdate.first?.lastMessageDetails?.userProfileImageUrl = msg.userProfileImageUrl
                    taskToUpdate.first?.lastMessageDetails?.reactionType = msg.reactionType ?? ""
                    taskToUpdate.first?.lastMessageDetails?.readBy.removeAll()
                    taskToUpdate.first?.lastMessageDetails?.deliveredTo.removeAll()
                    
                    taskToUpdate.first?.lastMessageDetails?.meetingId = msg.meetingId ?? ""
                    if let duration = msg.callDurations{
                        for x in duration{
                            let value = ISMMeetingDuration()
                            value.memberId = x.memberId
                            value.durationInMilliseconds = x.durationInMilliseconds
                            taskToUpdate.first?.lastMessageDetails?.callDurations.append(value)
                        }
                    }
                    if let missedByMembers = msg.missedByMembers{
                        for x in missedByMembers{
                            taskToUpdate.first?.lastMessageDetails?.missedByMembers.append(x)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - update last message detail
    public func updateLastMessageDetails(conId:String,msgObj:MessagesDB) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@  AND isDelete = %d", (conId ), false))
            if !taskToUpdate.isEmpty {
                if msgObj.messageId != taskToUpdate.first?.lastMessageDetails?.messageId && msgObj.messageId != "" {
                    self.clearLastMessageDeliverReadInfo(convID: conId)
                }else if msgObj.msgSyncStatus == ISMChatSyncStatus.Local.txt {
                    self.clearLastMessageDeliverReadInfo(convID: conId)
                }
                try! localRealm.write {
                    taskToUpdate.first?.lastMessageSentAt = Int(msgObj.sentAt )
                    //                        let lastMsg = LastMessageDB()
                    taskToUpdate.first?.lastMessageDetails?.sentAt = Double(msgObj.sentAt)
                    //                    lastMsg.updatedAt = msgObj.l
                    taskToUpdate.first?.lastMessageDetails?.senderName = msgObj.senderInfo?.userName
                    taskToUpdate.first?.lastMessageDetails?.senderIdentifier = msgObj.senderInfo?.userIdentifier
                    taskToUpdate.first?.lastMessageDetails?.senderId = msgObj.senderInfo?.userId
                    taskToUpdate.first?.lastMessageDetails?.conversationId = msgObj.conversationId
                    taskToUpdate.first?.lastMessageDetails?.body = msgObj.body
                    taskToUpdate.first?.lastMessageDetails?.messageId = msgObj.messageId
                    taskToUpdate.first?.lastMessageDetails?.customType = msgObj.customType
                    taskToUpdate.first?.lastMessageDetails?.action = msgObj.action
                    taskToUpdate.first?.lastMessageDetails?.msgSyncStatus = msgObj.msgSyncStatus
                    taskToUpdate.first?.lastMessageDetails?.members = msgObj.members
                    taskToUpdate.first?.lastMessageDetails?.userName = msgObj.userName
                    taskToUpdate.first?.lastMessageDetails?.deletedMessage = msgObj.deletedMessage
                    taskToUpdate.first?.lastMessageDetails?.deliveredTo = msgObj.deliveredTo
                    taskToUpdate.first?.lastMessageDetails?.readBy = msgObj.readBy
                    taskToUpdate.first?.lastMessageDetails?.userId = msgObj.userId
                    taskToUpdate.first?.lastMessageDetails?.userIdentifier = msgObj.userIdentifier
                    taskToUpdate.first?.lastMessageDetails?.userProfileImageUrl = msgObj.userProfileImageUrl
                    taskToUpdate.first?.lastMessageDetails?.reactionType = msgObj.reactionType
                    taskToUpdate.first?.lastMessageDetails?.initiatorId = msgObj.initiatorId
                }
            }
        }
    }
    
    //MARK: - clear lastmessagedb deliveredto and readby
    public func clearLastMessageDeliverReadInfo(convID: String){
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(LastMessageDB.self).filter(NSPredicate(format: "conversationId == %@", convID))
                guard !taskToDelete.isEmpty else { return }
                try localRealm.write {
                    taskToDelete.first?.deliveredTo.removeAll()
                    taskToDelete.first?.readBy.removeAll()
                }
            } catch {
                print("Error deleting task \(convID) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - change typing status in conversationList for perticular conversation
    public func changeTypingStatus(convId:String,status:Bool) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@  AND isDelete = %d", (convId ), false))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    taskToUpdate.first?.typing = status
                    self.getAllConversations()
                }
            }
        }
    }
    
    //MARK: - update last message body on edit
    public func updateLastMessageOnEdit(conversationId: String, messageId: String, newBody: String) {
        if let localRealm = localRealm {
            let conversationToUpdate = localRealm.objects(ConversationDB.self).where{$0.conversationId == conversationId && $0.isDelete == false && $0.lastMessageDetails.messageId == messageId}
            try! localRealm.write {
                conversationToUpdate.first?.lastMessageDetails?.body = newBody
                getAllConversations()
            }
        }
    }
    
    //MARK: - add last message in conversationDB on add or remove reaction
    public func addLastMessageOnAddAndRemoveReaction(conversationId: String,action : String,emoji : String,userId: String) {
        if let localRealm = localRealm {
            let conversationToUpdate = localRealm.objects(ConversationDB.self).where{$0.conversationId == conversationId && $0.isDelete == false}
            try! localRealm.write {
                conversationToUpdate.first?.lastMessageDetails?.action = action
                conversationToUpdate.first?.lastMessageDetails?.reactionType = emoji
                conversationToUpdate.first?.lastMessageDetails?.userId = userId
                getAllConversations()
            }
        }
    }
    
    //MARK: -  update unread count in conversationList
    public func updateUnreadCountThroughConId(conId: String,count:Int, reset:Bool = false) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@  AND isDelete = %d", (conId ), false))
            try! localRealm.write {
                taskToUpdate.first?.unreadMessagesCount = reset ? 0 : ((taskToUpdate.first?.unreadMessagesCount ?? 0)) + count
            }
        }
    }
    
    //MARK: - update last message delivered
    public func updateLastmsgDeliver(conId:String,messageId : String,userId : String,updatedAt : Double) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(LastMessageDB.self).filter(NSPredicate(format: "conversationId == %@ AND messageId == %@", (conId ), (messageId ?? "")))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    taskToUpdate.first?.readBy.removeAll()
                    taskToUpdate.first?.deliveredTo.removeAll()
                    
                    let deliverObj = MessageDeliveryStatusDB()
                    deliverObj.userId = userId
                    deliverObj.timestamp = updatedAt
                    
                    taskToUpdate.first?.deliveredTo.append(deliverObj)
                }
            }
        }
    }
    
    //MARK: -  update last message delivery info
    public func updateLastmsgDeliverInfo(conId:String,msgId: String,userId: String, updatedAt: Double) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(LastMessageDB.self).filter(NSPredicate(format: "conversationId == %@", (conId )))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    taskToUpdate.first?.readBy.removeAll()
                    taskToUpdate.first?.deliveredTo.removeAll()
                    
                    let deliverObj = MessageDeliveryStatusDB()
                    deliverObj.userId = userId
                    deliverObj.timestamp = updatedAt
                    
                    taskToUpdate.first?.deliveredTo.append(deliverObj)
                    
                }
            }
        }
    }
    
    //MARK: -  update last message read info
    public func updateLastmsgReadInfo(conId:String,msgId: String,userId: String, updatedAt: Double) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(LastMessageDB.self).filter(NSPredicate(format: "conversationId == %@", (conId )))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    
                    taskToUpdate.first?.readBy.removeAll()
                    taskToUpdate.first?.deliveredTo.removeAll()
                    
                    let deliverObj = MessageDeliveryStatusDB()
                    deliverObj.userId = userId
                    deliverObj.timestamp = updatedAt
                    
                    taskToUpdate.first?.deliveredTo.append(deliverObj)
                    taskToUpdate.first?.readBy.append(deliverObj)
                    
                }
            }
        }
    }
    
    //MARK: -  update last message read
    public func updateLastmsgRead(conId:String,messageId : String,userId : String,updatedAt : Double) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(LastMessageDB.self).filter(NSPredicate(format: "conversationId == %@", (conId )))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    
                    let deliverObj = MessageDeliveryStatusDB()
                    deliverObj.userId = userId
                    deliverObj.timestamp = updatedAt
                    taskToUpdate.first?.readBy.append(deliverObj)
                }
            }
        }
    }
    
    
    
    public func updateImageAndNameOfGroup(name : String,image : String,convID: String){
        if let localRealm = localRealm {
            do {
                let taskToUpdate = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@", convID))
                guard !taskToUpdate.isEmpty else { return }
                try localRealm.write {
                    taskToUpdate.first?.conversationTitle = name
                    taskToUpdate.first?.conversationImageUrl = image
                }
            } catch {
                print("Error deleting task \(convID) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - CLEAR/DELETE LAST MESSAGE FOR CONVERSATION lIST
    public func clearLastMessageFromConversationList(convID: String){
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(LastMessageDB.self).filter(NSPredicate(format: "conversationId == %@", convID))
                guard !taskToDelete.isEmpty else { return }
                //just delete all except sentAt or it will create date issue in ISMCONVERSATIONVIEW
                try localRealm.write {
                    taskToDelete.first?.body = nil
                    taskToDelete.first?.action = nil
                    taskToDelete.first?.customType = nil
                }
            } catch {
                print("Error deleting task \(convID) to Realm: \(error)")
            }
        }
    }
    
    public func isConversationExists(conversationID: String) -> Bool {
        do {
            let realm = try Realm()
            // Query the ConversationDB table to find an existing conversation with the given primary key
            return realm.object(ofType: ConversationDB.self, forPrimaryKey: conversationID) != nil
        } catch {
            print("Error checking if conversation exists: \(error.localizedDescription)")
            return false
        }
    }
}
