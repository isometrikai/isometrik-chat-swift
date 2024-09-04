//
//  File.swift
//
//
//  Created by Rasika Bharati on 08/08/24.
//

import Foundation
import UIKit
import Alamofire
//import TUSKit
//import TransloaditKit


extension ChatsViewModel{
    
    //MARK: - upload image, video, doc
    public func upload(messageKind : ISMChatMessageType,conversationId :  String,conversationType : Int? = 0,image : URL?,document : URL?,video : URL?,audio : URL?,mediaName : String,isfromDocument : Bool? = false,completion:@escaping(ISMChatPresignedUrlDetail?, String , Int)->()){
        var mediaType : Int = 0
        var mediaData : Data = Data()
        //params
        var params = [String: Any]()
        params["conversationId"] = conversationId
        //Type of the conversation for which to fetch presigned urls for attachments.0- Conversation, 1- Bulk messaging, 2- Groupcast
        params["conversationType"] = conversationType
        
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
                if let myImage = ISMChatHelper.compressImage(image: image){
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
        
        
        let endPoint = ISMChatMediaUploadEndpoint.messageMediaUpload
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: params)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatPresignedUrl, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                if let url = data.presignedUrls?.first?.mediaPresignedUrl{
                    AF.upload(mediaData, to: url, method: .put, headers: [:]).responseData { response in
                        ISMChatHelper.print(response)
                        if response.response?.statusCode == 200{
                            completion(data.presignedUrls?.first, mediaName, mediaData.count)
                        }else{
                            ISMChatHelper.print("Error in Image upload")
                        }
                    }
                }
            case .failure(let error) :
                ISMChatHelper.print(error ?? "Error")
            }
        }
    }
    
    
    
    
    //MARK: - upload conversation create image
    public func uploadConversationImage(image: UIImage,conversationType : Int,newConversation : Bool,conversationId : String,conversationTitle:String,completion:@escaping(String?)->()){
        //         conversationType
        //        "0" ->#Conversation
        //        "1" ->"BroadcastLists"
        //        "2" ->#Groupcast
        
        let endPoint = ISMChatMediaUploadEndpoint.conversationProfileUpload(mediaExtension: "png", conversationType: conversationType, newConversation: newConversation, conversationTitle: conversationTitle,conversationId: conversationId)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatPresignedUrlDetail, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                if let url = data.presignedUrl, let urlData = image.pngData(){
                    AF.upload(urlData, to: url, method: .put, headers: [:]).responseData { response in
                        ISMChatHelper.print(response)
                        if response.response?.statusCode == 200{
                            completion(data.mediaUrl)
                        }else{
                            ISMChatHelper.print("Error in Image upload")
                        }
                    }
                }
            case .failure(let error) :
                ISMChatHelper.print("Error in Image upload Api failed -----> \(String(describing: error))")
            }
        }
    }
}
