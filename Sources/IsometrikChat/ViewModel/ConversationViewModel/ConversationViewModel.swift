//
//  ConversationViewModel.swift
//  ISMChatSdk
//
//  Created by Rahul Iphone123 on 12/06/23.
//


import Foundation
import UIKit
import Alamofire
import LinkPresentation
import SwiftUI
import Combine
import Contacts

public class ConversationViewModel : NSObject ,ObservableObject{
    
    //MARK:  - PROPERTIES
    @Published public var searchedText = ""
    @Published public var debounceSearchedText = ""

    
    @Published public var conversations : [ISMChatConversationsDetail] = []
    @Published public var userData : ISMChatUser?
    @Published public var messages : [[ISMChatMessage]]?
    @Published public var allMessages  :  ISMChatMessages?
    @Published public var usersSectionDictionary : Dictionary<String , [ISMChatUser]> = [:]
    @Published public var contactSectionDictionary : Dictionary<String , [ISMChatContacts]> = [:]
    @Published public var users : [ISMChatUser] = []
    @Published public var contacts : [ISMChatContacts] = []
    @Published public var eligibleUsers : [ISMChatUser] = []
    @Published public var elogibleUsersSectionDictionary : Dictionary<String , [ISMChatUser]> = [:]
    // Separate user lists for create group/broadcast screen
    @Published public var createGroupUsers : [ISMChatUser] = []
    @Published public var createGroupUsersSectionDictionary : Dictionary<String , [ISMChatUser]> = [:]
    @Published public var blockUser = [ISMChatUser]()
    @Published public var chatLimit = 10
    @Published public var moreDataAvailableForChatList = true
    @Published public var getUsersLimit = 20
    @Published public var moreDataAvailableForGetUsers = true
    @Published public var moreDataAvailableForCreateGroupUsers = true
    @Published public var apiCalling = false
    @Published public var createGroupApiCalling = false
    @Published public var profileSwitched : Bool = false
    
    public override init(){
        super.init()
        self.setSearchedTextDebounce()
    }
    
    public func setSearchedTextDebounce(){
        debounceSearchedText = self.searchedText
        $searchedText
            .debounce(for: .seconds(0.75), scheduler: RunLoop.main)
            .assign(to: &$debounceSearchedText)
    }
    
    
    
    //MARK: - Get Conversation List with Custom Type
    public func getChatListWithCustomType(customType : String,search : String?,skip :Int,completion:@escaping(ISMChatConversations?,ISMChatNewAPIError?)->()){
        
        let endPoint = ISMChatConversationEndpoint.getconversationListWithCustomType(includeConversationStatusMessagesInUnreadMessagesCount: false, customType: customType, searchTag: search ?? "", skip: skip)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatConversations, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data,nil)
            case .failure(let error) :
                completion(nil,error)
                ISMChatHelper.print("Get Chat Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - Get Conversations List
    public func getChatList(passSkip: Bool? = true ,search : String?,completion:@escaping(ISMChatConversations?)->()){
        var skipNew = 0
        if passSkip == true{
            skipNew = self.conversations.count
        }
        let endPoint = ISMChatConversationEndpoint.getconversationList(includeConversationStatusMessagesInUnreadMessagesCount: false, skip: skipNew, searchTag: search ?? "")
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatConversations, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                self.moreDataAvailableForChatList = false
                ISMChatHelper.print("Get Chat Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    
    //MARK: - Delete Conversation
    public func deleteConversation(conversationId: String, completion:@escaping()->()){
        
        let endPoint = ISMChatConversationEndpoint.deleteConversationLocally(conversationId: conversationId)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatUser, ISMChatNewAPIError>) in
            switch result{
            case .success(_,_) :
                completion()
            case .failure(let error) :
                self.moreDataAvailableForChatList = false
                ISMChatHelper.print("Get delete Conversation Api failed -----> \(String(describing: error))")
            }
        }
    }
    
  
    //MARK: - Mute - UnMute Notification
    public func muteUnmuteNotification(conversationId: String,pushNotifications : Bool, completion:@escaping(Bool?)->()){
        var body = [String : Any]()
        body["pushNotifications"] = pushNotifications
        body["conversationId"] = conversationId
        
        let endPoint = ISMChatConversationEndpoint.updateConversationSetting
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(_,_) :
                completion(true)
            case .failure(let error) :
                ISMChatHelper.print("update conversation Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    
    //MARK: - Clear Chat
    public func clearChat(conversationId: String, completion:@escaping()->()){
        
        let endPoint = ISMChatConversationEndpoint.clearConversationMessages(conversationId: conversationId)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatUser, ISMChatNewAPIError>) in
            switch result{
            case .success(_,_) :
                completion()
            case .failure(let error) :
                ISMChatHelper.print("Get clear chat Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    public func unreadConversationsCount(completion:@escaping(Int?)->()){
        let endPoint = ISMChatConversationEndpoint.unreadConversationCount
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatSendMsg, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data.count)
            case .failure(_) :
                completion(0)
            }
        }
    }
    
    
    //MARK: - Update Profile Picture
    public func getPredefinedUrlToUpdateProfilePicture(image: UIImage,completion:@escaping(String?)->()){
        
        let endPoint = ISMChatMediaUploadEndpoint.updateUserImage(mediaExtension: "png")
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatPresignedUrlDetail, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                if let url = data.presignedUrl{
                    AF.upload(image.pngData()!, to: url, method: .put, headers: [:]).responseData { response in
                        ISMChatHelper.print(response)
                        if response.response?.statusCode == 200{
                            completion(data.mediaUrl)
                        }else{
                            ISMChatHelper.print("Error in Image Update")
                        }
                    }
                }
            case .failure(let error) :
                ISMChatHelper.print("Error in Image Update Api failed -----> \(String(describing: error))")
            }
        }
    }
}

extension ConversationViewModel {
    
    public func getSectionedDictionary(data : [ISMChatUser]) -> Dictionary <String , [ISMChatUser]> {
        let sectionDictionary: Dictionary<String, [ISMChatUser]> = {
            return Dictionary(grouping: data, by: {
                let name = $0.userName
                let normalizedName = name?.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
                let firstChar = String((normalizedName?.first!)!).uppercased()
                return firstChar
            })
        }()
        return sectionDictionary
    }
    
    public func getContactDictionary(data: [ISMChatContacts]) -> [String: [ISMChatContacts]] {
        let sectionDictionary: [String: [ISMChatContacts]] = Dictionary(grouping: data, by: { contact in
            let name = contact.contact.givenName
            let normalizedName = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            if let firstChar = normalizedName.first, !name.isEmpty {
                return String(firstChar).uppercased()
            }
            return "Un"
        })
        return sectionDictionary
    }
    
    public func getSortedFilteredChats(conversation : [ISMChatConversationsDetail],query : String) -> [ISMChatConversationsDetail]{
        let sortedChats = conversation.sorted {
            guard let date1 = $0.lastMessageDetails?.updatedAt else {return false}
            guard let date2 = $1.lastMessageDetails?.updatedAt else {return false}
            return date1 > date2
        }
        if query == ""{
            return sortedChats
        }
        return sortedChats.filter({($0.opponentDetails?.userName?.lowercased().prefix(query.count))! == query.lowercased()})
    }

    
    public func getConversationCount() -> Int {
         conversations.count
    }
    
    public func getConversation() -> [ISMChatConversationsDetail] {
         conversations
    }
    
    public func clearMessages() {
        self.messages = nil
        self.allMessages = nil
    }
    
    public func updateConversationObj(conversations: [ISMChatConversationsDetail]) {
        self.conversations.append(contentsOf: conversations)
    }
    
    public func updateProfileImage(img:String) {
        self.userData?.userProfileImageUrl = img
    }
    
    public func resetdata() {
        self.moreDataAvailableForChatList = true
        self.chatLimit = 10
        self.conversations.removeAll()
    }
    
    public func resetGetUsersdata() {
        self.moreDataAvailableForGetUsers = true
        self.getUsersLimit = 20
        self.users.removeAll()
    }
    
    public func resetEligibleUsersdata(){
        self.moreDataAvailableForGetUsers = true
        self.getUsersLimit = 20
        self.eligibleUsers.removeAll()
    }
    
    public func resetCreateGroupUsersdata(){
        self.moreDataAvailableForCreateGroupUsers = true
        self.getUsersLimit = 20
        self.createGroupUsers.removeAll()
        self.createGroupUsersSectionDictionary.removeAll()
    }

}


// MARK: - Block Users
extension ConversationViewModel {
    
    public func getBlockUserCount() -> Int {
        self.blockUser.count
    }
    
    public func getBlockUser() -> [ISMChatUser] {
        self.blockUser
    }
    
    public func removeBlockUser(obj:ISMChatUser) {
        self.blockUser = self.blockUser.filter({$0.id != obj.id})
    }
    
}
