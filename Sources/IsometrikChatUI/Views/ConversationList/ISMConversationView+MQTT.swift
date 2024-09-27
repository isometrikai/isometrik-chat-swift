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
    
    func localNotificationForActions(messageInfo: ISMChatMessageDelivered){
        //We have triggered "mqttMessageNewReceived" mqtt events for below actions too
        if messageInfo.action == ISMChatActionType.memberLeave.value{
            //check action == memberLeave or removeMEMBER and then remove that member from localdb
            realmManager.updateMemberCount(convId: messageInfo.conversationId ?? "", inc: false, dec: true, count: 1)
            if onScreen == true{
                if myUserData.allowNotification == true && messageInfo.meetingId == nil{
                    ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") left group", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
                }
            }
        }else if  messageInfo.action == ISMChatActionType.membersRemove.value{
            //check action == memberLeave or removeMEMBER and then remove that member from localdb
            if messageInfo.meetingId == nil{
                realmManager.updateMemberCount(convId: messageInfo.conversationId ?? "", inc: false, dec: true, count: 1)
                if onScreen == true{
                    let memberName = messageInfo.members?.first?.memberId == myUserData.userId ? ConstantStrings.you.lowercased() : messageInfo.members?.first?.memberName
                    if myUserData.allowNotification == true{
                        ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") removed \(memberName ?? "")", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
                    }
                }
            }
        }else if messageInfo.action == ISMChatActionType.membersAdd.value{
            //check action == membersAdd and then add that member to localdb
            if messageInfo.meetingId == nil{
                realmManager.updateMemberCount(convId: messageInfo.conversationId ?? "", inc: true, dec: false, count: 1)
                if onScreen == true{
                    let memberName = messageInfo.members?.first?.memberId == myUserData.userId ? ConstantStrings.you.lowercased() : messageInfo.members?.first?.memberName
                    if myUserData.allowNotification == true{
                        ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") added \(memberName ?? "")", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
                    }
                }
            }
        }else if messageInfo.action == ISMChatActionType.conversationTitleUpdated.value{
            //update conversationTilte in localdb
            if onScreen == true{
                realmManager.changeGroupName(conversationId: messageInfo.conversationId ?? "", conversationTitle: messageInfo.conversationTitle ?? "")
                if myUserData.allowNotification == true{
                    ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") changed group name", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
                }
            }
        }else if messageInfo.action == ISMChatActionType.conversationImageUpdated.value{
            //update conversationImage in localdb
            if onScreen == true{
                realmManager.changeGroupIcon(conversationId: messageInfo.conversationId ?? "", conversationIcon: messageInfo.conversationImageUrl ?? "")
                if myUserData.allowNotification == true{
                    ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") changed group icon", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
                }
            }
        }
    }
    
    func messageDeleteForAll(messageInfo: ISMChatMessageDelivered) {
        if let messageIds = messageInfo.messageIds {
            for message in messageIds {
                realmManager.updateMessageAsDeleted(conId: messageInfo.conversationId ?? "", messageId: message)
            }
            //Also update last message if its deleted for everyone
            if messageIds.contains(where: { messageId in
                realmManager.conversations.contains { conversation in
                    if let lastMessageId = conversation.lastMessageDetails?.messageId {
                        return messageId == lastMessageId
                    }
                    return false
                }
            }) {
                var membersArray : [ISMChatMemberAdded] = []
                if let members = messageInfo.members{
                    for x in members{
                        var member = ISMChatMemberAdded()
                        member.memberId = x.memberId
                        member.memberIdentifier = x.memberIdentifier
                        member.memberName = x.memberName
                        member.memberProfileImageUrl = x.memberProfileImageUrl
                        membersArray.append(member)
                    }
                }
                
                let msg = ISMChatLastMessage(sentAt: messageInfo.sentAt,senderName: messageInfo.senderName,senderIdentifier: messageInfo.senderIdentifier,senderId: messageInfo.senderId,conversationId: messageInfo.conversationId,body: messageInfo.body ?? "",messageId: messageInfo.messageId,deliveredToUser: messageInfo.userId,timeStamp: messageInfo.sentAt,customType: messageInfo.customType,messageDeleted: true, action: messageInfo.action, userId: messageInfo.userId, initiatorId: messageInfo.initiatorId, memberName: messageInfo.memberName, initiatorName: messageInfo.initiatorName, memberId: messageInfo.memberId, userName: messageInfo.userName,members: membersArray,userIdentifier: messageInfo.userIdentifier,userProfileImageUrl: messageInfo.userProfileImageUrl)
                
                self.realmManager.updateLastmsg(conId: messageInfo.conversationId ?? "", msg: msg)
            }
        }
    }
    
    func blockUnblockUserEvent(messageInfo : ISMChatUserBlockAndUnblock){
        if myUserData.userId != messageInfo.initiatorId{
            let msg = ISMChatLastMessage(sentAt: messageInfo.sentAt,conversationId: messageInfo.conversationId, body: nil, messageId: messageInfo.messageId, deliveredToUser: messageInfo.opponentId, timeStamp: messageInfo.sentAt, action: messageInfo.action, initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName,initiatorIdentifier: messageInfo.initiatorIdentifier)
            
            self.realmManager.updateLastmsg(conId: messageInfo.conversationId ?? "", msg: msg)
            
            if messageInfo.action == ISMChatActionType.conversationCreated.value{
                self.realmManager.updateUnreadCountThroughConId(conId: messageInfo.conversationId ?? "", count: 0)
            }else{
                self.realmManager.updateUnreadCountThroughConId(conId: messageInfo.conversationId ?? "", count: 1)
            }
            
            self.realmManager.getAllConversations()
            //added code to take user at top
            self.viewModel.updateConversationObj(conversations: viewModel.getSortedFilteredChats(conversation: viewModel.conversations, query: query))
        }
    }
    
    func addReaction(messageInfo: ISMChatReactions){
        //update last message in conversationList
        let msg = ISMChatLastMessage(sentAt: messageInfo.sentAt,conversationId: messageInfo.conversationId, body: nil, messageId: messageInfo.messageId, timeStamp: messageInfo.sentAt, action: messageInfo.action,userName: messageInfo.userName ?? "", reactionType: messageInfo.reactionType)
        
        self.realmManager.updateLastmsg(conId: messageInfo.conversationId ?? "", msg: msg)
        // increase unread count
//        self.realmManager.updateUnreadCountThroughConId(conId: messageInfo.conversationId ?? "", count: 1)
        
        self.realmManager.getAllConversations()
        
        self.viewModel.updateConversationObj(conversations: viewModel.getSortedFilteredChats(conversation: viewModel.conversations, query: query))
        
        realmManager.addReactionToMessage(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", reaction: messageInfo.reactionType ?? "", userId: messageInfo.userId ?? "")
    }
    
    func removeReaction(messageInfo: ISMChatReactions){
        //update last message in conversationList
        let msg = ISMChatLastMessage(sentAt: messageInfo.sentAt,conversationId: messageInfo.conversationId, body: nil, messageId: messageInfo.messageId, timeStamp: messageInfo.sentAt, action: messageInfo.action,userName: messageInfo.userName ?? "", reactionType: messageInfo.reactionType)
        
        self.realmManager.updateLastmsg(conId: messageInfo.conversationId ?? "", msg: msg)
        
//        self.realmManager.updateUnreadCountThroughConId(conId: messageInfo.conversationId ?? "", count: 1)
        
        self.realmManager.getAllConversations()
        
        self.viewModel.updateConversationObj(conversations: viewModel.getSortedFilteredChats(conversation: viewModel.conversations, query: query))
        
        realmManager.removeReactionFromMessage(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", reaction: messageInfo.reactionType ?? "", userId: messageInfo.userId ?? "")
    }
    
    func msgReceived(messageInfo: ISMChatMessageDelivered) {
        if myUserData.userId != messageInfo.senderId{
            //add members in Message
            
            var membersArray : [ISMChatMemberAdded] = []
            if let members = messageInfo.members{
                for x in members{
                    var member = ISMChatMemberAdded()
                    member.memberId = x.memberId
                    member.memberIdentifier = x.memberIdentifier
                    member.memberName = x.memberName
                    member.memberProfileImageUrl = x.memberProfileImageUrl
                    membersArray.append(member)
                }
            }
            
            let msg = ISMChatLastMessage(sentAt: messageInfo.sentAt,senderName: messageInfo.senderName,senderIdentifier: messageInfo.senderIdentifier,senderId: messageInfo.senderId,conversationId: messageInfo.conversationId,body: messageInfo.body ?? "",messageId: messageInfo.messageId,deliveredToUser: messageInfo.userId,timeStamp: messageInfo.sentAt,customType: messageInfo.customType,action: messageInfo.action, userId: messageInfo.userId, initiatorId: messageInfo.initiatorId, memberName: messageInfo.memberName, initiatorName: messageInfo.initiatorName, memberId: messageInfo.memberId, userName: messageInfo.userName,members: membersArray,userIdentifier: messageInfo.userIdentifier,userProfileImageUrl: messageInfo.userProfileImageUrl)
            
            self.realmManager.updateLastmsg(conId: messageInfo.conversationId ?? "", msg: msg)
            
            if messageInfo.action == ISMChatActionType.conversationCreated.value{
                self.realmManager.updateUnreadCountThroughConId(conId: messageInfo.conversationId ?? "", count: 0)
            }else{
                //update unread count
                let obj = self.realmManager.conversations.first(where: {$0.conversationId == messageInfo.conversationId ?? ""})
                self.realmManager.updateUnreadCountThroughConId(conId: messageInfo.conversationId ?? "", count: 1)
                //if message is deleted And msg comes from same user
                if obj == nil{
                    self.realmManager.undodeleteConversation(convID: messageInfo.conversationId ?? "")
                    self.getConversationList()
                }
            }
            
            self.realmManager.getAllConversations()
            //added code to take user at top
            self.viewModel.updateConversationObj(conversations: viewModel.getSortedFilteredChats(conversation: viewModel.conversations, query: query))
            //DELIVERED MSG API
            if let converId = messageInfo.conversationId, let messId = messageInfo.messageId{
                chatViewModel.deliveredMessageIndicator(conversationId: converId, messageId: messId) { _ in
                    
                }
            }
            if onScreen == true{
                if myUserData.allowNotification == true{
                    ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.senderName ?? "")", body: "\(messageInfo.notificationBody ?? (messageInfo.body ?? ""))", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? "","messageId" : messageInfo.messageId ?? ""])
                }
            }
        }
    }
    
    
    func msgDelivered(messageInfo: ISMChatMessageDelivered) {
        if myUserData.userId != messageInfo.senderId {
            let msg = ISMChatLastMessage(sentAt: messageInfo.sentAt,senderName: messageInfo.senderName,senderIdentifier: messageInfo.senderIdentifier,senderId: messageInfo.senderId,conversationId: messageInfo.conversationId,body: messageInfo.body ?? "",messageId: messageInfo.messageId,deliveredToUser: messageInfo.userId,timeStamp: messageInfo.sentAt,customType: messageInfo.customType,action: messageInfo.action, userId: messageInfo.userId, initiatorId: messageInfo.initiatorId, memberName: messageInfo.memberName, initiatorName: messageInfo.initiatorName, memberId: messageInfo.memberId, userName: messageInfo.userName,userIdentifier: messageInfo.userIdentifier,userProfileImageUrl: messageInfo.userProfileImageUrl)
            
            self.realmManager.updateLastmsg(conId: messageInfo.conversationId ?? "", msg: msg)
            
            if messageInfo.action == ISMChatActionType.conversationCreated.value{
                self.realmManager.updateUnreadCountThroughConId(conId: messageInfo.conversationId ?? "", count: 0)
            }else{
                //update unread count, for 1 to 1 only
                let obj = self.realmManager.conversations.first(where: {$0.conversationId == messageInfo.conversationId ?? ""})
                if obj?.isGroup == false {
                    self.realmManager.updateUnreadCountThroughConId(conId: messageInfo.conversationId ?? "", count: 1)
                }
            }
            
            realmManager.updateDeliveredToInAllmsgs(convId: messageInfo.conversationId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.updatedAt ?? 0)
            
            
            self.realmManager.getAllConversations()
            //added code to take user at top
            self.viewModel.updateConversationObj(conversations: viewModel.getSortedFilteredChats(conversation: viewModel.conversations, query: query))
            //DELIVERED MSG API
            if let converId = messageInfo.conversationId, let messId = messageInfo.messageId{
                chatViewModel.deliveredMessageIndicator(conversationId: converId, messageId: messId) { _ in
                    
                }
            }
        }else{
            realmManager.updateDeliveryStatusThroughMsgId(conId: messageInfo.conversationId ?? "", msgId: messageInfo.messageId ?? "")
        }
    }
    
    func messageRead(messageInfo : ISMChatMultipleMessageRead){
        // update deliverey and read status
        realmManager.updateLastmsgReadInfo(conId: messageInfo.conversationId ?? "", msgId: messageInfo.messageId ?? "",userId:messageInfo.userId ?? "",updatedAt:messageInfo.sentAt ?? 00)
        realmManager.updateLastmsgDeliverInfo(conId: messageInfo.conversationId ?? "", msgId: messageInfo.messageId ?? "",userId:messageInfo.userId ?? "",updatedAt:messageInfo.sentAt ?? 00)
        
        realmManager.updateAllDeliveryStatus(conId: messageInfo.conversationId ?? "")
        realmManager.updateAllReadStatus(conId: messageInfo.conversationId ?? "")
        
        realmManager.updateReadbyInAllmsgs(convId: messageInfo.conversationId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.lastReadAt ?? 0)
        if onScreen == true {
            self.realmManager.getAllConversations()
        }
    }
    
    func typingStatus(obj: ISMChatTypingEvent) {
        self.realmManager.changeTypingStatus(convId: obj.conversationId ?? "", status: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.realmManager.changeTypingStatus(convId: obj.conversationId ?? "", status: false)
        }
    }
    
    func handleLocalNotification(conversationId : String){
        conversationIdForNotification = conversationId
        let conversation = realmManager.conversations.first { data in
            data.conversationId == conversationIdForNotification
        }
        //update unread count, for grp only
        let obj = self.realmManager.conversations.first(where: {$0.conversationId == conversationId})
        if obj?.isGroup == true {
            self.realmManager.updateUnreadCountThroughConId(conId: conversationId , count: 1)
        }
        if let isgroup = conversation?.isGroup{
            isGroupFromNotification = isgroup
        }
        groupTitleFromNotification = conversation?.conversationTitle
        opponentDetailforNotification = conversation?.opponentDetails
        navigateToMessageViewFromLocalNotification = true
    }
}

