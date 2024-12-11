//
//  File.swift
//  
//
//  Created by Rasika Bharati on 30/08/24.
//

import Foundation

enum ISMChatMediaUploadEndpoint : ISMChatURLConvertible {
    
    case messageMediaUpload
    case conversationProfileUpload(mediaExtension: String,conversationType: Int,newConversation : Bool,conversationTitle: String,conversationId: String)
    case userImage(userIdentifier: String,mediaExtension: String)
    case updateUserImage(mediaExtension: String)
    
    var baseURL: URL {
        return URL(string:ISMChatSdk.getInstance().getChatClient()?.getConfigurations().projectConfig.origin ?? "")!
    }
    
    var path: String {
        switch self {
        case .messageMediaUpload:
            return "/chat/messages/presignedurls"
        case .conversationProfileUpload:
            return "/chat/conversation/presignedurl"
        case .userImage:
            return "/chat/user/presignedurl/create"
        case .updateUserImage:
            return "/chat/user/presignedurl/update"
        }
    }
    
    var method: ISMChatHTTPMethod {
        switch self {
        case .messageMediaUpload:
            return .post
        case .conversationProfileUpload:
            return .get
        case .userImage:
            return .get
        case .updateUserImage:
            return .get
        }
    }
    
    var queryParams: [String: String]? {
        switch self {
        case .messageMediaUpload:
            return [:]
        case .conversationProfileUpload(let mediaExtension, let conversationType, let newConversation, let conversationTitle,let conversationId):
            let params : [String : String] = [
                "mediaExtension" : "\(mediaExtension)",
                "conversationType" : "\(conversationType)",
                "newConversation" : "\(newConversation)",
                "conversationTitle" : "\(conversationTitle)",
                "conversationId" : "\(conversationId)"
            ]
            return params
        case .userImage(let userIdentifier,let mediaExtension):
            let params : [String : String] = [
                "userIdentifier" : "\(userIdentifier)",
                "mediaExtension" : "\(mediaExtension)"
            ]
            return params
        case .updateUserImage(let mediaExtension):
            let params : [String : String] = [
                "mediaExtension" : "\(mediaExtension)"
            ]
            return params
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .messageMediaUpload,.conversationProfileUpload,.userImage,.updateUserImage:
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
