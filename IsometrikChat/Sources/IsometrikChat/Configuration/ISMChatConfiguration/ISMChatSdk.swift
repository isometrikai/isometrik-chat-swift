//
//  ISMChatSdk.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 17/11/23.
//

import Foundation
import Alamofire
import UIKit
import SwiftUI


public class ISMChatSdk{
    
    //MARK: - PROPERTIES
    //chat client
    private var chatClient: ISMChat_Client?
    //user session
    private var userSession: ISMChat_UserSession?
    //mqtt session
    private var mqttSession: ISMChat_MQTTManager?
    //instance
    private static var sharedInstance : ISMChatSdk!
    
    public static func getInstance()-> ISMChatSdk{
        if sharedInstance == nil {
            sharedInstance = ISMChatSdk()
        }
        return sharedInstance
    }
    
    public func getMqttSession() -> ISMChat_MQTTManager {
        if mqttSession == nil {
            fatalError("Create configuration before trying to access mqtt session object.")
        }
        return mqttSession!
    }
    
    public func getChatClient() -> ISMChat_Client {
        if chatClient == nil {
            print("Create configuration before trying to access isometrik session object.")
        }
        return chatClient!
    }
    
    public func getUserSession() -> ISMChat_UserSession{
        if userSession == nil{
            print("Create configuration before trying to access user session object.")
        }
        return userSession!
    }
    
    
    
    public func appConfiguration(appConfig : ISMChat_Configuration, userConfig : ISMChat_UserConfig) {
        
        if appConfig.accountId.isEmpty {
            fatalError("Pass a valid accountId for isometrik sdk initialization.")
        } else if appConfig.projectId.isEmpty {
            fatalError("Pass a valid projectId for isometrik sdk initialization.")
        } else if appConfig.keySetId.isEmpty {
            fatalError("Pass a valid keysetId for isometrik sdk initialization.")
        } else if appConfig.licensekey.isEmpty {
            fatalError("Pass a valid licenseKey for isometrik sdk initialization.")
        } else if appConfig.appSecret.isEmpty{
            fatalError("Pass a valid appSecret for isometrik sdk initialization.")
        } else if appConfig.userSecret.isEmpty{
            fatalError("Pass a valid userSecret for isometrik sdk initialization.")
        } 
        
        let headers: HTTPHeaders = ["userToken": userConfig.userToken,
                                    "userSecret": appConfig.userSecret,
                                    "projectId": appConfig.projectId,
                                    "licenseKey": appConfig.licensekey,
                                    "appSecret": appConfig.appSecret,
                                    "accept" : "application/json",
                                    "Content-Type" : "application/json"]

        let userConfiguration = userConfig
        
        let projectConfiguration = ISMChat_ProjectConfig(accountId: appConfig.accountId, appSecret: appConfig.appSecret, userSecret: appConfig.userSecret, keySetId: appConfig.keySetId, licenseKey: appConfig.licensekey, projectId: appConfig.projectId, headers: headers)
        
        let mqttConfiguration = ISMChat_MqttConfig(hostName: appConfig.MQTTHost, port: appConfig.MQTTPort)
        
        let communicationConfiguration = ISMChat_CommunicationConfiguration(userConfig: userConfiguration, projectConfig: projectConfiguration, mqttConfig: mqttConfiguration)
        
        let apiManager = ISMChat_APIManager(configuration: projectConfiguration)
        
        
        //chatClient
        self.chatClient = ISMChat_Client(communicationConfig: communicationConfiguration, apiManager: apiManager)
        
        //userSession
        let userSession = ISMChat_UserSession()
        userSession.setUserId(userId: userConfig.userId)
        userSession.setUserToken(token: userConfig.userToken)
        userSession.setUserEmailId(email: userConfig.userEmail)
        userSession.setUserProfilePicture(url: userConfig.userProfileImage)
        userSession.setUserName(userName: userConfig.userName)
        self.userSession = userSession
        
        //mqttSession
        let mqttSession = ISMChat_MQTTManager(mqttConfiguration: mqttConfiguration, projectConfiguration: projectConfiguration, userdata: userConfig)
        mqttSession.connect(clientId: userSession.getUserId())
        self.mqttSession = mqttSession
    
    }
    
    public func onTerminate() {
        ISMChat_Helper.unSubscribeFCM()
        if mqttSession != nil {
            self.mqttSession?.unSubscribe()
        }
        if userSession != nil{
            self.userSession?.clearUserSession()
        }
    }
}
