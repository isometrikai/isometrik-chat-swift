//
//  ISMChatClient.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 16/10/23.
//

import Foundation


public class ISMChatClient {
    private var communicationConfig : ISMChatCommunicationConfiguration
    private var apiManager : ISMChatAPIManager

    
    public init(communicationConfig: ISMChatCommunicationConfiguration,apiManager : ISMChatAPIManager) {
        self.communicationConfig = communicationConfig
        self.apiManager = apiManager
    }
    
    public func getConfigurations() -> ISMChatCommunicationConfiguration{
        return communicationConfig
    }
    
     public func getApiManager () -> ISMChatAPIManager{
        return apiManager
    }
}





