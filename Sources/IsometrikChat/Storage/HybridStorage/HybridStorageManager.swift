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
    
    public func deleteConversation(id: String) async throws {
        do {
            // Fetch from remote and sync
            try await remoteStorageManager.deleteConversation(id: id)
            try await localStorageManager.deleteConversation(id: id)
        } catch {
            print("Error delete conversation with hybrid: \(error)")
            throw error
        }
    }
    
    public func clearConversation(id: String) async throws {
        
    }
    
}
