//
//  ISMChatClient.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 16/10/23.
//

import Foundation
import UIKit


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



public class ISMChatViewController {
    public var conversationListViewController : UIViewController.Type?
    public var messagesListViewController : UIViewController.Type?
    
    public init(conversationListViewController: UIViewController.Type?,messagesListViewController : UIViewController.Type?) {
        self.conversationListViewController = conversationListViewController
        self.messagesListViewController = messagesListViewController
    }
    
    public func getconversationListViewController() -> UIViewController.Type?{
        return conversationListViewController
    }
    
     public func getmessagesListViewController () -> UIViewController.Type?{
        return messagesListViewController
    }
}

