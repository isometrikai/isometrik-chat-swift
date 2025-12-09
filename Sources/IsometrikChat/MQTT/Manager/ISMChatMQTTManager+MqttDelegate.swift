//
//  SwiftUIView.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 31/01/25.
//

import Foundation
import CocoaMQTT
import UIKit
import ISMSwiftCall

protocol ISMChatMQTTManagerDelegate: AnyObject {
    func didReceiveTypingEvent(data: ISMChatTypingEvent)
    func didReceiveConversationCreated(data: ISMChatCreateConversation)
    func didReceiveMessageDelivered(data: ISMChatMessageDelivered)
    func didReceiveMessageRead(data: ISMChatMessageDelivered)
    func didReceiveMessageDeleteForAll(data: ISMChatMessageDelivered)
    func didReceiveMultipleMessageRead(data: ISMChatMultipleMessageRead)
    func didReceiveMessage(data: ISMChatMessageDelivered)
    func didReceiveAddReaction(data: Data)
    func didReceiveRemoveReaction(data: Data)
    func didReceiveBlockAndUnBlockUser(data: ISMChatUserBlockAndUnblock)
    func didReceiveBlockAndUnBlockConversation(data: ISMChatMessageDelivered)
    func didReceiveMessageDetailUpdated(data: ISMChatMessageDelivered)
}

extension ISMChatMQTTManager: CocoaMQTTDelegate {
    public func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        ISMChatHelper.print("trust: \(trust)")
        completionHandler(true)
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        ISMChatHelper.print("ack: \(ack)")
        if ack == .accept {
            self.reconnectAttempts = 0
            self.stopReconnectTimer()
            let client = clientId
            let messageTopic =
            "/\(self.projectConfiguration?.accountId ?? "")/\(self.projectConfiguration?.projectId ?? "")/Message/\(client)"
            let statusTopic =
            "/\(self.projectConfiguration?.accountId ?? "")/\(self.projectConfiguration?.projectId ?? "")/Status/\(client)"
            mqtt.subscribe([(messageTopic,.qos0),(statusTopic,qos: .qos0)])
            self.hasConnected = true
        } else {
            self.hasConnected = false
            mqtt.disconnect()
            self.handleConnectionFailure()
        }
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        ISMChatHelper.print("new state: \(state)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        ISMChatHelper.print("message: \(message.string?.description ?? ""), id: \(id)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        ISMChatHelper.print("id: \(id)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        if ISMChatSdk.getInstance().checkifChatInitialied() == true{
            TRACE("message topic: \(message.topic)")
            TRACE("message: \(message.string?.description ?? ""), id: \(id)")
            
            let messageString = "\(message.string?.description ?? "")"
            let data = Data(messageString.utf8)
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return
            }
            if let actionName = json["action"] as? String {
                if let userID = json["userId"] as? String, userID != userData?.userId{
                    ISMChatHelper.print("Event triggered with ACTION NAME Opposite USer :: \(actionName)")
                    ISMChatHelper.print("Response From MQTT Opposite USer :: \(json)")
                    switchEvents(actionName: actionName, data: data, message: message)
                }else if let userID = json["opponentId"] as? String, userID == userData?.userId{
                    ISMChatHelper.print("Event triggered with ACTION NAME Same user:: \(actionName)")
                    ISMChatHelper.print("Response From MQTT Same USer :: \(json)")
                    switchEvents(actionName: actionName, data: data, message: message)
                }else{
                    ISMChatHelper.print("Event triggered with ACTION NAME Same user:: \(actionName)")
                    switchEvents(actionName: actionName, data: data, message: message)
                }
            }else{
                //some times for broadcast messages action doesn't comes
                messageReceivedEvent(data: data)
            }
        }
    }
    
    func switchEvents(actionName : String,data : Data,message : CocoaMQTTMessage){
        switch ISMChatMQTTData.dataType(actionName) {
        case .mqttTypingEvent:
            self.typingEventResponse(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttTypingEvent.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttTypingEvent.name, object: nil,userInfo: ["data": "data","error" : error])
                }
            }
        case .mqttConversationCreated:
            self.conversationCreatedResponse(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttConversationCreated.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttConversationCreated.name, object: nil,userInfo: ["data": "data","error" : error])
                }
            }
        case .mqttMessageDelivered:
            self.messageDelivered(data) { result in
                switch result{
                case .success(let messageInfo):
                    if ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userId != messageInfo.userId{
                        self.realmManager.updateLastmsgDeliver(conId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.updatedAt ?? 0)
                        self.realmManager.addDeliveredToUser(convId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.updatedAt ?? -1)
                        self.realmManager.updateAllDeliveryStatus(conId: messageInfo.conversationId ?? "")
                        // Notify UI to refresh messages and conversation list after delivery update
                        NotificationCenter.default.post(name: NSNotification.refrestMessagesListLocally, object: nil)
                        NotificationCenter.default.post(name: NSNotification.refreshConvList, object: nil)
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        case .mqttMessageRead:
            self.messageRead(data) { result in
                switch result{
                case .success(let messageInfo):
                    self.realmManager.addReadByUser(convId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.updatedAt ?? 0)
                    self.realmManager.updateDeliveryStatusThroughMsgId(conId: messageInfo.conversationId ?? "", msgId: messageInfo.messageId ?? "")
                    self.realmManager.updateReadStatusThroughMsgId(msgId: messageInfo.messageId ?? "")
                    
                    self.realmManager.updateLastmsgRead(conId: messageInfo.conversationId ?? "",messageId: messageInfo.messageId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.updatedAt ?? 0)
                    NotificationCenter.default.post(name: NSNotification.updateChatBadgeCount, object: nil, userInfo: nil)
//                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageRead.name, object: nil,userInfo: ["data": data,"error" : ""])
                    // Notify UI to refresh messages and conversation list after delivery update
                    NotificationCenter.default.post(name: NSNotification.refrestMessagesListLocally, object: nil)
                    NotificationCenter.default.post(name: NSNotification.refreshConvList, object: nil)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        case .mqttMessageDeleteForAll:
            self.messageDeleteForAll(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageDeleteForAll.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageDeleteForAll.name, object: nil,userInfo: ["data": "data","error" : error])
                }
            }
        case .mqttMultipleMessageRead:
            self.multipleMessageRead(data) { result in
                switch result{
                case .success(let messageInfo):
                    if ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userId != messageInfo.userId{
                        self.realmManager.updateLastmsgRead(conId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.sentAt ?? 00)
                        self.realmManager.updateAllReadStatus(conId: messageInfo.conversationId ?? "")
                        self.realmManager.updateDeliveredToInAllmsgs(convId: messageInfo.conversationId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.lastReadAt ?? 0)
                        self.realmManager.updateReadbyInAllmsgs(convId: messageInfo.conversationId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.lastReadAt ?? 0)
                        NotificationCenter.default.post(name: NSNotification.updateChatBadgeCount, object: nil, userInfo: nil)
                        let dataNew: [String: Any] = [
                                       "messageId": messageInfo.messageId ?? "",
                                       "conversationId": messageInfo.conversationId ?? "",
                                       "userId": messageInfo.userId ?? "",
                                       "updatedAt": messageInfo.updatedAt ?? 0
                                   ]
                        NotificationCenter.default.post(name: NSNotification.mqttUpdateReadStatus, object: nil, userInfo: dataNew)
                        // Notify UI to refresh messages and conversation list after delivery update
                        NotificationCenter.default.post(name: NSNotification.refrestMessagesListLocally, object: nil)
                        NotificationCenter.default.post(name: NSNotification.refreshConvList, object: nil)
                    }
                    
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        case .mqttUserBlock:
            self.blockedUserAndUnBlockedUser(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserBlock.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserBlock.name, object: nil,userInfo: ["data": "data","error" : error])
                }
            }
        case .mqttUserBlockConversation:
            self.blockedUserAndUnBlocked(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserBlockConversation.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserBlockConversation.name, object: nil,userInfo: ["data": "data","error" : error])
                }
            }
        case .mqttUserUnblock:
            self.blockedUserAndUnBlockedUser(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserUnblock.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserUnblock.name, object: nil,userInfo: ["data": "data","error" : error])
                }
            }
        case .mqttUserUnblockConversation:
            self.blockedUserAndUnBlocked(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserUnblockConversation.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserUnblockConversation.name, object: nil,userInfo: ["data": "data","error" : error])
                }
            }
        case .mqttClearConversation:
            self.blockedUserAndUnBlocked(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttClearConversation.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttClearConversation.name, object: nil,userInfo: ["data": "data","error" : error])
                }
            }
        case .mqttDeleteConversationLocally:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    self.realmManager.deleteConversation(convID: data.conversationId ?? "")
                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttAddAdmin:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttRemoveAdmin:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttAddMember:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttRemoveMember:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttMemberLeave:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttConversationTitleUpdated:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttConversationImageUpdated:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttUpdateUser:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUpdateUser.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUpdateUser.name, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttforward:
            messageReceivedEvent(data: data)
        case .mqttmessageDetailsUpdated:
            messagedDetailUpdated(data: data)
        case .mqttAddReaction:
            reactionAddedToAMessage(data: data)
        case .mqttRemoveReaction:
            reactionRemovedFromMessage(data: data)
        case .mqttChatMessageSent:
            messageReceivedEvent(data: data)
        case .none:
            CallEventHandler.handleCallEvents(payload: message.payload)
            CallEventHandler.delegate = self
        }
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        ISMChatHelper.print("subscribed: \(success), failed: \(failed)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        ISMChatHelper.print("topic: \(topics)")
    }
    
    public func mqttDidPing(_ mqtt: CocoaMQTT) {
        ISMChatHelper.print()
    }
    
    public func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        ISMChatHelper.print()
    }
    
//    public func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
//        ISMChatHelper.print("\(err?.localizedDescription ?? "")")
//        hasConnected = false
//    }
    
    public func TRACE(_ message: String = "", fun: String = #function) {
        let names = fun.components(separatedBy: ":")
        var prettyName: String
        
        if names.count == 2 {
            prettyName = names[0]
        } else {
            prettyName = names[1]
        }
        
        if fun == "mqttDidDisconnect(_:withError:)" {
            prettyName = "didDisconnect"
        }
        
        ISMChatHelper.print("[TRACE] [\(prettyName)]: \(message)")
    }
}


extension ISMChatMQTTManager{
    public func reactionAddedToAMessage(data : Data){
        self.reactions(data) { result in
            switch result{
            case .success(let messageInfo):
                if ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userId != messageInfo.userId{
                    let msg = ISMChatLastMessage(sentAt: messageInfo.sentAt,conversationId: messageInfo.conversationId, body: nil, messageId: messageInfo.messageId, timeStamp: messageInfo.sentAt, action: messageInfo.action,userName: messageInfo.userName ?? "", reactionType: messageInfo.reactionType)
                    
                    self.realmManager.updateLastmsg(conId: messageInfo.conversationId ?? "", msg: msg)
                    self.realmManager.addReactionToMessage(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", reaction: messageInfo.reactionType ?? "", userId: messageInfo.userId ?? "")
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttAddReaction.name, object: nil,userInfo: ["data": data,"error" : ""])
                }
            case .failure(let error):
                ISMChatHelper.print(error)
            }
        }
    }
    
    public func reactionRemovedFromMessage(data : Data){
        self.reactions(data) { result in
            switch result{
            case .success(let messageInfo):
                if ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userId != messageInfo.userId{
                    let msg = ISMChatLastMessage(sentAt: messageInfo.sentAt,conversationId: messageInfo.conversationId, body: nil, messageId: messageInfo.messageId, timeStamp: messageInfo.sentAt, action: messageInfo.action,userName: messageInfo.userName ?? "", reactionType: messageInfo.reactionType)
                    
                    self.realmManager.updateLastmsg(conId: messageInfo.conversationId ?? "", msg: msg)
                    self.realmManager.removeReactionFromMessage(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", reaction: messageInfo.reactionType ?? "", userId: messageInfo.userId ?? "")
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttRemoveReaction.name, object: nil,userInfo: ["data": data,"error" : ""])
                }
            case .failure(let error):
                ISMChatHelper.print(error)
            }
        }
        
    }
    
    public func messagedDetailUpdated(data : Data){
        self.messageUpdated(data) { result in
            switch result{
            case .success(let messageInfo):
                self.realmManager.updateMessageBody(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", body: messageInfo.details?.body ?? "", metaData: messageInfo.details?.metaData ?? ISMChatMetaData(), customType: messageInfo.details?.customType ?? "")
                if let url = messageInfo.details?.metaData?.url{
                    self.realmManager.updateLastMessageOnEdit(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", newBody: url,metaData: messageInfo.details?.metaData ?? ISMChatMetaData())
                }else{
                    self.realmManager.updateLastMessageOnEdit(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", newBody: messageInfo.details?.body ?? "",metaData: messageInfo.details?.metaData ?? ISMChatMetaData())
                }
            case .failure(let error):
                ISMChatHelper.print(error)
            }
        }
    }

    public func messageReceivedEvent(data: Data) {
        self.messageReceived(data) { result in
            switch result {
            case .success(let messageInfo):
                let sdk = ISMChatSdk.getInstance()
                let currentUserId = sdk.getChatClient()?.getConfigurations().userConfig.userId
                
                // Helper: create ISMChatContactMetaData array
                func buildContacts(from metaData: ISMChatMetaData?) -> [ISMChatContactMetaData] {
                    guard let contacts = metaData?.contacts else { return [] }
                    return contacts.map { ISMChatContactMetaData(contactName: $0.contactName, contactIdentifier: $0.contactIdentifier, contactImageUrl: $0.contactImageUrl, contactImageData: $0.contactImageData) }
                }
                
                // Helper: create PaymentRequestedMembers array
                func buildPaymentRequestedMembers(from metaData: ISMChatMetaData?) -> [PaymentRequestedMembers] {
                    guard let members = metaData?.paymentRequestedMembers else { return [] }
                    return members.map { PaymentRequestedMembers(userId: $0.userId, userName: $0.userName, status: $0.status, statusText: $0.statusText, appUserId: $0.appUserId, userProfileImage: $0.userProfileImage, declineReason: $0.declineReason) }
                }
                
                // Helper: create ISMChatMemberAdded array
                func buildMembers(from list: [ISMChatMembers]?) -> [ISMChatMemberAdded] {
                    guard let members = list else { return [] }
                    return members.map { member in
                        var chatMember = ISMChatMemberAdded()
                        chatMember.memberId = member.memberId
                        chatMember.memberIdentifier = member.memberIdentifier
                        chatMember.memberName = member.memberName
                        chatMember.memberProfileImageUrl = member.memberProfileImageUrl
                        return chatMember
                    }
                }
                
                // Helper: create ISMChatMentionedUser array
                func buildMentionedUsers(from mentioned: [ISMChatMentionedUser]?) -> [ISMChatMentionedUser] {
                    guard let mentioned = mentioned else { return [] }
                    return mentioned.map { ISMChatMentionedUser(wordCount: $0.wordCount, userId: $0.userId, order: $0.order) }
                }
                
                // Helper: reply/message/post/product details (avoid repeating)
                func buildReplyMessage(from metaData: ISMChatMetaData?) -> ISMChatReplyMessageMetaData {
                    let reply = metaData?.replyMessage
                    return ISMChatReplyMessageMetaData(
                        parentMessageId: reply?.parentMessageId,
                        parentMessageBody: reply?.parentMessageBody,
                        parentMessageUserId: reply?.parentMessageUserId,
                        parentMessageUserName: reply?.parentMessageUserName,
                        parentMessageMessageType: reply?.parentMessageMessageType,
                        parentMessageAttachmentUrl: reply?.parentMessageAttachmentUrl,
                        parentMessageInitiator: reply?.parentMessageInitiator,
                        parentMessagecaptionMessage: reply?.parentMessagecaptionMessage
                    )
                }
                
                // Helper: metaData construction for edited messages
                func buildMetaData(from metaData: ISMChatMetaData?, with details: ISMChatUpdateMessageDetail?) -> ISMChatMetaData {
                    guard let detailsMeta = details?.metaData else { return metaData ?? ISMChatMetaData() }
                    // Prefer details if present (for updated messages)
                    return detailsMeta
                }
                
                // Helper: ISMChatUser construction
                func buildSenderInfo(from info: ISMChatMessageDelivered) -> ISMChatUser {
                    ISMChatUser(userId: info.senderId, userName: info.senderName, userIdentifier: info.senderIdentifier, userProfileImage: info.senderProfileImageUrl ?? "")
                }
                
                // Helper: ISMChatMessage construction
                func createChatMessage(from info: ISMChatMessageDelivered, body: String?, customType: String?, metaData: ISMChatMetaData, members: [ISMChatMemberAdded], mentionedUsers: [ISMChatMentionedUser]) -> ISMChatMessage {
                    ISMChatMessage(
                        sentAt: info.sentAt,
                        body: body,
                        messageId: info.messageId,
                        mentionedUsers: mentionedUsers,
                        metaData: metaData,
                        metaDataJsonString: info.metaDataJson,
                        customType: customType,
                        action: info.action,
                        attachment: info.attachments,
                        conversationId: info.conversationId,
                        userId: info.userId,
                        userName: info.userName,
                        initiatorId: info.initiatorId,
                        initiatorName: info.initiatorName,
                        memberName: info.memberName,
                        memberId: info.memberId,
                        memberIdentifier: info.memberIdentifier,
                        senderInfo: buildSenderInfo(from: info),
                        members: members,
                        reactions: info.reactions
                    )
                }
                
                // Distinguish between messages from others and self
                let isOwnMessage = messageInfo.senderId == currentUserId
                
                // 1. Prepare members, contacts, mentionedUsers, reply, etc.
                let contacts = buildContacts(from: messageInfo.metaData)
                let paymentRequestedMembers = buildPaymentRequestedMembers(from: messageInfo.metaData)
                let membersArray = buildMembers(from: messageInfo.members)
                let mentionedUserList = buildMentionedUsers(from: messageInfo.mentionedUsers)
                let replyMessageData = buildReplyMessage(from: messageInfo.metaData)
                let postDetail = ISMChatPostMetaData(postId: messageInfo.metaData?.post?.postId, postUrl: messageInfo.metaData?.post?.postUrl)
                let productDetail = ISMChatProductMetaData(
                    productId: messageInfo.metaData?.product?.productId,
                    productUrl: messageInfo.metaData?.product?.productUrl,
                    productCategoryId: messageInfo.metaData?.product?.productCategoryId
                )
                
                // 2. metaData creation
                var metaData = ISMChatMetaData(
                    replyMessage: replyMessageData,
                    locationAddress: messageInfo.metaData?.locationAddress,
                    contacts: contacts,
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
                    collectionId: messageInfo.metaData?.collectionId,
                    paymentRequestId: messageInfo.metaData?.paymentRequestId,
                    orderId: messageInfo.metaData?.orderId,
                    paymentRequestedMembers: paymentRequestedMembers,
                    requestAPaymentExpiryTime: messageInfo.metaData?.requestAPaymentExpiryTime,
                    currencyCode: messageInfo.metaData?.currencyCode,
                    amount: messageInfo.metaData?.amount,
                    inviteTitle: messageInfo.metaData?.inviteTitle,
                    inviteTimestamp: messageInfo.metaData?.inviteTimestamp,
                    inviteRescheduledTimestamp: messageInfo.metaData?.inviteRescheduledTimestamp,
                    inviteLocation: messageInfo.metaData?.inviteLocation,
                    inviteMembers: messageInfo.metaData?.inviteMembers,
                    groupCastId: messageInfo.metaData?.groupCastId,
                    status: messageInfo.metaData?.status
                )
                
                // If message is edited, override metaData, body, customType
                var bodyUpdated = messageInfo.body
                var customType = messageInfo.customType
                if messageInfo.action == ISMChatActionType.messageDetailsUpdated.value {
                    bodyUpdated = messageInfo.details?.body
                    customType = messageInfo.details?.customType
                    metaData = buildMetaData(from: messageInfo.metaData, with: messageInfo.details)
                }
                
                // 3. Save message and last message
                let chatMessage = createChatMessage(from: messageInfo, body: bodyUpdated, customType: customType, metaData: metaData, members: membersArray, mentionedUsers: mentionedUserList)
                if !isOwnMessage{
                    DispatchQueue.main.async {
                        self.realmManager.saveMessage(obj: [chatMessage])
                        let lastMessage = ISMChatLastMessage(
                            sentAt: messageInfo.sentAt,
                            senderName: messageInfo.senderName,
                            senderIdentifier: messageInfo.senderIdentifier,
                            senderId: messageInfo.senderId,
                            conversationId: messageInfo.conversationId,
                            body: bodyUpdated,
                            messageId: messageInfo.messageId,
                            customType: customType,
                            action: messageInfo.action,
                            userId: messageInfo.userId,
                            initiatorId: messageInfo.initiatorId, memberName: messageInfo.memberName, initiatorName: messageInfo.initiatorName, memberId: messageInfo.memberId, userName: messageInfo.userName,
                            members: membersArray, userIdentifier: messageInfo.userIdentifier,
                            userProfileImageUrl: messageInfo.userProfileImageUrl
                        )
                        self.realmManager.updateLastmsg(conId: messageInfo.conversationId ?? "", msg: lastMessage)
                    }
                    
                    
                    // 4. Update unread counts and message delivery
                    let viewModel = ChatsViewModel()
                    if let conId = messageInfo.conversationId, let msgId = messageInfo.messageId {
                        viewModel.deliveredMessageIndicator(conversationId: conId, messageId: msgId) { _ in
                            ISMChatHelper.print("Message marked delivered")
                        }
                    }
                    
                    if messageInfo.action == ISMChatActionType.conversationCreated.value {
                        self.realmManager.updateUnreadCountThroughConId(conId: messageInfo.conversationId ?? "", count: 0)
                    } else {
                        self.realmManager.updateUnreadCountThroughConId(conId: messageInfo.conversationId ?? "", count: 1)
                    }
                    
                    // 5. Local notification if in background and not own message
                    if UIApplication.shared.applicationState == .background,
                       messageInfo.senderId != currentUserId {
                        UserDefaults.standard.setValue("app is in background and i got mqtt event", forKey: "Chatsdk_1")
                        DispatchQueue.global(qos: .background).async {
                            self.whenInOtherScreen(messageInfo: messageInfo)
                        }
                    } else if let topViewController = UIApplication.topViewController(),
                              let chatVC = self.viewcontrollers?.conversationListViewController,
                              let messageVC = self.viewcontrollers?.messagesListViewController {
                        // If not on chat or message screen, show notification if not own message
                        let isNotChatVC = !(topViewController.isKind(of: chatVC))
                        let isNotMessageVC = !(topViewController.isKind(of: messageVC))
                        if isNotChatVC && isNotMessageVC && messageInfo.senderId != currentUserId {
                            self.whenInOtherScreen(messageInfo: messageInfo)
                        }
                    }
                    
                    // 6. Post notifications
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil, userInfo: ["data": messageInfo, "error": ""])
                        NotificationCenter.default.post(name: NSNotification.updateChatBadgeCount, object: nil, userInfo: nil)
                    }
                }
                
            case .failure(let error):
                NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil, userInfo: ["data": "", "error": error])
            }
        }
    }
    
//    public func messageReceivedEvent(data : Data){
//        self.messageReceived(data) { result in
//            switch result{
//            case .success(let messageInfo):
//                
//                if ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userId != messageInfo.senderId{
//                    // added last message in realm
//                    let membersArray = messageInfo.members?.map { member -> ISMChatMemberAdded in
//                        var chatMember = ISMChatMemberAdded()
//                        chatMember.memberId = member.memberId
//                        chatMember.memberIdentifier = member.memberIdentifier
//                        chatMember.memberName = member.memberName
//                        chatMember.memberProfileImageUrl = member.memberProfileImageUrl
//                        return chatMember
//                    } ?? []
//                    
//                    let msg = ISMChatLastMessage(sentAt: messageInfo.sentAt,senderName: messageInfo.senderName,senderIdentifier: messageInfo.senderIdentifier,senderId: messageInfo.senderId,conversationId: messageInfo.conversationId,body: messageInfo.body ?? "",messageId: messageInfo.messageId,deliveredToUser: messageInfo.userId,timeStamp: messageInfo.sentAt,customType: messageInfo.customType,action: messageInfo.action, userId: messageInfo.userId, initiatorId: messageInfo.initiatorId, memberName: messageInfo.memberName, initiatorName: messageInfo.initiatorName, memberId: messageInfo.memberId, userName: messageInfo.userName,members: membersArray,userIdentifier: messageInfo.userIdentifier,userProfileImageUrl: messageInfo.userProfileImageUrl)
//                    
//                    
//                    DispatchQueue.main.async {
//                        self.realmManager.updateLastmsg(conId: messageInfo.conversationId ?? "", msg: msg)
//                    }
//                    
//                    
//                    
//                    // added message in messagesdb
//                    var contact : [ISMChatContactMetaData] = []
//                    if let contacts = messageInfo.metaData?.contacts, contacts.count > 0{
//                        for x in contacts{
//                            var data = ISMChatContactMetaData()
//                            data.contactIdentifier = x.contactIdentifier
//                            data.contactImageData = x.contactImageData
//                            data.contactImageUrl = x.contactImageUrl
//                            data.contactName = x.contactName
//                            contact.append(data)
//                        }
//                    }
//                    
//                    let replyMessageData = ISMChatReplyMessageMetaData(
//                        parentMessageId: messageInfo.parentMessageId,
//                        parentMessageBody: messageInfo.metaData?.replyMessage?.parentMessageBody,
//                        parentMessageUserId: messageInfo.metaData?.replyMessage?.parentMessageUserId,
//                        parentMessageUserName: messageInfo.metaData?.replyMessage?.parentMessageUserName,
//                        parentMessageMessageType: messageInfo.metaData?.replyMessage?.parentMessageMessageType,
//                        parentMessageAttachmentUrl: messageInfo.metaData?.replyMessage?.parentMessageAttachmentUrl,
//                        parentMessageInitiator: messageInfo.metaData?.replyMessage?.parentMessageInitiator,
//                        parentMessagecaptionMessage: messageInfo.metaData?.replyMessage?.parentMessagecaptionMessage)
//                    
//                    let postDetail = ISMChatPostMetaData(postId: messageInfo.metaData?.post?.postId, postUrl: messageInfo.metaData?.post?.postUrl)
//                    let productDetail = ISMChatProductMetaData(productId: messageInfo.metaData?.product?.productId, productUrl: messageInfo.metaData?.product?.productUrl, productCategoryId: messageInfo.metaData?.product?.productCategoryId)
//                    
//                    
//                    // added message in messagesdb
//                    var paymentRequestedMembers : [PaymentRequestedMembers] = []
//                    if let members = messageInfo.metaData?.paymentRequestedMembers, members.count > 0{
//                        for x in members{
//                            var data = PaymentRequestedMembers()
//                            data.userId = x.userId
//                            data.userName = x.userName
//                            data.status = x.status
//                            data.statusText = x.statusText
//                            data.appUserId = x.appUserId
//                            paymentRequestedMembers.append(data)
//                        }
//                    }
//                    
//                    let senderInfo = ISMChatUser(userId: messageInfo.senderId, userName: messageInfo.senderName, userIdentifier: messageInfo.senderIdentifier, userProfileImage: "")
//                    
//                    var bodyUpdated = messageInfo.body
//                    var customType = messageInfo.customType
//                    var metaData = ISMChatMetaData(
//                        replyMessage: replyMessageData,
//                        locationAddress: messageInfo.metaData?.locationAddress,
//                        contacts: contact,
//                        captionMessage: messageInfo.metaData?.captionMessage,
//                        isBroadCastMessage: messageInfo.metaData?.isBroadCastMessage,
//                        post: postDetail,
//                        product: productDetail,
//                        storeName: messageInfo.metaData?.storeName,
//                        productName: messageInfo.metaData?.productName,
//                        bestPrice: messageInfo.metaData?.bestPrice,
//                        scratchPrice: messageInfo.metaData?.scratchPrice,
//                        url: messageInfo.metaData?.url,
//                        parentProductId: messageInfo.metaData?.parentProductId,
//                        childProductId: messageInfo.metaData?.childProductId,
//                        entityType: messageInfo.metaData?.entityType,
//                        productImage: messageInfo.metaData?.productImage,
//                        thumbnailUrl: messageInfo.metaData?.thumbnailUrl,
//                        description: messageInfo.metaData?.description,
//                        isVideoPost: messageInfo.metaData?.isVideoPost,
//                        socialPostId: messageInfo.metaData?.socialPostId,
//                        collectionTitle : messageInfo.metaData?.collectionTitle,
//                        collectionDescription : messageInfo.metaData?.collectionDescription,
//                        productCount : messageInfo.metaData?.productCount,
//                        collectionImage : messageInfo.metaData?.collectionImage,
//                        collectionId : messageInfo.metaData?.collectionId,
//                        paymentRequestId : messageInfo.metaData?.paymentRequestId,
//                        orderId : messageInfo.metaData?.orderId,
//                        paymentRequestedMembers: paymentRequestedMembers,
//                        requestAPaymentExpiryTime : messageInfo.metaData?.requestAPaymentExpiryTime,
//                        currencyCode : messageInfo.metaData?.currencyCode,
//                        amount : messageInfo.metaData?.amount,
//                        inviteTitle: messageInfo.metaData?.inviteTitle,
//                        inviteTimestamp: messageInfo.metaData?.inviteTimestamp,
//                        inviteRescheduledTimestamp: messageInfo.metaData?.inviteRescheduledTimestamp,
//                        inviteLocation: messageInfo.metaData?.inviteLocation,
//                        inviteMembers: messageInfo.metaData?.inviteMembers,
//                        groupCastId: messageInfo.metaData?.groupCastId,
//                        status: messageInfo.metaData?.status
//                    )
//                    
//                    if messageInfo.action == ISMChatActionType.messageDetailsUpdated.value ?? ""{
//                        bodyUpdated = messageInfo.details?.body
//                        customType = messageInfo.details?.customType
//                        
//                        var paymentRequestedMembersDetails : [PaymentRequestedMembers] = []
//                        if let members = messageInfo.details?.metaData?.paymentRequestedMembers, members.count > 0{
//                            for x in members{
//                                var data = PaymentRequestedMembers()
//                                data.userId = x.userId
//                                data.userName = x.userName
//                                data.status = x.status
//                                data.statusText = x.statusText
//                                data.appUserId = x.appUserId
//                                paymentRequestedMembersDetails.append(data)
//                            }
//                        }
//                        
//                        metaData = ISMChatMetaData(
//                            storeName: messageInfo.details?.metaData?.storeName,
//                            productName: messageInfo.details?.metaData?.productName,
//                            bestPrice: messageInfo.details?.metaData?.bestPrice,
//                            scratchPrice: messageInfo.details?.metaData?.scratchPrice,
//                            url: messageInfo.details?.metaData?.url,
//                            parentProductId: messageInfo.details?.metaData?.parentProductId,
//                            childProductId: messageInfo.details?.metaData?.childProductId,
//                            entityType: messageInfo.details?.metaData?.entityType,
//                            productImage: messageInfo.details?.metaData?.productImage,
//                            thumbnailUrl: messageInfo.details?.metaData?.thumbnailUrl,
//                            description: messageInfo.details?.metaData?.description,
//                            isVideoPost: messageInfo.details?.metaData?.isVideoPost,
//                            socialPostId: messageInfo.details?.metaData?.socialPostId,
//                            collectionTitle : messageInfo.details?.metaData?.collectionTitle,
//                            collectionDescription : messageInfo.details?.metaData?.collectionDescription,
//                            productCount : messageInfo.details?.metaData?.productCount,
//                            collectionImage : messageInfo.details?.metaData?.collectionImage,
//                            collectionId : messageInfo.details?.metaData?.collectionId,
//                            paymentRequestId : messageInfo.details?.metaData?.paymentRequestId,
//                            orderId : messageInfo.details?.metaData?.orderId,
//                            paymentRequestedMembers : paymentRequestedMembersDetails,
//                            requestAPaymentExpiryTime : messageInfo.details?.metaData?.requestAPaymentExpiryTime,
//                            currencyCode : messageInfo.details?.metaData?.currencyCode,
//                            amount : messageInfo.details?.metaData?.amount,
//                            inviteTitle: messageInfo.metaData?.inviteTitle,
//                            inviteTimestamp: messageInfo.metaData?.inviteTimestamp,
//                            inviteRescheduledTimestamp: messageInfo.metaData?.inviteRescheduledTimestamp,
//                            inviteLocation: messageInfo.metaData?.inviteLocation,
//                            inviteMembers: messageInfo.metaData?.inviteMembers,
//                            groupCastId: messageInfo.metaData?.groupCastId,
//                            status: messageInfo.metaData?.status
//                        )
//                        
//                    }
//                    
//                    var mentionedUser: [ISMChatMentionedUser] = []
//                    if let mentionedUsers = messageInfo.mentionedUsers {
//                        for x in mentionedUsers {
//                            let user = ISMChatMentionedUser(wordCount: x.wordCount, userId: x.userId, order: x.order)
//                            mentionedUser.append(user)
//                        }
//                    }
//                    
//                    let message = ISMChatMessage(sentAt: messageInfo.sentAt,body: bodyUpdated, messageId: messageInfo.messageId,mentionedUsers: mentionedUser,metaData : metaData,metaDataJsonString: messageInfo.metaDataJson, customType: customType,action: messageInfo.action, attachment: messageInfo.attachments,conversationId: messageInfo.conversationId, userId: messageInfo.userId, userName: messageInfo.userName, initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName, memberName: messageInfo.memberName, memberId: messageInfo.memberId, memberIdentifier: messageInfo.memberIdentifier,senderInfo: senderInfo,members: membersArray,reactions: messageInfo.reactions)
//                    
//                    DispatchQueue.main.async {
//                        self.realmManager.saveMessage(obj: [message])
//                    }
//                    
//                    let viewModel = ChatsViewModel()
//                    if let converId = messageInfo.conversationId, let messId = messageInfo.messageId{
//                        viewModel.deliveredMessageIndicator(conversationId: converId, messageId: messId) { _ in
//                            ISMChatHelper.print("Message marked delivered")
//                        }
//                    }
//                    
//                    //add unread count
//                    if messageInfo.action == ISMChatActionType.conversationCreated.value{
//                        self.realmManager.updateUnreadCountThroughConId(conId: messageInfo.conversationId ?? "", count: 0)
//                    }else{
//                        self.realmManager.updateUnreadCountThroughConId(conId: messageInfo.conversationId ?? "", count: 1)
//                    }
//                }else{
//                    // there are lots of messages send by logged in user from app or backend we need to save those too in realm
//                    //this is when you share social link, productlink and collectionlink from app, and then when u go to chat this will scroll to last message --> only saving my own message here for custom type, productLink,sociallink,collectionlink
//                    if (messageInfo.customType == ISMChatMediaType.ProductLink.value || messageInfo.customType == ISMChatMediaType.SocialLink.value || messageInfo.customType == ISMChatMediaType.CollectionLink.value) && messageInfo.metaData?.isSharedFromApp == true{
//                        var contact : [ISMChatContactMetaData] = []
//                        if let contacts = messageInfo.metaData?.contacts, contacts.count > 0{
//                            for x in contacts{
//                                var data = ISMChatContactMetaData()
//                                data.contactIdentifier = x.contactIdentifier
//                                data.contactImageData = x.contactImageData
//                                data.contactImageUrl = x.contactImageUrl
//                                data.contactName = x.contactName
//                                contact.append(data)
//                            }
//                        }
//                        
//                        let replyMessageData = ISMChatReplyMessageMetaData(
//                            parentMessageId: messageInfo.parentMessageId,
//                            parentMessageBody: messageInfo.metaData?.replyMessage?.parentMessageBody,
//                            parentMessageUserId: messageInfo.metaData?.replyMessage?.parentMessageUserId,
//                            parentMessageUserName: messageInfo.metaData?.replyMessage?.parentMessageUserName,
//                            parentMessageMessageType: messageInfo.metaData?.replyMessage?.parentMessageMessageType,
//                            parentMessageAttachmentUrl: messageInfo.metaData?.replyMessage?.parentMessageAttachmentUrl,
//                            parentMessageInitiator: messageInfo.metaData?.replyMessage?.parentMessageInitiator,
//                            parentMessagecaptionMessage: messageInfo.metaData?.replyMessage?.parentMessagecaptionMessage)
//                        
//                        let postDetail = ISMChatPostMetaData(postId: messageInfo.metaData?.post?.postId, postUrl: messageInfo.metaData?.post?.postUrl)
//                        let productDetail = ISMChatProductMetaData(productId: messageInfo.metaData?.product?.productId, productUrl: messageInfo.metaData?.product?.productUrl, productCategoryId: messageInfo.metaData?.product?.productCategoryId)
//                        
//                        
//                        
//                        
//                        let senderInfo = ISMChatUser(userId: messageInfo.senderId, userName: messageInfo.senderName, userIdentifier: messageInfo.senderIdentifier, userProfileImage: "")
//                        
//                        //add members in Message
//                        var membersArray : [ISMChatMemberAdded] = []
//                        if let members = messageInfo.members{
//                            for x in members{
//                                var member = ISMChatMemberAdded()
//                                member.memberId = x.memberId
//                                member.memberIdentifier = x.memberIdentifier
//                                member.memberName = x.memberName
//                                member.memberProfileImageUrl = x.memberProfileImageUrl
//                                membersArray.append(member)
//                            }
//                        }
//                        
//                        // added message in messagesdb
//                        var paymentRequestedMembers : [PaymentRequestedMembers] = []
//                        if let members = messageInfo.metaData?.paymentRequestedMembers, members.count > 0{
//                            for x in members{
//                                var data = PaymentRequestedMembers()
//                                data.userId = x.userId
//                                data.userName = x.userName
//                                data.status = x.status
//                                data.statusText = x.statusText
//                                data.appUserId = x.appUserId
//                                paymentRequestedMembers.append(data)
//                            }
//                        }
//                        
//                        var bodyUpdated = messageInfo.body
//                        var customType = messageInfo.customType
//                        var metaData = ISMChatMetaData(
//                            replyMessage: replyMessageData,
//                            locationAddress: messageInfo.metaData?.locationAddress,
//                            contacts: contact,
//                            captionMessage: messageInfo.metaData?.captionMessage,
//                            isBroadCastMessage: messageInfo.metaData?.isBroadCastMessage,
//                            post: postDetail,
//                            product: productDetail,
//                            storeName: messageInfo.metaData?.storeName,
//                            productName: messageInfo.metaData?.productName,
//                            bestPrice: messageInfo.metaData?.bestPrice,
//                            scratchPrice: messageInfo.metaData?.scratchPrice,
//                            url: messageInfo.metaData?.url,
//                            parentProductId: messageInfo.metaData?.parentProductId,
//                            childProductId: messageInfo.metaData?.childProductId,
//                            entityType: messageInfo.metaData?.entityType,
//                            productImage: messageInfo.metaData?.productImage,
//                            thumbnailUrl: messageInfo.metaData?.thumbnailUrl,
//                            description: messageInfo.metaData?.description,
//                            isVideoPost: messageInfo.metaData?.isVideoPost,
//                            socialPostId: messageInfo.metaData?.socialPostId,
//                            collectionTitle : messageInfo.metaData?.collectionTitle,
//                            collectionDescription : messageInfo.metaData?.collectionDescription,
//                            productCount : messageInfo.metaData?.productCount,
//                            collectionImage : messageInfo.metaData?.collectionImage,
//                            collectionId : messageInfo.metaData?.collectionId,
//                            paymentRequestId : messageInfo.metaData?.paymentRequestId,
//                            orderId : messageInfo.metaData?.orderId,
//                            paymentRequestedMembers: paymentRequestedMembers,
//                            requestAPaymentExpiryTime : messageInfo.metaData?.requestAPaymentExpiryTime,
//                            currencyCode : messageInfo.metaData?.currencyCode,
//                            amount : messageInfo.metaData?.amount,
//                            inviteTitle: messageInfo.metaData?.inviteTitle,
//                            inviteTimestamp: messageInfo.metaData?.inviteTimestamp,
//                            inviteRescheduledTimestamp: messageInfo.metaData?.inviteRescheduledTimestamp,
//                            inviteLocation: messageInfo.metaData?.inviteLocation,
//                            inviteMembers: messageInfo.metaData?.inviteMembers,
//                            groupCastId: messageInfo.metaData?.groupCastId,
//                            status: messageInfo.metaData?.status
//                        )
//                        
//                        if messageInfo.action == ISMChatActionType.messageDetailsUpdated.value ?? ""{
//                            bodyUpdated = messageInfo.details?.body
//                            customType = messageInfo.details?.customType
//                            
//                            var paymentRequestedMembersDetails : [PaymentRequestedMembers] = []
//                            if let members = messageInfo.details?.metaData?.paymentRequestedMembers, members.count > 0{
//                                for x in members{
//                                    var data = PaymentRequestedMembers()
//                                    data.userId = x.userId
//                                    data.userName = x.userName
//                                    data.status = x.status
//                                    data.statusText = x.statusText
//                                    data.appUserId = x.appUserId
//                                    paymentRequestedMembersDetails.append(data)
//                                }
//                            }
//                            
//                            metaData = ISMChatMetaData(
//                                storeName: messageInfo.details?.metaData?.storeName,
//                                productName: messageInfo.details?.metaData?.productName,
//                                bestPrice: messageInfo.details?.metaData?.bestPrice,
//                                scratchPrice: messageInfo.details?.metaData?.scratchPrice,
//                                url: messageInfo.details?.metaData?.url,
//                                parentProductId: messageInfo.details?.metaData?.parentProductId,
//                                childProductId: messageInfo.details?.metaData?.childProductId,
//                                entityType: messageInfo.details?.metaData?.entityType,
//                                productImage: messageInfo.details?.metaData?.productImage,
//                                thumbnailUrl: messageInfo.details?.metaData?.thumbnailUrl,
//                                description: messageInfo.details?.metaData?.description,
//                                isVideoPost: messageInfo.details?.metaData?.isVideoPost,
//                                socialPostId: messageInfo.details?.metaData?.socialPostId,
//                                collectionTitle : messageInfo.details?.metaData?.collectionTitle,
//                                collectionDescription : messageInfo.details?.metaData?.collectionDescription,
//                                productCount : messageInfo.details?.metaData?.productCount,
//                                collectionImage : messageInfo.details?.metaData?.collectionImage,
//                                collectionId : messageInfo.details?.metaData?.collectionId,
//                                paymentRequestId : messageInfo.details?.metaData?.paymentRequestId,
//                                orderId : messageInfo.details?.metaData?.orderId,
//                                paymentRequestedMembers : paymentRequestedMembersDetails,
//                                requestAPaymentExpiryTime : messageInfo.details?.metaData?.requestAPaymentExpiryTime,
//                                currencyCode : messageInfo.details?.metaData?.currencyCode,
//                                amount : messageInfo.details?.metaData?.amount,
//                                inviteTitle: messageInfo.metaData?.inviteTitle,
//                                inviteTimestamp: messageInfo.metaData?.inviteTimestamp,
//                                inviteRescheduledTimestamp: messageInfo.metaData?.inviteRescheduledTimestamp,
//                                inviteLocation: messageInfo.metaData?.inviteLocation,
//                                inviteMembers: messageInfo.metaData?.inviteMembers,
//                                groupCastId: messageInfo.metaData?.groupCastId,
//                                status: messageInfo.metaData?.status
//                            )
//                        }
//                        
//                        var mentionedUser : [ISMChatMentionedUser] = []
//                        if messageInfo.mentionedUsers != nil{
//                            for x in mentionedUser{
//                                let user = ISMChatMentionedUser(wordCount: x.wordCount, userId: x.userId, order: x.order)
//                                mentionedUser.append(user)
//                            }
//                        }
//                        
//                        let message = ISMChatMessage(sentAt: messageInfo.sentAt,body: bodyUpdated, messageId: messageInfo.messageId,mentionedUsers: mentionedUser,metaData : metaData,metaDataJsonString: messageInfo.metaDataJson, customType: customType,action: messageInfo.action, attachment: messageInfo.attachments,conversationId: messageInfo.conversationId, userId: messageInfo.userId, userName: messageInfo.userName, initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName, memberName: messageInfo.memberName, memberId: messageInfo.memberId, memberIdentifier: messageInfo.memberIdentifier,senderInfo: senderInfo,members: membersArray,reactions: messageInfo.reactions)
//                        
//                        DispatchQueue.main.async {
//                            self.realmManager.saveMessage(obj: [message])
//                        }
//                    }else if messageInfo.metaData?.isSharedFromApp == true{
//                        // there are lots of messages send by logged in user from backend we need to save those too in realm
//                        var contact : [ISMChatContactMetaData] = []
//                        if let contacts = messageInfo.metaData?.contacts, contacts.count > 0{
//                            for x in contacts{
//                                var data = ISMChatContactMetaData()
//                                data.contactIdentifier = x.contactIdentifier
//                                data.contactImageData = x.contactImageData
//                                data.contactImageUrl = x.contactImageUrl
//                                data.contactName = x.contactName
//                                contact.append(data)
//                            }
//                        }
//                        
//                        let replyMessageData = ISMChatReplyMessageMetaData(
//                            parentMessageId: messageInfo.parentMessageId,
//                            parentMessageBody: messageInfo.metaData?.replyMessage?.parentMessageBody,
//                            parentMessageUserId: messageInfo.metaData?.replyMessage?.parentMessageUserId,
//                            parentMessageUserName: messageInfo.metaData?.replyMessage?.parentMessageUserName,
//                            parentMessageMessageType: messageInfo.metaData?.replyMessage?.parentMessageMessageType,
//                            parentMessageAttachmentUrl: messageInfo.metaData?.replyMessage?.parentMessageAttachmentUrl,
//                            parentMessageInitiator: messageInfo.metaData?.replyMessage?.parentMessageInitiator,
//                            parentMessagecaptionMessage: messageInfo.metaData?.replyMessage?.parentMessagecaptionMessage)
//                        
//                        let postDetail = ISMChatPostMetaData(postId: messageInfo.metaData?.post?.postId, postUrl: messageInfo.metaData?.post?.postUrl)
//                        let productDetail = ISMChatProductMetaData(productId: messageInfo.metaData?.product?.productId, productUrl: messageInfo.metaData?.product?.productUrl, productCategoryId: messageInfo.metaData?.product?.productCategoryId)
//                        
//                        
//                        
//                        
//                        let senderInfo = ISMChatUser(userId: messageInfo.senderId, userName: messageInfo.senderName, userIdentifier: messageInfo.senderIdentifier, userProfileImage: "")
//                        
//                        //add members in Message
//                        var membersArray : [ISMChatMemberAdded] = []
//                        if let members = messageInfo.members{
//                            for x in members{
//                                var member = ISMChatMemberAdded()
//                                member.memberId = x.memberId
//                                member.memberIdentifier = x.memberIdentifier
//                                member.memberName = x.memberName
//                                member.memberProfileImageUrl = x.memberProfileImageUrl
//                                membersArray.append(member)
//                            }
//                        }
//                        
//                        // added message in messagesdb
//                        var paymentRequestedMembers : [PaymentRequestedMembers] = []
//                        if let members = messageInfo.metaData?.paymentRequestedMembers, members.count > 0{
//                            for x in members{
//                                var data = PaymentRequestedMembers()
//                                data.userId = x.userId
//                                data.userName = x.userName
//                                data.status = x.status
//                                data.statusText = x.statusText
//                                data.appUserId = x.appUserId
//                                paymentRequestedMembers.append(data)
//                            }
//                        }
//                        
//                        var bodyUpdated = messageInfo.body
//                        var customType = messageInfo.customType
//                        var metaData = ISMChatMetaData(
//                            replyMessage: replyMessageData,
//                            locationAddress: messageInfo.metaData?.locationAddress,
//                            contacts: contact,
//                            captionMessage: messageInfo.metaData?.captionMessage,
//                            isBroadCastMessage: messageInfo.metaData?.isBroadCastMessage,
//                            post: postDetail,
//                            product: productDetail,
//                            storeName: messageInfo.metaData?.storeName,
//                            productName: messageInfo.metaData?.productName,
//                            bestPrice: messageInfo.metaData?.bestPrice,
//                            scratchPrice: messageInfo.metaData?.scratchPrice,
//                            url: messageInfo.metaData?.url,
//                            parentProductId: messageInfo.metaData?.parentProductId,
//                            childProductId: messageInfo.metaData?.childProductId,
//                            entityType: messageInfo.metaData?.entityType,
//                            productImage: messageInfo.metaData?.productImage,
//                            thumbnailUrl: messageInfo.metaData?.thumbnailUrl,
//                            description: messageInfo.metaData?.description,
//                            isVideoPost: messageInfo.metaData?.isVideoPost,
//                            socialPostId: messageInfo.metaData?.socialPostId,
//                            collectionTitle : messageInfo.metaData?.collectionTitle,
//                            collectionDescription : messageInfo.metaData?.collectionDescription,
//                            productCount : messageInfo.metaData?.productCount,
//                            collectionImage : messageInfo.metaData?.collectionImage,
//                            collectionId : messageInfo.metaData?.collectionId,
//                            paymentRequestId : messageInfo.metaData?.paymentRequestId,
//                            orderId : messageInfo.metaData?.orderId,
//                            paymentRequestedMembers: paymentRequestedMembers,
//                            requestAPaymentExpiryTime : messageInfo.metaData?.requestAPaymentExpiryTime,
//                            currencyCode : messageInfo.metaData?.currencyCode,
//                            amount : messageInfo.metaData?.amount,
//                            inviteTitle: messageInfo.metaData?.inviteTitle,
//                            inviteTimestamp: messageInfo.metaData?.inviteTimestamp,
//                            inviteRescheduledTimestamp: messageInfo.metaData?.inviteRescheduledTimestamp,
//                            inviteLocation: messageInfo.metaData?.inviteLocation,
//                            inviteMembers: messageInfo.metaData?.inviteMembers,
//                            groupCastId: messageInfo.metaData?.groupCastId,
//                            status: messageInfo.metaData?.status
//                        )
//                        
//                        if messageInfo.action == ISMChatActionType.messageDetailsUpdated.value ?? ""{
//                            bodyUpdated = messageInfo.details?.body
//                            customType = messageInfo.details?.customType
//                            
//                            var paymentRequestedMembersDetails : [PaymentRequestedMembers] = []
//                            if let members = messageInfo.details?.metaData?.paymentRequestedMembers, members.count > 0{
//                                for x in members{
//                                    var data = PaymentRequestedMembers()
//                                    data.userId = x.userId
//                                    data.userName = x.userName
//                                    data.status = x.status
//                                    data.statusText = x.statusText
//                                    data.appUserId = x.appUserId
//                                    paymentRequestedMembersDetails.append(data)
//                                }
//                            }
//                            
//                            metaData = ISMChatMetaData(
//                                storeName: messageInfo.details?.metaData?.storeName,
//                                productName: messageInfo.details?.metaData?.productName,
//                                bestPrice: messageInfo.details?.metaData?.bestPrice,
//                                scratchPrice: messageInfo.details?.metaData?.scratchPrice,
//                                url: messageInfo.details?.metaData?.url,
//                                parentProductId: messageInfo.details?.metaData?.parentProductId,
//                                childProductId: messageInfo.details?.metaData?.childProductId,
//                                entityType: messageInfo.details?.metaData?.entityType,
//                                productImage: messageInfo.details?.metaData?.productImage,
//                                thumbnailUrl: messageInfo.details?.metaData?.thumbnailUrl,
//                                description: messageInfo.details?.metaData?.description,
//                                isVideoPost: messageInfo.details?.metaData?.isVideoPost,
//                                socialPostId: messageInfo.details?.metaData?.socialPostId,
//                                collectionTitle : messageInfo.details?.metaData?.collectionTitle,
//                                collectionDescription : messageInfo.details?.metaData?.collectionDescription,
//                                productCount : messageInfo.details?.metaData?.productCount,
//                                collectionImage : messageInfo.details?.metaData?.collectionImage,
//                                collectionId : messageInfo.details?.metaData?.collectionId,
//                                paymentRequestId : messageInfo.details?.metaData?.paymentRequestId,
//                                orderId : messageInfo.details?.metaData?.orderId,
//                                paymentRequestedMembers : paymentRequestedMembersDetails,
//                                requestAPaymentExpiryTime : messageInfo.details?.metaData?.requestAPaymentExpiryTime,
//                                currencyCode : messageInfo.details?.metaData?.currencyCode,
//                                amount : messageInfo.details?.metaData?.amount,
//                                inviteTitle: messageInfo.metaData?.inviteTitle,
//                                inviteTimestamp: messageInfo.metaData?.inviteTimestamp,
//                                inviteRescheduledTimestamp: messageInfo.metaData?.inviteRescheduledTimestamp,
//                                inviteLocation: messageInfo.metaData?.inviteLocation,
//                                inviteMembers: messageInfo.metaData?.inviteMembers,
//                                groupCastId: messageInfo.metaData?.groupCastId,
//                                status: messageInfo.metaData?.status
//                            )
//                        }
//                        
//                        
//                        var mentionedUser : [ISMChatMentionedUser] = []
//                        if messageInfo.mentionedUsers != nil{
//                            for x in mentionedUser{
//                                let user = ISMChatMentionedUser(wordCount: x.wordCount, userId: x.userId, order: x.order)
//                                mentionedUser.append(user)
//                            }
//                        }
//                        
//                        let message = ISMChatMessage(sentAt: messageInfo.sentAt,body: bodyUpdated, messageId: messageInfo.messageId,mentionedUsers: mentionedUser,metaData : metaData,metaDataJsonString: messageInfo.metaDataJson, customType: customType,action: messageInfo.action, attachment: messageInfo.attachments,conversationId: messageInfo.conversationId, userId: messageInfo.userId, userName: messageInfo.userName, initiatorId: messageInfo.initiatorId, initiatorName: messageInfo.initiatorName, memberName: messageInfo.memberName, memberId: messageInfo.memberId, memberIdentifier: messageInfo.memberIdentifier,senderInfo: senderInfo,members: membersArray,reactions: messageInfo.reactions)
//                        
//                        DispatchQueue.main.async {
//                            self.realmManager.saveMessage(obj: [message])
//                        }
//                    }
//                }
//            
//                
////                if self.framework == .UIKit {
//                    if UIApplication.shared.applicationState == .background {
//                        UserDefaults.standard.setValue("app is in background and i got mqtt event", forKey: "Chatsdk_1")
//                        DispatchQueue.global(qos: .background).async {
//                            if messageInfo.senderId != ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userId {
//                                self.whenInOtherScreen(messageInfo: messageInfo)
//                            }
//                        }
//                    }else{
//                        if let topViewController = UIApplication.topViewController() {
//                            if let Chatvc = self.viewcontrollers?.conversationListViewController,
//                               let Messagevc = self.viewcontrollers?.messagesListViewController {
//                                
//                                let isNotChatVC = !(topViewController.isKind(of: Chatvc))
//                                let isNotMessageVC = !(topViewController.isKind(of: Messagevc))
//                                
//                                if isNotChatVC && isNotMessageVC {
//                                    // Your code here
//                                    if messageInfo.senderId != ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userId{
//                                        self.whenInOtherScreen(messageInfo: messageInfo)
//                                    }
//                                }
//                            }
//                        }
//                    }
////                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": messageInfo,"error" : ""])
//                    NotificationCenter.default.post(name: NSNotification.updateChatBadgeCount, object: nil, userInfo: nil)
//                }
//            case .failure(let error):
//                NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
//            }
//        }
//    }
    
    public func whenInOtherScreen(messageInfo : ISMChatMessageDelivered){
        if ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userId != messageInfo.senderId{
            let viewModel = ChatsViewModel()
            if let converId = messageInfo.conversationId, let messId = messageInfo.messageId{
                if messageInfo.action != ISMChatActionType.conversationCreated.value{
                    UserDefaults.standard.setValue("triggered local notification in background", forKey: "Chatsdk_2")
                    ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.senderName ?? "")", body: "\(messageInfo.notificationBody ?? (messageInfo.body ?? ""))", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? "","senderProfileImageUrl" : messageInfo.senderProfileImageUrl ?? ""])
                }
                viewModel.deliveredMessageIndicator(conversationId: converId, messageId: messId) { _ in
                    ISMChatHelper.print("Message marked delivered")
                }
            }
        }
    }
}
