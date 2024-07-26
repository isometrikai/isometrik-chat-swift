//
//  RealmManagerMedia.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift

extension RealmManager{
    
    //MARK: - save media locally
    public func saveMedia(arr:[ISMChatAttachment], conId:String, customType:String,sentAt:Double,messageId:String,userName:String,fromView : Bool) {
        if let localRealm = localRealm {
            do {
                if fromView == true{
                    try localRealm.write {
                        saveMediaDetail(arr: arr, localRealm: localRealm, conId: conId, customType: customType, sentAt: sentAt, messageId: messageId, userName: userName)
                    }
                }else{
                    saveMediaDetail(arr: arr, localRealm: localRealm, conId: conId, customType: customType, sentAt: sentAt, messageId: messageId, userName: userName)
                }
                
            } catch {
                print("Error adding task to Realm: \(error)")
            }
        }
    }
    
    //MARK: - save media detail locally
    public func saveMediaDetail(arr : [ISMChatAttachment],localRealm : Realm, conId:String, customType:String,sentAt:Double,messageId:String,userName:String){
        for value in arr {
            let isAvailable = localRealm.objects(MediaDB.self).filter(NSPredicate(format: "messageId == %@", (messageId )))
            if isAvailable.isEmpty {
                let obj = MediaDB()
                
                obj.conversationId = conId
                
                obj.attachmentType = value.attachmentType ?? 0
                obj.extensions  = value.extensions ?? ""
                obj.mediaId  = value.mediaId ?? ""
                obj.mediaUrl  = value.mediaUrl ?? ""
                obj.mimeType  = value.mimeType ?? ""
                obj.name  = value.name ?? ""
                obj.size  = value.size ?? 0
                obj.thumbnailUrl  = value.thumbnailUrl ?? ""
                obj.caption = value.caption ?? ""
                obj.customType = customType
                obj.sentAt = sentAt
                obj.messageId = messageId
                obj.userName = userName
                localRealm.add(obj)
            }
        }
    }
    
    //MARK: - fetch photo and videos
    public func fetchPhotosAndVideos(conId:String)  {
        if let localRealm = localRealm {
            let predicate1 = NSPredicate(format: "customType == %@", ISMChatMediaType.Image.value)
            let predicate2 = NSPredicate(format: "customType == %@", ISMChatMediaType.Video.value)
            let predicate3 = NSPredicate(format: "customType == %@", ISMChatMediaType.gif.value)
            let predicateCompound = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1,predicate2,predicate3])
            
            let media = Array(localRealm.objects(MediaDB.self)
                .filter(NSPredicate(format: "conversationId == %@", conId))
                .filter(predicateCompound))
            self.medias = media
        }
    }
    
    //MARK: - fetch files
    public func fetchFiles(conId:String)  {
        if let localRealm = localRealm {
            let media = Array(localRealm.objects(MediaDB.self)
                .filter(NSPredicate(format: "conversationId == %@", conId))
                .filter(NSPredicate(format: "customType == %@", ISMChatMediaType.File.value)))
            self.filesMedia = media
        }
    }
    
    //MARK: - fetch links
    public func fetchLinks(conId: String) {
        if let localRealm = localRealm {
            let messages = Array(localRealm.objects(MessagesDB.self)
                .filter(NSPredicate(format: "conversationId == %@", conId)))
            
            // Filter messages that contain "www" or "https" and do not contain "map"
            let filteredMessages = messages.filter { message in
                return message.body.isValidURL && !message.body.contains("map")
            }
            
            self.linksMedia = filteredMessages
        }
    }
}
