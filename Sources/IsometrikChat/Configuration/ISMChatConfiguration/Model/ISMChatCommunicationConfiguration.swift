//
//  ISMChatCommunicationConfiguration.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 17/11/23.
//

import Foundation
import Alamofire

public struct ISMChatCommunicationConfiguration {
    public let userConfig: ISMChatUserConfig
    public let projectConfig: ISMChatProjectConfig
    public let mqttConfig: ISMChatMqttConfig
    public let username: String
    public let password: String

    public init(userConfig: ISMChatUserConfig,
         projectConfig: ISMChatProjectConfig,
         mqttConfig: ISMChatMqttConfig,
         username: String? = nil,
         password: String? = nil) {
        self.userConfig = userConfig
        self.projectConfig = projectConfig
        self.mqttConfig = mqttConfig
        self.username = username ?? "2\(projectConfig.accountId)\(projectConfig.projectId)"
        self.password = password ?? "\(projectConfig.licenseKey)\(projectConfig.keySetId)"
    }
}


public struct ISMChatUserConfig {
    public var userToken: String
    public var userId: String
    public var userName: String
    public var userEmail: String
    public var userProfileImage: String
    public var userProfileType : String
    public var userBio : String = ""
    public var allowNotification : Bool = true
    public var showLastSeen : Bool = true
    
    public init(userToken: String,
                userId: String,
                userName: String,
                userEmail: String,
                userProfileImage: String,
                userProfileType : String,
                userBio : String? = "",
                allowNotification : Bool? = true,
                showLastSeen : Bool? = true) {
        self.userToken = userToken
        self.userId = userId
        self.userName = userName
        self.userEmail = userEmail
        self.userProfileImage = userProfileImage
        self.userProfileType = userProfileType
        self.userBio = userBio ?? ""
        self.allowNotification = allowNotification ?? true
        self.showLastSeen = showLastSeen ?? true
    }
}


public struct ISMChatProjectConfig {
    let accountId: String
    let appSecret: String
    let userSecret: String
    let keySetId: String
    let licenseKey: String
    let projectId: String
    let headers : HTTPHeaders
    let origin : String

    public init(accountId: String,
         appSecret: String,
         userSecret: String,
         keySetId: String,
         licenseKey: String,
                projectId: String, origin : String, headers : HTTPHeaders) {
        self.accountId = accountId
        self.appSecret = appSecret
        self.userSecret = userSecret
        self.keySetId = keySetId
        self.licenseKey = licenseKey
        self.projectId = projectId
        self.headers = headers
        self.origin = origin
    }
}


public struct ISMChatMqttConfig {
    let hostName: String
    let port: Int

    public init(hostName: String, port: Int) {
        self.hostName = hostName
        self.port = port
    }
}

