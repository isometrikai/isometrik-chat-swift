//
//  ISMChatCommunicationConfiguration.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 17/11/23.
//

import Foundation
import Alamofire

public struct ISMChat_CommunicationConfiguration {
    let userConfig: ISMChat_UserConfig
    let projectConfig: ISMChat_ProjectConfig
    let mqttConfig: ISMChat_MqttConfig
    let username: String
    let password: String

    init(userConfig: ISMChat_UserConfig,
         projectConfig: ISMChat_ProjectConfig,
         mqttConfig: ISMChat_MqttConfig,
         username: String? = nil,
         password: String? = nil) {
        self.userConfig = userConfig
        self.projectConfig = projectConfig
        self.mqttConfig = mqttConfig
        self.username = username ?? "2\(projectConfig.accountId)\(projectConfig.projectId)"
        self.password = password ?? "\(projectConfig.licenseKey)\(projectConfig.keySetId)"
    }
}


public struct ISMChat_UserConfig {
    let userToken: String
    let userId: String
    let userName: String
    let userEmail: String
    let userProfileImage: String

    init(userToken: String,
         userId: String,
         userName: String,
         userEmail: String,
         userProfileImage: String) {
        self.userToken = userToken
        self.userId = userId
        self.userName = userName
        self.userEmail = userEmail
        self.userProfileImage = userProfileImage
    }
}


public struct ISMChat_ProjectConfig {
    let accountId: String
    let appSecret: String
    let userSecret: String
    let keySetId: String
    let licenseKey: String
    let projectId: String
    let headers : HTTPHeaders

    init(accountId: String,
         appSecret: String,
         userSecret: String,
         keySetId: String,
         licenseKey: String,
         projectId: String,headers : HTTPHeaders) {
        self.accountId = accountId
        self.appSecret = appSecret
        self.userSecret = userSecret
        self.keySetId = keySetId
        self.licenseKey = licenseKey
        self.projectId = projectId
        self.headers = headers
    }
}


struct ISMChat_MqttConfig {
    let hostName: String
    let port: Int

    init(hostName: String, port: Int) {
        self.hostName = hostName
        self.port = port
    }
}
