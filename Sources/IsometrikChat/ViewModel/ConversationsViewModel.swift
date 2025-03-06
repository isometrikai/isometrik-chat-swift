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
    @Published public var primaryConversations: [ISMChatConversationDB] = []
    @Published public var otherConversations: [ISMChatConversationDB] = [] //other conversations are those who other normal user or start User send me message for first time so i can accept or decline chat
    
    @Published public var allMessages : [ISMChatMessagesDB] = []
    @Published public var messages : [[ISMChatMessagesDB]] = []
    public var userData = ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig
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
                self.otherConversations = self.getOtherConversation()
                self.primaryConversations = self.getPrimaryConversation()
            }
        } catch {
            print("Error loading conversations: \(error)")
        }
    }
    
    public func deleteConversations(id: String) async {
        do {
            // Ensure delete completes before fetching conversations
            try await chatRepository.deleteConversation(conversationId: id)

            // Fetch updated conversations list
            let fetchedConversations = try await chatRepository.fetchConversations()

            // Update UI on main thread
            await MainActor.run {
                self.conversations = fetchedConversations
                self.otherConversations = self.getOtherConversation()
                self.primaryConversations = self.getPrimaryConversation()
            }
        } catch {
            print("Error loading conversations: \(error)")
        }
    }
    
    public func clearConversationMessages(id: String) async {
        do {
            // Ensure delete completes before fetching conversations
            try await chatRepository.clearConversationMessages(conversationId: id)
            await MainActor.run {
                self.allMessages.removeAll()
                self.messages.removeAll()
            }
        } catch {
            print("Error loading conversations: \(error)")
        }
    }
    
    public func getPrimaryConversation() -> [ISMChatConversationDB] {
        let otherConversations = self.getOtherConversation()
        let primaryConversations = conversations.filter { conversation in
            !otherConversations.contains(where: { $0.id == conversation.id })
        }
        return primaryConversations
    }
    
    public func getOtherConversation() -> [ISMChatConversationDB] {
        let filteredOutConversations = conversations.filter { conversation in
            // Check if the user is a business user
            if conversation.createdBy != userData?.userId{
                if ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userProfileType == ISMChatUserProfileType.Bussiness.value {
                    // If user is a business user
                    if let metaData = conversation.opponentDetails?.metaData ,let ConversationMetaData = conversation.metaData{
                        // Check if opponent's profileType is not "user" or "influencer" or allowToMessage is true
                        if metaData.userType == 1 && ConversationMetaData.chatStatus == ISMChatStatus.Reject.value{
                            return true
                        }else{
                            return false
                        }
                    }
                    return false // Reject conversations with opponents other than "user" or "influencer"
                } else  if ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userProfileType == ISMChatUserProfileType.Influencer.value {
                    if let metaData = conversation.opponentDetails?.metaData ,let ConversationMetaData = conversation.metaData{
                        // Check if opponent's profileType is not "user" or allowToMessage is true
                        if metaData.userType == 1 && metaData.isStarUser != true && ConversationMetaData.chatStatus == ISMChatStatus.Reject.value{
                            return true
                        } else {
                            return false
                        }
                    }
                    return false
                } else {
                    return false
                }
            }else{
                //if created by me then it should be in primary list
                return false
            }
        }
        return filteredOutConversations
    }
    
    public func loadMessages(conversationId : String,lastMessageTimestamp: String) async {
        do {
            let fetchedMessages = try await chatRepository.fetchMessages(conversationId: conversationId, lastMessageTimestamp: lastMessageTimestamp)
            DispatchQueue.main.async {
                self.allMessages = fetchedMessages
                self.messages = self.getSectionMessage(for: fetchedMessages)
            }
        } catch {
            print("Error loading conversations: \(error)")
        }
    }
    
    public func getSectionMessage(for chat : [ISMChatMessagesDB]) -> [[ISMChatMessagesDB]] {
        var res = [[ISMChatMessagesDB]]()
        let groupedMessages = Dictionary(grouping: chat) { (element) -> Date in
            
            //timestamp
            let timeStamp = element.sentAt
            let unixTimeStamp: Double = Double(timeStamp ) / 1000.0
            let dateFormatt = DateFormatter()
            dateFormatt.dateFormat = "dd/MM/yyy"
            //conver to string
            let strDate = dateFormatt.string(from: Date(timeIntervalSince1970: unixTimeStamp) as Date)
            //str to date
            return dateFormatt.date(from: strDate) ?? Date()
        }
        let sortedKeys = groupedMessages.keys.sorted()
        sortedKeys.forEach { (key) in
            var values = groupedMessages[key]
            values?.sort { Double($0.sentAt ) / 1000.0 < Double($1.sentAt ) / 1000.0 }
            res.append(values ?? [])
        }
        return res
    }
    
    public func getSenderInfo(messageId: String) -> ISMChatUserDB? {
        if let message = self.allMessages.first(where: { $0.messageId == messageId }) {
            return message.senderInfo
        }else{
            return nil
        }
    }
}
