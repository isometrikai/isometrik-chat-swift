//
//  ChatRepository.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 27/02/25.
//

import Foundation

public class ChatRepository {
    public let localStorageManager: LocalStorageManager
    public let remoteStorageManager: RemoteStorageManager
    public let hybridStorageManager: HybridStorageManager
    public let configurationService: ConfigurationService
    
    public init(localStorageManager: LocalStorageManager, remoteStorageManager: RemoteStorageManager, hybridStorageManager: HybridStorageManager, configurationService: ConfigurationService = .shared) {
            self.localStorageManager = localStorageManager
            self.remoteStorageManager = remoteStorageManager
            self.hybridStorageManager = hybridStorageManager 
            self.configurationService = configurationService
        }
    
    public var activeStorageManager: ChatStorageManager {
        switch configurationService.storageMode {
        case .local:
            return localStorageManager
        case .remote:
            return remoteStorageManager
        case .hybrid:
            return hybridStorageManager
        }
    }
    
    // Delegate all operations to the active storage manager
    public func fetchConversations() async throws -> [ISMChatConversationDB] {
        return try await activeStorageManager.fetchConversations()
    }
    
    public func saveConversation(_ conversations: [ISMChatConversationDB]) async throws{
        return try await activeStorageManager.saveConversation(conversations)
    }
    
    public func deleteConversation(id: String)  async throws{
        return try await activeStorageManager.deleteConversation(id: id)
    }
    
    public func clearConversation(id: String)  async throws{
        return try await activeStorageManager.clearConversation(id: id)
    }
    
    public func fetchMessages(conversationId: String) async throws -> [ISMChatMessagesDB] {
        return try await activeStorageManager.fetchMessages(conversationId: conversationId)
    }
}
