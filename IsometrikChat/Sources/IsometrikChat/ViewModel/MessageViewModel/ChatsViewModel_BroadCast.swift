//
//  ChatsViewModel_BroadCast.swift
//  ISMChatSdk
//
//  Created by Rasika on 12/06/24.
//

import Foundation

extension ChatsViewModel{
    
    //MARK: - create broadcast api
    func createBroadCast(users : [ISMChat_User],completion:@escaping(ISMChat_CreateConversationResponse?)->()){
        var body : [String : Any]
        var membersAll : [[String : Any]] = []
        var membersDetail : [[String : Any]] = []
        for x in users{
            let member = ["newConversationTypingEvents" : true, "newConversationReadEvents" : true, "newConversationPushNotificationsEvents" : true,"memberId" : x.userId ?? "","newConversationCustomType" : "Broadcast","newConversationMetadata" : nil] as [String : Any]
            membersAll.append(member)
            let memberDetail = ["memberId" :  x.userId ?? "","memberName" : x.userName ?? ""]
            membersDetail.append(memberDetail)
        }
        body = ["groupcastTitle" : "Default" ,
                "groupcastImageUrl" : "https://res.cloudinary.com/dxkoc9aao/image/upload/v1616075844/kesvhgzyiwchzge7qlsz_yfrh9x.jpg",
                "members" : membersAll,
                "metaData" : ["membersDetail" : membersDetail]] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.createBroadCast,httpMethod: .post,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("Create Conversation Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - get list of broadcasts api
    func getBroadCastList(completion:@escaping(ISMChat_Conversations?)->()){
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.getBroadCast,httpMethod: .get) { (result : ISMChat_Response<ISMChat_Conversations?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("Get CONVERSATION Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - get broadcast members api
    func getBroadMembers(groupcastId : String,completion:@escaping(ISMChat_BroadCastMembers?)->()){
        let baseUrl = "\(ISMChat_NetworkServices.Urls.getBroadCastMembers)?groupcastId=\(groupcastId)"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseUrl,httpMethod: .get) { (result : ISMChat_Response<ISMChat_BroadCastMembers?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("Get broadcast member Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - delete broadcast api
    func deleteBroadCastList(groupcastId: String,completion:@escaping(Bool?)->()){
        var body : [String : Any]
        body = ["groupcastId" : groupcastId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.createBroadCast,httpMethod: .delete,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                ISMChat_Helper.print(data?.msg)
                completion(true)
            case .failure(let error):
                ISMChat_Helper.print("delete broadcast Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - get broadcast messages api
    func getBroadCastMessages(refresh : Bool? = nil,groupcastId : String,lastMessageTimestamp:String,completion:@escaping(ISMChat_Messages?)->()){
        var baseURL = String()
        if lastMessageTimestamp == "" {
             baseURL = "\(ISMChat_NetworkServices.Urls.getbroadCastMessage)?groupcastId=\(groupcastId)"
        }else {
             baseURL = "\(ISMChat_NetworkServices.Urls.getbroadCastMessage)?groupcastId=\(groupcastId)&lastMessageTimestamp=\(lastMessageTimestamp)"
        }
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChat_Response<ISMChat_Messages?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("Get Message Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - update broadcast title api
    func updateBroadCastTitle(groupcastId:String, broadcastTitle : String,completion:@escaping(ISMChat_BroadCastMembers?)->()){
        var body : [String : Any]
        body = ["groupcastTitle" : broadcastTitle,"groupcastId" : groupcastId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.createBroadCast,httpMethod: .patch,params: body) { (result : ISMChat_Response<ISMChat_BroadCastMembers?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("update title Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - add members in broadcast api
    func addMemberInBroadCast(members : [ISMChat_User],groupcastId : String,completion:@escaping(Bool?)->()){
        var body : [String : Any]
        var membersAll : [[String : Any]] = []
        for x in members{
            let member = ["newConversationTypingEvents" : true, "newConversationReadEvents" : true, "newConversationPushNotificationsEvents" : true,"memberId" : x.userId ?? "","newConversationCustomType" : "Broadcast","newConversationMetadata" : nil] as [String : Any]
            membersAll.append(member)
        }
        body = ["members" : membersAll,"groupcastId" : groupcastId] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.addmembersToBroadCast,httpMethod: .put,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(true)
            case .failure(let error):
                ISMChat_Helper.print("Add member Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - remove members from broadcast api
    func removeMemberInBroadCast(members : [String],groupcastId : String,completion:@escaping(Bool?)->()){
        let totalMessageId = members.joined(separator: ",")
        let baseUrl = "\(ISMChat_NetworkServices.Urls.addmembersToBroadCast)?groupcastId=\(groupcastId)&members=\(totalMessageId)"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseUrl,httpMethod: .delete) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(_):
                completion(true)
            case .failure(let error):
                ISMChat_Helper.print("Add member Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - get broadcast message info if read
    func getGroupCastMessageReadInfo(messageId : String,groupcastId : String,completion:@escaping(ISMChat_ConversationDetail?)->()){
        let baseURL = "\(ISMChat_NetworkServices.Urls.groupcastMessageRead)?groupcastId=\(groupcastId)&groupcastMessageId=\(messageId)"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChat_Response<ISMChat_ConversationDetail?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(_):
                ISMChat_Helper.print("Message Read Info Failed")
            }
        }
    }
    
    //MARK: - get broadcast message info if delivered
    func getGroupCastMessageDeliveredInfo(messageId : String,groupcastId : String,completion:@escaping(ISMChat_ConversationDetail?)->()){
        let baseURL = "\(ISMChat_NetworkServices.Urls.groupcastMessageDelivered)?groupcastId=\(groupcastId)&groupcastMessageId=\(messageId)"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .get) { (result : ISMChat_Response<ISMChat_ConversationDetail?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                completion(data)
            case .failure(_):
                ISMChat_Helper.print("Message deleivered Info Failed")
            }
        }
    }
    
    //MARK: - delete broadcast message
    func deleteBroadCastMsg(messageDeleteType : ISMChat_DeleteMessageType,messageId : String,groupcastId : String,completion:@escaping()->()){
        var baseURL = ""
        switch messageDeleteType{
        case .DeleteForYou:
            baseURL = "\(ISMChat_NetworkServices.Urls.broadcastmessageDeleteForMe)?groupcastId=\(groupcastId)&messageId=\(messageId)&notifyOnCompletion=false&deleteForAll=true&sendPushForMessageDeleted=false"
        case .DeleteForEveryone:
            baseURL = "\(ISMChat_NetworkServices.Urls.broadcastmessageDeleteForEveryone)?groupcastId=\(groupcastId)&messageId=\(messageId)&notifyOnCompletion=false&deleteForAll=true&sendPushForMessageDeleted=false"
        }
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: baseURL,httpMethod: .delete) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(_):
                completion()
            case .failure(_):
                ISMChat_Helper.print("Message deleivered Info Failed")
            }
        }
    }
}
