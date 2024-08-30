//
//  File.swift
//  
//
//  Created by Rasika Bharati on 29/08/24.
//

import Foundation

enum ISMChatBroadCastEndpoint : ISMChatURLConvertible {
    
    case createBroadCast
    case getBroadCastList
    case deleteBroadCast
    case updateBroadCast
    case getBroadCastMembers(groupcastId: String)
    case sendBroadcastMessage
    case getBroadCastMessages(groupcastId: String,lastMessageTimestamp: String)
    case deleteBroadCastMessageForMe(groupcastId: String,messageId: String,notifyOnCompletion: Bool,deleteForAll: Bool,sendPushForMessageDeleted: Bool)
    case deleteBroadCastMessageForEveryone(groupcastId: String,messageId: String,notifyOnCompletion: Bool,deleteForAll: Bool,sendPushForMessageDeleted: Bool)
    case addMembersToBroadCast
    case removeMembersInBroadcast(groupcastId: String,membersId: String)
    case getEligibleUsersListtoAddInBroadcast(groupcastId: String, searchTag: String,sort: Int,skip: Int,limit: Int)
    case getBroadcastMessageDeliveredInfo(groupcastId: String,groupcastMessageId: String)
    case getBroadcastMessageReadInfo(groupcastId: String,groupcastMessageId: String)
    
    var baseURL: URL {
        return URL(string:ISMChatSdk.getInstance().getChatClient().getConfigurations().projectConfig.origin)!
    }
    
    var path: String {
        switch self {
        case .createBroadCast:
            return "/chat/groupcast"
        case .getBroadCastList:
            return "/chat/groupcasts"
        case .deleteBroadCast:
            return "/chat/groupcast"
        case .updateBroadCast:
            return "/chat/groupcast"
        case .getBroadCastMembers:
            return "/chat/groupcast/members"
        case .sendBroadcastMessage:
            return "/chat/groupcast/message"
        case .getBroadCastMessages:
            return "/chat/groupcast/messages"
        case .deleteBroadCastMessageForMe:
            return "/chat/groupcast/message/self"
        case .deleteBroadCastMessageForEveryone:
            return "/chat/groupcast/message/everyone"
        case .addMembersToBroadCast:
            return "/chat/groupcast/members"
        case .removeMembersInBroadcast:
            return "/chat/groupcast/members"
        case .getEligibleUsersListtoAddInBroadcast:
            return "/chat/groupcast/eligible/members"
        case .getBroadcastMessageDeliveredInfo:
            return "/chat/groupcast/message/status/delivery"
        case .getBroadcastMessageReadInfo:
            return "/chat/groupcast/message/status/read"
        }
    }
    
    var method: ISMChatHTTPMethod {
        switch self {
        case .createBroadCast:
            return .post
        case .getBroadCastList:
            return .get
        case .deleteBroadCast:
            return .delete
        case .updateBroadCast:
            return .patch
        case .getBroadCastMembers:
            return .get
        case .sendBroadcastMessage:
            return .post
        case .getBroadCastMessages:
            return .get
        case .deleteBroadCastMessageForMe:
            return .delete
        case .deleteBroadCastMessageForEveryone:
            return .delete
        case .addMembersToBroadCast:
            return .put
        case .removeMembersInBroadcast:
            return .delete
        case .getEligibleUsersListtoAddInBroadcast:
            return .get
        case .getBroadcastMessageDeliveredInfo:
            return .get
        case .getBroadcastMessageReadInfo:
            return .get
        }
    }
    
    var queryParams: [String: String]? {
        switch self {
        case .createBroadCast:
            return [:]
        case .getBroadCastList:
            return [:]
        case .deleteBroadCast:
            return [:]
        case .updateBroadCast:
            return [:]
        case .getBroadCastMembers(let groupcastId):
            var params : [String : String] = [
                "groupcastId" : "\(groupcastId)"
            ]
            return params
        case .sendBroadcastMessage:
            return [:]
        case .getBroadCastMessages(let groupcastId, let lastMessageTimestamp):
            var params : [String : String] = [
                "groupcastId" : "\(groupcastId)"
            ]
            if !lastMessageTimestamp.isEmpty{
                params.updateValue(lastMessageTimestamp, forKey: "lastMessageTimestamp")
            }
            return params
        case .deleteBroadCastMessageForMe(let groupcastId,let messageId,let notifyOnCompletion, let deleteForAll, let sendPushForMessageDeleted):
            var params : [String : String] = [
                "groupcastId" : "\(groupcastId)",
                "messageId" : "\(messageId)",
                "notifyOnCompletion" : "\(notifyOnCompletion)",
                "deleteForAll" : "\(deleteForAll)",
                "sendPushForMessageDeleted" : "\(sendPushForMessageDeleted)"
            ]
            return params
        case .deleteBroadCastMessageForEveryone(let groupcastId,let messageId,let notifyOnCompletion, let deleteForAll, let sendPushForMessageDeleted):
            var params : [String : String] = [
                "groupcastId" : "\(groupcastId)",
                "messageId" : "\(messageId)",
                "notifyOnCompletion" : "\(notifyOnCompletion)",
                "deleteForAll" : "\(deleteForAll)",
                "sendPushForMessageDeleted" : "\(sendPushForMessageDeleted)"
            ]
            return params
        case .addMembersToBroadCast:
            return [:]
        case .removeMembersInBroadcast(let groupcastId, let membersId):
            var params : [String : String] = [
                "groupcastId" : "\(groupcastId)",
                "members" : "\(membersId)"
            ]
            return params
        case .getEligibleUsersListtoAddInBroadcast(let groupcastId, let searchTag, let sort, let skip, let limit):
            var params : [String : String] = [
                "groupcastId" : "\(groupcastId)",
                "sort" : "\(sort)",
                "skip" : "\(skip)",
                "limit" : "\(limit)"
            ]
            if !searchTag.isEmpty{
                params.updateValue(searchTag, forKey: "searchTag")
            }
            return params
        case .getBroadcastMessageDeliveredInfo(let groupcastId ,let groupcastMessageId):
            var params : [String : String] = [
                "groupcastId" : "\(groupcastId)",
                "groupcastMessageId" : "\(groupcastMessageId)"
            ]
            return params
        case .getBroadcastMessageReadInfo(let groupcastId ,let groupcastMessageId):
            var params : [String : String] = [
                "groupcastId" : "\(groupcastId)",
                "groupcastMessageId" : "\(groupcastMessageId)"
            ]
            return params
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .createBroadCast , .getBroadCastList, .getBroadCastMembers, .sendBroadcastMessage, .getBroadCastMessages, .deleteBroadCastMessageForMe, .deleteBroadCastMessageForEveryone, .addMembersToBroadCast, .getEligibleUsersListtoAddInBroadcast, .getBroadcastMessageDeliveredInfo, .getBroadcastMessageReadInfo,.deleteBroadCast,.updateBroadCast,.removeMembersInBroadcast:
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






