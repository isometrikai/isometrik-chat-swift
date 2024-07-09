//
//  ChatsViewModel_Reactions.swift
//  ISMChatSdk
//
//  Created by Rasika on 12/06/24.
//

import Foundation

extension ChatsViewModel{
    
    //MARK: - send reaction
    public func sendReaction(conversationId : String,messageId : String,emojiReaction : String,completion:@escaping(Bool?)->()){
        var body : [String : Any]
        body = ["conversationId" : conversationId ,
                "messageId" : messageId,
                "reactionType" : emojiReaction] as [String : Any]
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: ISMChat_NetworkServices.Urls.emojiReaction,httpMethod: .post,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                ISMChat_Helper.print("Send reaction Api succedded -----> \(String(describing: data?.msg))")
                completion(true)
            case .failure(let error):
                ISMChat_Helper.print("Send reaction Api failed -----> \(String(describing: error))")
                completion(true)
            }
        }
    }
    
    //MARK: - get reactions
    public func getReaction(conversationId : String,messageId : String,emojiReaction : String,completion:@escaping(ISMChat_ReactionsData?)->()){
        var body : [String : Any]
        body = ["conversationId" : conversationId ,
                "messageId" : messageId] as [String : Any]
        let url = ISMChat_NetworkServices.Urls.emojiReaction + "/\(emojiReaction)"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: url,httpMethod: .get,params: body) { (result : ISMChat_Response<ISMChat_ReactionsData?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                ISMChat_Helper.print("Get reaction Api succedded -----> \(String(describing: data?.msg))")
                completion(data)
            case .failure(let error):
                ISMChat_Helper.print("Get reaction Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - remove reaction
    public func removeReaction(conversationId : String,messageId : String,emojiReaction : String,completion:@escaping(Bool?)->()){
        var body : [String : Any]
        body = ["conversationId" : conversationId ,
                "messageId" : messageId] as [String : Any]
        let url = ISMChat_NetworkServices.Urls.emojiReaction + "/\(emojiReaction)"
        ismChatSDK?.getChatClient().getApiManager().requestService(serviceUrl: url,httpMethod: .delete,params: body) { (result : ISMChat_Response<ISMChat_CreateConversationResponse?,ISMChat_ErrorData?>) in
            switch result{
            case .success(let data):
                ISMChat_Helper.print("Send reaction Api succedded -----> \(String(describing: data?.msg))")
                completion(true)
            case .failure(let error):
                ISMChat_Helper.print("Send reaction Api failed -----> \(String(describing: error))")
                completion(true)
            }
        }
    }
}
