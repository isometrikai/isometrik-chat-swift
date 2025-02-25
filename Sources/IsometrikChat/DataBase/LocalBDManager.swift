//
//  LocalBDManager.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 24/02/25.
//

import SwiftData
import Foundation

public class LocalDBManager {
    
    
    public var modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // 🔄 Fetch All Products
    public func fetchAllConversations() -> [ISMChatConversationDB] {
        do {
            let descriptor = FetchDescriptor<ISMChatConversationDB>()
            return try modelContext.fetch(descriptor)
        } catch {
            print("Fetch Error: \(error)")
            return []
        }
    }

    public func manageConversationList(arr: [ISMChatConversationsDetail]) {
        for obj in arr {
            let descriptor = FetchDescriptor<ISMChatConversationDB>(
                predicate: #Predicate { $0.conversationId == (obj.conversationId ?? "") }
            )
            do {
                let existingConversations = try modelContext.fetch(descriptor)

                if existingConversations.isEmpty {
                    // ✅ Add New Conversation
                    addConversation(obj: arr, modelContext: modelContext)
                } else if let existing = existingConversations.first, !existing.isDelete {
                    // 🔄 Update if not deleted
                    updateConversation(existing: existing, obj: obj, modelContext: modelContext)
                }

            } catch {
                print("SwiftData Error: \(error)")
            }
        }
    }


    
    //MARK: - Add conversation locally

    public func addConversation(obj: [ISMChatConversationsDetail], modelContext: ModelContext) {
        for value in obj {
            let userMataData = ISMChatUserMetaDataDB(
                userId: value.opponentDetails?.metaData?.userId ?? "",
                userType: value.opponentDetails?.metaData?.userType ?? 0,
                isStarUser: value.opponentDetails?.metaData?.isStarUser ?? false,
                userTypeString: value.opponentDetails?.metaData?.userTypeString ?? "")
            
            let opponentDetails = ISMChatUserDB(
                userId: value.opponentDetails?.userId ?? "",
                userProfileImageUrl: value.opponentDetails?.userProfileImageUrl ?? "",
                userName: value.opponentDetails?.userName ?? "",
                userIdentifier: value.opponentDetails?.userIdentifier ?? "",
                online: value.opponentDetails?.online ?? false,
                lastSeen: value.opponentDetails?.lastSeen ?? 0,
                metaData: userMataData)
            
            let config = ISMChatConfigDB(
                typingEvents: value.config?.typingEvents,
                readEvents: value.config?.readEvents,
                pushNotifications: value.config?.pushNotifications)
            
            var contactsValue : [ISMChatContactDB] = []
            if let contacts = value.lastMessageDetails?.metaData?.contacts{
                for contact in contacts {
                    let x = ISMChatContactDB(
                        contactName: contact.contactName,
                        contactIdentifier: contact.contactIdentifier,
                        contactImageUrl: contact.contactImageUrl)
                    contactsValue.append(x)
                }
            }
            
            var paymentRequestMembersValue : [ISMChatPaymentRequestMembersDB] = []
            if let members = value.lastMessageDetails?.metaData?.paymentRequestedMembers{
                for member in members {
                    let x = ISMChatPaymentRequestMembersDB(userId: member.userId, userName: member.userName, status: member.status, statusText: member.statusText, appUserId: member.appUserId, userProfileImage: member.userProfileImage, declineReason: member.declineReason)
                    paymentRequestMembersValue.append(x)
                }
            }
            
            var inviteMembersValue : [ISMChatPaymentRequestMembersDB] = []
            if let members = value.lastMessageDetails?.metaData?.inviteMembers{
                for member in members {
                    let x = ISMChatPaymentRequestMembersDB(userId: member.userId, userName: member.userName, status: member.status, statusText: member.statusText, appUserId: member.appUserId, userProfileImage: member.userProfileImage, declineReason: member.declineReason)
                    inviteMembersValue.append(x)
                }
            }
            
            let lastMessageMetaData = ISMChatMetaDataDB(
                locationAddress: value.lastMessageDetails?.metaData?.locationAddress,
                replyMessage: ISMChatReplyMessageDB(
                    parentMessageId: value.lastMessageDetails?.metaData?.replyMessage?.parentMessageId,
                    parentMessageBody: value.lastMessageDetails?.metaData?.replyMessage?.parentMessageBody,
                    parentMessageUserId:  value.lastMessageDetails?.metaData?.replyMessage?.parentMessageUserId,
                    parentMessageUserName:  value.lastMessageDetails?.metaData?.replyMessage?.parentMessageUserName,
                    parentMessageMessageType:  value.lastMessageDetails?.metaData?.replyMessage?.parentMessageMessageType,
                    parentMessageAttachmentUrl:  value.lastMessageDetails?.metaData?.replyMessage?.parentMessageAttachmentUrl,
                    parentMessageInitiator:  value.lastMessageDetails?.metaData?.replyMessage?.parentMessageInitiator,
                    parentMessagecaptionMessage:  value.lastMessageDetails?.metaData?.replyMessage?.parentMessagecaptionMessage),
                contacts: contactsValue,
                captionMessage: value.lastMessageDetails?.metaData?.captionMessage,
                isBroadCastMessage: value.lastMessageDetails?.metaData?.isBroadCastMessage,
                post: ISMChatPostDB(
                    postId: value.lastMessageDetails?.metaData?.post?.postId,
                    postUrl: value.lastMessageDetails?.metaData?.post?.postUrl),
                product: ISMChatProductDB(
                    productId: value.lastMessageDetails?.metaData?.product?.productId,
                    productUrl: value.lastMessageDetails?.metaData?.product?.productUrl,
                    productCategoryId: value.lastMessageDetails?.metaData?.product?.productCategoryId),
                storeName: value.lastMessageDetails?.metaData?.storeName,
                productName: value.lastMessageDetails?.metaData?.productName,
                bestPrice: value.lastMessageDetails?.metaData?.bestPrice,
                scratchPrice: value.lastMessageDetails?.metaData?.scratchPrice,
                url: value.lastMessageDetails?.metaData?.url,
                parentProductId: value.lastMessageDetails?.metaData?.parentProductId,
                childProductId: value.lastMessageDetails?.metaData?.childProductId,
                entityType: value.lastMessageDetails?.metaData?.entityType,
                productImage: value.lastMessageDetails?.metaData?.productImage,
                thumbnailUrl: value.lastMessageDetails?.metaData?.thumbnailUrl,
                Description: value.lastMessageDetails?.metaData?.description,
                isVideoPost: value.lastMessageDetails?.metaData?.isVideoPost,
                socialPostId: value.lastMessageDetails?.metaData?.socialPostId,
                collectionTitle: value.lastMessageDetails?.metaData?.collectionTitle,
                collectionDescription: value.lastMessageDetails?.metaData?.collectionDescription,
                productCount: value.lastMessageDetails?.metaData?.productCount,
                collectionImage: value.lastMessageDetails?.metaData?.collectionImage,
                collectionId: value.lastMessageDetails?.metaData?.collectionId,
                paymentRequestId: value.lastMessageDetails?.metaData?.paymentRequestId,
                orderId: value.lastMessageDetails?.metaData?.orderId,
                paymentRequestedMembers: paymentRequestMembersValue,
                requestAPaymentExpiryTime: value.lastMessageDetails?.metaData?.requestAPaymentExpiryTime,
                currencyCode: value.lastMessageDetails?.metaData?.currencyCode,
                amount: value.lastMessageDetails?.metaData?.amount,
                inviteTitle: value.lastMessageDetails?.metaData?.inviteTitle,
                inviteTimestamp: value.lastMessageDetails?.metaData?.inviteTimestamp,
                inviteRescheduledTimestamp: value.lastMessageDetails?.metaData?.inviteRescheduledTimestamp,
                inviteLocation: ISMChatLocationDB(
                    name: value.lastMessageDetails?.metaData?.inviteLocation?.name,
                    latitude: value.lastMessageDetails?.metaData?.inviteLocation?.latitude,
                    longitude: value.lastMessageDetails?.metaData?.inviteLocation?.longitude),
                inviteMembers: inviteMembersValue,
                groupCastId: value.lastMessageDetails?.metaData?.groupCastId,
                status: value.lastMessageDetails?.metaData?.status)
            
            var deliveredToValue : [ISMChatMessageDeliveryStatusDB] = []
            if let members = value.lastMessageDetails?.deliveredTo{
                for member in members {
                    let x = ISMChatMessageDeliveryStatusDB(userId: member.userId, timestamp: member.timestamp)
                    deliveredToValue.append(x)
                }
            }
            var readByValue : [ISMChatMessageDeliveryStatusDB] = []
            if let members = value.lastMessageDetails?.readBy{
                for member in members {
                    let x = ISMChatMessageDeliveryStatusDB(userId: member.userId, timestamp: member.timestamp)
                    readByValue.append(x)
                }
            }
            
            var memebersValue : [ISMChatLastMessageMemberDB] = []
            if let members = value.lastMessageDetails?.members{
                for member in members {
                    let x = ISMChatLastMessageMemberDB(memberProfileImageUrl: member.memberProfileImageUrl, memberName: member.memberName, memberIdentifier: member.memberIdentifier, memberId: member.memberId)
                    memebersValue.append(x)
                }
            }
            
            var callDurationsValue : [ISMChatMeetingDuration] = []
            if let calls = value.lastMessageDetails?.callDurations{
                for call in calls {
                    let x = ISMChatMeetingDuration(memberId: call.memberId, durationInMilliseconds: call.durationInMilliseconds)
                    callDurationsValue.append(x)
                }
            }
            
            let lastMessageDetails = ISMChatLastMessageDB(
                sentAt: value.lastMessageDetails?.sentAt,
                updatedAt: value.lastMessageDetails?.updatedAt,
                senderName: value.lastMessageDetails?.senderName,
                senderIdentifier: value.lastMessageDetails?.senderIdentifier,
                senderId: value.lastMessageDetails?.senderId,
                conversationId: value.lastMessageDetails?.conversationId,
                body: value.lastMessageDetails?.body,
                messageId: value.lastMessageDetails?.messageId,
                customType: value.lastMessageDetails?.customType,
                action: value.lastMessageDetails?.action,
                metaData: lastMessageMetaData,
                metaDataJsonString: value.lastMessageDetails?.metaDataJson,
                deliveredTo: deliveredToValue,
                readBy: readByValue,
                msgSyncStatus: "",
                reactionType: value.lastMessageDetails?.reactionType ?? "",
                userId: value.lastMessageDetails?.userId ?? "",
                userIdentifier: value.lastMessageDetails?.userIdentifier,
                userName: value.lastMessageDetails?.userName,
                userProfileImageUrl: value.lastMessageDetails?.userProfileImageUrl,
                members: memebersValue,
                memberName: value.lastMessageDetails?.memberName ?? "",
                memberId: value.lastMessageDetails?.memberId ?? "",
                messageDeleted: value.lastMessageDetails?.messageDeleted ?? false,
                initiatorName: value.lastMessageDetails?.initiatorName ?? "",
                initiatorId: value.lastMessageDetails?.initiatorId,
                initiatorIdentifier: value.lastMessageDetails?.initiatorIdentifier,
                deletedMessage: false,
                meetingId: value.lastMessageDetails?.meetingId,
                missedByMembers: value.lastMessageDetails?.missedByMembers ?? [],
                callDurations: callDurationsValue)
            
            let conversation = ISMChatConversationDB(
                conversationId: value.conversationId ?? "",
                updatedAt: value.lastMessageDetails?.updatedAt ?? 0,
                unreadMessagesCount: value.unreadMessagesCount ?? 0,
                membersCount: value.membersCount ?? 0,
                lastMessageSentAt: value.lastMessageSentAt ?? 0,
                createdAt: value.createdAt ?? 0,
                mode: "mode",
                conversationTitle: value.conversationTitle ?? "",
                conversationImageUrl: value.conversationImageUrl ?? "",
                createdBy: value.createdBy ?? "",
                createdByUserName: value.createdByUserName ?? "",
                privateOneToOne: value.privateOneToOne ?? false,
                messagingDisabled: false,
                isGroup: value.isGroup ?? false,
                typing: value.typing ?? false,
                isDelete: false,
                userIds: [],
                opponentDetails: opponentDetails,
                config: config,
                lastMessageDetails: lastMessageDetails,
                deletedMessage: false,
                metaData: ISMChatConversationMetaData(chatStatus: value.metaData?.chatStatus ?? "", membersIds: value.metaData?.membersIds ?? []),
                metaDataJson: value.metaDataJson,
                lastInputText: "")

            modelContext.insert(conversation)
        }

        do {
            try modelContext.save()
            fetchAllConversations()  // Fetch after saving
        } catch {
            print("Error saving to SwiftData: \(error.localizedDescription)")
        }
    }

    
    //MARK: - update convertion if already exist in local db
    public func updateConversation(existing: ISMChatConversationDB, obj: ISMChatConversationsDetail, modelContext: ModelContext) {
        existing.updatedAt = obj.lastMessageDetails?.updatedAt ?? existing.updatedAt
        existing.unreadMessagesCount = obj.unreadMessagesCount ?? existing.unreadMessagesCount
        existing.membersCount = obj.membersCount ?? existing.membersCount
        existing.lastMessageSentAt = obj.lastMessageSentAt ?? existing.lastMessageSentAt
        existing.conversationTitle = obj.conversationTitle ?? existing.conversationTitle
        existing.conversationImageUrl = obj.conversationImageUrl ?? existing.conversationImageUrl
        existing.privateOneToOne = obj.privateOneToOne ?? existing.privateOneToOne
        existing.isGroup = obj.isGroup ?? existing.isGroup

        do {
            try modelContext.save()  // 💾 Save changes to SwiftData
            print("Conversation updated successfully")
        } catch {
            print("Error updating conversation: \(error.localizedDescription)")
        }
    }

    // 🗑️ Delete All Products (Optional for syncing)
    public func deleteAllConversations() {
        let products = fetchAllConversations()
        for product in products {
            modelContext.delete(product)
        }

        do {
            try modelContext.save()
        } catch {
            print("Delete Error: \(error)")
        }
    }
}
