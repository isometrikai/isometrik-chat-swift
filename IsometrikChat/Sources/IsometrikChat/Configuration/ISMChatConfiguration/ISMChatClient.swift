//
//  ISMChatClient.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 16/10/23.
//

import Foundation


public class ISMChat_Client {
    private var communicationConfig : ISMChat_CommunicationConfiguration
    private var apiManager : ISMChat_APIManager

    
    public init(communicationConfig: ISMChat_CommunicationConfiguration,apiManager : ISMChat_APIManager) {
        self.communicationConfig = communicationConfig
        self.apiManager = apiManager
    }
    
    public func getConfigurations() -> ISMChat_CommunicationConfiguration{
        return communicationConfig
    }
    
     public func getApiManager () -> ISMChat_APIManager{
        return apiManager
    }
}





