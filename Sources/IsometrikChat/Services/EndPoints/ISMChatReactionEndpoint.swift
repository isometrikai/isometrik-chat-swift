//
//  File.swift
//  
//
//  Created by Rasika Bharati on 30/08/24.
//

import Foundation


enum ISMChatReactionEndpoint : ISMChatURLConvertible {
    case sendReaction
    case getReaction(reaction: String)
    case removeReaction(reaction: String)
    
    var baseURL: URL {
        return URL(string:ISMChatSdk.getInstance().getChatClient().getConfigurations().projectConfig.origin)!
    }
    
    var path: String {
        switch self {
        case .sendReaction:
            return "/chat/reaction"
        case .getReaction(let reaction):
            return "/chat/reaction" + "\(reaction)"
        case .removeReaction(let reaction):
            return "/chat/reaction" + "\(reaction)"
        }
    }
    
    var method: ISMChatHTTPMethod {
        switch self {
        case .sendReaction:
            return .post
        case .getReaction:
            return .get
        case .removeReaction:
            return .delete
        }
    }
    
    var queryParams: [String: String]? {
        switch self {
        case .sendReaction:
            return [:]
        case .getReaction(_):
            return [:]
        case .removeReaction(_):
            return [:]
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .sendReaction,.getReaction,.removeReaction:
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
