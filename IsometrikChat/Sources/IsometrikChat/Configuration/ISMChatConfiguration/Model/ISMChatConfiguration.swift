//
//  ISMChatConfiguration.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 16/11/23.
//

import Foundation
import Alamofire

public struct ISMChat_Configuration {
    
    public var accountId: String
    public var projectId: String
    public var keySetId: String
    public var licensekey: String
    public var origin: String
    public var headers: HTTPHeaders
    public var MQTTHost: String
    public var MQTTPort: Int
    public var appSecret: String
    public var userSecret: String
    public var authToken : String
    
    init(accountId: String = "", projectId: String = "", keySetId: String = "", licensekey: String = "", origin: String = "" , headers: HTTPHeaders = [:], MQTTHost: String = "", MQTTPort: Int = 0, appSecret: String = "", userSecret: String = "",authToken : String = "") {
        self.accountId = accountId
        self.projectId = projectId
        self.keySetId = keySetId
        self.licensekey = licensekey
        self.origin = origin
        self.headers = headers
        self.MQTTHost = MQTTHost
        self.MQTTPort = MQTTPort
        self.appSecret = appSecret
        self.userSecret = userSecret
        self.authToken = authToken
    }
}
