//
//  File.swift
//
//
//  Created by Rasika Bharati on 29/08/24.
//

import Foundation

enum ISMChatMessagesEndpoint : ISMChatURLConvertible {
    
    case getMessages(conversationId: String,lastMessageTimestamp: String)
    case getCustomTypeMessages(conversationId: String,customTypes: String,senderIds: String,senderIdsExclusive: Bool)
    case sendMessage
    case editMessage
    case deleteMessageForMe(conversationId: String,messageIds: String)
    case deleteMessageForEveryone(conversationId: String,messageIds: String)
    case forwardMessage
    case messageDeliveredInfo(conversationId: String,messageId: String)
    case messageReadInfo(conversationId: String,messageId: String)
    case allUnreadMessagesFromAllConversation(senderIdsExclusive: Bool,deliveredToMe: Bool,senderIds: String,limit: Int,skip: Int,sort : Int)
    case markMessageStatusRead
    
    var baseURL: URL {
        let defaultURL = URL(string: "https://apis.isometrik.ai")! // ✅ Force unwrapping is safe here since the URL is valid.
        if let origin = ISMChatSdk.getInstance().getChatClient()?.getConfigurations().projectConfig.origin,
           let validURL = URL(string: origin) {
            return validURL
        }
        return defaultURL
    }
    
    var path: String {
        switch self {
        case .getMessages:
            return "/chat/messages"
        case .getCustomTypeMessages:
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
        case .messageDeliveredInfo:
            return "/chat/message/status/delivery"
        case .messageReadInfo:
            return "/chat/message/status/read"
        case .allUnreadMessagesFromAllConversation:
            return "/chat/messages/user"
        case .markMessageStatusRead:
            return "/chat/messages/read"
        }
    }
    
    var method: ISMChatHTTPMethod {
        switch self {
        case .getMessages:
            return .get
        case .getCustomTypeMessages:
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
        case .messageDeliveredInfo:
            return .get
        case .messageReadInfo:
            return .get
        case .allUnreadMessagesFromAllConversation(_, _, _, _, _, _):
            return .get
        case .markMessageStatusRead:
            return .put
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
        case .getCustomTypeMessages(let conversationId, let customTypes,let senderIds, let senderIdsExclusive):
            let params : [String : String] = [
                "conversationId" : "\(conversationId)", "customTypes" : "\(customTypes)" , "senderIds" : "\(senderIds)", "senderIdsExclusive" : "\(senderIdsExclusive)"
            ]
            return params
        case .editMessage:
            return [:]
        case .sendMessage:
            return [:]
        case .deleteMessageForMe(conversationId: let conversationId, messageIds: let messageIds):
            let params : [String : String] = [
                "conversationId" : "\(conversationId)", "messageIds" : "\(messageIds)"
            ]
            return params
        case .deleteMessageForEveryone(conversationId: let conversationId, messageIds: let messageIds):
            let params : [String : String] = [
                "conversationId" : "\(conversationId)", "messageIds" : "\(messageIds)"
            ]
            return params
        case .forwardMessage:
            return [:]
        case .messageDeliveredInfo(let conversationId, let messageId):
            let params : [String : String] = [
                "conversationId" : "\(conversationId)", "messageId" : "\(messageId)"
            ]
            return params
        case .messageReadInfo(let conversationId, let messageId):
            let params : [String : String] = [
                "conversationId" : "\(conversationId)", "messageId" : "\(messageId)"
            ]
            return params
        case .allUnreadMessagesFromAllConversation(senderIdsExclusive: let senderIdsExclusive, deliveredToMe: let deliveredToMe, senderIds: let senderIds, limit: let limit, skip: let skip, sort: let sort):
            let params : [String : String] = [
                "senderIdsExclusive" : "\(senderIdsExclusive)", "deliveredToMe" : "\(deliveredToMe)", "senderIds" : "\(senderIds)", "limit" : "\(limit)" , "skip" : "\(skip)" , "sort" : "\(sort)"
            ]
            return params
        case .markMessageStatusRead:
            return [:]
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .getMessages,.getCustomTypeMessages, .editMessage,.sendMessage,.deleteMessageForMe,.deleteMessageForEveryone,.forwardMessage,.messageDeliveredInfo,.messageReadInfo,.allUnreadMessagesFromAllConversation,.markMessageStatusRead:
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






