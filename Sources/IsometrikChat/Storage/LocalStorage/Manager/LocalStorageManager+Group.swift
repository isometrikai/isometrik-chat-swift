//
//  LocalDBManager+Group.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 26/02/25.
//

import SwiftData
import Foundation

extension LocalStorageManager{
    public func updateMemberCount(convId: String, inc: Bool, dec: Bool, count: Int) {
        do {
            let descriptor = FetchDescriptor<ISMChatConversationDB>(predicate: #Predicate { $0.conversationId == convId})
            let listToUpdate = try modelContext.fetch(descriptor)
            
            guard let conversation = listToUpdate.first else { return }
            
            if inc {
                conversation.membersCount += 1
            } else if dec {
                conversation.membersCount -= 1
            } else {
                conversation.membersCount = count
            }
        } catch {
            print("Error updating member count: \(error)")
        }
    }

    public func changeGroupName(conversationId: String, conversationTitle: String) {
        do {
            let descriptor = FetchDescriptor<ISMChatConversationDB>(predicate: #Predicate { $0.conversationId == conversationId})
            let taskToUpdate = try modelContext.fetch(descriptor)
            
            guard let conversation = taskToUpdate.first else { return }
            
            conversation.conversationTitle = conversationTitle
//            fetchAllConversations()
        } catch {
            print("Error updating group name: \(error)")
        }
    }

    public func changeGroupIcon(conversationId: String, conversationIcon: String) {
        do {
            let descriptor = FetchDescriptor<ISMChatConversationDB>(predicate: #Predicate { $0.conversationId == conversationId})
            let taskToUpdate = try modelContext.fetch(descriptor)
            
            guard let conversation = taskToUpdate.first else { return }
            
            conversation.conversationImageUrl = conversationIcon
//            fetchAllConversations()
        } catch {
            print("Error updating group icon: \(error)")
        }
    }

}
