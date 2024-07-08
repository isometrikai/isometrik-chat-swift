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

class ConversationViewModel : NSObject ,ObservableObject{
    
    //MARK:  - PROPERTIES
    @Published var searchedText = ""
    @Published var debounceSearchedText = ""

    
    @Published var conversations : [ISMChat_ConversationsDetail] = []
    @Published var userData : ISMChat_User?
    @Published var messages : [[ISMChat_Message]]?
    @Published var allMessages  :  ISMChat_Messages?
    @Published var usersSectionDictionary : Dictionary<String , [ISMChat_User]> = [:]
    @Published var contactSectionDictionary : Dictionary<String , [ISMChat_Contacts]> = [:]
    @Published var users : [ISMChat_User] = []
    @Published var contacts : [ISMChat_Contacts] = []
    @Published var eligibleUsers : [ISMChat_User] = []
    @Published var elogibleUsersSectionDictionary : Dictionary<String , [ISMChat_User]> = [:]
    @Published var blockUser = [ISMChat_User]()
    @Published var chatLimit = 10
    @Published var moreDataAvailableForChatList = true
    @Published var getUsersLimit = 20
    @Published var moreDataAvailableForGetUsers = true
    @Published var apiCalling = false
    
    var ismChatSDK: ISMChatSdk?
    
     init(ismChatSDK: ISMChatSdk){
        super.init()
        self.ismChatSDK = ismChatSDK
        self.setSearchedTextDebounce()
    }
    
    func setSearchedTextDebounce(){
        debounceSearchedText = self.searchedText
        $searchedText
            .debounce(for: .seconds(0.75), scheduler: RunLoop.main)
            .assign(to: &$debounceSearchedText)
    }
    
    
    //MARK: - APIS
    func deliveredMessageIndicator(conversationId : String,messageId : String,completion:@escaping(Bool?)->()){
        var body : [String : Any]
        body = ["conversationId" : conversationId ,
                "messageId" : messageId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.deliveredMessageIndicator,httpMethod: .put,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                ISMChat_Helper.print("Delivered Message Indicator Api succedded -----> \(String(describing: data?.msg))")
                completion(true)
            case .failure(let error):
                ISMChat_Helper.print("Delivered Message Indicator Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    func getUserData(completion:@escaping(ISMChat_User?)->()){
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.userDetail,httpMethod: .get) { (result : ISMChat_Response<ISMChat_User?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                self.userData = data
                UserDefaults.standard.storeCodable(data, key: "userInfo")
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("Get User Data Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    func getChatList(search : String?,completion:@escaping(ISMChat_Conversations?)->()){
        var body : [String : Any]? = nil
        if let search = search , search != ""{
            body = ["searchTag" : search] as [String : Any]
        }
        let skip = self.conversations.count
        
        let newUrl = "\(ISMChat_NetworkServices.Urls.chatList)?includeConversationStatusMessagesInUnreadMessagesCount=false&skip=\(skip)"
        
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: newUrl,httpMethod: .get,params: body) { (result : ISMChat_Response<ISMChat_Conversations?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                self.moreDataAvailableForChatList = false
                ISMChat_Helper.print("Get Chat Api failed -----> \(String(describing: error))")
                
            }
        }
    }
    
    func deleteConversation(conversationId: String, completion:@escaping()->()){
        let baseURL = "\(ISMChat_NetworkServices.Urls.deleteConversationLocal)?conversationId=\(conversationId)"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .delete) { (result : ISMChat_Response<ISMChat_User?,ISMChat_ErrorData?>) in
            switch result{
            case .success(_):
                completion()
            case .failure(let error):
                ISMChat_Helper.print("Get delete Conversation Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    func exitGroup(conversationId: String, completion:@escaping()->()){
        let baseURL = "\(ISMChat_NetworkServices.Urls.exitGroup)?conversationId=\(conversationId)"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .delete) { (result : ISMChat_Response<ISMChat_User?,ISMChat_ErrorData?>) in
            switch result{
            case .success(_):
                completion()
            case .failure(let error):
                ISMChat_Helper.print("Get delete Conversation Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    func muteUnmuteNotification(conversationId: String,pushNotifications : Bool, completion:@escaping(Bool?)->()){
        var body = [String : Any]()
        body["pushNotifications"] = pushNotifications
        body["conversationId"] = conversationId
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.conversationSetting,httpMethod: .patch,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(_):
                completion(true)
            case .failure(let error):
                ISMChat_Helper.print("update title Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    func clearChat(conversationId: String, completion:@escaping()->()){
        let baseURL = "\(ISMChat_NetworkServices.Urls.clearChat)?conversationId=\(conversationId)"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .delete) { (result : ISMChat_Response<ISMChat_User?,ISMChat_ErrorData?>) in
            switch result{
            case .success(_):
                completion()
            case .failure(let error):
                ISMChat_Helper.print("Get clear chat Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    func getSortedFilteredChats(conversation : [ISMChat_ConversationsDetail],query : String) -> [ISMChat_ConversationsDetail]{
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
    
    func getPredefinedUrlToUpdateProfilePicture(image: UIImage,completion:@escaping(String?)->()){
        let baseURL = "\(ISMChat_NetworkServices.Urls.preassignedUrlUpdate)?mediaExtension=png"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChat_Response<ISMChat_PresignedUrlDetail?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                if let url = data?.presignedUrl{
                    AF.upload(image.pngData()!, to: url, method: .put, headers: [:]).responseData { response in
                        ISMChat_Helper.print(response)
                        if response.response?.statusCode == 200{
                            completion(data?.mediaUrl)
                        }else{
                            ISMChat_Helper.print("Error in Image Update")
                        }
                    }
                }
            case .failure(let error):
                ISMChat_Helper.print("Error in Image Update Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    func updateUserData(userName : String? = nil,userIdentifier : String? = nil,profileImage : String? = nil,notification : Bool? = nil,about : String? = nil,showLastSeen : Bool? = nil,completion:@escaping(Bool?)->()){
        var body = [String : Any]()
        var metaDataValue : [String : Any] = [:]
        
        if let userName = userName{
            body["userName"] = userName
        }
        if let userIdentifier = userIdentifier{
            body["userIdentifier"] = userIdentifier
        }
        if let profileImage = profileImage{
            body["userProfileImageUrl"] = profileImage
        }
        if let notification = notification{
            body["notification"] = notification
        }
        if let about = about{
            metaDataValue["about"] = about
        }
        if let showLastSeen = showLastSeen{
            metaDataValue["showlastSeen"] = showLastSeen
        }
        if metaDataValue.count > 0{
            body["metaData"] = metaDataValue
        }
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.register,httpMethod: .patch,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(_):
                completion(true)
            case .failure(let error):
                ISMChat_Helper.print("update title Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    func getUsers(search : String,completion:@escaping(ISMChat_Users?)->()){
        var baseURL = "\(ISMChat_NetworkServices.Urls.getnonBlockUsers)?skip=0&limit=20&sort=1"
        let skip = self.users.count
        if search != "" {
            baseURL = "\(ISMChat_NetworkServices.Urls.getnonBlockUsers)?searchTag=\(search)&sort=1&skip=\(skip)&limit=\(getUsersLimit)"
        }else {
            baseURL = "\(ISMChat_NetworkServices.Urls.getnonBlockUsers)?sort=1&skip=\(skip)&limit=\(getUsersLimit)"
           
        }
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChat_Response<ISMChat_Users?,ISMChat_ErrorData?>) in
            self.apiCalling = false
            switch result{
            case .success(let data):
                if skip == 0 {
                    self.users.removeAll()
                }
                completion(data)
            case .failure(_):
                ISMChat_Helper.print("get users Failed")
                self.moreDataAvailableForGetUsers = false
            }
        }
    }
    
    func getBroadCastEligibleUsers(groupCastId : String ,search : String,completion:@escaping(ISMChat_Users?)->()){
        var baseURL = "\(ISMChat_NetworkServices.Urls.getnonBlockUsers)?skip=0&limit=20&sort=1"
        let skip = self.users.count
        if search != "" {
            baseURL = "\(ISMChat_NetworkServices.Urls.eligibleuserForGroupcast)?groupcastId=\(groupCastId)&searchTag=\(search)&sort=1&skip=\(skip)&limit=\(getUsersLimit)"
        }else {
            baseURL = "\(ISMChat_NetworkServices.Urls.eligibleuserForGroupcast)?groupcastId=\(groupCastId)&sort=1&skip=\(skip)&limit=\(getUsersLimit)"
           
        }
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChat_Response<ISMChat_Users?,ISMChat_ErrorData?>) in
            self.apiCalling = false
            switch result{
            case .success(let data):
                if skip == 0 {
                    self.users.removeAll()
                }
                completion(data)
            case .failure(_):
                ISMChat_Helper.print("get users Failed")
                self.moreDataAvailableForGetUsers = false
            }
        }
    }
    
    func getEligibleUsers(search : String,conversationId: String,completion:@escaping(ISMChat_Users?)->()){
        var baseURL = "\(ISMChat_NetworkServices.Urls.eligibleUsers)?conversationId=\(conversationId)&sort=1&skip=0&limit=20"
        let skip = self.eligibleUsers.count
        if search != "" {
            baseURL = "\(ISMChat_NetworkServices.Urls.eligibleUsers)?conversationId=\(conversationId)&sort=1&skip=\(skip)&limit=\(getUsersLimit)&searchTag=\(search)"
        }else {
            baseURL = "\(ISMChat_NetworkServices.Urls.eligibleUsers)?conversationId=\(conversationId)&sort=1&skip=\(skip)&limit=\(getUsersLimit)"
           
        }
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChat_Response<ISMChat_Users?,ISMChat_ErrorData?>) in
            self.apiCalling = false
            switch result{
            case .success(let data):
                if skip == 0 {
                    self.eligibleUsers.removeAll()
                }
                completion(data)
            case .failure(_):
                ISMChat_Helper.print("get users Failed")
                self.moreDataAvailableForGetUsers = false
            }
        }
    }
    
    func refreshGetUser(completion:@escaping(ISMChat_Users?)->()){
        let baseURL = "\(ISMChat_NetworkServices.Urls.getnonBlockUsers)?skip=0&limit=20&sort=1"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChat_Response<ISMChat_Users?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("Get refreshGetUser Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    func getBlockUsers(completion:@escaping(ISMChat_Users?)->()){
        let baseURL = ISMChat_NetworkServices.Urls.getBlockUser
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChat_Response<ISMChat_Users?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                self.blockUser = data?.users ?? []
                completion(data)
            case .failure(_):
                ISMChat_Helper.print("get users Failed")
            }
        }
    }
    
    func blockUnBlockUser(opponentId : String,needToBlock:Bool,completion:@escaping(ISMChat_Users?)->()){
        var baseURL = ""
        if needToBlock {
            baseURL = "\(ISMChat_NetworkServices.Urls.blockUsers)"
        }else {
            baseURL = "\(ISMChat_NetworkServices.Urls.unBlockUsers)"
        }
        let body = ["opponentId": opponentId]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .post, params: body) { (result : ISMChat_Response<ISMChat_Users?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(_):
                ISMChat_Helper.print("get users Failed")
            }
        }
    }
    
}

extension ConversationViewModel {
    
    func getSectionedDictionary(data : [ISMChat_User]) -> Dictionary <String , [ISMChat_User]> {
        let sectionDictionary: Dictionary<String, [ISMChat_User]> = {
            return Dictionary(grouping: data, by: {
                let name = $0.userName
                let normalizedName = name?.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
                let firstChar = String((normalizedName?.first!)!).uppercased()
                return firstChar
            })
        }()
        return sectionDictionary
    }
    
    func getContactDictionary(data: [ISMChat_Contacts]) -> [String: [ISMChat_Contacts]] {
        let sectionDictionary: [String: [ISMChat_Contacts]] = Dictionary(grouping: data, by: { contact in
            if !contact.contact.givenName.isEmpty {
                let name = contact.contact.givenName
                let normalizedName = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
                if let firstChar = normalizedName.first {
                    return String(firstChar).uppercased()
                }
            }
            return "Un"
        })
        return sectionDictionary
    }

    
    func getConversationCount() -> Int {
         conversations.count
    }
    
    func getConversation() -> [ISMChat_ConversationsDetail] {
         conversations
    }
    
    func clearMessages() {
        self.messages = nil
        self.allMessages = nil
    }
    
    func updateConversationObj(conversations: [ISMChat_ConversationsDetail]) {
        self.conversations.append(contentsOf: conversations)
    }
    
    func updateProfileImage(img:String) {
        self.userData?.userProfileImageUrl = img
    }
    
    func resetdata() {
        self.moreDataAvailableForChatList = true
        self.chatLimit = 10
        self.conversations.removeAll()
    }
    
    func resetGetUsersdata() {
        self.moreDataAvailableForGetUsers = true
        self.getUsersLimit = 20
        self.users.removeAll()
    }
    
    func resetEligibleUsersdata(){
        self.moreDataAvailableForGetUsers = true
        self.getUsersLimit = 20
        self.eligibleUsers.removeAll()
    }

}


// MARK: - Block Users
extension ConversationViewModel {
    
    func getBlockUserCount() -> Int {
        self.blockUser.count
    }
    
    func getBlockUser() -> [ISMChat_User] {
        self.blockUser
    }
    
    func removeBlockUser(obj:ISMChat_User) {
        self.blockUser = self.blockUser.filter({$0.id != obj.id})
    }
    
}
