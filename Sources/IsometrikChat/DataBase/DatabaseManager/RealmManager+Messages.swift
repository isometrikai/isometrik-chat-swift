//
//  RealmManagerMessages.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift


extension RealmManager{
    //MARK: - check if this message already present
    public func doesMessageExistInMessagesDB(conversationId: String, messageId: String) -> Bool {
        if let localRealm = localRealm {
            // Assuming your MessagesDB model has properties like 'conversationId', 'messageId', and 'isDelete'
            let predicate = NSPredicate(format: "conversationId == %@ AND messageId == %@ AND isDelete == %d", conversationId, messageId, false)
            
            let msgsExists = localRealm.objects(MessagesDB.self).filter(predicate)
            return msgsExists.count > 0
        }
        return false
    }
    
    //MARK: - update body of message on edit
    public func updateMessageBody(conversationId : String,messageId : String,body : String){
        if let localRealm = localRealm {
            let messageToUpdate = localRealm.objects(MessagesDB.self).where{$0.conversationId == conversationId && $0.isDelete == false && $0.messageId == messageId}
            try! localRealm.write {
                messageToUpdate.first?.body = body
                messageToUpdate.first?.messageUpdated = true
            }
        }
    }
    
    //MARK: - update message Id for locally added message before api call, for best performance
    public func updateMsgId(objectId: String, msgId: String,mediaUrl : String? = nil,thumbnailUrl : String? = nil) {
        if let localRealm = localRealm {
            do {
                let id = try ObjectId(string: objectId)
                let existingDog = localRealm.object(ofType: MessagesDB.self, forPrimaryKey: id)
                try! localRealm.write {
                    existingDog?.messageId = msgId
                    existingDog?.msgSyncStatus = ISMChatSyncStatus.Synch.txt
                    if let url = mediaUrl{
                        existingDog?.attachments.first?.mediaUrl = url
                    }
                    if let thumbnailUrl = thumbnailUrl{
                        existingDog?.attachments.first?.thumbnailUrl = thumbnailUrl
                    }
                    
                }
            }catch {
                print("ERROR UPDATE")
            }
        }
    }
    
    //MARK: - update delivery status of message
    public func updateDeliveryStatusThroughMsgId(conId: String, msgId: String) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(MessagesDB.self).filter(NSPredicate(format: "conversationId == %@ AND messageId == %@  AND isDelete = %d", (conId),(msgId ), false))
            try! localRealm.write {
                taskToUpdate.first?.deliveredToAll = true
            }
        }
    }
    
    //MARK: - update delivery status of message where deliveredtoall id false
    public func updateAllDeliveryStatus(conId: String) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(MessagesDB.self).where{$0.deliveredToAll == false && $0.conversationId == conId && $0.isDelete == false}
            try! localRealm.write {
                taskToUpdate.forEach{$0.deliveredToAll = true}
            }
        }
    }
    
    //MARK: - update message as deleted
    public func updateMessageAsDeleted(conId: String, messageId: String) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(MessagesDB.self).where{$0.conversationId == conId && $0.isDelete == false && $0.messageId == messageId}
            try! localRealm.write {
                taskToUpdate.first?.deletedMessage = true
            }
        }
    }
    
    //MARK: - manage message list. check if present then update else add.
    public func manageMessagesList(arr: [ISMChatMessage]) {
        if let localRealm = localRealm {
            for obj in arr {
                let taskToUpdate = localRealm.objects(MessagesDB.self).filter(NSPredicate(format: "messageId == %@  AND isDelete = %d", (obj.messageId ?? ""), false))
                if taskToUpdate.isEmpty {
                    saveMessage(obj: [obj])
                }else {
                    // yet to manage update
                    if taskToUpdate.last?.isDelete == false {
                        
                    }
                }
            }
        }
    }
    
    //MARK: - save message locally
    public func saveMessage(obj: [ISMChatMessage]) {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    for value in obj {
                        
                        let obj = MessagesDB()
                        
                        obj.sentAt = (value.sentAt ?? 00)
                        obj.body = value.body ?? ""
                        obj.messageId = value.messageId ?? ""
                        
                        //mentioned user
                        for x in value.mentionedUsers ?? []{
                            let objV = MentionedUserDB()
                            objV.userId = x.userId
                            objV.order = x.order
                            objV.wordCount = x.wordCount
                            obj.mentionedUsers.append(objV)
                        }
                        
                        obj.deliveredToAll = value.deliveredToAll ?? false
                        obj.readByAll = value.readByAll ?? false
                        obj.customType = value.customType ?? ""
                        obj.action = value.action ?? ""
                        obj.messageType = value.messageType ?? 0
                        obj.parentMessageId = value.parentMessageId ?? ""
                        obj.initiatorIdentifier = value.initiatorIdentifier ?? ""
                        obj.initiatorId = value.initiatorId ?? ""
                        obj.initiatorName = value.initiatorName ?? ""
                        obj.conversationId = value.conversationId ?? ""
                        obj.groupcastId = value.groupcastId ?? ""
                        if obj.conversationId.isEmpty{
                            if let groupcastId = obj.groupcastId{
                                obj.conversationId = groupcastId
                            }
                        }
                        obj.msgSyncStatus = ISMChatSyncStatus.Synch.txt
                        obj.userName = value.userName ?? ""
                        obj.userId = value.userId ?? ""
                        obj.userIdentifier = value.userIdentifier ?? ""
                        
                        obj.memberName = value.memberName ?? ""
                        obj.memberId = value.memberId ?? ""
                        obj.memberIdentifier = value.memberIdentifier ?? ""
                        obj.messageUpdated = value.messageUpdated ?? false
                        
                        for x in value.members ?? []{
                            let objV = LastMessageMemberDB()
                            objV.memberProfileImageUrl = x.memberProfileImageUrl
                            objV.memberName = x.memberName
                            objV.memberIdentifier = x.memberIdentifier
                            objV.memberId = x.memberId
                            
                            obj.members.append(objV)
                        }
                        
                        //reaction
                        if let reaction = value.reactions {
                            for x in reaction {
                                // Check if x.value has elements
                                guard !x.value.isEmpty else {
                                    continue // Skip this iteration if x.value is empty
                                }
                                // Create a Reaction object
                                let reactionNew = ReactionDB()
                                reactionNew.reactionType = x.key
                                reactionNew.users.append(objectsIn: x.value)
                                // Add the reaction to yourModel's reactions
                                obj.reactions.append(reactionNew)
                            }
                        }
                        
                        //callkit
                        if let missedByMembers = value.missedByMembers {
                            for x in missedByMembers{
                                obj.missedByMembers.append(x)
                            }
                        }
                        obj.meetingId = value.meetingId
                        if let callDurations = value.callDurations{
                            for x in callDurations{
                                let objV = ISMMeetingDuration()
                                objV.memberId = x.memberId
                                objV.durationInMilliseconds = x.durationInMilliseconds
                                obj.callDurations.append(objV)
                            }
                        }
                        obj.audioOnly = value.audioOnly ?? false
                        obj.autoTerminate = value.autoTerminate ?? false
                        obj.config?.pushNotifications = value.config?.pushNotifications
                        
                        
                        
                        
                        let metaData = MetaDataDB()
                        
                        let replyMessageData = ReplyMessageDB()
                        replyMessageData.parentMessageId = value.metaData?.replyMessage?.parentMessageId
                        replyMessageData.parentMessageBody = value.metaData?.replyMessage?.parentMessageBody
                        replyMessageData.parentMessageUserId = value.metaData?.replyMessage?.parentMessageUserId
                        replyMessageData.parentMessageUserName = value.metaData?.replyMessage?.parentMessageUserName
                        replyMessageData.parentMessageMessageType = value.metaData?.replyMessage?.parentMessageMessageType
                        replyMessageData.parentMessageAttachmentUrl = value.metaData?.replyMessage?.parentMessageAttachmentUrl
                        replyMessageData.parentMessageInitiator = value.metaData?.replyMessage?.parentMessageInitiator
                        replyMessageData.parentMessagecaptionMessage = value.metaData?.replyMessage?.parentMessagecaptionMessage
                        
                        metaData.replyMessage = replyMessageData
                        metaData.locationAddress = value.metaData?.locationAddress
                        metaData.captionMessage = value.metaData?.captionMessage
                        metaData.postId = value.metaData?.postId
                        metaData.isBroadCastMessage = value.metaData?.isBroadCastMessage
                        
                        
                        if let contacts = value.metaData?.contacts{
                            for x in contacts{
                                let contact = ContactDB()
                                contact.contactName = x.contactName
                                contact.contactIdentifier = x.contactIdentifier
                                contact.contactImageUrl = x.contactImageUrl
                                metaData.contacts.append(contact)
                            }
                        }
                        
                        obj.metaData = metaData
                        
                        
                        let user = UserDB()
                        user.lastSeen = value.senderInfo?.lastSeen ?? 00
                        user.online = value.senderInfo?.online
                        user.userId = value.senderInfo?.userId
                        user.userIdentifier = value.senderInfo?.userIdentifier
                        user.userName = value.senderInfo?.userName
                        user.userProfileImageUrl = value.senderInfo?.userProfileImageUrl
                        
                        obj.senderInfo = user
                        
                        for result in value.deliveredTo ?? [] {
                            let deliverObj = MessageDeliveryStatusDB()
                            deliverObj.userId = result.userId
                            deliverObj.timestamp = result.timestamp
                            obj.deliveredTo.append(deliverObj)
                        }
                        
                        for result in value.readBy ?? [] {
                            let readBy = MessageDeliveryStatusDB()
                            readBy.userId = result.userId
                            readBy.timestamp = result.timestamp
                            obj.readBy.append(readBy)
                        }
                        
                        for result in value.attachments ?? []{
                            let attach = AttachmentDB()
                            
                            attach.attachmentType = result.attachmentType ?? 0
                            attach.extensions  = result.extensions ?? ""
                            attach.mediaId  = result.mediaId ?? 0
                            attach.mediaUrl  = result.mediaUrl ?? ""
                            attach.mimeType  = result.mimeType ?? ""
                            attach.name  = result.name ?? ""
                            attach.size  = result.size ?? 0
                            attach.thumbnailUrl  = result.thumbnailUrl ?? ""
                            
                            attach.latitude = result.latitude ?? 0
                            attach.longitude = result.longitude ?? 0
                            attach.title = result.title ?? ""
                            attach.address = result.address ?? ""
                            obj.attachments.append(attach)
                        }
                        
                        localRealm.add(obj)
                        if (value.attachments?.count ?? 0) > 0 ,let msgId = value.messageId ,!msgId.isEmpty{
                            saveMedia(arr: value.attachments ?? [], conId: value.conversationId ?? "", customType: value.customType ?? "",sentAt: (value.sentAt ?? 00),messageId: value.messageId ?? "", userName: value.userName ?? "", fromView: false)
                        }
                    }
                }
            } catch {
                print("Error adding task to Realm: \(error)")
            }
        }
    }
    
    //MARK: - delete selected messages
    public func deleteMessages(msgs:[MessagesDB])  {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    for obj in msgs {
                        obj.deletedMessage = true
                    }
                }
            } catch {
                //                print("Error deleting task \(convID) to Realm: \(error)")
            }
        }
    }
    
    
    //MARK: - hard delete messages
    public func hardDeleteMsgs()  {
        if let localRealm = localRealm {
            do {
                let msgs = localRealm.objects(MessagesDB.self).filter(NSPredicate(format: "isDelete = %d", true))
                guard !msgs.isEmpty else { return }
                try localRealm.write {
                    localRealm.delete(msgs)
                }
            } catch {
                //print("Error deleting task \(convID) to Realm: \(error)")
            }
        }
    }
    
    
    //MARK: - delete all messages in conversationId
    public func clearMessages(convID: String) {
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(MessagesDB.self).filter(NSPredicate(format: "conversationId == %@", convID))
                guard !taskToDelete.isEmpty else { return }
                clearLastMessageFromConversationList(convID: convID)
                try localRealm.write {
                    localRealm.delete(taskToDelete)
                }
            } catch {
                print("Error deleting task \(convID) to Realm: \(error)")
            }
        }
    }
    
    //MARK: - get all messages
    public func getAllMessages() {
        if let localRealm = localRealm {
            allMessages =  Array(localRealm.objects(MessagesDB.self).where{$0.isDelete == false})
        }
    }
    
    //MARK: - get messages throuh conversationId
    public func getMsgsThroughConversationId(conversationId: String) {
        if let localRealm = localRealm {
            let msgs = Array(localRealm.objects(MessagesDB.self).filter(NSPredicate(format: "conversationId == %@ AND isDelete = %d", conversationId, false)))
            //            guard !msgs.isEmpty else { return }
            allMessages =  msgs
        }
    }
    
    //MARK: - get all local messages which are not sent to api yet
    public func getAllLocalMsgs() {
        if let localRealm = localRealm {
            let msgs = Array(localRealm.objects(MessagesDB.self).filter(NSPredicate(format: "msgSyncStatus == %@  AND isDelete = %d", ISMChatSyncStatus.Local.txt, false)))
            //            guard !msgs.isEmpty else { return }
            localMessages =  msgs
        }
    }
    
    //MARK: - save local message
    public func saveLocalMessage(sent:Double, txt: String,parentMessageId: String,initiatorIdentifier: String,conversationId: String,userEmailId:String,customType:String,placeName:String = "",msgSyncStatus:String) -> String? {
        var objId = ""
        if let localRealm = localRealm {
            try! localRealm.write {
                
                let obj = MessagesDB()
                
                obj.sentAt = (sent)
                obj.body = txt
                obj.customType = customType
                obj.action = ""
                obj.messageType = 0
                obj.parentMessageId = parentMessageId
                obj.initiatorIdentifier = initiatorIdentifier
                obj.conversationId = conversationId
                obj.placeName = placeName
                obj.msgSyncStatus = msgSyncStatus
                
                let user = UserDB()
                user.userId = userSession.getUserId()
                user.userIdentifier = userEmailId
                user.userName = userSession.getUserName()
                
                obj.senderInfo = user
                
                localRealm.add(obj)
                
                objId = obj.id.description
                return objId
            }
        }
        return objId
    }
    
    //MARK: - update read status
    public func updateReadStatusThroughMsgId(msgId: String) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(MessagesDB.self).filter(NSPredicate(format: "messageId == %@  AND isDelete = %d", (msgId ), false))
            try! localRealm.write {
                taskToUpdate.first?.readByAll = true
            }
        }
    }
    
    //MARK: - mark all messages as read
    public func updateAllReadStatus(conId: String) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(MessagesDB.self).where{$0.readByAll == false && $0.conversationId == conId && $0.isDelete == false}
            try! localRealm.write {
                taskToUpdate.forEach{$0.readByAll = true}
            }
        }
    }
    
    //MARK: - clear all messages
    public func clearMessages() {
        self.allMessages?.removeAll()
        self.messages.removeAll()
        self.localMessages?.removeAll()
        self.medias?.removeAll()
        self.linksMedia?.removeAll()
        self.filesMedia?.removeAll()
    }
    
    //MARK: - delete all messages for conversationId locally
    public func deleteMessagesThroughConvId(convID: String)  {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(MessagesDB.self).filter(NSPredicate(format: "conversationId == %@", (convID )))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    for x in taskToUpdate{
                        x.isDelete = true
                    }
                }
            }
        }
    }
    
    //MARK: - Add read for all users
    public func addReadByUser(convId:String,messageId:String,userId:String,updatedAt:Double) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(MessagesDB.self).filter(NSPredicate(format: "conversationId == %@ AND messageId == %@", (convId), messageId))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    
                    if taskToUpdate.first?.readBy.contains(where: { msg in msg.userId == userId}) == false {
                        let deliverObj = MessageDeliveryStatusDB()
                        deliverObj.userId = userId
                        deliverObj.timestamp = updatedAt
                        
                        taskToUpdate.first?.readBy.append(deliverObj)
                    }
                }
            }
        }
    }
    
    //MARK: - Add delivered for all users
    public func addDeliveredToUser(convId:String,messageId:String,userId:String,updatedAt:Double) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(MessagesDB.self).filter(NSPredicate(format: "conversationId == %@ AND messageId == %@", (convId), messageId))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    
                    if taskToUpdate.first?.deliveredTo.contains(where: { msg in msg.userId == userId}) == false {
                        let deliverObj = MessageDeliveryStatusDB()
                        deliverObj.userId = userId
                        deliverObj.timestamp = updatedAt
                        
                        taskToUpdate.first?.deliveredTo.append(deliverObj)
                    }
                }
            }
        }
    }
    
    //MARK: - update delivered for all users
    public func updateDeliveredToInAllmsgs(convId:String,userId:String,updatedAt:Double) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(MessagesDB.self).filter(NSPredicate(format: "conversationId == %@", (convId)))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    var arr = [MessagesDB]()
                    for obj in taskToUpdate {
                        if obj.deliveredTo.contains(where: { msg in msg.userId == userId}) == false {
                            arr.append(obj)
                        }
                    }
                    for result in arr {
                        let deliverObj = MessageDeliveryStatusDB()
                        deliverObj.userId = userId
                        deliverObj.timestamp = updatedAt
                        
                        result.deliveredTo.append(deliverObj)
                    }
                }
            }
        }
    }
    
    //MARK: - update read for all users
    public func updateReadbyInAllmsgs(convId:String,userId:String,updatedAt:Double) {
        if let localRealm = localRealm {
            let taskToUpdate = localRealm.objects(MessagesDB.self).filter(NSPredicate(format: "conversationId == %@", (convId)))
            if !taskToUpdate.isEmpty {
                try! localRealm.write {
                    var arr = [MessagesDB]()
                    for obj in taskToUpdate {
                        if obj.readBy.contains(where: { msg in msg.userId == userId}) == false {
                            arr.append(obj)
                        }
                    }
                    for result in arr {
                        let deliverObj = MessageDeliveryStatusDB()
                        deliverObj.userId = userId
                        deliverObj.timestamp = updatedAt
                        
                        result.readBy.append(deliverObj)
                    }
                }
            }
        }
    }
}
