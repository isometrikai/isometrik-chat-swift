//
//  ChatStorageManager.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 27/02/25.
//

import Foundation
import Combine

public protocol ChatStorageManager {
    
    func deleteSwiftData() async throws
    // Conversation operations
    func createConversation(user : ISMChatUserDB,conversationId : String) async throws -> String //return conversationId
    func fetchConversations() async throws -> [ISMChatConversationDB]
    func fetchConversationsLocal() async throws -> [ISMChatConversationDB]
    func saveConversation(_ conversations: [ISMChatConversationDB]) async throws
    func deleteConversation(conversationId: String) async throws
    func clearConversationMessages(conversationId: String) async throws
    func updateLastMessageInConversation(conversationId : String, lastMessage : ISMChatLastMessageDB) async throws
    func updateUnreadCountThroughConversation(conversationId: String, count: Int, reset: Bool?) async throws
//    func updateConversation(_ conversation: ISMChatConversationDB) async throws
    
    // Message operations
    func fetchMessages(conversationId: String,lastMessageTimestamp : String,onlyLocal : Bool) async throws -> [ISMChatMessagesDB]
    func saveAllMessages(_ messages: [ISMChatMessagesDB], conversationId: String) async throws
    func updateMsgId(objectId: UUID, msgId: String, conversationId: String, mediaUrl: String, thumbnailUrl: String, mediaSize: Int, mediaId: String) async throws
    func updateMessage(conversationId: String, messageId: String, body: String, metaData: ISMChatMetaDataDB?, customType: String?) async throws
    func updateMessageAsDeletedLocally(conversationId: String,messageId: String) async throws
    func doesMessageExistInMessagesDB(conversationId: String,messageId: String) async throws -> Bool
//    func deleteMessage(id: String) async throws
//    func updateMessage(_ message: ISMChatMessagesDB) async throws
    
    
    //Media operations
    func saveMedia(arr: [ISMChatAttachmentDB],conversationId: String,customType: String,sentAt: Double,messageId: String,userName: String) async throws
    func fetchPhotosAndVideos(conversationId: String) async throws -> [ISMChatMediaDB]
    func fetchFiles(conversationId: String) async throws -> [ISMChatMediaDB]
    func fetchLinks(conversationId: String) async throws -> [ISMChatMessagesDB]
    func deleteMedia(conversationId: String, messageId: String) async throws
    
    
    //group operations
    func updateGroupTitle(title : String, conversationId : String,localOnly : Bool) async throws
    func updateGroupImage(image : String, conversationId : String,localOnly : Bool) async throws
    
    
    func getConversationIdFromUserId(opponentUserId : String,myUserId: String) -> String
    
    
    //group
    func exitGroup(conversationId : String) async throws
    func updateMemberCountInGroup(conversationId: String, inc: Bool, dec: Bool, count: Int) async throws
    func getMemberCount(conversationId:String) async throws -> Int
    
    //
    func changeTypingStatus(conversationId: String, status: Bool) async throws
    func getLastInputTextInConversation(conversationId : String) async throws -> String
    func saveLastInputTextInConversation(text: String, conversationId: String) async throws
    
    //
    func addLastMessageOnAddAndRemoveReaction(conversationId: String,action : String,emoji : String,userId: String) async throws
}
