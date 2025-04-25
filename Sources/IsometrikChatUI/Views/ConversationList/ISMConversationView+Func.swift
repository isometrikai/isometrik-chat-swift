//
//  ISMConversationView+Func.swift
//  ISMChatSdk
//
//  Created by Rasika on 02/05/24.
//

import Foundation
import SwiftUI
import IsometrikChat

extension ISMConversationView{
    
    /// Determines if more data should be loaded based on the last conversation.
    /// - Parameter item: The conversation item to check.
    /// - Returns: A boolean indicating whether to load more data.
    func shouldLoadMoreData(_ item: ConversationDB) -> Bool {
        guard let lastItem = realmManager.getConversation().last else { return false }
        return item.conversationId == lastItem.conversationId
    }
    
    /// Loads more conversation data if the current count is a multiple of 20.
    func loadMoreData() {
        guard viewModel.conversations.count % 20 == 0 else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("call api of pagination again")
            getConversationList()
        }
    }
    
    /// Fetches user data and updates the view model with the retrieved information.
    /// - Parameter completion: A closure that returns the user ID.
    func getuserData(completion :@escaping (String?)->()){
        viewModel.getUserData { data in
            if let user = data {
                viewModel.userData = user
            }
            completion(data?.userId)
        }
    }
    
    /// Updates the count of other conversations and posts a notification.
    func getOtherChatCountUpdate(){
        let count = realmManager.getOtherConversationCount()
        let otherConversationCount : [String: Int] = ["count": count]
        NotificationCenter.default.post(name: NSNotification.refreshOtherChatCount, object: nil, userInfo: otherConversationCount)
    }
    
    /// Retrieves the list of conversations and updates the view model accordingly.
    func getConversationList(){
        viewModel.getChatList(search: "") { data in
            self.viewModel.updateConversationObj(conversations: viewModel.getSortedFilteredChats(conversation: data?.conversations ?? [], query: ""))
            realmManager.manageConversationList(arr: viewModel.getConversation())
            if ISMChatSdkUI.getInstance().getChatProperties().otherConversationList == true{
                getOtherChatCountUpdate()
            }
            if ISMChatSdk.getInstance().getFramework() == .UIKit && ISMChatSdkUI.getInstance().getChatProperties().otherConversationList == true{
                getBroadcastList()
                
                let chatcount = ISMChatSdkUI.getInstance().getChatProperties().otherConversationList == true ? realmManager.getPrimaryConversationCount() : realmManager.getConversationCount()
                let Info : [String: Int] = ["count": chatcount]
                NotificationCenter.default.post(name: NSNotification.updateChatCount, object: nil, userInfo: Info)
            }
        }
    }
    
    /// Fetches the broadcast list and updates the realm manager with the retrieved data.
    func getBroadcastList(){
        chatViewModel.getBroadCastList { data in
            if let groupcast = data?.groupcasts{
                realmManager.manageBroadCastList(arr: groupcast)
                
                let count = realmManager.getBroadCastsCount()
                let Info : [String: Int] = ["count": count]
                NotificationCenter.default.post(name: NSNotification.updateBroadCastCount, object: nil, userInfo: Info)
            }
        }
    }
    
    /// Deletes a conversation and its associated messages and media.
    /// - Parameter conversationId: The ID of the conversation to delete.
    func deleteConversation(conversationId: String) {
        viewModel.deleteConversation(conversationId: conversationId) {
            realmManager.deleteConversation(convID: conversationId)
            realmManager.deleteMessagesThroughConvId(convID: conversationId)
            realmManager.deleteMediaThroughConversationId(convID: conversationId)
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.viewModel.resetdata()
                self.viewModel.clearMessages()
                realmManager.getAllConversations()
            })
        }
    }
    
    /// Clears the messages of a conversation without deleting it.
    /// - Parameter conversationId: The ID of the conversation to clear.
    func clearConversation(conversationId : String){
        viewModel.clearChat(conversationId: conversationId) {
            self.realmManager.clearMessages()
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.realmManager.clearMessages(convID: conversationId)
                self.viewModel.resetdata()
                self.viewModel.clearMessages()
                realmManager.getAllConversations()
            })
        }
    }
    
    /// Exits a group conversation and deletes its associated data.
    /// - Parameter conversationId: The ID of the group conversation to exit.
    func exitGroup(conversationId : String){
        chatViewModel.exitGroup(conversationId: conversationId) {
            realmManager.deleteConversation(convID: conversationId)
            realmManager.deleteMessagesThroughConvId(convID: conversationId)
            realmManager.deleteMediaThroughConversationId(convID: conversationId)
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.viewModel.resetdata()
                self.viewModel.clearMessages()
                realmManager.getAllConversations()
            })
        }
    }
    
    /// Searches for conversations based on a query and updates the conversation list.
    func searchInConversationList() {
        let conversation = realmManager.storeConv
        realmManager.conversations = conversation.filter { conversation in
            // Convert query to lowercase for case-insensitive search
            let lowercasedQuery = query.lowercased()
            
            // Check opponent's username for the query (case-insensitive)
            let createdByUserNameCondition = conversation.opponentDetails?.userName?.lowercased().contains(lowercasedQuery) ?? false
            
            // Check conversation title for the query (case-insensitive)
            let conversationTitleCondition = conversation.conversationTitle.lowercased().contains(lowercasedQuery)
            
            return (createdByUserNameCondition || conversationTitleCondition)
        }
    }
}
