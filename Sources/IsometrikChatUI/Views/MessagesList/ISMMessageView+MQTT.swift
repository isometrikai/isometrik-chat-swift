//
//  ISMMessageView+MQTT.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 08/09/23.
//

import Foundation
import ISMSwiftCall
import IsometrikChat

 extension ISMMessageView{
    func messageReceived(messageInfo : ISMChatMessageDelivered){
        if messageInfo.conversationId == self.conversationID{
            if userData.userId == messageInfo.senderId{
            }else{
                var contact : [ISMChatContactMetaData] = []
                if let contacts = messageInfo.metaData?.contacts, contacts.count > 0{
                    for x in contacts{
                        var data = ISMChatContactMetaData()
                        data.contactIdentifier = x.contactIdentifier
                        data.contactImageData = x.contactImageData
                        data.contactImageUrl = x.contactImageUrl
                        data.contactName = x.contactName
                        contact.append(data)
                    }
                }
                
                let replyMessageData = ISMChatReplyMessageMetaData(
                    parentMessageId: messageInfo.parentMessageId,
                    parentMessageBody: messageInfo.metaData?.replyMessage?.parentMessageBody,
                    parentMessageUserId: messageInfo.metaData?.replyMessage?.parentMessageUserId,
                    parentMessageUserName: messageInfo.metaData?.replyMessage?.parentMessageUserName,
                    parentMessageMessageType: messageInfo.metaData?.replyMessage?.parentMessageMessageType,
                    parentMessageAttachmentUrl: messageInfo.metaData?.replyMessage?.parentMessageAttachmentUrl,
                    parentMessageInitiator: messageInfo.metaData?.replyMessage?.parentMessageInitiator,
                    parentMessagecaptionMessage: messageInfo.metaData?.replyMessage?.parentMessagecaptionMessage)
                
                let postDetail = ISMChatPostMetaData(postId: messageInfo.metaData?.post?.postId, postUrl: messageInfo.metaData?.post?.postUrl)
                
                let metaData = ISMChatMetaData(replyMessage: replyMessageData,
                                           locationAddress: messageInfo.metaData?.locationAddress,
                                               contacts: contact,captionMessage: messageInfo.metaData?.captionMessage,isBroadCastMessage: messageInfo.metaData?.isBroadCastMessage,post: postDetail)
                
                let senderInfo = ISMChatUser(userId: messageInfo.senderId, userName: messageInfo.senderName, userIdentifier: messageInfo.senderIdentifier, userProfileImage: "")
                
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
                
                var bodyUpdated = messageInfo.body
                if messageInfo.action == ISMChatActionType.messageDetailsUpdated.value{
                    bodyUpdated = messageInfo.details?.body
                }
                
                var mentionedUser : [ISMChatMentionedUser] = []
                if let Users = messageInfo.mentionedUsers{
                    for x in mentionedUser{
                        var user = ISMChatMentionedUser(wordCount: x.wordCount, userId: x.userId, order: x.order)
                        mentionedUser.append(user)
                    }
                }
                
                let message = ISMChatMessage(sentAt: messageInfo.sentAt,body: bodyUpdated, messageId: messageInfo.messageId,mentionedUsers: mentionedUser,metaData : metaData, customType: messageInfo.customType,action: messageInfo.action, attachment: messageInfo.attachments,conversationId: messageInfo.conversationId, userName: messageInfo.userName, initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName, memberName: messageInfo.memberName, memberId: messageInfo.memberId, memberIdentifier: messageInfo.memberIdentifier,senderInfo: senderInfo,members: membersArray,reactions: messageInfo.reactions)
                
                realmManager.saveMessage(obj: [message])
                
                self.getMessages()
                
                realmManager.parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
                if let converId = messageInfo.conversationId, let messId = messageInfo.messageId{
                    viewModel.deliveredMessageIndicator(conversationId: converId, messageId: messId) { _ in
                        // update status of message to deleivered
                        viewModel.readMessageIndicator(conversationId: converId, messageId: messId) { _ in
                            // update status of message to read
                            
                            //after message is read then only resent unread count
                            realmManager.updateUnreadCountThroughConId(conId: self.conversationID ?? "",count: 0,reset:true)
                        }
                    }
                }
            }
        }
    }
    
     func messageDelivered(messageInfo : ISMChatMessageDelivered){
         if messageInfo.conversationId == self.conversationID{
             if userData.userId == messageInfo.senderId || messageInfo.senderId == nil{
                 if isGroup == true {
                     realmManager.addDeliveredToUser(convId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.updatedAt ?? -1)
                 }else {
                     realmManager.updateAllDeliveryStatus(conId: messageInfo.conversationId ?? "")
                 }
                 self.getMessages()
             }else{
                 realmManager.parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
                 if let converId = messageInfo.conversationId, let messId = messageInfo.messageId{
                     viewModel.deliveredMessageIndicator(conversationId: converId, messageId: messId) { _ in
                         // update status of message to deleivered
                         viewModel.readMessageIndicator(conversationId: converId, messageId: messId) { _ in
                             // update status of message to read
                         }
                     }
                 }
             }
             realmManager.updateUnreadCountThroughConId(conId: self.conversationID ?? "",count: 0,reset:true)
         }else{
             if let converId = messageInfo.conversationId, let messId = messageInfo.messageId{
                 viewModel.deliveredMessageIndicator(conversationId: converId, messageId: messId) { _ in
                     // update status of message to deleivered
                     
                 }
             }
         }
     }
     
     func messageRead(messageInfo : ISMChatMessageDelivered){
         if messageInfo.conversationId == self.conversationID{
             if isGroup == true {
                 realmManager.addReadByUser(convId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.updatedAt ?? 0)
             }else {
                 realmManager.updateDeliveryStatusThroughMsgId(conId: messageInfo.conversationId ?? "", msgId: messageInfo.messageId ?? "")
                 realmManager.updateReadStatusThroughMsgId(msgId: messageInfo.messageId ?? "")
             }
             realmManager.updateLastmsgDeliver(conId: self.conversationID ?? "", msg: messageInfo)
             realmManager.updateLastmsgRead(conId: self.conversationID ?? "", msg: messageInfo)
             self.getMessages()
         }else{
             //update for any conversation
             
         }
     }
     
     
     func addMeeting(messageInfo : ISMMeeting){
         var members : [ISMChatMemberAdded] = []
         if let membersInCall = messageInfo.members{
             for member in membersInCall{
                 let y = ISMChatMemberAdded(memberProfileImageUrl: member.memberProfileImageURL, memberName: member.memberName, memberIdentifier: member.memberIdentifier, memberId: member.memberId, isPublishing: member.isPublishing, isAdmin: member.isAdmin)
                 members.append(y)
             }
         }
         let message = ISMChatMessage(sentAt: messageInfo.sentAt, messageId: messageInfo.messageId, customType: messageInfo.customType, initiatorIdentifier: messageInfo.initiatorIdentifier, action: messageInfo.action, conversationId: messageInfo.conversationId, initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName, members: members, missedByMembers: messageInfo.missedByMembers, meetingId: messageInfo.meetingId, callDurations: messageInfo.callDurations, audioOnly: messageInfo.audioOnly, autoTerminate: messageInfo.autoTerminate, config: messageInfo.config)
         realmManager.saveMessage(obj: [message])
         self.getMessages()
         realmManager.parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
         
         //update last message of conversationList item too
         let lastMessage = ISMChatLastMessage(sentAt: messageInfo.sentAt, conversationId: self.conversationID ?? "", body: "", messageId:  messageInfo.messageId, customType: messageInfo.customType, action: messageInfo.action, initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName, initiatorIdentifier: messageInfo.initiatorIdentifier)
         realmManager.updateLastmsg(conId: self.conversationID ?? "", msg: lastMessage)
     }

    
    func userBlockedAndUnblocked(messageInfo : ISMChatUserBlockAndUnblock){
        let message = ISMChatMessage(sentAt: messageInfo.sentAt, messageId: messageInfo.messageId,initiatorIdentifier: messageInfo.initiatorIdentifier, action: messageInfo.action,conversationId: self.conversationID ?? "", initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName)
        realmManager.saveMessage(obj: [message])
        self.getMessages()
        realmManager.parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
        
        //update last message of conversationList item too
        let lastMessage = ISMChatLastMessage(sentAt: messageInfo.sentAt, conversationId: self.conversationID ?? "", body: "", messageId:  messageInfo.messageId, action: messageInfo.action, initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName, initiatorIdentifier: messageInfo.initiatorIdentifier)
        realmManager.updateLastmsg(conId: self.conversationID ?? "", msg: lastMessage)
    }
    
    func userTyping(messageInfo : ISMChatTypingEvent){
        if messageInfo.conversationId == self.conversationID{
            otherUserTyping = true
            typingUserName = messageInfo.userName
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                otherUserTyping = false
                typingUserName = nil
            }
        }
    }
    
     func multipleMessageRead(messageInfo : ISMChatMultipleMessageRead){
         if messageInfo.conversationId == self.conversationID{
             if self.isGroup == true {
                 realmManager.updateDeliveredToInAllmsgs(convId: messageInfo.conversationId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.lastReadAt ?? 0)
                 realmManager.updateReadbyInAllmsgs(convId: messageInfo.conversationId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.lastReadAt ?? 0)

             }else {
                 realmManager.updateAllDeliveryStatus(conId: messageInfo.conversationId ?? "")
                 realmManager.updateAllReadStatus(conId: messageInfo.conversationId ?? "")
             }
             self.getMessages()
         }
     }
     
     func actionOnMessageDelivered(messageInfo : ISMChatMessageDelivered){
         //We have triggered "mqttMessageNewReceived" mqtt events for below actions too
         if messageInfo.action == ISMChatActionType.memberLeave.value{
             //check action == memberLeave or removeMEMBER and then remove that member from localdb
             getConversationDetail()
         }else if  messageInfo.action == ISMChatActionType.membersRemove.value{
             //check action == memberLeave or removeMEMBER and then remove that member from localdb
             getConversationDetail()
         }else if messageInfo.action == ISMChatActionType.membersAdd.value{
             //check action == membersAdd and then add that member to localdb
             getConversationDetail()
         }else if messageInfo.action == ISMChatActionType.conversationTitleUpdated.value{
             //update conversationTilte in localdb
             realmManager.changeGroupName(conversationId: messageInfo.conversationId ?? "", conversationTitle: messageInfo.conversationTitle ?? "")
         }else if messageInfo.action == ISMChatActionType.conversationImageUpdated.value{
             //update conversationImage in localdb
             realmManager.changeGroupIcon(conversationId: messageInfo.conversationId ?? "", conversationIcon: messageInfo.conversationImageUrl ?? "")
         }
     }
     
     func sendLocalNotification(messageInfo : ISMChatMessageDelivered){
         if messageInfo.senderId != userData.userId{
             if messageInfo.conversationId !=  self.conversationID{
                 if userData.allowNotification == true{
                     ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.senderName ?? "")", body: "\(messageInfo.notificationBody ?? (messageInfo.body ?? ""))", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
                 }
                 if messageInfo.action == ISMChatActionType.memberLeave.value{
                     if userData.allowNotification == true{
                         ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") left group", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
                     }
                 }else if  messageInfo.action == ISMChatActionType.membersRemove.value{
                     let memberName = messageInfo.members?.first?.memberId == userData.userId ? ConstantStrings.you.lowercased() : messageInfo.members?.first?.memberName
                     if userData.allowNotification == true{
                         ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") removed \(memberName ?? "")", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
                     }
                 }else if messageInfo.action == ISMChatActionType.membersAdd.value{
                     let memberName = messageInfo.members?.first?.memberId == userData.userId ? ConstantStrings.you.lowercased() : messageInfo.members?.first?.memberName
                     if userData.allowNotification == true{
                         ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") added \(memberName ?? "")", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
                     }
                 }else if messageInfo.action == ISMChatActionType.conversationTitleUpdated.value{
                     realmManager.changeGroupName(conversationId: messageInfo.conversationId ?? "", conversationTitle: messageInfo.conversationTitle ?? "")
                     if userData.allowNotification == true{
                         ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") changed group name", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
                     }
                 }else if messageInfo.action == ISMChatActionType.conversationImageUpdated.value{
                     realmManager.changeGroupIcon(conversationId: messageInfo.conversationId ?? "", conversationIcon: messageInfo.conversationImageUrl ?? "")
                     if userData.allowNotification == true{
                         ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") changed group icon", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
                     }
                 }
             }
         }
     }
}
