//
//  ISMConversationView+MQTT.swift
//  ISMChatSdk
//
//  Created by Rasika on 02/05/24.
//

import Foundation
import SwiftUI
import IsometrikChat

extension ISMConversationView{
    
    /// Handles local notifications for various actions related to chat messages.
    /// - Parameter messageInfo: Information about the delivered chat message.
//    func localNotificationForActions(messageInfo: ISMChatMessageDelivered){
//        // Check if the action is a member leaving the conversation
//        if messageInfo.action == ISMChatActionType.memberLeave.value{
//            // Update member count in local database
//            dbManager.updateMemberCount(convId: messageInfo.conversationId ?? "", inc: false, dec: true, count: 1)
//            // Check if notifications are allowed and if the meeting ID is nil
//            if onConversationList == true && myUserData?.allowNotification == true && messageInfo.meetingId == nil{
//                // Set a local notification for the member leaving
//                ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") left group", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
//            }
//        }else if  messageInfo.action == ISMChatActionType.membersRemove.value{
//            // Update member count in local database
//            if messageInfo.meetingId == nil{
//                dbManager.updateMemberCount(convId: messageInfo.conversationId ?? "", inc: false, dec: true, count: 1)
//                if onConversationList == true{
//                    // Determine the member's name for the notification
//                    let memberName = messageInfo.members?.first?.memberId == myUserData?.userId ? ConstantStrings.you.lowercased() : messageInfo.members?.first?.memberName
//                    if myUserData?.allowNotification == true{
//                        // Set a local notification for the member being removed
//                        ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") removed \(memberName ?? "")", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
//                    }
//                }
//            }
//        }else if messageInfo.action == ISMChatActionType.membersAdd.value{
//            // Update member count in local database
//            if messageInfo.meetingId == nil{
//                dbManager.updateMemberCount(convId: messageInfo.conversationId ?? "", inc: true, dec: false, count: 1)
//                if onConversationList == true{
//                    // Determine the member's name for the notification
//                    let memberName = messageInfo.members?.first?.memberId == myUserData?.userId ? ConstantStrings.you.lowercased() : messageInfo.members?.first?.memberName
//                    if myUserData?.allowNotification == true{
//                        // Set a local notification for the member being added
//                        ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") added \(memberName ?? "")", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
//                    }
//                }
//            }
//        }else if messageInfo.action == ISMChatActionType.conversationTitleUpdated.value{
//            // Update conversation title in local database
//            if onConversationList == true{
//                dbManager.changeGroupName(conversationId: messageInfo.conversationId ?? "", conversationTitle: messageInfo.conversationTitle ?? "")
//                if myUserData?.allowNotification == true{
//                    // Set a local notification for the title change
//                    ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") changed group name", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
//                }
//            }
//        }else if messageInfo.action == ISMChatActionType.conversationImageUpdated.value{
//            // Update conversation image in local database
//            if onConversationList == true{
//                dbManager.changeGroupIcon(conversationId: messageInfo.conversationId ?? "", conversationIcon: messageInfo.conversationImageUrl ?? "")
//                if myUserData?.allowNotification == true{
//                    // Set a local notification for the image change
//                    ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") changed group icon", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
//                }
//            }
//        }
//    }
    
    /// Deletes messages for all users in the conversation.
    /// - Parameter messageInfo: Information about the delivered chat message.
//    func messageDeleteForAll(messageInfo: ISMChatMessageDelivered) {
//        if let messageIds = messageInfo.messageIds {
//            for message in messageIds {
////                realmManager.updateMessageAsDeleted(conId: messageInfo.conversationId ?? "", messageId: message)
//            }
//            // Also update last message if its deleted for everyone
//            if messageIds.contains(where: { messageId in
//                dbManager.fetchAllConversations().contains { conversation in
//                    if let lastMessageId = conversation.lastMessageDetails?.messageId {
//                        return messageId == lastMessageId
//                    }
//                    return false
//                }
//            }) {
//                var membersArray : [ISMChatMemberAdded] = []
//                if let members = messageInfo.members{
//                    for x in members{
//                        var member = ISMChatMemberAdded()
//                        member.memberId = x.memberId
//                        member.memberIdentifier = x.memberIdentifier
//                        member.memberName = x.memberName
//                        member.memberProfileImageUrl = x.memberProfileImageUrl
//                        membersArray.append(member)
//                    }
//                }
//                
//                let msg = ISMChatLastMessage(sentAt: messageInfo.sentAt,senderName: messageInfo.senderName,senderIdentifier: messageInfo.senderIdentifier,senderId: messageInfo.senderId,conversationId: messageInfo.conversationId,body: messageInfo.body ?? "",messageId: messageInfo.messageId,deliveredToUser: messageInfo.userId,timeStamp: messageInfo.sentAt,customType: messageInfo.customType,messageDeleted: true, action: messageInfo.action, userId: messageInfo.userId, initiatorId: messageInfo.initiatorId, memberName: messageInfo.memberName, initiatorName: messageInfo.initiatorName, memberId: messageInfo.memberId, userName: messageInfo.userName,members: membersArray,userIdentifier: messageInfo.userIdentifier,userProfileImageUrl: messageInfo.userProfileImageUrl)
//                
//                self.dbManager.updateLastmsg(conId: messageInfo.conversationId ?? "", msg: msg)
//            }
//        }
//    }
    
    /// Handles blocking and unblocking of users in the conversation.
    /// - Parameter messageInfo: Information about the block/unblock event.
//    func blockUnblockUserEvent(messageInfo : ISMChatUserBlockAndUnblock){
//        if myUserData?.userId != messageInfo.initiatorId{
//            let msg = ISMChatLastMessage(sentAt: messageInfo.sentAt,conversationId: messageInfo.conversationId, body: nil, messageId: messageInfo.messageId, deliveredToUser: messageInfo.opponentId, timeStamp: messageInfo.sentAt, action: messageInfo.action, initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName,initiatorIdentifier: messageInfo.initiatorIdentifier)
//            
//            self.dbManager.updateLastmsg(conId: messageInfo.conversationId ?? "", msg: msg)
//            
//            if messageInfo.action == ISMChatActionType.conversationCreated.value{
//                self.dbManager.updateUnreadCountThroughConId(conId: messageInfo.conversationId ?? "", count: 0)
//            }else{
//                self.dbManager.updateUnreadCountThroughConId(conId: messageInfo.conversationId ?? "", count: 1)
//            }
//            
////            self.realmManager.getAllConversations()
//            //added code to take user at top
//            self.viewModel.updateConversationObj(conversations: viewModel.getSortedFilteredChats(conversation: viewModel.conversations, query: query))
//        }
//    }
    
    /// All things are happening in mqtt Manager, we are just refreshing list, to come that chat on top
//    func reactionUpdate(messageInfo: ISMChatReactions){
//        if conversationData.first?.conversationId != messageInfo.conversationId{
//            //added code to take user at top
//            self.viewModel.updateConversationObj(conversations: viewModel.getSortedFilteredChats(conversation: viewModel.conversations, query: query))
//        }
//    }
    
    /// Handles the receipt of a new message.
    /// - Parameter messageInfo: Information about the delivered chat message.
//    func msgReceived(messageInfo: ISMChatMessageDelivered) {
//        if myUserData?.userId != messageInfo.senderId{
//            if messageInfo.action != ISMChatActionType.conversationCreated.value{
//                // Update unread count
//                let obj = dbManager.fetchAllConversations().first(where: {$0.conversationId == messageInfo.conversationId ?? ""})
//                if obj == nil{
//                    self.dbManager.undodeleteConversation(convID: messageInfo.conversationId ?? "")
//                    self.getConversationList()
//                }
//            }
//            
////            self.realmManager.getAllConversations()
//            if conversationData.first?.conversationId != messageInfo.conversationId{
//                //added code to take user at top
//                self.viewModel.updateConversationObj(conversations: viewModel.getSortedFilteredChats(conversation: viewModel.conversations, query: query))
//            }
//            
//            if myUserData?.allowNotification == true && onConversationList == true{
//                self.localNotificationForActions(messageInfo: messageInfo)
//                ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.senderName ?? "")", body: "\(messageInfo.notificationBody ?? (messageInfo.body ?? ""))", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? "","messageId" : messageInfo.messageId ?? ""])
//            }
//        }
//    }
    
    /// Updates the typing status for a conversation.
    /// - Parameter obj: Information about the typing event.
//    func typingStatus(obj: ISMChatTypingEvent) {
//        self.dbManager.changeTypingStatus(convId: obj.conversationId ?? "", status: true)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            self.dbManager.changeTypingStatus(convId: obj.conversationId ?? "", status: false)
//        }
//    }
    
    /// Handles local notifications for a specific conversation.
    /// - Parameter conversationId: The ID of the conversation for which to handle notifications.
//    func handleLocalNotification(conversationId: String) {
//        conversationIdForNotification = conversationId
//
//        // Fetch conversation once and use it
//        guard let conversation = dbManager.fetchAllConversations().first(where: { $0.conversationId == conversationId }) else {
//            return
//        }
//
//        // Update unread count if it's a group
//        if conversation.isGroup {
//            dbManager.updateUnreadCountThroughConId(conId: conversationId, count: 1)
//        }
//
//        // Assign values safely
//        isGroupFromNotification = conversation.isGroup
//        groupTitleFromNotification = conversation.conversationTitle
//        opponentDetailforNotification = conversation.opponentDetails
//        
//        // Trigger navigation
//        navigateToMessageViewFromLocalNotification = true
//    }
}

