//
//  File.swift
//  
//
//  Created by Rasika Bharati on 30/08/24.
//

import Foundation



enum ISMChatGroupEndpoint : ISMChatURLConvertible {
    
    case createGroup
    case addMembersInGroup
    case addMemberAsGroupAdmin
    case removeMemberAsGroupAdmin
    case removeMemberFromGroup
    case getMembersInGroup(conversationId: String)
    case updateGroupTitle
    case updateGroupImage
    case exitGroup(conversationId: String)
    case eligibleUsersToAddInGroup(conversationId: String,sort: Int,skip: Int,limit: Int,searchTag: String)
    
    
    var baseURL: URL {
        return URL(string:ISMChatSdk.getInstance().getChatClient()?.getConfigurations().projectConfig.origin ?? "")!
    }
    
    var path: String {
        switch self {
        case .createGroup:
            return "/chat/conversation"
        case .addMembersInGroup:
            return "/chat/conversation/members"
        case .addMemberAsGroupAdmin:
            return "/chat/conversation/admin"
        case .removeMemberAsGroupAdmin:
            return "/chat/conversation/admin"
        case .removeMemberFromGroup:
            return "/chat/conversation/members"
        case .getMembersInGroup:
            return "/chat/conversation/members"
        case .updateGroupTitle:
            return "/chat/conversation/title"
        case .updateGroupImage:
            return "/chat/conversation/image"
        case .exitGroup:
            return "/chat/conversation/leave"
        case .eligibleUsersToAddInGroup:
            return "/chat/conversation/eligible/members"
        }
    }
    
    var method: ISMChatHTTPMethod {
        switch self {
        case .createGroup:
            return .post
        case .addMembersInGroup:
            return .put
        case .addMemberAsGroupAdmin:
            return .put
        case .removeMemberAsGroupAdmin:
            return .delete
        case .removeMemberFromGroup:
            return .delete
        case .getMembersInGroup:
            return .get
        case .updateGroupTitle:
            return .patch
        case .updateGroupImage:
            return .patch
        case .exitGroup:
            return .delete
        case .eligibleUsersToAddInGroup:
            return .get
        }
    }
    
    var queryParams: [String: String]? {
        switch self {
        case .createGroup:
            return [:]
        case .addMembersInGroup:
            return [:]
        case .addMemberAsGroupAdmin:
            return [:]
        case .removeMemberAsGroupAdmin:
            return [:]
        case .removeMemberFromGroup:
            return [:]
        case .getMembersInGroup(let conversationId):
            let params : [String : String] = [
                "conversationId" : "\(conversationId)"
            ]
            return params
        case .updateGroupTitle:
            return [:]
        case .updateGroupImage:
            return [:]
        case .exitGroup(let conversationId):
            let params : [String : String] = [
                "conversationId" : "\(conversationId)"
            ]
            return params
        case .eligibleUsersToAddInGroup(conversationId: let conversationId, sort: let sort, skip: let skip, limit: let limit, searchTag: let searchTag):
            var params : [String : String] = [
                "conversationId" : "\(conversationId)",
                "sort" : "\(sort)",
                "skip" : "\(skip)",
                "limit" : "\(limit)"
            ]
            if !searchTag.isEmpty{
                params.updateValue(searchTag, forKey: "searchTag")
            }
            return params
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .createGroup,.addMembersInGroup,.addMemberAsGroupAdmin,.removeMemberAsGroupAdmin,.removeMemberFromGroup,.getMembersInGroup,.updateGroupTitle,.updateGroupImage,.exitGroup,.eligibleUsersToAddInGroup:
            return ["userToken": ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userToken ?? "",
                    "userSecret": ISMChatSdk.getInstance().getChatClient()?.getConfigurations().projectConfig.userSecret ?? "",
                    "projectId": ISMChatSdk.getInstance().getChatClient()?.getConfigurations().projectConfig.projectId ?? "",
                    "licenseKey": ISMChatSdk.getInstance().getChatClient()?.getConfigurations().projectConfig.licenseKey ?? "",
                    "appSecret": ISMChatSdk.getInstance().getChatClient()?.getConfigurations().projectConfig.appSecret ?? "",
                    "accept" : "application/json",
                    "Content-Type" : "application/json"]
        }
    }
}






