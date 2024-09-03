//
//  ChatsViewModelReactions.swift
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
        
        let endPoint = ISMChatReactionEndpoint.sendReaction
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                ISMChatHelper.print("Send reaction Api succedded -----> \(String(describing: data.msg))")
                completion(true)
            case .failure(let error) :
                ISMChatHelper.print("Send reaction Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - get reactions
    public func getReaction(conversationId : String,messageId : String,emojiReaction : String,completion:@escaping(ISMChatReactionsData?)->()){
        var body : [String : Any]
        body = ["conversationId" : conversationId ,
                "messageId" : messageId] as [String : Any]
        
        let endPoint = ISMChatReactionEndpoint.getReaction(reaction: emojiReaction)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatReactionsData, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                ISMChatHelper.print("Get reaction Api succedded -----> \(String(describing: data.msg))")
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("Get reaction Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - remove reaction
    public func removeReaction(conversationId : String,messageId : String,emojiReaction : String,completion:@escaping(Bool?)->()){
        var body : [String : Any]
        body = ["conversationId" : conversationId ,
                "messageId" : messageId] as [String : Any]
        let endPoint = ISMChatReactionEndpoint.removeReaction(reaction: emojiReaction)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                ISMChatHelper.print("remove reaction Api succedded -----> \(String(describing: data.msg))")
                completion(true)
            case .failure(let error) :
                ISMChatHelper.print("remove reaction Api failed -----> \(String(describing: error))")
            }
        }
    }
}
