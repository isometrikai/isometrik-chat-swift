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
import ISMSwiftCall


public class ISMChatSdk{
    
    //MARK: - PROPERTIES
    //chat client
    private var chatClient: ISMChatClient?
    //user session
    private var userSession: ISMChatUserSession?
    //mqtt session
    private var mqttSession: ISMChatMQTTManager?
    //instance
    private static var sharedInstance : ISMChatSdk!
    
    public static func getInstance()-> ISMChatSdk{
        if sharedInstance == nil {
            sharedInstance = ISMChatSdk()
        }
        return sharedInstance
    }
    
    public func getMqttSession() -> ISMChatMQTTManager {
        if mqttSession == nil {
            fatalError("Create configuration before trying to access mqtt session object.")
        }
        return mqttSession!
    }
    
    public func getChatClient() -> ISMChatClient {
        if chatClient == nil {
            print("Create configuration before trying to access isometrik session object.")
        }
        return chatClient!
    }
    
    public func getUserSession() -> ISMChatUserSession{
        if userSession == nil{
            print("Create configuration before trying to access user session object.")
        }
        return userSession!
    }
    
    public func checkifChatInitialied() -> Bool{
        if mqttSession == nil {
            return false
        }else{
            return true
        }
    }
    
    
    
    public func appConfiguration(appConfig : ISMChatConfiguration, userConfig : ISMChatUserConfig) {
        
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
        
        let projectConfiguration = ISMChatProjectConfig(accountId: appConfig.accountId, appSecret: appConfig.appSecret, userSecret: appConfig.userSecret, keySetId: appConfig.keySetId, licenseKey: appConfig.licensekey, projectId: appConfig.projectId, headers: headers)
        
        let mqttConfiguration = ISMChatMqttConfig(hostName: appConfig.MQTTHost, port: appConfig.MQTTPort)
        
        let communicationConfiguration = ISMChatCommunicationConfiguration(userConfig: userConfiguration, projectConfig: projectConfiguration, mqttConfig: mqttConfiguration)
        
        let apiManager = ISMChatAPIManager(configuration: projectConfiguration)
        
        
        //chatClient
        self.chatClient = ISMChatClient(communicationConfig: communicationConfiguration, apiManager: apiManager)
        
        //userSession
        let userSession = ISMChatUserSession()
        userSession.setUserId(userId: userConfig.userId)
        userSession.setUserToken(token: userConfig.userToken)
        userSession.setUserEmailId(email: userConfig.userEmail)
        userSession.setUserProfilePicture(url: userConfig.userProfileImage)
        userSession.setUserName(userName: userConfig.userName)
        self.userSession = userSession
        
        //mqttSession
        let mqttSession = ISMChatMQTTManager(mqttConfiguration: mqttConfiguration, projectConfiguration: projectConfiguration, userdata: userConfig)
        mqttSession.connect(clientId: userSession.getUserId())
        self.mqttSession = mqttSession
    
    }
    
    public func onTerminate() {
        //1. unsubscribe fcm
        ISMChatHelper.unSubscribeFCM()
        //2. unsubscribe mqtt
        if mqttSession != nil {
            self.mqttSession?.unSubscribe()
        }
        //3. clear user session
        if userSession != nil{
            self.userSession?.clearUserSession()
        }
        //4. delete local data
        RealmManager().deleteAllData()
        //5. For call
        IsometrikCall().clearSession()
        ISMCallManager.shared.invalidatePushKitAPNSDeviceToken(type: .voIP)
    }
}
