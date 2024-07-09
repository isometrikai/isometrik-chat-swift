//
//  RealmManager_Conversations.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift

extension RealmManager {
    
    //MARK: - get all conversations count
    public func getConversationCount() -> Int {
        conversations.count
    }
    
    //MARK: - get all conversations
    public func getConversation() -> [ConversationDB] {
        conversations
    }
    
    //MARK: - get conversation id if already there for specific user
    public func getConversationId(userId : String) -> String{
        let conversation = conversations.first { con in
            con.opponentDetails?.userId == userId
        }
        if conversation != nil{
            return conversation?.conversationId ?? ""
        }else{
            return ""
        }
    }
    
    
    //MARK: - We check if conversation already exist in local DB, if yes updateit, else save/add
    public func manageConversationList(arr: [ISMChat_ConversationsDetail]) {
        if let localRealm = localRealm {
            for obj in arr {
                let taskToUpdate = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@", (obj.conversationId ?? "")))
                if taskToUpdate.isEmpty {
                    addConversation(obj: [obj])
                }else {
                    if let objID = taskToUpdate.first?.id {
                        if taskToUpdate.first?.isDelete == false {
                            updateConversation(obj: obj)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Add conversation locally
    public func addConversation(obj: [ISMChat_ConversationsDetail]) {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    for value in obj {
                        
                        let obj = ConversationDB()
                        obj.conversationId = value.conversationId ?? ""
                        obj.updatedAt = value.lastMessageDetails?.updatedAt ?? 00
                        obj.unreadMessagesCount = value.unreadMessagesCount ?? 0
                        obj.membersCount = value.membersCount ?? 0
                        obj.lastMessageSentAt = value.lastMessageSentAt ?? 0
                        obj.createdAt = value.createdAt ?? 00
                        obj.mode = "mode"
                        obj.conversationTitle = value.conversationTitle ?? ""
                        obj.conversationImageUrl = value.conversationImageUrl ?? ""
                        obj.createdBy = value.createdBy ?? ""
                        obj.createdByUserName = value.createdByUserName ?? ""
                        obj.privateOneToOne = value.privateOneToOne ?? false
                        obj.messagingDisabled = false
                        obj.isGroup = value.isGroup ?? false
                        
                        let config = ConfigDB()
                        config.typingEvents = value.config?.typingEvents
                        config.pushNotifications = value.config?.pushNotifications
                        config.readEvents = value.config?.readEvents
                        obj.config = config
                        
                        let user = UserDB()
                        user.lastSeen = value.opponentDetails?.lastSeen ?? 00
                        user.online = value.opponentDetails?.online
                        user.userId = value.opponentDetails?.userId
                        user.userIdentifier = value.opponentDetails?.userIdentifier
                        user.userName = value.opponentDetails?.userName
                        user.userProfileImageUrl = value.opponentDetails?.userProfileImageUrl
                        
                        obj.opponentDetails = user
                        
                        let lastMsg = LastMessageDB()
                        lastMsg.sentAt = value.lastMessageDetails?.sentAt
                        lastMsg.updatedAt = value.lastMessageDetails?.updatedAt
                        lastMsg.senderName = value.lastMessageDetails?.senderName
                        lastMsg.senderIdentifier = value.lastMessageDetails?.senderIdentifier
                        lastMsg.senderId = value.lastMessageDetails?.senderId
                        lastMsg.conversationId = value.lastMessageDetails?.conversationId
                        lastMsg.body = value.lastMessageDetails?.body
                        lastMsg.messageId = value.lastMessageDetails?.messageId
                        lastMsg.customType = value.lastMessageDetails?.customType
                        lastMsg.action = value.lastMessageDetails?.action
                        lastMsg.userId = value.lastMessageDetails?.userId ?? ""
                        lastMsg.reactionType = value.lastMessageDetails?.reactionType ?? ""
                        lastMsg.memberName = value.lastMessageDetails?.memberName ?? ""
                        lastMsg.memberId = value.lastMessageDetails?.memberId ?? ""
                        lastMsg.userName = value.lastMessageDetails?.userName ?? ""
                        lastMsg.initiatorName = value.lastMessageDetails?.initiatorName
                        lastMsg.initiatorId = value.lastMessageDetails?.initiatorId
                        lastMsg.initiatorIdentifier = value.lastMessageDetails?.initiatorIdentifier
                        lastMsg.reactionType = value.lastMessageDetails?.reactionType ?? ""
                        lastMsg.meetingId = value.lastMessageDetails?.meetingId
                        
                        if let missedByMembers = value.lastMessageDetails?.missedByMembers {
                            for x in missedByMembers{
                                lastMsg.missedByMembers.append(x)
                            }
                        }
                        
                        if let callDurations = value.lastMessageDetails?.callDurations{
                            for x in callDurations{
                                let objV = ISMMeetingDuration()
                                objV.memberId = x.memberId
                                objV.durationInMilliseconds = x.durationInMilliseconds
                                lastMsg.callDurations.append(objV)
                            }
                        }
                        
                        if lastMsg.action == ISMChat_ActionType.messageDetailsUpdated.value{
                            lastMsg.body = value.lastMessageDetails?.details?.body
                        }
                        
                        
                        for x in value.lastMessageDetails?.members ?? []{
                            let obj = LastMessageMemberDB()
                            obj.memberProfileImageUrl = x.memberProfileImageUrl
                            obj.memberName = x.memberName
                            obj.memberIdentifier = x.memberIdentifier
                            obj.memberId = x.memberId
                            lastMsg.members.append(obj)
                        }
                        
                        
                        let metaData = MetaDataDB()
                        
                        let replyMessageData = ReplyMessageDB()
                        replyMessageData.parentMessageId = value.lastMessageDetails?.metaData?.replyMessage?.parentMessageId
                        replyMessageData.parentMessageBody = value.lastMessageDetails?.metaData?.replyMessage?.parentMessageBody
                        replyMessageData.parentMessageUserId = value.lastMessageDetails?.metaData?.replyMessage?.parentMessageUserId
                        replyMessageData.parentMessageUserName = value.lastMessageDetails?.metaData?.replyMessage?.parentMessageUserName
                        replyMessageData.parentMessageMessageType = value.lastMessageDetails?.metaData?.replyMessage?.parentMessageMessageType
                        replyMessageData.parentMessageAttachmentUrl = value.lastMessageDetails?.metaData?.replyMessage?.parentMessageAttachmentUrl
                        replyMessageData.parentMessageInitiator = value.lastMessageDetails?.metaData?.replyMessage?.parentMessageInitiator
                        replyMessageData.parentMessagecaptionMessage = value.lastMessageDetails?.metaData?.replyMessage?.parentMessagecaptionMessage
                        
                        metaData.replyMessage = replyMessageData
                        metaData.locationAddress = value.lastMessageDetails?.metaData?.locationAddress
                        metaData.captionMessage = value.lastMessageDetails?.metaData?.captionMessage
                        metaData.isBroadCastMessage = value.lastMessageDetails?.metaData?.isBroadCastMessage
                        lastMsg.metaData = metaData
                        
                        
                        for obj in value.lastMessageDetails?.deliveredTo ?? [] {
                            let deliverObj = MessageDeliveryStatusDB()
                            deliverObj.userId = obj.userId
                            deliverObj.timestamp = obj.timestamp
                            
                            lastMsg.deliveredTo.append(deliverObj)
                        }
                        
                        for obj in value.lastMessageDetails?.readBy ?? [] {
                            let deliverObj = MessageDeliveryStatusDB()
                            deliverObj.userId = obj.userId
                            deliverObj.timestamp = obj.timestamp
                            
                            lastMsg.readBy.append(deliverObj)
                        }
                        obj.lastMessageDetails = lastMsg
                        
                        localRealm.add(obj)
                    }
                    getAllConversations()
                }
            } catch {
                print("Error adding task to Realm: \(error)")
            }
        }
    }
    
    //MARK: - update convertion if already exist in local db
    public func updateConversation(obj: ISMChat_ConversationsDetail) {
        if let localRealm = localRealm {
            do {
                let listToUpdate = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@  AND isDelete = %d", (obj.conversationId ?? ""), false))
                
                guard !listToUpdate.isEmpty else { return }
                try localRealm.write {
                    
                    listToUpdate.first?.updatedAt = obj.lastMessageDetails?.updatedAt ?? 00
                    listToUpdate.first?.unreadMessagesCount = obj.unreadMessagesCount ?? 0
                    listToUpdate.first?.membersCount = obj.membersCount ?? 0
                    listToUpdate.first?.lastMessageSentAt = obj.lastMessageSentAt ?? 0
                    listToUpdate.first?.createdAt = obj.createdAt ?? 00
                    listToUpdate.first?.mode = "need to set"
                    listToUpdate.first?.conversationTitle = obj.conversationTitle ?? ""
                    listToUpdate.first?.conversationImageUrl = obj.conversationImageUrl ?? ""
                    listToUpdate.first?.createdBy = obj.createdBy ?? ""
                    listToUpdate.first?.createdByUserName = obj.createdByUserName ?? ""
                    listToUpdate.first?.privateOneToOne = obj.privateOneToOne ?? false
                    listToUpdate.first?.messagingDisabled = false
                    listToUpdate.first?.isGroup = obj.isGroup ?? false
                    
                    let config = ConfigDB()
                    config.pushNotifications = obj.config?.pushNotifications
                    config.typingEvents = obj.config?.typingEvents
                    config.readEvents = obj.config?.readEvents
                    listToUpdate.first?.config = config
                    
                    listToUpdate.first?.opponentDetails?.lastSeen = obj.opponentDetails?.lastSeen ?? 00
                    listToUpdate.first?.opponentDetails?.online = obj.opponentDetails?.online
                    listToUpdate.first?.opponentDetails?.userId = obj.opponentDetails?.userId
                    listToUpdate.first?.opponentDetails?.userIdentifier = obj.opponentDetails?.userIdentifier
                    listToUpdate.first?.opponentDetails?.userName = obj.opponentDetails?.userName
                    listToUpdate.first?.opponentDetails?.userProfileImageUrl = obj.opponentDetails?.userProfileImageUrl
                    
                    listToUpdate.first?.lastMessageDetails?.sentAt = obj.lastMessageDetails?.sentAt
                    listToUpdate.first?.lastMessageDetails?.updatedAt = obj.lastMessageDetails?.updatedAt
                    listToUpdate.first?.lastMessageDetails?.senderName = obj.lastMessageDetails?.senderName
                    listToUpdate.first?.lastMessageDetails?.senderIdentifier = obj.lastMessageDetails?.senderIdentifier
                    listToUpdate.first?.lastMessageDetails?.senderId = obj.lastMessageDetails?.senderId
                    listToUpdate.first?.lastMessageDetails?.conversationId = obj.lastMessageDetails?.conversationId
                    listToUpdate.first?.lastMessageDetails?.body = obj.lastMessageDetails?.body ?? ""
                    listToUpdate.first?.lastMessageDetails?.messageId = obj.lastMessageDetails?.messageId
                    listToUpdate.first?.lastMessageDetails?.userId = obj.lastMessageDetails?.userId ?? ""
                    listToUpdate.first?.lastMessageDetails?.userIdentifier = obj.lastMessageDetails?.userIdentifier
                    listToUpdate.first?.lastMessageDetails?.userName = obj.lastMessageDetails?.userName
                    listToUpdate.first?.lastMessageDetails?.userProfileImageUrl = obj.lastMessageDetails?.userProfileImageUrl
                    listToUpdate.first?.lastMessageDetails?.initiatorId = obj.lastMessageDetails?.initiatorId
                    listToUpdate.first?.lastMessageDetails?.customType = obj.lastMessageDetails?.customType
                    listToUpdate.first?.lastMessageDetails?.action = obj.lastMessageDetails?.action
                    if listToUpdate.first?.lastMessageDetails?.action == ISMChat_ActionType.messageDetailsUpdated.value{
                        listToUpdate.first?.lastMessageDetails?.body = obj.lastMessageDetails?.details?.body
                    }
                    
                    listToUpdate.first?.lastMessageDetails?.deliveredTo.removeAll()
                    listToUpdate.first?.lastMessageDetails?.readBy.removeAll()
                    
                    for obj in obj.lastMessageDetails?.deliveredTo ?? [] {
                        let deliverObj = MessageDeliveryStatusDB()
                        deliverObj.userId = obj.userId
                        deliverObj.timestamp = obj.timestamp
                        
                        listToUpdate.first?.lastMessageDetails?.deliveredTo.append(deliverObj)
                    }
                    
                    for obj in obj.lastMessageDetails?.readBy ?? [] {
                        let deliverObj = MessageDeliveryStatusDB()
                        deliverObj.userId = obj.userId
                        deliverObj.timestamp = obj.timestamp
                        
                        listToUpdate.first?.lastMessageDetails?.readBy.append(deliverObj)
                    }
                    
                    getAllConversations()
                }
            } catch {
                print("Error updating task \(obj.id) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - Get local conversations
    public func getAllConversations() {
        if let localRealm = localRealm {
            conversations =  Array(localRealm.objects(ConversationDB.self).where{$0.isDelete == false })
            conversations = conversations.sorted(by: { lhsData, rhsData in
                lhsData.lastMessageSentAt > rhsData.lastMessageSentAt
            })
            //remove broadcast list from conversationList
            let data = conversations.filter { conversation in
                return conversation.opponentDetails?.userId == nil && conversation.opponentDetails?.userName == nil
                && conversation.isGroup == false
            }
            conversations = conversations.filter { !data.contains($0) }
            storeConv = conversations
        }
    }
    
    //MARK: - delete conversation locally
    public func deleteConversation(convID: String) {
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@", convID))
                guard !taskToDelete.isEmpty else { return }
                try localRealm.write {
                    taskToDelete.first?.isDelete = true
                    getAllConversations()
                }
            } catch {
                print("Error deleting task \(convID) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - undo delete conversation
    public func undodeleteConversation(convID: String) {
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@ AND isDelete = %d", convID, true))
                guard !taskToDelete.isEmpty else { return }
                try localRealm.write {
                    taskToDelete.first?.isDelete = false
                }
            } catch {
                print("Error deleting task \(convID) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - Hard delete all conversations in local DB
    public func hardDeleteAll() {
        if let localRealm = localRealm {
            do {
                let obj = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "isDelete = %d", true))
                guard !obj.isEmpty else { return }
                try localRealm.write {
                    localRealm.delete(obj)
                }
            } catch {
                //                print("Error deleting task \(convID) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - hard delete single conversation
    public func hardConvDelete(convID:String) {
        if let localRealm = localRealm {
            do {
                let obj = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@", convID))
                guard !obj.isEmpty else { return }
                try localRealm.write {
                    localRealm.delete(obj)
                    self.getAllConversations()
                }
            } catch {
                print("Error deleting task \(convID) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - Get last message "sent time" for perticular conversation
    public func getlastMessageSentForConversation(conversationId: String) -> String {
        if let localRealm = localRealm {
            let msgs = (localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@ AND isDelete = %d", conversationId, false)))
            guard !msgs.isEmpty else { return ""}
            return msgs.last?.lastMessageSentAt.description ?? ""
        }
        return ""
    }
    
    //MARK: - Get last message "action" for perticular conversation
    public func getConversationListLastMessageAction(conversationId: String) -> String {
        guard let localRealm = localRealm else { return "" } // Ensure localRealm is not nil
        
        // Fetch conversation with the given conversationId and isDelete flag is false
        let conversation = localRealm.objects(ConversationDB.self)
            .filter("conversationId == %@ AND isDelete == false", conversationId)
            .first
        
        // Ensure conversation is not nil
        guard let lastMessageDetails = conversation?.lastMessageDetails else { return "" }
        
        // Return the action of the last message
        return lastMessageDetails.action ?? ""
    }
    
    //MARK: - update last message of conversation
    public func updateLastmsg(conId:String,msg: ISMChat_LastMessage) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@  AND isDelete = %d", (conId ), false))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    
                    taskToUpdate.first?.lastMessageSentAt = Int(msg.sentAt ?? 00)
                    
                    taskToUpdate.first?.lastMessageDetails?.sentAt = msg.sentAt
                    taskToUpdate.first?.lastMessageDetails?.updatedAt = msg.updatedAt
                    taskToUpdate.first?.lastMessageDetails?.senderName = msg.senderName
                    taskToUpdate.first?.lastMessageDetails?.senderIdentifier = msg.senderIdentifier
                    taskToUpdate.first?.lastMessageDetails?.senderId = msg.senderId
                    taskToUpdate.first?.lastMessageDetails?.conversationId = msg.conversationId
                    taskToUpdate.first?.lastMessageDetails?.body = msg.body
                    taskToUpdate.first?.lastMessageDetails?.messageId = msg.messageId
                    taskToUpdate.first?.lastMessageDetails?.customType = msg.customType
                    taskToUpdate.first?.lastMessageDetails?.action = msg.action
                    taskToUpdate.first?.lastMessageDetails?.messageDeleted = msg.messageDeleted ?? false
                    taskToUpdate.first?.lastMessageDetails?.deletedMessage = msg.messageDeleted ?? false
                    taskToUpdate.first?.lastMessageDetails?.initiatorId = msg.initiatorId
                    taskToUpdate.first?.lastMessageDetails?.initiatorName = msg.initiatorName
                    taskToUpdate.first?.lastMessageDetails?.initiatorIdentifier = msg.initiatorIdentifier
                    taskToUpdate.first?.lastMessageDetails?.memberId = msg.memberId ?? ""
                    taskToUpdate.first?.lastMessageDetails?.memberName = msg.memberName ?? ""
                    taskToUpdate.first?.lastMessageDetails?.userId = msg.userId ?? ""
                    taskToUpdate.first?.lastMessageDetails?.userName = msg.userName
                    taskToUpdate.first?.lastMessageDetails?.userIdentifier = msg.userIdentifier
                    taskToUpdate.first?.lastMessageDetails?.userProfileImageUrl = msg.userProfileImageUrl
                    taskToUpdate.first?.lastMessageDetails?.reactionType = msg.reactionType ?? ""
                    
                    taskToUpdate.first?.lastMessageDetails?.meetingId = msg.meetingId ?? ""
                    if let duration = msg.callDurations{
                        for x in duration{
                            var value = ISMMeetingDuration()
                            value.memberId = x.memberId
                            value.durationInMilliseconds = x.durationInMilliseconds
                            taskToUpdate.first?.lastMessageDetails?.callDurations.append(value)
                        }
                    }
                    if let missedByMembers = msg.missedByMembers{
                        for x in missedByMembers{
                            taskToUpdate.first?.lastMessageDetails?.missedByMembers.append(x)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - update last message detail
    public func updateLastMessageDetails(conId:String,msgObj:MessagesDB) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@  AND isDelete = %d", (conId ), false))
            if !taskToUpdate.isEmpty {
                if msgObj.messageId != taskToUpdate.first?.lastMessageDetails?.messageId && msgObj.messageId != "" {
                    self.clearLastMessageDeliverReadInfo(convID: conId)
                }else if msgObj.msgSyncStatus == ISMChat_SyncStatus.Local.txt {
                    self.clearLastMessageDeliverReadInfo(convID: conId)
                }
                try! localRealm.write {
                    taskToUpdate.first?.lastMessageSentAt = Int(msgObj.sentAt )
                    //                        let lastMsg = LastMessageDB()
                    taskToUpdate.first?.lastMessageDetails?.sentAt = Double(msgObj.sentAt)
                    //                    lastMsg.updatedAt = msgObj.l
                    taskToUpdate.first?.lastMessageDetails?.senderName = msgObj.senderInfo?.userName
                    taskToUpdate.first?.lastMessageDetails?.senderIdentifier = msgObj.senderInfo?.userIdentifier
                    taskToUpdate.first?.lastMessageDetails?.senderId = msgObj.senderInfo?.userId
                    taskToUpdate.first?.lastMessageDetails?.conversationId = msgObj.conversationId
                    taskToUpdate.first?.lastMessageDetails?.body = msgObj.body
                    taskToUpdate.first?.lastMessageDetails?.messageId = msgObj.messageId
                    taskToUpdate.first?.lastMessageDetails?.customType = msgObj.customType
                    taskToUpdate.first?.lastMessageDetails?.action = msgObj.action
                    taskToUpdate.first?.lastMessageDetails?.msgSyncStatus = msgObj.msgSyncStatus
                    taskToUpdate.first?.lastMessageDetails?.members = msgObj.members
                    taskToUpdate.first?.lastMessageDetails?.userName = msgObj.userName
                    taskToUpdate.first?.lastMessageDetails?.deletedMessage = msgObj.deletedMessage
                    taskToUpdate.first?.lastMessageDetails?.deliveredTo = msgObj.deliveredTo
                    taskToUpdate.first?.lastMessageDetails?.readBy = msgObj.readBy
                    taskToUpdate.first?.lastMessageDetails?.userId = msgObj.userId
                    taskToUpdate.first?.lastMessageDetails?.userIdentifier = msgObj.userIdentifier
                    taskToUpdate.first?.lastMessageDetails?.userProfileImageUrl = msgObj.userProfileImageUrl
                    taskToUpdate.first?.lastMessageDetails?.reactionType = msgObj.reactionType
                    taskToUpdate.first?.lastMessageDetails?.initiatorId = msgObj.initiatorId
                }
            }
        }
    }
    
    //MARK: - clear lastmessagedb deliveredto and readby
    public func clearLastMessageDeliverReadInfo(convID: String){
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(LastMessageDB.self).filter(NSPredicate(format: "conversationId == %@", convID))
                guard !taskToDelete.isEmpty else { return }
                try localRealm.write {
                    taskToDelete.first?.deliveredTo.removeAll()
                    taskToDelete.first?.readBy.removeAll()
                }
            } catch {
                print("Error deleting task \(convID) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - change typing status in conversationList for perticular conversation
    public func changeTypingStatus(convId:String,status:Bool) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@  AND isDelete = %d", (convId ), false))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    taskToUpdate.first?.typing = status
                    self.getAllConversations()
                }
            }
        }
    }
    
    //MARK: - update last message body on edit
    public func updateLastMessageOnEdit(conversationId: String, messageId: String, newBody: String) {
        if let localRealm = localRealm {
            let conversationToUpdate = localRealm.objects(ConversationDB.self).where{$0.conversationId == conversationId && $0.isDelete == false && $0.lastMessageDetails.messageId == messageId}
            try! localRealm.write {
                    conversationToUpdate.first?.lastMessageDetails?.body = newBody
                getAllConversations()
            }
        }
    }
    
    //MARK: - add last message in conversationDB on add or remove reaction
    public func addLastMessageOnAddAndRemoveReaction(conversationId: String,action : String,emoji : String,userId: String) {
        if let localRealm = localRealm {
            let conversationToUpdate = localRealm.objects(ConversationDB.self).where{$0.conversationId == conversationId && $0.isDelete == false}
            try! localRealm.write {
                conversationToUpdate.first?.lastMessageDetails?.action = action
                conversationToUpdate.first?.lastMessageDetails?.reactionType = emoji
                conversationToUpdate.first?.lastMessageDetails?.userId = userId
                getAllConversations()
            }
        }
    }
    
    //MARK: -  update unread count in conversationList
    public func updateUnreadCountThroughConId(conId: String,count:Int, reset:Bool = false) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@  AND isDelete = %d", (conId ), false))
            try! localRealm.write {
                taskToUpdate.first?.unreadMessagesCount = reset ? 0 : ((taskToUpdate.first?.unreadMessagesCount ?? 0)) + count
            }
        }
    }
    
    //MARK: - update last message delivered
    public func updateLastmsgDeliver(conId:String,msg: ISMChat_MessageDelivered) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(LastMessageDB.self).filter(NSPredicate(format: "conversationId == %@ AND messageId == %@", (conId ), (msg.messageId ?? "")))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    
                    taskToUpdate.first?.deliveredTo.first?.userId = msg.userId
                    taskToUpdate.first?.deliveredTo.first?.timestamp = msg.updatedAt
                    
                    
                }
            }
        }
    }
    
    //MARK: -  update last message delivery info
    public func updateLastmsgDeliverInfo(conId:String,msgId: String,userId: String, updatedAt: Double) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(LastMessageDB.self).filter(NSPredicate(format: "conversationId == %@", (conId )))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    
                    taskToUpdate.first?.deliveredTo.removeAll()
                    
                    let deliverObj = MessageDeliveryStatusDB()
                    deliverObj.userId = userId
                    deliverObj.timestamp = updatedAt
                    
                    taskToUpdate.first?.deliveredTo.append(deliverObj)
                    
                }
            }
        }
    }
    
    //MARK: -  update last message read info
    public func updateLastmsgReadInfo(conId:String,msgId: String,userId: String, updatedAt: Double) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(LastMessageDB.self).filter(NSPredicate(format: "conversationId == %@", (conId )))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    
                    taskToUpdate.first?.readBy.removeAll()
                    
                    let deliverObj = MessageDeliveryStatusDB()
                    deliverObj.userId = userId
                    deliverObj.timestamp = updatedAt
                    
                    taskToUpdate.first?.readBy.append(deliverObj)
                    
                }
            }
        }
    }
    
    //MARK: -  update last message read
    public func updateLastmsgRead(conId:String,msg: ISMChat_MessageDelivered) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(LastMessageDB.self).filter(NSPredicate(format: "conversationId == %@  AND messageId == %@", (conId ), (msg.messageId ?? "")))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    
                    taskToUpdate.first?.deliveredTo.first?.userId = msg.userId
                    taskToUpdate.first?.deliveredTo.first?.timestamp = msg.updatedAt
                }
            }
        }
    }
    
    
    
    public func updateImageAndNameOfGroup(name : String,image : String,convID: String){
        if let localRealm = localRealm {
            do {
                let taskToUpdate = localRealm.objects(ConversationDB.self).filter(NSPredicate(format: "conversationId == %@", convID))
                guard !taskToUpdate.isEmpty else { return }
                try localRealm.write {
                    taskToUpdate.first?.conversationTitle = name
                    taskToUpdate.first?.conversationImageUrl = image
                }
            } catch {
                print("Error deleting task \(convID) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - CLEAR/DELETE LAST MESSAGE FOR CONVERSATION lIST
    public func clearLastMessageFromConversationList(convID: String){
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(LastMessageDB.self).filter(NSPredicate(format: "conversationId == %@", convID))
                guard !taskToDelete.isEmpty else { return }
                //just delete all except sentAt or it will create date issue in ISMCONVERSATIONVIEW
                try localRealm.write {
                    taskToDelete.first?.body = nil
                    taskToDelete.first?.action = nil
                    taskToDelete.first?.customType = nil
                }
            } catch {
                print("Error deleting task \(convID) to Realm: \(error)")
            }
        }
    }
}
