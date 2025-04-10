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
                        Task{
                            try? await self.localStorageManager.updateLastMsgAsDeliver(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", userId: messageInfo.userId ?? "", updatedAt:  messageInfo.updatedAt ?? 0)
                            try? await self.localStorageManager.addDeliveredToUser(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.updatedAt ?? -1)
                            try? await self.localStorageManager.updateAllDeliveryStatus(conversationId: messageInfo.conversationId ?? "")
                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageDelivered.name, object: nil,userInfo: ["data": data,"error" : ""])
                        }
//                        self.realmManager.updateLastmsgDeliver(conId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.updatedAt ?? 0)
//                        self.realmManager.addDeliveredToUser(convId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.updatedAt ?? -1)
//                        self.realmManager.updateAllDeliveryStatus(conId: messageInfo.conversationId ?? "")
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        case .mqttMessageRead:
            self.messageRead(data) { result in
                switch result{
                case .success(let messageInfo):
                    Task{
                        try? await self.localStorageManager.addReadByUser(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.updatedAt ?? 0)
                        try? await self.localStorageManager.updateDeliveryStatusThroughMsgId(conversationId:  messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "")
                        try? await self.localStorageManager.updateReadStatusThroughMsgId(messageId:  messageInfo.messageId ?? "")
                        try? await self.localStorageManager.updateLastMessageRead(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.updatedAt ?? 0)
//                        self.realmManager.addReadByUser(convId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.updatedAt ?? 0)
//                        self.realmManager.updateDeliveryStatusThroughMsgId(conId: messageInfo.conversationId ?? "", msgId: messageInfo.messageId ?? "")
//                        self.realmManager.updateReadStatusThroughMsgId(msgId: messageInfo.messageId ?? "")
                        
//                        self.realmManager.updateLastmsgRead(conId: messageInfo.conversationId ?? "",messageId: messageInfo.messageId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.updatedAt ?? 0)
                        NotificationCenter.default.post(name: NSNotification.updateChatBadgeCount, object: nil, userInfo: nil)
                        NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageRead.name, object: nil,userInfo: ["data": data,"error" : ""])
                    }
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
                        Task{
                            try? await self.localStorageManager.updateLastMessageRead(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.sentAt ?? 00)
                            try? await self.localStorageManager.updateAllReadStatus(conversationId: messageInfo.conversationId ?? "")
                            try? await self.localStorageManager.updateDeliveredToInAllmsgs(conversationId: messageInfo.conversationId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.lastReadAt ?? 0)
                            try? await self.localStorageManager.updateReadByInAllMessages(conversationId: messageInfo.conversationId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.lastReadAt ?? 0)
                            NotificationCenter.default.post(name: NSNotification.updateChatBadgeCount, object: nil, userInfo: nil)
                            let dataNew: [String: Any] = [
                                           "messageId": messageInfo.messageId ?? "",
                                           "conversationId": messageInfo.conversationId ?? "",
                                           "userId": messageInfo.userId ?? "",
                                           "updatedAt": messageInfo.updatedAt ?? 0
                                       ]
                            NotificationCenter.default.post(name: NSNotification.mqttUpdateReadStatus, object: nil, userInfo: dataNew)
                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMultipleMessageRead.name, object: nil,userInfo: ["data": data,"error" : ""])
                        }
//                        self.realmManager.updateLastmsgRead(conId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.sentAt ?? 00)
//                        self.realmManager.updateAllReadStatus(conId: messageInfo.conversationId ?? "")
//                        self.realmManager.updateDeliveredToInAllmsgs(convId: messageInfo.conversationId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.lastReadAt ?? 0)
//                        self.realmManager.updateReadbyInAllmsgs(convId: messageInfo.conversationId ?? "", userId: messageInfo.userId ?? "", updatedAt: messageInfo.lastReadAt ?? 0)
                       
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
                    Task{
                        try? await self.localStorageManager.deleteConversation(conversationId: data.conversationId ?? "")
                    }
//                    self.realmManager.deleteConversation(convID: data.conversationId ?? "")
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
                    Task{
                        let msg = ISMChatLastMessageDB(sentAt: messageInfo.sentAt, conversationId: messageInfo.conversationId, body: nil, messageId: messageInfo.messageId, action: messageInfo.action, reactionType: messageInfo.reactionType, userName: messageInfo.userName ?? "")
                        try? await self.localStorageManager.updateLastMessageInConversation(conversationId: messageInfo.conversationId ?? "", lastMessage: msg)
                        try? await self.localStorageManager.addReactionToMessage(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", reaction: messageInfo.reactionType ?? "", userId: messageInfo.userId ?? "")
                        //                    self.realmManager.updateLastmsg(conId: messageInfo.conversationId ?? "", msg: msg)
                        //                    self.realmManager.addReactionToMessage(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", reaction: messageInfo.reactionType ?? "", userId: messageInfo.userId ?? "")
                        NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttAddReaction.name, object: nil,userInfo: ["data": data,"error" : ""])
                    }
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
                    Task{
                        let msg = ISMChatLastMessageDB(sentAt: messageInfo.sentAt, conversationId: messageInfo.conversationId, body: nil, messageId: messageInfo.messageId, action: messageInfo.action, reactionType: messageInfo.reactionType, userName: messageInfo.userName ?? "")
                        try? await self.localStorageManager.updateLastMessageInConversation(conversationId: messageInfo.conversationId ?? "", lastMessage: msg)
                        try? await self.localStorageManager.removeReactionFromMessage(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", reaction: messageInfo.reactionType ?? "", userId: messageInfo.userId ?? "")
                        //                    let msg = ISMChatLastMessage(sentAt: messageInfo.sentAt,conversationId: messageInfo.conversationId, body: nil, messageId: messageInfo.messageId, timeStamp: messageInfo.sentAt, action: messageInfo.action,userName: messageInfo.userName ?? "", reactionType: messageInfo.reactionType)
                        //
                        //                    self.realmManager.updateLastmsg(conId: messageInfo.conversationId ?? "", msg: msg)
                        //                    self.realmManager.removeReactionFromMessage(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", reaction: messageInfo.reactionType ?? "", userId: messageInfo.userId ?? "")
                        NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttRemoveReaction.name, object: nil,userInfo: ["data": data,"error" : ""])
                    }
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
                Task{
                    // Process contacts
                    var contactsValue: [ISMChatContactDB] = []
                    if let contacts = messageInfo.metaData?.contacts ?? messageInfo.details?.metaData?.contacts {
                        for contact in contacts {
                            let contactDB = ISMChatContactDB(
                                contactName: contact.contactName,
                                contactIdentifier: contact.contactIdentifier,
                                contactImageUrl: contact.contactImageUrl
                            )
                            contactsValue.append(contactDB)
                        }
                    }
                    
                    // Process payment request members
                    var paymentRequestMembersValue: [ISMChatPaymentRequestMembersDB] = []
                    if let members = messageInfo.metaData?.paymentRequestedMembers ?? messageInfo.details?.metaData?.paymentRequestedMembers {
                        for member in members {
                            let memberDB = ISMChatPaymentRequestMembersDB(
                                userId: member.userId,
                                userName: member.userName,
                                status: member.status,
                                statusText: member.statusText,
                                appUserId: member.appUserId,
                                userProfileImage: member.userProfileImage,
                                declineReason: member.declineReason
                            )
                            paymentRequestMembersValue.append(memberDB)
                        }
                    }
                    
                    // Process invite members
                    var inviteMembersValue: [ISMChatPaymentRequestMembersDB] = []
                    if let members = messageInfo.metaData?.inviteMembers ?? messageInfo.details?.metaData?.inviteMembers {
                        for member in members {
                            let memberDB = ISMChatPaymentRequestMembersDB(
                                userId: member.userId,
                                userName: member.userName,
                                status: member.status,
                                statusText: member.statusText,
                                appUserId: member.appUserId,
                                userProfileImage: member.userProfileImage,
                                declineReason: member.declineReason
                            )
                            inviteMembersValue.append(memberDB)
                        }
                    }
                    let metaData = ISMChatMetaDataDB(
                        locationAddress: messageInfo.metaData?.locationAddress ?? messageInfo.details?.metaData?.locationAddress,
                        
                        replyMessage: (messageInfo.metaData?.replyMessage ?? messageInfo.details?.metaData?.replyMessage).map {
                            ISMChatReplyMessageDB(
                                parentMessageId: $0.parentMessageId,
                                parentMessageBody: $0.parentMessageBody,
                                parentMessageUserId: $0.parentMessageUserId,
                                parentMessageUserName: $0.parentMessageUserName,
                                parentMessageMessageType: $0.parentMessageMessageType,
                                parentMessageAttachmentUrl: $0.parentMessageAttachmentUrl,
                                parentMessageInitiator: $0.parentMessageInitiator,
                                parentMessagecaptionMessage: $0.parentMessagecaptionMessage
                            )
                        },
                        
                        contacts: contactsValue,
                        captionMessage: messageInfo.metaData?.captionMessage ?? messageInfo.details?.metaData?.captionMessage,
                        isBroadCastMessage: messageInfo.metaData?.isBroadCastMessage ?? messageInfo.details?.metaData?.isBroadCastMessage,
                        
                        post: (messageInfo.metaData?.post ?? messageInfo.details?.metaData?.post).map {
                            ISMChatPostDB(
                                postId: $0.postId,
                                postUrl: $0.postUrl
                            )
                        },
                        
                        product: (messageInfo.metaData?.product ?? messageInfo.details?.metaData?.product).map {
                            ISMChatProductDB(
                                productId: $0.productId,
                                productUrl: $0.productUrl,
                                productCategoryId: $0.productCategoryId
                            )
                        },
                        
                        storeName: messageInfo.metaData?.storeName ?? messageInfo.details?.metaData?.storeName,
                        productName: messageInfo.metaData?.productName ?? messageInfo.details?.metaData?.productName,
                        bestPrice: messageInfo.metaData?.bestPrice ?? messageInfo.details?.metaData?.bestPrice,
                        scratchPrice: messageInfo.metaData?.scratchPrice ?? messageInfo.details?.metaData?.scratchPrice,
                        url: messageInfo.metaData?.url ?? messageInfo.details?.metaData?.url,
                        parentProductId: messageInfo.metaData?.parentProductId ?? messageInfo.details?.metaData?.parentProductId,
                        childProductId: messageInfo.metaData?.childProductId ?? messageInfo.details?.metaData?.childProductId,
                        entityType: messageInfo.metaData?.entityType ?? messageInfo.details?.metaData?.entityType,
                        productImage: messageInfo.metaData?.productImage ?? messageInfo.details?.metaData?.productImage,
                        thumbnailUrl: messageInfo.metaData?.thumbnailUrl ?? messageInfo.details?.metaData?.thumbnailUrl,
                        Description: messageInfo.metaData?.description ?? messageInfo.details?.metaData?.description,
                        isVideoPost: messageInfo.metaData?.isVideoPost ?? messageInfo.details?.metaData?.isVideoPost,
                        socialPostId: messageInfo.metaData?.socialPostId ?? messageInfo.details?.metaData?.socialPostId,
                        collectionTitle: messageInfo.metaData?.collectionTitle ?? messageInfo.details?.metaData?.collectionTitle,
                        collectionDescription: messageInfo.metaData?.collectionDescription ?? messageInfo.details?.metaData?.collectionDescription,
                        productCount: messageInfo.metaData?.productCount ?? messageInfo.details?.metaData?.productCount,
                        collectionImage: messageInfo.metaData?.collectionImage ?? messageInfo.details?.metaData?.collectionImage,
                        collectionId: messageInfo.metaData?.collectionId ?? messageInfo.details?.metaData?.collectionId,
                        paymentRequestId: messageInfo.metaData?.paymentRequestId ?? messageInfo.details?.metaData?.paymentRequestId,
                        orderId: messageInfo.metaData?.orderId ?? messageInfo.details?.metaData?.orderId,
                        paymentRequestedMembers: paymentRequestMembersValue,
                        requestAPaymentExpiryTime: messageInfo.metaData?.requestAPaymentExpiryTime ?? messageInfo.details?.metaData?.requestAPaymentExpiryTime,
                        currencyCode: messageInfo.metaData?.currencyCode ?? messageInfo.details?.metaData?.currencyCode,
                        amount: messageInfo.metaData?.amount ?? messageInfo.details?.metaData?.amount,
                        inviteTitle: messageInfo.metaData?.inviteTitle ?? messageInfo.details?.metaData?.inviteTitle,
                        inviteTimestamp: messageInfo.metaData?.inviteTimestamp ?? messageInfo.details?.metaData?.inviteTimestamp,
                        inviteRescheduledTimestamp: messageInfo.metaData?.inviteRescheduledTimestamp ?? messageInfo.details?.metaData?.inviteRescheduledTimestamp,
                        
                        inviteLocation: (messageInfo.metaData?.inviteLocation ?? messageInfo.details?.metaData?.inviteLocation).map {
                            ISMChatLocationDB(
                                name: $0.name,
                                latitude: $0.latitude,
                                longitude: $0.longitude
                            )
                        },
                        
                        inviteMembers: inviteMembersValue,
                        groupCastId: messageInfo.metaData?.groupCastId ?? messageInfo.details?.metaData?.groupCastId,
                        status: messageInfo.metaData?.status ?? messageInfo.details?.metaData?.status
                    )
                    try? await self.localStorageManager.updateMessage(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", body: messageInfo.details?.body ?? "", metaData: metaData, customType: messageInfo.details?.customType ?? "")
                }
                //                self.realmManager.updateMessageBody(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", body: messageInfo.details?.body ?? "", metaData: messageInfo.details?.metaData ?? ISMChatMetaData(), customType: messageInfo.details?.customType ?? "")
                //                if let url = messageInfo.details?.metaData?.url{
                //                    self.realmManager.updateLastMessageOnEdit(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", newBody: url,metaData: messageInfo.details?.metaData ?? ISMChatMetaData())
                //                }else{
                //                    self.realmManager.updateLastMessageOnEdit(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", newBody: messageInfo.details?.body ?? "",metaData: messageInfo.details?.metaData ?? ISMChatMetaData())
                //                }
            case .failure(let error):
                ISMChatHelper.print(error)
            }
        }
    }
    
    public func messageReceivedEvent(data : Data){
                self.messageReceived(data) { result in
                    switch result{
                    case .success(let messageInfo):
        
                        if ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userId != messageInfo.senderId{
                            // added last message in realm
                            Task{
                                let membersArray = messageInfo.members?.map { member -> ISMChatLastMessageMemberDB in
                                    var chatMember = ISMChatLastMessageMemberDB()
                                    chatMember.memberId = member.memberId
                                    chatMember.memberIdentifier = member.memberIdentifier
                                    chatMember.memberName = member.memberName
                                    chatMember.memberProfileImageUrl = member.memberProfileImageUrl
                                    return chatMember
                                } ?? []
                                
                                let msg = ISMChatLastMessageDB(
                                    sentAt: messageInfo.sentAt,
                                    updatedAt: messageInfo.updatedAt ?? messageInfo.sentAt, // Default to sentAt if updatedAt is nil
                                    senderName: messageInfo.senderName,
                                    senderIdentifier: messageInfo.senderIdentifier,
                                    senderId: messageInfo.senderId,
                                    conversationId: messageInfo.conversationId,
                                    body: messageInfo.body ?? "",
                                    messageId: messageInfo.messageId,
                                    customType: messageInfo.customType ?? "",
                                    action: messageInfo.action ?? "",
                                    userId: messageInfo.userId,
                                    userIdentifier: messageInfo.userIdentifier,
                                    userName: messageInfo.userName,
                                    userProfileImageUrl: messageInfo.userProfileImageUrl ?? "",
                                    members: membersArray, // Ensure `membersArray` is defined
                                    memberName: messageInfo.memberName ?? "",
                                    memberId: messageInfo.memberId ?? "",
                                    messageDeleted: false,
                                    initiatorName: messageInfo.initiatorName ?? "",
                                    initiatorId: messageInfo.initiatorId ?? "",
                                    initiatorIdentifier: messageInfo.initiatorIdentifier ?? "",
                                    deletedMessage: false,
                                    meetingId: messageInfo.meetingId ?? ""
                                )
                                
                                try? await self.localStorageManager.updateLastMessageInConversation(conversationId: messageInfo.conversationId ?? "", lastMessage: msg)
                                
                                
                                var bodyUpdated = messageInfo.body
                                var customType = messageInfo.customType
                                var metaData = self.returnMetaData(parentMessageId: messageInfo.parentMessageId ??  "", metaData: messageInfo.metaData ?? ISMChatMetaData())
                                //updated message
                                if messageInfo.action == ISMChatActionType.messageDetailsUpdated.value ?? ""{
                                    bodyUpdated = messageInfo.details?.body
                                    customType = messageInfo.details?.customType
                                    metaData = self.returnMetaData(parentMessageId: messageInfo.parentMessageId ??  "", metaData: messageInfo.details?.metaData ?? ISMChatMetaData())
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
                                    createdBy: messageInfo.createdBy ?? "",
                                    action: messageInfo.action ?? "",
                                    readBy: [],
                                    deliveredTo: [],
                                    messageType: 0,
                                    parentMessageId: messageInfo.parentMessageId ?? "",
                                    metaData: metaData,
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
                                
                                try? await self.localStorageManager.saveAllMessages([message], conversationId: messageInfo.conversationId ?? "")
                                
                                let viewModel = ChatsViewModel()
                                if let converId = messageInfo.conversationId, let messId = messageInfo.messageId{
                                    viewModel.deliveredMessageIndicator(conversationId: converId, messageId: messId) { _ in
                                        ISMChatHelper.print("Message marked delivered")
                                    }
                                }
                                
                                //add unread count
                                if messageInfo.action == ISMChatActionType.conversationCreated.value{
                                    try? await self.localStorageManager.updateUnreadCountThroughConversation(conversationId: messageInfo.conversationId ?? "", count: 0, reset: false)
                                }else{
                                    try? await self.localStorageManager.updateUnreadCountThroughConversation(conversationId: messageInfo.conversationId ?? "", count: 1, reset: false)
                                }
                            }
                        }
                        else{
                                // there are lots of messages send by logged in user from app or backend we need to save those too in swiftdata
                                //this is when you share social link, productlink and collectionlink from app, and then when u go to chat this will scroll to last message --> only saving my own message here for custom type, productLink,sociallink,collectionlink
                            if (messageInfo.customType == ISMChatMediaType.ProductLink.value || messageInfo.customType == ISMChatMediaType.SocialLink.value || messageInfo.customType == ISMChatMediaType.CollectionLink.value) && messageInfo.metaData?.isSharedFromApp == true{
                                
                                Task{
                                
                                var bodyUpdated = messageInfo.body
                                var customType = messageInfo.customType
                                var metaData = self.returnMetaData(parentMessageId: messageInfo.parentMessageId ?? "", metaData: messageInfo.metaData ?? ISMChatMetaData())
                                
                                if messageInfo.action == ISMChatActionType.messageDetailsUpdated.value ?? ""{
                                    bodyUpdated = messageInfo.details?.body
                                    customType = messageInfo.details?.customType
                                    
                                    metaData = self.returnMetaData(parentMessageId: messageInfo.parentMessageId ?? "", metaData: messageInfo.details?.metaData ?? ISMChatMetaData())
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
                                    createdBy: messageInfo.createdBy ?? "",
                                    action: messageInfo.action ?? "",
                                    readBy: [],
                                    deliveredTo: [],
                                    messageType: 0,
                                    parentMessageId: messageInfo.parentMessageId ?? "",
                                    metaData: metaData,
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
                                
                                try? await self.localStorageManager.saveAllMessages([message], conversationId: messageInfo.conversationId ?? "")
                            }
                                }else if messageInfo.metaData?.isSharedFromApp == true{
                                    // there are lots of messages send by logged in user from backend we need to save those too in swiftdata
                                    Task{
                                        
                                        var bodyUpdated = messageInfo.body
                                        var customType = messageInfo.customType
                                        var metaData = self.returnMetaData(parentMessageId: messageInfo.parentMessageId ?? "", metaData: messageInfo.metaData ??  ISMChatMetaData())
                                        
                                        if messageInfo.action == ISMChatActionType.messageDetailsUpdated.value ?? ""{
                                            bodyUpdated = messageInfo.details?.body
                                            customType = messageInfo.details?.customType
                                            metaData = self.returnMetaData(parentMessageId: messageInfo.parentMessageId ?? "", metaData: messageInfo.details?.metaData ??  ISMChatMetaData())
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
                                            createdBy: messageInfo.createdBy ?? "",
                                            action: messageInfo.action ?? "",
                                            readBy: [],
                                            deliveredTo: [],
                                            messageType: 0,
                                            parentMessageId: messageInfo.parentMessageId ?? "",
                                            metaData: metaData,
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
                                        
                                        try? await self.localStorageManager.saveAllMessages([message], conversationId: messageInfo.conversationId ?? "")
                                    }
                                }
                        }
        
        
                            if UIApplication.shared.applicationState == .background {
                                UserDefaults.standard.setValue("app is in background and i got mqtt event", forKey: "Chatsdk_1")
                                DispatchQueue.global(qos: .background).async {
                                    if messageInfo.senderId != ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userId {
                                        self.whenInOtherScreen(messageInfo: messageInfo)
                                    }
                                }
                            }else{
                                if let topViewController = UIApplication.topViewController() {
                                    if let Chatvc = self.viewcontrollers?.conversationListViewController,
                                       let Messagevc = self.viewcontrollers?.messagesListViewController {
        
                                        let isNotChatVC = !(topViewController.isKind(of: Chatvc))
                                        let isNotMessageVC = !(topViewController.isKind(of: Messagevc))
        
                                        if isNotChatVC && isNotMessageVC {
                                            // Your code here
                                            if messageInfo.senderId != ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userId{
                                                self.whenInOtherScreen(messageInfo: messageInfo)
                                            }
                                        }
                                    }
                                }
                            }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": messageInfo,"error" : ""])
                            NotificationCenter.default.post(name: NSNotification.updateChatBadgeCount, object: nil, userInfo: nil)
                        }
                    case .failure(let error):
                        NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
                    }
                }
    }
    
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
    
    public func returnMetaData(parentMessageId: String,metaData : ISMChatMetaData) -> ISMChatMetaDataDB{
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
                parentMessageId: parentMessageId,
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
            return ISMChatMetaDataDB(
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
}

