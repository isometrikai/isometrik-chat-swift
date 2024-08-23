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
    
    func shouldLoadMoreData(_ item: ConversationDB) -> Bool {
        guard let lastItem = realmManager.getConversation().last else { return false }
        return item.conversationId == lastItem.conversationId
    }
    
    func loadMoreData() {
        guard viewModel.conversations.count % 20 == 0 else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("call api of pagination again")
            getConversationList()
        }
    }
    
    func userData(completion :@escaping (String?)->()){
        viewModel.getUserData { data in
            if let user = data {
                viewModel.userData = user
                //                self.viewModel.updateUserObj(obj: user)
            }
//            self.userSession.setnotification(on: data?.notification ?? true)
//            self.userSession.setUserProfilePicture(url:  data?.userProfileImageUrl ?? "")
//            self.userSession.setUserName(userName: data?.userName ?? "")
//            self.userSession.setUserEmailId(email: data?.userIdentifier ?? "")
//            self.userSession.setUserBio(bio: data?.metaData?.about ?? "")
//            self.userSession.setLastSeen(showLastSeen: data?.metaData?.showlastSeen ?? true)
            completion(data?.userId)
        }
    }
    
    func getOtherChatCountUpdate(){
        let count = realmManager.getOtherConversationCount()
        let otherConversationCount : [String: Int] = ["count": count]
        NotificationCenter.default.post(name: NSNotification.refreshOtherChatCount, object: nil, userInfo: otherConversationCount)
    }
    
    func getConversationList(){
        viewModel.getChatList(search: "") { data in
            self.viewModel.updateConversationObj(conversations: viewModel.getSortedFilteredChats(conversation: data?.conversations ?? [], query: ""))
            realmManager.manageConversationList(arr: viewModel.getConversation())
            if ISMChatSdkUI.getInstance().getChatProperties().otherConversationList == true{
                getOtherChatCountUpdate()
            }
            if ISMChatSdk.getInstance().getFramework() == .UIKit && ISMChatSdkUI.getInstance().getChatProperties().otherConversationList == true{
                getBroadcastList()
                
                let chatcount = realmManager.getConversationCount()
                let Info : [String: Int] = ["count": chatcount]
                NotificationCenter.default.post(name: NSNotification.updateChatCount, object: nil, userInfo: Info)
            }
        }
    }
    
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
    
    func deleteConversation(conversationId: String) {
        viewModel.deleteConversation(conversationId: conversationId) {
            realmManager.deleteConversation(convID: conversationId)
            realmManager.deleteMessagesThroughConvId(convID: conversationId)
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.viewModel.resetdata()
                self.viewModel.clearMessages()
                realmManager.getAllConversations()
            })
        }
    }
    
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
    
    func exitGroup(conversationId : String){
        viewModel.exitGroup(conversationId: conversationId) {
            realmManager.deleteConversation(convID: conversationId)
            realmManager.deleteMessagesThroughConvId(convID: conversationId)
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.viewModel.resetdata()
                self.viewModel.clearMessages()
                realmManager.getAllConversations()
            })
        }
    }
    
    func searchInConversationList(){
        let  conversation = realmManager.storeConv
        realmManager.conversations = conversation.filter { conversation in
            let createdByUserNameCondition = conversation.opponentDetails?.userName?.contains(query) ?? false
            let conversationTitleCondition = conversation.conversationTitle.contains(query)
            return (createdByUserNameCondition || conversationTitleCondition)
        }
    }
}
