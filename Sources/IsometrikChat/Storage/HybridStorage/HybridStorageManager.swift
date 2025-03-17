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
    
    public func createConversation(user : ISMChatUserDB,conversationId : String) async throws -> String {
        do {
            // 1️⃣ Create conversation remotely and get the conversationId
            let conversationIdFromApi = try await remoteStorageManager.createConversation(user: user, conversationId: conversationId)
            return conversationIdFromApi
        } catch {
            print("Error syncing with remote: \(error)")
            throw error
        }
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
    
    public func updateUnreadCountThroughConversation(conversationId: String, count: Int, reset: Bool?) async throws {
        do {
            try await localStorageManager.updateUnreadCountThroughConversation(conversationId: conversationId, count: count, reset: reset)
        } catch {
            print("Error updating unread count with hybrid: \(error)")
            throw error
        }
    }
    
    
    public func fetchMessages(conversationId: String,lastMessageTimestamp: String) async throws -> [ISMChatMessagesDB] {
        do {
            // Fetch from remote and sync
            let remoteMessages = try await remoteStorageManager.fetchMessages(conversationId: conversationId, lastMessageTimestamp: lastMessageTimestamp)
            try await localStorageManager.saveAllMessages(remoteMessages, conversationId: conversationId)
            // saving media simultanously in conversation
            for value in remoteMessages{
                if (value.attachments?.count ?? 0) > 0 ,!value.messageId.isEmpty{
                    try await  localStorageManager.saveMedia(arr: value.attachments ?? [], conversationId: conversationId, customType: value.customType ?? "", sentAt: value.sentAt ?? 0, messageId: value.messageId ?? "", userName: value.senderInfo?.userName ?? "")
                }
            }
            let localMessages = try await localStorageManager.fetchMessages(conversationId: conversationId, lastMessageTimestamp: lastMessageTimestamp)
            return localMessages
        } catch {
            print("Error syncing with remote: \(error)")
            throw error
        }
    }
    
    public func saveAllMessages(_ messages: [ISMChatMessagesDB], conversationId: String) async throws {
        do {
            try await localStorageManager.saveAllMessages(messages, conversationId: conversationId)
        } catch {
            print("Error saving messages in conversation with hybrid: \(error)")
            throw error
        }
    }
    
    public func updateLastMessageInConversation(conversationId : String, lastMessage : ISMChatLastMessageDB) async throws{
        do {
            try await localStorageManager.updateLastMessageInConversation(conversationId: conversationId, lastMessage: lastMessage)
        } catch {
            print("Error saving messages in conversation with hybrid: \(error)")
            throw error
        }
    }
    
    public func updateMsgId(objectId: UUID, msgId: String, conversationId: String, mediaUrl: String, thumbnailUrl: String, mediaSize: Int, mediaId: String) async throws {
        do {
            try await localStorageManager.updateMsgId(objectId: objectId, msgId: msgId, conversationId: conversationId, mediaUrl: mediaUrl, thumbnailUrl: thumbnailUrl, mediaSize: mediaSize, mediaId: mediaId)
        } catch {
            print("Error saving messages in conversation with hybrid: \(error)")
            throw error
        }
    }
    
    public func updateMessage(conversationId: String, messageId: String, body: String, metaData: ISMChatMetaDataDB?, customType: String?) async throws {
        do {
            try await localStorageManager.updateMessage(conversationId: conversationId, messageId: messageId, body: body, metaData: metaData, customType: customType)
        } catch {
            print("Error updating messages in conversation with hybrid: \(error)")
            throw error
        }
    }
    
    public func saveMedia(arr: [ISMChatAttachmentDB], conversationId: String, customType: String, sentAt: Double, messageId: String, userName: String) async throws {
        do {
            try await localStorageManager.saveMedia(arr: arr, conversationId: conversationId, customType: customType, sentAt: sentAt, messageId: messageId, userName: userName)
        } catch {
            print("Error updating messages in conversation with hybrid: \(error)")
            throw error
        }
    }
    
    public func fetchPhotosAndVideos(conversationId: String) async throws -> [ISMChatMediaDB] {
        do {
            let media = try await localStorageManager.fetchPhotosAndVideos(conversationId: conversationId)
            return media
        } catch {
            print("Error updating messages in conversation with hybrid: \(error)")
            throw error
        }
    }
    
    public func fetchFiles(conversationId: String) async throws -> [ISMChatMediaDB] {
        do {
            let files = try await localStorageManager.fetchFiles(conversationId: conversationId)
            return files
        } catch {
            print("Error updating messages in conversation with hybrid: \(error)")
            throw error
        }
    }
    
    public func fetchLinks(conversationId: String) async throws -> [ISMChatMessagesDB] {
        do {
            let links = try await localStorageManager.fetchLinks(conversationId: conversationId)
            return links
        } catch {
            print("Error updating messages in conversation with hybrid: \(error)")
            throw error
        }
    }
    
    public func deleteMedia(conversationId: String, messageId: String) async throws {
        do {
            try await localStorageManager.deleteMedia(conversationId: conversationId, messageId: messageId)
        } catch {
            print("Error updating messages in conversation with hybrid: \(error)")
            throw error
        }
    }
    
    public func updateGroupTitle(title: String, conversationId: String,localOnly : Bool) async throws {
        do {
            // Fetch from remote and sync
            if localOnly == false{
                //if we need to just locally updatedata then no need to call remote apis
                try await remoteStorageManager.updateGroupTitle(title: title, conversationId: conversationId, localOnly: localOnly)
            }
            try await localStorageManager.updateGroupTitle(title: title, conversationId: conversationId, localOnly: localOnly)
        } catch {
            print("Error delete conversation with hybrid: \(error)")
            throw error
        }
    }
    
    public func updateGroupImage(image: String, conversationId: String,localOnly : Bool) async throws {
        do {
            // Fetch from remote and sync
            if localOnly == false{
                //if we need to just locally updatedata then no need to call remote apis
                try await remoteStorageManager.updateGroupImage(image: image, conversationId: conversationId, localOnly: localOnly)
            }
            try await localStorageManager.updateGroupImage(image: image, conversationId: conversationId, localOnly: localOnly)
        } catch {
            print("Error delete conversation with hybrid: \(error)")
            throw error
        }
    }
    
    public func getConversationIdFromUserId(opponentUserId: String, myUserId: String) async throws -> String {
        do {
            let conversationId = try await localStorageManager.getConversationIdFromUserId(opponentUserId: opponentUserId, myUserId: myUserId)
            return conversationId
        } catch {
            print("Error delete conversation with hybrid: \(error)")
            throw error
        }
    }
    
    public func exitGroup(conversationId: String) async throws {
        do {
            // Fetch from remote and sync
            try await remoteStorageManager.exitGroup(conversationId: conversationId)
            try await localStorageManager.deleteConversation(conversationId: conversationId)
        } catch {
            print("Error delete conversation with hybrid: \(error)")
            throw error
        }
    }
    
    public func changeTypingStatus(conversationId: String, status: Bool) async throws {
        do {
            try await localStorageManager.changeTypingStatus(conversationId: conversationId, status: status)
        } catch {
            print("Error delete conversation with hybrid: \(error)")
            throw error
        }
    }
    
    public func updateMemberCountInGroup(conversationId: String, inc: Bool, dec: Bool, count: Int) async throws {
        do {
            try await localStorageManager.updateMemberCountInGroup(conversationId: conversationId, inc: inc, dec: dec, count: count)
        } catch {
            print("Error updating member count in group conversation with hybrid: \(error)")
            throw error
        }
    }
    
    public func updateMessageAsDeletedLocally(conversationId: String, messageId: String) async throws {
        do {
            try await localStorageManager.updateMessageAsDeletedLocally(conversationId: conversationId, messageId: messageId)
        } catch {
            print("Error updating member count in group conversation with hybrid: \(error)")
            throw error
        }
    }
}
