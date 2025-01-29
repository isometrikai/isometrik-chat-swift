//
//  ISMMessageView+MQTT.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 08/09/23.
//

import Foundation
import ISMSwiftCall
import IsometrikChat

extension ISMMessageView {
    // This function handles the reception of a message
    func messageReceived(messageInfo: ISMChatMessageDelivered) {
        // Check if the received message belongs to the current conversation
        if messageInfo.conversationId == self.conversationID {
            // Only process if the message is in the message list
            if OnMessageList == true && messageInfo.conversationId == self.conversationID {
                // Handle media messages
                if messageInfo.customType == ISMChatMediaType.Image.value || 
                   messageInfo.customType == ISMChatMediaType.Video.value || 
                   messageInfo.customType == ISMChatMediaType.gif.value {
                    realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
                } else if messageInfo.customType == ISMChatMediaType.File.value {
                    realmManager.fetchFiles(conId: self.conversationID ?? "")
                } else if let body = messageInfo.body, body.isValidURL && !body.contains("map") {
                    realmManager.fetchLinks(conId: self.conversationID ?? "")
                }
                
                // Reload the view if the user is blocked or unblocked
                if messageInfo.action == "userBlock" || 
                   messageInfo.action == "userBlockConversation" || 
                   messageInfo.action == "userUnblock" || 
                   messageInfo.action == "userUnblockConversation" {
                    self.reload()
                }
                
                // Fetch messages and update read status
                self.getMessages()
                if let converId = messageInfo.conversationId, let messId = messageInfo.messageId {
                    chatViewModel.readMessageIndicator(conversationId: converId, messageId: messId) { _ in
                        realmManager.updateUnreadCountThroughConId(conId: self.conversationID ?? "", count: 0, reset: true)
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
    
    // This function handles group actions such as adding/removing members
    func groupAction(messageInfo: ISMChatMessageDelivered) {
        // Check if the group action is for the current conversation
        if messageInfo.conversationId == self.conversationID {
            var contact: [ISMChatContactMetaData] = []
            // Collect contact metadata from the message
            if let contacts = messageInfo.metaData?.contacts, contacts.count > 0 {
                for x in contacts {
                    var data = ISMChatContactMetaData()
                    data.contactIdentifier = x.contactIdentifier
                    data.contactImageData = x.contactImageData
                    data.contactImageUrl = x.contactImageUrl
                    data.contactName = x.contactName
                    contact.append(data)
                }
            }
            
            // Prepare reply message metadata
            let replyMessageData = ISMChatReplyMessageMetaData(
                parentMessageId: messageInfo.parentMessageId,
                parentMessageBody: messageInfo.metaData?.replyMessage?.parentMessageBody,
                parentMessageUserId: messageInfo.metaData?.replyMessage?.parentMessageUserId,
                parentMessageUserName: messageInfo.metaData?.replyMessage?.parentMessageUserName,
                parentMessageMessageType: messageInfo.metaData?.replyMessage?.parentMessageMessageType,
                parentMessageAttachmentUrl: messageInfo.metaData?.replyMessage?.parentMessageAttachmentUrl,
                parentMessageInitiator: messageInfo.metaData?.replyMessage?.parentMessageInitiator,
                parentMessagecaptionMessage: messageInfo.metaData?.replyMessage?.parentMessagecaptionMessage
            )
            
            // Prepare post and product details
            let postDetail = ISMChatPostMetaData(postId: messageInfo.metaData?.post?.postId, postUrl: messageInfo.metaData?.post?.postUrl)
            let productDetail = ISMChatProductMetaData(productId: messageInfo.metaData?.product?.productId, productUrl: messageInfo.metaData?.product?.productUrl, productCategoryId: messageInfo.metaData?.product?.productCategoryId)
            
            // Create metadata for the chat message
            let metaData = ISMChatMetaData(
                replyMessage: replyMessageData,
                locationAddress: messageInfo.metaData?.locationAddress,
                contacts: contact,
                captionMessage: messageInfo.metaData?.captionMessage,
                isBroadCastMessage: messageInfo.metaData?.isBroadCastMessage,
                post: postDetail,
                product: productDetail,
                storeName: messageInfo.metaData?.storeName,
                productName: messageInfo.metaData?.productName,
                bestPrice: messageInfo.metaData?.bestPrice,
                scratchPrice: messageInfo.metaData?.scratchPrice,
                url: messageInfo.metaData?.url,
                parentProductId: messageInfo.metaData?.parentProductId,
                childProductId: messageInfo.metaData?.childProductId,
                entityType: messageInfo.metaData?.entityType,
                productImage: messageInfo.metaData?.productImage,
                thumbnailUrl: messageInfo.metaData?.thumbnailUrl,
                description: messageInfo.metaData?.description,
                isVideoPost: messageInfo.metaData?.isVideoPost,
                socialPostId: messageInfo.metaData?.socialPostId,
                collectionTitle: messageInfo.metaData?.collectionTitle,
                collectionDescription: messageInfo.metaData?.collectionDescription,
                productCount: messageInfo.metaData?.productCount,
                collectionImage: messageInfo.metaData?.collectionImage,
                collectionId: messageInfo.metaData?.collectionId
            )
            
            // Prepare sender information
            let senderInfo = ISMChatUser(userId: messageInfo.senderId, userName: messageInfo.senderName, userIdentifier: messageInfo.senderIdentifier, userProfileImage: "")
            
            // Add members to the message
            var membersArray: [ISMChatMemberAdded] = []
            if let members = messageInfo.members {
                for x in members {
                    var member = ISMChatMemberAdded()
                    member.memberId = x.memberId
                    member.memberIdentifier = x.memberIdentifier
                    member.memberName = x.memberName
                    member.memberProfileImageUrl = x.memberProfileImageUrl
                    membersArray.append(member)
                }
            }
            
            // Update message body if details are provided
            var bodyUpdated = messageInfo.body
            if messageInfo.action == ISMChatActionType.messageDetailsUpdated.value {
                bodyUpdated = messageInfo.details?.body
            }
            
            // Prepare mentioned users
            var mentionedUser: [ISMChatMentionedUser] = []
            if messageInfo.mentionedUsers != nil {
                for x in mentionedUser {
                    let user = ISMChatMentionedUser(wordCount: x.wordCount, userId: x.userId, order: x.order)
                    mentionedUser.append(user)
                }
            }
            
            // Create the chat message object
            let message = ISMChatMessage(sentAt: messageInfo.sentAt, body: bodyUpdated, messageId: messageInfo.messageId, mentionedUsers: mentionedUser, metaData: metaData, customType: messageInfo.customType, action: messageInfo.action, attachment: messageInfo.attachments, conversationId: messageInfo.conversationId, userId: messageInfo.userId, userName: messageInfo.userName, initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName, memberName: messageInfo.memberName, memberId: messageInfo.memberId, memberIdentifier: messageInfo.memberIdentifier, senderInfo: senderInfo, members: membersArray, reactions: messageInfo.reactions)
            
            // Save the message to the realm manager
            realmManager.saveMessage(obj: [message])
            
            // Handle media fetching after saving the message
            if messageInfo.customType == ISMChatMediaType.Image.value || 
               messageInfo.customType == ISMChatMediaType.Video.value || 
               messageInfo.customType == ISMChatMediaType.gif.value {
                realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
            } else if messageInfo.customType == ISMChatMediaType.File.value {
                realmManager.fetchFiles(conId: self.conversationID ?? "")
            } else if let body = messageInfo.body, body.isValidURL && !body.contains("map") {
                realmManager.fetchLinks(conId: self.conversationID ?? "")
            }
            
            // Fetch messages and update the last message ID to scroll
            self.getMessages()
            parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
            if let converId = messageInfo.conversationId, let messId = messageInfo.messageId {
                chatViewModel.deliveredMessageIndicator(conversationId: converId, messageId: messId) { _ in
                    // Update status of message to delivered
                }
                chatViewModel.readMessageIndicator(conversationId: converId, messageId: messId) { _ in
                    // Update status of message to read
                    // After message is read, reset unread count
                    realmManager.updateUnreadCountThroughConId(conId: self.conversationID ?? "", count: 0, reset: true)
                }
            }
        }
    }
    
    // This function handles the addition of meeting messages
    func addMeeting(messageInfo: ISMMeeting) {
        var members: [ISMChatMemberAdded] = []
        // Collect members in the call
        if let membersInCall = messageInfo.members {
            for member in membersInCall {
                let y = ISMChatMemberAdded(memberProfileImageUrl: member.memberProfileImageURL, memberName: member.memberName, memberIdentifier: member.memberIdentifier, memberId: member.memberId, isPublishing: member.isPublishing, isAdmin: member.isAdmin)
                members.append(y)
            }
        }
        // Create the meeting message object
        let message = ISMChatMessage(sentAt: messageInfo.sentAt, messageId: messageInfo.messageId, customType: messageInfo.customType, initiatorIdentifier: messageInfo.initiatorIdentifier, action: messageInfo.action, conversationId: messageInfo.conversationId, initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName, members: members, missedByMembers: messageInfo.missedByMembers, meetingId: messageInfo.meetingId, callDurations: messageInfo.callDurations, audioOnly: messageInfo.audioOnly, autoTerminate: messageInfo.autoTerminate, config: messageInfo.config)
        
        // Save the meeting message
        realmManager.saveMessage(obj: [message])
        self.getMessages()
        parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
        
        // Update the last message of the conversation list item
        let lastMessage = ISMChatLastMessage(sentAt: messageInfo.sentAt, conversationId: self.conversationID ?? "", body: "", messageId: messageInfo.messageId, customType: messageInfo.customType, action: messageInfo.action, initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName, initiatorIdentifier: messageInfo.initiatorIdentifier)
        realmManager.updateLastmsg(conId: self.conversationID ?? "", msg: lastMessage)
    }

    // This function handles user block and unblock actions
    func userBlockedAndUnblocked(messageInfo: ISMChatUserBlockAndUnblock) {
        // Create a message object for the block/unblock action
        let message = ISMChatMessage(sentAt: messageInfo.sentAt, messageId: messageInfo.messageId, initiatorIdentifier: messageInfo.initiatorIdentifier, action: messageInfo.action, conversationId: self.conversationID ?? "", initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName)
        
        // Save the block/unblock message
        realmManager.saveMessage(obj: [message])
        self.getMessages()
        parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
        
        // Update the last message of the conversation list item
        let lastMessage = ISMChatLastMessage(sentAt: messageInfo.sentAt, conversationId: self.conversationID ?? "", body: "", messageId: messageInfo.messageId, action: messageInfo.action, initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName, initiatorIdentifier: messageInfo.initiatorIdentifier)
        realmManager.updateLastmsg(conId: self.conversationID ?? "", msg: lastMessage)
    }
    
    // This function handles user typing events
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
    
    // This function handles actions on message delivery
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
            realmManager.changeGroupName(conversationId: messageInfo.conversationId ?? "", conversationTitle: messageInfo.conversationTitle ?? "")
        } else if messageInfo.action == ISMChatActionType.conversationImageUpdated.value {
            // Update conversation image in local database
            realmManager.changeGroupIcon(conversationId: messageInfo.conversationId ?? "", conversationIcon: messageInfo.conversationImageUrl ?? "")
        }
    }
    
    // This function sends local notifications based on message actions
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
                        realmManager.changeGroupName(conversationId: messageInfo.conversationId ?? "", conversationTitle: messageInfo.conversationTitle ?? "")
                        ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") changed group name", userInfo: ["senderId": messageInfo.senderId ?? "", "senderName": messageInfo.senderName ?? "", "conversationId": messageInfo.conversationId ?? "", "body": messageInfo.notificationBody ?? "", "userIdentifier": messageInfo.senderIdentifier ?? ""])
                    } else if messageInfo.action == ISMChatActionType.conversationImageUpdated.value {
                        realmManager.changeGroupIcon(conversationId: messageInfo.conversationId ?? "", conversationIcon: messageInfo.conversationImageUrl ?? "")
                        ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") changed group icon", userInfo: ["senderId": messageInfo.senderId ?? "", "senderName": messageInfo.senderName ?? "", "conversationId": messageInfo.conversationId ?? "", "body": messageInfo.notificationBody ?? "", "userIdentifier": messageInfo.senderIdentifier ?? ""])
                    } else {
                        ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.senderName ?? "")", body: "\(messageInfo.notificationBody ?? (messageInfo.body ?? ""))", userInfo: ["senderId": messageInfo.senderId ?? "", "senderName": messageInfo.senderName ?? "", "conversationId": messageInfo.conversationId ?? "", "body": messageInfo.notificationBody ?? "", "userIdentifier": messageInfo.senderIdentifier ?? ""])
                    }
                }
            }
        }
    }
}
