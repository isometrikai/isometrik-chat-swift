//
//  HybridStorageManager.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 28/02/25.
//

import SwiftData
import Foundation
import SwiftUI

public class HybridStorageManager: ChatStorageManager {
    
    
    private let localStorageManager: LocalStorageManager
    private let remoteStorageManager: RemoteStorageManager
    
    public init(localStorageManager: LocalStorageManager, remoteStorageManager: RemoteStorageManager) {
        self.localStorageManager = localStorageManager
        self.remoteStorageManager = remoteStorageManager
    }
    
    public func fetchConversations() async throws -> [ISMChatConversationDB] {
        do {
            // Fetch from remote and sync
            let remoteConversations = try await remoteStorageManager.fetchConversations()
            try await localStorageManager.saveConversation(remoteConversations)
            let localConversations = try await localStorageManager.fetchConversations()
            return localConversations
        } catch {
            print("Error syncing with remote: \(error)")
            throw error
        }
    }
    
    public func saveConversation(_ conversations: [ISMChatConversationDB]) async throws {
        
    }
    
    public func deleteConversation(conversationId: String) async throws {
        do {
            // Fetch from remote and sync
            try await remoteStorageManager.deleteConversation(conversationId: conversationId)
            try await localStorageManager.deleteConversation(conversationId: conversationId)
        } catch {
            print("Error delete conversation with hybrid: \(error)")
            throw error
        }
    }
    
    public func clearConversationMessages(conversationId: String) async throws {
        do {
            // Fetch from remote and sync
            try await remoteStorageManager.clearConversationMessages(conversationId: conversationId)
            try await localStorageManager.clearConversationMessages(conversationId: conversationId)
        } catch {
            print("Error delete conversation with hybrid: \(error)")
            throw error
        }
    }
    
    public func fetchMessages(conversationId: String,lastMessageTimestamp: String) async throws -> [ISMChatMessagesDB] {
        do {
            // Fetch from remote and sync
            let remoteMessages = try await remoteStorageManager.fetchMessages(conversationId: conversationId, lastMessageTimestamp: lastMessageTimestamp)
            try await localStorageManager.saveAllMessages(remoteMessages, conversationId: conversationId)
            let localMessages = try await localStorageManager.fetchMessages(conversationId: conversationId, lastMessageTimestamp: lastMessageTimestamp)
            return localMessages
        } catch {
            print("Error syncing with remote: \(error)")
            throw error
        }
    }
    
    public func saveAllMessages(_ messages: [ISMChatMessagesDB], conversationId: String) async throws {
        
    }
}
