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
    @Published public var blockUser = [ISMChatUser]()
    @Published public var chatLimit = 10
    @Published public var moreDataAvailableForChatList = true
    @Published public var getUsersLimit = 20
    @Published public var moreDataAvailableForGetUsers = true
    @Published public var apiCalling = false
    
    var ismChatSDK: ISMChatSdk?
    
    public init(ismChatSDK: ISMChatSdk){
        super.init()
        self.ismChatSDK = ismChatSDK
        self.setSearchedTextDebounce()
    }
    
    public func setSearchedTextDebounce(){
        debounceSearchedText = self.searchedText
        $searchedText
            .debounce(for: .seconds(0.75), scheduler: RunLoop.main)
            .assign(to: &$debounceSearchedText)
    }
    
    
    //MARK: - APIS
    public func deliveredMessageIndicator(conversationId : String,messageId : String,completion:@escaping(Bool?)->()){
        var body : [String : Any]
        body = ["conversationId" : conversationId ,
                "messageId" : messageId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.deliveredMessageIndicator,httpMethod: .put,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                ISMChatHelper.print("Delivered Message Indicator Api succedded -----> \(String(describing: data?.msg))")
                completion(true)
            case .failure(let error):
                ISMChatHelper.print("Delivered Message Indicator Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    public func getUserData(completion:@escaping(ISMChatUser?)->()){
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.userDetail,httpMethod: .get) { (result : ISMChatResponse<ISMChatUser?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                self.userData = data
//                UserDefaults.standard.storeCodable(data, key: "userInfo")
                completion(data)
            case .failure(let error):
                ISMChatHelper.print("Get User Data Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    public func getChatListWithCustomType(customType : String,search : String?,skip :Int,completion:@escaping(ISMChatConversations?)->()){
        var body = [String : Any]()
        if let search = search , search != ""{
            body["searchTag"] = search
        }
        body["customType"] = customType
        
        
        let newUrl = "\(ISMChatNetworkServices.Urls.chatList)?includeConversationStatusMessagesInUnreadMessagesCount=false&skip=\(skip)"
        
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: newUrl,httpMethod: .get,params: body) { (result : ISMChatResponse<ISMChatConversations?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                self.moreDataAvailableForChatList = false
                ISMChatHelper.print("Get Chat Api failed -----> \(String(describing: error))")
                
            }
        }
    }
    
    public func getChatList(search : String?,completion:@escaping(ISMChatConversations?)->()){
        var body : [String : Any]? = nil
        if let search = search , search != ""{
            body = ["searchTag" : search] as [String : Any]
        }
        let skip = self.conversations.count
        
        let newUrl = "\(ISMChatNetworkServices.Urls.chatList)?includeConversationStatusMessagesInUnreadMessagesCount=false&skip=\(skip)"
        
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: newUrl,httpMethod: .get,params: body) { (result : ISMChatResponse<ISMChatConversations?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                self.moreDataAvailableForChatList = false
                ISMChatHelper.print("Get Chat Api failed -----> \(String(describing: error))")
                
            }
        }
    }
    
    public func deleteConversation(conversationId: String, completion:@escaping()->()){
        let baseURL = "\(ISMChatNetworkServices.Urls.deleteConversationLocal)?conversationId=\(conversationId)"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .delete) { (result : ISMChatResponse<ISMChatUser?,ISMChatErrorData?>) in
            switch result{
            case .success(_):
                completion()
            case .failure(let error):
                ISMChatHelper.print("Get delete Conversation Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    public func exitGroup(conversationId: String, completion:@escaping()->()){
        let baseURL = "\(ISMChatNetworkServices.Urls.exitGroup)?conversationId=\(conversationId)"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .delete) { (result : ISMChatResponse<ISMChatUser?,ISMChatErrorData?>) in
            switch result{
            case .success(_):
                completion()
            case .failure(let error):
                ISMChatHelper.print("Get delete Conversation Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    public func muteUnmuteNotification(conversationId: String,pushNotifications : Bool, completion:@escaping(Bool?)->()){
        var body = [String : Any]()
        body["pushNotifications"] = pushNotifications
        body["conversationId"] = conversationId
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.conversationSetting,httpMethod: .patch,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
            switch result{
            case .success(_):
                completion(true)
            case .failure(let error):
                ISMChatHelper.print("update title Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    public func clearChat(conversationId: String, completion:@escaping()->()){
        let baseURL = "\(ISMChatNetworkServices.Urls.clearChat)?conversationId=\(conversationId)"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .delete) { (result : ISMChatResponse<ISMChatUser?,ISMChatErrorData?>) in
            switch result{
            case .success(_):
                completion()
            case .failure(let error):
                ISMChatHelper.print("Get clear chat Api failed -----> \(String(describing: error))")
            }
        }
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
    
    public func getPredefinedUrlToUpdateProfilePicture(image: UIImage,completion:@escaping(String?)->()){
        let baseURL = "\(ISMChatNetworkServices.Urls.preassignedUrlUpdate)?mediaExtension=png"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChatResponse<ISMChatPresignedUrlDetail?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                if let url = data?.presignedUrl{
                    AF.upload(image.pngData()!, to: url, method: .put, headers: [:]).responseData { response in
                        ISMChatHelper.print(response)
                        if response.response?.statusCode == 200{
                            completion(data?.mediaUrl)
                        }else{
                            ISMChatHelper.print("Error in Image Update")
                        }
                    }
                }
            case .failure(let error):
                ISMChatHelper.print("Error in Image Update Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    public func updateUserData(userName : String? = nil,userIdentifier : String? = nil,profileImage : String? = nil,notification : Bool? = nil,about : String? = nil,showLastSeen : Bool? = nil,completion:@escaping(Bool?)->()){
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
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.register,httpMethod: .patch,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
            switch result{
            case .success(_):
                completion(true)
            case .failure(let error):
                ISMChatHelper.print("update title Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    public func getUsers(search : String,completion:@escaping(ISMChatUsers?)->()){
        var baseURL = "\(ISMChatNetworkServices.Urls.getnonBlockUsers)?skip=0&limit=20&sort=1"
        let skip = self.users.count
        if search != "" {
            baseURL = "\(ISMChatNetworkServices.Urls.getnonBlockUsers)?searchTag=\(search)&sort=1&skip=\(skip)&limit=\(getUsersLimit)"
        }else {
            baseURL = "\(ISMChatNetworkServices.Urls.getnonBlockUsers)?sort=1&skip=\(skip)&limit=\(getUsersLimit)"
           
        }
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChatResponse<ISMChatUsers?,ISMChatErrorData?>) in
            self.apiCalling = false
            switch result{
            case .success(let data):
                if skip == 0 {
                    self.users.removeAll()
                }
                completion(data)
            case .failure(_):
                ISMChatHelper.print("get users Failed")
                self.moreDataAvailableForGetUsers = false
            }
        }
    }
    
    public func getUserDetail(userId: String,userName : String,completion:@escaping(ISMChatUser?)->()){
        var baseURL = "\(ISMChatNetworkServices.Urls.getUsers)?searchTag=\(userName)&sort=1"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChatResponse<ISMChatUsers?,ISMChatErrorData?>) in
//            self.apiCalling = false
            switch result{
            case .success(let data):
                guard let users = data?.users else {
                    completion(nil)
                    return
                }
                
                for user in users {
                    if user.userId == userId {
                        completion(user)
                        return
                    }
                }
            case .failure(_):
                ISMChatHelper.print("get users Failed")
            }
        }
    }
    
    public func getBroadCastEligibleUsers(groupCastId : String ,search : String,completion:@escaping(ISMChatUsers?)->()){
        var baseURL = "\(ISMChatNetworkServices.Urls.getnonBlockUsers)?skip=0&limit=20&sort=1"
        let skip = self.users.count
        if search != "" {
            baseURL = "\(ISMChatNetworkServices.Urls.eligibleuserForGroupcast)?groupcastId=\(groupCastId)&searchTag=\(search)&sort=1&skip=\(skip)&limit=\(getUsersLimit)"
        }else {
            baseURL = "\(ISMChatNetworkServices.Urls.eligibleuserForGroupcast)?groupcastId=\(groupCastId)&sort=1&skip=\(skip)&limit=\(getUsersLimit)"
           
        }
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChatResponse<ISMChatUsers?,ISMChatErrorData?>) in
            self.apiCalling = false
            switch result{
            case .success(let data):
                if skip == 0 {
                    self.users.removeAll()
                }
                completion(data)
            case .failure(_):
                ISMChatHelper.print("get users Failed")
                self.moreDataAvailableForGetUsers = false
            }
        }
    }
    
    public func getEligibleUsers(search : String,conversationId: String,completion:@escaping(ISMChatUsers?)->()){
        var baseURL = "\(ISMChatNetworkServices.Urls.eligibleUsers)?conversationId=\(conversationId)&sort=1&skip=0&limit=20"
        let skip = self.eligibleUsers.count
        if search != "" {
            baseURL = "\(ISMChatNetworkServices.Urls.eligibleUsers)?conversationId=\(conversationId)&sort=1&skip=\(skip)&limit=\(getUsersLimit)&searchTag=\(search)"
        }else {
            baseURL = "\(ISMChatNetworkServices.Urls.eligibleUsers)?conversationId=\(conversationId)&sort=1&skip=\(skip)&limit=\(getUsersLimit)"
           
        }
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChatResponse<ISMChatUsers?,ISMChatErrorData?>) in
            self.apiCalling = false
            switch result{
            case .success(let data):
                if skip == 0 {
                    self.eligibleUsers.removeAll()
                }
                completion(data)
            case .failure(_):
                ISMChatHelper.print("get users Failed")
                self.moreDataAvailableForGetUsers = false
            }
        }
    }
    
    public func refreshGetUser(completion:@escaping(ISMChatUsers?)->()){
        let baseURL = "\(ISMChatNetworkServices.Urls.getnonBlockUsers)?skip=0&limit=20&sort=1"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChatResponse<ISMChatUsers?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChatHelper.print("Get refreshGetUser Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    public func getBlockUsers(completion:@escaping(ISMChatUsers?)->()){
        let baseURL = ISMChatNetworkServices.Urls.getBlockUser
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChatResponse<ISMChatUsers?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                self.blockUser = data?.users ?? []
                completion(data)
            case .failure(_):
                ISMChatHelper.print("get users Failed")
            }
        }
    }
    
    public func blockUnBlockUser(opponentId : String,needToBlock:Bool,completion:@escaping(ISMChatUsers?)->()){
        var baseURL = ""
        if needToBlock {
            baseURL = "\(ISMChatNetworkServices.Urls.blockUsers)"
        }else {
            baseURL = "\(ISMChatNetworkServices.Urls.unBlockUsers)"
        }
        let body = ["opponentId": opponentId]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .post, params: body) { (result : ISMChatResponse<ISMChatUsers?,ISMChatErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(_):
                ISMChatHelper.print("get users Failed")
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
