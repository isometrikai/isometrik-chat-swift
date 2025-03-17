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
    
    public func updateUnreadCountThroughConversation(conversationId: String, count: Int, reset: Bool?) async throws{
        return try await activeStorageManager.updateUnreadCountThroughConversation(conversationId: conversationId, count: count, reset: reset)
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
    
    public func saveMedia(arr: [ISMChatAttachmentDB], conversationId: String, customType: String, sentAt: Double, messageId: String, userName: String) async throws {
        return try await activeStorageManager.saveMedia(arr: arr, conversationId: conversationId, customType: customType, sentAt: sentAt, messageId: messageId, userName: userName)
    }
    
    public func fetchPhotosAndVideos(conversationId: String) async throws -> [ISMChatMediaDB] {
        return try await activeStorageManager.fetchPhotosAndVideos(conversationId: conversationId)
    }
    
    public func fetchFiles(conversationId: String) async throws -> [ISMChatMediaDB] {
        return try await activeStorageManager.fetchFiles(conversationId: conversationId)
    }
    
    public func fetchLinks(conversationId: String) async throws -> [ISMChatMessagesDB] {
        return try await activeStorageManager.fetchLinks(conversationId: conversationId)
    }

    public func deleteMedia(conversationId: String, messageId: String) async throws{
        return try await activeStorageManager.deleteMedia(conversationId: conversationId, messageId: messageId)
    }
    
    public func updateGroupTitle(title : String, conversationId : String,localOnly : Bool) async throws{
        return try await activeStorageManager.updateGroupTitle(title: title, conversationId: conversationId, localOnly: localOnly)
    }
    
    public func updateGroupImage(image : String, conversationId : String,localOnly : Bool) async throws{
        return try await activeStorageManager.updateGroupImage(image: image, conversationId: conversationId, localOnly: localOnly)
    }
    
    public func getConversationIdFromUserId(opponentUserId : String,myUserId: String) async throws -> String{
        return try await activeStorageManager.getConversationIdFromUserId(opponentUserId: opponentUserId, myUserId: myUserId)
    }
    
    public func exitGroup(conversationId : String) async throws{
        return try await activeStorageManager.exitGroup(conversationId: conversationId)
    }

    public func changeTypingStatus(conversationId: String, status: Bool) async throws{
        return try await activeStorageManager.changeTypingStatus(conversationId: conversationId, status: status)
    }
    
    public func updateMemberCountInGroup(conversationId: String, inc: Bool, dec: Bool, count: Int) async throws{
        return try await activeStorageManager.updateMemberCountInGroup(conversationId: conversationId, inc: inc, dec: dec, count: count)
    }
    
    
    public func updateMessageAsDeletedLocally(conversationId: String,messageId: String) async throws{
        return try await activeStorageManager.updateMessageAsDeletedLocally(conversationId: conversationId, messageId: messageId)
    }
    
}
