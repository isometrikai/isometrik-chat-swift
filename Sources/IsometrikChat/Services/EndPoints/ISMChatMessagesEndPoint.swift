//
//  File.swift
//
//
//  Created by Rasika Bharati on 29/08/24.
//

import Foundation


enum ISMChatMessagesEndpoint : ISMChatURLConvertible {
    
    case getMessages(conversationId: String,lastMessageTimestamp: String)
    case sendMessage
    case editMessage
    case deleteMessageForMe(conversationId: String,messageIds: String)
    case deleteMessageForEveryone(conversationId: String,messageIds: String)
    case forwardMessage
    
    var baseURL: URL {
        return URL(string:ISMChatSdk.getInstance().getChatClient().getConfigurations().projectConfig.origin)!
    }
    
    var path: String {
        switch self {
        case .getMessages:
            return "/chat/messages"
        case .editMessage:
            return "/chat/message"
        case .sendMessage:
            return "/chat/message"
        case .deleteMessageForMe:
            return "/chat/messages/self"
        case .deleteMessageForEveryone:
            return "/chat/messages/everyone"
        case .forwardMessage:
            return "/chat/message/forward"
        }
    }
    
    var method: ISMChatHTTPMethod {
        switch self {
        case .getMessages:
            return .get
        case .editMessage:
            return .patch
        case .sendMessage:
            return .post
        case .deleteMessageForMe:
            return .delete
        case .deleteMessageForEveryone:
            return .delete
        case .forwardMessage:
            return .post
        }
    }
    
    var queryParams: [String: String]? {
        switch self {
        case .getMessages(let conversationId, let lastMessageTimestamp):
            var params : [String : String] = [
                "conversationId" : "\(conversationId)"
            ]
            if !lastMessageTimestamp.isEmpty{
                params.updateValue(lastMessageTimestamp, forKey: "lastMessageTimestamp")
            }
            return params
        case .editMessage:
            return [:]
        case .sendMessage:
            return [:]
        case .deleteMessageForMe(conversationId: let conversationId, messageIds: let messageIds):
            var params : [String : String] = [
                "conversationId" : "\(conversationId)", "messageIds" : "\(messageIds)"
            ]
            return params
        case .deleteMessageForEveryone(conversationId: let conversationId, messageIds: let messageIds):
            var params : [String : String] = [
                "conversationId" : "\(conversationId)", "messageIds" : "\(messageIds)"
            ]
            return params
        case .forwardMessage:
            return [:]
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .getMessages, .editMessage,.sendMessage,.deleteMessageForMe,.deleteMessageForEveryone,.forwardMessage:
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






