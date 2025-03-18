//
//  MQTT.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 25/04/23.
//

import Foundation
import CocoaMQTT
import UIKit
import ISMSwiftCall

open class ISMChatMQTTManager: NSObject{
    
    //MARK:  - PROPERTIES
    var mqtt: CocoaMQTT?
    var clientId : String = ""
    let deviceId = UniqueIdentifierManager.shared.getUniqueIdentifier()
    var mqttConfiguration : ISMChatMqttConfig?
    var projectConfiguration : ISMChatProjectConfig?
    var viewcontrollers : ISMChatViewController?
    var framework : FrameworkType
    public var hasConnected : Bool = false
    var userData : ISMChatUserConfig?
    var reconnectTimer: Timer?
    let maxReconnectAttempts = 5
    var reconnectAttempts = 0
    let reconnectInterval: TimeInterval = 5.0
    let localStorageManager: LocalStorageManager
    init(mqttConfiguration : ISMChatMqttConfig,projectConfiguration : ISMChatProjectConfig,userdata : ISMChatUserConfig,viewcontrollers : ISMChatViewController,framework : FrameworkType) {
        self.mqttConfiguration = mqttConfiguration
        self.projectConfiguration = projectConfiguration
        self.userData = userdata
        self.viewcontrollers = viewcontrollers
        self.framework = framework
        self.localStorageManager = try! LocalStorageManager()
        super.init()
    }
    
    //MARK: - CONFIGURE
    func connect(clientId : String){
        self.clientId = clientId
        mqtt = CocoaMQTT(clientID: clientId + "CHAT" + (deviceId), host: (mqttConfiguration?.hostName ?? ""), port: UInt16(mqttConfiguration?.port ?? 0))
        mqtt?.username = "2" + (projectConfiguration?.accountId ?? "") + (projectConfiguration?.projectId ?? "")
        mqtt?.password = (projectConfiguration?.licenseKey ?? "") + (projectConfiguration?.keySetId ?? "")
        mqtt?.keepAlive = 60
        mqtt?.autoReconnect = true
        mqtt?.autoReconnectTimeInterval = 5
        mqtt?.allowUntrustCACertificate = false
        mqtt?.cleanSession = true
        mqtt?.logLevel = .debug
        _ = mqtt?.connect()
        mqtt?.delegate = self
    }
    
    func unSubscribe(){
        let client = self.clientId
        let messageTopic =
        "/\(self.projectConfiguration?.accountId ?? "")/\(self.projectConfiguration?.projectId ?? "")/Message/\(client)"
        let statusTopic =
        "/\(self.projectConfiguration?.accountId ?? "")/\(self.projectConfiguration?.projectId ?? "")/Status/\(client)"
        mqtt?.unsubscribe(messageTopic)
        mqtt?.unsubscribe(statusTopic)
        mqtt?.disconnect()
    }
    
    open func addObserverForMQTT(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?) {
        NotificationCenter.default.addObserver(observer, selector: aSelector, name: aName, object: anObject)
    }
    
    open func removeObserverForMQTT(_ observer: Any, name aName: NSNotification.Name?, object anObject: Any?) {
        NotificationCenter.default.removeObserver(observer, name: aName, object: anObject)
    }
    
    func handleConnectionFailure() {
        if reconnectAttempts < maxReconnectAttempts {
            startReconnectTimer()
        } else {
            NotificationCenter.default.post(
                name: NSNotification.Name("MQTTConnectionFailed"),
                object: nil
            )
        }
    }
    
    func startReconnectTimer() {
        stopReconnectTimer()
        reconnectTimer = Timer.scheduledTimer(
            withTimeInterval: reconnectInterval,
            repeats: false
        ) { [weak self] _ in
            guard let self = self else { return }
            self.reconnectAttempts += 1
            self.connect(clientId: self.clientId)
        }
    }
    
    func stopReconnectTimer() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }
    
    public func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        ISMChatHelper.print("\(err?.localizedDescription ?? "")")
        hasConnected = false
        DispatchQueue.main.async { [weak self] in
            if err != nil {
                mqtt.disconnect()
                self?.handleConnectionFailure()
            }
        }
    }
}







