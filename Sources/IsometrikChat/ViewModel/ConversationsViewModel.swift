//
//  C.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 28/02/25.
//

import Foundation
import Combine
import SwiftUI

public class ConversationsViewModel: ObservableObject {
    @Published public var conversations: [ISMChatConversationDB] = []
    public let chatRepository: ChatRepository
    
    public init(chatRepository: ChatRepository = ChatRepository(
        localStorageManager: try! LocalStorageManager(),
        remoteStorageManager: RemoteStorageManager(),
        hybridStorageManager: HybridStorageManager(localStorageManager: try! LocalStorageManager(), remoteStorageManager: RemoteStorageManager())
    )) {
        self.chatRepository = chatRepository
    }
    
    public func loadConversations() async {
        do {
            let fetchedConversations = try await chatRepository.fetchConversations()
            DispatchQueue.main.async {
                self.conversations = fetchedConversations
            }
        } catch {
            print("Error loading conversations: \(error)")
        }
    }
}
