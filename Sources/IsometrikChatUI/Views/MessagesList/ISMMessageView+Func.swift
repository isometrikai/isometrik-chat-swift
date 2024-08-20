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
    func deleteMultipleMessages(otherUserMessage: Bool, type: ISMChatDeleteMessageType) {
        let messageIds = deleteMessage.map { $0.messageId }
        func handleDeleteCompletion() {
            showDeleteMultipleMessage = false
            realmManager.deleteMessages(msgs: deleteMessage)
            getMessages()
            deleteMessage.removeAll()
        }
        if otherUserMessage {
            handleDeleteCompletion()
        } else {
            viewModel.deleteMsg(messageDeleteType: type, messageId: messageIds, conversationId: conversationID ?? "") {
                handleDeleteCompletion()
            }
        }
    }
    
    //MARK: - DELETE MULTIPLE MESSAGE For Broadcast
    func deleteMultipleBroadcastMessages(otherUserMessage: Bool, type: ISMChatDeleteMessageType) {
        let messageIds = deleteMessage.map { $0.messageId }
        for id in messageIds{
            viewModel.deleteBroadCastMsg(messageDeleteType: type, messageId: id, groupcastId: self.groupCastId ?? "") {
                realmManager.deleteBroadCastMessages(groupcastId: self.groupCastId ?? "", messageId: id)
            }
        }
        showDeleteMultipleMessage = false
        deleteMessage.removeAll()
    }
    
    //MARK: - REPLY MESSAGE
    func replyMessage(message : ISMChatMessage) -> Bool{
        if message.messageType == 2{ //reply
            if ((self.viewModel.allMessages?.contains(where: { msg in
                msg.messageId == message.parentMessageId
            })) != nil),let index = self.viewModel.allMessages?.firstIndex(where: { element in
                element.messageId == message.parentMessageId
            }){
                if let message = viewModel.allMessages{
                    parentMessage = message[index]
                    return true
                }
            }
        }
        return false
    }
    
    //MARK: - ON CHANGE FUNCTIONS
    
    func sendMessageIfDocumentSelected() {
        if viewModel.documentSelectedFromPicker != nil{
            sendMessage(msgType: .document)
            viewModel.documentSelectedFromPicker = nil
        }
    }
    
    func sendMessageIfAudioUrl() {
        if viewModel.audioUrl != nil {
            sendMessage(msgType: .audio)
        }
    }
    
    func sendMessageTypingIndicator() {
        if keyboardFocused {
            //when keyboard is open scroll to last message
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                realmManager.parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
            }
            // when typing send typing indicator
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                viewModel.typingMessageIndicator(conversationId: self.conversationID ?? "")
            }
        }
    }
    
    func sendMessageIfUploadMedia() {
        sendMessage(msgType: .photo)
    }
    
    func sendMessageIfPlaceId() {
        sendMessage(msgType: .location)
    }
    func sendMessageIfGif(){
        sendMessage(msgType: .gif)
    }
    
    //MARK: - ON APPEAR
    func setupOnAppear() {
        viewModel.skip = 0
        executeRepeatly = true
        executeRepeatlyForOfflineMessage = true
    }
    
    //MARK: - CHECK AUDIO PERMISSION
    func checkAudioPermission(){
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            audioPermissionCheck = true
        case AVAudioSession.RecordPermission.denied:
            audioPermissionCheck = false
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    audioPermissionCheck = true
                } else {
                    audioPermissionCheck = false
                }
            })
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
        if networkMonitor.isConnected {
            realmManager.getAllLocalMsgs()
            let group = DispatchGroup()
            for obj in realmManager.localMessages ?? [] {
                group.enter()
                if obj.customType == ISMChatMediaType.Text.value && obj.body != "" {
                    viewModel.sendMessage(messageKind: .text, customType: ISMChatMediaType.Text.value, conversationId: obj.conversationId, message: obj.body, fileName: nil, fileSize: nil, mediaId: nil,objectId: obj.id.description,isGroup: self.isGroup,groupMembers: self.mentionUsers,isBroadCastMessage: self.fromBroadCastFlow,groupcastId: self.groupCastId) { msgId,objId  in
                        realmManager.updateMsgId(objectId: objId, msgId: msgId)
                        if fromBroadCastFlow == true{
                            //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                            NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                        }
                        group.leave()
                    }
                }else if obj.customType == ISMChatMediaType.Location.value {
                    viewModel.sendMessage(messageKind: .location, customType: ISMChatMediaType.Location.value, conversationId: self.conversationID ?? "", message: obj.body, fileName: nil, fileSize: nil, mediaId: nil, placeName: obj.placeName,isBroadCastMessage: self.fromBroadCastFlow,groupcastId: self.groupCastId) { msgId,objId in
                        realmManager.updateMsgId(objectId: objId, msgId: msgId)
                        if fromBroadCastFlow == true{
                            //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                            NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                        }
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main) {
                self.getMessages()
            }
        }
    }
    
    //MARK: - SEND MESSAGE
    func sendMessage(msgType: ISMChatMessageType) {
        self.text = self.textFieldtxt
        self.textFieldtxt = ""
        if !networkMonitor.isConnected && isGroup == false {
            
            if msgType == .text {
                _ = realmManager.saveLocalMessage(sent: Date().timeIntervalSince1970 * 1000, txt: self.text, parentMessageId: "", initiatorIdentifier: "", conversationId: self.conversationID ?? "", customType: ISMChatMediaType.Text.value, msgSyncStatus: ISMChatSyncStatus.Local.txt)
            }
            self.getMessages()
            self.text = ""
            return
        }
        if self.fromBroadCastFlow == true{
            sendMessageInBroadcast()
        }else if ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == true{
            sendMessageDetail()
        }else{
            if isGroup == false{
                if self.conversationID == nil || self.conversationID == ""{
                    viewModel.createConversation(user: self.opponenDetail ?? UserDB(),profileType: ISMChatSdk.getInstance().getUserSession().getProfileType(),chatStatus: ISMChatStatus.Reject.value) { data in
                        self.conversationID = data?.conversationId
                        viewModel.getConversationDetail(conversationId: self.conversationID ?? "", isGroup: self.isGroup ?? false) { data in
                            //1. first check if conversation is deleted locally
                            realmManager.undodeleteConversation(convID: self.conversationID ?? "")
                            
                            self.conversationDetail = data
                            
                            //2. save conversation locally, no need to call api again
                            let conv = ISMChatConversationsDetail(opponentDetails: self.conversationDetail?.conversationDetails?.opponentDetails, lastMessageDetails: nil, unreadMessagesCount: 0, isGroup: self.conversationDetail?.conversationDetails?.isGroup, membersCount:  self.conversationDetail?.conversationDetails?.membersCount, createdAt:  self.conversationDetail?.conversationDetails?.createdAt, conversationTitle:  self.conversationDetail?.conversationDetails?.conversationTitle, conversationImageUrl:  self.conversationDetail?.conversationDetails?.conversationImageUrl, createdBy:  self.conversationDetail?.conversationDetails?.createdBy, createdByUserName:  self.conversationDetail?.conversationDetails?.createdByUserName, privateOneToOne:  self.conversationDetail?.conversationDetails?.privateOneToOne, conversationId:  self.conversationID ?? "", members: self.conversationDetail?.conversationDetails?.members, config: self.conversationDetail?.conversationDetails?.config,metaData: self.conversationDetail?.conversationDetails?.metaData)
                            realmManager.addConversation(obj: [conv])
                            NotificationCenter.default.post(name: NSNotification.refrestConversationListLocally,object: nil)
                            
                            //3. check if user is not block or your blocked
                            if isMessagingEnabled() == true{
                                sendMessageDetail()
                            }
                        }
                    }
                }else{
                    //check if user is not block or your blocked
                    if isMessagingEnabled() == true{
                        sendMessageDetail()
                    }
                }
            }else{
                sendMessageDetail()
            }
        }
    }
    
    func sendReaction(){
        if let selectedReaction = selectedReaction{
            viewModel.sendReaction(conversationId: self.conversationID ?? "", messageId: self.sentRecationToMessageId, emojiReaction: selectedReaction) { _ in
                //add my reactions here, and for other added in mqtt event
                realmManager.addReactionToMessage(conversationId: self.conversationID ?? "", messageId:  self.sentRecationToMessageId, reaction: selectedReaction, userId: userSession.getUserId() ?? "")
                self.selectedReaction = nil
                realmManager.addLastMessageOnAddAndRemoveReaction(conversationId: self.conversationID ?? "", action: ISMChatActionType.reactionAdd.value, emoji: selectedReaction, userId: userSession.getUserId() ?? "")
                
            }
        }
    }
    
    func sendMessageDetail(){
//        if selectedGIF != nil{
//            if selectedGIF?.isSticker == true{
//                //MARK: - STICKER
//                
//                if let url = selectedGIF?.url(rendition: .fixedWidth, fileType: .gif),let filename = selectedGIF?.description{
//                    
//                    //1. nill data if any
//                    nilData()
//                    
//                    
//                    //2. save message locally
//                    var localIds = [String]()
//                    let id = saveMessageToLocalDB(sentAt: Date().timeIntervalSince1970 * 1000, messageId: "", message: "Sticker", mentionUsers: [], fileName: filename, fileUrl: url, messageType: .sticker,customType: .sticker, messageKind: .normal)
//                    localIds.append(id)
//                    
//                    //3. send message Api
//                    viewModel.sendMessage(messageKind: .sticker, customType: ISMChatMediaType.sticker.value, conversationId: self.conversationID ?? "", message: url, fileName: filename, fileSize: nil, mediaId: nil) {messageId,_  in
//                        
//                        //4. update messageId locally
//                        realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId)
//                        localIds.removeFirst()
//                        
//                    }
//                }
//            }else{
//                //MARK: - GIF
//                if let url = selectedGIF?.url(rendition: .fixedWidth, fileType: .gif),let filename = selectedGIF?.description{
//                    
//                    //1. nill data if any
//                    nilData()
//                    
//                    //2. save message locally
//                    var localIds = [String]()
//                    let sentAt = Date().timeIntervalSince1970 * 1000
//                    
//                    let id = saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: "Gif", mentionUsers: [], fileName: filename, fileUrl: url, messageType: .gif,customType: .gif, messageKind: .normal)
//                    localIds.append(id)
//                    
//                    //3. send message api
//                    viewModel.sendMessage(messageKind: .gif, customType: ISMChatMediaType.gif.value, conversationId: self.conversationID ?? "", message: url, fileName: filename, fileSize: nil, mediaId: nil) {messageId,_  in
//                        
//                        //4. update messageId locally
//                        realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId)
//                        localIds.removeFirst()
//                        
//                    }
//                }
//            }
//        }else 
        if selectedMsgToReply.body != "" {
            //MARK: - REPLY MESSAGE
            let text = self.text
            
            let selectedMsgToReply = self.selectedMsgToReply
            
            
            //1. nill data if any
            nilData()
            
            //2. save message locally
            var localIds = [String]()
            let sentAt = Date().timeIntervalSince1970 * 1000
            let id = saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: text, mentionUsers: [], fileName: "", fileUrl: "", messageType: .text,customType: .ReplyText, messageKind: .reply,parentMessage : selectedMsgToReply)
            localIds.append(id)
            
            //3. reply message api
            viewModel.replyToMessage(customType: ISMChatMediaType.ReplyText.value, conversationId: self.conversationID ?? "", message: text, parentMessage: selectedMsgToReply) { messageId in
                self.text = ""
                
                //4. update messageId locally
                realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId)
                localIds.removeFirst()
                
                
            }
        }else if updateMessage.body != ""{
            //MARK: - UPDATE MESSAGE
            let text = self.text
            viewModel.updateMessage(messageId: updateMessage.messageId , conversationId: updateMessage.conversationId , message: text ) { messageID in
                //update message locally
                realmManager.updateMessageBody(conversationId: updateMessage.conversationId, messageId: updateMessage.messageId, body: text)
                realmManager.updateLastMessageOnEdit(conversationId: updateMessage.conversationId, messageId: updateMessage.messageId, newBody: text)
                self.text = ""
                self.updateMessage = MessagesDB()
                
            }
        }else if shareContact == true{
            //MARK: - CONTACT MESSAGE
            
            let selectedContactToShare = self.selectedContactToShare
            
            //1. nill data if any
            nilData()
            
            //2. save message locally
            var localIds = [String]()
            let sentAt = Date().timeIntervalSince1970 * 1000
            let id = saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: "Contact", mentionUsers: [], fileName: "", fileUrl: "", messageType: .contact,contactInfo: selectedContactToShare,customType: .Contact, messageKind: .normal)
            localIds.append(id)
            
            //3. send message api
            viewModel.sendMessage(messageKind: .contact, customType: ISMChatMediaType.Contact.value, conversationId: self.conversationID ?? "", message: "", fileName: nil, fileSize: nil, mediaId: nil,contactInfo: selectedContactToShare) { messageId, _ in
                
                //4. update messageId locally
                realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId)
                localIds.removeFirst()
                
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
            var localIds = [String]()
            let sentAt = Date().timeIntervalSince1970 * 1000
            let id = saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: msg, mentionUsers: [], fileName: mediaName, fileUrl: "", messageType: messageKind,customType: messageKind == .video ? .Video : .Image, messageKind: .normal)
            localIds.append(id)
            
            
            
            if messageKind == .video , let videoUrl = videoUrl{
                ISMChatHelper.generateThumbnailImageURL(from: videoUrl) { thumbnailUrl in
                    //upload thumbnail image
                    if ISMChatSdk.getInstance().checkuploadOnExternalCDN() == true{
                        self.delegate?.uploadOnExternalCDN(messageKind: .photo, mediaUrl: thumbnailUrl!, completion: { imageURL, _ in
                            self.delegate?.uploadOnExternalCDN(messageKind: .video, mediaUrl: videoUrl, completion: { videoUrl, mediaData in
                                sendMediaMessage(messageKind: messageKind, customType: customType, mediaId: mediaId, mediaName: mediaName, mediaUrl: videoUrl, mediaData: mediaData, thubnailUrl: imageURL, sentAt: sentAt, objectId: localIds.first ?? "")
                                localIds.removeFirst()
                            })
                        })
                    }else{
                    viewModel.upload(messageKind: .photo, conversationId: self.conversationID ?? "", image: thumbnailUrl, document: nil, video: nil, audio: nil, mediaName: "\(UUID()).jpg") { thumbnailmedia, thumbnailfilename, thumbnailsize in
                        //upload video
                        viewModel.upload(messageKind: .video, conversationId: self.conversationID ?? "", image: nil, document: nil, video: videoUrl, audio: nil, mediaName: mediaName) {  data, filename, size in
                            if let dataValue = data {
                                sendMediaMessage(messageKind: messageKind, customType: customType, mediaId: dataValue.mediaId ?? "", mediaName: filename, mediaUrl: data?.mediaUrl ?? "", mediaData: size, thubnailUrl: thumbnailmedia?.mediaUrl ?? "", sentAt: sentAt, objectId: localIds.first ?? "")
                                localIds.removeFirst()
//                                viewModel.sendMessage(messageKind: messageKind, customType: customType, conversationId: self.conversationID ?? "", message: data.mediaUrl ?? "", fileName: filename, fileSize: size, mediaId: data.mediaId,thumbnailUrl: thumbnailmedia?.mediaUrl) {messageId,_ in
//                                    
//                                    //4. update messageId locally
//                                    realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId,mediaUrl: data.mediaUrl ?? "",thumbnailUrl: thumbnailmedia?.mediaUrl,mediaSize: size,mediaId: data.mediaId)
//                                    localIds.removeFirst()
//                                    
//                                    //5. we need to save media
//                                    let attachment = ISMChatAttachment(attachmentType: ISMChatAttachmentType.Video.type, extensions: ISMChatExtensionType.Video.type, mediaUrl: data.mediaUrl ?? "", mimeType: ISMChatExtensionType.Video.type, name: filename, thumbnailUrl: thumbnailmedia?.mediaUrl)
//                                    realmManager.saveMedia(arr: [attachment], conId: self.conversationID ?? "", customType: ISMChatMediaType.Video.value , sentAt: sentAt, messageId: messageId, userName: userSession.getUserName() ?? "", fromView: true)
//                                    
//                                    //6. if we add image or video, we need to save it to show in media
//                                    realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
//                                }
                            }
                        }
                    }
                }
                }
            }else{
                if ISMChatSdk.getInstance().checkuploadOnExternalCDN() == true{
                    self.delegate?.uploadOnExternalCDN(messageKind: .photo, mediaUrl: cameraImage, completion: { imageURL, imageData in
                        sendMediaMessage(messageKind: .photo, customType: ISMChatMediaType.Image.value, mediaId: mediaId, mediaName: mediaName, mediaUrl: imageURL, mediaData: imageData, thubnailUrl: imageURL, sentAt: sentAt, objectId: localIds.first ?? "")
                        localIds.removeFirst()
                    })
                }else{
                    viewModel.upload(messageKind: .photo, conversationId: self.conversationID ?? "", image: cameraImage, document: nil, video: nil, audio: nil, mediaName: mediaName) {  data, filename, size in
                        if let data = data {
                            sendMediaMessage(messageKind: .photo, customType: ISMChatMediaType.Image.value, mediaId: data.mediaId ?? "", mediaName: filename, mediaUrl: data.mediaUrl ?? "", mediaData: size, thubnailUrl: data.mediaUrl ?? "", sentAt: sentAt, objectId: localIds.first ?? "")
                            localIds.removeFirst()
                            //                        viewModel.sendMessage(messageKind: .photo, customType: ISMChatMediaType.Image.value, conversationId: self.conversationID ?? "", message: data.mediaUrl ?? "", fileName: filename, fileSize: size, mediaId: data.mediaId) {messageId,_  in
                            //
                            //                            //4. update messageId locally
                            //                            realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId,mediaUrl: data.mediaUrl ?? "",mediaSize: size,mediaId: data.mediaId)
                            //                            localIds.removeFirst()
                            //
                            //                            //5. we need to save media
                            //                            let attachment = ISMChatAttachment(attachmentType: ISMChatAttachmentType.Image.type, extensions: ISMChatExtensionType.Image.type, mediaUrl: data.mediaUrl ?? "", mimeType: ISMChatExtensionType.Image.type, name: filename, thumbnailUrl: "")
                            //                            realmManager.saveMedia(arr: [attachment], conId: self.conversationID ?? "", customType: ISMChatMediaType.Image.value , sentAt: sentAt, messageId: messageId, userName: userSession.getUserName() ?? "", fromView: true)
                            //
                            //                            //6. if we add image or video, we need to save it to show in media
                            //                            realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
                            //                        }
                        }
                    }
                }
            }
        }else if let documentSelected = viewModel.documentSelectedFromPicker {
            //MARK: - DOCUMENT MESSAGE
            var  messageKind : ISMChatMessageType = .document
            var imageUrl : URL? = nil
            var customType : ISMChatMediaType = .File
            var mediaName : String = ""
            var attachment : ISMChatAttachmentType = .Document
            var extensionType : ISMChatExtensionType = .Document
            let mediaId = "\(UUID())"
            
            if let urlextension = ISMChatHelper.getExtensionFromURL(url: documentSelected){
                if urlextension.contains("png") || urlextension.contains("jpg") || urlextension.contains("jpeg")  || urlextension.contains("heic"){
                    messageKind = .photo
                    customType = .Image
                    mediaName = "\(UUID()).jpg"
                    attachment = .Image
                    extensionType = .Image
                }else if urlextension.contains("mp4"){
                    messageKind = .video
                    customType = .Video
                    mediaName = "\(UUID()).mp4"
                    attachment = .Video
                    extensionType = .Video
                }
                else{
                    mediaName = documentSelected.lastPathComponent
                    attachment = .Document
                    extensionType = .Document
                }
                imageUrl = documentSelected
            }
            
            //1. nill data if any
            nilData()
            
            //2. save message locally
            var localIds = [String]()
            let sentAt = Date().timeIntervalSince1970 * 1000
            let id = saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: "Document", mentionUsers: [], fileName: mediaName, fileUrl: "", messageType: messageKind,customType: customType, messageKind: .normal)
            localIds.append(id)
            
            
            if ISMChatSdk.getInstance().checkuploadOnExternalCDN() == true{
                self.delegate?.uploadOnExternalCDN(messageKind: messageKind, mediaUrl: documentSelected , completion: { docURL, docData in
                    sendMediaMessage(messageKind: messageKind, customType: customType.value, mediaId: mediaId, mediaName: mediaName, mediaUrl: docURL, mediaData: docData, thubnailUrl: docURL, sentAt: sentAt, objectId: localIds.first ?? "")
                    localIds.removeFirst()
                })
            }else{
                viewModel.upload(messageKind: messageKind, conversationId: self.conversationID ?? "", image: nil, document: documentSelected, video: imageUrl, audio: nil, mediaName: mediaName ,isfromDocument: true) { data, filename, size in
                    if let data = data {
                        
                        sendMediaMessage(messageKind: messageKind, customType: customType.value, mediaId: data.mediaId ?? "", mediaName: filename, mediaUrl: data.mediaUrl ?? "", mediaData: size, thubnailUrl: data.mediaUrl ?? "", sentAt: sentAt, objectId: localIds.first ?? "")
//                        viewModel.sendMessage(messageKind: messageKind, customType: customType.value, conversationId: self.conversationID ?? "", message: data.mediaUrl ?? "", fileName: filename, fileSize: size, mediaId: data.mediaId) {messageId,_  in
//                            
//                            //4. update messageId locally
//                            realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId,mediaUrl: data.mediaUrl ?? "",mediaSize: size,mediaId: data.mediaId)
//                            localIds.removeFirst()
//                            
//                            //5. we need to save media
//                            let attachment = ISMChatAttachment(attachmentType: attachment.type, extensions: extensionType.type, mediaUrl: data.mediaUrl ?? "", mimeType: extensionType.type, name: filename, thumbnailUrl: "")
//                            realmManager.saveMedia(arr: [attachment], conId: self.conversationID ?? "", customType:  customType.value, sentAt: sentAt, messageId: messageId, userName: userSession.getUserName() ?? "", fromView: true)
//                            
//                            //6. if we add image or video, we need to save it to show in media
//                            realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
//                            realmManager.fetchFiles(conId: self.conversationID ?? "")
//                        }
                    }
                }
            }
        } else if let audioUrl = viewModel.audioUrl {
            //MARK: - AUDIO MESSAGE
            
            let mediaName = "\(UUID()).m4a"
            let mediaId = "\(UUID())"
            //1. nill data if any
            nilData()
            
            //2. save message locally
            var localIds = [String]()
            let sentAt = Date().timeIntervalSince1970 * 1000
            let id = saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: "Audio", mentionUsers: [], fileName: mediaName, fileUrl: "", messageType: .audio,customType: .Voice, messageKind: .normal)
            localIds.append(id)
            
            //3. send message api
            
            if ISMChatSdk.getInstance().checkuploadOnExternalCDN() == true{
                self.delegate?.uploadOnExternalCDN(messageKind: .audio, mediaUrl: audioUrl , completion: { audioUrl, audioData in
                    
                    sendMediaMessage(messageKind: .audio, customType: ISMChatMediaType.Voice.value, mediaId: mediaId, mediaName: mediaName, mediaUrl: audioUrl, mediaData: audioData, thubnailUrl: audioUrl, sentAt: sentAt, objectId: localIds.first ?? "")
                    localIds.removeFirst()
                })
            }else{
                viewModel.upload(messageKind: .audio, conversationId: self.conversationID ?? "", image: nil, document: nil, video: nil, audio: audioUrl, mediaName: mediaName) { data, filename, size in
                    if let data = data {
                        
                        sendMediaMessage(messageKind: .audio, customType: ISMChatMediaType.Voice.value, mediaId: mediaId, mediaName: filename, mediaUrl: data.mediaUrl ?? "", mediaData: size, thubnailUrl: data.mediaUrl ?? "", sentAt: sentAt, objectId: localIds.first ?? "")
                        localIds.removeFirst()
//                        viewModel.sendMessage(messageKind: .audio, customType: ISMChatMediaType.Voice.value, conversationId: self.conversationID ?? "", message: data.mediaUrl ?? "", fileName: filename, fileSize: size, mediaId: data.mediaId) {messageId,_ in
//                            
//                            //4. update messageId locally
//                            realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId,mediaUrl: data.mediaUrl ?? "",mediaSize: size,mediaId: data.mediaId)
//                            localIds.removeFirst()
//                            
//                        }
                    }
                }
            }
        } else if !videoSelectedFromPicker.isEmpty {
            // Messages as media
            for media in videoSelectedFromPicker {
                if ISMChatHelper.checkMediaType(media: media.url) == .video{
                    
                    let mediaName = "\(UUID()).mp4"
                    let mediaId = "\(UUID())"
                    
                    //1. nill data if any
                    nilData()
                    
                    //2. save message locally
                    var localIds = [String]()
                    let sentAt = Date().timeIntervalSince1970 * 1000
                    let id = saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: "Video", mentionUsers: [], fileName: mediaName, fileUrl: "", messageType: .video,customType: .Video, messageKind: .normal,mediaCaption: media.caption)
                    localIds.append(id)
                    
                    ISMChatHelper.generateThumbnailImageURL(from: media.url) { thumbnailUrl in
                        
                        if ISMChatSdk.getInstance().checkuploadOnExternalCDN() == true{
                            self.delegate?.uploadOnExternalCDN(messageKind: .photo, mediaUrl: thumbnailUrl! , completion: { imageUrl, imageData in
                                self.delegate?.uploadOnExternalCDN(messageKind: .video, mediaUrl: media.url, completion: { videoUrl, videoData in
                                    sendMediaMessage(messageKind: ISMChatHelper.checkMediaType(media: media.url), customType: ISMChatHelper.checkMediaCustomType(media: media.url), mediaId: mediaId, mediaName: mediaName, mediaUrl: videoUrl, mediaData: videoData, thubnailUrl: imageUrl, sentAt: sentAt, objectId:  localIds.first ?? "")
                                    localIds.removeFirst()
                                })
                            })
                        }else{
                            viewModel.upload(messageKind: .photo, conversationId: self.conversationID ?? "", image: thumbnailUrl, document: nil, video: nil, audio: nil, mediaName: "\(UUID()).jpg") { thumbnailmedia, _, _ in
                                viewModel.upload(messageKind: ISMChatHelper.checkMediaType(media: media.url), conversationId: self.conversationID ?? "", image: nil, document: nil, video: media.url, audio: nil, mediaName:  mediaName) {  data, filename, size in
                                    sendMediaMessage(messageKind: .video, customType: ISMChatHelper.checkMediaCustomType(media: media.url), mediaId: mediaId, mediaName: filename, mediaUrl: data?.mediaUrl ?? "", mediaData: size, thubnailUrl: thumbnailmedia?.mediaUrl ?? "", sentAt: sentAt, objectId:  localIds.first ?? "")
                                    localIds.removeFirst()
                                }
                            }
                            
                        }
                        
                        
                        //upload thumbnail image
//                        viewModel.upload(messageKind: .photo, conversationId: self.conversationID ?? "", image: thumbnailUrl, document: nil, video: nil, audio: nil, mediaName: "\(UUID()).jpg") { thumbnailmedia, thumbnailfilename, thumbnailsize in
//                            //upload video
//                            viewModel.upload(messageKind: ISMChatHelper.checkMediaType(media: media.url), conversationId: self.conversationID ?? "", image: nil, document: nil, video: media.url, audio: nil, mediaName:  mediaName) {  data, filename, size in
//                                if let data = data {
//                                    viewModel.sendMessage(messageKind: ISMChatHelper.checkMediaType(media: media.url), customType: ISMChatHelper.checkMediaCustomType(media: media.url), conversationId: self.conversationID ?? "", message: data.mediaUrl ?? "", fileName: filename, fileSize: size, mediaId: data.mediaId,thumbnailUrl: thumbnailmedia?.mediaUrl,caption: media.caption) {messageId,_ in
//                                        if media == self.videoSelectedFromPicker.last {
//                                            self.videoSelectedFromPicker.removeAll()
//                                        }
//                                        
//                                        //4. update messageId locally
//                                        realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId,mediaUrl: data.mediaUrl ?? "",thumbnailUrl: thumbnailmedia?.mediaUrl,mediaSize: size,mediaId: data.mediaId)
//                                        localIds.removeFirst()
//                                        
//                                        //5. we need to save media
//                                        let attachment = ISMChatAttachment(attachmentType: ISMChatAttachmentType.Video.type, extensions: ISMChatExtensionType.Video.type, mediaUrl: data.mediaUrl ?? "", mimeType: ISMChatExtensionType.Video.type, name: filename, thumbnailUrl: thumbnailmedia?.mediaUrl,caption: media.caption)
//                                        realmManager.saveMedia(arr: [attachment], conId: self.conversationID ?? "", customType: ISMChatMediaType.Video.value , sentAt: sentAt, messageId: messageId, userName: userSession.getUserName() ?? "", fromView: true)
//                                        
//                                        
//                                        //6. if we add image or video, we need to save it to show in media
//                                        realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
//                                        
//                                        
//                                        
//                                    }
//                                }
//                            }
//                        }
                    }
                }else{
                    
                    let mediaName = "\(UUID()).jpg"
                    let mediaId = "\(UUID())"
                    //1. nill data if any
                    nilData()
                    
                    //2. save message locally
                    var localIds = [String]()
                    let sentAt = Date().timeIntervalSince1970 * 1000
                    let id = saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: "Image", mentionUsers: [], fileName: mediaName, fileUrl: "", messageType: .photo,customType: .Image, messageKind: .normal,mediaCaption: media.caption)
                    localIds.append(id)
                    
                    
                    if ISMChatSdk.getInstance().checkuploadOnExternalCDN() == true{
                        self.delegate?.uploadOnExternalCDN(messageKind: .photo, mediaUrl: media.url , completion: { imageUrl, imageData in
                            sendMediaMessage(messageKind: ISMChatHelper.checkMediaType(media: media.url), customType: ISMChatHelper.checkMediaCustomType(media: media.url), mediaId: mediaId, mediaName: mediaName, mediaUrl: imageUrl, mediaData: imageData, thubnailUrl: imageUrl, sentAt: sentAt, objectId: localIds.first ?? "")
                            localIds.removeFirst()
                        })
                    }else{
                        viewModel.upload(messageKind: ISMChatHelper.checkMediaType(media: media.url), conversationId: self.conversationID ?? "", image: nil, document: nil, video: media.url, audio: nil, mediaName: mediaName) {  data, filename, size in
                            if let data = data {
                                sendMediaMessage(messageKind: ISMChatHelper.checkMediaType(media: media.url), customType: ISMChatHelper.checkMediaCustomType(media: media.url), mediaId: mediaId, mediaName: filename, mediaUrl: data.mediaUrl ?? "", mediaData: size, thubnailUrl: data.thumbnailUrl ?? "", sentAt: sentAt, objectId: localIds.first ?? "")
                                localIds.removeFirst()
                                if media == self.videoSelectedFromPicker.last {
                                    self.videoSelectedFromPicker.removeAll()
                                }
//                                viewModel.sendMessage(messageKind: ISMChatHelper.checkMediaType(media: media.url), customType: ISMChatHelper.checkMediaCustomType(media: media.url), conversationId: self.conversationID ?? "", message: data.mediaUrl ?? "", fileName: filename, fileSize: size, mediaId: data.mediaId,caption: media.caption) {messageId,_ in
//                                    if media == self.videoSelectedFromPicker.last {
//                                        self.videoSelectedFromPicker.removeAll()
//                                    }
//                                    
//                                    //4. update messageId locally
//                                    realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId,mediaUrl: data.mediaUrl ?? "",mediaSize: size,mediaId: data.mediaId)
//                                    localIds.removeFirst()
//                                    
//                                    //5. we need to save media
//                                    let attachment = ISMChatAttachment(attachmentType: ISMChatAttachmentType.Image.type, extensions: ISMChatExtensionType.Image.type, mediaUrl: data.mediaUrl ?? "", mimeType: ISMChatExtensionType.Image.type, name: filename, thumbnailUrl: "",caption: media.caption)
//                                    realmManager.saveMedia(arr: [attachment], conId: self.conversationID ?? "", customType: ISMChatMediaType.Image.value , sentAt: sentAt, messageId: messageId, userName: userSession.getUserName() ?? "", fromView: true)
//                                    
//                                    //6. if we add image or video, we need to save it to show in media
//                                    realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
//                                    
//                                    
//                                }
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
            
            //2. save message locally
            var localIds = [String]()
            let id = saveMessageToLocalDB(sentAt: Date().timeIntervalSince1970 * 1000, messageId: "", message: text, mentionUsers: [],fileName: "",fileUrl: "", messageType: .location,customType: .Location, messageKind: .normal,longitude: longitude,latitude: latitude,placeName: name,placeAddress: placeAddress)
            localIds.append(id)
            
            //3. send messaga api
            viewModel.sendMessage(messageKind: .location, customType: ISMChatMediaType.Location.value, conversationId: self.conversationID ?? "", message: text, fileName: nil, fileSize: nil, mediaId: nil,latitude : latitude,longitude: longitude, placeName: name,placeAddress: placeAddress) { msgId,_ in
                
                //4. update messageId locally
                realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: msgId)
                localIds.removeFirst()
                
            }
        } else if self.text.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            // MARK: - TEXT MESSAGE
            if networkMonitor.isConnected {
                
                let text = self.text
                
                //1. nil data if any
                nilData()
                
                //2. save message locally
                var localIds = [String]()
                let sentAt = Date().timeIntervalSince1970 * 1000
                let id = saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: text, mentionUsers: self.mentionUsers,fileName: "",fileUrl: "", messageType: .text,customType: .Text, messageKind: .normal)
                localIds.append(id)
                
                //3. send message api
                viewModel.sendMessage(messageKind: .text, customType: ISMChatMediaType.Text.value, conversationId: self.conversationID ?? "", message: text, fileName: nil, fileSize: nil, mediaId: nil,isGroup: self.isGroup,groupMembers: self.mentionUsers) { msgId,_ in
                    
                    //4. update messageId locally
                    realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: msgId)
                    localIds.removeFirst()
                    
                    //5. if we send url in text, we need to save it to show in media
                    if text.isValidURL{
                        realmManager.fetchLinks(conId: self.conversationID ?? "")
                    }
                    
                }
            }else {
                let id = realmManager.saveLocalMessage(sent: Date().timeIntervalSince1970 * 1000, txt: self.text, parentMessageId: "", initiatorIdentifier: "", conversationId: self.conversationID ?? "", customType: ISMChatMediaType.Text.value, msgSyncStatus: ISMChatSyncStatus.Local.txt)
                realmManager.parentMessageIdToScroll = id ?? ""
                self.getMessages()
                nilData()
            }
        }
    }
    
    
    func sendMediaMessage(messageKind : ISMChatMessageType,customType : String,mediaId : String,mediaName: String,mediaUrl : String,mediaData: Int,thubnailUrl : String,sentAt : Double,objectId : String){
        viewModel.sendMessage(messageKind: messageKind, customType: customType, conversationId: self.conversationID ?? "", message: mediaUrl, fileName: mediaName, fileSize: mediaData, mediaId: mediaId,thumbnailUrl: thubnailUrl) {messageId,_ in
            
            //4. update messageId locally
            realmManager.updateMsgId(objectId: objectId, msgId: messageId,mediaUrl: mediaUrl,thumbnailUrl: thubnailUrl,mediaSize: mediaData,mediaId: mediaId)
            
            //5. we need to save media
            if messageKind != .audio{
                let attachment = ISMChatAttachment(attachmentType: ISMChatAttachmentType.Video.type, extensions: ISMChatExtensionType.Video.type, mediaUrl: mediaUrl, mimeType: ISMChatExtensionType.Video.type, name: mediaName, thumbnailUrl: thubnailUrl)
                realmManager.saveMedia(arr: [attachment], conId: self.conversationID ?? "", customType: customType , sentAt: sentAt, messageId: messageId, userName: userSession.getUserName(), fromView: true)
                
                //6. if we add image or video, we need to save it to show in media
                realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
                if messageKind == .document{
                    realmManager.fetchFiles(conId: self.conversationID ?? "")
                }
            }
        }
    }
    
    func sendMessageInBroadcast(){
//        if selectedGIF != nil{
//            if selectedGIF?.isSticker == true{
//                //MARK: - STICKER
//                
//                if let url = selectedGIF?.url(rendition: .fixedWidth, fileType: .gif),let filename = selectedGIF?.description{
////                    
////                    //1. nill data if any
//                    nilData()
////                    
////                    
////                    //2. save message locally
////                    var localIds = [String]()
////                    let id = saveMessageToLocalDB(sentAt: Date().timeIntervalSince1970 * 1000, messageId: "", message: "Sticker", mentionUsers: [], fileName: filename, fileUrl: url, messageType: .sticker,customType: .sticker, messageKind: .normal)
////                    localIds.append(id)
////                    
//                    //3. send message Api
//                    viewModel.sendMessage(messageKind: .sticker, customType: ISMChatMediaType.sticker.value, conversationId: self.conversationID ?? "", message: url, fileName: filename, fileSize: nil, mediaId: nil,isBroadCastMessage: true,groupcastId: self.groupCastId) {messageId,_  in
//                        reloadBroadCastMessages()
//                        //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
//                        NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
////                        //4. update messageId locally
////                        realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId)
////                        localIds.removeFirst()
//                        
//                    }
//                }
//            }else{
//                //MARK: - GIF
//                if let url = selectedGIF?.url(rendition: .fixedWidth, fileType: .gif),let filename = selectedGIF?.description{
//                    
//                    //1. nill data if any
//                    nilData()
//                    
//                    //2. save message locally
////                    var localIds = [String]()
////                    let sentAt = Date().timeIntervalSince1970 * 1000
////                    
////                    let id = saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: "Gif", mentionUsers: [], fileName: filename, fileUrl: url, messageType: .gif,customType: .gif, messageKind: .normal)
////                    localIds.append(id)
//                    
//                    //3. send message api
//                    viewModel.sendMessage(messageKind: .gif, customType: ISMChatMediaType.gif.value, conversationId: self.conversationID ?? "", message: url, fileName: filename, fileSize: nil, mediaId: nil,isBroadCastMessage: true,groupcastId: self.groupCastId) {messageId,_  in
//                        reloadBroadCastMessages()
//                        //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
//                        NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
//                        //4. update messageId locally
////                        realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId)
////                        localIds.removeFirst()
//                        
//                    }
//                }
//            }
//        }else if shareContact == true{
         if shareContact == true{
            //MARK: - CONTACT MESSAGE
            
            let selectedContactToShare = self.selectedContactToShare
            
            //1. nill data if any
            nilData()
            viewModel.sendMessage(messageKind: .contact, customType: ISMChatMediaType.Contact.value, conversationId: self.conversationID ?? "", message: "", fileName: nil, fileSize: nil, mediaId: nil,contactInfo: selectedContactToShare,isBroadCastMessage: true,groupcastId: self.groupCastId) { messageId, _ in
                reloadBroadCastMessages()
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
            let msg = messageKind == .photo ? "Image" : "Video"
            
            //1. nill data if any
            nilData()
            
            //2. save message locally
//            var localIds = [String]()
//            let sentAt = Date().timeIntervalSince1970 * 1000
//            let id = saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: msg, mentionUsers: [], fileName: mediaName, fileUrl: "", messageType: messageKind,customType: messageKind == .video ? .Video : .Image, messageKind: .normal)
//            localIds.append(id)
            
            
            
            if messageKind == .video , let videoUrl = videoUrl{
                ISMChatHelper.generateThumbnailImageURL(from: videoUrl) { thumbnailUrl in
                    //upload thumbnail image
                    viewModel.upload(messageKind: .photo, conversationId: self.conversationID ?? "", conversationType: (fromBroadCastFlow == true ? 2 : 0), image: thumbnailUrl, document: nil, video: nil, audio: nil, mediaName: "\(UUID()).jpg") { thumbnailmedia, thumbnailfilename, thumbnailsize in
                        //upload video
                        viewModel.upload(messageKind: .video, conversationId: self.conversationID ?? "", conversationType: (fromBroadCastFlow == true ? 2 : 0), image: nil, document: nil, video: videoUrl, audio: nil, mediaName: mediaName) {  data, filename, size in
                            if let data = data {
                                viewModel.sendMessage(messageKind: messageKind, customType: customType, conversationId: self.conversationID ?? "", message: data.mediaUrl ?? "", fileName: filename, fileSize: size, mediaId: data.mediaId,thumbnailUrl: thumbnailmedia?.mediaUrl,isBroadCastMessage: true,groupcastId: self.groupCastId) {messageId,_ in
                                    reloadBroadCastMessages()
                                    //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                                    NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                                    //4. update messageId locally
//                                    realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId,mediaUrl: data.mediaUrl ?? "",thumbnailUrl: thumbnailmedia?.mediaUrl)
//                                    localIds.removeFirst()
                                    
                                    //5. we need to save media
//                                    let attachment = ISMChatAttachment(attachmentType: ISMChatAttachmentType.Video.type, extensions: ISMChatExtensionType.Video.type, mediaUrl: data.mediaUrl ?? "", mimeType: ISMChatExtensionType.Video.type, name: filename, thumbnailUrl: thumbnailmedia?.mediaUrl)
//                                    realmManager.saveMedia(arr: [attachment], conId: self.conversationID ?? "", customType: ISMChatMediaType.Video.value , sentAt: sentAt, messageId: messageId, userName: ChatKeychain.shared.userName ?? "", fromView: true)
//                                    
//                                    //6. if we add image or video, we need to save it to show in media
//                                    realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
                                }
                            }
                        }
                    }
                }
            }else{
                viewModel.upload(messageKind: .photo, conversationId: self.conversationID ?? "", conversationType: (fromBroadCastFlow == true ? 2 : 0), image: cameraImage, document: nil, video: nil, audio: nil, mediaName: mediaName) {  data, filename, size in
                    if let data = data {
                        viewModel.sendMessage(messageKind: .photo, customType: ISMChatMediaType.Image.value, conversationId: self.conversationID ?? "", message: data.mediaUrl ?? "", fileName: filename, fileSize: size, mediaId: data.mediaId,isBroadCastMessage: true,groupcastId: self.groupCastId) {messageId,_  in
                            reloadBroadCastMessages()
                            //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                            NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                            //4. update messageId locally
//                            realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId,mediaUrl: data.mediaUrl ?? "")
//                            localIds.removeFirst()
//                            
//                            //5. we need to save media
//                            let attachment = ISMChatAttachment(attachmentType: ISMChatAttachmentType.Image.type, extensions: ISMChatExtensionType.Image.type, mediaUrl: data.mediaUrl ?? "", mimeType: ISMChatExtensionType.Image.type, name: filename, thumbnailUrl: "")
//                            realmManager.saveMedia(arr: [attachment], conId: self.conversationID ?? "", customType: ISMChatMediaType.Image.value , sentAt: sentAt, messageId: messageId, userName: ChatKeychain.shared.userName ?? "", fromView: true)
//                            
//                            //6. if we add image or video, we need to save it to show in media
//                            realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
                        }
                    }
                }
            }
        }else if let documentSelected = viewModel.documentSelectedFromPicker {
            //MARK: - DOCUMENT MESSAGE
            var  messageKind : ISMChatMessageType = .document
            var imageUrl : URL? = nil
            var customType : ISMChatMediaType = .File
            var mediaName : String = ""
            var attachment : ISMChatAttachmentType = .Document
            var extensionType : ISMChatExtensionType = .Document
            
            if let urlextension = ISMChatHelper.getExtensionFromURL(url: documentSelected){
                if urlextension.contains("png") || urlextension.contains("jpg") || urlextension.contains("jpeg")  || urlextension.contains("heic"){
                    messageKind = .photo
                    customType = .Image
                    mediaName = "\(UUID()).jpg"
                    attachment = .Image
                    extensionType = .Image
                }else if urlextension.contains("mp4"){
                    messageKind = .video
                    customType = .Video
                    mediaName = "\(UUID()).mp4"
                    attachment = .Video
                    extensionType = .Video
                }
                else{
                    mediaName = documentSelected.lastPathComponent
                    attachment = .Document
                    extensionType = .Document
                }
                imageUrl = documentSelected
            }
            
            //1. nill data if any
            nilData()
            
            //2. save message locally
//            var localIds = [String]()
//            let sentAt = Date().timeIntervalSince1970 * 1000
//            let id = saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: "Document", mentionUsers: [], fileName: mediaName, fileUrl: "", messageType: messageKind,customType: customType, messageKind: .normal)
//            localIds.append(id)
//            
//            
            viewModel.upload(messageKind: messageKind, conversationId: self.conversationID ?? "", conversationType: (fromBroadCastFlow == true ? 2 : 0), image: nil, document: documentSelected, video: imageUrl, audio: nil, mediaName: mediaName ,isfromDocument: true) { data, filename, size in
                if let data = data {
                    viewModel.sendMessage(messageKind: messageKind, customType: customType.value, conversationId: self.conversationID ?? "", message: data.mediaUrl ?? "", fileName: filename, fileSize: size, mediaId: data.mediaId,isBroadCastMessage: true,groupcastId: self.groupCastId) {messageId,_  in
                        reloadBroadCastMessages()
                        //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                        NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                        //4. update messageId locally
//                        realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId,mediaUrl: data.mediaUrl ?? "")
//                        localIds.removeFirst()
//                        
//                        //5. we need to save media
//                        let attachment = ISMChatAttachment(attachmentType: attachment.type, extensions: extensionType.type, mediaUrl: data.mediaUrl ?? "", mimeType: extensionType.type, name: filename, thumbnailUrl: "")
//                        realmManager.saveMedia(arr: [attachment], conId: self.conversationID ?? "", customType:  customType.value, sentAt: sentAt, messageId: messageId, userName: ChatKeychain.shared.userName ?? "", fromView: true)
//                        
//                        //6. if we add image or video, we need to save it to show in media
//                        realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
//                        realmManager.fetchFiles(conId: self.conversationID ?? "")
                    }
                }
            }
        } else if let audioUrl = viewModel.audioUrl {
            //MARK: - AUDIO MESSAGE
            
            let mediaName = "\(UUID()).m4a"
            
            //1. nill data if any
            nilData()
            
            //2. save message locally
//            var localIds = [String]()
//            let sentAt = Date().timeIntervalSince1970 * 1000
//            let id = saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: "Audio", mentionUsers: [], fileName: mediaName, fileUrl: "", messageType: .audio,customType: .Voice, messageKind: .normal)
//            localIds.append(id)
            
            //3. send message api
            viewModel.upload(messageKind: .audio, conversationId: self.conversationID ?? "", conversationType: (fromBroadCastFlow == true ? 2 : 0), image: nil, document: nil, video: nil, audio: audioUrl, mediaName: mediaName) { data, filename, size in
                if let data = data {
                    viewModel.sendMessage(messageKind: .audio, customType: ISMChatMediaType.Voice.value, conversationId: self.conversationID ?? "", message: data.mediaUrl ?? "", fileName: filename, fileSize: size, mediaId: data.mediaId,isBroadCastMessage: true,groupcastId: self.groupCastId) {messageId,_ in
                        reloadBroadCastMessages()
                        //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                        NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                        //4. update messageId locally
//                        realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId,mediaUrl: data.mediaUrl ?? "")
//                        localIds.removeFirst()
                        
                    }
                }
            }
        } else if !videoSelectedFromPicker.isEmpty {
            // Messages as media
            for media in videoSelectedFromPicker {
                if ISMChatHelper.checkMediaType(media: media.url) == .video{
                    
                    let mediaName = "\(UUID()).mp4"
                    
                    //1. nill data if any
                    nilData()
                    
                    //2. save message locally
//                    var localIds = [String]()
//                    let sentAt = Date().timeIntervalSince1970 * 1000
//                    let id = saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: "Video", mentionUsers: [], fileName: mediaName, fileUrl: "", messageType: .video,customType: .Video, messageKind: .normal,mediaCaption: media.caption)
//                    localIds.append(id)
                    
                    ISMChatHelper.generateThumbnailImageURL(from: media.url) { thumbnailUrl in
                        //upload thumbnail image
                        viewModel.upload(messageKind: .photo, conversationId: self.conversationID ?? "", conversationType: (fromBroadCastFlow == true ? 2 : 0), image: thumbnailUrl, document: nil, video: nil, audio: nil, mediaName: "\(UUID()).jpg") { thumbnailmedia, thumbnailfilename, thumbnailsize in
                            //upload video
                            viewModel.upload(messageKind: ISMChatHelper.checkMediaType(media: media.url), conversationId: self.conversationID ?? "", conversationType: (fromBroadCastFlow == true ? 2 : 0), image: nil, document: nil, video: media.url, audio: nil, mediaName:  mediaName) {  data, filename, size in
                                if let data = data {
                                    viewModel.sendMessage(messageKind: ISMChatHelper.checkMediaType(media: media.url), customType: ISMChatHelper.checkMediaCustomType(media: media.url), conversationId: self.conversationID ?? "", message: data.mediaUrl ?? "", fileName: filename, fileSize: size, mediaId: data.mediaId,thumbnailUrl: thumbnailmedia?.mediaUrl,caption: media.caption,isBroadCastMessage: true,groupcastId: self.groupCastId) {messageId,_ in
                                        if media == self.videoSelectedFromPicker.last {
                                            self.videoSelectedFromPicker.removeAll()
                                        }
                                        reloadBroadCastMessages()
                                        //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                                        NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                                        //4. update messageId locally
//                                        realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId,mediaUrl: data.mediaUrl ?? "",thumbnailUrl: thumbnailmedia?.mediaUrl)
//                                        localIds.removeFirst()
//                                        
//                                        //5. we need to save media
//                                        let attachment = ISMChatAttachment(attachmentType: ISMChatAttachmentType.Video.type, extensions: ISMChatExtensionType.Video.type, mediaUrl: data.mediaUrl ?? "", mimeType: ISMChatExtensionType.Video.type, name: filename, thumbnailUrl: thumbnailmedia?.mediaUrl,caption: media.caption)
//                                        realmManager.saveMedia(arr: [attachment], conId: self.conversationID ?? "", customType: ISMChatMediaType.Video.value , sentAt: sentAt, messageId: messageId, userName: ChatKeychain.shared.userName ?? "", fromView: true)
//                                        
//                                        
//                                        //6. if we add image or video, we need to save it to show in media
//                                        realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
//                                        
                                        
                                        
                                    }
                                }
                            }
                        }
                    }
                }else{
                    
                    let mediaName = "\(UUID()).jpg"
                    
                    //1. nill data if any
                    nilData()
                    
                    //2. save message locally
//                    var localIds = [String]()
//                    let sentAt = Date().timeIntervalSince1970 * 1000
//                    let id = saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: "Image", mentionUsers: [], fileName: mediaName, fileUrl: "", messageType: .photo,customType: .Image, messageKind: .normal,mediaCaption: media.caption)
//                    localIds.append(id)
                    
                    
                    viewModel.upload(messageKind: ISMChatHelper.checkMediaType(media: media.url), conversationId: self.conversationID ?? "", conversationType: (fromBroadCastFlow == true ? 2 : 0), image: nil, document: nil, video: media.url, audio: nil, mediaName: mediaName) {  data, filename, size in
                        if let data = data {
                            viewModel.sendMessage(messageKind: ISMChatHelper.checkMediaType(media: media.url), customType: ISMChatHelper.checkMediaCustomType(media: media.url), conversationId: self.conversationID ?? "", message: data.mediaUrl ?? "", fileName: filename, fileSize: size, mediaId: data.mediaId,caption: media.caption,isBroadCastMessage: true,groupcastId: self.groupCastId) {messageId,_ in
                                if media == self.videoSelectedFromPicker.last {
                                    self.videoSelectedFromPicker.removeAll()
                                }
                                reloadBroadCastMessages()
                                //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                                NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                                //4. update messageId locally
//                                realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: messageId,mediaUrl: data.mediaUrl ?? "")
//                                localIds.removeFirst()
//                                
//                                //5. we need to save media
//                                let attachment = ISMChatAttachment(attachmentType: ISMChatAttachmentType.Image.type, extensions: ISMChatExtensionType.Image.type, mediaUrl: data.mediaUrl ?? "", mimeType: ISMChatExtensionType.Image.type, name: filename, thumbnailUrl: "",caption: media.caption)
//                                realmManager.saveMedia(arr: [attachment], conId: self.conversationID ?? "", customType: ISMChatMediaType.Image.value , sentAt: sentAt, messageId: messageId, userName: ChatKeychain.shared.userName ?? "", fromView: true)
//                                
//                                //6. if we add image or video, we need to save it to show in media
//                                realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
                                
                                
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
            
            //2. save message locally
//            var localIds = [String]()
//            let id = saveMessageToLocalDB(sentAt: Date().timeIntervalSince1970 * 1000, messageId: "", message: text, mentionUsers: [],fileName: "",fileUrl: "", messageType: .location,customType: .Location, messageKind: .normal,longitude: longitude,latitude: latitude,placeName: name,placeAddress: placeAddress)
//            localIds.append(id)
            
            //3. send messaga api
            viewModel.sendMessage(messageKind: .location, customType: ISMChatMediaType.Location.value, conversationId: self.conversationID ?? "", message: text, fileName: nil, fileSize: nil, mediaId: nil,latitude : latitude,longitude: longitude, placeName: name,placeAddress: placeAddress,isBroadCastMessage: true,groupcastId: self.groupCastId) { msgId,_ in
                reloadBroadCastMessages()
                //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                //4. update messageId locally
//                realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: msgId)
//                localIds.removeFirst()
                
            }
        } else if self.text.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            // MARK: - TEXT MESSAGE
            if networkMonitor.isConnected {
                
                let text = self.text
                
                //1. nil data if any
                nilData()
                
                //2. save message locally
//                var localIds = [String]()
//                let sentAt = Date().timeIntervalSince1970 * 1000
//                let id = saveMessageToLocalDB(sentAt: sentAt, messageId: "", message: text, mentionUsers: self.mentionUsers,fileName: "",fileUrl: "", messageType: .text,customType: .Text, messageKind: .normal)
//                localIds.append(id)
                
                //3. send message api
                viewModel.sendMessage(messageKind: .text, customType: ISMChatMediaType.Text.value, conversationId: self.conversationID ?? "", message: text, fileName: nil, fileSize: nil, mediaId: nil,isGroup: self.isGroup,groupMembers: self.mentionUsers,isBroadCastMessage: true,groupcastId: self.groupCastId) { msgId,_ in
                    reloadBroadCastMessages()
                    //first we will refresh conversation list from here,beoz what if we have send message to user which has not conversation with us, basically to refresh list
                    NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                    //4. update messageId locally
//                    realmManager.updateMsgId(objectId: localIds.first ?? "", msgId: msgId)
//                    localIds.removeFirst()
//                    
//                    //5. if we send url in text, we need to save it to show in media
//                    if text.isValidURL{
//                        realmManager.fetchLinks(conId: self.conversationID ?? "")
//                    }
                    
                }
            }else {
//                let id = realmManager.saveLocalMessage(sent: Date().timeIntervalSince1970 * 1000, txt: self.text, parentMessageId: "", initiatorIdentifier: "", conversationId: self.conversationID ?? "", userEmailId: self.userId ?? "", customType: ISMChatMediaType.Text.value, msgSyncStatus: ISMChatSyncStatus.Local.txt)
//                realmManager.parentMessageIdToScroll = id ?? ""
//                self.getMessages()
//                nilData()
            }
        }
    }
    
    
    func nilData(){
        self.longitude = nil
        self.latitude = nil
        self.placeId = nil
        self.placeAddress = nil
        self.text = ""
        self.viewModel.audioUrl = nil
      //  self.selectedGIF = nil
        self.selectedMsgToReply = MessagesDB()
        self.selectedContactToShare.removeAll()
        self.cameraImageToUse = nil
        self.viewModel.isBusy = false
        self.viewModel.documentSelectedFromPicker = nil
    }
    
    
    
    //MARK: - SAVE TEXT MESSAGE LOCALLY WHEN SEND WITHOUT CALLING API
    
    func saveMessageToLocalDB(sentAt: Double,messageId : String,message : String,mentionUsers : [ISMChatGroupMember],fileName : String? = nil,fileUrl : String? = nil,messageType : ISMChatMessageType,contactInfo: [ISMChatPhoneContact]? = [],customType : ISMChatMediaType,messageKind : ISMChatMessageKind,parentMessage : MessagesDB? = nil,longitude :Double? = nil,latitude : Double? = nil,placeName : String? = nil, placeAddress : String? = nil,mediaCaption : String? = nil) -> String{
        
        //1. senderInfo
        let senderInfo = ISMChatUser(userId: userSession.getUserId(), userName: userSession.getUserName(), userIdentifier: userSession.getEmailId(), userProfileImage: userSession.getUserProfilePicture())
        
        //2. message initialize
        var messageValue = ISMChatMessage()
        
        //3. last message intialize
        var lastMessage = ISMChatLastMessage()
        
        //4. metaData
        var metaData = ISMChatMetaData()
        
        //5. attachment
        var attachment = ISMChatAttachment()
        
        //5. save data according to message type
        switch messageType {
        case .text:
            var mentionedUser : [ISMChatMentionedUser] = []
            
            //1. checking if this is group and if there is any mentioned user in text
            if mentionUsers.count > 0, isGroup == true {
                let mentionPattern = "@([a-zA-Z ]+)"
                
                do {
                    let regex = try NSRegularExpression(pattern: mentionPattern, options: [])
                    let matches = regex.matches(in: message, options: [], range: NSRange(location: 0, length: message.utf16.count))
                    var currentIndex = 0
                    for match in matches {
                        let usernameRange = Range(match.range(at: 1), in: message)!
                        let username = String(message[usernameRange])
                        
                        if mentionUsers.contains(where: { member in
                            if let memberUsername = member.userName {
                                return username.lowercased().contains(memberUsername.lowercased())
                            }
                            return false
                        }) {
                            if let matchedUser = mentionUsers.first(where: { member in
                                if let memberUsername = member.userName {
                                    return username.lowercased().contains(memberUsername.lowercased())
                                }
                                return false
                            }) {
                                mentionedUser.append(ISMChatMentionedUser(wordCount: matchedUser.userName?.components(separatedBy: " ").count ?? 0, userId: matchedUser.userId ?? "", order: currentIndex))
                            }
                        }
                        
                        currentIndex += 1
                    }
                } catch {
                    print("Error in regex pattern")
                }
            }
            
            
            if messageKind == .reply{
                var thumbnailUrl : String = ""
                if parentMessage?.customType == ISMChatMediaType.Video.value{
                    thumbnailUrl = parentMessage?.attachments.first?.thumbnailUrl ?? ""
                }else if parentMessage?.customType == ISMChatMediaType.Location.value{
                    thumbnailUrl = parentMessage?.body ?? ""
                }else{
                    thumbnailUrl = parentMessage?.attachments.first?.mediaUrl ?? ""
                }
                
                let replyParentMessage = ISMChatReplyMessageMetaData(parentMessageId: parentMessage?.messageId, parentMessageBody: parentMessage?.body, parentMessageUserId: parentMessage?.senderInfo?.userId ?? "", parentMessageUserName: parentMessage?.senderInfo?.userName ?? "", parentMessageMessageType: parentMessage?.customType, parentMessageAttachmentUrl: thumbnailUrl, parentMessageInitiator: userSession.getUserId() == parentMessage?.senderInfo?.userId, parentMessagecaptionMessage: parentMessage?.metaData?.captionMessage ?? "")
                
                metaData = ISMChatMetaData(replyMessage: replyParentMessage)
            }
            
        case .gif:
            attachment = ISMChatAttachment(attachmentType: ISMChatAttachmentType.Gif.type, extensions: "", mediaId: "", mediaUrl: fileUrl, name: fileName, thumbnailUrl: fileUrl)
        case .sticker:
            attachment = ISMChatAttachment(attachmentType: ISMChatAttachmentType.Sticker.type, extensions: "", mediaId: "", mediaUrl: fileUrl, name: fileName, thumbnailUrl: fileUrl)
        case .contact:
            var contactsMetaData : [ISMChatContactMetaData] = []
            if let contacts = contactInfo{
                for x in contacts{
                    let value = ISMChatContactMetaData(contactName: x.displayName, contactIdentifier: x.phones?.first?.number, contactImageUrl: x.imageUrl, contactImageData: nil)
                    contactsMetaData.append(value)
                }
            }
            metaData = ISMChatMetaData(contacts: contactsMetaData)
        case .audio:
            attachment = ISMChatAttachment(attachmentType: ISMChatAttachmentType.Audio.type, extensions: ISMChatExtensionType.Audio.type, mediaUrl: fileUrl, mimeType: ISMChatExtensionType.Audio.type, name: fileName, thumbnailUrl: fileUrl)
        case .location:
            attachment = ISMChatAttachment(latitude: latitude,longitude: longitude, title: placeName, address: placeAddress)
        case .photo:
            attachment = ISMChatAttachment(attachmentType: ISMChatAttachmentType.Image.type, extensions: ISMChatExtensionType.Image.type, mediaUrl: "", mimeType: ISMChatExtensionType.Image.type, name: fileName, thumbnailUrl: "")
            if let caption  = mediaCaption, !caption.isEmpty{
                metaData = ISMChatMetaData(captionMessage: caption)
            }
        case .video:
            attachment = ISMChatAttachment(attachmentType: ISMChatAttachmentType.Video.type, extensions: ISMChatExtensionType.Video.type, mediaUrl: "", mimeType: ISMChatExtensionType.Video.type, name: fileName, thumbnailUrl: "")
            if let caption  = mediaCaption, !caption.isEmpty{
                metaData = ISMChatMetaData(captionMessage: caption)
            }
        case .document:
            attachment = ISMChatAttachment(attachmentType: ISMChatAttachmentType.Document.type, extensions: ISMChatExtensionType.Document.type, mediaUrl: "", mimeType: ISMChatExtensionType.Document.type, name: fileName, thumbnailUrl: "")
        default:
            return ""
        }
        
        messageValue = ISMChatMessage(sentAt: sentAt, body: message, messageId: messageId, metaData: metaData, customType: customType.value, attachment: [attachment], conversationId: self.conversationID ?? "", senderInfo: senderInfo,messageType: messageKind.value)
        
        lastMessage = ISMChatLastMessage(sentAt: sentAt, senderName: userSession.getUserName(), senderIdentifier: userSession.getEmailId(), senderId: userSession.getUserId(), conversationId: self.conversationID ?? "", body: message, messageId: messageId, customType: customType.value)
        
        //6. append in list
        realmManager.saveMessage(obj: [messageValue])
        //7. sort messages by sentTime
        self.getMessages()
        //8. scroll to last message
        realmManager.parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
        //9. update last message of conversationList item too
        realmManager.updateLastmsg(conId: self.conversationID ?? "", msg: lastMessage)
        
        return self.realmManager.messages.last?.last?.id.description ?? ""
        
    }
    
    
    //MARK: - DELETE MESSAGE
    func deleteMsgFromView(message:MessagesDB) {
        if deleteMessage.contains(where: { msg in
            msg.messageId == message.messageId
        }) {
            deleteMessage.removeAll(where: { $0.messageId == message.messageId })
        } else {
            deleteMessage.append(message)
        }
    }
    
    //MARK: - FORWARD MESSAGE
    func forwardMessageView(message:MessagesDB) {
        if forwardMessageSelected.contains(where: { msg in
            msg.messageId == message.messageId
        }) {
            forwardMessageSelected.removeAll(where: { $0.messageId == message.messageId })
        } else {
            forwardMessageSelected.append(message)
        }
    }
    
    
    //MARK: - SCROLL TO PARENT MESSAGE
    func scrollToParentMessage(message : MessagesDB,scrollReader : ScrollViewProxy){
        if message.customType == ISMChatMediaType.ReplyText.value{
            if message.metaData?.replyMessage?.parentMessageId != ""{
                let id = getMatchingId(parentMessageId: message.metaData?.replyMessage?.parentMessageId ?? "",messages: realmManager.allMessages ?? [])
                if id != ""{
                    scrollTo(messageId: id, anchor: .center, shouldAnimate: true, scrollReader: scrollReader)
                }
            }
        }
    }
    
    func getMatchingId(parentMessageId: String,messages: [MessagesDB]) -> String {
        let matchingMessage = messages.first(where: { $0.messageId == parentMessageId })
        return matchingMessage?.id.description ?? ""
    }
    
    //MARK: - CLEAR CHAT
    func clearChat(){
        conversationViewModel.clearChat(conversationId: conversationID ?? "") {
            print("Success")
            self.realmManager.clearMessages()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.realmManager.clearMessages(convID: conversationID ?? "")
            })
        }
    }
    
    //MARK: - BLOCK USER
    func blockChatFromUser(){
        conversationViewModel.blockUnBlockUser(opponentId: self.conversationDetail?.conversationDetails?.opponentDetails?.id ?? "", needToBlock: true) { obj in
            print("Success")
            self.conversationDetail?.conversationDetails?.messagingDisabled = true
            self.delegate?.externalBlockMechanism(appUserId: self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.userId ?? "",block: true)
        }
    }
}
