//
//  RealmManagerReactions.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/06/24.
//

import Foundation
import RealmSwift


extension RealmManager{
    
    //MARK: - add reaction for message locally
    public func addReactionToMessage(conversationId: String, messageId: String, reaction: String, userId: String) {
        if let localRealm = localRealm {
            let messageToUpdate = localRealm.objects(MessagesDB.self).filter("conversationId == %@ AND isDelete == false AND messageId == %@", conversationId, messageId)

            try! localRealm.write {
                if let message = messageToUpdate.first {
                    // Check if there's an existing reaction of the specified type
                    if let existingReaction = message.reactions.first(where: { $0.reactionType == reaction }) {
                        // Only append userId if it does not already exist
                        if !existingReaction.users.contains(userId) {
                            existingReaction.users.append(userId)
                        }
                    } else {
                        // Create a new reaction and add it to the message
                        let newReaction = ReactionDB()
                        newReaction.reactionType = reaction
                        newReaction.users.append(userId)
                        message.reactions.append(newReaction)
                    }
                }
            }
        }
    }
    
    
    //MARK: - remove reaction for message locally
    public func removeReactionFromMessage(conversationId: String, messageId: String, reaction: String, userId: String) {
        if let localRealm = localRealm {
            let messageToUpdate = localRealm.objects(MessagesDB.self).filter("conversationId == %@ AND isDelete == false AND messageId == %@", conversationId, messageId)
            if let message = messageToUpdate.first {
                try! localRealm.write {
                    // Iterate over reactions
                    for reactionDB in message.reactions {
                        // Check if reaction type matches
                        if reactionDB.reactionType == reaction {
                            // Check if the user exists in this reaction
                            if let userIndex = reactionDB.users.firstIndex(of: userId) {
                                // Remove the user from the reaction
                                reactionDB.users.remove(at: userIndex)
                                // If the reaction has no users left, remove it
                                if reactionDB.users.isEmpty {
                                    localRealm.delete(reactionDB)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
