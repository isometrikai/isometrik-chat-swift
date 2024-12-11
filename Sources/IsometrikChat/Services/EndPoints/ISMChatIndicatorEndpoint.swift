//
//  File.swift
//  
//
//  Created by Rasika Bharati on 02/09/24.
//

import Foundation

enum ISMChatIndicatorEndpoint : ISMChatURLConvertible {
    case typingIndicator
    case deliveredIndicator
    case readIndicator
    
    var baseURL: URL {
        return URL(string:ISMChatSdk.getInstance().getChatClient()?.getConfigurations().projectConfig.origin ?? "")!
    }
    
    var path: String {
        switch self {
        case .typingIndicator:
            return "/chat/indicator/typing"
        case .deliveredIndicator:
            return "/chat/indicator/delivered"
        case .readIndicator:
            return "/chat/indicator/read"
        }
    }
    
    var method: ISMChatHTTPMethod {
        switch self {
        case .typingIndicator:
            return .post
        case .deliveredIndicator:
            return .put
        case .readIndicator:
            return .put
        }
    }
    
    var queryParams: [String: String]? {
        switch self {
        case .typingIndicator:
            return [:]
        case .deliveredIndicator:
            return [:]
        case .readIndicator:
            return [:]
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .typingIndicator,.deliveredIndicator,.readIndicator:
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
