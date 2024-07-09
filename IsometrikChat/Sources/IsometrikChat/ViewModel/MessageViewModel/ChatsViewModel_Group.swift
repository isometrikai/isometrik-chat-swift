//
//  ChatsViewModel_Group.swift
//  ISMChatSdk
//
//  Created by Rasika on 12/06/24.
//

import Foundation
import UIKit
import Alamofire

extension ChatsViewModel{
    
    //MARK: - craete group
    public func createGroup(members : [String],groupTitle : String,groupImage : String,completion:@escaping(ISMChat_CreateConversationResponse?)->()){
        var body : [String : Any]
        let metaData : [String : Any] = [:]
        body = ["typingEvents" : true ,
                "readEvents" : true,
                "pushNotifications" : true,
                "members" : members,
                "isGroup" : true,
                "conversationType" : 0,
                "searchableTags" : [""],
                "conversationImageUrl" : groupImage,
                "conversationTitle" : groupTitle,
                "metaData" : metaData] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.createConversation,httpMethod: .post,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("Create Group Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - add member in group
    public func addMembersInAlredyExistingGroup(members : [String],conversationId : String,completion:@escaping(ISMChat_CreateConversationResponse?)->()){
        var body : [String : Any]
        body = ["members" : members,"conversationId" : conversationId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.groupMembers,httpMethod: .put,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("Add member Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - make user as group admin
    public func addGroupAdmin(memberId : String,conversationId : String,completion:@escaping(ISMChat_CreateConversationResponse?)->()){
        var body : [String : Any]
        body = ["memberId" : memberId,"conversationId" : conversationId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.groupAdmin,httpMethod: .put,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("add group admin member Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - remove user as group admin
    public func removeGroupAdmin(memberId : String,conversationId : String,completion:@escaping(ISMChat_CreateConversationResponse?)->()){
        var body : [String : Any]
        body = ["memberId" : memberId,"conversationId" : conversationId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.groupAdmin,httpMethod: .delete,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("remove group admin member Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - remove user as group
    public func removeUserFromGroup(members : String,conversationId : String,completion:@escaping(ISMChat_CreateConversationResponse?)->()){
        var body : [String : Any]
        body = ["members" : members,"conversationId" : conversationId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.groupMembers,httpMethod: .delete,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("remove member Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - get group members
    public func getGroupMembers(conversationId : String,completion:@escaping(ISMGroupMember?)->()){
        let baseUrl = "\(ISMChat_NetworkServices.Urls.groupMembers)?conversationId=\(conversationId)"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseUrl,httpMethod: .get) { (result : ISMChat_Response<ISMGroupMember?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("get member Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - update group title
    public func updateGroupTitle(title : String,conversationId : String,completion:@escaping(ISMChat_CreateConversationResponse?)->()){
        var body : [String : Any]
        body = ["conversationTitle" : title,"conversationId" : conversationId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.groupTitle,httpMethod: .patch,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("update title Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - update group image
    public func updateGroupImage(image : String,conversationId : String,completion:@escaping(ISMChat_CreateConversationResponse?)->()){
        var body : [String : Any]
        body = ["conversationImageUrl" : image,"conversationId" : conversationId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.groupImage,httpMethod: .patch,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("update image Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - upload group image to cloudinary
    public func uploadGroupImage(image: UIImage,userEmail : String,completion:@escaping(String?)->()){
        let baseURL = "\(ISMChat_NetworkServices.Urls.preassignedUrlCreate)?userIdentifier=\(userEmail)&mediaExtension=png"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChat_Response<ISMChat_PresignedUrlDetail?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                if let url = data?.presignedUrl, let urlData = image.pngData(){
                    AF.upload(urlData, to: url, method: .put, headers: [:]).responseData { response in
                        ISMChat_Helper.print(response)
                        if response.response?.statusCode == 200{
                            completion(data?.mediaUrl)
                        }else{
                            ISMChat_Helper.print("Error in Image upload")
                        }
                    }
                }
            case .failure(let error):
                ISMChat_Helper.print("Error in Image upload Api failed -----> \(String(describing: error))")
            }
        }
    }
}
