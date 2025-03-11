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
    
    public func createConversation(user : ISMChatUserDB,conversationId : String) async throws -> String{
        return try await activeStorageManager.createConversation(user: user, conversationId: conversationId)
    }
    
    // Delegate all operations to the active storage manager
    public func fetchConversations() async throws -> [ISMChatConversationDB] {
        return try await activeStorageManager.fetchConversations()
    }
    
    public func saveConversation(_ conversations: [ISMChatConversationDB]) async throws{
        return try await activeStorageManager.saveConversation(conversations)
    }
    
    public func deleteConversation(conversationId: String)  async throws{
        return try await activeStorageManager.deleteConversation(conversationId: conversationId)
    }
    
    public func clearConversationMessages(conversationId: String) async throws{
        return try await activeStorageManager.clearConversationMessages(conversationId: conversationId)
    }
    
    public func updateLastMessageInConversation(conversationId : String, lastMessage : ISMChatLastMessageDB) async throws{
        return try await activeStorageManager.updateLastMessageInConversation(conversationId: conversationId, lastMessage: lastMessage)
    }
    
    public func fetchMessages(conversationId: String,lastMessageTimestamp : String) async throws -> [ISMChatMessagesDB] {
        return try await activeStorageManager.fetchMessages(conversationId: conversationId, lastMessageTimestamp: lastMessageTimestamp)
    }
    
    public func saveAllMessages(_ messages: [ISMChatMessagesDB], conversationId: String) async throws {
        return try await activeStorageManager.saveAllMessages(messages, conversationId: conversationId)
    }

    public func updateMsgId(objectId: UUID, msgId: String, conversationId: String, mediaUrl: String, thumbnailUrl: String, mediaSize: Int, mediaId: String) async throws {
        return try await activeStorageManager.updateMsgId(objectId: objectId, msgId: msgId, conversationId: conversationId, mediaUrl: mediaUrl, thumbnailUrl: thumbnailUrl, mediaSize: mediaSize, mediaId: mediaId)
    }
    
    public func updateMessage(conversationId: String, messageId: String, body: String, metaData: ISMChatMetaDataDB?,customType : String?) async throws{
        return try await activeStorageManager.updateMessage(conversationId: conversationId, messageId: messageId, body: body, metaData: metaData, customType: customType)
    }

}
