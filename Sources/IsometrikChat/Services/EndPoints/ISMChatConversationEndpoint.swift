//
//  File.swift
//  
//
//  Created by Rasika Bharati on 30/08/24.
//

import Foundation


enum ISMChatConversationEndpoint : ISMChatURLConvertible {
    
    case getconversationList(includeConversationStatusMessagesInUnreadMessagesCount: Bool,skip :Int,searchTag : String)
    case getconversationListWithCustomType(includeConversationStatusMessagesInUnreadMessagesCount: Bool,customType: String,searchTag : String,skip :Int)
    case createConversation
    case conversationDetail(conversationId: String,includeMembers:Bool,isGroup: Bool)
    case updateConversationDetail
    case deleteConversationLocally(conversationId: String)
    case clearConversationMessages(conversationId: String)
    case updateConversationSetting
    case unreadConversationCount
    
    
    var baseURL: URL {
        return URL(string:ISMChatSdk.getInstance().getChatClient().getConfigurations().projectConfig.origin)!
    }
    
    var path: String {
        switch self {
        case .getconversationList:
            return "/chat/conversations"
        case .getconversationListWithCustomType:
            return "/chat/conversations"
        case .createConversation:
            return "/chat/conversation"
        case .conversationDetail(let conversationId,_,_):
            return "/chat/conversation/details/" + "\(conversationId)"
        case .updateConversationDetail:
            return "/chat/conversation/details"
        case .deleteConversationLocally:
            return "/chat/conversation/local"
        case .clearConversationMessages:
            return "/chat/conversation/clear"
        case .updateConversationSetting:
            return "/chat/conversation/settings"
        case .unreadConversationCount:
            return "/chat/conversations/unread/count"
        }
    }
    
    var method: ISMChatHTTPMethod {
        switch self {
        case .getconversationList:
            return .get
        case .getconversationListWithCustomType:
            return .get
        case .createConversation:
            return .post
        case .conversationDetail:
            return .get
        case .updateConversationDetail:
            return .patch
        case .deleteConversationLocally:
            return .delete
        case .clearConversationMessages:
            return .delete
        case .updateConversationSetting:
            return .patch
        case .unreadConversationCount:
            return .get
        }
    }
    
    var queryParams: [String: String]? {
        switch self {
        case .getconversationList(let includeConversationStatusMessagesInUnreadMessagesCount,let skip,let searchTag):
            var params : [String : String] = [
                "includeConversationStatusMessagesInUnreadMessagesCount" : "\(includeConversationStatusMessagesInUnreadMessagesCount)",
                "skip" : "\(skip)"
            ]
            if !searchTag.isEmpty{
                params.updateValue(searchTag, forKey: "searchTag")
            }
            return params
        case .getconversationListWithCustomType(let includeConversationStatusMessagesInUnreadMessagesCount, let customType, let searchTag, let skip):
                                                   
            var params : [String : String] = [
                "includeConversationStatusMessagesInUnreadMessagesCount" : "\(includeConversationStatusMessagesInUnreadMessagesCount)",
                "skip" : "\(skip)"
            ]
            if !customType.isEmpty{
                params.updateValue(customType, forKey: "customType")
            }
            if !searchTag.isEmpty{
                params.updateValue(searchTag, forKey: "searchTag")
            }
            return params
            
        case .createConversation:
            return [:]
        case .conversationDetail(_,let includeMembers,let isGroup):
            if isGroup == true{
                let params : [String : String] = [
                    "includeMembers" : "\(includeMembers)"
                ]
                return params
            }else{
                return [:]
            }
        case .updateConversationDetail:
            return  [:]
        case .deleteConversationLocally(let conversationId):
            let params : [String : String] = [
                "conversationId" : "\(conversationId)"
            ]
            return params
        case .clearConversationMessages(let conversationId):
            let params : [String : String] = [
                "conversationId" : "\(conversationId)"
            ]
            return params
        case .updateConversationSetting:
            return [:]
        case .unreadConversationCount:
            return ["includeConversationStatusMessagesInUnreadMessagesCount" : "false", "hidden" : "false"]
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .getconversationList,.getconversationListWithCustomType,.createConversation,.conversationDetail,.updateConversationDetail,.deleteConversationLocally,.clearConversationMessages,.updateConversationSetting,.unreadConversationCount:
            return ["userToken": ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig.userToken,
                    "userSecret": ISMChatSdk.getInstance().getChatClient().getConfigurations().projectConfig.userSecret,
                    "projectId": ISMChatSdk.getInstance().getChatClient().getConfigurations().projectConfig.projectId,
                    "licenseKey": ISMChatSdk.getInstance().getChatClient().getConfigurations().projectConfig.licenseKey,
                    "appSecret": ISMChatSdk.getInstance().getChatClient().getConfigurations().projectConfig.appSecret,
                    "accept" : "application/json",
                    "Content-Type" : "application/json"]
        }
    }
}
