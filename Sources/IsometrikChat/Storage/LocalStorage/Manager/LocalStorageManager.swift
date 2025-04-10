//
//  LocalBDManager.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 24/02/25.
//

import SwiftData
import CoreData
import Foundation
import SwiftUI

public class LocalStorageManager: ChatStorageManager {
    public var userData = ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig
    public let modelContainer: ModelContainer
    public let modelContext: ModelContext
    
    public init() throws {
        let schema = Schema([
            ISMChatConversationDB.self, ISMChatMessagesDB.self, ISMChatUserDB.self, ISMChatConfigDB.self,
            ISMChatLastMessageDB.self, ISMChatConversationMetaData.self, ISMChatUserMetaDataDB.self,
            ISMChatMetaDataDB.self, ISMChatMessageDeliveryStatusDB.self, ISMChatLastMessageMemberDB.self,
            ISMChatMeetingDuration.self, ISMChatMentionedUserDB.self, ISMChatAttachmentDB.self,
            ISMChatReactionDB.self, ISMChatMeetingConfig.self
        ])
        let modelConfiguration = ModelConfiguration(
            "ISMChatSdk.store",
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        self.modelContext = ModelContext(modelContainer)
    }
    
    
    public func deleteSwiftData() async throws {
        do {
            try modelContext.delete(model: ISMChatConversationDB.self)
            try modelContext.delete(model: ISMChatMessagesDB.self)
            try modelContext.delete(model: ISMChatUserDB.self)
            try modelContext.delete(model: ISMChatConfigDB.self)
            try modelContext.delete(model: ISMChatLastMessageDB.self)
            try modelContext.delete(model: ISMChatConversationMetaData.self)
            try modelContext.delete(model: ISMChatUserMetaDataDB.self)
            try modelContext.delete(model: ISMChatMessageDeliveryStatusDB.self)
            try modelContext.delete(model: ISMChatLastMessageMemberDB.self)
            try modelContext.delete(model: ISMChatMeetingDuration.self)
            try modelContext.delete(model: ISMChatMentionedUserDB.self)
            try modelContext.delete(model: ISMChatAttachmentDB.self)
            try modelContext.delete(model: ISMChatReactionDB.self)
            try modelContext.delete(model: ISMChatMeetingConfig.self)
        } catch {
            print("Failed to clear all data.")
        }
    }

    
    public func createConversation(user : ISMChatUserDB,conversationId : String) async throws -> String {
        return ""
    }

    
    
    public func fetchConversations() async throws  -> [ISMChatConversationDB] {
//        let descriptor = FetchDescriptor<ISMChatConversationDB>(
//            sortBy: [SortDescriptor(\.lastMessageDetails?.sentAt, order: .reverse)]
//        )
        let descriptor = FetchDescriptor<ISMChatConversationDB>()

        do {
            let conversations: [ISMChatConversationDB] = try modelContext.fetch(descriptor)
            

            // Remove broadcast list from conversation list
            let filteredConversations = conversations.filter { conversation in
                guard let opponent = conversation.opponentDetails else {
                    return false
                }
                return !(opponent.userId == nil &&
                         opponent.userName == nil &&
                         conversation.isGroup == false)
            }

            let sortedChats = filteredConversations.sorted {
                guard let date1 = $0.lastMessageDetails?.updatedAt else {return false}
                guard let date2 = $1.lastMessageDetails?.updatedAt else {return false}
                return date1 > date2
            }
            return sortedChats
        } catch {
            print("❌ Fetch Error: \(error)")
            return []
        }
    }
    
    public func fetchConversationsLocal() async throws -> [ISMChatConversationDB] {
        let descriptor = FetchDescriptor<ISMChatConversationDB>()

        do {
            let conversations: [ISMChatConversationDB] = try modelContext.fetch(descriptor)
            

            // Remove broadcast list from conversation list
            let filteredConversations = conversations.filter { conversation in
                guard let opponent = conversation.opponentDetails else {
                    return false
                }
                return !(opponent.userId == nil &&
                         opponent.userName == nil &&
                         conversation.isGroup == false)
            }

            let sortedChats = filteredConversations.sorted {
                guard let date1 = $0.lastMessageDetails?.updatedAt else {return false}
                guard let date2 = $1.lastMessageDetails?.updatedAt else {return false}
                return date1 > date2
            }
            return sortedChats
        } catch {
            print("❌ Fetch Error: \(error)")
            return []
        }
    }
    
    @MainActor
    public func saveConversation(_ conversations: [ISMChatConversationDB]) async throws {
        for obj in conversations {
            guard let conversationId = obj.conversationId else { continue }

            let descriptor = FetchDescriptor<ISMChatConversationDB>(
                predicate: #Predicate { $0.conversationId == conversationId }
            )

            do {
                let existingConversations = try await modelContext.fetch(descriptor) // ✅ Now async-safe

                if let existing = existingConversations.first {
                    // ✅ Update existing object instead of re-inserting
                    existing.updatedAt = obj.updatedAt
                    existing.lastMessageDetails = obj.lastMessageDetails
//                    existing.lastMessageDetails?.body = obj.lastMessageDetails?.body
//                    if let objLastMessage = obj.lastMessageDetails {
//                        
//                            let newLastMessage = ISMChatLastMessageDB(
//                                sentAt: objLastMessage.sentAt,
//                                updatedAt: objLastMessage.updatedAt,
//                                senderName: objLastMessage.senderName,
//                                senderIdentifier: objLastMessage.senderIdentifier,
//                                senderId: objLastMessage.senderId,
//                                conversationId: objLastMessage.conversationId,
//                                body: objLastMessage.body,
//                                messageId: objLastMessage.messageId,
//                                customType: objLastMessage.customType,
//                                action: objLastMessage.action,
//                                metaData: objLastMessage.metaData,  // ⚠️ Make sure `metaData` is also from the same context
//                                metaDataJsonString: objLastMessage.metaDataJsonString,
//                                deliveredTo: objLastMessage.deliveredTo,  // ⚠️ Handle this separately if needed
//                                readBy: objLastMessage.readBy,  // ⚠️ Handle this separately if needed
//                                msgSyncStatus: objLastMessage.msgSyncStatus,
//                                reactionType: objLastMessage.reactionType,
//                                userId: objLastMessage.userId,
//                                userIdentifier: objLastMessage.userIdentifier,
//                                userName: objLastMessage.userName,
//                                userProfileImageUrl: objLastMessage.userProfileImageUrl,
//                                members: objLastMessage.members,  // ⚠️ Handle separately if needed
//                                memberName: objLastMessage.memberName,
//                                memberId: objLastMessage.memberId,
//                                messageDeleted: objLastMessage.messageDeleted,
//                                initiatorName: objLastMessage.initiatorName,
//                                initiatorId: objLastMessage.initiatorId,
//                                initiatorIdentifier: objLastMessage.initiatorIdentifier,
//                                deletedMessage: objLastMessage.deletedMessage,
//                                meetingId: objLastMessage.meetingId,
//                                missedByMembers: objLastMessage.missedByMembers ?? [],
//                                callDurations: objLastMessage.callDurations
//                            )
//                            
//                            existing.lastMessageDetails = newLastMessage
//                        
//                        
//                    } else {
//                        existing.lastMessageDetails = nil
//                    }
                    existing.lastMessageSentAt = obj.lastMessageSentAt
                    try modelContext.save()
                } else {
                    var opponentDetails = ISMChatUserDB()
                    if let opponent = obj.opponentDetails{
                        opponentDetails = ISMChatUserDB(userId: opponent.userId, userProfileImageUrl: opponent.userProfileImageUrl, userName: opponent.userName, userIdentifier: opponent.userIdentifier, online: opponent.online, lastSeen: opponent.lastSeen, metaData: opponent.metaData)
                    }
                    let newConversation = ISMChatConversationDB(
                        conversationId: obj.conversationId ?? "",
                                    updatedAt: obj.updatedAt,
                                    unreadMessagesCount: obj.unreadMessagesCount,
                                    membersCount: obj.membersCount,
                                    lastMessageSentAt: obj.lastMessageSentAt,
                                    createdAt: obj.createdAt,
                                    mode: obj.mode,
                                    conversationTitle: obj.conversationTitle,
                                    conversationImageUrl: obj.conversationImageUrl,
                                    createdBy: obj.createdBy,
                                    createdByUserName: obj.createdByUserName,
                                    privateOneToOne: obj.privateOneToOne,
                                    messagingDisabled: obj.messagingDisabled,
                                    isGroup: obj.isGroup,
                                    typing: obj.typing,
                                    userIds: obj.userIds,
                                    opponentDetails: opponentDetails,
                                    config: obj.config,
                                    lastMessageDetails: obj.lastMessageDetails,
                                    deletedMessage: obj.deletedMessage,
                                    metaData: obj.metaData,
                                    metaDataJson: obj.metaDataJson,
                                    lastInputText: obj.lastInputText
                                )
                        modelContext.insert(newConversation)
                    try modelContext.save()
                }
                
            } catch {
                print("SwiftData Error: \(error)")
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
    
    public func deleteAllConversations() async throws {
        await MainActor.run {
            let descriptor = FetchDescriptor<ISMChatConversationDB>()

            do {
                let allConversations = try modelContext.fetch(descriptor)

                for conversation in allConversations {
                    modelContext.delete(conversation)
                }
                modelContext.rollback()
                print("✅ Deleted all conversations from SwiftData")
            } catch {
                print("❌ Error deleting all conversations: \(error)")
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
                //also clear last message 
                existingConversation.lastMessageDetails?.body = nil
                existingConversation.lastMessageDetails?.action = nil
                existingConversation.lastMessageDetails?.customType = nil
                // Save changes
                try modelContext.save()
            }
        } catch {
            print("SwiftData Delete Error: \(error)")
        }
    }
    
    public func updateLastMessageInConversation(conversationId: String, lastMessage: ISMChatLastMessageDB) async throws {
        do {
            let descriptor = FetchDescriptor<ISMChatConversationDB>(
                predicate: #Predicate { $0.conversationId == conversationId }
            )
            
            if let existingConversation = try modelContext.fetch(descriptor).first {
                // Update the last message details
                existingConversation.lastMessageDetails = lastMessage
                existingConversation.lastMessageSentAt = Int(lastMessage.sentAt ?? 0)

                // Save the changes
                try modelContext.save()
            }
        } catch {
            print("Error updating last message: \(error)")
            throw error
        }
    }


    
    public func fetchMessages(conversationId: String,lastMessageTimestamp: String,onlyLocal : Bool) async throws -> [ISMChatMessagesDB] {
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

    
    public func updateMsgId(objectId: UUID, msgId: String, conversationId: String, mediaUrl: String, thumbnailUrl: String, mediaSize: Int, mediaId: String) async throws {
        do {
            print("🔍 Searching for conversation with ID: \(conversationId)")
            
            // Fetch the conversation first
            if let conversation = try modelContext.fetch(FetchDescriptor<ISMChatConversationDB>(predicate: #Predicate { $0.conversationId == conversationId })).first {
                
                print("✅ Conversation found! Checking messages...")
                
                // Ensure messages exist in the conversation
                if !conversation.messages.isEmpty {
                    print("📌 Found \(conversation.messages.count) messages in the conversation.")

                    // Look for the message with the given objectId
                    if let message = conversation.messages.first(where: { $0.id == objectId }) {
                        print("✅ Found message with objectId: \(objectId)")

                        // Update message fields
                        message.messageId = msgId
                        message.msgSyncStatus = ISMChatSyncStatus.Synch.txt
                        
                        if !mediaUrl.isEmpty {
                            message.attachments?.first?.mediaUrl = mediaUrl
                        }
                        if !thumbnailUrl.isEmpty {
                            message.attachments?.first?.thumbnailUrl = thumbnailUrl
                        }
                        if mediaSize != 0 {
                            message.attachments?.first?.size = mediaSize
                        }
                        if !mediaId.isEmpty {
                            message.attachments?.first?.mediaId = mediaId
                        }
                        
                        // Update last message details in conversation
                        conversation.lastMessageDetails?.msgSyncStatus = ISMChatSyncStatus.Synch.txt
                        conversation.lastMessageDetails?.messageId = msgId
                        
                        // Save changes
                        try modelContext.save()
                        print("✅ Message updated successfully!")
                        
                    } else {
                        print("❌ No message found with objectId: \(objectId)")
                    }
                } else {
                    print("❌ No messages found in this conversation.")
                }
            } else {
                print("❌ No conversation found with ID: \(conversationId)")
            }
        } catch {
            print("🚨 Error updating message: \(error.localizedDescription)")
        }
    }

    public func updateMessage(conversationId: String, messageId: String, body: String, metaData: ISMChatMetaDataDB?, customType: String?) async throws {
        do {
            // Fetch conversation using conversationId
            if let conversation = try modelContext.fetch(FetchDescriptor<ISMChatConversationDB>(predicate: #Predicate { $0.conversationId == conversationId })).first {
                
                print("✅ Conversation found for ID: \(conversationId), checking messages...")
                
                // Ensure messages exist
                if !conversation.messages.isEmpty {
                    // Find the message with the given messageId
                    if let messageToUpdate = conversation.messages.first(where: { $0.messageId == messageId }) {
                        
                        print("✅ Found message with messageId: \(messageId), updating...")
                        
                        // Update body and messageUpdated flag
                        messageToUpdate.body = body
                        messageToUpdate.messageUpdated = true
                        
                        // Update customType if provided
                        if let customType = customType, !customType.isEmpty {
                            messageToUpdate.customType = customType
                        }
                        
                        if let metaData = metaData{
                            // Update metadata
                            let metadataValue = ISMChatMetaDataDB()
                            metadataValue.locationAddress = metaData.locationAddress
                            metadataValue.captionMessage = metaData.captionMessage
                            metadataValue.isBroadCastMessage = metaData.isBroadCastMessage
                            metadataValue.storeName = metaData.storeName
                            metadataValue.productName = metaData.productName
                            metadataValue.bestPrice = metaData.bestPrice
                            metadataValue.scratchPrice = metaData.scratchPrice
                            metadataValue.url = metaData.url
                            metadataValue.parentProductId = metaData.parentProductId
                            metadataValue.childProductId = metaData.childProductId
                            metadataValue.entityType = metaData.entityType
                            metadataValue.productImage = metaData.productImage
                            metadataValue.thumbnailUrl = metaData.thumbnailUrl
                            metadataValue.DescriptionValue = metaData.DescriptionValue
                            metadataValue.isVideoPost = metaData.isVideoPost
                            metadataValue.socialPostId = metaData.socialPostId
                            metadataValue.collectionTitle = metaData.collectionTitle
                            metadataValue.collectionDescription = metaData.collectionDescription
                            metadataValue.productCount = metaData.productCount
                            metadataValue.collectionImage = metaData.collectionImage
                            metadataValue.collectionId = metaData.collectionId
                            metadataValue.paymentRequestId = metaData.paymentRequestId
                            metadataValue.orderId = metaData.orderId
                            metadataValue.requestAPaymentExpiryTime = metaData.requestAPaymentExpiryTime
                            metadataValue.currencyCode = metaData.currencyCode
                            metadataValue.amount = metaData.amount
                            
                            if let members = metaData.paymentRequestedMembers {
                                metadataValue.paymentRequestedMembers = members.map { member in
                                    let paymentRequestMembersDB = ISMChatPaymentRequestMembersDB()
                                    paymentRequestMembersDB.userId = member.userId
                                    paymentRequestMembersDB.userName = member.userName
                                    paymentRequestMembersDB.status = member.status
                                    paymentRequestMembersDB.statusText = member.statusText
                                    paymentRequestMembersDB.appUserId = member.appUserId
                                    return paymentRequestMembersDB
                                }
                            }
                            
                            metadataValue.inviteTitle = metaData.inviteTitle
                            metadataValue.status = metaData.status
                            metadataValue.inviteTimestamp = metaData.inviteTimestamp
                            metadataValue.inviteRescheduledTimestamp = metaData.inviteRescheduledTimestamp
                            metadataValue.groupCastId = metaData.groupCastId
                            
                            if let location = metaData.inviteLocation {
                                let locationDB = ISMChatLocationDB()
                                locationDB.name = location.name
                                locationDB.latitude = location.latitude
                                locationDB.longitude = location.longitude
                                metadataValue.inviteLocation = locationDB
                            }
                            
                            if let inviteMembers = metaData.inviteMembers {
                                metadataValue.inviteMembers = inviteMembers.map { member in
                                    let membersDB = ISMChatPaymentRequestMembersDB()
                                    membersDB.userId = member.userId
                                    membersDB.userName = member.userName
                                    membersDB.status = member.status
                                    membersDB.statusText = member.statusText
                                    membersDB.appUserId = member.appUserId
                                    membersDB.userProfileImage = member.userProfileImage
                                    membersDB.declineReason = member.declineReason
                                    return membersDB
                                }
                            }
                            
                            if let replyMessage = metaData.replyMessage {
                                let replyMessageDB = ISMChatReplyMessageDB()
                                replyMessageDB.parentMessageId = replyMessage.parentMessageId
                                replyMessageDB.parentMessageBody = replyMessage.parentMessageBody
                                replyMessageDB.parentMessageUserId = replyMessage.parentMessageUserId
                                replyMessageDB.parentMessageUserName = replyMessage.parentMessageUserName
                                replyMessageDB.parentMessageMessageType = replyMessage.parentMessageMessageType
                                replyMessageDB.parentMessageAttachmentUrl = replyMessage.parentMessageAttachmentUrl
                                replyMessageDB.parentMessageInitiator = replyMessage.parentMessageInitiator
                                replyMessageDB.parentMessagecaptionMessage = replyMessage.parentMessagecaptionMessage
                                metadataValue.replyMessage = replyMessageDB
                            }
                            
                            if let contacts = metaData.contacts {
                                metadataValue.contacts = contacts.map { contact in
                                    let contactDB = ISMChatContactDB()
                                    contactDB.contactName = contact.contactName
                                    contactDB.contactIdentifier = contact.contactIdentifier
                                    contactDB.contactImageUrl = contact.contactImageUrl
                                    return contactDB
                                }
                            }
                            
                            if let post = metaData.post {
                                let postDB = ISMChatPostDB()
                                postDB.postId = post.postId
                                postDB.postUrl = post.postUrl
                                metadataValue.post = postDB
                            }
                            
                            if let product = metaData.product {
                                let productDB = ISMChatProductDB()
                                productDB.productId = product.productId
                                productDB.productUrl = product.productUrl
                                productDB.productCategoryId = product.productCategoryId
                                metadataValue.product = productDB
                            }
                            
                            messageToUpdate.metaData = metadataValue
                            
                            
                            // Convert metadata to JSON and store
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: metaData.toDictionary(), options: [])
                                if let jsonString = String(data: jsonData, encoding: .utf8) {
                                    messageToUpdate.metaDataJsonString = jsonString
                                }
                            } catch {
                                print("Failed to convert metaData to JSON: \(error.localizedDescription)")
                            }
                            
                        }
                        
                        // if updated message is edited then it should also update simultanously
                        if conversation.lastMessageDetails?.messageId == messageId {
                            print("✅ Edited message is the last message in the conversation. Updating last message details...")
                            
                            if let url = metaData?.url{
                                conversation.lastMessageDetails?.body = url
                            }else{
                                conversation.lastMessageDetails?.body = body
                            }
                            
                            if let customType = customType, !customType.isEmpty {
                                conversation.lastMessageDetails?.customType = customType
                            }
                            
                            if let metaData = metaData {
                                conversation.lastMessageDetails?.metaData = metaData
                            }
                        }
                        
                        // Save changes
                        try modelContext.save()
                        print("✅ Message successfully updated!")
                        
                    } else {
                        print("❌ No message found with messageId: \(messageId)")
                    }
                } else {
                    print("❌ No messages found in this conversation.")
                }
            } else {
                print("❌ No conversation found with ID: \(conversationId)")
            }
        } catch {
            print("🚨 Error updating message: \(error.localizedDescription)")
        }
    }


    public func saveMedia(arr: [ISMChatAttachmentDB], conversationId: String, customType: String, sentAt: Double, messageId: String, userName: String)  {
            
            // Step 1: Find conversation using conversationId
            let conversationFetchDescriptor = FetchDescriptor<ISMChatConversationDB>(
                predicate: #Predicate { $0.conversationId == conversationId }
            )
            
            do {
                let conversations = try modelContext.fetch(conversationFetchDescriptor)
                
                guard let conversation = conversations.first else {
                    print("❌ No conversation found for ID: \(conversationId)")
                    return
                }
                
                // Step 2: Check if messageId is already in the conversation's media array
                if conversation.medias.contains(where: { $0.messageId == messageId }) {
                    print("✅ Media already exists for messageId: \(messageId), skipping insert.")
                    return
                }

                // Step 3: Save new media
                for value in arr {
                    let newMedia = ISMChatMediaDB(
                        conversationId: conversationId,
                        groupcastId: "",
                        attachmentType: value.attachmentType ?? 0,
                        extensions: value.extensions ?? "",
                        mediaId: value.mediaId ?? "",
                        mediaUrl: value.mediaUrl ?? "",
                        mimeType: value.mimeType ?? "",
                        name: value.name ?? "",
                        size: value.size ?? 0,
                        thumbnailUrl: value.thumbnailUrl ?? "",
                        customType: customType,
                        sentAt: sentAt,
                        messageId: messageId,
                        userName: userName,
                        caption: "",
                        isDelete: false
                    )
                    
                    modelContext.insert(newMedia)
                    
                    // Step 4: Add media to the conversation's media array
                    conversation.medias.append(newMedia)
                }
                try modelContext.save()
            } catch {
                print("❌ Error fetching conversation: \(error.localizedDescription)")
            }
    }
    
    public func fetchPhotosAndVideos(conversationId: String) async throws -> [ISMChatMediaDB] {
        let conversationFetchDescriptor = FetchDescriptor<ISMChatConversationDB>(
            predicate: #Predicate { $0.conversationId == conversationId }
        )
        
        do {
            let conversations = try modelContext.fetch(conversationFetchDescriptor)
            
            guard let conversation = conversations.first else {
                print("❌ No conversation found for ID: \(conversationId)")
                return []
            }
            
            // Filter medias for photos and videos
            let filteredMedia = conversation.medias.filter { media in
                media.customType == ISMChatMediaType.Image.value ||
                media.customType == ISMChatMediaType.Video.value ||
                media.customType == ISMChatMediaType.gif.value
            }.filter { !$0.isDelete }
            
            // Assign to the property
            return filteredMedia
            print("✅ Found \(filteredMedia.count) media items.")
        } catch {
            print("❌ Error fetching media: \(error.localizedDescription)")
            return []
        }
    }
    
    public func fetchFiles(conversationId: String) async throws -> [ISMChatMediaDB] {
        let conversationFetchDescriptor = FetchDescriptor<ISMChatConversationDB>(
            predicate: #Predicate { $0.conversationId == conversationId }
        )
        
        do {
            let conversations = try modelContext.fetch(conversationFetchDescriptor)
            
            guard let conversation = conversations.first else {
                print("❌ No conversation found for ID: \(conversationId)")
                return []
            }
            
            // Filter medias for photos and videos
            let filteredFiles = conversation.medias.filter { media in
                media.customType == ISMChatMediaType.File.value
            }.filter { !$0.isDelete }
            
            // Assign to the property
            return filteredFiles
            print("✅ Found \(filteredFiles.count) media items.")
        } catch {
            print("❌ Error fetching media: \(error.localizedDescription)")
            return []
        }
    }
    
    public func fetchLinks(conversationId: String) async throws -> [ISMChatMessagesDB] {
        let messagesFetchDescriptor = FetchDescriptor<ISMChatConversationDB>(
            predicate: #Predicate { $0.conversationId == conversationId }
        )
        
        do {
            let conversations = try modelContext.fetch(messagesFetchDescriptor)
            
            guard let conversation = conversations.first else {
                print("❌ No conversation found for ID: \(conversationId)")
                return []
            }
            
            // Filter messages containing "www" or "https" and exclude "map"
            let filteredMessages = conversation.messages.filter { message in
                message.body.isValidURL && !message.body.contains("map")
            }
            
            print("✅ Found \(filteredMessages.count) links.")
            return filteredMessages
        } catch {
            print("❌ Error fetching links: \(error.localizedDescription)")
            return []
        }
    }
    
    public func deleteMedia(conversationId: String, messageId: String) async {
        let conversationFetchDescriptor = FetchDescriptor<ISMChatConversationDB>(
            predicate: #Predicate { $0.conversationId == conversationId }
        )
        
        do {
            let conversations = try modelContext.fetch(conversationFetchDescriptor)
            
            guard let conversation = conversations.first else {
                print("❌ No conversation found for ID: \(conversationId)")
                return
            }
            
            // Find the media entry with the given messageId
            if let mediaToDelete = conversation.medias.first(where: { $0.messageId == messageId }) {
                modelContext.delete(mediaToDelete)
                print("✅ Media deleted successfully.")
            } else {
                print("❌ No media found for messageId: \(messageId)")
            }
            
        } catch {
            print("❌ Error deleting media: \(error.localizedDescription)")
        }
    }


    
    public func updateGroupTitle(title: String, conversationId: String,localOnly : Bool) async throws {
        let conversationFetchDescriptor = FetchDescriptor<ISMChatConversationDB>(
            predicate: #Predicate { $0.conversationId == conversationId }
        )
        do {
            let conversations = try modelContext.fetch(conversationFetchDescriptor)
            
            guard let conversation = conversations.first else {
                print("❌ No conversation found for ID: \(conversationId)")
                return
            }
            
            conversation.conversationTitle = title
            try modelContext.save()
        } catch {
            print("❌ Error deleting media: \(error.localizedDescription)")
        }
    }
    
    public func updateGroupImage(image: String, conversationId: String,localOnly : Bool) async throws {
        let conversationFetchDescriptor = FetchDescriptor<ISMChatConversationDB>(
            predicate: #Predicate { $0.conversationId == conversationId }
        )
        do {
            let conversations = try modelContext.fetch(conversationFetchDescriptor)
            
            guard let conversation = conversations.first else {
                print("❌ No conversation found for ID: \(conversationId)")
                return
            }
            conversation.conversationImageUrl = image
            try modelContext.save()
        } catch {
            print("❌ Error deleting media: \(error.localizedDescription)")
        }
    }

    
    public func getConversationIdFromUserId(opponentUserId: String, myUserId: String) -> String {
        let conversationFetchDescriptor = FetchDescriptor<ISMChatConversationDB>(
            predicate: #Predicate { $0.opponentDetails?.userId == opponentUserId }
        )
        do {
            let conversations = try modelContext.fetch(conversationFetchDescriptor)
            
            guard let conversation = conversations.first else {
                print("❌ No conversation found for userID: \(opponentUserId)")
                return ""
            }
            return conversation.conversationId ?? ""
        } catch {
            print("❌ Error getting conversation from userId : \(error.localizedDescription)")
            return ""
        }
    }
    
    public func exitGroup(conversationId: String) async throws {
        // same logic as delete
    }
    
    
    public func updateMemberCountInGroup(conversationId: String, inc: Bool, dec: Bool, count: Int) async throws {
        let conversationFetchDescriptor = FetchDescriptor<ISMChatConversationDB>(
            predicate: #Predicate { $0.conversationId == conversationId }
        )
        do {
            let conversations = try modelContext.fetch(conversationFetchDescriptor)
            
            guard let conversation = conversations.first else {
                print("❌ No conversation found for ID: \(conversationId)")
                return
            }
            if inc {
                conversation.membersCount += 1
            } else if dec {
                conversation.membersCount -= 1
            } else {
                conversation.membersCount = count
            }
            try modelContext.save() // Save changes on the main thread
        } catch {
            print("❌ Error updating member count in group: \(error.localizedDescription)")
            return
        }
    }
    
    
    public func updateMessageAsDeletedLocally(conversationId: String, messageId: String) async throws {
        let conversationFetchDescriptor = FetchDescriptor<ISMChatConversationDB>(
            predicate: #Predicate { $0.conversationId == conversationId }
        )
        do {
            if let existingConversation = try modelContext.fetch(conversationFetchDescriptor).first {
                if let messageIndex = existingConversation.messages.firstIndex(where: { $0.messageId == messageId }) {
                    DispatchQueue.main.async {
                        existingConversation.messages[messageIndex].deletedMessage = true
                        try? self.modelContext.save() // Save only if an update happens
                    }
                }
            }
        } catch {
            print("❌ Error updating message as deleted: \(error.localizedDescription)")
        }
    }
    
    public func addReactionToMessage(conversationId: String, messageId: String, reaction: String, userId: String) async throws {
        let fetchDescriptor = FetchDescriptor<ISMChatConversationDB>(
            predicate: #Predicate { $0.conversationId == conversationId }
        )
        
        do {
            if let existingConversation = try modelContext.fetch(fetchDescriptor).first {
                if let message = existingConversation.messages.first(where: { $0.messageId == messageId }) {
                    await MainActor.run {
                        if let existingReaction = message.reactions?.first(where: { $0.reactionType == reaction }) {
                            // Only append userId if not already present
                            if !existingReaction.users.contains(userId) {
                                existingReaction.users.append(userId)
                            }
                        } else {
                            // Ensure reactions array is initialized
                            if message.reactions == nil {
                                message.reactions = []
                            }
                            // Create a new reaction and add it to the message
                            let newReaction = ISMChatReactionDB(reactionType: reaction, users: [userId])
                            message.reactions?.append(newReaction)
                        }
                        
                        // ✅ Save changes
                        try? modelContext.save()
                    }
                }
            }
        } catch {
            print("❌ Error adding reaction: \(error.localizedDescription)")
        }
    }
    
    public func removeReactionFromMessage(conversationId: String, messageId: String, reaction: String, userId: String) async throws {
        let fetchDescriptor = FetchDescriptor<ISMChatConversationDB>(
            predicate: #Predicate { $0.conversationId == conversationId }
        )
        
        do {
            if let existingConversation = try modelContext.fetch(fetchDescriptor).first {
                if let message = existingConversation.messages.first(where: { $0.messageId == messageId }) {
                    await MainActor.run {
                        if let existingReaction = message.reactions?.first(where: { $0.reactionType == reaction }) {
                            // Check if user exists in this reaction
                            if let userIndex = existingReaction.users.firstIndex(of: userId) {
                                // Remove user from the reaction
                                existingReaction.users.remove(at: userIndex)
                                
                                // If the reaction has no users left, remove it
                                if existingReaction.users.isEmpty {
                                    if let reactionIndex = message.reactions?.firstIndex(where: { $0.reactionType == reaction }) {
                                        message.reactions?.remove(at: reactionIndex)
                                    }
                                }
                                
                                // ✅ Save changes
                                try? modelContext.save()
                            }
                        }
                    }
                }
            }
        } catch {
            print("❌ Error removing reaction: \(error.localizedDescription)")
        }
    }
    
    public func updateLastMsgAsDeliver(conversationId: String, messageId: String, userId: String, updatedAt: Double) async throws {
        let fetchDescriptor = FetchDescriptor<ISMChatConversationDB>(
            predicate: #Predicate { $0.conversationId == conversationId}
        )

        do {
            if let conversation = try modelContext.fetch(fetchDescriptor).first {
                await MainActor.run {
                    // Clear existing readBy and deliveredTo arrays
                    conversation.lastMessageDetails?.readBy.removeAll()
                    conversation.lastMessageDetails?.deliveredTo.removeAll()
                    
                    // Create a new delivery status object
                    let deliverObj = ISMChatMessageDeliveryStatusDB(userId: userId, timestamp: updatedAt)
                    
                    // Append new delivery status
                    conversation.lastMessageDetails?.deliveredTo.append(deliverObj)
                    
                    // ✅ Save changes
                    try? modelContext.save()
                }
            }
        } catch {
            print("❌ Error updating last message delivery: \(error.localizedDescription)")
        }
    }
    
    public func addDeliveredToUser(conversationId: String, messageId: String, userId: String, updatedAt: Double) async throws {
        let fetchDescriptor = FetchDescriptor<ISMChatConversationDB>(
            predicate: #Predicate { $0.conversationId == conversationId}
        )

        do {
            if let conversation = try modelContext.fetch(fetchDescriptor).first {
                if let message = conversation.messages.first(where: { $0.messageId == messageId }) {
                    await MainActor.run {
                        // Check if the user already exists in deliveredTo list
                        if ((message.deliveredTo?.contains { $0.userId == userId }) == nil) {
                            let deliverObj = ISMChatMessageDeliveryStatusDB(userId: userId, timestamp: updatedAt)
                            message.deliveredTo?.append(deliverObj)
                            
                            // ✅ Save changes
                            try? modelContext.save()
                        }
                    }
                }
            }
        } catch {
            print("❌ Error adding deliveredTo user: \(error.localizedDescription)")
        }
    }

    
    public func updateAllDeliveryStatus(conversationId: String) async throws {
        let fetchDescriptor = FetchDescriptor<ISMChatMessagesDB>(
            predicate: #Predicate { !$0.deliveredToAll && $0.conversationId == conversationId}
        )

        do {
            let messagesToUpdate = try modelContext.fetch(fetchDescriptor)

            await MainActor.run {
                messagesToUpdate.forEach { $0.deliveredToAll = true }

                // ✅ Save changes to persist updates
                try? modelContext.save()
            }
        } catch {
            print("❌ Error updating all delivery statuses: \(error.localizedDescription)")
        }
    }
    
    public func updateAllReadStatus(conversationId: String) async throws {
        let fetchDescriptor = FetchDescriptor<ISMChatMessagesDB>(
            predicate: #Predicate { $0.readByAll == false && $0.conversationId == conversationId}
        )

        do {
            let messagesToUpdate = try modelContext.fetch(fetchDescriptor)
            
            await MainActor.run {
                messagesToUpdate.forEach { message in
                    message.deliveredToAll = true
                    message.readByAll = true
                }
                
                try? modelContext.save() // ✅ Save changes safely
            }
        } catch {
            print("❌ Error updating all read statuses: \(error.localizedDescription)")
        }
    }
    
    public func updateDeliveredToInAllmsgs(conversationId: String, userId: String, updatedAt: Double) async throws {
        let fetchDescriptor = FetchDescriptor<ISMChatMessagesDB>(
            predicate: #Predicate { $0.conversationId == conversationId }
        )

        do {
            let messagesToUpdate = try modelContext.fetch(fetchDescriptor)
            
            await MainActor.run {
                let filteredMessages = messagesToUpdate.filter { message in
                    !(message.deliveredTo?.contains(where: { $0.userId == userId }) ?? false)
                }
                
                for message in filteredMessages {
                    let deliverObj = ISMChatMessageDeliveryStatusDB(userId: userId, timestamp: updatedAt)
                    message.deliveredTo?.append(deliverObj)
                }
                
                try? modelContext.save() // ✅ Save changes safely
            }
        } catch {
            print("❌ Error updating delivery status in all messages: \(error.localizedDescription)")
        }
    }
    
    public func updateReadByInAllMessages(conversationId: String, userId: String, updatedAt: Double) async throws {
        let fetchDescriptor = FetchDescriptor<ISMChatMessagesDB>(
            predicate: #Predicate { $0.conversationId == conversationId }
        )

        do {
            let messagesToUpdate = try modelContext.fetch(fetchDescriptor)
            
            await MainActor.run {
                let filteredMessages = messagesToUpdate.filter { message in
                    !(message.readBy?.contains(where: { $0.userId == userId }) ?? false)
                }
                
                for message in filteredMessages {
                    let readByObj = ISMChatMessageDeliveryStatusDB(userId: userId, timestamp: updatedAt)
                    message.readBy?.append(readByObj)
                }
                
                try? modelContext.save() // ✅ Save changes safely
            }
        } catch {
            print("❌ Error updating read status in all messages: \(error.localizedDescription)")
        }
    }



    
    public func addReadByUser(conversationId: String, messageId: String, userId: String, updatedAt: Double) async throws {
        let fetchDescriptor = FetchDescriptor<ISMChatMessagesDB>(
            predicate: #Predicate { $0.conversationId == conversationId && $0.messageId == messageId }
        )

        do {
            if let message = try modelContext.fetch(fetchDescriptor).first {
                await MainActor.run {
                    if !(message.readBy?.contains { $0.userId == userId } ?? false) {
                        let readStatus = ISMChatMessageDeliveryStatusDB(userId: userId, timestamp: updatedAt)
                        message.readBy?.append(readStatus)
                    }

                    // ✅ Save changes to persist updates
                    try? modelContext.save()
                }
            }
        } catch {
            print("❌ Error adding read-by user: \(error.localizedDescription)")
        }
    }

    
    public func updateDeliveryStatusThroughMsgId(conversationId: String, messageId: String) async throws {
        let fetchDescriptor = FetchDescriptor<ISMChatMessagesDB>(
            predicate: #Predicate { $0.conversationId == conversationId && $0.messageId == messageId}
        )

        do {
            if let message = try modelContext.fetch(fetchDescriptor).first {
                await MainActor.run {
                    message.deliveredToAll = true
                    try? modelContext.save() // ✅ Save the changes
                }
            }
        } catch {
            print("❌ Error updating delivery status: \(error.localizedDescription)")
        }
    }

    public func updateReadStatusThroughMsgId(messageId: String) async throws {
        let fetchDescriptor = FetchDescriptor<ISMChatMessagesDB>(
            predicate: #Predicate { $0.messageId == messageId }
        )

        do {
            if let message = try modelContext.fetch(fetchDescriptor).first {
                await MainActor.run {
                    message.readByAll = true
                    try? modelContext.save() // ✅ Save the changes safely
                }
            }
        } catch {
            print("❌ Error updating read status: \(error.localizedDescription)")
        }
    }

    public func updateLastMessageRead(conversationId: String, messageId: String, userId: String, updatedAt: Double) async throws {
        let fetchDescriptor = FetchDescriptor<ISMChatLastMessageDB>(
            predicate: #Predicate { $0.conversationId == conversationId }
        )

        do {
            if let lastMessage = try modelContext.fetch(fetchDescriptor).first {
                await MainActor.run {
                    let deliveryStatus = ISMChatMessageDeliveryStatusDB(userId: userId, timestamp: updatedAt)
                    lastMessage.readBy.append(deliveryStatus)
                    
                    try? modelContext.save() // ✅ Save changes safely
                }
            }
        } catch {
            print("❌ Error updating last message read status: \(error.localizedDescription)")
        }
    }


    public func doesMessageExistInMessagesDB(conversationId: String, messageId: String) async throws -> Bool {
        let fetchDescriptor = FetchDescriptor<ISMChatMessagesDB>(
                predicate: #Predicate { $0.conversationId == conversationId && $0.messageId == messageId }
            )
            
            do {
                let results = try modelContext.fetch(fetchDescriptor)
                return !results.isEmpty
            } catch {
                print("Failed to fetch messages: \(error)")
                return false
            }
    }
    
    public func getLastInputTextInConversation(conversationId: String) async throws -> String {
        let fetchDescriptor = FetchDescriptor<ISMChatConversationDB>(
            predicate: #Predicate { $0.conversationId == conversationId}
        )

        do {
            if let conversation = try modelContext.fetch(fetchDescriptor).first {
                return conversation.lastInputText ?? ""
            }else{
                return ""
            }
        } catch {
            print("❌ Error getting last input text: \(error.localizedDescription)")
            return ""
        }
    }
    
    public func saveLastInputTextInConversation(text: String, conversationId: String) async throws {
        let fetchDescriptor = FetchDescriptor<ISMChatConversationDB>(
            predicate: #Predicate { $0.conversationId == conversationId}
        )

        do {
            if let conversation = try modelContext.fetch(fetchDescriptor).first {
                await MainActor.run {
                    conversation.lastInputText = text
                    // ✅ Save changes
                    try? modelContext.save()
                }
            }
        } catch {
            print("❌ Error updating last message delivery: \(error.localizedDescription)")
        }
    }
    
    public func getMemberCount(conversationId: String) async throws -> Int {
        let fetchDescriptor = FetchDescriptor<ISMChatConversationDB>(
            predicate: #Predicate { $0.conversationId == conversationId}
        )

        do {
            if let conversation = try modelContext.fetch(fetchDescriptor).first {
                return conversation.membersCount
            }else{
                return -1
            }
        } catch {
            print("❌ Error updating last message delivery: \(error.localizedDescription)")
            return -1
        }
    }
    
    public func addLastMessageOnAddAndRemoveReaction(conversationId: String, action: String, emoji: String, userId: String) async throws {
        let fetchDescriptor = FetchDescriptor<ISMChatConversationDB>(
            predicate: #Predicate { $0.conversationId == conversationId}
        )

        do {
            if let conversation = try modelContext.fetch(fetchDescriptor).first {
                conversation.lastMessageDetails?.action = action
                conversation.lastMessageDetails?.reactionType = emoji
                conversation.lastMessageDetails?.userId = userId
                try? modelContext.save()
            }
        } catch {
            print("❌ Error updating last message delivery: \(error.localizedDescription)")
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
    public func updateUnreadCountThroughConversation(conversationId: String, count: Int, reset: Bool?) async throws {
        do {
            if let conversation = try modelContext.fetch(FetchDescriptor<ISMChatConversationDB>(predicate: #Predicate { $0.conversationId == conversationId })).first {
                conversation.unreadMessagesCount = reset == true ? 0 : (conversation.unreadMessagesCount + count)
                try modelContext.save()
            }
        } catch {
            print("Failed to update unread count: \(error)")
        }
    }
    
    // Change Typing Status in Conversation List
    public func changeTypingStatus(conversationId : String, status: Bool) {
        do {
            if let conversation = try modelContext.fetch(FetchDescriptor<ISMChatConversationDB>(predicate: #Predicate { $0.conversationId == conversationId })).first {
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
