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

open class ISMChat_MQTTManager: NSObject{
    
    //MARK:  - PROPERTIES
    var mqtt: CocoaMQTT?
    var clientId : String = ""
//    static let shared = ISMChat_MQTTManager()
    let deviceId = UniqueIdentifierManager.shared.getUniqueIdentifier()
    var mqttConfiguration : ISMChat_MqttConfig?
    var projectConfiguration : ISMChat_ProjectConfig?
    var hasConnected : Bool = false
    var userData : ISMChat_UserConfig?
//    weak var delegate: ISMChat_MQTTManagerDelegate?
    init(mqttConfiguration : ISMChat_MqttConfig,projectConfiguration : ISMChat_ProjectConfig,userdata : ISMChat_UserConfig) {
        self.mqttConfiguration = mqttConfiguration
        self.projectConfiguration = projectConfiguration
        self.userData = userdata
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
        mqtt?.logLevel = .debug
        mqtt?.connect()
        mqtt?.delegate = self
        mqtt?.didConnectAck = { mqtt, ack in
            if ack == .accept{
                let client = clientId
                let messageTopic =
                "/\(self.projectConfiguration?.accountId ?? "")/\(self.projectConfiguration?.projectId ?? "")/Message/\(client)"
                let statusTopic =
                "/\(self.projectConfiguration?.accountId ?? "")/\(self.projectConfiguration?.projectId ?? "")/Status/\(client)"
                mqtt.subscribe([(messageTopic,.qos0),(statusTopic,qos: .qos0)])
                self.hasConnected = true
            }
        }
    }
    
    func unSubscribe(){
        let client = self.clientId 
        let messageTopic =
        "/\(self.projectConfiguration?.accountId ?? "")/\(self.projectConfiguration?.projectId ?? "")/Message/\(client)"
        let statusTopic =
        "/\(self.projectConfiguration?.accountId ?? "")/\(self.projectConfiguration?.projectId ?? "")/Status/\(client)"
        mqtt?.unsubscribe(messageTopic)
        mqtt?.unsubscribe(statusTopic)
    }
    
    open func addObserverForMQTT(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?) {
        NotificationCenter.default.addObserver(observer, selector: aSelector, name: aName, object: anObject)
    }
    
    open func removeObserverForMQTT(_ observer: Any, name aName: NSNotification.Name?, object anObject: Any?) {
        NotificationCenter.default.removeObserver(observer, name: aName, object: anObject)
    }
}

extension ISMChat_MQTTManager: CallEventHandlerDelegate{
    public func didReceiveMeetingCreated(meeting: ISMSwiftCall.ISMMeeting?) {
        
    }
    
    public func didReceiveMeetingEnded(meeting: ISMSwiftCall.ISMMeeting?) {
        if let meeting = meeting{
            NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMeetingEnded.name, object: nil,userInfo: ["data": meeting,"error" : ""])
        }
    }
    
    public func didReceiveJoinRequestReject(meeting: ISMSwiftCall.ISMMeeting?) {
        
    }
    
    public func didReceiveJoinRequestAccept(meeting: ISMSwiftCall.ISMMeeting?) {
        
    }
    
    public func didReceiveMessagePublished(meeting: ISMSwiftCall.ISMMeeting?, messageBody: String) {
        
    }
}

extension ISMChat_MQTTManager: CocoaMQTTDelegate {
    public func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        ISMChat_Helper.print("trust: \(trust)")
        completionHandler(true)
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        ISMChat_Helper.print("ack: \(ack)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        ISMChat_Helper.print("new state: \(state)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        ISMChat_Helper.print("message: \(message.string?.description ?? ""), id: \(id)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        ISMChat_Helper.print("id: \(id)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        TRACE("message topic: \(message.topic)")
        TRACE("message: \(message.string?.description ?? ""), id: \(id)")
        
        let messageString = "\(message.string?.description ?? "")"
        let data = Data(messageString.utf8)
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return
        }
            if let actionName = json["action"] as? String {
                if let userID = json["userId"] as? String, userID != userData?.userId{
                    ISMChat_Helper.print("Event triggered with ACTION NAME Opposite USer :: \(actionName)")
                    ISMChat_Helper.print("Response From MQTT Opposite USer :: \(json)")
                    switch ISMChat_MQTTData.dataType(actionName) {
                    case .mqttTypingEvent:
                        self.typingEventResponse(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttTypingEvent.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttTypingEvent.name, object: nil,userInfo: ["data": "data","error" : error])
                            }
                        }
                    case .mqttConversationCreated:
                        self.conversationCreatedResponse(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttConversationCreated.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttConversationCreated.name, object: nil,userInfo: ["data": "data","error" : error])
                            }
                        }
                    case .mqttMessageDelivered:
                        self.messageDelivered(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageDelivered.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageDelivered.name, object: nil,userInfo: ["data": "","error" : error])
                            }
                        }
                    case .mqttMessageRead:
                        self.messageRead(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageRead.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageRead.name, object: nil,userInfo: ["data": "data","error" : error])
                            }
                        }
                    case .mqttMessageDeleteForAll:
                        self.messageDeleteForAll(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageDeleteForAll.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageDeleteForAll.name, object: nil,userInfo: ["data": "data","error" : error])
                            }
                        }
                    case .mqttMultipleMessageRead:
                        self.multipleMessageRead(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMultipleMessageRead.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMultipleMessageRead.name, object: nil,userInfo: ["data": "data","error" : error])
                            }
                        }
                    case .mqttUserBlock:
                        break
                    case .mqttUserBlockConversation:
                        break
                    case .mqttUserUnblock:
                        break
                    case .mqttUserUnblockConversation:
                        break
                    case .mqttClearConversation:
                        break
                    case .mqttDeleteConversationLocally:
                        break
                    case .mqttAddMember:
                        self.messageReceived(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
                            }
                        }
                    case .mqttRemoveMember:
                        self.messageReceived(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
                            }
                        }
                    case .mqttMemberLeave:
                        self.messageReceived(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
                            }
                        }
                    case .mqttConversationTitleUpdated:
                        self.messageReceived(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
                            }
                        }
                    case .mqttConversationImageUpdated:
                        self.messageReceived(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
                            }
                        }
                    case .mqttmessageDetailsUpdated :
                        print("updated Message")
                        self.messageUpdated(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttmessageDetailsUpdated.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttmessageDetailsUpdated.name, object: nil,userInfo: ["data": "","error" : error])
                            }
                        }
                    case .mqttAddReaction:
                        //other user
                        print("Reaction added")
                        self.reactions(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttAddReaction.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttAddReaction.name, object: nil,userInfo: ["data": "","error" : error])
                            }
                        }
                    case .mqttRemoveReaction:
                        //other user
                        print("Reaction removed")
                        self.reactions(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttRemoveReaction.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttRemoveReaction.name, object: nil,userInfo: ["data": "","error" : error])
                            }
                        }
                    default:
                        CallEventHandler.handleCallEvents(payload: message.payload)
                        CallEventHandler.delegate = self
                    }
                }else if let userID = json["opponentId"] as? String, userID == userData?.userId{
                    ISMChat_Helper.print("Event triggered with ACTION NAME Same user:: \(actionName)")
                    ISMChat_Helper.print("Response From MQTT Same USer :: \(json)")
                    switch ISMChat_MQTTData.dataType(actionName) {
                    case .mqttUserBlockConversation:
                        self.blockedUserAndUnBlocked(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttUserBlockConversation.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttUserBlockConversation.name, object: nil,userInfo: ["data": "data","error" : error])
                            }
                        }
                    case .mqttUserUnblockConversation:
                        self.blockedUserAndUnBlocked(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttUserUnblockConversation.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttUserUnblockConversation.name, object: nil,userInfo: ["data": "data","error" : error])
                            }
                        }
                    case .mqttMultipleMessageRead:
                        self.multipleMessageRead(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMultipleMessageRead.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMultipleMessageRead.name, object: nil,userInfo: ["data": "data","error" : error])
                            }
                        }
                    default:
                        CallEventHandler.handleCallEvents(payload: message.payload)
                        CallEventHandler.delegate = self
                    }
                }else{
                    ISMChat_Helper.print("Event triggered with ACTION NAME Same user:: \(actionName)")
                    switch ISMChat_MQTTData.dataType(actionName) {
                    case .mqttAddAdmin:
                        self.messageReceived(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
                            }
                        }
                    case .mqttRemoveAdmin:
                        self.messageReceived(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
                            }
                        }
                    case .mqttUpdateUser:
                        self.messageReceived(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttUpdateUser.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttUpdateUser.name, object: nil,userInfo: ["data": "","error" : error])
                            }
                        }
                    case .mqttforward:
                        self.messageReceived(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
                            }
                        }
                    case .mqttAddReaction:
                        //becoz i have manage it while api call only for myself
                        break
                    case .mqttRemoveReaction:
                        //becoz i have manage it while api call only for myself
                        break
                    case .mqttUserBlock:
                        self.blockedUserAndUnBlockedUser(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttUserBlock.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttUserBlock.name, object: nil,userInfo: ["data": "data","error" : error])
                            }
                        }
                    case .mqttUserUnblock:
                        self.blockedUserAndUnBlockedUser(data) { result in
                            switch result{
                            case .success(let data):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttUserUnblock.name, object: nil,userInfo: ["data": data,"error" : ""])
                            case .failure(let error):
                                NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttUserUnblock.name, object: nil,userInfo: ["data": "data","error" : error])
                            }
                        }
                    default:
                        CallEventHandler.handleCallEvents(payload: message.payload)
                        CallEventHandler.delegate = self
                    }
                }
            }else{
                self.messageReceived(data) { result in
                    switch result{
                    case .success(let data):
                        NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
                    case .failure(let error):
                        NotificationCenter.default.post(name: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
                    }
                }
            }
        
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        ISMChat_Helper.print("subscribed: \(success), failed: \(failed)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        ISMChat_Helper.print("topic: \(topics)")
    }
    
    public func mqttDidPing(_ mqtt: CocoaMQTT) {
        ISMChat_Helper.print()
    }
    
    public func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        ISMChat_Helper.print()
    }
    
    public func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        ISMChat_Helper.print("\(err?.localizedDescription ?? "")")
        hasConnected = false
    }
    
    public func TRACE(_ message: String = "", fun: String = #function) {
        let names = fun.components(separatedBy: ":")
        var prettyName: String
        
        if names.count == 2 {
            prettyName = names[0]
        } else {
            prettyName = names[1]
        }
        
        if fun == "mqttDidDisconnect(_:withError:)" {
            prettyName = "didDisconnect"
        }
        
        ISMChat_Helper.print("[TRACE] [\(prettyName)]: \(message)")
    }
}


protocol ISMChat_MQTTManagerDelegate: AnyObject {
    func didReceiveTypingEvent(data: ISMChat_TypingEvent)
    func didReceiveConversationCreated(data: ISMChat_CreateConversation)
    func didReceiveMessageDelivered(data: ISMChat_MessageDelivered)
    func didReceiveMessageRead(data: ISMChat_MessageDelivered)
    func didReceiveMessageDeleteForAll(data: ISMChat_MessageDelivered)
    func didReceiveMultipleMessageRead(data: ISMChat_MultipleMessageRead)
    func didReceiveMessage(data: ISMChat_MessageDelivered)
    func didReceiveAddReaction(data: Data)
    func didReceiveRemoveReaction(data: Data)
    func didReceiveBlockAndUnBlockUser(data: ISMChat_UserBlockAndUnblock)
    func didReceiveBlockAndUnBlockConversation(data: ISMChat_MessageDelivered)
    func didReceiveMessageDetailUpdated(data: ISMChat_MessageDelivered)
}
