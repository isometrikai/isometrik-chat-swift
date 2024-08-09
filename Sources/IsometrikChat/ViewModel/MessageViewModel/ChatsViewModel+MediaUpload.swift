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
        
//        
//        if self.ismChatSDK?.checkAllowUpload() == true{
//            if messageKind == .document{
//                if let document = document {
//                    if document.startAccessingSecurityScopedResource() {
//                        guard let restoredData = try? Data(contentsOf: document) else {
//                            return
//                        }
//                        mediaData = restoredData
//                    }
//                    document.stopAccessingSecurityScopedResource()
//                    uploadFiles(file: document) { data, error in
//                        completion(ISMChatPresignedUrlDetail(mediaUrl: data?.url ?? "", mediaId: "\(UUID())"), mediaName, mediaData.count)
//                    }
//                }
//            }else if messageKind == .photo{
//                
//                
//                if let image = video {
//                    if isfromDocument == true{
//                        guard image.startAccessingSecurityScopedResource() else {
//                            return
//                        }
//                        if let myImage = ISMChatHelper.compressImage(image: image){
//                            uploadImage(image: myImage) { data, error in
//                                completion(ISMChatPresignedUrlDetail(mediaUrl: data?.url ?? "", mediaId: "\(UUID())"), mediaName, mediaData.count)
//                            }
//                        }
//                    }
//                    mediaData = try! Data(contentsOf: image)
//                }else if let image = image{
//                    if let myImage = ISMChatHelper.compressImage(image: image){
//                        if let dataobj = myImage.jpegData(compressionQuality: 0.1){
//                            mediaData = dataobj
//                            uploadImage(image: myImage) { data, error in
//                                completion(ISMChatPresignedUrlDetail(mediaUrl: data?.url ?? "", mediaId: "\(UUID())"), mediaName, mediaData.count)
//                            }
//                        }
//                    }
//                }
//            }else if messageKind == .video{
//                if let video = video {
//                    mediaData =  try! Data(contentsOf: video)
//                    uploadVideo(video: video) { data, error in
//                        completion(ISMChatPresignedUrlDetail(mediaUrl: data?.url ?? "", mediaId: "\(UUID())"), mediaName, mediaData.count)
//                    }
//                }
//            }else if messageKind == .audio{
//                if let audio = audio {
//                    mediaData =  try! Data(contentsOf: audio)
//                    uploadFiles(file: audio) { data, error in
//                        completion(ISMChatPresignedUrlDetail(mediaUrl: data?.url ?? "", mediaId: "\(UUID())"), mediaName, mediaData.count)
//                    }
//                }
//            }
//            
//            
//            
//        }else{
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
            ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.presignedUrl,httpMethod: .post,params: params) { (result : ISMChatResponse<ISMChatPresignedUrl?,ISMChatErrorData?>) in
                switch result{
                case .success(let data):
                    if let url = data?.presignedUrls?.first?.mediaPresignedUrl{
                        AF.upload(mediaData, to: url, method: .put, headers: [:]).responseData { response in
                            ISMChatHelper.print(response)
                            if response.response?.statusCode == 200{
                                completion(data?.presignedUrls?.first, mediaName, mediaData.count)
                            }else{
                                ISMChatHelper.print("Error in Image upload")
                            }
                        }
                    }
                case .failure(let error):
                    ISMChatHelper.print(error ?? "Error")
                }
            }
        }
    }
    
    
//    
//    
//    func uploadImage(image: UIImage,isForReels:Bool = false,isForCover:Bool? = false,compressionQuality:Double = 1.0,progress: ((Progress) -> Void)? = nil, complication:@escaping(CLDUploadResult?, NSError?)->Void){
//        guard  let data = self.ismChatSDK?.getUploadMediaConfig()  else {return}
//        self.isVideo = false
//        self.isFile = false
//        
//        do {
//            self.tusClient = try TUSClient(
//                server: URL(string: data.uploadUrl)!,
//                sessionIdentifier: "TUS DEMO"
//            )
//            self.tusClient?.delegate = self
//        } catch {
//            assertionFailure("Could not fetch failed id's from disk, or could not instantiate TUSClient \(error)")
//        }
//        
//        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
//            return
//        }
//        
//        
//        
//        
//        do {
//            try tusClient?.upload(data: imageData,customHeaders: data.headers)
//        }catch let err {
//            
//        }
//        self.callBack = { url, isVideo in
//            complication(CLDUploadResult(url: url, secureUrl: url, height: 100, width: 100),nil)
//        }
//        var progressObj = Progress()
//        self.callBackProgress = { uploaded, totalProgress, isVideo in
//            progressObj.totalUnitCount = Int64(totalProgress)
//            progressObj.completedUnitCount = Int64(uploaded)
//            if progress != nil {
//                progress!(progressObj)
//            }
//        }
//    }
//    
//    
//    func uploadVideo(video: URL,isForReels: Bool = false, progress: ((Progress) -> Void)? = nil, onCompletion: @escaping (CLDUploadResult?, NSError?) -> Void) {
//        
//        guard  let data = self.ismChatSDK?.getUploadMediaConfig()  else {return}
//        self.isVideo = true
//        self.isFile = false
//        
//        do {
//            self.tusClient = try TUSClient(
//                server: URL(string: data.uploadUrl)!,
//                sessionIdentifier: "TUS DEMO"
//            )
//            self.tusClient?.delegate = self
//        } catch {
//            assertionFailure("Could not fetch failed id's from disk, or could not instantiate TUSClient \(error)")
//        }
//        
//        
//        self.uploadVideo(url: video)
//        self.callBack = { url, isVideo in
//            onCompletion(CLDUploadResult(url: url, secureUrl: url, height: 100, width: 100),nil)
//        }
//        var progressObj = Progress()
//        self.callBackProgress = { uploaded, totalProgress, isVideo in
//            progressObj.totalUnitCount = Int64(totalProgress)
//            progressObj.completedUnitCount = Int64(uploaded)
//            if progress != nil {
//                progress!(progressObj)
//            }
//            
//        }
//    }
//    
//    
//    func uploadFiles(file: URL,isForReels: Bool = false, progress: ((Progress) -> Void)? = nil, onCompletion: @escaping (CLDUploadResult?, NSError?) -> Void) {
//        guard  let data = self.ismChatSDK?.getUploadMediaConfig()  else {return}
//        self.isFile = true
//        self.isVideo = false
//        
//        do {
//            self.tusClient = try TUSClient(
//                server: URL(string: data.uploadUrl)!,
//                sessionIdentifier: "TUS DEMO"
//            )
//            self.tusClient?.delegate = self
//        } catch {
//            assertionFailure("Could not fetch failed id's from disk, or could not instantiate TUSClient \(error)")
//        }
//        
//        
//        self.uploadFile(url: file)
//        self.callBack = { url, isVideo in
//            onCompletion(CLDUploadResult(url: url, secureUrl: url, height: 100, width: 100),nil)
//        }
//        var progressObj = Progress()
//        self.callBackProgress = { uploaded, totalProgress, isVideo in
//            progressObj.totalUnitCount = Int64(totalProgress)
//            progressObj.completedUnitCount = Int64(uploaded)
//            if progress != nil {
//                progress!(progressObj)
//            }
//            
//        }
//    }
//    
//    
//    // Upload Video To Tus Server
//    func uploadVideo(url: URL) {
//        guard  let data = self.ismChatSDK?.getUploadMediaConfig()  else {return}
//        let filesToUpload: [URL] = [url]
//        do {
//            try self.tusClient?.uploadFiles(filePaths: filesToUpload,customHeaders: data.headers)
//        }catch let err {
//            
//        }
//    }
//
//    
//    // Upload Video To Tus Server
//    func uploadFile(url: URL) {
//        guard  let data = self.ismChatSDK?.getUploadMediaConfig()  else {return}
//        let filesToUpload: [URL] = [url]
//        do {
//            try self.tusClient?.uploadFiles(filePaths: filesToUpload,customHeaders: data.headers)
//        }catch let err {
//            
//        }
//    }
//}
//
//
//
//struct CLDUploadResult {
//    var url:String?
//    var secureUrl:String = ""
//    var width:Int?
//    var height:Int?
//    var duration:Double?
//    
//    init(url: String,secureUrl: String, height: Int, width: Int) {
//        self.url = url
//        self.secureUrl = secureUrl
//        self.width = width
//        self.height = height
//        self.duration = 10.0
//    }
//}
//
//
//extension ChatsViewModel: TUSClientDelegate {
//    
//    public func uploadFailed(id: UUID, error: Error, context: [String : String]?, client: TUSKit.TUSClient) {
//        // Upload Failed
//        print("failed___\(error.localizedDescription)")
//    }
//    
//    public func fileError(error: TUSKit.TUSClientError, client: TUSKit.TUSClient) {
//        // Upload Failed due to file
//        print("failed___\(error.localizedDescription)")
//    }
//    
//    public func totalProgress(bytesUploaded: Int, totalBytes: Int, client: TUSKit.TUSClient) {
//        // Upload Progress
//    }
//    
//    
//    public func didStartUpload(id: UUID, context: [String : String]?, client: TUSKit.TUSClient) {
//        // Upload Start
//        
//    }
//    
//    public func didFinishUpload(id: UUID, url: URL, context: [String : String]?, client: TUSKit.TUSClient) {
//        // Upload Finished
//        
//        guard  let data = self.ismChatSDK?.getUploadMediaConfig()  else {return}
//        if isVideo {
//            if let fetchUrl = url.absoluteString.components(separatedBy: "/").last {
//                if let closure = self.callBack {
//                    closure("\(data.fetchUrl)/hls/\(fetchUrl)/master.m3u8",true)
//                }
//                
//            }
//        }else if self.isFile{
//            if let fetchUrl = url.absoluteString.components(separatedBy: "/").last {
//                if let closure = self.callBack {
//                    closure("\(data.fetchUrl)/\(fetchUrl)",false)
//                }
//            }
//        } else{
//            if let fetchUrl = url.absoluteString.components(separatedBy: "/").last {
//                if let closure = self.callBack {
//                    closure("\(data.fetchUrl)/cdn/\(fetchUrl)",false)
//                }
//            }
//        }
//    }
//    
//    public func progressFor(id: UUID, context: [String : String]?, bytesUploaded: Int, totalBytes: Int, client: TUSKit.TUSClient) {
//        DispatchQueue.main.async {
//            if let closure = self.callBackProgress {
//                closure(bytesUploaded,totalBytes,self.isVideo)
//            }
//        }
//    }
//}
//
