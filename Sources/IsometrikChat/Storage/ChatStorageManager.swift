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
    func fetchConversations() async throws -> [ISMChatConversationDB]
    func saveConversation(_ conversations: [ISMChatConversationDB]) async throws
    func deleteConversation(id: String) async throws
    func clearConversation(id: String) async throws
//    func updateConversation(_ conversation: ISMChatConversationDB) async throws
    
    // Message operations
    func fetchMessages(conversationId: String) async throws -> [ISMChatMessagesDB]
//    func saveMessage(_ message: ISMChatMessagesDB) async throws
//    func deleteMessage(id: String) async throws
//    func updateMessage(_ message: ISMChatMessagesDB) async throws
}
