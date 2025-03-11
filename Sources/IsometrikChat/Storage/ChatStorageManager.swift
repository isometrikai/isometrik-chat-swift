//
//  ChatStorageManager.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 27/02/25.
//

import Foundation
import Combine

public protocol ChatStorageManager {
    // Conversation operations
    func createConversation(user : ISMChatUserDB,conversationId : String) async throws -> String //return conversationId
    func fetchConversations() async throws -> [ISMChatConversationDB]
    func saveConversation(_ conversations: [ISMChatConversationDB]) async throws
    func deleteConversation(conversationId: String) async throws
    func clearConversationMessages(conversationId: String) async throws
    func updateLastMessageInConversation(conversationId : String, lastMessage : ISMChatLastMessageDB) async throws
//    func updateConversation(_ conversation: ISMChatConversationDB) async throws
    
    // Message operations
    func fetchMessages(conversationId: String,lastMessageTimestamp : String) async throws -> [ISMChatMessagesDB]
    func saveAllMessages(_ messages: [ISMChatMessagesDB], conversationId: String) async throws
    func updateMsgId(objectId: UUID, msgId: String, conversationId: String, mediaUrl: String, thumbnailUrl: String, mediaSize: Int, mediaId: String) async throws
    func updateMessage(conversationId: String, messageId: String, body: String, metaData: ISMChatMetaDataDB?, customType: String?) async throws

//    func deleteMessage(id: String) async throws
//    func updateMessage(_ message: ISMChatMessagesDB) async throws
}
