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
        
        
        let endPoint = ISMChatGroupEndpoint.createGroup
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("Create Group Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - add member in group
    public func addMembersInAlredyExistingGroup(members : [String],conversationId : String,completion:@escaping(ISMChatCreateConversationResponse?)->()){
        var body : [String : Any]
        body = ["members" : members,"conversationId" : conversationId] as [String : Any]
        
        let endPoint = ISMChatGroupEndpoint.addMembersInGroup
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("Add member Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - make user as group admin
    public func addGroupAdmin(memberId : String,conversationId : String,completion:@escaping(ISMChatCreateConversationResponse?)->()){
        var body : [String : Any]
        body = ["memberId" : memberId,"conversationId" : conversationId] as [String : Any]
        
        let endPoint = ISMChatGroupEndpoint.addMemberAsGroupAdmin
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("add group admin member Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - remove user as group admin
    public func removeGroupAdmin(memberId : String,conversationId : String,completion:@escaping(ISMChatCreateConversationResponse?)->()){
        var body : [String : Any]
        body = ["memberId" : memberId,"conversationId" : conversationId] as [String : Any]
        
        let endPoint = ISMChatGroupEndpoint.removeMemberAsGroupAdmin
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("remove group admin member Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - remove user as group
    public func removeUserFromGroup(members : String,conversationId : String,completion:@escaping(ISMChatCreateConversationResponse?)->()){
        var body : [String : Any]
        body = ["members" : members,"conversationId" : conversationId] as [String : Any]
        
        
        let endPoint = ISMChatGroupEndpoint.removeMemberFromGroup
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("remove member Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - get group members
    public func getGroupMembers(conversationId : String,completion:@escaping(ISMGroupMember?)->()){
        
        let endPoint = ISMChatGroupEndpoint.getMembersInGroup(conversationId: conversationId)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMGroupMember, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("get member Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - update group title
    public func updateGroupTitle(title : String,conversationId : String,completion:@escaping(ISMChatCreateConversationResponse?)->()){
        var body : [String : Any]
        body = ["conversationTitle" : title,"conversationId" : conversationId] as [String : Any]
        
        let endPoint = ISMChatGroupEndpoint.updateGroupTitle
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("update title Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - update group image
    public func updateGroupImage(image : String,conversationId : String,completion:@escaping(ISMChatCreateConversationResponse?)->()){
        var body : [String : Any]
        body = ["conversationImageUrl" : image,"conversationId" : conversationId] as [String : Any]
        
        let endPoint = ISMChatGroupEndpoint.updateGroupImage
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("update image Api fail -----> \(String(describing: error))")
            }
        }
    }
    //MARK: - EXIT GROUP
    
    public func exitGroup(conversationId: String, completion:@escaping()->()){
        
        let endPoint = ISMChatGroupEndpoint.exitGroup(conversationId: conversationId)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatUsers, ISMChatNewAPIError>) in
            switch result{
            case .success(_,_) :
                completion()
            case .failure(let error) :
                ISMChatHelper.print("exit group Api failed -----> \(String(describing: error))")
            }
        }
    }
}
