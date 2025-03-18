////
////  ISMMessageView+MQTT.swift
////  ISMChatSdk
////
////  Created by Rahul Sharma on 08/09/23.
////
//
import Foundation
import ISMSwiftCall
import IsometrikChat

extension ISMMessageView {
//    // This function handles the reception of a message
    func messageReceived(messageInfo: ISMChatMessageDelivered) {
        // Check if the received message belongs to the current conversation
        if messageInfo.conversationId == self.conversationID {
            // Only process if the message is in the message list
            if OnMessageList == true && messageInfo.conversationId == self.conversationID {
                // Handle media messages
                if messageInfo.customType == ISMChatMediaType.Image.value || 
                   messageInfo.customType == ISMChatMediaType.Video.value || 
                   messageInfo.customType == ISMChatMediaType.gif.value {
                    Task{
                        await self.viewModelNew.fetchPhotosAndVideos(conversationId: self.conversationID ?? "")
                    }
//                    realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
                } else if messageInfo.customType == ISMChatMediaType.File.value {
                    Task{
                        await self.viewModelNew.fetchFiles(conversationId: self.conversationID ?? "")
                    }
//                    realmManager.fetchFiles(conId: self.conversationID ?? "")
                } else if let body = messageInfo.body, body.isValidURL && !body.contains("map") {
                    Task{
                        await self.viewModelNew.fetchLinks(conversationId: self.conversationID ?? "")
                    }
//                    realmManager.fetchLinks(conId: self.conversationID ?? "")
                }
                
                // Reload the view if the user is blocked or unblocked
                if messageInfo.action == "userBlock" || 
                   messageInfo.action == "userBlockConversation" || 
                   messageInfo.action == "userUnblock" || 
                   messageInfo.action == "userUnblockConversation" {
//                    self.reload()
                    self.getMessages()
                }
                
                // Fetch messages and update read status
                self.getMessages()
                if let converId = messageInfo.conversationId, let messId = messageInfo.messageId {
                    chatViewModel.readMessageIndicator(conversationId: converId, messageId: messId) { _ in
//                        realmManager.updateUnreadCountThroughConId(conId: self.conversationID ?? "", count: 0, reset: true)
                        Task{
                            await self.viewModelNew.updateUnreadCountThroughConversation(conversationId:  self.conversationID ?? "", count: 0, reset: true)
                        }
                    }
                }
            }
        }
        
        // Handle notifications for messages sent by other users
        if userData?.userId != messageInfo.senderId {
            if ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.allowNotification == true && 
               OnMessageList == true && 
               messageInfo.conversationId != self.conversationID {
                ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.senderName ?? "")", body: "\(messageInfo.notificationBody ?? (messageInfo.body ?? ""))", userInfo: ["senderId": messageInfo.senderId ?? "", "senderName": messageInfo.senderName ?? "", "conversationId": messageInfo.conversationId ?? "", "body": messageInfo.notificationBody ?? "", "userIdentifier": messageInfo.senderIdentifier ?? "", "messageId": messageInfo.messageId ?? ""])
            }
        }
    }
    
//    // This function handles group actions such as adding/removing members
    func groupAction(messageInfo: ISMChatMessageDelivered) {
        // Check if the group action is for the current conversation
        if messageInfo.conversationId == self.conversationID {
            var metaDataValue = ISMChatMetaDataDB()
            if let metaData = messageInfo.metaData{
                var contact : [ISMChatContactDB] = []
                if let contacts = metaData.contacts, contacts.count > 0{
                    for x in contacts{
                        var data = ISMChatContactDB()
                        data.contactIdentifier = x.contactIdentifier
                        data.contactImageUrl = x.contactImageUrl
                        data.contactName = x.contactName
                        contact.append(data)
                    }
                }
                
                let replyMessageData = ISMChatReplyMessageDB(
                    parentMessageId: messageInfo.parentMessageId,
                    parentMessageBody: metaData.replyMessage?.parentMessageBody,
                    parentMessageUserId: metaData.replyMessage?.parentMessageUserId,
                    parentMessageUserName: metaData.replyMessage?.parentMessageUserName,
                    parentMessageMessageType: metaData.replyMessage?.parentMessageMessageType,
                    parentMessageAttachmentUrl: metaData.replyMessage?.parentMessageAttachmentUrl,
                    parentMessageInitiator: metaData.replyMessage?.parentMessageInitiator,
                    parentMessagecaptionMessage: metaData.replyMessage?.parentMessagecaptionMessage)
                
                let postDetail = ISMChatPostDB(postId: metaData.post?.postId, postUrl: metaData.post?.postUrl)
                let productDetail = ISMChatProductDB(productId: metaData.product?.productId, productUrl: metaData.product?.productUrl, productCategoryId: metaData.product?.productCategoryId)
                
                
                // added message in messagesdb
                var paymentRequestedMembers : [ISMChatPaymentRequestMembersDB] = []
                if let members = metaData.paymentRequestedMembers, members.count > 0{
                    for x in members{
                        var data = ISMChatPaymentRequestMembersDB()
                        data.userId = x.userId
                        data.userName = x.userName
                        data.status = x.status
                        data.statusText = x.statusText
                        data.appUserId = x.appUserId
                        paymentRequestedMembers.append(data)
                    }
                }
                
                var inviteMembers : [ISMChatPaymentRequestMembersDB] = []
                if let members = metaData.inviteMembers, members.count > 0{
                    for x in members{
                        var data = ISMChatPaymentRequestMembersDB()
                        data.userId = x.userId
                        data.userName = x.userName
                        data.status = x.status
                        data.statusText = x.statusText
                        data.appUserId = x.appUserId
                        inviteMembers.append(data)
                    }
                }
                let location = ISMChatLocationDB(name: metaData.inviteLocation?.name ?? "", latitude: metaData.inviteLocation?.latitude ?? 0, longitude: metaData.inviteLocation?.longitude ?? 0)
                
                metaDataValue =  ISMChatMetaDataDB(
                    locationAddress: metaData.locationAddress ?? "",
                    replyMessage: replyMessageData,
                    contacts: contact,
                    captionMessage: metaData.captionMessage ?? "",
                    isBroadCastMessage: metaData.isBroadCastMessage ?? false,
                    post: postDetail,
                    product: productDetail,
                    storeName: metaData.storeName ?? "",
                    productName: metaData.productName,
                    bestPrice:  metaData.bestPrice,
                    scratchPrice: metaData.scratchPrice,
                    url: metaData.url,
                    parentProductId: metaData.parentProductId,
                    childProductId: metaData.childProductId,
                    entityType: metaData.entityType,
                    productImage: metaData.productImage,
                    thumbnailUrl: metaData.thumbnailUrl,
                    Description: metaData.description,
                    isVideoPost: metaData.isVideoPost,
                    socialPostId: metaData.socialPostId,
                    collectionTitle: metaData.collectionTitle,
                    collectionDescription: metaData.collectionDescription,
                    productCount: metaData.productCount,
                    collectionImage: metaData.collectionImage,
                    collectionId: metaData.collectionId,
                    paymentRequestId: metaData.paymentRequestId,
                    orderId: metaData.orderId,
                    paymentRequestedMembers: paymentRequestedMembers,
                    requestAPaymentExpiryTime: metaData.requestAPaymentExpiryTime,
                    currencyCode: metaData.currencyCode,
                    amount: metaData.amount,
                    inviteTitle: metaData.inviteTitle,
                    inviteTimestamp: metaData.inviteTimestamp,
                    inviteRescheduledTimestamp: metaData.inviteRescheduledTimestamp,
                    inviteLocation:  location,
                    inviteMembers: inviteMembers,
                    groupCastId: metaData.groupCastId,
                    status: metaData.status)
            }
            //updated message
            var bodyUpdated = messageInfo.body
            var customType = messageInfo.customType
            if messageInfo.action == ISMChatActionType.messageDetailsUpdated.value ?? ""{
                bodyUpdated = messageInfo.details?.body
                customType = messageInfo.details?.customType
            }
            
            var mentionedUser: [ISMChatMentionedUserDB] = []
            if let mentionedUsers = messageInfo.mentionedUsers {
                for x in mentionedUsers {
                    let user = ISMChatMentionedUserDB(wordCount: x.wordCount, userId: x.userId, order: x.order)
                    mentionedUser.append(user)
                }
            }
            
            let senderIndo = ISMChatUserDB(userId: messageInfo.senderId ?? "", userProfileImageUrl: messageInfo.senderProfileImageUrl ?? "", userName: messageInfo.senderName ?? "", userIdentifier: messageInfo.senderIdentifier ?? "", online: false, lastSeen: -1, metaData: nil)
            
            var reactionDBArray: [ISMChatReactionDB] = []
            if let reactionsDict = messageInfo.reactions {
                reactionDBArray = reactionsDict.map { key, value in
                    ISMChatReactionDB(reactionType: key, users: value)
                }
            }
            func createAttachments() -> [ISMChatAttachmentDB] {
                return messageInfo.attachments?.map {
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
            let membersArray = messageInfo.members?.map { member -> ISMChatLastMessageMemberDB in
                var chatMember = ISMChatLastMessageMemberDB()
                chatMember.memberId = member.memberId
                chatMember.memberIdentifier = member.memberIdentifier
                chatMember.memberName = member.memberName
                chatMember.memberProfileImageUrl = member.memberProfileImageUrl
                return chatMember
            } ?? []
            
            let message = ISMChatMessagesDB(
                messageId: messageInfo.messageId ?? "",
                sentAt: messageInfo.sentAt ?? 0,
                senderInfo: senderIndo,
                body: bodyUpdated ?? "", // Updated message body
                userName: messageInfo.userName,
                userIdentifier: messageInfo.userIdentifier ?? "",
                userId: messageInfo.userId,
                userProfileImageUrl: messageInfo.userProfileImageUrl ?? "",
                mentionedUsers: mentionedUser ?? [],
                deliveredToAll: false,
                readByAll: false,
                customType: messageInfo.customType ?? "",
                action: messageInfo.action ?? "",
                readBy: [],
                deliveredTo: [],
                messageType: 0,
                parentMessageId: messageInfo.parentMessageId ?? "",
                metaData: metaDataValue,
                metaDataJsonString: messageInfo.metaDataJson ?? "",
                attachments:  createAttachments(),
                initiatorIdentifier: messageInfo.initiatorIdentifier ?? "",
                initiatorId: messageInfo.initiatorId ?? "",
                initiatorName: messageInfo.initiatorName ?? "",
                conversationId: messageInfo.conversationId ?? "",
                members: membersArray, // Ensure membersArray is populated
                deletedMessage: false,
                memberName: messageInfo.memberName ?? "",
                memberId: messageInfo.memberId ?? "",
                memberIdentifier: messageInfo.memberIdentifier ?? "",
                messageUpdated: false,
                reactions: reactionDBArray,
                meetingId: messageInfo.meetingId ?? ""
            )
            
            Task{
                await self.viewModelNew.saveMessages(conversationId: messageInfo.conversationId ?? "", messages: [message])
                // Handle media fetching after saving the message
                if messageInfo.customType == ISMChatMediaType.Image.value ||
                   messageInfo.customType == ISMChatMediaType.Video.value ||
                   messageInfo.customType == ISMChatMediaType.gif.value {
//                    realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
                    await self.viewModelNew.fetchPhotosAndVideos(conversationId: self.conversationID ?? "")
                } else if messageInfo.customType == ISMChatMediaType.File.value {
//                    realmManager.fetchFiles(conId: self.conversationID ?? "")
                    await self.viewModelNew.fetchFiles(conversationId: self.conversationID ?? "")
                } else if let body = messageInfo.body, body.isValidURL && !body.contains("map") {
//                    realmManager.fetchLinks(conId: self.conversationID ?? "")
                    await self.viewModelNew.fetchLinks(conversationId: self.conversationID ?? "")
                }
            }
            
            
           
            
            // Fetch messages and update the last message ID to scroll
//            self.getMessages()
            parentMessageIdToScroll = self.viewModelNew.messages.last?.last?.id.description ?? ""
            if let converId = messageInfo.conversationId, let messId = messageInfo.messageId {
                chatViewModel.deliveredMessageIndicator(conversationId: converId, messageId: messId) { _ in
                    // Update status of message to delivered
                }
                chatViewModel.readMessageIndicator(conversationId: converId, messageId: messId) { _ in
                    // Update status of message to read
                    // After message is read, reset unread count
                    Task{
                        await viewModelNew.updateUnreadCountThroughConversation(conversationId:  self.conversationID ?? "", count: 0, reset: true)
//                        realmManager.updateUnreadCountThroughConId(conId: self.conversationID ?? "", count: 0, reset: true)
                    }
                }
            }
        }
    }
//    
//    // This function handles the addition of meeting messages
    func addMeeting(messageInfo: ISMMeeting) {
        var members: [ISMChatLastMessageMemberDB] = []
        // Collect members in the call
        if let membersInCall = messageInfo.members {
            for member in membersInCall {
                let y = ISMChatLastMessageMemberDB(memberProfileImageUrl: member.memberProfileImageURL, memberName: member.memberName, memberIdentifier: member.memberIdentifier, memberId: member.memberId)
                members.append(y)
            }
        }
        
        var chatMeetingDurations: [ISMChatMeetingDuration] = messageInfo.callDurations?.map { duration in
            return ISMChatMeetingDuration(
                memberId: duration.memberId,
                durationInMilliseconds: duration.durationInMilliseconds
            )
        } ?? []
        
        let config = ISMChatMeetingConfig(pushNotifications: messageInfo.config?.pushNotifications)

        // Create the meeting message object
        let message = ISMChatMessagesDB(messageId: messageInfo.messageId ?? "",
                                        sentAt: messageInfo.sentAt ?? 0,
                                        customType: messageInfo.customType,
                                        action: messageInfo.action ?? "",
                                        initiatorIdentifier: messageInfo.initiatorIdentifier,
                                        initiatorId: messageInfo.initiatorId,
                                        initiatorName: messageInfo.initiatorName,
                                        conversationId: messageInfo.conversationId ?? "",
                                        members: members,
                                        missedByMembers: messageInfo.missedByMembers,
                                        meetingId: messageInfo.meetingId,
                                        callDurations: chatMeetingDurations,
                                        audioOnly: messageInfo.audioOnly,
                                        autoTerminate: messageInfo.autoTerminate,
                                        config: config)
        
        Task{
            await viewModelNew.saveMessages(conversationId: messageInfo.conversationId ?? "", messages: [message])
            parentMessageIdToScroll = self.viewModelNew.messages.last?.last?.id.description ?? ""
            let lastMessage = ISMChatLastMessageDB(sentAt: messageInfo.sentAt, conversationId: self.conversationID ?? "", messageId: messageInfo.messageId,customType: messageInfo.customType, action: messageInfo.action, initiatorName: messageInfo.initiatorName, initiatorId: messageInfo.initiatorId, initiatorIdentifier: messageInfo.initiatorIdentifier)
            await viewModelNew.updateLastmsgInConversation(conversationId:  messageInfo.conversationId ?? "", lastmsg: lastMessage)
        }
    }

    // This function handles user block and unblock actions
    func userBlockedAndUnblocked(messageInfo: ISMChatUserBlockAndUnblock) {
        // Create a message object for the block/unblock action
        let message = ISMChatMessagesDB(messageId: messageInfo.messageId ?? "", sentAt: messageInfo.sentAt ?? 0, action: messageInfo.action ?? "", initiatorIdentifier: messageInfo.initiatorIdentifier, initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName, conversationId: self.conversationID ?? "")
        
        Task{
            await viewModelNew.saveMessages(conversationId: messageInfo.conversationId ?? "", messages: [message])
            parentMessageIdToScroll = self.viewModelNew.messages.last?.last?.id.description ?? ""
            let lastMessage = ISMChatLastMessageDB(sentAt: messageInfo.sentAt, conversationId: self.conversationID ?? "", messageId: messageInfo.messageId, action: messageInfo.action, initiatorName: messageInfo.initiatorName, initiatorId: messageInfo.initiatorId, initiatorIdentifier: messageInfo.initiatorIdentifier)
            await viewModelNew.updateLastmsgInConversation(conversationId:  messageInfo.conversationId ?? "", lastmsg: lastMessage)
        }
    }
  
//    // This function handles user typing events
    func userTyping(messageInfo: ISMChatTypingEvent) {
        // Check if the typing event is for the current conversation
        if messageInfo.conversationId == self.conversationID {
            stateViewModel.otherUserTyping = true
            typingUserName = messageInfo.userName
            // Reset typing state after 7 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                stateViewModel.otherUserTyping = false
                typingUserName = nil
            }
        }
    }
//    
//    // This function handles actions on message delivery
    func actionOnMessageDelivered(messageInfo: ISMChatMessageDelivered) {
        // Handle different actions related to message delivery
        if messageInfo.action == ISMChatActionType.memberLeave.value {
            // Check if the action is member leave and get conversation details
            if messageInfo.meetingId == nil {
                getConversationDetail()
            }
        } else if messageInfo.action == ISMChatActionType.membersRemove.value {
            // Check if the action is members remove and get conversation details
            if messageInfo.meetingId == nil {
                getConversationDetail()
            }
        } else if messageInfo.action == ISMChatActionType.membersAdd.value {
            // Check if the action is members add and get conversation details
            if messageInfo.meetingId == nil {
                getConversationDetail()
            }
        } else if messageInfo.action == ISMChatActionType.conversationTitleUpdated.value {
            // Update conversation title in local database
            Task{
                await viewModelNew.updateGroupTitle(title: messageInfo.conversationTitle ?? "", conversationId: messageInfo.conversationId ?? "", localOnly: true)
            }
//            realmManager.changeGroupName(conversationId: messageInfo.conversationId ?? "", conversationTitle: messageInfo.conversationTitle ?? "")
        } else if messageInfo.action == ISMChatActionType.conversationImageUpdated.value {
            // Update conversation image in local database
            Task{
                await viewModelNew.updateGroupImage(image: messageInfo.conversationImageUrl ?? "", conversationId: messageInfo.conversationId ?? "", localOnly: true)
            }
//            realmManager.changeGroupIcon(conversationId: messageInfo.conversationId ?? "", conversationIcon: messageInfo.conversationImageUrl ?? "")
        }
    }
//    
//    // This function sends local notifications based on message actions
    func sendLocalNotification(messageInfo: ISMChatMessageDelivered) {
        // Check if the message is from another user
        if messageInfo.senderId != userData?.userId {
            // Check if the conversation ID is different from the current one
            if messageInfo.conversationId != self.conversationID {
                if userData?.allowNotification == true {
                    // Handle different actions for notifications
                    if messageInfo.action == ISMChatActionType.memberLeave.value {
                        if messageInfo.meetingId == nil {
                            ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") left group", userInfo: ["senderId": messageInfo.senderId ?? "", "senderName": messageInfo.senderName ?? "", "conversationId": messageInfo.conversationId ?? "", "body": messageInfo.notificationBody ?? "", "userIdentifier": messageInfo.senderIdentifier ?? ""])
                        }
                    } else if messageInfo.action == ISMChatActionType.membersRemove.value {
                        let memberName = messageInfo.members?.first?.memberId == userData?.userId ? ConstantStrings.you.lowercased() : messageInfo.members?.first?.memberName
                        ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") removed \(memberName ?? "")", userInfo: ["senderId": messageInfo.senderId ?? "", "senderName": messageInfo.senderName ?? "", "conversationId": messageInfo.conversationId ?? "", "body": messageInfo.notificationBody ?? "", "userIdentifier": messageInfo.senderIdentifier ?? ""])
                    } else if messageInfo.action == ISMChatActionType.membersAdd.value {
                        let memberName = messageInfo.members?.first?.memberId == userData?.userId ? ConstantStrings.you.lowercased() : messageInfo.members?.first?.memberName
                        ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") added \(memberName ?? "")", userInfo: ["senderId": messageInfo.senderId ?? "", "senderName": messageInfo.senderName ?? "", "conversationId": messageInfo.conversationId ?? "", "body": messageInfo.notificationBody ?? "", "userIdentifier": messageInfo.senderIdentifier ?? ""])
                    } else if messageInfo.action == ISMChatActionType.conversationTitleUpdated.value {
//                        realmManager.changeGroupName(conversationId: messageInfo.conversationId ?? "", conversationTitle: messageInfo.conversationTitle ?? "")
                        Task{
                            await viewModelNew.updateGroupTitle(title: messageInfo.conversationTitle ?? "", conversationId: messageInfo.conversationId ?? "", localOnly: true)
                        }
                        ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") changed group name", userInfo: ["senderId": messageInfo.senderId ?? "", "senderName": messageInfo.senderName ?? "", "conversationId": messageInfo.conversationId ?? "", "body": messageInfo.notificationBody ?? "", "userIdentifier": messageInfo.senderIdentifier ?? ""])
                    } else if messageInfo.action == ISMChatActionType.conversationImageUpdated.value {
//                        realmManager.changeGroupIcon(conversationId: messageInfo.conversationId ?? "", conversationIcon: messageInfo.conversationImageUrl ?? "")
                        Task{
                            await viewModelNew.updateGroupImage(image: messageInfo.conversationImageUrl ?? "", conversationId: messageInfo.conversationId ?? "", localOnly: true)
                        }
                        ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") changed group icon", userInfo: ["senderId": messageInfo.senderId ?? "", "senderName": messageInfo.senderName ?? "", "conversationId": messageInfo.conversationId ?? "", "body": messageInfo.notificationBody ?? "", "userIdentifier": messageInfo.senderIdentifier ?? ""])
                    } else {
                        ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.senderName ?? "")", body: "\(messageInfo.notificationBody ?? (messageInfo.body ?? ""))", userInfo: ["senderId": messageInfo.senderId ?? "", "senderName": messageInfo.senderName ?? "", "conversationId": messageInfo.conversationId ?? "", "body": messageInfo.notificationBody ?? "", "userIdentifier": messageInfo.senderIdentifier ?? ""])
                    }
                }
            }
        }
    }
}
