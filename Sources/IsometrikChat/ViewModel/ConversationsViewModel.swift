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
            let fetchedConversations = try await chatRepository.deleteConversation(id: id)
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
}
