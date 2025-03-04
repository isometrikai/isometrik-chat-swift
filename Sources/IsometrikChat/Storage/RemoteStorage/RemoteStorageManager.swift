//
//  RemoteStorageManager.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 27/02/25.
//

import Foundation

public class RemoteStorageManager: ChatStorageManager {
    
    
    public let conversationViewModel = ConversationViewModel()
    public let messageViewModel = ChatsViewModel()
    public init(){}
   
    
    // Implement all protocol methods using API calls
    public func fetchConversations() async throws -> [ISMChatConversationDB] {
        return try await withCheckedThrowingContinuation { continuation in
            conversationViewModel.getChatList(passSkip: true, search: "") { conversations in
                if let conversations = conversations {
                    self.conversationViewModel.conversations = conversations.conversations ?? []
                    // Create an array to hold the converted DB models
                    var convertedConversations: [ISMChatConversationDB] = []
                    
                    // Unwrap the conversations.conversations array before iterating
                    if let conversationList = conversations.conversations {
                        // Loop through each conversation and convert it
                        for conversation in conversationList {
                            let dbConversation = conversation.toConversationDB()
                            convertedConversations.append(dbConversation)
                        }
                    }
                    
                    continuation.resume(returning: convertedConversations)
                } else {
                    self.conversationViewModel.conversations = []
                    continuation.resume(throwing: NSError(domain: "ChatError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch conversations"]))
                }
            }
        }
    }
    
    public func saveConversation(_ conversations: [ISMChatConversationDB]) async throws {
        
    }
    
    public func deleteConversation(id: String) async throws {
        conversationViewModel.deleteConversation(conversationId: id) {
        }
    }
    
    public func clearConversation(id: String) async throws {
        conversationViewModel.clearChat(conversationId: id) {
        }
    }
    
    public func fetchMessages(conversationId: String) async throws -> [ISMChatMessagesDB] {
        return try await withCheckedThrowingContinuation { continuation in
            messageViewModel.getMessages(conversationId: conversationId, lastMessageTimestamp: "") { messages in
                if let messages = messages {
                    self.messageViewModel.allMessages = messages.messages ?? []

                    // Create an array to hold the converted DB models
                    var convertedMessages: [ISMChatMessagesDB] = []

                    // Unwrap the messages array before iterating
                    if let messageList = messages.messages {
                        for message in messageList {
                            let dbMessage = message.toMessageDB() // Assuming you have this function
                            convertedMessages.append(dbMessage)
                        }
                    }

                    continuation.resume(returning: convertedMessages)
                } else {
                    self.messageViewModel.messages = []
                    continuation.resume(throwing: NSError(domain: "ChatError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch messages"]))
                }
            }
        }
    }

}
