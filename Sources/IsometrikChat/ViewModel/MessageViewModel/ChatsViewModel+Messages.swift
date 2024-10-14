//
//  File.swift
//  
//
//  Created by Rasika Bharati on 30/08/24.
//

import Foundation
import UIKit


extension ChatsViewModel{
    
    //MARK: - get messages
    public func getMessages(refresh : Bool? = nil,conversationId : String,lastMessageTimestamp:String,completion:@escaping(ISMChatMessages?)->()){
        
        let endPoint = ISMChatMessagesEndpoint.getMessages(conversationId: conversationId, lastMessageTimestamp: lastMessageTimestamp)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatMessages, ISMChatNewAPIError>) in
            switch result{
            case .success(let user,_) :
                completion(user)
            case .failure(_) :
                print("Error")
            }
        }
    }
    
    
    //MARK: - update messages
    public func updateMessage(messageId : String,conversationId : String,message : String,completion:@escaping(String)->()){
        var searchTags : [String] = []
        searchTags.append(ISMChatSearchTags.text.value)
        searchTags.append(message)
        let body = ["messageId" : messageId,"conversationId" : conversationId, "body" : message,"searchableTags" : searchTags] as [String : Any]
        
        
        let endPoint = ISMChatMessagesEndpoint.editMessage
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)

        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatSendMsg, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_):
                completion(data.messageId ?? "")
            case .failure(let error):
                ISMChatHelper.print("Get send Message Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    
    
    //MARK: - send Reel
    public func sharePost(user: UserDB,postId : String,postURL : String,postCaption : String,completion:@escaping()->()){
        self.createConversation(user: user,chatStatus: ISMChatStatus.Reject.value) { response,error  in
            self.sendMessage(messageKind: .post, customType: ISMChatMediaType.Post.value, conversationId: response?.conversationId ?? "", message: postURL, fileName: "", fileSize: nil, mediaId: nil,caption: postCaption,postId: postId) { _, _ in
                completion()
            }
        }
    }
    
    public func shareProduct(user: UserDB,productId : String,productUrl : String,productCaption : String,productCategoryId : String,completion:@escaping(Bool)->()){
        self.createConversation(user: user,chatStatus: ISMChatStatus.Reject.value) { response,error  in
            if let error = error{
                completion(false)
            }
            NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
            self.sendMessage(messageKind: .Product, customType: ISMChatMediaType.Product.value, conversationId: response?.conversationId ?? "", message: productUrl, fileName: "", fileSize: nil, mediaId: nil,caption: productCaption,productId: productId,productCategoryId: productCategoryId) { _, _ in
                completion(true)
            }
        }
    }
    
    
    //MARK: - send messages
    public func sendMessage(messageKind : ISMChatMessageType,customType : String,conversationId :  String,message : String,fileName : String?,fileSize : Int?,mediaId : String?,objectId : String? = "",messageType:Int = 0,thumbnailUrl : String? = "",contactInfo: [ISMChatPhoneContact]? = [],latitude : Double? = nil,longitude : Double? = nil,placeName : String? = nil,placeAddress : String? = nil,isGroup : Bool? = false,groupMembers : [ISMChatGroupMember]? = [],caption : String? = nil,isBroadCastMessage : Bool? = false,groupcastId : String? = nil,postId : String? = nil,productId : String? = nil,productCategoryId : String? = nil,completion:@escaping(String, String)->()){
        var searchTags : [String] = []
        var body : [String : Any] = [:]
        var attachmentValue : [String : Any] = [:]
        var metaData : [String : Any] = [:]
        var notificationBody = ""
        var messageInBody = ""
        var mentionedUsers : [[String : Any]] = []
        let deviceId = UniqueIdentifierManager.shared.getUniqueIdentifier()
        switch messageKind {
        case .photo:
            attachmentValue = ["thumbnailUrl": message, "size" : fileSize ?? 0, "name" : fileName ?? "" , "mimeType" : ISMChatExtensionType.Image.type, "mediaUrl" : message, "mediaId" : mediaId ?? "", "extension" : ISMChatExtensionType.Image.type, "attachmentType" : ISMChatAttachmentType.Image.type]
            body["attachments"] = attachmentValue
            notificationBody = "📷 Photo"
            messageInBody = "Image"
            //searchable tags
            searchTags.append(ISMChatSearchTags.photo.value)
            searchTags.append(message)
            if let caption  = caption, !caption.isEmpty{
                metaData = ["captionMessage" : caption]
            }
        case .video:
            attachmentValue = ["thumbnailUrl": thumbnailUrl ?? "", "size" : fileSize ?? 0, "name" : fileName ?? "" , "mimeType" : ISMChatExtensionType.Video.type, "mediaUrl" : message, "mediaId" : mediaId ?? "", "extension" : ISMChatExtensionType.Video.type, "attachmentType" : ISMChatAttachmentType.Video.type]
            body["attachments"] = attachmentValue
            notificationBody = "📹 Video"
            messageInBody = "Video"
            //searchable tags
            searchTags.append(ISMChatSearchTags.video.value)
            searchTags.append(message)
            if let caption  = caption, !caption.isEmpty{
                metaData = ["captionMessage" : caption]
            }
        case .audio:
            attachmentValue = ["thumbnailUrl": message, "size" : fileSize ?? 0, "name" : fileName ?? "" , "mimeType" : ISMChatExtensionType.Audio.type, "mediaUrl" : message, "mediaId" : mediaId ?? "", "extension" : ISMChatExtensionType.Audio.type, "attachmentType" : ISMChatAttachmentType.Audio.type]
            body["attachments"] = attachmentValue
            notificationBody = "🎤 Voice Message"
            messageInBody = "Audio"
            //searchable tags
            searchTags.append(ISMChatSearchTags.audio.value)
            searchTags.append(message)
        case .document:
            attachmentValue = ["thumbnailUrl": message, "size" : fileSize ?? 0, "name" : fileName ?? "" , "mimeType" : ISMChatExtensionType.Document.type, "mediaUrl" : message, "mediaId" : mediaId ?? "", "extension" : ISMChatExtensionType.Document.type, "attachmentType" : ISMChatAttachmentType.Document.type]
            if let documentUrl = URL(string: message){
                let fileName = ISMChatHelper.getFileNameFromURL(url: documentUrl)
                notificationBody = "📄 \(fileName)"
                messageInBody = "Document"
            }
            //searchable tags
            searchTags.append(ISMChatSearchTags.file.value)
            searchTags.append(message)
        case .text:
            //mentionUser
            if let groupMembers = groupMembers, groupMembers.count > 0, isGroup == true {
                let mentionPattern = "@([a-zA-Z ]+)"
                
                do {
                    let regex = try NSRegularExpression(pattern: mentionPattern, options: [])
                    let matches = regex.matches(in: message, options: [], range: NSRange(location: 0, length: message.utf16.count))
                    var currentIndex = 0
                    for match in matches {
                        let usernameRange = Range(match.range(at: 1), in: message)!
                        let username = String(message[usernameRange])
                        
                        if groupMembers.contains(where: { member in
                            if let memberUsername = member.userName {
                                return username.lowercased().contains(memberUsername.lowercased())
                            }
                            return false
                        }) {
                            if let matchedUser = groupMembers.first(where: { member in
                                if let memberUsername = member.userName {
                                    return username.lowercased().contains(memberUsername.lowercased())
                                }
                                return false
                            }) {
                                let userTuple = ["wordCount": matchedUser.userName?.components(separatedBy: " ").count ?? 0,
                                                 "userId": matchedUser.userId ?? "",
                                                 "order": currentIndex] as [String: Any]
                                
                                mentionedUsers.append(userTuple)
                            }
                        }
                        
                        currentIndex += 1  // Increment the position for the next iteration
                    }
                    
                    // Print the mentioned users
                    print("mentionedUsers: \(mentionedUsers)")
                    
                } catch {
                    print("Error in regex pattern")
                }
            }
            
            notificationBody = message
            messageInBody = message
            //searchable tags
            searchTags.append(ISMChatSearchTags.text.value)
            searchTags.append(message)
        case .location:
            if let latitude = latitude, let longitude = longitude, let placeName = placeName,let placeAddress = placeAddress{
                attachmentValue = ["latitude" : latitude, "title": placeName, "longitude" : longitude , "address" : placeAddress,"attachmentType" : ISMChatAttachmentType.Location.type]
                body["attachments"] = [attachmentValue]
            }
            
            messageInBody = message
            if let name = placeName , !name.isEmpty{
                metaData["locationAddress"] = name
                notificationBody = "📍 \(name)"
            }
            //searchable tags
            searchTags.append(ISMChatSearchTags.location.value)
            searchTags.append(message)
        case .contact:
            if contactInfo?.count == 1{
                notificationBody = "👤 \(contactInfo?.first?.displayName ?? "")"
            }else{
                notificationBody = "👤 \(contactInfo?.first?.displayName ?? "") and \((contactInfo?.count ?? 1) - 1) other contact"
            }
            
            //searchable tags
            searchTags.append(ISMChatSearchTags.contact.value)
            searchTags.append(message)
            
            messageInBody = "Contact"
            
            
            var contacts : [[String: Any]] = []
            if let contactInfo = contactInfo{
                for contact in contactInfo {
                    let contactDictionary: [String: Any] = [
                        "contactName": contact.displayName ?? "",
                        "contactIdentifier": contact.phones?.first?.number ?? "",
                        "contactImageUrl": contact.imageUrl ?? ""
                    ]
                    contacts.append(contactDictionary)
                }
            }
            
            metaData = ["contacts" : contacts]
        case .gif:
            attachmentValue = ["thumbnailUrl": message, "attachmentMessageType" : "Gif","attachmentSchemaType" : "GifSticker", "attachmentType" : ISMChatAttachmentType.Gif.type,"mediaUrl" : message,"name" : fileName ?? "", "stillUrl" : message]
            body["attachments"] = attachmentValue
            notificationBody = "Gif"
            messageInBody = "Gif"
            //searchable tags
            searchTags.append(ISMChatSearchTags.gif.value)
            searchTags.append(fileName ?? "")
        case .sticker:
            attachmentValue = ["thumbnailUrl": message, "attachmentMessageType" : "Sticker","attachmentSchemaType" : "GifSticker", "attachmentType" : ISMChatAttachmentType.Sticker.type,"mediaUrl" : message,"name" : fileName ?? "", "stillUrl" : message]
            body["attachments"] = attachmentValue
            notificationBody = "Sticker"
            messageInBody = "Sticker"
            //searchable tags
            searchTags.append(ISMChatSearchTags.sticker.value)
            searchTags.append(fileName ?? "")
        case .post:
            notificationBody = "📷 Reels Post"
            messageInBody = "Reels Post"
            //searchable tags
            searchTags.append(ISMChatSearchTags.post.value)
            searchTags.append(message)
            
            if let caption  = caption, !caption.isEmpty{
                metaData["captionMessage"] =  caption
            }
            let post : [String: Any] = ["postId" : postId ?? "","postUrl" : message]
            metaData["post"] = post
        case .Product:
            notificationBody = "Product"
            messageInBody = "Product"
            //searchable tags
            searchTags.append(ISMChatSearchTags.product.value)
            searchTags.append(message)
            
            if let caption  = caption, !caption.isEmpty{
                metaData["captionMessage"] = caption
            }
            let product : [String: Any] = ["productId" : productId ?? "","productUrl" : message, "productCategoryId" : productCategoryId ?? ""]
            metaData["product"] = product
        default:
            break
        }
        let eventDetail : [String : Any] = ["sendPushNotification" : true,"updateUnreadCount" : true]
        body["showInConversation"] = true
        body["messageType"] = messageType
        body["encrypted"] = false
        body["deviceId"] = deviceId
        body["conversationId"] = conversationId
        body["body"] = messageInBody
        body["customType"] = customType
        body["notificationTitle"] = ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig.userName
        body["notificationBody"] = notificationBody
        body["searchableTags"] = searchTags
        body["events"] = eventDetail
        
        // Add "groupcastId" if it's a broadcast message
        if isBroadCastMessage == true{
            body["groupcastId"] = groupcastId
            body["hideNewConversationsForSender"] = false
            body["notifyOnCompletion"] = false
            body["sendPushForNewConversationCreated"] = false
            metaData = ["isBroadCastMessage" : true]
            body["metaData"] = metaData
        }
        
        // Add additional keys based on messageKind
        switch messageKind {
        case .text:
            if !mentionedUsers.isEmpty {
                body["mentionedUsers"] = mentionedUsers
            }
        case .location, .contact,.post,.Product:
            body["metaData"] = metaData
        case .photo, .video,.audio,.gif,.sticker,.document:
            body["attachments"] = [attachmentValue]
            if !metaData.isEmpty {
                body["metaData"] = metaData
            }
        default:
            break
        }
        
        let endPoint : ISMChatURLConvertible = isBroadCastMessage == false ? ISMChatMessagesEndpoint.sendMessage : ISMChatBroadCastEndpoint.sendBroadcastMessage
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatSendMsg, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_):
                completion(data.messageId ?? "", objectId ?? "")
                NotificationCenter.default.post(name: NSNotification.refrestConversationListLocally,object: nil)
            case .failure(let error):
                ISMChatHelper.print("Get send Message Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    
    //MARK: - delete message
    public func deleteMsg(messageDeleteType : ISMChatDeleteMessageType,messageId : [String],conversationId : String,completion:@escaping()->()){
        let totalMessageId = messageId.joined(separator: ",")
        let endPoint : ISMChatURLConvertible = messageDeleteType == .DeleteForYou ? ISMChatMessagesEndpoint.deleteMessageForMe(conversationId: conversationId, messageIds: totalMessageId) : ISMChatMessagesEndpoint.deleteMessageForEveryone(conversationId: conversationId, messageIds: totalMessageId)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])

        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(_,_):
                completion()
            case .failure(_):
                ISMChatHelper.print("Message deleivered Info Failed")
            }
        }
    }
    
    public func forwardToMutipleUsers(users : [UserDB],messages : [MessagesDB],completion:@escaping()->()){
        var newConversationIds: [String] = []
        
        DispatchQueue.global(qos: .userInitiated).async {
            let conversationGroup = DispatchGroup()
            
            for newUser in users {
                conversationGroup.enter()
                self.createConversation(user: newUser,chatStatus: ISMChatStatus.Reject.value) { data,_  in
                    guard let conversationId = data?.conversationId else {
                        conversationGroup.leave()
                        return
                    }
                    newConversationIds.append(conversationId)
                    conversationGroup.leave()
                }
            }
            
            conversationGroup.notify(queue: .main) {
                guard !newConversationIds.isEmpty else {
                    print("No conversations created.")
                    return
                }
                
                let messageGroup = DispatchGroup()
                
                for singleMessage in messages {
                    for conversationId in newConversationIds {
                        messageGroup.enter()
                        self.forwardMessage(conversationIds: [conversationId],
                                                 message: singleMessage.body,
                                                 attachments: singleMessage.customType == ISMChatMediaType.Text.value ? nil : singleMessage.attachments.first,
                                                 customType: singleMessage.customType,
                                                 placeName: singleMessage.metaData?.locationAddress,
                                                 metaData: singleMessage.metaData ?? nil) {
                            ISMChatHelper.print("Message Forwarded")
                            NotificationCenter.default.post(name: NSNotification.refreshConvList, object: nil)
                            messageGroup.leave()
                        }
                    }
                }
                
                messageGroup.notify(queue: .main) {
                    print("All messages forwarded and view dismissed!")
                    completion()
                }
            }
        }
    }
    
    
    //MARK: - forward message
    public func forwardMessage(conversationIds : [String],message : String,attachments:AttachmentDB? ,customType : String,placeName : String? = nil,contactInfo: [ISMChatPhoneContact]? = [],metaData : MetaDataDB? = nil,completion:@escaping()->()){
        var body : [String : Any]
        var metaDataValue : [String : Any] = [:]
        let deviceId = UniqueIdentifierManager.shared.getUniqueIdentifier()
        body = ["showInConversation" : true , "messageType" : 1 ,"encrypted" : false, "conversationIds" : conversationIds,"body" : message,"deviceId" : deviceId,"notificationTitle": ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig.userName,"customType" : customType] as [String : Any]
        
        if let obj = attachments{
            if attachments?.attachmentType == 3  {
                //Document
                body["attachments"] = [["thumbnailUrl": obj.thumbnailUrl , "size" : obj.size , "name" : obj.name , "mimeType" : obj.mimeType , "mediaUrl" : obj.mediaUrl , "mediaId" : UIDevice.current.identifierForVendor!.uuidString, "extension" : obj.extensions , "attachmentType" : obj.attachmentType] as [String : Any]]
                if let documentUrl = URL(string: obj.mediaUrl){
                    let fileName = ISMChatHelper.getFileNameFromURL(url: documentUrl)
                    body["notificationBody"] = "📄 \(fileName)"
                }
            }else if attachments?.attachmentType == 2{
                //Audio
                body["attachments"] = [["thumbnailUrl": obj.thumbnailUrl , "size" : obj.size , "name" : obj.name , "mimeType" : obj.mimeType , "mediaUrl" : obj.mediaUrl , "mediaId" : UIDevice.current.identifierForVendor!.uuidString, "extension" : obj.extensions , "attachmentType" : obj.attachmentType] as [String : Any]]
                body["notificationBody"] = "🎤 Voice Message"
            }else if attachments?.attachmentType == 1{
                //Video
                metaDataValue["captionMessage"] = metaData?.captionMessage
                body["metaData"] = metaDataValue
                body["attachments"] = [["thumbnailUrl": obj.thumbnailUrl , "size" : obj.size , "name" : obj.name , "mimeType" : obj.mimeType , "mediaUrl" : obj.mediaUrl , "mediaId" : UIDevice.current.identifierForVendor!.uuidString, "extension" : obj.extensions , "attachmentType" : obj.attachmentType] as [String : Any]]
                body["notificationBody"] = "📹 Video"
            }else if attachments?.attachmentType == 0{
                //Photo
                metaDataValue["captionMessage"] = metaData?.captionMessage
                body["metaData"] = metaDataValue
                body["attachments"] = [[
                    "thumbnailUrl": obj.thumbnailUrl,
                    "size": obj.size == 0 ? 10 : obj.size,
                    "name": obj.name,
                    "mimeType": obj.mimeType,
                    "mediaUrl": obj.mediaUrl,
                    "mediaId": obj.mediaId,
                    "extension": obj.extensions,
                    "attachmentType": obj.attachmentType
                ]as [String : Any]]
                body["notificationBody"] = "📷 Photo"
            }
        }
        
        if customType == ISMChatMediaType.Location.value{
            if let name = placeName , !name.isEmpty{
                body["notificationBody"] = "📍 \(name)"
            }
        }else if customType == ISMChatMediaType.Contact.value{
            let result = ISMChatHelper.parseJSONString(jsonString: message)
            if result.count == 1{
                body["notificationBody"] = "👤 \(result.firstDisplayName ?? "")"
            }else{
                body["notificationBody"] = "👤 \(result.firstDisplayName ?? "") and \((result.count) - 1) other contact"
            }
            var contacts : [[String: Any]] = []
            if let metaData = metaData{
                for contact in metaData.contacts {
                    let contactDictionary: [String: Any] = [
                        "contactName": contact.contactName ?? "",
                        "contactIdentifier": contact.contactIdentifier ?? "",
                        "contactImageUrl": contact.contactImageUrl ?? ""
                    ]
                    contacts.append(contactDictionary)
                }
            }
            metaDataValue = ["contacts" : contacts]
            body["metaData"] = metaDataValue
        }else{
            //text
            body["notificationBody"] = message
        }
        
        body["events"] = ["updateUnreadCount" : true ,"sendPushNotification" : true]
        
        
        let endPoint : ISMChatURLConvertible = ISMChatMessagesEndpoint.forwardMessage
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)

        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatSendMsg, ISMChatNewAPIError>) in
            switch result{
            case .success(_,_):
                completion()
            case .failure(let error):
                ISMChatHelper.print("post forward msg Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - reply message
    public func replyToMessage(customType : String,conversationId :  String,message : String,parentMessage : MessagesDB,completion:@escaping(String)->()){
        var body : [String : Any]
        let deviceId = UniqueIdentifierManager.shared.getUniqueIdentifier()
        var thumbnailUrl = ""
        if parentMessage.customType == ISMChatMediaType.Video.value{
            thumbnailUrl = parentMessage.attachments.first?.thumbnailUrl ?? ""
        }else if parentMessage.customType == ISMChatMediaType.Location.value{
            thumbnailUrl = parentMessage.body
        }else{
            thumbnailUrl = parentMessage.attachments.first?.mediaUrl ?? ""
        }
        let replyMessageData : [String : Any] = ["parentMessageBody" : parentMessage.body,
                                                 "parentMessageUserId" : parentMessage.senderInfo?.userId ?? "",
                                                 "parentMessageInitiator" : ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig.userId == parentMessage.senderInfo?.userId,
                                                 "parentMessageUserName" : parentMessage.senderInfo?.userName ?? "",
                                                 "parentMessageMessageType" : parentMessage.customType,
                                                 "parentMessageAttachmentUrl" : thumbnailUrl,
                                                 "parentMessagecaptionMessage" : parentMessage.metaData?.captionMessage ?? ""]
        let metaData : [String : Any] = ["replyMessage" : replyMessageData]
        let eventDetail : [String : Any] = ["sendPushNotification" : true,"updateUnreadCount" : true]
        body = ["showInConversation" : true , "messageType" : 2 , "encrypted" : false ,"deviceId" : deviceId,"conversationId" : conversationId, "body" : message,"customType" : customType,"parentMessageId" : parentMessage.messageId,"metaData" : metaData,"notificationTitle": ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig.userName,"notificationBody": message, "events" : eventDetail] as [String : Any]
        
        let endPoint : ISMChatURLConvertible = ISMChatMessagesEndpoint.sendMessage
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)

        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatSendMsg, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_):
                completion(data.messageId ?? "")
            case .failure(let error):
                ISMChatHelper.print("Get send Message Api failed -----> \(String(describing: error))")
            }
        }
    }
}
