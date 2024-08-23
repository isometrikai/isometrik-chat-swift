//
//  ChatViewModel.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 30/01/23.
//

import Foundation
import UIKit
import Alamofire
import LinkPresentation
import AVFoundation
import AVKit
import SwiftUI
import Combine
//import TUSKit
//import TransloaditKit

public class ChatsViewModel : NSObject ,ObservableObject,AVAudioPlayerDelegate{
    
    //MARK:  - PROPERTIES
    @Published public var messages : [[ISMChatMessage]]?
    @Published public var allMessages : [ISMChatMessage]? = []
    @Published public var forwardToConversations : [ISMChatConversationsDetail] = []
    @Published public var documentSelectedFromPicker : URL?
    //    @Published var cameraImageToUse : URL?
    public var skip : Int = 0
    public var skipUser : Int = 0
    @Published public var isBusy = false
    
    //audio recorder
    public var audioRecorder : AVAudioRecorder!
    public var audioPlayer : AVAudioPlayer!
    public var audioUrl : URL?
    public var indexOfPlayer = 0
    @Published public var isRecording : Bool = false
    @Published public var countSec = 0
    @Published public var timerCount : Timer?
    @Published public var blinkingCount : Timer?
    @Published public var timerValue : String = "0:00"
    @Published public var toggleColor : Bool = false
    
    @Published public var recordingsList = [ISMChatRecording]()
    
    //grp
    @Published public var groupTitleImage : URL?
    
//    public var tusClient: TUSClient? = nil
//    public var callBack : ((String,Bool)->())? = nil
//    public var callBackProgress : ((Int,Int,Bool)->())? = nil
//    public var isVideo:Bool = false
//    public var isFile: Bool = false
    
    var ismChatSDK: ISMChatSdk?
    
    public init(ismChatSDK: ISMChatSdk) {
        self.ismChatSDK = ismChatSDK
    }
    
    //MARK: - get messages
    public func getMessages(refresh : Bool? = nil,conversationId : String,lastMessageTimestamp:String,completion:@escaping(ISMChatMessages?)->()){
        var baseURL = String()
        if lastMessageTimestamp == "" {
            baseURL = "\(ISMChatNetworkServices.Urls.messages)?conversationId=\(conversationId)"
        }else {
            baseURL = "\(ISMChatNetworkServices.Urls.messages)?conversationId=\(conversationId)&lastMessageTimestamp=\(lastMessageTimestamp)"
        }
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChatResponse<ISMChatMessages?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChatHelper.print("Get Message Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    
    //MARK: - update messages
    public func updateMessage(messageId : String,conversationId : String,message : String,completion:@escaping(String)->()){
        var searchTags : [String] = []
        searchTags.append(ISMChatSearchTags.text.value)
        searchTags.append(message)
        let body = ["messageId" : messageId,"conversationId" : conversationId, "body" : message,"searchableTags" : searchTags] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.sendMessage,httpMethod: .patch,params: body) { (result : ISMChatResponse<ISMChatSendMsg?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data?.messageId ?? "")
            case .failure(let error):
                ISMChatHelper.print("Get send Message Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - send Reel
    public func sharePost(user: UserDB,postId : String,postURL : String,postCaption : String,completion:@escaping()->()){
        self.createConversation(user: user) { response in
            self.sendMessage(messageKind: .post, customType: ISMChatMediaType.Post.value, conversationId: response?.conversationId ?? "", message: postURL, fileName: "", fileSize: nil, mediaId: nil,caption: postCaption,postId: postId) { _, _ in
                NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                completion()
            }
        }
    }
    
    
    //MARK: - send messages
    public func sendMessage(messageKind : ISMChatMessageType,customType : String,conversationId :  String,message : String,fileName : String?,fileSize : Int?,mediaId : String?,objectId : String? = "",messageType:Int = 0,thumbnailUrl : String? = "",contactInfo: [ISMChatPhoneContact]? = [],latitude : Double? = nil,longitude : Double? = nil,placeName : String? = nil,placeAddress : String? = nil,isGroup : Bool? = false,groupMembers : [ISMChatGroupMember]? = [],caption : String? = nil,isBroadCastMessage : Bool? = false,groupcastId : String? = nil,postId : String? = nil,completion:@escaping(String, String)->()){
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
            attachmentValue = ["thumbnailUrl": message, "attachmentMessageType" : "Gif","attachmentSchemaType" : "GifSticker", "attachmentType" : ISMChatAttachmentType.Gif.type,"mediaUrl" : message,"name" : fileName, "stillUrl" : message]
            body["attachments"] = attachmentValue
            notificationBody = "Gif"
            messageInBody = "Gif"
            //searchable tags
            searchTags.append(ISMChatSearchTags.gif.value)
            searchTags.append(fileName ?? "")
        case .sticker:
            attachmentValue = ["thumbnailUrl": message, "attachmentMessageType" : "Sticker","attachmentSchemaType" : "GifSticker", "attachmentType" : ISMChatAttachmentType.Sticker.type,"mediaUrl" : message,"name" : fileName, "stillUrl" : message]
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
                metaData = ["captionMessage" : caption]
            }
            var post : [String: Any] = ["postId" : postId ?? "","postUrl" : message]
            metaData = ["post" : post]
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
        body["notificationTitle"] = ismChatSDK?.getChatClient().getConfigurations().userConfig.userName ?? "Message"
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
        case .location, .contact,.post:
            body["metaData"] = metaData
        case .photo, .video,.audio:
            body["attachments"] = [attachmentValue]
            if !metaData.isEmpty {
                body["metaData"] = metaData
            }
        default:
            break
        }
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: isBroadCastMessage == false ?  ISMChatNetworkServices.Urls.sendMessage : ISMChatNetworkServices.Urls.postbroadCastMessage,httpMethod: .post,params: body) { (result : ISMChatResponse<ISMChatSendMsg?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data?.messageId ?? "", objectId ?? "")
            case .failure(let error):
                ISMChatHelper.print("Get send Message Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - get conversation Detail
    public func getConversationDetail(conversationId : String,isGroup : Bool,completion:@escaping(ISMChatConversationDetail?)->()){
        var baseURL = ""
        if isGroup == true{
            baseURL = "\(ISMChatNetworkServices.Urls.conversationDetail)\(conversationId)?includeMembers=true"
        }else{
            baseURL = "\(ISMChatNetworkServices.Urls.conversationDetail)\(conversationId)"
        }
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChatResponse<ISMChatConversationDetail?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChatHelper.print("Get CONVERSATION Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - message read info
    public func getMessageReadInfo(messageId : String,conversationId : String,completion:@escaping(ISMChatConversationDetail?)->()){
        let baseURL = "\(ISMChatNetworkServices.Urls.messageRead)?conversationId=\(conversationId)&messageId=\(messageId)"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChatResponse<ISMChatConversationDetail?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(_):
                ISMChatHelper.print("Message Read Info Failed")
            }
        }
    }
    
    //MARK: - message delivered info
    public func getMessageDeliveredInfo(messageId : String,conversationId : String,completion:@escaping(ISMChatConversationDetail?)->()){
        let baseURL = "\(ISMChatNetworkServices.Urls.messageDelivered)?conversationId=\(conversationId)&messageId=\(messageId)"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChatResponse<ISMChatConversationDetail?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(_):
                ISMChatHelper.print("Message deleivered Info Failed")
            }
        }
    }
    
    //MARK: - delete message
    public func deleteMsg(messageDeleteType : ISMChatDeleteMessageType,messageId : [String],conversationId : String,completion:@escaping()->()){
        let totalMessageId = messageId.joined(separator: ",")
        var baseURL = ""
        switch messageDeleteType{
        case .DeleteForYou:
            baseURL = "\(ISMChatNetworkServices.Urls.messageDeleteForMe)?conversationId=\(conversationId)&messageIds=\(totalMessageId)"
        case .DeleteForEveryone:
            baseURL = "\(ISMChatNetworkServices.Urls.messageDeleteForEveryone)?conversationId=\(conversationId)&messageIds=\(totalMessageId)"
        }
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .delete) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
            switch result{
            case .success(_):
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
                self.createConversation(user: newUser) { data in
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
        body = ["showInConversation" : true , "messageType" : 1 ,"encrypted" : false, "conversationIds" : conversationIds,"body" : message,"deviceId" : deviceId,"notificationTitle": ismChatSDK?.getChatClient().getConfigurations().userConfig.userName ?? "","customType" : customType] as [String : Any]
        
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
        
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.forwardMessage,httpMethod: .post,params: body) { (result : ISMChatResponse<ISMChatSendMsg?,ISMChatErrorData?>) in
            switch result{
            case .success(_):
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
                                                 "parentMessageInitiator" : ismChatSDK?.getChatClient().getConfigurations().userConfig.userId == parentMessage.senderInfo?.userId,
                                                 "parentMessageUserName" : parentMessage.senderInfo?.userName ?? "",
                                                 "parentMessageMessageType" : parentMessage.customType,
                                                 "parentMessageAttachmentUrl" : thumbnailUrl,
                                                 "parentMessagecaptionMessage" : parentMessage.metaData?.captionMessage ?? ""]
        let metaData : [String : Any] = ["replyMessage" : replyMessageData]
        let eventDetail : [String : Any] = ["sendPushNotification" : true,"updateUnreadCount" : true]
        body = ["showInConversation" : true , "messageType" : 2 , "encrypted" : false ,"deviceId" : deviceId,"conversationId" : conversationId, "body" : message,"customType" : customType,"parentMessageId" : parentMessage.messageId,"metaData" : metaData,"notificationTitle": ismChatSDK?.getChatClient().getConfigurations().userConfig.userName ?? "","notificationBody": message, "events" : eventDetail] as [String : Any]
        
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.sendMessage,httpMethod: .post,params: body) { (result : ISMChatResponse<ISMChatSendMsg?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data?.messageId ?? "")
            case .failure(let error):
                ISMChatHelper.print("Get send Message Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - create conversation
    public func createConversation(user : UserDB,profileType : String? = nil,chatStatus : String? = nil,completion:@escaping(ISMChatCreateConversationResponse?)->()){
        var body : [String : Any]
        let metaDataValue : [String : Any] = ["profileType" : profileType ?? "", "chatStatus" : chatStatus ?? ""]
        body = ["typingEvents" : true ,
                "readEvents" : true,
                "pushNotifications" : true,
                "members" : [user.userId],
                "isGroup" : false,
                "conversationType" : 0,
                "metaData" : metaDataValue] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.createConversation,httpMethod: .post,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChatHelper.print("Create Conversation Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - accept rquest to chat
    public func acceptRequestToAllowMessage(conversationId : String,completion:@escaping(ISMChatCreateConversationResponse?)->()){
        var body : [String : Any]
        let metaData = ["chatStatus" : ISMChatStatus.Accept.value]
        body = ["metaData" : metaData,"conversationId" : conversationId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.conversationDetail,httpMethod: .patch,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChatHelper.print("Meta data changed to allow message -----> \(String(describing: error))")
            }
        }
    }
    
    
    //MARK: - get all messages not delivered yet
    public func getAllMessagesWhichWereSendToMeWhenOfflineMarkThemAsDelivered(myUserId : String,skip : Int = 0){
        let limit = 20
        let baseUrl = "\(ISMChatNetworkServices.Urls.getMessagesInConersation)?senderIdsExclusive=true&deliveredToMe=false&senderIds=\(myUserId)&limit=\(limit)&skip=\(skip)&sort=-1"
        
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseUrl,httpMethod: .get) { (result : ISMChatResponse<ISMChatMessages?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                print("success")
                let filteredMessages = data?.messages?.filter { message in
                    return message.action != ISMChatActionType.userBlock.value &&
                    message.action != ISMChatActionType.userUnblock.value &&
                    message.action != ISMChatActionType.userBlockConversation.value &&
                    message.action != ISMChatActionType.userUnblockConversation.value &&
                    message.action != ISMChatActionType.deleteConversationLocally.value &&
                    message.action != ISMChatActionType.conversationTitleUpdated.value &&
                    message.action != ISMChatActionType.conversationImageUpdated.value &&
                    message.action != ISMChatActionType.conversationCreated.value &&
                    message.action != ISMChatActionType.membersAdd.value &&
                    message.action != ISMChatActionType.memberLeave.value &&
                    message.action != ISMChatActionType.addAdmin.value &&
                    message.action != ISMChatActionType.removeAdmin.value &&
                    message.action != ISMChatActionType.membersRemove.value &&
                    message.action != ISMChatActionType.messageDetailsUpdated.value &&
                    message.action != ISMChatActionType.reactionAdd.value &&
                    message.action != ISMChatActionType.reactionRemove.value &&
                    message.action != ISMChatActionType.conversationSettingsUpdated.value &&
                    message.action != ISMChatActionType.meetingCreated.value &&
                    message.action != ISMChatActionType.meetingEndedDueToRejectionByAll.value &&
                    message.action != ISMChatActionType.meetingEndedDueToNoUserPublishing.value &&
                    message.action != ISMChatActionType.userUpdate.value
                }
                if let messagesToDeliver = filteredMessages {
                    for message in messagesToDeliver {
                        guard let conversationId = message.conversationId,
                              let messageId = message.messageId else {
                            continue // Skip this message if conversationId or messageId is nil
                        }
                        
                        let myUserId = self.ismChatSDK?.getChatClient().getConfigurations().userConfig.userId ?? ""
                        
                        // Check if your userId is contained in the deliveredTo array
                        let containsUserId = message.deliveredTo?.contains(where: { $0.userId == myUserId }) ?? false
                        
                        if !containsUserId {
                            // Call your delivered API if your userId is not contained in deliveredTo
                            self.deliveredMessageIndicator(conversationId: conversationId, messageId: messageId) { value in
                                if value == true {
                                    // Do something if the message was delivered successfully
                                }
                            }
                        }
                    }
                    if messagesToDeliver.count == limit {
                        self.getAllMessagesWhichWereSendToMeWhenOfflineMarkThemAsDelivered(myUserId: myUserId, skip: skip + limit)
                    } else {
                        print("Pagination stopped")
                    }
                }
            case .failure(let error):
                ISMChatHelper.print("get all messages Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    
    //MARK: - mark message as read
    public func markMessagesAsRead(conversationId : String){
        var body : [String : Any]
        let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
        body = ["conversationId" : conversationId ,
                "timestamp" : timeStamp] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.markMessageAsRead,httpMethod: .put,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                ISMChatHelper.print("Mark Message Read Api succedded -----> \(String(describing: data?.msg))")
            case .failure(let error):
                ISMChatHelper.print("Mark Message Read Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - read message indicator
    public func readMessageIndicator(conversationId : String,messageId : String,completion:@escaping(Bool?)->()){
        var body : [String : Any]
        body = ["conversationId" : conversationId ,
                "messageId" : messageId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.readMessageIndicator,httpMethod: .put,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                ISMChatHelper.print("Read Message Indicator Api succedded -----> \(String(describing: data?.msg))")
                completion(true)
            case .failure(let error):
                ISMChatHelper.print("Read Message Indicator Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - typing message indicator
    public func typingMessageIndicator(conversationId : String){
        var body : [String : Any]
        body = ["conversationId" : conversationId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.typingMessageIndicator,httpMethod: .post,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                ISMChatHelper.print("Typing Message Indicator Api succedded -----> \(String(describing: data?.msg))")
            case .failure(let error):
                ISMChatHelper.print("Typing Message Indicator Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - delivered message indicator
    public func deliveredMessageIndicator(conversationId : String,messageId : String,completion:@escaping(Bool?)->()){
        var body : [String : Any]
        body = ["conversationId" : conversationId ,
                "messageId" : messageId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.deliveredMessageIndicator,httpMethod: .put,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                ISMChatHelper.print("Delivered Message Indicator Api succedded -----> \(String(describing: data?.msg))")
                completion(true)
            case .failure(let error):
                ISMChatHelper.print("Delivered Message Indicator Api failed -----> \(String(describing: error))")
                completion(true)
            }
        }
    }
}

extension ChatsViewModel{
    public func getSectionMessage(for chat : [MessagesDB]) -> [[MessagesDB]] {
        var res = [[MessagesDB]]()
        let groupedMessages = Dictionary(grouping: chat) { (element) -> Date in
            
            //timestamp
            let timeStamp = element.sentAt
            let unixTimeStamp: Double = Double(timeStamp ) / 1000.0
            let dateFormatt = DateFormatter()
            dateFormatt.dateFormat = "dd/MM/yyy"
            //conver to string
            let strDate = dateFormatt.string(from: Date(timeIntervalSince1970: unixTimeStamp) as Date)
            //str to date
            return dateFormatt.date(from: strDate) ?? Date()
        }
        let sortedKeys = groupedMessages.keys.sorted()
        sortedKeys.forEach { (key) in
            var values = groupedMessages[key]
            values?.sort { Double($0.sentAt ) / 1000.0 < Double($1.sentAt ) / 1000.0 }
            res.append(values ?? [])
        }
        return res
    }
}
