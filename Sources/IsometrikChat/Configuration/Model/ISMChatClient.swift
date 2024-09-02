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

    
    public init(communicationConfig: ISMChatCommunicationConfiguration) {
        self.communicationConfig = communicationConfig
    }
    
    public func getConfigurations() -> ISMChatCommunicationConfiguration{
        return communicationConfig
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

