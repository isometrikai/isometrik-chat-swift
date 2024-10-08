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
    //mqtt session
    private var mqttSession: ISMChatMQTTManager?
    //instance
    public static var sharedInstance : ISMChatSdk!
    
    private var hostFrameworksType : FrameworkType = .UIKit
    
    private var uploadOnExternalCDN : Bool?
    
    private var chatInitialized : Bool?
    
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
    public func getFramework() -> FrameworkType{
        return hostFrameworksType
    }
    
    public func checkuploadOnExternalCDN() -> Bool{
        return uploadOnExternalCDN ?? false
    }
    
    public func checkifChatInitialied() -> Bool{
        if chatInitialized == nil || chatInitialized == false{
            return false
        }else{
            return true
        }
    }
    
    
    
    public func appConfiguration(appConfig : ISMChatConfiguration, userConfig : ISMChatUserConfig,hostFrameworkType : FrameworkType,conversationListViewControllerName : UIViewController.Type?,messagesListViewControllerName : UIViewController.Type?,uploadOnExternalCDN : Bool? = false) {
        
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
        
        let projectConfiguration = ISMChatProjectConfig(accountId: appConfig.accountId, appSecret: appConfig.appSecret, userSecret: appConfig.userSecret, keySetId: appConfig.keySetId, licenseKey: appConfig.licensekey, projectId: appConfig.projectId, origin: appConfig.origin, headers: headers)
        
        let mqttConfiguration = ISMChatMqttConfig(hostName: appConfig.MQTTHost, port: appConfig.MQTTPort)
        
        let communicationConfiguration = ISMChatCommunicationConfiguration(userConfig: userConfiguration, projectConfig: projectConfiguration, mqttConfig: mqttConfiguration)
        
        self.hostFrameworksType = hostFrameworkType
        
        self.uploadOnExternalCDN = uploadOnExternalCDN
        
        //chatClient
        self.chatClient = ISMChatClient(communicationConfig: communicationConfiguration)
        //mqttSession
        let viewcontrollers = ISMChatViewController(conversationListViewController: conversationListViewControllerName, messagesListViewController: messagesListViewControllerName)
        
        let mqttSession = ISMChatMQTTManager(mqttConfiguration: mqttConfiguration, projectConfiguration: projectConfiguration, userdata: userConfig,viewcontrollers: viewcontrollers,framework: self.hostFrameworksType)
        mqttSession.connect(clientId: userConfig.userId)
        self.mqttSession = mqttSession
        
        //initializeCall
        initializeCallIsometrik(accountId: appConfig.accountId, projectId: appConfig.projectId, keysetId: appConfig.keySetId, licenseKey: appConfig.licensekey, appSecret: appConfig.appSecret, userSecret: appConfig.userSecret, isometricChatUserId: userConfig.userId, isometricUserToken: userConfig.userToken)
        self.chatInitialized = true
        print("CHAT INITIALIZED")
         
        let viewmodel = ChatsViewModel()
        viewmodel.getAllMessagesWhichWereSendToMeWhenOfflineMarkThemAsDelivered(myUserId: userConfiguration.userId)
    }
    
    public func onTerminate(userId : String) {
        //1. unsubscribe fcm
        if checkifChatInitialied() == true{
            ISMChatHelper.unSubscribeFCM(userId: userId)
            //2. unsubscribe mqtt
            if mqttSession != nil {
                self.mqttSession?.unSubscribe()
            }
            //3. delete local data
            RealmManager().deleteRealm(for: self.getChatClient().getConfigurations().userConfig.userId)
            //4. For call
            IsometrikCall().clearSession()
            ISMCallManager.shared.invalidatePushKitAPNSDeviceToken(type: .voIP)
            self.chatInitialized = nil
        }
    }
    
    public func onProfileSwitch(oldUserId : String,appConfig : ISMChatConfiguration, userConfig : ISMChatUserConfig,hostFrameworkType : FrameworkType,conversationListViewControllerName : UIViewController.Type?,messagesListViewControllerName : UIViewController.Type?){
        //1. unsubscribe fcm
        ISMChatHelper.unSubscribeFCM(userId: oldUserId)
        //2. unsubscribe mqtt
        if mqttSession != nil {
            self.mqttSession?.unSubscribe()
        }
        //3. delete local data
        RealmManager().switchProfile(oldUserId: oldUserId, newUserId: userConfig.userId)
        
        self.chatInitialized = nil
        
        self.appConfiguration(appConfig: appConfig, userConfig: userConfig, hostFrameworkType: hostFrameworkType, conversationListViewControllerName: conversationListViewControllerName, messagesListViewControllerName: messagesListViewControllerName)
    }
    
    func initializeCallIsometrik(accountId : String,projectId : String,keysetId : String,licenseKey : String,appSecret : String,userSecret : String,isometricChatUserId : String,isometricUserToken : String){
        let sdkConfig = ISMCallConfiguration.init(accountId: accountId, projectId: projectId, keysetId: keysetId, licenseKey: licenseKey, appSecret: appSecret, userSecret: userSecret)
        let isometrik = IsometrikCall(configuration: sdkConfig)
        isometrik.updateUserId(isometricChatUserId)
        isometrik.updateUserToken(isometricUserToken)
        ISMCallManager.shared.updatePushRegisteryToken()
    }
    
    public func getUserDetail(isometrikUserId : String,userName : String,completion: @escaping (ISMChatUser?) -> Void) {
        let viewModel = ConversationViewModel()
        viewModel.getUserDetail(userId: isometrikUserId, userName: userName) { data in
            completion(data)
        }
    }
}


public enum FrameworkType{
    case SwiftUI
    case UIKit
}
