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
   
    
    public func createConversation(user : ISMChatUserDB,conversationId : String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            messageViewModel.createConversation(user: user, chatStatus: ISMChatStatus.Reject.value) { response, error in
                if let error = error {
                    continuation.resume(throwing: error) // Handle the error
                } else if let conversationId = response?.conversationId {
                    continuation.resume(returning: conversationId) // Return the conversation ID
                } else {
                    continuation.resume(throwing: NSError(domain: "CreateConversationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"]))
                }
            }
        }
    }
    
    
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
    
    public func deleteConversation(conversationId: String) async throws {
        conversationViewModel.deleteConversation(conversationId: conversationId) {
        }
    }
    
    public func clearConversationMessages(conversationId: String) async throws {
        conversationViewModel.clearChat(conversationId: conversationId) {
        }
    }
    
    public func updateLastMessageInConversation(conversationId : String, lastMessage : ISMChatLastMessageDB) async throws{
        
    }
    
    public func fetchMessages(conversationId: String,lastMessageTimestamp : String) async throws -> [ISMChatMessagesDB] {
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
    
    public func saveAllMessages(_ messages: [ISMChatMessagesDB], conversationId: String) async throws {
        
    }
    
}
