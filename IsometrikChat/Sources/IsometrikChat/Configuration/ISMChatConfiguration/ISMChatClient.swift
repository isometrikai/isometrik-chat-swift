//
//  ISMChatClient.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 16/10/23.
//

import Foundation


public class ISMChat_Client {
    private var communicationConfig : ISMChat_CommunicationConfiguration
    private var chatPageProperties : ISMChat_PageProperties
    private var apiManager : ISMChat_APIManager

    
    init(communicationConfig: ISMChat_CommunicationConfiguration,apiManager : ISMChat_APIManager,chatPageProperties : ISMChat_PageProperties) {
        self.communicationConfig = communicationConfig
        self.apiManager = apiManager
        self.chatPageProperties = chatPageProperties
    }
    
    public func getConfigurations() -> ISMChat_CommunicationConfiguration{
        return communicationConfig
    }
    
    public func getChatPageProperties() -> ISMChat_PageProperties{
        return chatPageProperties
    }
    
     public func getApiManager () -> ISMChat_APIManager{
        return apiManager
    }
}





