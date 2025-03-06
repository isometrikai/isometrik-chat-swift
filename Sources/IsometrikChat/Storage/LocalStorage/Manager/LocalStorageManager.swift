//
//  LocalBDManager.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 24/02/25.
//

import SwiftData
import Foundation
import SwiftUI

public class LocalStorageManager: ChatStorageManager {
    
    public var userData = ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig
    public let modelContainer: ModelContainer
    public let modelContext: ModelContext
    
    public init() throws {
        let schema = Schema([ISMChatConversationDB.self, ISMChatMessagesDB.self, ISMChatUserDB.self, ISMChatConfigDB.self,ISMChatLastMessageDB.self,ISMChatConversationMetaData.self,ISMChatMessagesDB.self,ISMChatUserMetaDataDB.self,ISMChatMetaDataDB.self,ISMChatMessageDeliveryStatusDB.self,ISMChatLastMessageMemberDB.self, ISMChatMeetingDuration.self,ISMChatMentionedUserDB.self,ISMChatAttachmentDB.self, ISMChatReactionDB.self,ISMChatMeetingConfig.self])
        let modelConfiguration = ModelConfiguration(schema: schema)
        self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        self.modelContext = ModelContext(modelContainer)
    }
    
    
    public func fetchConversations() async throws -> [ISMChatConversationDB] {
        do {
            let descriptor = FetchDescriptor<ISMChatConversationDB>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
            var conversations = try modelContext.fetch(descriptor)
            
            // Sort by lastMessageSentAt in descending order
            conversations.sort { $0.lastMessageSentAt > $1.lastMessageSentAt }
            
            // Remove broadcast list from conversation list
            let filteredConversations = conversations.filter { conversation in
                !(conversation.opponentDetails?.userId == nil &&
                  conversation.opponentDetails?.userName == nil &&
                  conversation.isGroup == false)
            }
            
            return filteredConversations
        } catch {
            print("Fetch Error: \(error)")
            return []
        }
    }
    
    public func saveConversation(_ conversations: [ISMChatConversationDB]) async throws {
        for obj in conversations {
            if let conversationId = obj.conversationId {
                let descriptor = FetchDescriptor<ISMChatConversationDB>(
                    predicate: #Predicate { $0.conversationId == conversationId }
                )
                do {
                    let existingConversations = try modelContext.fetch(descriptor)
                    
                    if existingConversations.isEmpty {
                        // ✅ Add New Conversation
                        modelContext.insert(obj)
                        try modelContext.save()
                    } else if let existing = existingConversations.first {
                        // 🔄 Update if not deleted
                        try modelContext.save()
                    }
                    
                } catch {
                    print("SwiftData Error: \(error)")
                }
            }
        }
    }
    
    public func deleteConversation(conversationId: String) async throws {
        await MainActor.run {
            let descriptor = FetchDescriptor<ISMChatConversationDB>(
                predicate: #Predicate { $0.conversationId == conversationId }
            )

            do {
                let conversationsToDelete = try modelContext.fetch(descriptor)
                guard let conversation = conversationsToDelete.first else { return }

                modelContext.delete(conversation) // Directly delete the conversation
            } catch {
                print("Error deleting conversation \(conversationId) in SwiftData: \(error)")
            }
        }
    }
    
    public func clearConversationMessages(conversationId: String) async throws {
        do {
            let descriptor = FetchDescriptor<ISMChatConversationDB>(
                predicate: #Predicate { $0.conversationId == conversationId }
            )
            
            if let existingConversation = try modelContext.fetch(descriptor).first {
                // Delete all messages using forEach
                existingConversation.messages.forEach { modelContext.delete($0) }

                // Save changes
                try modelContext.save()
            }
        } catch {
            print("SwiftData Delete Error: \(error)")
        }
    }

    
    public func fetchMessages(conversationId: String,lastMessageTimestamp: String) async throws -> [ISMChatMessagesDB] {
        do {
            let descriptor = FetchDescriptor<ISMChatMessagesDB>(
                predicate: #Predicate { $0.conversationId == conversationId }
            )
            let messages = try modelContext.fetch(descriptor)
            return messages
        } catch {
            print("Fetch Messages Error: \(error)")
            return []
        }
    }
    
    public func saveAllMessages(_ messages: [ISMChatMessagesDB], conversationId: String) async throws {
        do {
            let descriptor = FetchDescriptor<ISMChatConversationDB>(
                predicate: #Predicate { $0.conversationId == conversationId }
            )

            if let existingConversation = try modelContext.fetch(descriptor).first {
                let existingMessageIds = Set(existingConversation.messages.map { $0.messageId })

                // ✅ Filter out messages that already exist
                let newMessages = messages.filter { !existingMessageIds.contains($0.messageId) }

                if !newMessages.isEmpty {
                    existingConversation.messages.append(contentsOf: newMessages)
                    try modelContext.save()
                }
            }
        } catch {
            print("SwiftData Save Error: \(error)")
        }
    }




    
    
    
    
    
    
 
    
    // 🔄 Fetch Other Conversations
//    public func fetchOtherConversations() -> [ISMChatConversationDB] {
//        do {
//            let descriptor = FetchDescriptor<ISMChatConversationDB>()
//            let allConversations = try modelContext.fetch(descriptor)
//            
//            return allConversations.filter { conversation in
//                guard conversation.createdBy != userData?.userId else { return false }
//                
//                if let userProfileType = ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userProfileType {
//                    if userProfileType == ISMChatUserProfileType.Bussiness.value {
//                        if let metaData = conversation.opponentDetails?.metaData,
//                           let conversationMetaData = conversation.metaData,
//                           metaData.userType == 1,
//                           conversationMetaData.chatStatus == ISMChatStatus.Reject.value {
//                            return true
//                        }
//                    } else if userProfileType == ISMChatUserProfileType.Influencer.value {
//                        if let metaData = conversation.opponentDetails?.metaData,
//                           let conversationMetaData = conversation.metaData,
//                           metaData.userType == 1,
//                           metaData.isStarUser != true,
//                           conversationMetaData.chatStatus == ISMChatStatus.Reject.value {
//                            return true
//                        }
//                    }
//                }
//                return false
//            }
//        } catch {
//            print("Fetch Error: \(error)")
//            return []
//        }
//    }
    
    // 🔄 Fetch Other Conversations Count
//    public func fetchOtherConversationCount() -> Int {
//        return fetchOtherConversations().count
//    }
    
    // 🔄 Fetch Primary Conversations
//    public func fetchPrimaryConversations() -> [ISMChatConversationDB] {
//        let allConversations = (try? modelContext.fetch(FetchDescriptor<ISMChatConversationDB>())) ?? []
//        let otherConversations = fetchOtherConversations()
//        return allConversations.filter { conversation in
//            !otherConversations.contains(where: { $0.id == conversation.id })
//        }
//    }
    
    // 🔄 Fetch Primary Conversations Count
//    public func fetchPrimaryConversationCount() -> Int {
//        return fetchPrimaryConversations().count
//    }
    
    
    // Manage Conversation List
//    public func manageConversationList(arr: [ISMChatConversationsDetail]) {
//    }
    
    
    
    // ✅ Add New Conversation
//    public func addConversation(obj: [ISMChatConversationsDetail], modelContext: ModelContext) {
//        for value in obj {
//            let userMataData = ISMChatUserMetaDataDB(
//                userId: value.opponentDetails?.metaData?.userId ?? "",
//                userType: value.opponentDetails?.metaData?.userType ?? 0,
//                isStarUser: value.opponentDetails?.metaData?.isStarUser ?? false,
//                userTypeString: value.opponentDetails?.metaData?.userTypeString ?? "")
//            
//            let opponentDetails = ISMChatUserDB(
//                userId: value.opponentDetails?.userId ?? "",
//                userProfileImageUrl: value.opponentDetails?.userProfileImageUrl ?? "",
//                userName: value.opponentDetails?.userName ?? "",
//                userIdentifier: value.opponentDetails?.userIdentifier ?? "",
//                online: value.opponentDetails?.online ?? false,
//                lastSeen: value.opponentDetails?.lastSeen ?? 0,
//                metaData: userMataData)
//            
//            let config = ISMChatConfigDB(
//                typingEvents: value.config?.typingEvents,
//                readEvents: value.config?.readEvents,
//                pushNotifications: value.config?.pushNotifications)
//            
//            var contactsValue : [ISMChatContactDB] = []
//            if let contacts = value.lastMessageDetails?.metaData?.contacts{
//                for contact in contacts {
//                    let x = ISMChatContactDB(
//                        contactName: contact.contactName,
//                        contactIdentifier: contact.contactIdentifier,
//                        contactImageUrl: contact.contactImageUrl)
//                    contactsValue.append(x)
//                }
//            }
//            
//            var paymentRequestMembersValue : [ISMChatPaymentRequestMembersDB] = []
//            if let members = value.lastMessageDetails?.metaData?.paymentRequestedMembers{
//                for member in members {
//                    let x = ISMChatPaymentRequestMembersDB(userId: member.userId, userName: member.userName, status: member.status, statusText: member.statusText, appUserId: member.appUserId, userProfileImage: member.userProfileImage, declineReason: member.declineReason)
//                    paymentRequestMembersValue.append(x)
//                }
//            }
//            
//            var inviteMembersValue : [ISMChatPaymentRequestMembersDB] = []
//            if let members = value.lastMessageDetails?.metaData?.inviteMembers{
//                for member in members {
//                    let x = ISMChatPaymentRequestMembersDB(userId: member.userId, userName: member.userName, status: member.status, statusText: member.statusText, appUserId: member.appUserId, userProfileImage: member.userProfileImage, declineReason: member.declineReason)
//                    inviteMembersValue.append(x)
//                }
//            }
//            
//            let lastMessageMetaData = ISMChatMetaDataDB(
//                locationAddress: value.lastMessageDetails?.metaData?.locationAddress,
//                replyMessage: ISMChatReplyMessageDB(
//                    parentMessageId: value.lastMessageDetails?.metaData?.replyMessage?.parentMessageId,
//                    parentMessageBody: value.lastMessageDetails?.metaData?.replyMessage?.parentMessageBody,
//                    parentMessageUserId:  value.lastMessageDetails?.metaData?.replyMessage?.parentMessageUserId,
//                    parentMessageUserName:  value.lastMessageDetails?.metaData?.replyMessage?.parentMessageUserName,
//                    parentMessageMessageType:  value.lastMessageDetails?.metaData?.replyMessage?.parentMessageMessageType,
//                    parentMessageAttachmentUrl:  value.lastMessageDetails?.metaData?.replyMessage?.parentMessageAttachmentUrl,
//                    parentMessageInitiator:  value.lastMessageDetails?.metaData?.replyMessage?.parentMessageInitiator,
//                    parentMessagecaptionMessage:  value.lastMessageDetails?.metaData?.replyMessage?.parentMessagecaptionMessage),
//                contacts: contactsValue,
//                captionMessage: value.lastMessageDetails?.metaData?.captionMessage,
//                isBroadCastMessage: value.lastMessageDetails?.metaData?.isBroadCastMessage,
//                post: ISMChatPostDB(
//                    postId: value.lastMessageDetails?.metaData?.post?.postId,
//                    postUrl: value.lastMessageDetails?.metaData?.post?.postUrl),
//                product: ISMChatProductDB(
//                    productId: value.lastMessageDetails?.metaData?.product?.productId,
//                    productUrl: value.lastMessageDetails?.metaData?.product?.productUrl,
//                    productCategoryId: value.lastMessageDetails?.metaData?.product?.productCategoryId),
//                storeName: value.lastMessageDetails?.metaData?.storeName,
//                productName: value.lastMessageDetails?.metaData?.productName,
//                bestPrice: value.lastMessageDetails?.metaData?.bestPrice,
//                scratchPrice: value.lastMessageDetails?.metaData?.scratchPrice,
//                url: value.lastMessageDetails?.metaData?.url,
//                parentProductId: value.lastMessageDetails?.metaData?.parentProductId,
//                childProductId: value.lastMessageDetails?.metaData?.childProductId,
//                entityType: value.lastMessageDetails?.metaData?.entityType,
//                productImage: value.lastMessageDetails?.metaData?.productImage,
//                thumbnailUrl: value.lastMessageDetails?.metaData?.thumbnailUrl,
//                Description: value.lastMessageDetails?.metaData?.description,
//                isVideoPost: value.lastMessageDetails?.metaData?.isVideoPost,
//                socialPostId: value.lastMessageDetails?.metaData?.socialPostId,
//                collectionTitle: value.lastMessageDetails?.metaData?.collectionTitle,
//                collectionDescription: value.lastMessageDetails?.metaData?.collectionDescription,
//                productCount: value.lastMessageDetails?.metaData?.productCount,
//                collectionImage: value.lastMessageDetails?.metaData?.collectionImage,
//                collectionId: value.lastMessageDetails?.metaData?.collectionId,
//                paymentRequestId: value.lastMessageDetails?.metaData?.paymentRequestId,
//                orderId: value.lastMessageDetails?.metaData?.orderId,
//                paymentRequestedMembers: paymentRequestMembersValue,
//                requestAPaymentExpiryTime: value.lastMessageDetails?.metaData?.requestAPaymentExpiryTime,
//                currencyCode: value.lastMessageDetails?.metaData?.currencyCode,
//                amount: value.lastMessageDetails?.metaData?.amount,
//                inviteTitle: value.lastMessageDetails?.metaData?.inviteTitle,
//                inviteTimestamp: value.lastMessageDetails?.metaData?.inviteTimestamp,
//                inviteRescheduledTimestamp: value.lastMessageDetails?.metaData?.inviteRescheduledTimestamp,
//                inviteLocation: ISMChatLocationDB(
//                    name: value.lastMessageDetails?.metaData?.inviteLocation?.name,
//                    latitude: value.lastMessageDetails?.metaData?.inviteLocation?.latitude,
//                    longitude: value.lastMessageDetails?.metaData?.inviteLocation?.longitude),
//                inviteMembers: inviteMembersValue,
//                groupCastId: value.lastMessageDetails?.metaData?.groupCastId,
//                status: value.lastMessageDetails?.metaData?.status)
//            
//            var deliveredToValue : [ISMChatMessageDeliveryStatusDB] = []
//            if let members = value.lastMessageDetails?.deliveredTo{
//                for member in members {
//                    let x = ISMChatMessageDeliveryStatusDB(userId: member.userId, timestamp: member.timestamp)
//                    deliveredToValue.append(x)
//                }
//            }
//            var readByValue : [ISMChatMessageDeliveryStatusDB] = []
//            if let members = value.lastMessageDetails?.readBy{
//                for member in members {
//                    let x = ISMChatMessageDeliveryStatusDB(userId: member.userId, timestamp: member.timestamp)
//                    readByValue.append(x)
//                }
//            }
//            
//            var memebersValue : [ISMChatLastMessageMemberDB] = []
//            if let members = value.lastMessageDetails?.members{
//                for member in members {
//                    let x = ISMChatLastMessageMemberDB(memberProfileImageUrl: member.memberProfileImageUrl, memberName: member.memberName, memberIdentifier: member.memberIdentifier, memberId: member.memberId)
//                    memebersValue.append(x)
//                }
//            }
//            
//            var callDurationsValue : [ISMChatMeetingDuration] = []
//            if let calls = value.lastMessageDetails?.callDurations{
//                for call in calls {
//                    let x = ISMChatMeetingDuration(memberId: call.memberId, durationInMilliseconds: call.durationInMilliseconds)
//                    callDurationsValue.append(x)
//                }
//            }
//            
//            let lastMessageDetails = ISMChatLastMessageDB(
//                sentAt: value.lastMessageDetails?.sentAt,
//                updatedAt: value.lastMessageDetails?.updatedAt,
//                senderName: value.lastMessageDetails?.senderName,
//                senderIdentifier: value.lastMessageDetails?.senderIdentifier,
//                senderId: value.lastMessageDetails?.senderId,
//                conversationId: value.lastMessageDetails?.conversationId,
//                body: value.lastMessageDetails?.body,
//                messageId: value.lastMessageDetails?.messageId,
//                customType: value.lastMessageDetails?.customType,
//                action: value.lastMessageDetails?.action,
//                metaData: lastMessageMetaData,
//                metaDataJsonString: value.lastMessageDetails?.metaDataJson,
//                deliveredTo: deliveredToValue,
//                readBy: readByValue,
//                msgSyncStatus: "",
//                reactionType: value.lastMessageDetails?.reactionType ?? "",
//                userId: value.lastMessageDetails?.userId ?? "",
//                userIdentifier: value.lastMessageDetails?.userIdentifier,
//                userName: value.lastMessageDetails?.userName,
//                userProfileImageUrl: value.lastMessageDetails?.userProfileImageUrl,
//                members: memebersValue,
//                memberName: value.lastMessageDetails?.memberName ?? "",
//                memberId: value.lastMessageDetails?.memberId ?? "",
//                messageDeleted: value.lastMessageDetails?.messageDeleted ?? false,
//                initiatorName: value.lastMessageDetails?.initiatorName ?? "",
//                initiatorId: value.lastMessageDetails?.initiatorId,
//                initiatorIdentifier: value.lastMessageDetails?.initiatorIdentifier,
//                deletedMessage: false,
//                meetingId: value.lastMessageDetails?.meetingId,
//                missedByMembers: value.lastMessageDetails?.missedByMembers ?? [],
//                callDurations: callDurationsValue)
//            
//            let conversation = ISMChatConversationDB(
//                conversationId: value.conversationId ?? "",
//                updatedAt: value.lastMessageDetails?.updatedAt ?? 0,
//                unreadMessagesCount: value.unreadMessagesCount ?? 0,
//                membersCount: value.membersCount ?? 0,
//                lastMessageSentAt: value.lastMessageSentAt ?? 0,
//                createdAt: value.createdAt ?? 0,
//                mode: "mode",
//                conversationTitle: value.conversationTitle ?? "",
//                conversationImageUrl: value.conversationImageUrl ?? "",
//                createdBy: value.createdBy ?? "",
//                createdByUserName: value.createdByUserName ?? "",
//                privateOneToOne: value.privateOneToOne ?? false,
//                messagingDisabled: false,
//                isGroup: value.isGroup ?? false,
//                typing: value.typing ?? false,
//                isDelete: false,
//                userIds: [],
//                opponentDetails: opponentDetails,
//                config: config,
//                lastMessageDetails: lastMessageDetails,
//                deletedMessage: false,
//                metaData: ISMChatConversationMetaData(chatStatus: value.metaData?.chatStatus ?? "", membersIds: value.metaData?.membersIds ?? []),
//                metaDataJson: value.metaDataJson,
//                lastInputText: "")
//            
//            modelContext.insert(conversation)
//        }
//        
//        do {
//            try modelContext.save()
//            fetchAllConversations()  // Fetch after saving
//        } catch {
//            print("Error saving to SwiftData: \(error.localizedDescription)")
//        }
//    }
    
    
    // 🔄 Update if not deleted
//    public func updateConversation(existing: ISMChatConversationDB, obj: ISMChatConversationsDetail, modelContext: ModelContext) {
//        existing.updatedAt = obj.lastMessageDetails?.updatedAt ?? existing.updatedAt
//        existing.unreadMessagesCount = obj.unreadMessagesCount ?? existing.unreadMessagesCount
//        existing.membersCount = obj.membersCount ?? existing.membersCount
//        existing.lastMessageSentAt = obj.lastMessageSentAt ?? existing.lastMessageSentAt
//        existing.conversationTitle = obj.conversationTitle ?? existing.conversationTitle
//        existing.conversationImageUrl = obj.conversationImageUrl ?? existing.conversationImageUrl
//        existing.privateOneToOne = obj.privateOneToOne ?? existing.privateOneToOne
//        existing.isGroup = obj.isGroup ?? existing.isGroup
//        
//        // Update Opponent Details
//        existing.opponentDetails = ISMChatUserDB(
//            userId: obj.opponentDetails?.userId ?? existing.opponentDetails?.userId ?? "",
//            userProfileImageUrl: obj.opponentDetails?.userProfileImageUrl ?? existing.opponentDetails?.userProfileImageUrl ?? "",
//            userName: obj.opponentDetails?.userName ?? existing.opponentDetails?.userName ?? "",
//            userIdentifier: obj.opponentDetails?.userIdentifier ?? existing.opponentDetails?.userIdentifier ?? "",
//            online: obj.opponentDetails?.online ?? existing.opponentDetails?.online ?? false,
//            lastSeen: obj.opponentDetails?.lastSeen ?? existing.opponentDetails?.lastSeen ?? 0,
//            metaData: existing.opponentDetails?.metaData
//        )
//        
//        // Update Last Message Metadata
//        var deliveredToValue: [ISMChatMessageDeliveryStatusDB] = []
//        if let deliveredTo = obj.lastMessageDetails?.deliveredTo {
//            for member in deliveredTo {
//                deliveredToValue.append(ISMChatMessageDeliveryStatusDB(userId: member.userId, timestamp: member.timestamp))
//            }
//        }
//        
//        var readByValue: [ISMChatMessageDeliveryStatusDB] = []
//        if let readBy = obj.lastMessageDetails?.readBy {
//            for member in readBy {
//                readByValue.append(ISMChatMessageDeliveryStatusDB(userId: member.userId, timestamp: member.timestamp))
//            }
//        }
//        
//        var membersValue: [ISMChatLastMessageMemberDB] = []
//        if let members = obj.lastMessageDetails?.members {
//            for member in members {
//                membersValue.append(ISMChatLastMessageMemberDB(
//                    memberProfileImageUrl: member.memberProfileImageUrl,
//                    memberName: member.memberName,
//                    memberIdentifier: member.memberIdentifier,
//                    memberId: member.memberId
//                ))
//            }
//        }
//        
//        var callDurationsValue: [ISMChatMeetingDuration] = []
//        if let calls = obj.lastMessageDetails?.callDurations {
//            for call in calls {
//                callDurationsValue.append(ISMChatMeetingDuration(memberId: call.memberId, durationInMilliseconds: call.durationInMilliseconds))
//            }
//        }
//        
//        existing.lastMessageDetails = ISMChatLastMessageDB(
//            sentAt: obj.lastMessageDetails?.sentAt,
//            updatedAt: obj.lastMessageDetails?.updatedAt,
//            senderName: obj.lastMessageDetails?.senderName,
//            senderIdentifier: obj.lastMessageDetails?.senderIdentifier,
//            senderId: obj.lastMessageDetails?.senderId,
//            conversationId: obj.lastMessageDetails?.conversationId,
//            body: obj.lastMessageDetails?.body,
//            messageId: obj.lastMessageDetails?.messageId,
//            customType: obj.lastMessageDetails?.customType,
//            action: obj.lastMessageDetails?.action,
//            metaData: existing.lastMessageDetails?.metaData,
//            metaDataJsonString: obj.lastMessageDetails?.metaDataJson,
//            deliveredTo: deliveredToValue,
//            readBy: readByValue,
//            msgSyncStatus: existing.lastMessageDetails?.msgSyncStatus ?? "",
//            reactionType: obj.lastMessageDetails?.reactionType ?? "",
//            userId: obj.lastMessageDetails?.userId ?? "",
//            userIdentifier: obj.lastMessageDetails?.userIdentifier,
//            userName: obj.lastMessageDetails?.userName,
//            userProfileImageUrl: obj.lastMessageDetails?.userProfileImageUrl,
//            members: membersValue,
//            memberName: obj.lastMessageDetails?.memberName ?? "",
//            memberId: obj.lastMessageDetails?.memberId ?? "",
//            messageDeleted: obj.lastMessageDetails?.messageDeleted ?? false,
//            initiatorName: obj.lastMessageDetails?.initiatorName ?? "",
//            initiatorId: obj.lastMessageDetails?.initiatorId,
//            initiatorIdentifier: obj.lastMessageDetails?.initiatorIdentifier,
//            deletedMessage: false,
//            meetingId: obj.lastMessageDetails?.meetingId,
//            missedByMembers: obj.lastMessageDetails?.missedByMembers ?? [],
//            callDurations: callDurationsValue
//        )
//        
//        do {
//            try modelContext.save()
//            print("Conversation updated successfully")
//        } catch {
//            print("Error updating conversation: \(error.localizedDescription)")
//        }
//    }
    
    // 🗑️ Delete All Conversations (Optional for syncing)
//    public func deleteAllConversations() {
//        let products = fetchAllConversations()
//        for product in products {
//            modelContext.delete(product)
//        }
//        
//        do {
//            try modelContext.save()
//        } catch {
//            print("Delete Error: \(error)")
//        }
//    }
    
    // 🗑️ Delete All Conversations (Optional for syncing)
//    public func hardDeleteAll() {
//        do {
//            let descriptor = FetchDescriptor<ISMChatConversationDB>
//            let objectsToDelete = try modelContext.fetch(descriptor)
//            
//            guard !objectsToDelete.isEmpty else { return }
//            
//            for obj in objectsToDelete {
//                modelContext.delete(obj)
//            }
//        } catch {
//            print("Error deleting conversations: \(error)")
//        }
//    }
    
    // Update Last Message Of Conversation
    public func updateLastmsg(conId: String, msg: ISMChatLastMessage) {
        do {
            let descriptor = FetchDescriptor<ISMChatConversationDB>(predicate: #Predicate { $0.conversationId == conId})
            let taskToUpdate = try modelContext.fetch(descriptor)
            
            guard let conversation = taskToUpdate.first else { return }
            
            conversation.lastMessageSentAt = Int(msg.sentAt ?? 0)
            
            conversation.lastMessageDetails?.sentAt = msg.sentAt
            conversation.lastMessageDetails?.updatedAt = msg.updatedAt
            conversation.lastMessageDetails?.senderName = msg.senderName
            conversation.lastMessageDetails?.senderIdentifier = msg.senderIdentifier
            conversation.lastMessageDetails?.senderId = msg.senderId
            conversation.lastMessageDetails?.conversationId = msg.conversationId
            conversation.lastMessageDetails?.body = msg.body
            conversation.lastMessageDetails?.messageId = msg.messageId
            conversation.lastMessageDetails?.customType = msg.customType
            conversation.lastMessageDetails?.action = msg.action
            conversation.lastMessageDetails?.messageDeleted = msg.messageDeleted ?? false
            conversation.lastMessageDetails?.deletedMessage = msg.messageDeleted ?? false
            conversation.lastMessageDetails?.initiatorId = msg.initiatorId
            conversation.lastMessageDetails?.initiatorName = msg.initiatorName
            conversation.lastMessageDetails?.initiatorIdentifier = msg.initiatorIdentifier
            conversation.lastMessageDetails?.memberId = msg.memberId ?? ""
            conversation.lastMessageDetails?.memberName = msg.memberName ?? ""
            conversation.lastMessageDetails?.userId = msg.userId ?? ""
            conversation.lastMessageDetails?.userName = msg.userName
            conversation.lastMessageDetails?.userIdentifier = msg.userIdentifier
            conversation.lastMessageDetails?.userProfileImageUrl = msg.userProfileImageUrl
            conversation.lastMessageDetails?.reactionType = msg.reactionType ?? ""
            conversation.lastMessageDetails?.readBy.removeAll()
            conversation.lastMessageDetails?.deliveredTo.removeAll()
            
            conversation.lastMessageDetails?.meetingId = msg.meetingId ?? ""
            
            if let duration = msg.callDurations {
                conversation.lastMessageDetails?.callDurations = duration.map { x in
                    let value = ISMChatMeetingDuration()
                    value.memberId = x.memberId
                    value.durationInMilliseconds = x.durationInMilliseconds
                    return value
                }
            }
            
            if let missedByMembers = msg.missedByMembers {
                conversation.lastMessageDetails?.missedByMembers = missedByMembers
            }
            
        } catch {
            print("Error updating last message: \(error)")
        }
    }
    
    // Update Unread Count in Conversation List
    public func updateUnreadCountThroughConId(conId: String, count: Int, reset: Bool = false) {
        do {
            if let conversation = try modelContext.fetch(FetchDescriptor<ISMChatConversationDB>(predicate: #Predicate { $0.conversationId == conId })).first {
                conversation.unreadMessagesCount = reset ? 0 : (conversation.unreadMessagesCount + count)
                try modelContext.save()
            }
        } catch {
            print("Failed to update unread count: \(error)")
        }
    }
    
    // Change Typing Status in Conversation List
    public func changeTypingStatus(convId: String, status: Bool) {
        do {
            if let conversation = try modelContext.fetch(FetchDescriptor<ISMChatConversationDB>(predicate: #Predicate { $0.conversationId == convId })).first {
                conversation.typing = status
                try modelContext.save()
            }
        } catch {
            print("Failed to update typing status: \(error)")
        }
    }
    
    // Undo Delete Conversation
//    public func undodeleteConversation(convID: String) {
//        do {
//            let descriptor = FetchDescriptor<ISMChatConversationDB>(
//                predicate: #Predicate { $0.conversationId == convID && $0.isDelete == true }
//            )
//            
//            if let conversation = try modelContext.fetch(descriptor).first {
//                conversation.isDelete = false
//                try modelContext.save()
//            }
//        } catch {
//            print("Error restoring conversation \(convID): \(error)")
//        }
//    }
    
}
