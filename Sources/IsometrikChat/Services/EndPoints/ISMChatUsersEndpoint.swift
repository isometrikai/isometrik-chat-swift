//
//  File.swift
//  
//
//  Created by Rasika Bharati on 02/09/24.
//

import Foundation

public enum ISMChatUsersEndpoint : ISMChatURLConvertible {

//    case authenticateUser
//    case registerUser
    case getUserDetail
    case updateUserDetail
    case allUsers(searchTag: String,sort: Int)
    case allBlockedUsers
    case allNonBlockUsers(searchTag: String,sort: Int,skip: Int,limit: Int)
    case blockUser
    case unBlockUser
    
    var baseURL: URL {
        return URL(string:ISMChatSdk.getInstance().getChatClient().getConfigurations().projectConfig.origin)!
    }
    
    var path: String {
        switch self {
//        case .authenticateUser:
//            return "/chat/user/authenticate"
//        case .registerUser:
//            return "/chat/user"
        case .getUserDetail:
            return "/chat/user/details"
        case .updateUserDetail:
            return "/chat/user"
        case .allUsers:
            return "/chat/users"
        case .allBlockedUsers:
            return "/chat/user/block"
        case .allNonBlockUsers:
            return "/chat/user/nonblock"
        case .blockUser:
            return "/chat/user/block"
        case .unBlockUser:
            return "/chat/user/unblock"
        }
    }
    
     var method: ISMChatHTTPMethod {
        switch self {
//        case .authenticateUser:
//            return .post
//        case .registerUser:
//            return .post
        case .getUserDetail:
            return .get
        case .updateUserDetail:
            return .patch
        case .allUsers:
            return .get
        case .allBlockedUsers:
            return .get
        case .allNonBlockUsers:
            return .get
        case .blockUser:
            return .post
        case .unBlockUser:
            return .post
        }
    }
    
    public var queryParams: [String: String]? {
        switch self {
//        case .authenticateUser:
//            return [:]
//        case .registerUser:
//            return [:]
        case .getUserDetail:
            return [:]
        case .updateUserDetail:
            return [:]
        case .allUsers(let searchTag, let sort):
            var params : [String : String] = [
                "sort" : "\(sort)"
            ]
            if !searchTag.isEmpty{
                params.updateValue(searchTag, forKey: "searchTag")
            }
            return params
        case .allBlockedUsers:
            return [:]
        case .allNonBlockUsers(let searchTag, let sort, let skip, let limit):
            var params : [String : String] = [
                "sort" : "\(sort)",
                "skip" : "\(skip)",
                "limit": "\(limit)"
            ]
            if !searchTag.isEmpty{
                params.updateValue(searchTag, forKey: "searchTag")
            }
            return params
        case .blockUser:
            return [:]
        case .unBlockUser:
            return [:]
        }
    }
    
    public var headers: [String: String]? {
        switch self {
        case /*.authenticateUser,.registerUser,*/.getUserDetail,.updateUserDetail,.allUsers,.allBlockedUsers,.allNonBlockUsers,.blockUser,.unBlockUser:
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
