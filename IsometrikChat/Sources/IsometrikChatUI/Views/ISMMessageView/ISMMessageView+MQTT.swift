//
//  ISMMessageView+MQTT.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 08/09/23.
//

import Foundation
import ISMSwiftCall


 extension ISMMessageView{
    func messageReceived(messageInfo : ISMChat_MessageDelivered){
        if messageInfo.conversationId == self.conversationID{
            if userSession.getUserId() == messageInfo.senderId{
            }else{
                var contact : [ISMChat_ContactMetaData] = []
                if let contacts = messageInfo.metaData?.contacts, contacts.count > 0{
                    for x in contacts{
                        var data = ISMChat_ContactMetaData()
                        data.contactIdentifier = x.contactIdentifier
                        data.contactImageData = x.contactImageData
                        data.contactImageUrl = x.contactImageUrl
                        data.contactName = x.contactName
                        contact.append(data)
                    }
                }
                
                let replyMessageData = ISMChat_ReplyMessageMetaData(
                    parentMessageId: messageInfo.parentMessageId,
                    parentMessageBody: messageInfo.metaData?.replyMessage?.parentMessageBody,
                    parentMessageUserId: messageInfo.metaData?.replyMessage?.parentMessageUserId,
                    parentMessageUserName: messageInfo.metaData?.replyMessage?.parentMessageUserName,
                    parentMessageMessageType: messageInfo.metaData?.replyMessage?.parentMessageMessageType,
                    parentMessageAttachmentUrl: messageInfo.metaData?.replyMessage?.parentMessageAttachmentUrl,
                    parentMessageInitiator: messageInfo.metaData?.replyMessage?.parentMessageInitiator,
                    parentMessagecaptionMessage: messageInfo.metaData?.replyMessage?.parentMessagecaptionMessage)
                
                let metaData = ISMChat_MetaData(replyMessage: replyMessageData,
                                           locationAddress: messageInfo.metaData?.locationAddress,
                                                contacts: contact,captionMessage: messageInfo.metaData?.captionMessage,isBroadCastMessage: messageInfo.metaData?.isBroadCastMessage)
                
                let senderInfo = ISMChat_User(userId: messageInfo.senderId, userName: messageInfo.senderName, userIdentifier: messageInfo.senderIdentifier, userProfileImage: "")
                
                //add members in Message
                var membersArray : [ISMChat_MemberAdded] = []
                if let members = messageInfo.members{
                    for x in members{
                        var member = ISMChat_MemberAdded()
                        member.memberId = x.memberId
                        member.memberIdentifier = x.memberIdentifier
                        member.memberName = x.memberName
                        member.memberProfileImageUrl = x.memberProfileImageUrl
                        membersArray.append(member)
                    }
                }
                
                var bodyUpdated = messageInfo.body
                if messageInfo.action == ISMChat_ActionType.messageDetailsUpdated.value{
                    bodyUpdated = messageInfo.details?.body
                }
                
                var mentionedUser : [ISMChat_MentionedUser] = []
                if let Users = messageInfo.mentionedUsers{
                    for x in mentionedUser{
                        var user = ISMChat_MentionedUser(wordCount: x.wordCount, userId: x.userId, order: x.order)
                        mentionedUser.append(user)
                    }
                }
                
                let message = ISMChat_Message(sentAt: messageInfo.sentAt,body: bodyUpdated, messageId: messageInfo.messageId,mentionedUsers: mentionedUser,metaData : metaData, customType: messageInfo.customType,action: messageInfo.action, attachment: messageInfo.attachments,conversationId: messageInfo.conversationId, userName: messageInfo.userName, initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName, memberName: messageInfo.memberName, memberId: messageInfo.memberId, memberIdentifier: messageInfo.memberIdentifier,senderInfo: senderInfo,members: membersArray,reactions: messageInfo.reactions)
                
                realmManager.saveMessage(obj: [message])
                
                self.getMessages()
                
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
        }
    }
    
     func messageDelivered(messageInfo : ISMChat_MessageDelivered){
         if messageInfo.conversationId == self.conversationID{
             if userSession.getUserId() == messageInfo.senderId || messageInfo.senderId == nil{
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
     
     func messageRead(messageInfo : ISMChat_MessageDelivered){
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
         var members : [ISMChat_MemberAdded] = []
         if let membersInCall = messageInfo.members{
             for member in membersInCall{
                 let y = ISMChat_MemberAdded(memberProfileImageUrl: member.memberProfileImageURL, memberName: member.memberName, memberIdentifier: member.memberIdentifier, memberId: member.memberId, isPublishing: member.isPublishing, isAdmin: member.isAdmin)
                 members.append(y)
             }
         }
         let message = ISMChat_Message(sentAt: messageInfo.sentAt, messageId: messageInfo.messageId, customType: messageInfo.customType, initiatorIdentifier: messageInfo.initiatorIdentifier, action: messageInfo.action, conversationId: messageInfo.conversationId, initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName, members: members, missedByMembers: messageInfo.missedByMembers, meetingId: messageInfo.meetingId, callDurations: messageInfo.callDurations, audioOnly: messageInfo.audioOnly, autoTerminate: messageInfo.autoTerminate, config: messageInfo.config)
         realmManager.saveMessage(obj: [message])
         self.getMessages()
         realmManager.parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
         
         //update last message of conversationList item too
         let lastMessage = ISMChat_LastMessage(sentAt: messageInfo.sentAt, conversationId: self.conversationID ?? "", body: "", messageId:  messageInfo.messageId, customType: messageInfo.customType, action: messageInfo.action, initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName, initiatorIdentifier: messageInfo.initiatorIdentifier)
         realmManager.updateLastmsg(conId: self.conversationID ?? "", msg: lastMessage)
     }

    
    func userBlockedAndUnblocked(messageInfo : ISMChat_UserBlockAndUnblock){
        let message = ISMChat_Message(sentAt: messageInfo.sentAt, messageId: messageInfo.messageId,initiatorIdentifier: messageInfo.initiatorIdentifier, action: messageInfo.action,conversationId: self.conversationID ?? "", initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName)
        realmManager.saveMessage(obj: [message])
        self.getMessages()
        realmManager.parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
        
        //update last message of conversationList item too
        let lastMessage = ISMChat_LastMessage(sentAt: messageInfo.sentAt, conversationId: self.conversationID ?? "", body: "", messageId:  messageInfo.messageId, action: messageInfo.action, initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName, initiatorIdentifier: messageInfo.initiatorIdentifier)
        realmManager.updateLastmsg(conId: self.conversationID ?? "", msg: lastMessage)
    }
    
    func userTyping(messageInfo : ISMChat_TypingEvent){
        if messageInfo.conversationId == self.conversationID{
            otherUserTyping = true
            typingUserName = messageInfo.userName
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                otherUserTyping = false
                typingUserName = nil
            }
        }
    }
    
     func multipleMessageRead(messageInfo : ISMChat_MultipleMessageRead){
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
     
     func actionOnMessageDelivered(messageInfo : ISMChat_MessageDelivered){
         //We have triggered "mqttMessageNewReceived" mqtt events for below actions too
         if messageInfo.action == ISMChat_ActionType.memberLeave.value{
             //check action == memberLeave or removeMEMBER and then remove that member from localdb
             getConversationDetail()
         }else if  messageInfo.action == ISMChat_ActionType.membersRemove.value{
             //check action == memberLeave or removeMEMBER and then remove that member from localdb
             getConversationDetail()
         }else if messageInfo.action == ISMChat_ActionType.membersAdd.value{
             //check action == membersAdd and then add that member to localdb
             getConversationDetail()
         }else if messageInfo.action == ISMChat_ActionType.conversationTitleUpdated.value{
             //update conversationTilte in localdb
             realmManager.changeGroupName(conversationId: messageInfo.conversationId ?? "", conversationTitle: messageInfo.conversationTitle ?? "")
         }else if messageInfo.action == ISMChat_ActionType.conversationImageUpdated.value{
             //update conversationImage in localdb
             realmManager.changeGroupIcon(conversationId: messageInfo.conversationId ?? "", conversationIcon: messageInfo.conversationImageUrl ?? "")
         }
     }
     
     func sendLocalNotification(messageInfo : ISMChat_MessageDelivered){
         if messageInfo.senderId != userSession.getUserId(){
             if messageInfo.conversationId !=  self.conversationID{
                 if userSession.getNotificationStatus() == true{
                     ISMChat_LocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.senderName ?? "")", body: "\(messageInfo.notificationBody ?? (messageInfo.body ?? ""))", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
                 }
                 if messageInfo.action == ISMChat_ActionType.memberLeave.value{
                     if userSession.getNotificationStatus() == true{
                         ISMChat_LocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") left group", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
                     }
                 }else if  messageInfo.action == ISMChat_ActionType.membersRemove.value{
                     let memberName = messageInfo.members?.first?.memberId == userSession.getUserId() ? ConstantStrings.you.lowercased() : messageInfo.members?.first?.memberName
                     if userSession.getNotificationStatus() == true{
                         ISMChat_LocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") removed \(memberName ?? "")", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
                     }
                 }else if messageInfo.action == ISMChat_ActionType.membersAdd.value{
                     let memberName = messageInfo.members?.first?.memberId == userSession.getUserId() ? ConstantStrings.you.lowercased() : messageInfo.members?.first?.memberName
                     if userSession.getNotificationStatus() == true{
                         ISMChat_LocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") added \(memberName ?? "")", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
                     }
                 }else if messageInfo.action == ISMChat_ActionType.conversationTitleUpdated.value{
                     realmManager.changeGroupName(conversationId: messageInfo.conversationId ?? "", conversationTitle: messageInfo.conversationTitle ?? "")
                     if userSession.getNotificationStatus() == true{
                         ISMChat_LocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") changed group name", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
                     }
                 }else if messageInfo.action == ISMChat_ActionType.conversationImageUpdated.value{
                     realmManager.changeGroupIcon(conversationId: messageInfo.conversationId ?? "", conversationIcon: messageInfo.conversationImageUrl ?? "")
                     if userSession.getNotificationStatus() == true{
                         ISMChat_LocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.conversationTitle ?? "")", body: "\(messageInfo.userName ?? "") changed group icon", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? ""])
                     }
                 }
             }
         }
     }
}
