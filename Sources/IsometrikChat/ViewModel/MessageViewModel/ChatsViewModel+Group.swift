//
//  ChatsViewModelGroup.swift
//  ISMChatSdk
//
//  Created by Rasika on 12/06/24.
//

import Foundation
import UIKit
import Alamofire

extension ChatsViewModel{
    
    //MARK: - craete group
    public func createGroup(members : [String],groupTitle : String,groupImage : String,completion:@escaping(ISMChatCreateConversationResponse?)->()){
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
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.createConversation,httpMethod: .post,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChatHelper.print("Create Group Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - add member in group
    public func addMembersInAlredyExistingGroup(members : [String],conversationId : String,completion:@escaping(ISMChatCreateConversationResponse?)->()){
        var body : [String : Any]
        body = ["members" : members,"conversationId" : conversationId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.groupMembers,httpMethod: .put,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChatHelper.print("Add member Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - make user as group admin
    public func addGroupAdmin(memberId : String,conversationId : String,completion:@escaping(ISMChatCreateConversationResponse?)->()){
        var body : [String : Any]
        body = ["memberId" : memberId,"conversationId" : conversationId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.groupAdmin,httpMethod: .put,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChatHelper.print("add group admin member Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - remove user as group admin
    public func removeGroupAdmin(memberId : String,conversationId : String,completion:@escaping(ISMChatCreateConversationResponse?)->()){
        var body : [String : Any]
        body = ["memberId" : memberId,"conversationId" : conversationId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.groupAdmin,httpMethod: .delete,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChatHelper.print("remove group admin member Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - remove user as group
    public func removeUserFromGroup(members : String,conversationId : String,completion:@escaping(ISMChatCreateConversationResponse?)->()){
        var body : [String : Any]
        body = ["members" : members,"conversationId" : conversationId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.groupMembers,httpMethod: .delete,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChatHelper.print("remove member Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - get group members
    public func getGroupMembers(conversationId : String,completion:@escaping(ISMGroupMember?)->()){
        let baseUrl = "\(ISMChatNetworkServices.Urls.groupMembers)?conversationId=\(conversationId)"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseUrl,httpMethod: .get) { (result : ISMChatResponse<ISMGroupMember?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChatHelper.print("get member Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - update group title
    public func updateGroupTitle(title : String,conversationId : String,completion:@escaping(ISMChatCreateConversationResponse?)->()){
        var body : [String : Any]
        body = ["conversationTitle" : title,"conversationId" : conversationId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.groupTitle,httpMethod: .patch,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChatHelper.print("update title Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - update group image
    public func updateGroupImage(image : String,conversationId : String,completion:@escaping(ISMChatCreateConversationResponse?)->()){
        var body : [String : Any]
        body = ["conversationImageUrl" : image,"conversationId" : conversationId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.groupImage,httpMethod: .patch,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChatHelper.print("update image Api fail -----> \(String(describing: error))")
            }
        }
    }
}
