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
    @Published public var conversationData: [ISMChatConversationDB] = []
    @Published public var conversations: [ISMChatConversationDB] = []
    @Published public var primaryConversations: [ISMChatConversationDB] = []
    @Published public var otherConversations: [ISMChatConversationDB] = [] //other conversations are those who other normal user or start User send me message for first time so i can accept or decline chat
    
    @Published public var allMessages : [ISMChatMessagesDB] = []
    @Published public var messages : [[ISMChatMessagesDB]] = []
    @Published public var medias : [ISMChatMediaDB] = []
    @Published public var files : [ISMChatMediaDB] = []
    @Published public var links : [ISMChatMessagesDB] = []
    
    public var userData = ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig
    public let chatRepository: ChatRepository
    
    public init(chatRepository: ChatRepository = ChatRepository(
        localStorageManager: try! LocalStorageManager(),
        remoteStorageManager: RemoteStorageManager(),
        hybridStorageManager: HybridStorageManager(localStorageManager: try! LocalStorageManager(), remoteStorageManager: RemoteStorageManager())
    )) {
        self.chatRepository = chatRepository
    }
    
    public func deleteSwiftData() async{
        do {
            try await chatRepository.deleteSwiftData()
        } catch {
            print("Error loading conversations: \(error)")
        }
    }
    
    public func createConversation(user : ISMChatUserDB) async -> String{
        do {
            let conversationId = try await chatRepository.createConversation(user: user, conversationId: "")
            let fetchedConversations = try await chatRepository.fetchConversations()
            DispatchQueue.main.async {
                self.conversations = fetchedConversations
                self.otherConversations = self.getOtherConversation()
                self.primaryConversations = self.getPrimaryConversation()
            }
            return conversationId
        } catch {
            print("Error loading conversations: \(error)")
            return ""
        }
    }
    
    public func loadConversations(showOtherList : Bool) async {
        do {
            let fetchedConversations = try await chatRepository.fetchConversations()
            DispatchQueue.main.async {
                self.conversations = fetchedConversations
                self.otherConversations = self.getOtherConversation()
                self.primaryConversations = self.getPrimaryConversation()
                self.conversationData =  showOtherList == true ? self.primaryConversations : self.conversations
            }
        } catch {
            print("Error loading conversations: \(error)")
        }
    }
    
    public func loadConversationsLocal(showOtherList : Bool) async {
        do {
            let fetchedConversations = try await chatRepository.fetchConversationsLocal()
            DispatchQueue.main.async {
               
                self.conversations = fetchedConversations
                self.otherConversations = self.getOtherConversation()
                self.primaryConversations = self.getPrimaryConversation()
                self.conversationData =  showOtherList == true ? self.primaryConversations : self.conversations
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
            await MainActor.run {
                self.allMessages.removeAll()
                self.messages.removeAll()
            }
            try await chatRepository.clearConversationMessages(conversationId: id)
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
    
    public func updateUnreadCountThroughConversation(conversationId: String, count: Int, reset: Bool?) async {
        do {
            try await chatRepository.updateUnreadCountThroughConversation(conversationId: conversationId, count: count, reset: reset)
        } catch {
            print("Error loading conversations: \(error)")
        }
    }
    
    public func loadMessages(fromBroadCastFlow: Bool,conversationId : String,lastMessageTimestamp: String) async {
        do {
            let fetchedMessages = try await chatRepository.fetchMessages(fromBroadCastFlow: fromBroadCastFlow,conversationId: conversationId, lastMessageTimestamp: lastMessageTimestamp,onlyLocal: false)
            DispatchQueue.main.async {
                //i have filter some action type to not show in UI
                self.allMessages = fetchedMessages.filter { message in
                                            return message.action != "clearConversation" && message.action != "deleteConversationLocally" && message.action != "reactionAdd" && message.action != "reactionRemove" && message.action != "messageDetailsUpdated" && message.action != "conversationSettingsUpdated" && message.action != "meetingCreated"
                                        }
                self.messages = self.getSectionMessage(for: self.allMessages)
            }
        } catch {
            print("Error loading conversations: \(error)")
        }
    }
    
    public func loadMessagesLocallyToUpdateUI(fromBroadCastFlow: Bool,conversationId : String,lastMessageTimestamp: String) async {
        do {
            let fetchedMessages = try await chatRepository.fetchMessages(fromBroadCastFlow: fromBroadCastFlow,conversationId: conversationId, lastMessageTimestamp: lastMessageTimestamp,onlyLocal: true)
            DispatchQueue.main.async {
                //i have filter some action type to not show in UI
                self.allMessages = fetchedMessages.filter { message in
                                            return message.action != "clearConversation" && message.action != "deleteConversationLocally" && message.action != "reactionAdd" && message.action != "reactionRemove" && message.action != "messageDetailsUpdated" && message.action != "conversationSettingsUpdated" && message.action != "meetingCreated"
                                        }
                self.messages = self.getSectionMessage(for: self.allMessages)
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
    
    public func saveMessages(conversationId : String,messages: [ISMChatMessagesDB]) async {
        do {
            let _ = try await chatRepository.saveAllMessages(messages, conversationId: conversationId)
            DispatchQueue.main.async {
                self.allMessages.append(contentsOf: messages)
                self.messages = self.getSectionMessage(for: self.allMessages)
            }
        } catch {
            print("Error loading conversations: \(error)")
        }
    }
    
    public func updateLastmsgInConversation(conversationId: String, lastmsg: ISMChatLastMessageDB) async{
        do {
            let _ = try await chatRepository.updateLastMessageInConversation(conversationId: conversationId, lastMessage: lastmsg)
        } catch {
            print("Error loading conversations: \(error)")
        }
    }
    
    public func updateMessageId(objectId: UUID, msgId: String, conversationId: String, mediaUrl: String, thumbnailUrl: String, mediaSize: Int, mediaId: String) async {
        do {
            let _ = try await chatRepository.updateMsgId(objectId: objectId, msgId: msgId, conversationId: conversationId, mediaUrl: mediaUrl, thumbnailUrl: thumbnailUrl, mediaSize: mediaSize, mediaId: mediaId)
            if let index = allMessages.firstIndex(where: { $0.id == objectId }) {
                allMessages[index].messageId = msgId
                if !mediaUrl.isEmpty{
                    allMessages[index].attachments?.first?.mediaUrl = mediaUrl
                }
                if !thumbnailUrl.isEmpty{
                    allMessages[index].attachments?.first?.thumbnailUrl = thumbnailUrl
                }
                if mediaSize > 0{
                    allMessages[index].attachments?.first?.size = mediaSize
                }
                if !mediaId.isEmpty{
                    allMessages[index].attachments?.first?.mediaId = mediaId
                }
            }
            
            // ✅ Manually update messages array (2D Array)
            for (sectionIndex, section) in messages.enumerated() {
                if let messageIndex = section.firstIndex(where: { $0.id == objectId }) {
                    messages[sectionIndex][messageIndex].messageId = msgId
                    if !mediaUrl.isEmpty{
                        messages[sectionIndex][messageIndex].attachments?.first?.mediaUrl = mediaUrl
                    }
                    if !thumbnailUrl.isEmpty{
                        messages[sectionIndex][messageIndex].attachments?.first?.thumbnailUrl = thumbnailUrl
                    }
                    if mediaSize > 0{
                        messages[sectionIndex][messageIndex].attachments?.first?.size = mediaSize
                    }
                    if !mediaId.isEmpty{
                        messages[sectionIndex][messageIndex].attachments?.first?.mediaId = mediaId
                    }
                    break // No need to continue searching once updated
                }
            }
        } catch {
            print("Error updating message Id in conversations: \(error)")
        }
    }
    
    public func updateMessage(conversationId: String, messageId: String, body: String, metaData: ISMChatMetaDataDB? = nil, customType: String? = nil) async {
        do {
            let _ = try await chatRepository.updateMessage(conversationId: conversationId, messageId: messageId, body: body, metaData: metaData, customType: customType)
        } catch {
            print("Error updating message Id in conversations: \(error)")
        }
    }
    
    public func saveMedia(arr: [ISMChatAttachmentDB],conversationId: String,customType: String,sentAt: Double,messageId: String,userName: String) async {
        do {
            let _ = try await chatRepository.saveMedia(arr: arr, conversationId: conversationId, customType: customType, sentAt: sentAt, messageId: messageId, userName: userName)
        } catch {
            print("Error saving media in conversations: \(error)")
        }
    }
    
    public func fetchPhotosAndVideos(conversationId : String) async{
        do {
            let medias = try await chatRepository.fetchPhotosAndVideos(conversationId: conversationId)
            DispatchQueue.main.async {
                self.medias = medias
            }
        } catch {
            print("Error saving media in conversations: \(error)")
        }
    }
    
    public func fetchFiles(conversationId : String) async{
        do {
            let files = try await chatRepository.fetchFiles(conversationId: conversationId)
            DispatchQueue.main.async {
                self.files = files
            }
        } catch {
            print("Error saving media in conversations: \(error)")
        }
    }
    
    public func fetchLinks(conversationId : String) async{
        do {
            let links = try await chatRepository.fetchLinks(conversationId: conversationId)
            DispatchQueue.main.async {
                self.links = links
            }
        } catch {
            print("Error saving media in conversations: \(error)")
        }
    }
    
    public func updateGroupTitle(title: String, conversationId: String,localOnly : Bool) async{
        do {
            try await chatRepository.updateGroupTitle(title: title, conversationId: conversationId, localOnly: localOnly)
        } catch {
            print("Error loading conversations: \(error)")
        }
    }
    
    public func updateGroupImage(image: String, conversationId: String,localOnly : Bool) async{
        do {
            try await chatRepository.updateGroupImage(image: image, conversationId: conversationId, localOnly: localOnly)
        } catch {
            print("Error loading conversations: \(error)")
        }
    }
    
    public func getConversationIdFromUserId(opponentUserId : String,myUserId: String) -> String{
        do {
            let conversationId = chatRepository.getConversationIdFromUserId(opponentUserId: opponentUserId, myUserId: myUserId)
            return conversationId
        } catch {
            print("Unable to find conversationId: \(error)")
            return ""
        }
    }
    
    public func exitGroup(conversationId: String) async{
        do {
            try await chatRepository.exitGroup(conversationId: conversationId)
        } catch {
            print("Unable exit group: \(error)")
        }
    }
    
    public func changeTypingStatus(conversationId: String, status: Bool) async{
        do {
            try await chatRepository.changeTypingStatus(conversationId: conversationId, status: status)
        } catch {
            print("Unable exit group: \(error)")
        }
    }
    
    public func updateMemberCountInGroup(conversationId: String, inc: Bool, dec: Bool, count: Int) async{
        do {
            try await chatRepository.updateMemberCountInGroup(conversationId: conversationId, inc: inc, dec: dec, count: count)
        } catch {
            print("Unable to update member count in group: \(error)")
        }
    }
    
    public func updateMessageAsDeletedLocally(conversationId: String,messageId: String) async{
        do {
            try await chatRepository.updateMessageAsDeletedLocally(conversationId: conversationId, messageId: messageId)
        } catch {
            print("Unable to update member count in group: \(error)")
        }
    }
    
    public func doesMessageExistInMessagesDB(conversationId: String,messageId: String) async -> Bool{
        do {
           let x =  try await chatRepository.doesMessageExistInMessagesDB(conversationId: conversationId, messageId: messageId)
            return x
        } catch {
            print("Unable to update member count in group: \(error)")
            return false
        }
    }
    
    public func getLastInputTextInConversation(conversationId : String) async -> String{
        do {
            let x =  try await chatRepository.getLastInputTextInConversation(conversationId: conversationId)
            return x
        } catch {
            print("Unable to get last input text : \(error)")
            return ""
        }
    }
    
    public func saveLastInputTextInConversation(text: String, conversationId: String) async{
        do {
            try await chatRepository.saveLastInputTextInConversation(text: text, conversationId: conversationId)
        } catch {
            print("Unable to save last input text : \(error)")
        }
    }
    
    public func getMemberCount(conversationId:String) async -> Int{
        do {
            let x =  try await chatRepository.getMemberCount(conversationId: conversationId)
            return x
        } catch {
            print("Unable to get last input text : \(error)")
            return -1
        }
    }
    
    public func addReactionToMessage(conversationId: String, messageId: String, reaction: String, userId: String) async {
        do {
            try await chatRepository.addReactionToMessage(conversationId: conversationId, messageId: messageId, reaction: reaction, userId: userId)
        } catch {
            print("Unable to add last message on add and remove reaction : \(error)")
        }
    }
    
    public func addLastMessageOnAddAndRemoveReaction(conversationId: String,action : String,emoji : String,userId: String) async {
        do {
              try await chatRepository.addLastMessageOnAddAndRemoveReaction(conversationId: conversationId, action: action, emoji: emoji, userId: userId)
        } catch {
            print("Unable to add last message on add and remove reaction : \(error)")
        }
    }
}
