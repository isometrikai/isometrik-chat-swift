//
//  ChatsViewModelBroadCast.swift
//  ISMChatSdk
//
//  Created by Rasika on 12/06/24.
//

import Foundation

extension ChatsViewModel{
    
    //MARK: - create broadcast api
    public func createBroadCast(broadCastTitle : String? = "Default",broadcastImage : String? = "https://res.cloudinary.com/dxkoc9aao/image/upload/v1616075844/kesvhgzyiwchzge7qlsz_yfrh9x.jpg",users : [ISMChatUser],completion:@escaping(ISMChatCreateConversationResponse?)->()){
        var body : [String : Any]
        var membersAll : [[String : Any]] = []
        var membersDetail : [[String : Any]] = []
        for x in users{
            let member = ["newConversationTypingEvents" : true, "newConversationReadEvents" : true, "newConversationPushNotificationsEvents" : true,"memberId" : x.userId ?? "","newConversationCustomType" : "Broadcast","newConversationMetadata" : nil] as [String : Any]
            membersAll.append(member)
            let memberDetail = ["memberId" :  x.userId ?? "","memberName" : x.userName ?? ""]
            membersDetail.append(memberDetail)
        }
        body = ["groupcastTitle" : broadCastTitle ?? "Default",
                "groupcastImageUrl" : broadcastImage ?? "https://res.cloudinary.com/dxkoc9aao/image/upload/v1616075844/kesvhgzyiwchzge7qlsz_yfrh9x.jpg",
                "members" : membersAll,
                "metaData" : ["membersDetail" : membersDetail]] as [String : Any]
        
        let endPoint = ISMChatBroadCastEndpoint.createBroadCast
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                NotificationCenter.default.post(name: NSNotification.refreshBroadCastListNotification,object: nil)
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("Create Broadcast Api failed -----> \(String(describing: error))")
            }
        }
        
//        
//        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.createBroadCast,httpMethod: .post,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
//            switch result{
//            case .success(let data):
//                NotificationCenter.default.post(name: NSNotification.refreshBroadCastListNotification,object: nil)
//                completion(data)
//            case .failure(let error):
//                ISMChatHelper.print("Create Conversation Api failed -----> \(String(describing: error))")
//            }
//        }
    }
    
    //MARK: - get list of broadcasts api
    public func getBroadCastList(completion:@escaping(ISMChatConversations?)->()){
        
        let endPoint = ISMChatBroadCastEndpoint.getBroadCastList
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatConversations, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("Get Broadcast Api failed -----> \(String(describing: error))")
            }
        }
        
//        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.getBroadCast,httpMethod: .get) { (result : ISMChatResponse<ISMChatConversations?,ISMChatErrorData?>) in
//            switch result{
//            case .success(let data):
//                completion(data)
//            case .failure(let error):
//                ISMChatHelper.print("Get CONVERSATION Api failed -----> \(String(describing: error))")
//            }
//        }
    }
    
    //MARK: - get broadcast members api
    public func getBroadMembers(groupcastId : String,completion:@escaping(ISMChatBroadCastMembers?)->()){
        
        
        let endPoint = ISMChatBroadCastEndpoint.getBroadCastMembers(groupcastId: groupcastId)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatBroadCastMembers, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("Get broadcast member Api failed -----> \(String(describing: error))")
            }
        }
        
        
//        let baseUrl = "\(ISMChatNetworkServices.Urls.getBroadCastMembers)?groupcastId=\(groupcastId)"
//        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseUrl,httpMethod: .get) { (result : ISMChatResponse<ISMChatBroadCastMembers?,ISMChatErrorData?>) in
//            switch result{
//            case .success(let data):
//                completion(data)
//            case .failure(let error):
//                ISMChatHelper.print("Get broadcast member Api failed -----> \(String(describing: error))")
//            }
//        }
    }
    
    //MARK: - delete broadcast api
    public func deleteBroadCastList(groupcastId: String,completion:@escaping(Bool?)->()){
        
        var body : [String : Any]
        body = ["groupcastId" : groupcastId] as [String : Any]
        
        let endPoint = ISMChatBroadCastEndpoint.deleteBroadCast
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                ISMChatHelper.print(data.msg)
                completion(true)
            case .failure(let error) :
                ISMChatHelper.print("delete broadcast Api fail -----> \(String(describing: error))")
            }
        }
        
        
        
//        var body : [String : Any]
//        body = ["groupcastId" : groupcastId] as [String : Any]
//        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.createBroadCast,httpMethod: .delete,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
//            switch result{
//            case .success(let data):
//                ISMChatHelper.print(data?.msg)
//                completion(true)
//            case .failure(let error):
//                ISMChatHelper.print("delete broadcast Api fail -----> \(String(describing: error))")
//            }
//        }
    }
    
    //MARK: - get broadcast messages api
    public func getBroadCastMessages(refresh : Bool? = nil,groupcastId : String,lastMessageTimestamp:String,completion:@escaping(ISMChatMessages?)->()){
        
        
        let endPoint = ISMChatBroadCastEndpoint.getBroadCastMessages(groupcastId: groupcastId, lastMessageTimestamp: lastMessageTimestamp)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatMessages, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("delete broadcast Api fail -----> \(String(describing: error))")
            }
        }
        
        
        
//        var baseURL = String()
//        if lastMessageTimestamp == "" {
//             baseURL = "\(ISMChatNetworkServices.Urls.getbroadCastMessage)?groupcastId=\(groupcastId)"
//        }else {
//             baseURL = "\(ISMChatNetworkServices.Urls.getbroadCastMessage)?groupcastId=\(groupcastId)&lastMessageTimestamp=\(lastMessageTimestamp)"
//        }
//        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChatResponse<ISMChatMessages?,ISMChatErrorData?>) in
//            switch result{
//            case .success(let data):
//                completion(data)
//            case .failure(let error):
//                ISMChatHelper.print("Get Message Api failed -----> \(String(describing: error))")
//            }
//        }
    }
    
    //MARK: - update broadcast title api
    public func updateBroadCastTitle(groupcastId:String, broadcastTitle : String,completion:@escaping(ISMChatBroadCastMembers?)->()){
        var body : [String : Any]
        body = ["groupcastTitle" : broadcastTitle,"groupcastId" : groupcastId] as [String : Any]
        
        
        
        let endPoint = ISMChatBroadCastEndpoint.updateBroadCast
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatBroadCastMembers, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("update title Api fail -----> \(String(describing: error))")
            }
        }
        
        
//        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.createBroadCast,httpMethod: .patch,params: body) { (result : ISMChatResponse<ISMChatBroadCastMembers?,ISMChatErrorData?>) in
//            switch result{
//            case .success(let data):
//                completion(data)
//            case .failure(let error):
//                ISMChatHelper.print("update title Api fail -----> \(String(describing: error))")
//            }
//        }
    }
    
    //MARK: - add members in broadcast api
    public func addMemberInBroadCast(members : [ISMChatUser],groupcastId : String,completion:@escaping(Bool?)->()){
        var body : [String : Any]
        var membersAll : [[String : Any]] = []
        for x in members{
            let member = ["newConversationTypingEvents" : true, "newConversationReadEvents" : true, "newConversationPushNotificationsEvents" : true,"memberId" : x.userId ?? "","newConversationCustomType" : "Broadcast","newConversationMetadata" : nil] as [String : Any]
            membersAll.append(member)
        }
        body = ["members" : membersAll,"groupcastId" : groupcastId] as [String : Any]
        
        
        let endPoint = ISMChatBroadCastEndpoint.addMembersToBroadCast
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(true)
            case .failure(let error) :
                ISMChatHelper.print("Add member Api fail -----> \(String(describing: error))")
            }
        }
        
        
//        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChatNetworkServices.Urls.addmembersToBroadCast,httpMethod: .put,params: body) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
//            switch result{
//            case .success(let data):
//                completion(true)
//            case .failure(let error):
//                ISMChatHelper.print("Add member Api fail -----> \(String(describing: error))")
//            }
//        }
    }
    
    //MARK: - remove members from broadcast api
    public func removeMemberInBroadCast(members : [String],groupcastId : String,completion:@escaping(Bool?)->()){
        let totalMessageId = members.joined(separator: ",")
        
        let endPoint = ISMChatBroadCastEndpoint.removeMembersInBroadcast(groupcastId: groupcastId, membersId: totalMessageId)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(true)
            case .failure(let error) :
                ISMChatHelper.print("Add member Api fail -----> \(String(describing: error))")
            }
        }
        
        
//        let baseUrl = "\(ISMChatNetworkServices.Urls.addmembersToBroadCast)?groupcastId=\(groupcastId)&members=\(totalMessageId)"
//        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseUrl,httpMethod: .delete) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
//            switch result{
//            case .success(_):
//                completion(true)
//            case .failure(let error):
//                ISMChatHelper.print("Add member Api fail -----> \(String(describing: error))")
//            }
//        }
    }
    
    //MARK: - get broadcast message info if read
    public func getGroupCastMessageReadInfo(messageId : String,groupcastId : String,completion:@escaping(ISMChatConversationDetail?)->()){
        
        let endPoint = ISMChatBroadCastEndpoint.getBroadcastMessageReadInfo(groupcastId: groupcastId, groupcastMessageId: messageId)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatConversationDetail, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("Message Read Info Failed")
            }
        }
        
        
//        let baseURL = "\(ISMChatNetworkServices.Urls.groupcastMessageRead)?groupcastId=\(groupcastId)&groupcastMessageId=\(messageId)"
//        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChatResponse<ISMChatConversationDetail?,ISMChatErrorData?>) in
//            switch result{
//            case .success(let data):
//                completion(data)
//            case .failure(_):
//                ISMChatHelper.print("Message Read Info Failed")
//            }
//        }
    }
    
    //MARK: - get broadcast message info if delivered
    public func getGroupCastMessageDeliveredInfo(messageId : String,groupcastId : String,completion:@escaping(ISMChatConversationDetail?)->()){
        
        let endPoint = ISMChatBroadCastEndpoint.getBroadcastMessageDeliveredInfo(groupcastId: groupcastId, groupcastMessageId: messageId)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatConversationDetail, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("Message deleivered Info Failed")
            }
        }
        
//        let baseURL = "\(ISMChatNetworkServices.Urls.groupcastMessageDelivered)?groupcastId=\(groupcastId)&groupcastMessageId=\(messageId)"
//        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChatResponse<ISMChatConversationDetail?,ISMChatErrorData?>) in
//            switch result{
//            case .success(let data):
//                completion(data)
//            case .failure(_):
//                ISMChatHelper.print("Message deleivered Info Failed")
//            }
//        }
    }
    
    //MARK: - delete broadcast message
    public func deleteBroadCastMsg(messageDeleteType : ISMChatDeleteMessageType,messageId : String,groupcastId : String,completion:@escaping()->()){
        
        let endPoint : ISMChatURLConvertible = messageDeleteType == .DeleteForYou ?
        ISMChatBroadCastEndpoint.deleteBroadCastMessageForMe(groupcastId: groupcastId, messageId: messageId, notifyOnCompletion: false, deleteForAll: true, sendPushForMessageDeleted: false) :
        ISMChatBroadCastEndpoint.deleteBroadCastMessageForEveryone(groupcastId: groupcastId, messageId: messageId, notifyOnCompletion: false, deleteForAll: true, sendPushForMessageDeleted: false)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion()
            case .failure(let error) :
                ISMChatHelper.print("Message deleivered Info Failed")
            }
        }
        
//        var baseURL = ""
//        switch messageDeleteType{
//        case .DeleteForYou:
//            baseURL = "\(ISMChatNetworkServices.Urls.broadcastmessageDeleteForMe)?groupcastId=\(groupcastId)&messageId=\(messageId)&notifyOnCompletion=false&deleteForAll=true&sendPushForMessageDeleted=false"
//        case .DeleteForEveryone:
//            baseURL = "\(ISMChatNetworkServices.Urls.broadcastmessageDeleteForEveryone)?groupcastId=\(groupcastId)&messageId=\(messageId)&notifyOnCompletion=false&deleteForAll=true&sendPushForMessageDeleted=false"
//        }
//        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .delete) { (result : ISMChatResponse<ISMChatCreateConversationResponse?,ISMChatErrorData?>) in
//            switch result{
//            case .success(_):
//                completion()
//            case .failure(_):
//                ISMChatHelper.print("Message deleivered Info Failed")
//            }
//        }
    }
}
