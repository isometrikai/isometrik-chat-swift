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
    
    public func updateUserConfig(userName: String, userEmail: String, userProfileImage: String, userBio: String, allowNotification: Bool, showLastSeen: Bool) {
        var updatedUserConfig = communicationConfig.userConfig
        updatedUserConfig.userName = userName
        updatedUserConfig.userEmail = userEmail
        updatedUserConfig.userProfileImage = userProfileImage
        updatedUserConfig.userBio = userBio
        updatedUserConfig.allowNotification = allowNotification
        updatedUserConfig.showLastSeen = showLastSeen
        
        let updatedCommunicationConfig = ISMChatCommunicationConfiguration(
            userConfig: updatedUserConfig,
            projectConfig: communicationConfig.projectConfig,
            mqttConfig: communicationConfig.mqttConfig,
            username: communicationConfig.username,
            password: communicationConfig.password
        )
        self.communicationConfig = updatedCommunicationConfig
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

