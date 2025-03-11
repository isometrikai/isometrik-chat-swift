//
//  ISMMessageView+Func.swift
//  ISMChatSdk
//
//  Created by Rasika on 15/04/24.
//

import Foundation
import SwiftUI
import AVFoundation
import IsometrikChat

extension ISMMessageView{
    
    //MARK: - DELETE MULTIPLE MESSAGE
    /// Deletes multiple messages based on the user's selection.
    /// - Parameters:
    ///   - otherUserMessage: A boolean indicating if the message is from another user.
    ///   - type: The type of message deletion.
    func deleteMultipleMessages(otherUserMessage: Bool, type: ISMChatDeleteMessageType) {
        let messageIds = deleteMessage.map { $0.messageId }
        func handleDeleteCompletion() {
            stateViewModel.showDeleteMultipleMessage = false
            stateViewModel.showDeleteSingleMessage = false
//            realmManager.deleteMessages(msgs: deleteMessage,type: type)
            getMessages()
            deleteMessage.removeAll()
        }
        if otherUserMessage {
            handleDeleteCompletion()
        } else {
            chatViewModel.deleteMsg(messageDeleteType: type, messageId: messageIds, conversationId: conversationID ?? "") {
                handleDeleteCompletion()
            }
        }
    }
    
    //MARK: - DELETE MULTIPLE MESSAGE For Broadcast
    /// Deletes multiple broadcast messages.
    /// - Parameters:
    ///   - otherUserMessage: A boolean indicating if the message is from another user.
    ///   - type: The type of message deletion.
    func deleteMultipleBroadcastMessages(otherUserMessage: Bool, type: ISMChatDeleteMessageType) {
        let messageIds = deleteMessage.map { $0.messageId }
        for id in messageIds{
            chatViewModel.deleteBroadCastMsg(messageDeleteType: type, messageId: id, groupcastId: self.groupCastId ?? "") {
//                realmManager.deleteBroadCastMessages(groupcastId: self.groupCastId ?? "", messageId: id)
            }
        }
        stateViewModel.showDeleteMultipleMessage = false
        deleteMessage.removeAll()
    }
    
    //MARK: - REPLY MESSAGE
    /// Replies to a message if it is a reply type.
    /// - Parameter message: The message to reply to.
    /// - Returns: A boolean indicating if the reply was successful.
    func replyMessage(message : ISMChatMessage) -> Bool{
        if message.messageType == 2{ //reply
            if ((self.chatViewModel.allMessages?.contains(where: { msg in
                msg.messageId == message.parentMessageId
            })) != nil),let index = self.chatViewModel.allMessages?.firstIndex(where: { element in
                element.messageId == message.parentMessageId
            }){
                if let message = chatViewModel.allMessages{
                    parentMessage = message[index]
                    return true
                }
            }
        }
        return false
    }
    
    //MARK: - ON CHANGE FUNCTIONS
    
    /// Sends a message if a document is selected from the picker.
    func sendMessageIfDocumentSelected() {
        if chatViewModel.documentSelectedFromPicker != nil{
            Task{
                await sendMessage(msgType: .document)
                chatViewModel.documentSelectedFromPicker = nil
            }
        }
    }
    
    func sendMessageIfAudioUrl() {
        if chatViewModel.audioUrl != nil {
            Task{
                await sendMessage(msgType: .audio)
            }
        }
    }
    
    func sendMessageTypingIndicator() {
        if stateViewModel.keyboardFocused {
            //when keyboard is open scroll to last message
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
            }
            // when typing send typing indicator
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                chatViewModel.typingMessageIndicator(conversationId: self.conversationID ?? "")
            }
        }
    }
    
    func sendMessageIfUploadMedia() {
        Task{
            await sendMessage(msgType: .photo)
        }
    }
    
    func sendMessageIfPlaceId() {
        Task{
            await sendMessage(msgType: .location)
        }
    }
    func sendMessageIfGif(){
        Task{
            await sendMessage(msgType: .gif)
        }
    }
    
    //MARK: - ON APPEAR
    func setupOnAppear() {
        chatViewModel.skip = 0
        stateViewModel.executeRepeatly = true
        stateViewModel.executeRepeatlyForOfflineMessage = true
    }
    
    //MARK: - CHECK AUDIO PERMISSION
    func checkAudioPermission() {
        // Use AVAudioApplication.shared() for checking permission
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            audioPermissionCheck = true
        case .denied:
            audioPermissionCheck = false
        case .undetermined:
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        audioPermissionCheck = true
                    } else {
                        audioPermissionCheck = false
                    }
                }
            }
        default:
            break
        }
    }
    
    //MARK: - MENTIONED STRING
    
    func getMentionedString(inputString : String) -> String{
        if let lastAtIndex = inputString.range(of: "@", options: .backwards)?.upperBound {
            let substringAfterLastAt = String(inputString.suffix(from: lastAtIndex))
            // Remove leading and trailing whitespaces, if any
            let trimmedSubstring = substringAfterLastAt.trimmingCharacters(in: .whitespaces)
            return trimmedSubstring
        }
        return ""
    }
    
    //MARK: - SEND LOCAL MESSAGE
    func sendLocalMsg() {
//        if networkMonitor.isConnected {
//            realmManager.getAllLocalMsgs()
//            let group = DispatchGroup()
//            for obj in realmManager.localMessages ?? [] {
//                group.enter()
//                if obj.customType == ISMChatMediaType.Text.value && obj.body != "" {
//                    chatViewModel.sendMessage(messageKind: .text, customType: ISMChatMediaType.Text.value, conversationId: obj.conversationId, message: obj.body, fileName: nil, fileSize: nil, mediaId: nil,objectId: obj.id.description,isGroup: self.isGroup,groupMembers: self.mentionUsers,isBroadCastMessage: self.fromBroadCastFlow,groupcastId: self.groupCastId) { msgId,objId  in
//                        realmManager.updateMsgId(objectId: objId, msgId: msgId, conversationId: self.conversationID ?? "")
//                        if fromBroadCastFlow == true{
//                            //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
//                            NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
//                        }
//                        group.leave()
//                    }
//                }else if obj.customType == ISMChatMediaType.Location.value {
//                    chatViewModel.sendMessage(messageKind: .location, customType: ISMChatMediaType.Location.value, conversationId: self.conversationID ?? "", message: obj.body, fileName: nil, fileSize: nil, mediaId: nil, placeName: obj.placeName,isBroadCastMessage: self.fromBroadCastFlow,groupcastId: self.groupCastId) { msgId,objId in
//                        realmManager.updateMsgId(objectId: objId, msgId: msgId, conversationId: self.conversationID ?? "")
//                        if fromBroadCastFlow == true{
//                            //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
//                            NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
//                        }
//                        group.leave()
//                    }
//                }
//            }
//            group.notify(queue: .main) {
//                self.getMessages()
//            }
//        }
    }
    
    func clearTextField() {
        textFieldtxt = " " // Temporarily set to a space
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            textFieldtxt = "" // Set back to empty string
        }
    }
    
    //MARK: - SEND MESSAGE
    /// Sends a message based on the message type and current state.
    /// - Parameter msgType: The type of message to send.
    func sendMessage(msgType: ISMChatMessageType) async {
        self.text = self.textFieldtxt
        clearTextField()
        if !networkMonitor.isConnected{
            // save messages locally if internet not connected
//            if msgType == .text {
//                _ = realmManager.saveLocalMessage(sent: Date().timeIntervalSince1970 * 1000, txt: self.text.trimmingCharacters(in: .whitespacesAndNewlines), parentMessageId: "", initiatorIdentifier: "", conversationId: self.conversationID ?? "", customType: ISMChatMediaType.Text.value, msgSyncStatus: ISMChatSyncStatus.Local.txt)
//            }
//            self.getMessages()
//            self.text = ""
//            return
        }else{
            if self.fromBroadCastFlow == true{
                sendMessageInBroadcast()
            }else if ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == true{
                if isMessagingEnabled() {
                    await sendMessageDetail()
                }
            }else{
                if isGroup == false{
                    if self.conversationID == nil || self.conversationID == "" {
                        self.createConversation { _ in
                            // Check if user is not blocked or you're blocked
                            if isMessagingEnabled() {
                                Task {
                                    await sendMessageDetail()
                                }
                            }
                        }
                    } else {
                        // Check if user is not blocked or you're blocked
                        if isMessagingEnabled() {
                            await sendMessageDetail()
                        }
                    }
                }else{
                    if isMessagingEnabled() {
                        await sendMessageDetail()
                    }
                }
            }
        }
    }
    
    func createConversation(completion:@escaping(Bool)->()){
        if let user = self.opponenDetail{
            Task{
                let conversationId = await viewModelNew.createConversation(user: user)
                chatViewModel.getConversationDetail(conversationId: conversationId, isGroup: self.isGroup ?? false) { data in
                    self.conversationDetail = data
                }
                // added this message locally for end to end encryption
                let sentAt = Date().timeIntervalSince1970 * 1000
                let message = ISMChatMessagesDB(messageId: "", sentAt: sentAt, body: "", customType: "", action: ISMChatActionType.conversationCreated.value, conversationId: conversationId)
                await viewModelNew.saveMessages(conversationId: conversationId, messages: [message])
                NotificationCenter.default.post(name: NSNotification.refrestConversationListLocally, object: nil)
            }
            
//            chatViewModel.createConversation(user: user, chatStatus: ISMChatStatus.Reject.value) { data,error  in
//                self.conversationID = data?.conversationId
//                
//                // Ensure that conversationID is not nil or empty before proceeding
//                guard let conversationID = self.conversationID, !conversationID.isEmpty else { return }
//                
//                chatViewModel.getConversationDetail(conversationId: conversationID, isGroup: self.isGroup ?? false) { data in
//                    // First check if conversation is deleted locally
//                    realmManager.undodeleteConversation(convID: conversationID)
//                    
//                    self.conversationDetail = data
//                    
//                    // Check if conversation already exists in Realm to avoid duplicate primary key error
//                    if !realmManager.isConversationExists(conversationID: conversationID) {
//                        // Save conversation locally, no need to call API again
//                        let conv = ISMChatConversationsDetail(
//                            opponentDetails: self.conversationDetail?.conversationDetails?.opponentDetails,
//                            lastMessageDetails: nil,
//                            unreadMessagesCount: 0,
//                            isGroup: self.conversationDetail?.conversationDetails?.isGroup,
//                            membersCount: self.conversationDetail?.conversationDetails?.membersCount,
//                            createdAt: self.conversationDetail?.conversationDetails?.createdAt,
//                            conversationTitle: self.conversationDetail?.conversationDetails?.conversationTitle,
//                            conversationImageUrl: self.conversationDetail?.conversationDetails?.conversationImageUrl,
//                            createdBy: self.conversationDetail?.conversationDetails?.createdBy,
//                            createdByUserName: self.conversationDetail?.conversationDetails?.createdByUserName,
//                            privateOneToOne: self.conversationDetail?.conversationDetails?.privateOneToOne,
//                            conversationId: conversationID,
//                            members: self.conversationDetail?.conversationDetails?.members,
//                            config: self.conversationDetail?.conversationDetails?.config,
//                            metaData: self.conversationDetail?.conversationDetails?.metaData,
//                            metaDataJson: self.conversationDetail?.conversationDetails?.metaDataJson
//                        )
//                        realmManager.addConversation(obj: [conv])
//                        // added this message locally for end to end encryption
//                        let sentAt = Date().timeIntervalSince1970 * 1000
//                        let message = ISMChatMessage(sentAt: sentAt,body: "", messageId: "", customType: "",action: ISMChatActionType.conversationCreated.value,conversationId: conversationID)
//                        realmManager.saveMessage(obj: [message])
//                        NotificationCenter.default.post(name: NSNotification.refrestConversationListLocally, object: nil)
//                        completion(true)
//                    }else{
//                        completion(true)
//                    }
//                    
//                }
//            }
        }
    }
    
    func sendReaction(){
        if let selectedReaction = selectedReaction{
            chatViewModel.sendReaction(conversationId: self.conversationID ?? "", messageId: self.sentRecationToMessageId, emojiReaction: selectedReaction) { _ in
                //add my reactions here, and for other added in mqtt event
//                realmManager.addReactionToMessage(conversationId: self.conversationID ?? "", messageId:  self.sentRecationToMessageId, reaction: selectedReaction, userId: userData?.userId ?? "")
//                self.selectedReaction = nil
//                realmManager.addLastMessageOnAddAndRemoveReaction(conversationId: self.conversationID ?? "", action: ISMChatActionType.reactionAdd.value, emoji: selectedReaction, userId: userData?.userId ?? "")
                
            }
        }
    }
    
    func sendMessageDetail() async{
        if selectedGIF != nil{
            if selectedGIF?.isSticker == true{
                //MARK: - STICKER
                
                if let url = selectedGIF?.url(rendition: .fixedWidth, fileType: .gif),let filename = selectedGIF?.description{
                    let sentAt = Date().timeIntervalSince1970 * 1000
                    let mediaId = "\(UUID())"
                    //1. nill data if any
                    nilData()
                    //2. save message locally
                    var localIds = [UUID]()
                    let id = await saveMessageToLocalDB(sentAt: Date().timeIntervalSince1970 * 1000, messageId: "", message: "Sticker", mentionUsers: [], fileName: filename, fileUrl: url, messageType: .sticker,customType: .sticker, messageKind: .normal)
                    localIds.append(id)
                    sendMediaMessage(messageKind: .sticker, customType: ISMChatMediaType.sticker.value, mediaId: mediaId, mediaName: filename, mediaUrl: url, mediaData: 1, thubnailUrl: url, sentAt: sentAt, objectId: localIds.first ?? UUID(), caption: "")
                    localIds.removeFirst()
                }
            }else{
                //MARK: - GIF
                if let url = selectedGIF?.url(rendition: .fixedWidth, fileType: .gif),let filename = selectedGIF?.description{
                    let sentAt = Date().timeIntervalSince1970 * 1000
                    let mediaId = "\(UUID())"
                    //1. nill data if any
                    nilData()
                    //2. save message locally
                    var localIds = [UUID]()
                    
                    let id = await saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: "Gif", mentionUsers: [], fileName: filename, fileUrl: url, messageType: .gif,customType: .gif, messageKind: .normal)
                    localIds.append(id)
                    sendMediaMessage(messageKind: .gif, customType: ISMChatMediaType.gif.value, mediaId: mediaId, mediaName: filename, mediaUrl: url, mediaData: 1, thubnailUrl: url, sentAt: sentAt, objectId: localIds.first ?? UUID(), caption: "")
                    localIds.removeFirst()
                }
            }
        }else if selectedMsgToReply != nil {
            //MARK: - REPLY MESSAGE
            let text = self.text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let selectedMsgToReply = self.selectedMsgToReply{
                
                
                //1. nill data if any
                nilData()
                
                //2. save message locally
                var localIds = [UUID]()
                let sentAt = Date().timeIntervalSince1970 * 1000
                let id = await saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: text, mentionUsers: [], fileName: "", fileUrl: "", messageType: .text,customType: .ReplyText, messageKind: .reply,parentMessage : selectedMsgToReply)
                localIds.append(id)
                
                //3. reply message api
                chatViewModel.replyToMessage(customType: ISMChatMediaType.ReplyText.value, conversationId: self.conversationID ?? "", message: text, parentMessage: selectedMsgToReply) { messageId in
                    self.text = ""
                    Task {
                        if let objectId = localIds.first {
                            await viewModelNew.updateMessageId(
                                objectId: objectId,
                                msgId: messageId,
                                conversationId: self.conversationID ?? "",
                                mediaUrl: "",
                                thumbnailUrl: "",
                                mediaSize: 0,
                                mediaId: ""
                            )
                            parentMessageIdToScroll = self.viewModelNew.messages.last?.last?.id.description ?? ""
                            localIds.removeFirst()
                        } else {
                            print("⚠️ localIds is empty, breakpoint won't hit.")
                            localIds.removeFirst()
                        }
                    }
                    //4. update messageId locally
                    //                realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId, conversationId: self.conversationID ?? "")
//                    localIds.removeFirst()
                    
                    
                }
            }
        }else if updateMessage != nil{
            //MARK: - UPDATE MESSAGE
            let text = self.text.trimmingCharacters(in: .whitespacesAndNewlines)
            chatViewModel.updateMessage(messageId: updateMessage?.messageId ?? "", conversationId: updateMessage?.conversationId ?? "", message: text ) { messageID in
                //update message locally
                Task{
                    await viewModelNew.updateMessage(conversationId: updateMessage?.conversationId ?? "", messageId: updateMessage?.messageId ?? "", body: text)
                    //                realmManager.updateMessageBody(conversationId: updateMessage.conversationId, messageId: updateMessage.messageId, body: text)
                    //                realmManager.updateLastMessageOnEdit(conversationId: updateMessage.conversationId, messageId: updateMessage.messageId, newBody: text)
                    self.text = ""
                    self.updateMessage = nil
                }
                
            }
        }else if stateViewModel.shareContact == true{
            //MARK: - CONTACT MESSAGE
            
            let selectedContactToShare = self.selectedContactToShare
            
            //1. nill data if any
            nilData()
            
            //2. save message locally
            var localIds = [UUID]()
            let sentAt = Date().timeIntervalSince1970 * 1000
            let id = await saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: "Contact", mentionUsers: [], fileName: "", fileUrl: "", messageType: .contact,contactInfo: selectedContactToShare,customType: .Contact, messageKind: .normal)
            localIds.append(id)
            
            //3. send message api
            chatViewModel.sendMessage(messageKind: .contact, customType: ISMChatMediaType.Contact.value, conversationId: self.conversationID ?? "", message: "", fileName: nil, fileSize: nil, mediaId: nil,contactInfo: selectedContactToShare) { messageId, _ in
                
                //4. update messageId locally
//                realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId, conversationId: self.conversationID ?? "")
//                localIds.removeFirst()
                
                Task {
                    if let objectId = localIds.first {
                        await viewModelNew.updateMessageId(
                            objectId: objectId,
                            msgId: messageId,
                            conversationId: self.conversationID ?? "",
                            mediaUrl: "",
                            thumbnailUrl: "",
                            mediaSize: 0,
                            mediaId: ""
                        )
                        parentMessageIdToScroll = self.viewModelNew.messages.last?.last?.id.description ?? ""
                        localIds.removeFirst()
                    } else {
                        print("⚠️ localIds is empty, breakpoint won't hit.")
                        localIds.removeFirst()
                    }
                }
                
            }
        }else if let cameraImage = cameraImageToUse{
            //MARK: - CAMERA CAPTURED MESSAGE
            
            
            var messageKind : ISMChatMessageType = .photo
            var videoUrl : URL? = nil
            var customType : String = ISMChatMediaType.Image.value
            
            if let urlextension = ISMChatHelper.getExtensionFromURL(url: cameraImage){
                if urlextension.contains("MOV") || urlextension.contains("mov"){
                    messageKind = .video
                    customType = ISMChatMediaType.Video.value
                    videoUrl = cameraImage
                }
            }
            
            let mediaName = messageKind == .photo ? "\(UUID()).jpg" : "\(UUID()).mp4"
            let mediaId = "\(UUID())"
            let msg = messageKind == .photo ? "Image" : "Video"
            
            //1. nill data if any
            nilData()
            
            //2. save message locally
            var localIds = [UUID]()
            let sentAt = Date().timeIntervalSince1970 * 1000
            let id = await saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: msg, mentionUsers: [], fileName: mediaName, fileUrl: "", messageType: messageKind,customType: messageKind == .video ? .Video : .Image, messageKind: .normal)
            localIds.append(id)
            
            
            
            if messageKind == .video , let videoUrl = videoUrl{
                ISMChatHelper.generateThumbnailImageURL(from: videoUrl) { thumbnailUrl in
                    //upload thumbnail image
                    if ISMChatSdk.getInstance().checkuploadOnExternalCDN() == true{
                        self.delegate?.uploadOnExternalCDN(messageKind: .photo, mediaUrl: thumbnailUrl!, completion: { imageURL, _ in
                            self.delegate?.uploadOnExternalCDN(messageKind: .video, mediaUrl: videoUrl, completion: { videoUrl, mediaData in
                                sendMediaMessage(messageKind: messageKind, customType: customType, mediaId: mediaId, mediaName: mediaName, mediaUrl: videoUrl, mediaData: mediaData, thubnailUrl: imageURL, sentAt: sentAt, objectId: localIds.first ?? UUID(), caption: "")
                                localIds.removeFirst()
                            })
                        })
                    }else{
                        chatViewModel.upload(messageKind: .photo, conversationId: self.conversationID ?? "", image: thumbnailUrl, document: nil, video: nil, audio: nil, mediaName: "\(UUID()).jpg") { thumbnailmedia, thumbnailfilename, thumbnailsize in
                        //upload video
                            chatViewModel.upload(messageKind: .video, conversationId: self.conversationID ?? "", image: nil, document: nil, video: videoUrl, audio: nil, mediaName: mediaName) {  data, filename, size in
                            if let dataValue = data {
                                sendMediaMessage(messageKind: messageKind, customType: customType, mediaId: dataValue.mediaId ?? "", mediaName: filename, mediaUrl: data?.mediaUrl ?? "", mediaData: size, thubnailUrl: thumbnailmedia?.mediaUrl ?? "", sentAt: sentAt, objectId: localIds.first ?? UUID(), caption: "")
                                localIds.removeFirst()
                            }
                        }
                    }
                }
                }
            }else{
                if ISMChatSdk.getInstance().checkuploadOnExternalCDN() == true{
                    self.delegate?.uploadOnExternalCDN(messageKind: .photo, mediaUrl: cameraImage, completion: { imageURL, imageData in
                        sendMediaMessage(messageKind: .photo, customType: ISMChatMediaType.Image.value, mediaId: mediaId, mediaName: mediaName, mediaUrl: imageURL, mediaData: imageData, thubnailUrl: imageURL, sentAt: sentAt, objectId: localIds.first ?? UUID(), caption: "")
                        localIds.removeFirst()
                    })
                }else{
                    chatViewModel.upload(messageKind: .photo, conversationId: self.conversationID ?? "", image: cameraImage, document: nil, video: nil, audio: nil, mediaName: mediaName) {  data, filename, size in
                        if let data = data {
                            sendMediaMessage(messageKind: .photo, customType: ISMChatMediaType.Image.value, mediaId: data.mediaId ?? "", mediaName: filename, mediaUrl: data.mediaUrl ?? "", mediaData: size, thubnailUrl: data.thumbnailUrl ?? "", sentAt: sentAt, objectId: localIds.first ?? UUID(), caption: "")
                            localIds.removeFirst()
                        }
                    }
                }
            }
        }else if let documentSelected = chatViewModel.documentSelectedFromPicker {
            //MARK: - DOCUMENT MESSAGE
            var  messageKind : ISMChatMessageType = .document
            var imageUrl : URL? = nil
            var customType : ISMChatMediaType = .File
            var mediaName : String = ""
            let mediaId = "\(UUID())"
            
            if let urlextension = ISMChatHelper.getExtensionFromURL(url: documentSelected){
                if urlextension.contains("png") || urlextension.contains("jpg") || urlextension.contains("jpeg")  || urlextension.contains("heic"){
                    messageKind = .photo
                    customType = .Image
                    mediaName = "\(UUID()).jpg"
                }else if urlextension.contains("mp4"){
                    messageKind = .video
                    customType = .Video
                    mediaName = "\(UUID()).mp4"
                }
                else{
                    mediaName = documentSelected.lastPathComponent
                }
                imageUrl = documentSelected
            }
            
            //1. nill data if any
            nilData()
            
            //2. save message locally
            var localIds = [UUID]()
            let sentAt = Date().timeIntervalSince1970 * 1000
            let id = await saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: "Document", mentionUsers: [], fileName: mediaName, fileUrl: "", messageType: messageKind,customType: customType, messageKind: .normal)
            localIds.append(id)
            
            
            if ISMChatSdk.getInstance().checkuploadOnExternalCDN() == true{
                self.delegate?.uploadOnExternalCDN(messageKind: messageKind, mediaUrl: documentSelected , completion: { docURL, docData in
                    sendMediaMessage(messageKind: messageKind, customType: customType.value, mediaId: mediaId, mediaName: mediaName, mediaUrl: docURL, mediaData: docData, thubnailUrl: docURL, sentAt: sentAt, objectId: localIds.first ?? UUID(), caption: "")
                    localIds.removeFirst()
                })
            }else{
                chatViewModel.upload(messageKind: messageKind, conversationId: self.conversationID ?? "", image: nil, document: documentSelected, video: imageUrl, audio: nil, mediaName: mediaName ,isfromDocument: true) { data, filename, size in
                    if let data = data {
                        
                        sendMediaMessage(messageKind: messageKind, customType: customType.value, mediaId: data.mediaId ?? "", mediaName: filename, mediaUrl: data.mediaUrl ?? "", mediaData: size, thubnailUrl: data.mediaUrl ?? "", sentAt: sentAt, objectId: localIds.first ?? UUID(), caption: "")
                    }
                }
            }
        } else if let audioUrl = chatViewModel.audioUrl {
            //MARK: - AUDIO MESSAGE
            
            let mediaName = "\(UUID()).m4a"
            let mediaId = "\(UUID())"
            //1. nill data if any
            nilData()
            
            //2. save message locally
            var localIds = [UUID]()
            let sentAt = Date().timeIntervalSince1970 * 1000
            let id = await saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: "Audio", mentionUsers: [], fileName: mediaName, fileUrl: audioUrl.absoluteString, messageType: .audio,customType: .Voice, messageKind: .normal)
            localIds.append(id)
            
            //3. send message api
            
            if ISMChatSdk.getInstance().checkuploadOnExternalCDN() == true{
                self.delegate?.uploadOnExternalCDN(messageKind: .audio, mediaUrl: audioUrl , completion: { audioUrl, audioData in
                    
                    sendMediaMessage(messageKind: .audio, customType: ISMChatMediaType.Voice.value, mediaId: mediaId, mediaName: mediaName, mediaUrl: audioUrl, mediaData: audioData, thubnailUrl: audioUrl, sentAt: sentAt, objectId: localIds.first ?? UUID(), caption: "")
                    localIds.removeFirst()
                })
            }else{
                chatViewModel.upload(messageKind: .audio, conversationId: self.conversationID ?? "", image: nil, document: nil, video: nil, audio: audioUrl, mediaName: mediaName) { data, filename, size in
                    if let data = data {
                        
                        sendMediaMessage(messageKind: .audio, customType: ISMChatMediaType.Voice.value, mediaId: mediaId, mediaName: filename, mediaUrl: data.mediaUrl ?? "", mediaData: size, thubnailUrl: data.mediaUrl ?? "", sentAt: sentAt, objectId: localIds.first ?? UUID(), caption: "")
                        localIds.removeFirst()
                    }
                }
            }
        } else if !mediaSelectedFromPicker.isEmpty {
            // Messages as media
            for media in mediaSelectedFromPicker {
                if ISMChatHelper.checkMediaType(media: media.url) == .video{
                    
                    let mediaName = "\(UUID()).mp4"
                    let mediaId = "\(UUID())"
                    
                    //1. nill data if any
                    nilData()
                    
                    //2. save message locally
                    var localIds = [UUID]()
                    let sentAt = Date().timeIntervalSince1970 * 1000
                    
                    
//                    ISMChatHelper.generateThumbnailImageURL(from: media.url) { thumbnailUrl in
//                        
//                        let id = await saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: "Video", mentionUsers: [], fileName: mediaName, fileUrl: "", messageType: .video,customType: .Video, messageKind: .normal,mediaCaption: media.caption,localMediaUrl: media.url.absoluteString,localThumbnailUrl: thumbnailUrl?.absoluteString)
//                        localIds.append(id)
//                        
//                        
//                        if ISMChatSdk.getInstance().checkuploadOnExternalCDN() == true{
//                            self.delegate?.uploadOnExternalCDN(messageKind: .photo, mediaUrl: thumbnailUrl! , completion: { imageUrl, imageData in
//                                self.delegate?.uploadOnExternalCDN(messageKind: .video, mediaUrl: media.url, completion: { videoUrl, videoData in
//                                    sendMediaMessage(messageKind: ISMChatHelper.checkMediaType(media: media.url), customType: ISMChatHelper.checkMediaCustomType(media: media.url), mediaId: mediaId, mediaName: mediaName, mediaUrl: videoUrl, mediaData: videoData, thubnailUrl: imageUrl, sentAt: sentAt, objectId:  localIds.first ?? UUID(), caption: media.caption)
//                                    localIds.removeFirst()
//                                })
//                            })
//                        }else{
//                            chatViewModel.upload(messageKind: .photo, conversationId: self.conversationID ?? "", image: thumbnailUrl, document: nil, video: nil, audio: nil, mediaName: "\(UUID()).jpg") { thumbnailmedia, _, _ in
//                                chatViewModel.upload(messageKind: ISMChatHelper.checkMediaType(media: media.url), conversationId: self.conversationID ?? "", image: nil, document: nil, video: media.url, audio: nil, mediaName:  mediaName) {  data, filename, size in
//                                    sendMediaMessage(messageKind: .video, customType: ISMChatHelper.checkMediaCustomType(media: media.url), mediaId: mediaId, mediaName: filename, mediaUrl: data?.mediaUrl ?? "", mediaData: size, thubnailUrl: thumbnailmedia?.mediaUrl ?? "", sentAt: sentAt, objectId:  localIds.first ?? UUID(), caption: media.caption)
//                                    localIds.removeFirst()
//                                }
//                            }
//                            
//                        }
//                    }
                }else{
                    
                    let mediaName = "\(UUID()).png"
                    let mediaId = "\(UUID())"
                    //1. nill data if any
                    nilData()
                    
                    //2. save message locally
                    var localIds = [UUID]()
                    let sentAt = Date().timeIntervalSince1970 * 1000
                    let id = await saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: "Image", mentionUsers: [], fileName: mediaName, fileUrl: "", messageType: .photo,customType: .Image, messageKind: .normal,mediaCaption: media.caption,localMediaUrl: media.url.absoluteString)
                    localIds.append(id)
                    
                    
                    if ISMChatSdk.getInstance().checkuploadOnExternalCDN() == true{
                        self.delegate?.uploadOnExternalCDN(messageKind: .photo, mediaUrl: media.url , completion: { imageUrl, imageData in
                            sendMediaMessage(messageKind: ISMChatHelper.checkMediaType(media: media.url), customType: ISMChatHelper.checkMediaCustomType(media: media.url), mediaId: mediaId, mediaName: mediaName, mediaUrl: imageUrl, mediaData: imageData, thubnailUrl: imageUrl, sentAt: sentAt, objectId: localIds.first ?? UUID(), caption: media.caption)
                            localIds.removeFirst()
                            if media == self.mediaSelectedFromPicker.last {
                                self.mediaSelectedFromPicker.removeAll()
                            }
                        })
                    }else{
                        chatViewModel.upload(messageKind: ISMChatHelper.checkMediaType(media: media.url), conversationId: self.conversationID ?? "", image: media.url, document: nil, video: nil, audio: nil, mediaName: mediaName) {  data, filename, size in
                            if let data = data {
                                sendMediaMessage(messageKind: ISMChatHelper.checkMediaType(media: media.url), customType: ISMChatHelper.checkMediaCustomType(media: media.url), mediaId: mediaId, mediaName: filename, mediaUrl: data.mediaUrl ?? "", mediaData: size, thubnailUrl: data.thumbnailUrl ?? "", sentAt: sentAt, objectId: localIds.first ?? UUID(), caption: media.caption)
                                localIds.removeFirst()
                                if media == self.mediaSelectedFromPicker.last {
                                    self.mediaSelectedFromPicker.removeAll()
                                }
                            }
                        }
                    }
                }
            }
            mediaSelectedFromPicker.removeAll()
        } else if let placeId = self.placeId, let longitude = self.longitude, let latitude = self.latitude, let name = self.placeName ,let placeAddress = placeAddress{
            //MARK: - LOCATION MESSAGE
            let msg = "https://www.google.com/maps/search/?api=1&map_action=map&query=\(latitude)%2C\(longitude)&query_place_id=\(placeId)"
            let text = msg
            
            //1. nill data if any
            nilData()
            
            //2. save message locally
            var localIds = [UUID]()
            let id = await saveMessageToLocalDB(sentAt: Date().timeIntervalSince1970 * 1000, messageId: "", message: text, mentionUsers: [],fileName: "",fileUrl: "", messageType: .location,customType: .Location, messageKind: .normal,longitude: longitude,latitude: latitude,placeName: name,placeAddress: placeAddress)
            localIds.append(id)
            
            //3. send messaga api
            chatViewModel.sendMessage(messageKind: .location, customType: ISMChatMediaType.Location.value, conversationId: self.conversationID ?? "", message: text, fileName: nil, fileSize: nil, mediaId: nil,latitude : latitude,longitude: longitude, placeName: name,placeAddress: placeAddress) { msgId,_ in
                Task {
                    if let objectId = localIds.first {
                        await viewModelNew.updateMessageId(
                            objectId: objectId,
                            msgId: msgId,
                            conversationId: self.conversationID ?? "",
                            mediaUrl: "",
                            thumbnailUrl: "",
                            mediaSize: 0,
                            mediaId: ""
                        )
                        parentMessageIdToScroll = self.viewModelNew.messages.last?.last?.id.description ?? ""
                        localIds.removeFirst()
                    } else {
                        print("⚠️ localIds is empty, breakpoint won't hit.")
                        localIds.removeFirst()
                    }
                }
                //4. update messageId locally
//                realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: msgId, conversationId: self.conversationID ?? "")
//                localIds.removeFirst()
                
            }
        } else {
            // MARK: - TEXT MESSAGE
            if networkMonitor.isConnected {
                
                let text = self.text.trimmingCharacters(in: .whitespacesAndNewlines)
                if !text.isEmpty{
                    self.text = ""
                    //1. nil data if any
                    nilData()
                    
                    //2. save message locally
                    var localIds = [UUID]()
                    let sentAt = Date().timeIntervalSince1970 * 1000

                    let id = await saveMessageToLocalDB(
                        sentAt: sentAt,
                        messageId: "",
                        message: text,
                        mentionUsers: self.mentionUsers,
                        fileName: "",
                        fileUrl: "",
                        messageType: .text,
                        customType: .Text,
                        messageKind: .normal
                    )

                    if id != UUID() { // Ensure valid ID before appending
                        localIds.append(id)
                        parentMessageIdToScroll = id.description
                    }

                    chatViewModel.sendMessage(
                        messageKind: .text,
                        customType: ISMChatMediaType.Text.value,
                        conversationId: self.conversationID ?? "",
                        message: text,
                        fileName: nil,
                        fileSize: nil,
                        mediaId: nil,
                        isGroup: self.isGroup,
                        groupMembers: self.mentionUsers
                    ) { msgId, _ in
                        Task {
                            if let objectId = localIds.first {
                                await viewModelNew.updateMessageId(
                                    objectId: objectId,
                                    msgId: msgId,
                                    conversationId: self.conversationID ?? "",
                                    mediaUrl: "",
                                    thumbnailUrl: "",
                                    mediaSize: 0,
                                    mediaId: ""
                                )
                                parentMessageIdToScroll = self.viewModelNew.messages.last?.last?.id.description ?? ""
                                localIds.removeFirst()
                            } else {
                                print("⚠️ localIds is empty, breakpoint won't hit.")
                                localIds.removeFirst()
                            }
                        }
                        
                        
                        
                        //5. if we send url in text, we need to save it to show in media
                        if text.isValidURL{
//                            realmManager.fetchLinks(conId: self.conversationID ?? "")
                            delegate?.messageValidUrl(url: text, messageId: msgId, conversationId: self.conversationID ?? ""){ data in
//                                realmManager.updateMessageBody(conversationId: self.conversationID ?? "", messageId: msgId, body: data.body ?? "", metaData: data.metaData,customType: data.customType)
                                Task{
                                    await viewModelNew.updateMessage(conversationId: self.conversationID ?? "", messageId: msgId, body: data.body ?? "", metaData: data.metaData, customType: data.customType)
                                }
                            }
                        }
                        
                    }
                }
            }else {
//                let id = realmManager.saveLocalMessage(sent: Date().timeIntervalSince1970 * 1000, txt: self.text.trimmingCharacters(in: .whitespacesAndNewlines), parentMessageId: "", initiatorIdentifier: "", conversationId: self.conversationID ?? "", customType: ISMChatMediaType.Text.value, msgSyncStatus: ISMChatSyncStatus.Local.txt)
//                parentMessageIdToScroll = id ?? ""
                self.getMessages()
                nilData()
            }
        }
    }
    
    
    func sendMediaMessage(messageKind : ISMChatMessageType,customType : String,mediaId : String,mediaName: String,mediaUrl : String,mediaData: Int,thubnailUrl : String,sentAt : Double,objectId : UUID,caption : String){
        chatViewModel.sendMessage(messageKind: messageKind, customType: customType, conversationId: self.conversationID ?? "", message: mediaUrl, fileName: mediaName, fileSize: mediaData, mediaId: mediaId,thumbnailUrl: thubnailUrl,caption: caption) {messageId,_ in
            
            //4. update messageId locally
            Task{
                await viewModelNew.updateMessageId(objectId: objectId, msgId: messageId, conversationId: self.conversationID ?? "", mediaUrl: mediaUrl, thumbnailUrl: thubnailUrl, mediaSize: mediaData, mediaId: mediaId)
                parentMessageIdToScroll = self.viewModelNew.messages.last?.last?.id.description ?? ""
            }
//            realmManager.updateMsgId(objectId: objectId, msgId: messageId, conversationId: self.conversationID ?? "",mediaUrl: mediaUrl,thumbnailUrl: thubnailUrl,mediaSize: mediaData,mediaId: mediaId)
            
//            parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
            
            //5. we need to save media
            if messageKind != .audio && messageKind != .sticker && messageKind != .gif{
                let attachment = ISMChatAttachment(attachmentType: ISMChatAttachmentType.Video.type, extensions: ISMChatExtensionType.Video.type, mediaUrl: mediaUrl, mimeType: ISMChatExtensionType.Video.type, name: mediaName, thumbnailUrl: thubnailUrl)
//                realmManager.saveMedia(arr: [attachment], conId: self.conversationID ?? "", customType: customType , sentAt: sentAt, messageId: messageId, userName: userData?.userName ?? "", fromView: true)
//                
//                //6. if we add image or video, we need to save it to show in media
//                realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
//                if messageKind == .document{
//                    realmManager.fetchFiles(conId: self.conversationID ?? "")
//                }
            }
        }
    }
    
    func sendMessageInBroadcast(){
        if stateViewModel.shareContact == true{
            //MARK: - CONTACT MESSAGE
            
            let selectedContactToShare = self.selectedContactToShare
            
            //1. nill data if any
            nilData()
            chatViewModel.sendMessage(messageKind: .contact, customType: ISMChatMediaType.Contact.value, conversationId: self.conversationID ?? "", message: "", fileName: nil, fileSize: nil, mediaId: nil,contactInfo: selectedContactToShare,isBroadCastMessage: true,groupcastId: self.groupCastId) { messageId, _ in
//                reloadBroadCastMessages()
                //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                
            }
        }else if let cameraImage = cameraImageToUse{
            //MARK: - CAMERA CAPTURED MESSAGE
            
            
            var messageKind : ISMChatMessageType = .photo
            var videoUrl : URL? = nil
            var customType : String = ISMChatMediaType.Image.value
            
            if let urlextension = ISMChatHelper.getExtensionFromURL(url: cameraImage){
                if urlextension.contains("MOV") || urlextension.contains("mov"){
                    messageKind = .video
                    customType = ISMChatMediaType.Video.value
                    videoUrl = cameraImage
                }
            }
            
            let mediaName = messageKind == .photo ? "\(UUID()).jpg" : "\(UUID()).mp4"
//            let msg = messageKind == .photo ? "Image" : "Video"
            
           
            nilData()
            if messageKind == .video , let videoUrl = videoUrl{
                ISMChatHelper.generateThumbnailImageURL(from: videoUrl) { thumbnailUrl in
                    //upload thumbnail image
                    chatViewModel.upload(messageKind: .photo, conversationId: self.conversationID ?? "", conversationType: (fromBroadCastFlow == true ? 2 : 0), image: thumbnailUrl, document: nil, video: nil, audio: nil, mediaName: "\(UUID()).jpg") { thumbnailmedia, thumbnailfilename, thumbnailsize in
                        //upload video
                        chatViewModel.upload(messageKind: .video, conversationId: self.conversationID ?? "", conversationType: (fromBroadCastFlow == true ? 2 : 0), image: nil, document: nil, video: videoUrl, audio: nil, mediaName: mediaName) {  data, filename, size in
                            if let data = data {
                                chatViewModel.sendMessage(messageKind: messageKind, customType: customType, conversationId: self.conversationID ?? "", message: data.mediaUrl ?? "", fileName: filename, fileSize: size, mediaId: data.mediaId,thumbnailUrl: thumbnailmedia?.mediaUrl,isBroadCastMessage: true,groupcastId: self.groupCastId) {messageId,_ in
//                                    reloadBroadCastMessages()
                                    //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                                    NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                                }
                            }
                        }
                    }
                }
            }else{
                chatViewModel.upload(messageKind: .photo, conversationId: self.conversationID ?? "", conversationType: (fromBroadCastFlow == true ? 2 : 0), image: cameraImage, document: nil, video: nil, audio: nil, mediaName: mediaName) {  data, filename, size in
                    if let data = data {
                        chatViewModel.sendMessage(messageKind: .photo, customType: ISMChatMediaType.Image.value, conversationId: self.conversationID ?? "", message: data.mediaUrl ?? "", fileName: filename, fileSize: size, mediaId: data.mediaId,isBroadCastMessage: true,groupcastId: self.groupCastId) {messageId,_  in
//                            reloadBroadCastMessages()
                            //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                            NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                        }
                    }
                }
            }
        }else if let documentSelected = chatViewModel.documentSelectedFromPicker {
            //MARK: - DOCUMENT MESSAGE
            var  messageKind : ISMChatMessageType = .document
            var imageUrl : URL? = nil
            var customType : ISMChatMediaType = .File
            var mediaName : String = ""
//            var attachment : ISMChatAttachmentType = .Document
//            var extensionType : ISMChatExtensionType = .Document
            
            if let urlextension = ISMChatHelper.getExtensionFromURL(url: documentSelected){
                if urlextension.contains("png") || urlextension.contains("jpg") || urlextension.contains("jpeg")  || urlextension.contains("heic"){
                    messageKind = .photo
                    customType = .Image
                    mediaName = "\(UUID()).jpg"
//                    attachment = .Image
//                    extensionType = .Image
                }else if urlextension.contains("mp4"){
                    messageKind = .video
                    customType = .Video
                    mediaName = "\(UUID()).mp4"
//                    attachment = .Video
//                    extensionType = .Video
                }
                else{
                    mediaName = documentSelected.lastPathComponent
//                    attachment = .Document
//                    extensionType = .Document
                }
                imageUrl = documentSelected
            }
            
            //1. nill data if any
            nilData()
            
//            
//            
            chatViewModel.upload(messageKind: messageKind, conversationId: self.conversationID ?? "", conversationType: (fromBroadCastFlow == true ? 2 : 0), image: nil, document: documentSelected, video: imageUrl, audio: nil, mediaName: mediaName ,isfromDocument: true) { data, filename, size in
                if let data = data {
                    chatViewModel.sendMessage(messageKind: messageKind, customType: customType.value, conversationId: self.conversationID ?? "", message: data.mediaUrl ?? "", fileName: filename, fileSize: size, mediaId: data.mediaId,isBroadCastMessage: true,groupcastId: self.groupCastId) {messageId,_  in
//                        reloadBroadCastMessages()
                        //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                        NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                    }
                }
            }
        } else if let audioUrl = chatViewModel.audioUrl {
            //MARK: - AUDIO MESSAGE
            
            let mediaName = "\(UUID()).m4a"
            
            //1. nill data if any
            nilData()

            //3. send message api
            chatViewModel.upload(messageKind: .audio, conversationId: self.conversationID ?? "", conversationType: (fromBroadCastFlow == true ? 2 : 0), image: nil, document: nil, video: nil, audio: audioUrl, mediaName: mediaName) { data, filename, size in
                if let data = data {
                    chatViewModel.sendMessage(messageKind: .audio, customType: ISMChatMediaType.Voice.value, conversationId: self.conversationID ?? "", message: data.mediaUrl ?? "", fileName: filename, fileSize: size, mediaId: data.mediaId,isBroadCastMessage: true,groupcastId: self.groupCastId) {messageId,_ in
//                        reloadBroadCastMessages()
                        //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                        NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                       
                        
                    }
                }
            }
        } else if !mediaSelectedFromPicker.isEmpty {
            // Messages as media
            for media in mediaSelectedFromPicker {
                if ISMChatHelper.checkMediaType(media: media.url) == .video{
                    
                    let mediaName = "\(UUID()).mp4"
                    
                    //1. nill data if any
                    nilData()
                    
    
                    
                    ISMChatHelper.generateThumbnailImageURL(from: media.url) { thumbnailUrl in
                        //upload thumbnail image
                        chatViewModel.upload(messageKind: .photo, conversationId: self.conversationID ?? "", conversationType: (fromBroadCastFlow == true ? 2 : 0), image: thumbnailUrl, document: nil, video: nil, audio: nil, mediaName: "\(UUID()).jpg") { thumbnailmedia, thumbnailfilename, thumbnailsize in
                            //upload video
                            chatViewModel.upload(messageKind: ISMChatHelper.checkMediaType(media: media.url), conversationId: self.conversationID ?? "", conversationType: (fromBroadCastFlow == true ? 2 : 0), image: nil, document: nil, video: media.url, audio: nil, mediaName:  mediaName) {  data, filename, size in
                                if let data = data {
                                    chatViewModel.sendMessage(messageKind: ISMChatHelper.checkMediaType(media: media.url), customType: ISMChatHelper.checkMediaCustomType(media: media.url), conversationId: self.conversationID ?? "", message: data.mediaUrl ?? "", fileName: filename, fileSize: size, mediaId: data.mediaId,thumbnailUrl: thumbnailmedia?.mediaUrl,caption: media.caption,isBroadCastMessage: true,groupcastId: self.groupCastId) {messageId,_ in
                                        if media == self.mediaSelectedFromPicker.last {
                                            self.mediaSelectedFromPicker.removeAll()
                                        }
//                                        reloadBroadCastMessages()
                                        //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                                        NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                                    }
                                }
                            }
                        }
                    }
                }else{
                    
                    let mediaName = "\(UUID()).jpg"
                    
                    //1. nill data if any
                    nilData()

                    chatViewModel.upload(messageKind: ISMChatHelper.checkMediaType(media: media.url), conversationId: self.conversationID ?? "", conversationType: (fromBroadCastFlow == true ? 2 : 0), image: nil, document: nil, video: media.url, audio: nil, mediaName: mediaName) {  data, filename, size in
                        if let data = data {
                            chatViewModel.sendMessage(messageKind: ISMChatHelper.checkMediaType(media: media.url), customType: ISMChatHelper.checkMediaCustomType(media: media.url), conversationId: self.conversationID ?? "", message: data.mediaUrl ?? "", fileName: filename, fileSize: size, mediaId: data.mediaId,caption: media.caption,isBroadCastMessage: true,groupcastId: self.groupCastId) {messageId,_ in
                                if media == self.mediaSelectedFromPicker.last {
                                    self.mediaSelectedFromPicker.removeAll()
                                }
//                                reloadBroadCastMessages()
                                //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                                NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
   
                            }
                        }
                    }
                }
            }
        } else if let placeId = self.placeId, let longitude = self.longitude, let latitude = self.latitude, let name = self.placeName ,let placeAddress = placeAddress{
            //MARK: - LOCATION MESSAGE
            let msg = "https://www.google.com/maps/search/?api=1&map_action=map&query=\(latitude)%2C\(longitude)&query_place_id=\(placeId)"
            let text = msg
            
            //1. nill data if any
            nilData()
  
            //3. send messaga api
            chatViewModel.sendMessage(messageKind: .location, customType: ISMChatMediaType.Location.value, conversationId: self.conversationID ?? "", message: text, fileName: nil, fileSize: nil, mediaId: nil,latitude : latitude,longitude: longitude, placeName: name,placeAddress: placeAddress,isBroadCastMessage: true,groupcastId: self.groupCastId) { msgId,_ in
//                reloadBroadCastMessages()
                //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                
            }
        } else {
            // MARK: - TEXT MESSAGE
            if networkMonitor.isConnected {
                
                let text = self.text.trimmingCharacters(in: .whitespacesAndNewlines)
                
                //1. nil data if any
                nilData()
 
                //3. send message api
                chatViewModel.sendMessage(messageKind: .text, customType: ISMChatMediaType.Text.value, conversationId: self.conversationID ?? "", message: text, fileName: nil, fileSize: nil, mediaId: nil,isGroup: self.isGroup,groupMembers: self.mentionUsers,isBroadCastMessage: true,groupcastId: self.groupCastId) { msgId,_ in
//                    reloadBroadCastMessages()
                    //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                    NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                
                }
            }else {
//                let id = realmManager.saveLocalMessage(sent: Date().timeIntervalSince1970 * 1000, txt: self.text, parentMessageId: "", initiatorIdentifier: "", conversationId: self.conversationID ?? "", userEmailId: self.userId ?? "", customType: ISMChatMediaType.Text.value, msgSyncStatus: ISMChatSyncStatus.Local.txt)
//                parentMessageIdToScroll = id ?? ""
//                self.getMessages()
//                nilData()
            }
        }
    }
    
    
    func nilData(){
        self.longitude = nil
        self.latitude = nil
        self.placeId = nil
        self.placeName = nil
        self.placeAddress = nil
        self.text = ""
        self.chatViewModel.audioUrl = nil
        self.selectedGIF = nil
        self.selectedMsgToReply = nil
        self.selectedContactToShare.removeAll()
        self.cameraImageToUse = nil
        self.chatViewModel.isBusy = false
        self.chatViewModel.countSec = 0
        self.chatViewModel.timerValue = "0:00"
        self.chatViewModel.documentSelectedFromPicker = nil
    }
    
    
    
    //MARK: - SAVE TEXT MESSAGE LOCALLY WHEN SEND WITHOUT CALLING API
    
    func saveMessageToLocalDB(
        sentAt: Double,
        messageId: String,
        message: String,
        mentionUsers: [ISMChatGroupMember],
        fileName: String? = nil,
        fileUrl: String? = nil,
        messageType: ISMChatMessageType,
        contactInfo: [ISMChatPhoneContact]? = [],
        customType: ISMChatMediaType,
        messageKind: ISMChatMessageKind,
        parentMessage: ISMChatMessagesDB? = nil,
        longitude: Double? = nil,
        latitude: Double? = nil,
        placeName: String? = nil,
        placeAddress: String? = nil,
        mediaCaption: String? = nil,
        localMediaUrl: String? = nil,
        localThumbnailUrl: String? = nil
    ) async -> UUID {
        
        // 1. Sender Info
        let senderInfo = ISMChatUserDB(
            userId: userData?.userId,
            userProfileImageUrl: userData?.userProfileImage,
            userName: userData?.userName,
            userIdentifier: userData?.userEmail
        )
        
        var messageValue: ISMChatMessagesDB?
        var lastMessage: ISMChatLastMessageDB?
        var metaData: ISMChatMetaDataDB?
        var attachment: ISMChatAttachmentDB?
        
        // 2. Handle different message types
        switch messageType {
        case .text:
            var mentionedUser: [ISMChatMentionedUserDB] = []
            
            if mentionUsers.count > 0, isGroup == true {
                let mentionPattern = "@([a-zA-Z ]+)"
                do {
                    let regex = try NSRegularExpression(pattern: mentionPattern, options: [])
                    let matches = regex.matches(in: message, range: NSRange(location: 0, length: message.utf16.count))
                    var currentIndex = 0
                    for match in matches {
                        let usernameRange = Range(match.range(at: 1), in: message)!
                        let username = String(message[usernameRange])
                        
                        if let matchedUser = mentionUsers.first(where: { $0.userName?.lowercased() == username.lowercased() }) {
                            mentionedUser.append(ISMChatMentionedUserDB(
                                wordCount: matchedUser.userName?.components(separatedBy: " ").count ?? 0,
                                userId: matchedUser.userId ?? "",
                                order: currentIndex
                            ))
                        }
                        currentIndex += 1
                    }
                } catch {
                    print("Error in regex pattern")
                }
            }
            
            if messageKind == .reply {
                let thumbnailUrl = parentMessage?.attachments?.first?.thumbnailUrl ?? parentMessage?.body ?? ""
                let replyParentMessage = ISMChatReplyMessageDB(
                    parentMessageId: parentMessage?.messageId ?? "",
                    parentMessageBody: parentMessage?.body ?? "",
                    parentMessageUserId: parentMessage?.senderInfo?.userId ?? "",
                    parentMessageUserName: parentMessage?.senderInfo?.userName ?? "",
                    parentMessageMessageType: parentMessage?.customType,
                    parentMessageAttachmentUrl: thumbnailUrl,
                    parentMessageInitiator: userData?.userId == parentMessage?.senderInfo?.userId,
                    parentMessagecaptionMessage: parentMessage?.metaData?.captionMessage ?? ""
                )
                metaData = ISMChatMetaDataDB(replyMessage: replyParentMessage)
            }
            
        case .gif:
            attachment = ISMChatAttachmentDB(attachmentType: ISMChatAttachmentType.Gif.type, mediaUrl: fileUrl ?? "", name: fileName ?? "", thumbnailUrl: fileUrl ?? "")
            
        case .sticker:
            attachment = ISMChatAttachmentDB(attachmentType: ISMChatAttachmentType.Sticker.type, mediaUrl: fileUrl, name: fileName, thumbnailUrl: fileUrl)
            
        case .contact:
            let contactsMetaData = contactInfo?.map {
                ISMChatContactDB(contactName: $0.displayName, contactIdentifier: $0.phones?.first?.number, contactImageUrl: $0.imageUrl)
            } ?? []
            metaData = ISMChatMetaDataDB(contacts: contactsMetaData)
            
        case .audio:
            attachment = ISMChatAttachmentDB(attachmentType: ISMChatAttachmentType.Audio.type, mediaUrl: fileUrl, mimeType: ISMChatExtensionType.Audio.type, name: fileName, thumbnailUrl: fileUrl)
            
        case .location:
            attachment = ISMChatAttachmentDB(latitude: latitude, longitude: longitude, title: placeName, address: placeAddress)
            
        case .photo:
            attachment = ISMChatAttachmentDB(attachmentType: ISMChatAttachmentType.Image.type, mediaUrl: localMediaUrl, mimeType: ISMChatExtensionType.Image.type, name: fileName, thumbnailUrl: localMediaUrl)
            if let caption = mediaCaption, !caption.isEmpty {
                metaData = ISMChatMetaDataDB(captionMessage: caption)
            }
            
        case .video:
            attachment = ISMChatAttachmentDB(attachmentType: ISMChatAttachmentType.Video.type, mediaUrl: localMediaUrl, mimeType: ISMChatExtensionType.Video.type, name: fileName, thumbnailUrl: localThumbnailUrl)
            if let caption = mediaCaption, !caption.isEmpty {
                metaData = ISMChatMetaDataDB(captionMessage: caption)
            }
            
        case .document:
            attachment = ISMChatAttachmentDB(attachmentType: ISMChatAttachmentType.Document.type, mediaUrl: "", mimeType: ISMChatExtensionType.Document.type, name: fileName, thumbnailUrl: "")
            
        default:
            return UUID()
        }
        
        // 3. Create the message object
        messageValue = ISMChatMessagesDB(
            messageId: messageId,
            sentAt: sentAt,
            senderInfo: senderInfo,
            body: message,
            customType: customType.value,
            action: "",
            messageType: messageKind.value,
            metaData: metaData,
            attachments: attachment != nil ? [attachment!] : [],
            conversationId: self.conversationID ?? "",
            msgSyncStatus: ISMChatSyncStatus.Local.txt
        )
        
        lastMessage = ISMChatLastMessageDB(
            sentAt: sentAt,
            senderName: userData?.userName,
            senderIdentifier: userData?.userEmail,
            senderId: userData?.userId,
            conversationId: self.conversationID ?? "",
            body: message,
            messageId: messageId,
            customType: customType.value
        )
        
        // 4. Save messages and update last message **before returning**
        if let messageValue = messageValue {
            await viewModelNew.saveMessages(conversationId: self.conversationID ?? "", messages: [messageValue])
            
            if let lastMessage = lastMessage {
                await viewModelNew.updateLastmsgInConversation(conversationId: self.conversationID ?? "", lastmsg: lastMessage)
            }
        }
        
        // 5. Return the latest message ID
        return self.viewModelNew.messages.last?.last?.id ?? UUID()
    }
    
    
    //MARK: - DELETE MESSAGE
    func deleteMsgFromView(message:ISMChatMessagesDB) {
        if deleteMessage.contains(where: { msg in
            msg.messageId == message.messageId
        }) {
            deleteMessage.removeAll(where: { $0.messageId == message.messageId })
        } else {
            deleteMessage.append(message)
        }
    }
    
    //MARK: - FORWARD MESSAGE
    func forwardMessageView(message:ISMChatMessagesDB) {
        if forwardMessageSelected.contains(where: { msg in
            msg.messageId == message.messageId
        }) {
            forwardMessageSelected.removeAll(where: { $0.messageId == message.messageId })
        } else {
            forwardMessageSelected.append(message)
        }
    }
    
    
    //MARK: - SCROLL TO PARENT MESSAGE
    func scrollToParentMessage(message : ISMChatMessagesDB,scrollReader : ScrollViewProxy){
        if message.customType == ISMChatMediaType.ReplyText.value{
            if message.metaData?.replyMessage?.parentMessageId != ""{
//                let id = getMatchingId(parentMessageId: message.metaData?.replyMessage?.parentMessageId ?? "",messages: realmManager.allMessages ?? [])
//                if id != ""{
//                    scrollTo(messageId: id, anchor: .center, shouldAnimate: true, scrollReader: scrollReader)
//                }
            }
        }
    }
    
    func getMatchingId(parentMessageId: String,messages: [ISMChatMessagesDB]) -> String {
        let matchingMessage = messages.first(where: { $0.messageId == parentMessageId })
        return matchingMessage?.id.description ?? ""
    }
    
    //MARK: - CLEAR CHAT
    func clearChat() {
        Task {
            await viewModelNew.clearConversationMessages(id: conversationID ?? "")
        }
        
//        conversationViewModel.clearChat(conversationId: conversationID ?? "") {
//            print("Success")
//            self.realmManager.clearMessages()
//            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
//                self.realmManager.clearMessages(convID: conversationID ?? "")
//                self.realmManager.deleteMessagesThroughConvId(convID:  conversationID ?? "")
//                self.realmManager.deleteMediaThroughConversationId(convID: conversationID ?? "")
//                self.realmManager.clearLastMessageFromConversationList(convID: conversationID ?? "")
//            })
//        }
    }
    
    //MARK: - BLOCK USER
    func blockChatFromUser(block : Bool){
        conversationViewModel.blockUnBlockUser(opponentId: self.conversationDetail?.conversationDetails?.opponentDetails?.id ?? "", needToBlock: block) { obj in
            print("Success")
            self.conversationDetail?.conversationDetails?.messagingDisabled = block
            self.delegate?.externalBlockMechanism(appUserId: self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.userId ?? "",block: block)
        }
    }
}
