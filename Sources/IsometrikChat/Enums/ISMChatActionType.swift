//
//  ISMMessageActionType.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 21/06/23.
//

import Foundation

public enum ISMChatActionType : CaseIterable{
    case userBlock
    case userUnblock
    case deleteConversationLocally
    
    
    //grp
    case conversationTitleUpdated
    case conversationImageUpdated
    
    case conversationCreated
    
    case membersAdd
    case memberLeave
    
    case addAdmin
    case removeAdmin
    
    case membersRemove
    case messageDetailsUpdated
    case reactionAdd
    case reactionRemove
    case conversationSettingsUpdated
    
    //call kit actions
    
    case meetingEndedDueToNoUserPublishing
    case meetingCreated
    case meetingEndedDueToRejectionByAll
    
    case userUpdate
    
//    typingEvent,
//      conversationCreated,
//      messageDelivered,
//      messageRead,
//      messagesDeleteForAll,
//      multipleMessagesRead,

    case userBlockConversation
    case userUnblockConversation

//      clearConversation,
//      removeMember,
//      addMember,
//      removeAdmin,
//      addAdmin,
//      memberLeave,
//      deleteConversationLocally,

//      reactionRemove,
//      conversationDetailsUpdated;
//
    public var value : String{
        switch self {
        case .userBlock:
            return "userBlock"
        case .userUnblock:
            return "userUnblock"
        case .deleteConversationLocally:
            return "deleteConversationLocally"
        case .conversationTitleUpdated:
            return "conversationTitleUpdated"
        case .conversationImageUpdated:
            return "conversationImageUpdated"
        case .conversationCreated:
            return "conversationCreated"
        case .membersAdd:
            return "membersAdd"
        case .memberLeave:
            return "memberLeave"
        case .addAdmin:
            return "addAdmin"
        case .removeAdmin:
            return "removeAdmin"
        case .membersRemove:
            return "membersRemove"
        case .messageDetailsUpdated:
            return "messageDetailsUpdated"
        case .reactionAdd:
            return "reactionAdd"
        case .conversationSettingsUpdated:
            return "conversationSettingsUpdated"
        case .reactionRemove:
            return "reactionRemove"
        case .meetingEndedDueToNoUserPublishing:
            return "meetingEndedDueToNoUserPublishing"
        case .meetingCreated:
            return "meetingCreated"
        case .meetingEndedDueToRejectionByAll:
            return "meetingEndedDueToRejectionByAll"
        case .userUpdate:
            return "userUpdate"
        case .userBlockConversation:
            return "userBlockConversation"
        case .userUnblockConversation:
            return "userUnblockConversation"
        }
    }
}
