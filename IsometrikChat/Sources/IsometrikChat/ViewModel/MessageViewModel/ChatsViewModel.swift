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

class ChatsViewModel : NSObject ,ObservableObject,AVAudioPlayerDelegate{
    
    //MARK:  - PROPERTIES
    @Published var messages : [[ISMChat_Message]]?
    @Published var allMessages : [ISMChat_Message]? = []
    @Published var forwardToConversations : [ISMChat_ConversationsDetail] = []
    @Published var documentSelectedFromPicker : URL?
    //    @Published var cameraImageToUse : URL?
    var skip : Int = 0
    var skipUser : Int = 0
    @Published var isBusy = false
    
    //audio recorder
    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var audioUrl : URL?
    var indexOfPlayer = 0
    @Published var isRecording : Bool = false
    @Published var countSec = 0
    @Published var timerCount : Timer?
    @Published var blinkingCount : Timer?
    @Published var timerValue : String = "0:00"
    @Published var toggleColor : Bool = false
    
    @Published var recordingsList = [ISMChat_Recording]()
    
    //grp
    @Published var groupTitleImage : URL?
    
    
    var ismChatSDK: ISMChatSdk?
    
    init(ismChatSDK: ISMChatSdk) {
        self.ismChatSDK = ismChatSDK
    }
    
    //MARK: - get messages
    func getMessages(refresh : Bool? = nil,conversationId : String,lastMessageTimestamp:String,completion:@escaping(ISMChat_Messages?)->()){
        var baseURL = String()
        if lastMessageTimestamp == "" {
            baseURL = "\(ISMChat_NetworkServices.Urls.messages)?conversationId=\(conversationId)"
        }else {
            baseURL = "\(ISMChat_NetworkServices.Urls.messages)?conversationId=\(conversationId)&lastMessageTimestamp=\(lastMessageTimestamp)"
        }
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChat_Response<ISMChat_Messages?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("Get Message Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    
    //MARK: - update messages
    func updateMessage(messageId : String,conversationId : String,message : String,completion:@escaping(String)->()){
        var searchTags : [String] = []
        searchTags.append(ISMChat_SearchTags.ism_search_tag_text.value)
        searchTags.append(message)
        let body = ["messageId" : messageId,"conversationId" : conversationId, "body" : message,"searchableTags" : searchTags] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.sendMessage,httpMethod: .patch,params: body) { (result : ISMChat_Response<ISMChat_SendMsg?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data?.messageId ?? "")
            case .failure(let error):
                ISMChat_Helper.print("Get send Message Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - send messages
    func sendMessage(messageKind : ISMChat_MessageType,customType : String,conversationId :  String,message : String,fileName : String?,fileSize : Int?,mediaId : String?,objectId : String? = "",messageType:Int = 0,thumbnailUrl : String? = "",contactInfo: [ISMChat_PhoneContact]? = [],latitude : Double? = nil,longitude : Double? = nil,placeName : String? = nil,placeAddress : String? = nil,isGroup : Bool? = false,groupMembers : [ISMChat_GroupMember]? = [],caption : String? = nil,isBroadCastMessage : Bool? = false,groupcastId : String? = nil,completion:@escaping(String, String)->()){
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
            attachmentValue = ["thumbnailUrl": message, "size" : fileSize ?? 0, "name" : fileName ?? "" , "mimeType" : ISMChat_ExtensionType.Image.type, "mediaUrl" : message, "mediaId" : mediaId ?? "", "extension" : ISMChat_ExtensionType.Image.type, "attachmentType" : ISMChat_AttachmentType.Image.type]
            body["attachments"] = attachmentValue
            notificationBody = "📷 Photo"
            messageInBody = "Image"
            //searchable tags
            searchTags.append(ISMChat_SearchTags.ism_search_tag_photo.value)
            searchTags.append(message)
            if let caption  = caption, !caption.isEmpty{
                metaData = ["captionMessage" : caption]
            }
        case .video:
            attachmentValue = ["thumbnailUrl": thumbnailUrl ?? "", "size" : fileSize ?? 0, "name" : fileName ?? "" , "mimeType" : ISMChat_ExtensionType.Video.type, "mediaUrl" : message, "mediaId" : mediaId ?? "", "extension" : ISMChat_ExtensionType.Video.type, "attachmentType" : ISMChat_AttachmentType.Video.type]
            body["attachments"] = attachmentValue
            notificationBody = "📹 Video"
            messageInBody = "Video"
            //searchable tags
            searchTags.append(ISMChat_SearchTags.ism_search_tag_video.value)
            searchTags.append(message)
            if let caption  = caption, !caption.isEmpty{
                metaData = ["captionMessage" : caption]
            }
        case .audio:
            attachmentValue = ["thumbnailUrl": message, "size" : fileSize ?? 0, "name" : fileName ?? "" , "mimeType" : ISMChat_ExtensionType.Audio.type, "mediaUrl" : message, "mediaId" : mediaId ?? "", "extension" : ISMChat_ExtensionType.Audio.type, "attachmentType" : ISMChat_AttachmentType.Audio.type]
            body["attachments"] = attachmentValue
            notificationBody = "🎤 Voice Message"
            messageInBody = "Audio"
            //searchable tags
            searchTags.append(ISMChat_SearchTags.ism_search_tag_audio.value)
            searchTags.append(message)
        case .document:
            attachmentValue = ["thumbnailUrl": message, "size" : fileSize ?? 0, "name" : fileName ?? "" , "mimeType" : ISMChat_ExtensionType.Document.type, "mediaUrl" : message, "mediaId" : mediaId ?? "", "extension" : ISMChat_ExtensionType.Document.type, "attachmentType" : ISMChat_AttachmentType.Document.type]
            if let documentUrl = URL(string: message){
                let fileName = ISMChat_Helper.getFileNameFromURL(url: documentUrl)
                notificationBody = "📄 \(fileName)"
                messageInBody = "Document"
            }
            //searchable tags
            searchTags.append(ISMChat_SearchTags.ism_search_tag_file.value)
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
            searchTags.append(ISMChat_SearchTags.ism_search_tag_text.value)
            searchTags.append(message)
        case .location:
            if let latitude = latitude, let longitude = longitude, let placeName = placeName,let placeAddress = placeAddress{
                attachmentValue = ["latitude" : latitude, "title": placeName, "longitude" : longitude , "address" : placeAddress,"attachmentType" : ISMChat_AttachmentType.Location.type]
            }
            
            messageInBody = message
            if let name = placeName , !name.isEmpty{
                metaData["locationAddress"] = name
                notificationBody = "📍 \(name)"
            }
            //searchable tags
            searchTags.append(ISMChat_SearchTags.ism_search_tag_location.value)
            searchTags.append(message)
        case .contact:
            if contactInfo?.count == 1{
                notificationBody = "👤 \(contactInfo?.first?.displayName ?? "")"
            }else{
                notificationBody = "👤 \(contactInfo?.first?.displayName ?? "") and \((contactInfo?.count ?? 1) - 1) other contact"
            }
            
            //searchable tags
            searchTags.append(ISMChat_SearchTags.ism_search_tag_contact.value)
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
            attachmentValue = ["thumbnailUrl": message, "attachmentMessageType" : "Gif","attachmentSchemaType" : "GifSticker", "attachmentType" : ISMChat_AttachmentType.Gif.type,"mediaUrl" : message,"name" : fileName, "stillUrl" : message]
            body["attachments"] = attachmentValue
            notificationBody = "Gif"
            messageInBody = "Gif"
            //searchable tags
            searchTags.append(ISMChat_SearchTags.ism_search_tag_gif.value)
            searchTags.append(fileName ?? "")
        case .sticker:
            attachmentValue = ["thumbnailUrl": message, "attachmentMessageType" : "Sticker","attachmentSchemaType" : "GifSticker", "attachmentType" : ISMChat_AttachmentType.Sticker.type,"mediaUrl" : message,"name" : fileName, "stillUrl" : message]
            body["attachments"] = attachmentValue
            notificationBody = "Sticker"
            messageInBody = "Sticker"
            //searchable tags
            searchTags.append(ISMChat_SearchTags.ism_search_tag_sticker.value)
            searchTags.append(fileName ?? "")
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
        body["notificationTitle"] = ismChatSDK?.getUserSession().getUserName() ?? ""
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
        case .location, .contact:
            body["metaData"] = metaData
        case .photo, .video:
            body["attachments"] = [attachmentValue]
            if !metaData.isEmpty {
                body["metaData"] = metaData
            }
        default:
            break
        }
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: isBroadCastMessage == false ?  ISMChat_NetworkServices.Urls.sendMessage : ISMChat_NetworkServices.Urls.postbroadCastMessage,httpMethod: .post,params: body) { (result : ISMChat_Response<ISMChat_SendMsg?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data?.messageId ?? "", objectId ?? "")
            case .failure(let error):
                ISMChat_Helper.print("Get send Message Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - upload image, video, doc
    func upload(messageKind : ISMChat_MessageType,conversationId :  String,conversationType : Int? = 0,image : URL?,document : URL?,video : URL?,audio : URL?,mediaName : String,isfromDocument : Bool? = false,completion:@escaping(ISMChat_PresignedUrlDetail?, String , Int)->()){
        //params
        var params = [String: Any]()
        params["conversationId"] = conversationId
        //Type of the conversation for which to fetch presigned urls for attachments.0- Conversation, 1- Bulk messaging, 2- Groupcast
        params["conversationType"] = conversationType
        var mediaType : Int = 0
        var mediaData : Data = Data()
        if messageKind == .document{
            mediaType = 3
            if let document = document {
                if document.startAccessingSecurityScopedResource() {
                    guard let restoredData = try? Data(contentsOf: document) else {
                        return
                    }
                    mediaData = restoredData
                }
                document.stopAccessingSecurityScopedResource()
            }
        }else if messageKind == .photo{
            mediaType = 0
            if let image = video {
                if isfromDocument == true{
                    guard image.startAccessingSecurityScopedResource() else {
                        return
                    }
                }
                mediaData = try! Data(contentsOf: image)
            }else if let image = image{
                if let myImage = ISMChat_Helper.compressImage(image: image){
                    if let dataobj = myImage.jpegData(compressionQuality: 0.1){
                        mediaData = dataobj
                    }
                }
            }
        }else if messageKind == .video{
            mediaType = 1
            if let video = video {
                mediaData =  try! Data(contentsOf: video)
            }
        }else if messageKind == .audio{
            mediaType = 2
            if let audio = audio {
                mediaData =  try! Data(contentsOf: audio)
            }
        }
        params["attachments"] = [["nameWithExtension": mediaName ,"mediaType" : mediaType,"mediaId" : UIDevice.current.identifierForVendor!.uuidString] as [String : Any]]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.presignedUrl,httpMethod: .post,params: params) { (result : ISMChat_Response<ISMChat_PresignedUrl?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                if let url = data?.presignedUrls?.first?.mediaPresignedUrl{
                    AF.upload(mediaData, to: url, method: .put, headers: [:]).responseData { response in
                        ISMChat_Helper.print(response)
                        if response.response?.statusCode == 200{
                            completion(data?.presignedUrls?.first, mediaName, mediaData.count)
                        }else{
                            ISMChat_Helper.print("Error in Image upload")
                        }
                    }
                }
            case .failure(let error):
                ISMChat_Helper.print(error ?? "Error")
            }
        }
    }
    
    
    //MARK: - get conversation Detail
    func getConversationDetail(conversationId : String,isGroup : Bool,completion:@escaping(ISMChat_ConversationDetail?)->()){
        var baseURL = ""
        if isGroup == true{
            baseURL = "\(ISMChat_NetworkServices.Urls.conversationDetail)\(conversationId)?includeMembers=true"
        }else{
            baseURL = "\(ISMChat_NetworkServices.Urls.conversationDetail)\(conversationId)"
        }
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChat_Response<ISMChat_ConversationDetail?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("Get CONVERSATION Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - message read info
    func getMessageReadInfo(messageId : String,conversationId : String,completion:@escaping(ISMChat_ConversationDetail?)->()){
        let baseURL = "\(ISMChat_NetworkServices.Urls.messageRead)?conversationId=\(conversationId)&messageId=\(messageId)"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChat_Response<ISMChat_ConversationDetail?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(_):
                ISMChat_Helper.print("Message Read Info Failed")
            }
        }
    }
    
    //MARK: - message delivered info
    func getMessageDeliveredInfo(messageId : String,conversationId : String,completion:@escaping(ISMChat_ConversationDetail?)->()){
        let baseURL = "\(ISMChat_NetworkServices.Urls.messageDelivered)?conversationId=\(conversationId)&messageId=\(messageId)"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChat_Response<ISMChat_ConversationDetail?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(_):
                ISMChat_Helper.print("Message deleivered Info Failed")
            }
        }
    }
    
    //MARK: - delete message
    func deleteMsg(messageDeleteType : ISMChat_DeleteMessageType,messageId : [String],conversationId : String,completion:@escaping()->()){
        let totalMessageId = messageId.joined(separator: ",")
        var baseURL = ""
        switch messageDeleteType{
        case .DeleteForYou:
            baseURL = "\(ISMChat_NetworkServices.Urls.messageDeleteForMe)?conversationId=\(conversationId)&messageIds=\(totalMessageId)"
        case .DeleteForEveryone:
            baseURL = "\(ISMChat_NetworkServices.Urls.messageDeleteForEveryone)?conversationId=\(conversationId)&messageIds=\(totalMessageId)"
        }
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .delete) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(_):
                completion()
            case .failure(_):
                ISMChat_Helper.print("Message deleivered Info Failed")
            }
        }
    }
    
    
    //MARK: - forward message
    func forwardMessage(conversationIds : [String],message : String,attachments:AttachmentDB? ,customType : String,placeName : String? = nil,contactInfo: [ISMChat_PhoneContact]? = [],metaData : MetaDataDB? = nil,completion:@escaping()->()){
        var body : [String : Any]
        var metaDataValue : [String : Any] = [:]
        let deviceId = UniqueIdentifierManager.shared.getUniqueIdentifier()
        body = ["showInConversation" : true , "messageType" : 1 ,"encrypted" : false, "conversationIds" : conversationIds,"body" : message,"deviceId" : deviceId,"notificationTitle": ismChatSDK?.getUserSession().getUserName() ?? "","customType" : customType] as [String : Any]
        
        if let obj = attachments{
            if attachments?.attachmentType == 3  {
                //Document
                body["attachments"] = [["thumbnailUrl": obj.thumbnailUrl , "size" : obj.size , "name" : obj.name , "mimeType" : obj.mimeType , "mediaUrl" : obj.mediaUrl , "mediaId" : UIDevice.current.identifierForVendor!.uuidString, "extension" : obj.extensions , "attachmentType" : obj.attachmentType] as [String : Any]]
                if let documentUrl = URL(string: obj.mediaUrl){
                    let fileName = ISMChat_Helper.getFileNameFromURL(url: documentUrl)
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
                body["attachments"] = [["thumbnailUrl": obj.thumbnailUrl , "size" : obj.size , "name" : obj.name , "mimeType" : obj.mimeType , "mediaUrl" : obj.mediaUrl , "mediaId" : UIDevice.current.identifierForVendor!.uuidString, "extension" : obj.extensions , "attachmentType" : obj.attachmentType] as [String : Any]]
                body["notificationBody"] = "📷 Photo"
            }
        }
        
        if customType == ISMChat_MediaType.Location.value{
            if let name = placeName , !name.isEmpty{
                body["notificationBody"] = "📍 \(name)"
            }
        }else if customType == ISMChat_MediaType.Contact.value{
            let result = ISMChat_Helper.parseJSONString(jsonString: message)
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
        
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.forwardMessage,httpMethod: .post,params: body) { (result : ISMChat_Response<ISMChat_SendMsg?,ISMChat_ErrorData?>) in
            switch result{
            case .success(_):
                completion()
            case .failure(let error):
                ISMChat_Helper.print("post forward msg Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - reply message
    func replyToMessage(customType : String,conversationId :  String,message : String,parentMessage : MessagesDB,completion:@escaping(String)->()){
        var body : [String : Any]
        let deviceId = UniqueIdentifierManager.shared.getUniqueIdentifier()
        var thumbnailUrl = ""
        if parentMessage.customType == ISMChat_MediaType.Video.value{
            thumbnailUrl = parentMessage.attachments.first?.thumbnailUrl ?? ""
        }else if parentMessage.customType == ISMChat_MediaType.Location.value{
            thumbnailUrl = parentMessage.body
        }else{
            thumbnailUrl = parentMessage.attachments.first?.mediaUrl ?? ""
        }
        let replyMessageData : [String : Any] = ["parentMessageBody" : parentMessage.body,
                                                 "parentMessageUserId" : parentMessage.senderInfo?.userId ?? "",
                                                 "parentMessageInitiator" : ismChatSDK?.getUserSession().getUserId() == parentMessage.senderInfo?.userId,
                                                 "parentMessageUserName" : parentMessage.senderInfo?.userName ?? "",
                                                 "parentMessageMessageType" : parentMessage.customType,
                                                 "parentMessageAttachmentUrl" : thumbnailUrl,
                                                 "parentMessagecaptionMessage" : parentMessage.metaData?.captionMessage ?? ""]
        let metaData : [String : Any] = ["replyMessage" : replyMessageData]
        let eventDetail : [String : Any] = ["sendPushNotification" : true,"updateUnreadCount" : true]
        body = ["showInConversation" : true , "messageType" : 2 , "encrypted" : false ,"deviceId" : deviceId,"conversationId" : conversationId, "body" : message,"customType" : customType,"parentMessageId" : parentMessage.messageId,"metaData" : metaData,"notificationTitle": ismChatSDK?.getUserSession().getUserName() ?? "","notificationBody": message, "events" : eventDetail] as [String : Any]
        
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.sendMessage,httpMethod: .post,params: body) { (result : ISMChat_Response<ISMChat_SendMsg?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data?.messageId ?? "")
            case .failure(let error):
                ISMChat_Helper.print("Get send Message Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - create conversation
    func createConversation(userId : String,completion:@escaping(ISMChat_CreateConversationResponse?)->()){
        var body : [String : Any]
        //        let metaData : [String : Any] = [:]
        body = ["typingEvents" : true ,
                "readEvents" : true,
                "pushNotifications" : true,
                "members" : [userId],
                "isGroup" : false,
                "conversationType" : 0] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.createConversation,httpMethod: .post,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("Create Conversation Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    
    //MARK: - get all messages not delivered yet
    func getAllMessagesWhichWereSendToMeWhenOfflineMarkThemAsDelivered(myUserId : String,skip : Int = 0){
        let limit = 20
        let baseUrl = "\(ISMChat_NetworkServices.Urls.getMessagesInConersation)?senderIdsExclusive=true&deliveredToMe=false&senderIds=\(myUserId)&limit=\(limit)&skip=\(skip)&sort=-1"
        
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseUrl,httpMethod: .get) { (result : ISMChat_Response<ISMChat_Messages?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                print("success")
                let filteredMessages = data?.messages?.filter { message in
                    return message.action != ISMChat_ActionType.userBlock.value &&
                    message.action != ISMChat_ActionType.userUnblock.value &&
                    message.action != ISMChat_ActionType.userBlockConversation.value &&
                    message.action != ISMChat_ActionType.userUnblockConversation.value &&
                    message.action != ISMChat_ActionType.deleteConversationLocally.value &&
                    message.action != ISMChat_ActionType.conversationTitleUpdated.value &&
                    message.action != ISMChat_ActionType.conversationImageUpdated.value &&
                    message.action != ISMChat_ActionType.conversationCreated.value &&
                    message.action != ISMChat_ActionType.membersAdd.value &&
                    message.action != ISMChat_ActionType.memberLeave.value &&
                    message.action != ISMChat_ActionType.addAdmin.value &&
                    message.action != ISMChat_ActionType.removeAdmin.value &&
                    message.action != ISMChat_ActionType.membersRemove.value &&
                    message.action != ISMChat_ActionType.messageDetailsUpdated.value &&
                    message.action != ISMChat_ActionType.reactionAdd.value &&
                    message.action != ISMChat_ActionType.reactionRemove.value &&
                    message.action != ISMChat_ActionType.conversationSettingsUpdated.value &&
                    message.action != ISMChat_ActionType.meetingCreated.value &&
                    message.action != ISMChat_ActionType.meetingEndedDueToRejectionByAll.value &&
                    message.action != ISMChat_ActionType.meetingEndedDueToNoUserPublishing.value &&
                    message.action != ISMChat_ActionType.userUpdate.value
                }
                if let messagesToDeliver = filteredMessages {
                    for message in messagesToDeliver {
                        guard let conversationId = message.conversationId,
                              let messageId = message.messageId else {
                            continue // Skip this message if conversationId or messageId is nil
                        }
                        
                        let myUserId = self.ismChatSDK?.getUserSession().getUserId() ?? ""
                        
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
                ISMChat_Helper.print("get all messages Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    
    //MARK: - mark message as read
    func markMessagesAsRead(conversationId : String){
        var body : [String : Any]
        let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
        body = ["conversationId" : conversationId ,
                "timestamp" : timeStamp] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.markMessageAsRead,httpMethod: .put,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                ISMChat_Helper.print("Mark Message Read Api succedded -----> \(String(describing: data?.msg))")
            case .failure(let error):
                ISMChat_Helper.print("Mark Message Read Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - read message indicator
    func readMessageIndicator(conversationId : String,messageId : String,completion:@escaping(Bool?)->()){
        var body : [String : Any]
        body = ["conversationId" : conversationId ,
                "messageId" : messageId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.readMessageIndicator,httpMethod: .put,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                ISMChat_Helper.print("Read Message Indicator Api succedded -----> \(String(describing: data?.msg))")
                completion(true)
            case .failure(let error):
                ISMChat_Helper.print("Read Message Indicator Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - typing message indicator
    func typingMessageIndicator(conversationId : String){
        var body : [String : Any]
        body = ["conversationId" : conversationId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.typingMessageIndicator,httpMethod: .post,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                ISMChat_Helper.print("Typing Message Indicator Api succedded -----> \(String(describing: data?.msg))")
            case .failure(let error):
                ISMChat_Helper.print("Typing Message Indicator Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - delivered message indicator
    func deliveredMessageIndicator(conversationId : String,messageId : String,completion:@escaping(Bool?)->()){
        var body : [String : Any]
        body = ["conversationId" : conversationId ,
                "messageId" : messageId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.deliveredMessageIndicator,httpMethod: .put,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                ISMChat_Helper.print("Delivered Message Indicator Api succedded -----> \(String(describing: data?.msg))")
                completion(true)
            case .failure(let error):
                ISMChat_Helper.print("Delivered Message Indicator Api failed -----> \(String(describing: error))")
                completion(true)
            }
        }
    }
}

extension ChatsViewModel{
    func getSectionMessage(for chat : [MessagesDB]) -> [[MessagesDB]] {
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
