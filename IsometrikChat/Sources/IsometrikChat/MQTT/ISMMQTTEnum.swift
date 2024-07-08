//
//  ISMMQTTEnum.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 26/04/23.
//

import Foundation

/// MQTT data Type
public enum ISMChat_MQTTNotificationType: String {
    case mqttTypingEvent = "MQTTtypingEvent"
    case mqttConversationCreated = "MQTTconversationCreated"
    case mqttMessageDelivered = "MQTTmessageDelivered"
    case mqttMessageRead = "MQTTmessageRead"
    case mqttMessageDeleteForAll = "MQTTmessagesDeleteForAll"
    case mqttMultipleMessageRead = "MQTTmultipleMessagesRead"
    case mqttUserBlock = "MQTTuserBlock"
    case mqttUserBlockConversation = "MQTTuserBlockConversation" //ignore
    case mqttUserUnblock = "MQTTuserUnblock"
    case mqttUserUnblockConversation = "MQTTuserUnblockConversation"  //ignore
    case mqttClearConversation = "MQTTclearConversation"  //ignore
    case mqttDeleteConversationLocally = "MQTTdeleteConversationLocally" //ignore
    case mqttMessageNewReceived = "MQTTmessageNewReceived"
    
    case mqttAddAdmin = "MQTTAddAdmin"
    case mqttRemoveAdmin = "MQTTRemoveAdmin"
    case mqttAddMember = "MQTTAddMember"
    case mqttRemoveMember = "MQTTRemoveMember"
    case mqttMemberLeave = "MQTTMemberLeave"
    case mqttConversationTitleUpdated = "MQTTConversationTitleUpdated"
    case mqttConversationImageUpdated = "MQTTConversationImageUpdated"
    
    case mqttUpdateUser = "MQTTUpdateUser"
    
    case mqttforward = "MQTTForward"
    case mqttmessageDetailsUpdated = "MQTTmessageDetailsUpdated"
    case mqttAddReaction = "MQTTAddReaction"
    case mqttRemoveReaction = "MQTTRemoveReaction"
    
    
    //callkit
    case mqttMeetingCreated = "MQTTMeetingCreated"
    case mqttMeetingEnded = "MQTTMeetingEnded"
    
    
    public var name: Notification.Name {
        return Notification.Name(rawValue: self.rawValue)
    }
}

/// MQTT Data.
enum ISMChat_MQTTData {
    case mqttTypingEvent
    case mqttConversationCreated
    case mqttMessageDelivered
    case mqttMessageRead
    case mqttMessageDeleteForAll
    case mqttMultipleMessageRead
    case mqttUserBlock
    case mqttUserBlockConversation
    case mqttUserUnblock
    case mqttUserUnblockConversation
    case mqttClearConversation
    case mqttDeleteConversationLocally
    
    case mqttAddAdmin
    case mqttRemoveAdmin
    case mqttAddMember
    case mqttRemoveMember
    case mqttMemberLeave
    case mqttConversationTitleUpdated
    case mqttConversationImageUpdated
    
    case mqttUpdateUser
    
    case mqttforward
    case mqttmessageDetailsUpdated
    
    //reaction
    case mqttAddReaction
    case mqttRemoveReaction
    
    case none
    
    static func dataType(_ type: String) -> ISMChat_MQTTData {
        switch type {
        case "typingEvent": return .mqttTypingEvent
        case "conversationCreated" : return .mqttConversationCreated
        case "messageDelivered" : return .mqttMessageDelivered
        case "messageRead" : return .mqttMessageRead
        case "messagesDeleteForAll" : return .mqttMessageDeleteForAll
        case "multipleMessagesRead" : return .mqttMultipleMessageRead
        case "userBlock" : return .mqttUserBlock
        case "userBlockConversation" : return .mqttUserBlockConversation
        case "userUnblock" : return .mqttUserUnblock
        case "userUnblockConversation" : return .mqttUserUnblockConversation
        case "clearConversation" : return .mqttClearConversation
        case "deleteConversationLocally" : return .mqttDeleteConversationLocally
            
        case "addAdmin"  : return .mqttAddAdmin
        case "removeAdmin" : return .mqttRemoveAdmin
        case "membersAdd" : return .mqttAddMember
        case "membersRemove" : return .mqttRemoveMember
        case "memberLeave" : return .mqttMemberLeave
        case "conversationTitleUpdated" : return .mqttConversationTitleUpdated
        case "conversationImageUpdated" : return .mqttConversationImageUpdated
            
        case "userUpdate" : return .mqttUpdateUser
        case "forward" : return .mqttforward
        case "messageDetailsUpdated" : return .mqttmessageDetailsUpdated
        case "reactionAdd" : return .mqttAddReaction
        case "reactionRemove" : return .mqttRemoveReaction
            
        default: return .none
        }
    }
}


enum ISMChat_MqttResult<T> {
    case success(T)
    case failure(ISMChat_Error)
}

public struct ISMChat_Error: Error {
    
    let httpResponseCode: Int?
    let errorMessage: String
    let remoteErrorCode: Int?
    let isometrikErrorCode: Int?
    let remoteError: Bool?
    
    init(httpResponseCode: Int? = nil, remoteError: Bool? = nil, errorMessage: String, remoteErrorCode: Int? = nil, isometrikErrorCode: Int? = nil) {
        self.httpResponseCode = httpResponseCode
        self.errorMessage = errorMessage
        self.remoteError = remoteError
        self.remoteErrorCode = remoteErrorCode
        self.isometrikErrorCode = isometrikErrorCode
    }
}
