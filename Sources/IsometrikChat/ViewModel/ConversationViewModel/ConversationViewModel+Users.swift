//
//  File.swift
//  
//
//  Created by Rasika Bharati on 02/09/24.
//

import Foundation


extension ConversationViewModel{
    //MARK: - Get User Detail
    
    public func getUserData(completion:@escaping(ISMChatUser?)->()){
        
        let endPoint = ISMChatUsersEndpoint.getUserDetail
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatUser, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("Get User Data Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    
    //MARK: - Update User Data
    
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
        
        let endPoint = ISMChatUsersEndpoint.updateUserDetail
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse?, ISMChatNewAPIError>) in
            switch result{
            case .success(_,_) :
                completion(true)
            case .failure(let error) :
                ISMChatHelper.print("update title Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - Get Users
    
    public func getUsers(search : String,completion:@escaping(ISMChatUsers?)->()){
        let skip = self.users.count

        let endPoint = ISMChatUsersEndpoint.allNonBlockUsers(searchTag: search, sort: 1, skip: skip, limit: getUsersLimit)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatUsers?, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                DispatchQueue.main.async {
                    if skip == 0 {
                        self.users.removeAll()
                    }
                    let fetchedCount = data?.users?.count ?? 0
                    self.moreDataAvailableForGetUsers = fetchedCount == self.getUsersLimit
                    completion(data)
                }
            case .failure(_) :
                DispatchQueue.main.async {
                    ISMChatHelper.print("get users Failed")
                    self.moreDataAvailableForGetUsers = false
                    completion(nil)
                }
            }
        }
    }
    
    //MARK: - Get User Detail
    
    public func getUserDetail(userId: String,userName : String,completion:@escaping(ISMChatUser?)->()){
        
        let endPoint = ISMChatUsersEndpoint.allUsers(searchTag: userName, sort: 1)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatUsers?, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
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
            case .failure(_) :
                ISMChatHelper.print("get users Failed")
            }
        }
    }
    
    //MARK: - Get BroadCast Eligible Users
    public func getBroadCastEligibleUsers(groupCastId : String ,search : String,completion:@escaping(ISMChatUsers?)->()){
        
        let skip = self.users.count
        let endPoint = ISMChatBroadCastEndpoint.getEligibleUsersListtoAddInBroadcast(groupcastId: groupCastId, searchTag: search, sort: 1, skip: skip, limit: getUsersLimit)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatUsers, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                if skip == 0 {
                    self.users.removeAll()
                }
                completion(data)
            case .failure(_) :
                ISMChatHelper.print("get users Failed")
                self.moreDataAvailableForGetUsers = false
            }
        }
    }
    
    
    //MARK: - Get Group Eligible Users
    public func getEligibleUsers(search : String,conversationId: String,completion:@escaping(ISMChatUsers?)->()){
        let skip = self.eligibleUsers.count
        let endPoint = ISMChatGroupEndpoint.eligibleUsersToAddInGroup(conversationId: conversationId, sort: 1, skip: skip, limit: getUsersLimit, searchTag: search)
        let request = ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatUsers, ISMChatNewAPIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data, _):
                    if skip == 0 {
                        // Clear only when it's a fresh load
                        self.eligibleUsers.removeAll()
                    }
                    self.eligibleUsers.append(contentsOf: data.conversationEligibleMembers ?? [])
                    self.elogibleUsersSectionDictionary = self.getSectionedDictionary(data: self.eligibleUsers)
                    self.moreDataAvailableForGetUsers = true
                    completion(data)
                    
                case .failure(_):
                    ISMChatHelper.print("get users Failed")
                    self.moreDataAvailableForGetUsers = false
                    completion(nil)
                }
            }
        }
    }
    
    //MARK: - Refresh Non Block Users
    public func refreshGetUser(completion:@escaping(ISMChatUsers?)->()){
        
        let endPoint = ISMChatUsersEndpoint.allNonBlockUsers(searchTag: "", sort: 1, skip: 0, limit: 20)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatUsers?, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("Get refreshGetUser Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - Get All Blocked Users
    public func getBlockUsers(completion:@escaping(ISMChatUsers?)->()){
        
        let endPoint = ISMChatUsersEndpoint.allBlockedUsers
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatUsers, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                self.blockUser = data.users ?? []
                completion(data)
            case .failure(_) :
                ISMChatHelper.print("get users Failed")
                completion(nil)
            }
        }
    }
    
    
    //MARK: - Block And Unblock User
    public func blockUnBlockUser(conversationId:String,initiatorId : String,opponentId : String,needToBlock:Bool,completion:@escaping(ISMChatUsers?)->()){
        let body = ["opponentId": opponentId]
        let endPoint = needToBlock == true ? ISMChatUsersEndpoint.blockUser : ISMChatUsersEndpoint.unBlockUser
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        let blockedMessage = needToBlock == true ? ISMLastBlockedUser(userId: initiatorId, initiatorId: initiatorId) : ISMLastBlockedUser(userId: "", initiatorId: "")
        if needToBlock == true{
            self.updatelastblockedUserInConversationMetaData(conversationId: conversationId, blockedMessage: blockedMessage){_ in 
                ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatUsers, ISMChatNewAPIError>) in
                    switch result{
                    case .success(let data,_) :
                        completion(data)
                    case .failure(_) :
                        ISMChatHelper.print("get users Failed")
                    }
                }
            }
        }else{
            ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatUsers, ISMChatNewAPIError>) in
                switch result{
                case .success(let data,_) :
                    completion(data)
                case .failure(_) :
                    ISMChatHelper.print("get users Failed")
                }
            }
        }
    }
    
    public func updatelastblockedUserInConversationMetaData(conversationId : String,blockedMessage : ISMLastBlockedUser,completion:@escaping(ISMChatCreateConversationResponse?)->()){
        var body : [String : Any]
        let metaData = ["blockedMessage" : ["userId" : blockedMessage.userId  ,"initiatorId" : blockedMessage.initiatorId ]]
        body = ["metaData" : metaData,"conversationId" : conversationId]  as [String : Any]
        
        let endPoint = ISMChatConversationEndpoint.updateConversationDetail
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
                ISMChatHelper.print("Meta data updated for blocked user in conversatiion")
            case .failure(let error) :
                ISMChatHelper.print("Meta data changed to allow message -----> \(String(describing: error))")
            }
        }
    }
}
