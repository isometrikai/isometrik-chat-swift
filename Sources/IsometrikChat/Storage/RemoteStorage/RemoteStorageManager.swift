//
//  RemoteStorageManager.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 27/02/25.
//

import Foundation

public class RemoteStorageManager: ChatStorageManager {
    public func deleteSwiftData() async throws {
        
    }
    
    public func fetchConversationsLocal() async throws -> [ISMChatConversationDB] {
        return []
    }
    
    
    
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
    public func updateUnreadCountThroughConversation(conversationId: String, count: Int, reset: Bool?) async throws {
       
    }
    
    public func fetchMessages(conversationId: String,lastMessageTimestamp : String,onlyLocal : Bool) async throws -> [ISMChatMessagesDB] {
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
    
    public func updateMsgId(objectId: UUID, msgId: String, conversationId: String, mediaUrl: String, thumbnailUrl: String, mediaSize: Int, mediaId: String) async throws {
        
    }
    
    public func updateMessage(conversationId: String, messageId: String, body: String, metaData: ISMChatMetaDataDB?, customType: String?) async throws {
        
    }
    
    public func saveMedia(arr: [ISMChatAttachmentDB], conversationId: String, customType: String, sentAt: Double, messageId: String, userName: String) async throws {
        
    }
    
    public func fetchPhotosAndVideos(conversationId: String) async throws -> [ISMChatMediaDB] {
        return []
    }
    
    public func fetchFiles(conversationId: String) async throws -> [ISMChatMediaDB] {
        return []
    }
    
    public func fetchLinks(conversationId: String) async throws -> [ISMChatMessagesDB] {
        return []
    }
    
    public func deleteMedia(conversationId: String, messageId: String) async throws {
        
    }
    
    public func updateGroupTitle(title: String, conversationId: String,localOnly : Bool) async throws {
        messageViewModel.updateGroupTitle(title: title, conversationId: conversationId ?? "") { _ in
        }
    }
    
    public func updateGroupImage(image: String, conversationId: String,localOnly : Bool) async throws {
        messageViewModel.updateGroupImage(image: image, conversationId: conversationId) { _ in
            
        }
    }
    
    public func getConversationIdFromUserId(opponentUserId: String, myUserId: String)  -> String {
        return ""
    }
    
    public func exitGroup(conversationId: String) async throws {
        messageViewModel.exitGroup(conversationId: conversationId) {
        }
    }
    
    public func changeTypingStatus(conversationId: String, status: Bool) async throws {
        
    }
    
    public func updateMemberCountInGroup(conversationId: String, inc: Bool, dec: Bool, count: Int) async throws {
        
    }
    
    public func getMemberCount(conversationId: String) async throws -> Int {
        return -1
    }
    
    public func updateMessageAsDeletedLocally(conversationId: String, messageId: String) async throws {
        
    }
    public func doesMessageExistInMessagesDB(conversationId: String, messageId: String) async throws -> Bool {
        return false
    }
    
    public func getLastInputTextInConversation(conversationId: String) async throws -> String {
        return ""
    }
    
    public func saveLastInputTextInConversation(text: String, conversationId: String) async throws {
        
    }
    
    public func addLastMessageOnAddAndRemoveReaction(conversationId: String, action: String, emoji: String, userId: String) async throws {
        
    }
}
