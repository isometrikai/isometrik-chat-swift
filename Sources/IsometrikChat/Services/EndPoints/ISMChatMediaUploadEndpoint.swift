//
//  File.swift
//  
//
//  Created by Rasika Bharati on 30/08/24.
//

import Foundation

enum ISMChatMediaUploadEndpoint : ISMChatURLConvertible {
    
    case messageMediaUpload
    case conversationProfileUpload(mediaExtension: String,conversationType: Int,newConversation : Bool,conversationTitle: String)
    
    var baseURL: URL {
        return URL(string:ISMChatSdk.getInstance().getChatClient().getConfigurations().projectConfig.origin)!
    }
    
    var path: String {
        switch self {
        case .messageMediaUpload:
            return "/chat/messages/presignedurls"
        case .conversationProfileUpload:
            return "/chat/conversation/presignedurl"
        }
    }
    
    var method: ISMChatHTTPMethod {
        switch self {
        case .messageMediaUpload:
            return .post
        case .conversationProfileUpload:
            return .get
        }
    }
    
    var queryParams: [String: String]? {
        switch self {
        case .messageMediaUpload:
            return [:]
        case .conversationProfileUpload(let mediaExtension, let conversationType, let newConversation, let conversationTitle):
            var params : [String : String] = [
                "mediaExtension" : "\(mediaExtension)",
                "conversationType" : "\(conversationType)",
                "newConversation" : "\(newConversation)",
                "conversationTitle" : "\(conversationTitle)"
            ]
            return params
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .messageMediaUpload,.conversationProfileUpload:
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
