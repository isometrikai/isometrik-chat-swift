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
    var hasConnected : Bool = false
    var userData : ISMChatUserConfig?
    init(mqttConfiguration : ISMChatMqttConfig,projectConfiguration : ISMChatProjectConfig,userdata : ISMChatUserConfig,viewcontrollers : ISMChatViewController,framework : FrameworkType) {
        self.mqttConfiguration = mqttConfiguration
        self.projectConfiguration = projectConfiguration
        self.userData = userdata
        self.viewcontrollers = viewcontrollers
        self.framework = framework
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
        _ = mqtt?.connect()
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

extension ISMChatMQTTManager: CallEventHandlerDelegate{
    public func publishingStarted(meeting: ISMSwiftCall.ISMMeeting?) {
        
    }
    
    public func didMemberLeaveTheMeeting(meeting: ISMSwiftCall.ISMMeeting?) {
        
    }
    
    public func didReceiveMeetingCreated(meeting: ISMSwiftCall.ISMMeeting?) {
        
    }
    
    public func didReceiveMeetingEnded(meeting: ISMSwiftCall.ISMMeeting?) {
        if let meeting = meeting{
            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMeetingEnded.name, object: nil,userInfo: ["data": meeting,"error" : ""])
        }
    }
    
    public func didReceiveJoinRequestReject(meeting: ISMSwiftCall.ISMMeeting?) {
        
    }
    
    public func didReceiveJoinRequestAccept(meeting: ISMSwiftCall.ISMMeeting?) {
        
    }
    
    public func didReceiveMessagePublished(meeting: ISMSwiftCall.ISMMeeting?, messageBody: String) {
        
    }
}

extension ISMChatMQTTManager: CocoaMQTTDelegate {
    public func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        ISMChatHelper.print("trust: \(trust)")
        completionHandler(true)
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        ISMChatHelper.print("ack: \(ack)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        ISMChatHelper.print("new state: \(state)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        ISMChatHelper.print("message: \(message.string?.description ?? ""), id: \(id)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        ISMChatHelper.print("id: \(id)")
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
                ISMChatHelper.print("Event triggered with ACTION NAME Opposite USer :: \(actionName)")
                ISMChatHelper.print("Response From MQTT Opposite USer :: \(json)")
//                switch ISMChatMQTTData.dataType(actionName) {
//                case .mqttTypingEvent:
//                    self.typingEventResponse(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttTypingEvent.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttTypingEvent.name, object: nil,userInfo: ["data": "data","error" : error])
//                        }
//                    }
//                case .mqttConversationCreated:
//                    self.conversationCreatedResponse(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttConversationCreated.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttConversationCreated.name, object: nil,userInfo: ["data": "data","error" : error])
//                        }
//                    }
//                case .mqttMessageDelivered:
//                    self.messageDelivered(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageDelivered.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageDelivered.name, object: nil,userInfo: ["data": "","error" : error])
//                        }
//                    }
//                case .mqttMessageRead:
//                    self.messageRead(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageRead.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageRead.name, object: nil,userInfo: ["data": "data","error" : error])
//                        }
//                    }
//                case .mqttMessageDeleteForAll:
//                    self.messageDeleteForAll(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageDeleteForAll.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageDeleteForAll.name, object: nil,userInfo: ["data": "data","error" : error])
//                        }
//                    }
//                case .mqttMultipleMessageRead:
//                    self.multipleMessageRead(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMultipleMessageRead.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMultipleMessageRead.name, object: nil,userInfo: ["data": "data","error" : error])
//                        }
//                    }
//                case .mqttUserBlock:
//                    break
//                case .mqttUserBlockConversation:
//                    break
//                case .mqttUserUnblock:
//                    break
//                case .mqttUserUnblockConversation:
//                    break
//                case .mqttClearConversation:
//                    break
//                case .mqttDeleteConversationLocally:
//                    break
//                case .mqttAddMember:
//                    self.messageReceived(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
//                        }
//                    }
//                case .mqttRemoveMember:
//                    self.messageReceived(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
//                        }
//                    }
//                case .mqttMemberLeave:
//                    self.messageReceived(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
//                        }
//                    }
//                case .mqttConversationTitleUpdated:
//                    self.messageReceived(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
//                        }
//                    }
//                case .mqttConversationImageUpdated:
//                    self.messageReceived(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
//                        }
//                    }
//                case .mqttmessageDetailsUpdated :
//                    print("updated Message")
//                    self.messageUpdated(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttmessageDetailsUpdated.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttmessageDetailsUpdated.name, object: nil,userInfo: ["data": "","error" : error])
//                        }
//                    }
//                case .mqttAddReaction:
//                    //other user
//                    print("Reaction added")
//                    self.reactions(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttAddReaction.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttAddReaction.name, object: nil,userInfo: ["data": "","error" : error])
//                        }
//                    }
//                case .mqttRemoveReaction:
//                    //other user
//                    print("Reaction removed")
//                    self.reactions(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttRemoveReaction.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttRemoveReaction.name, object: nil,userInfo: ["data": "","error" : error])
//                        }
//                    }
//                default:
//                    CallEventHandler.handleCallEvents(payload: message.payload)
//                    CallEventHandler.delegate = self
//                }
                switchEvents(actionName: actionName, data: data, message: message)
            }else if let userID = json["opponentId"] as? String, userID == userData?.userId{
                ISMChatHelper.print("Event triggered with ACTION NAME Same user:: \(actionName)")
                ISMChatHelper.print("Response From MQTT Same USer :: \(json)")
//                switch ISMChatMQTTData.dataType(actionName) {
//                case .mqttUserBlockConversation:
//                    self.blockedUserAndUnBlocked(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserBlockConversation.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserBlockConversation.name, object: nil,userInfo: ["data": "data","error" : error])
//                        }
//                    }
//                case .mqttUserUnblockConversation:
//                    self.blockedUserAndUnBlocked(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserUnblockConversation.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserUnblockConversation.name, object: nil,userInfo: ["data": "data","error" : error])
//                        }
//                    }
//                case .mqttMultipleMessageRead:
//                    self.multipleMessageRead(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMultipleMessageRead.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMultipleMessageRead.name, object: nil,userInfo: ["data": "data","error" : error])
//                        }
//                    }
//                default:
//                    CallEventHandler.handleCallEvents(payload: message.payload)
//                    CallEventHandler.delegate = self
//                }
                switchEvents(actionName: actionName, data: data, message: message)
            }else{
                ISMChatHelper.print("Event triggered with ACTION NAME Same user:: \(actionName)")
                switchEvents(actionName: actionName, data: data, message: message)
//                switch ISMChatMQTTData.dataType(actionName) {
//                case .mqttAddAdmin:
//                    self.messageReceived(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
//                        }
//                    }
//                case .mqttRemoveAdmin:
//                    self.messageReceived(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
//                        }
//                    }
//                case .mqttUpdateUser:
//                    self.messageReceived(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUpdateUser.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUpdateUser.name, object: nil,userInfo: ["data": "","error" : error])
//                        }
//                    }
//                case .mqttforward:
//                    self.messageReceived(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
//                        }
//                    }
//                case .mqttAddReaction:
//                    //becoz i have manage it while api call only for myself
//                    break
//                case .mqttRemoveReaction:
//                    //becoz i have manage it while api call only for myself
//                    break
//                case .mqttUserBlock:
//                    self.blockedUserAndUnBlockedUser(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserBlock.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserBlock.name, object: nil,userInfo: ["data": "data","error" : error])
//                        }
//                    }
//                case .mqttUserUnblock:
//                    self.blockedUserAndUnBlockedUser(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserUnblock.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserUnblock.name, object: nil,userInfo: ["data": "data","error" : error])
//                        }
//                    }
//                case .mqttUserBlockConversation:
//                    self.blockedUserAndUnBlocked(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserBlockConversation.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserBlockConversation.name, object: nil,userInfo: ["data": "data","error" : error])
//                        }
//                    }
//                case .mqttAddMember:
//                    self.messageReceived(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
//                        }
//                    }
//                case .mqttRemoveMember:
//                    self.messageReceived(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
//                        }
//                    }
//                case .mqttUserUnblockConversation:
//                    self.blockedUserAndUnBlocked(data) { result in
//                        switch result{
//                        case .success(let data):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserUnblockConversation.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserUnblockConversation.name, object: nil,userInfo: ["data": "data","error" : error])
//                        }
//                    }
//                case .mqttChatMessageSent:
//                    self.messageReceived(data) { result in
//                        switch result{
//                        case .success(let data):
//                            if self.framework == .UIKit {
//                                if let topViewController = UIApplication.topViewController() {
//                                    if let Chatvc = self.viewcontrollers?.conversationListViewController,
//                                       let Messagevc = self.viewcontrollers?.messagesListViewController {
//                                        
//                                        let isNotChatVC = !(topViewController.isKind(of: Chatvc))
//                                        let isNotMessageVC = !(topViewController.isKind(of: Messagevc))
//                                        
//                                        if isNotChatVC && isNotMessageVC {
//                                            // Your code here
//                                            if data.senderId != ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig.userId{
//                                                self.whenInOtherScreen(messageInfo: data)
//                                                NotificationCenter.default.post(name: NSNotification.updateChatBadgeCount, object: nil, userInfo: nil)
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
//                        case .failure(let error):
//                            NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
//                        }
//                    }
//                default:
//                    CallEventHandler.handleCallEvents(payload: message.payload)
//                    CallEventHandler.delegate = self
//                }
            }
        }
    }
    
    func switchEvents(actionName : String,data : Data,message : CocoaMQTTMessage){
        switch ISMChatMQTTData.dataType(actionName) {
        case .mqttTypingEvent:
            self.typingEventResponse(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttTypingEvent.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttTypingEvent.name, object: nil,userInfo: ["data": "data","error" : error])
                }
            }
        case .mqttConversationCreated:
            self.conversationCreatedResponse(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttConversationCreated.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttConversationCreated.name, object: nil,userInfo: ["data": "data","error" : error])
                }
            }
        case .mqttMessageDelivered:
            self.messageDelivered(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageDelivered.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageDelivered.name, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttMessageRead:
            self.messageRead(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageRead.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageRead.name, object: nil,userInfo: ["data": "data","error" : error])
                }
            }
        case .mqttMessageDeleteForAll:
            self.messageDeleteForAll(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageDeleteForAll.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageDeleteForAll.name, object: nil,userInfo: ["data": "data","error" : error])
                }
            }
        case .mqttMultipleMessageRead:
            self.multipleMessageRead(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMultipleMessageRead.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMultipleMessageRead.name, object: nil,userInfo: ["data": "data","error" : error])
                }
            }
        case .mqttUserBlock:
            self.blockedUserAndUnBlockedUser(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserBlock.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserBlock.name, object: nil,userInfo: ["data": "data","error" : error])
                }
            }
        case .mqttUserBlockConversation:
            self.blockedUserAndUnBlocked(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserBlockConversation.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserBlockConversation.name, object: nil,userInfo: ["data": "data","error" : error])
                }
            }
        case .mqttUserUnblock:
            self.blockedUserAndUnBlockedUser(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserUnblock.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserUnblock.name, object: nil,userInfo: ["data": "data","error" : error])
                }
            }
        case .mqttUserUnblockConversation:
            self.blockedUserAndUnBlocked(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserUnblockConversation.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUserUnblockConversation.name, object: nil,userInfo: ["data": "data","error" : error])
                }
            }
        case .mqttClearConversation:
            break
        case .mqttDeleteConversationLocally:
            break
        case .mqttAddAdmin:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttRemoveAdmin:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttAddMember:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttRemoveMember:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttMemberLeave:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttConversationTitleUpdated:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttConversationImageUpdated:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.groupActions, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttUpdateUser:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUpdateUser.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttUpdateUser.name, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttforward:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttmessageDetailsUpdated:
            print("updated Message")
            self.messageUpdated(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttmessageDetailsUpdated.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttmessageDetailsUpdated.name, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttAddReaction:
            //other user
            print("Reaction added")
            self.reactions(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttAddReaction.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttAddReaction.name, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttRemoveReaction:
            print("Reaction removed")
            self.reactions(data) { result in
                switch result{
                case .success(let data):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttRemoveReaction.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttRemoveReaction.name, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .mqttChatMessageSent:
            self.messageReceived(data) { result in
                switch result{
                case .success(let data):
                    if self.framework == .UIKit {
                        if let topViewController = UIApplication.topViewController() {
                            if let Chatvc = self.viewcontrollers?.conversationListViewController,
                               let Messagevc = self.viewcontrollers?.messagesListViewController {
                                
                                let isNotChatVC = !(topViewController.isKind(of: Chatvc))
                                let isNotMessageVC = !(topViewController.isKind(of: Messagevc))
                                
                                if isNotChatVC && isNotMessageVC {
                                    // Your code here
                                    if data.senderId != ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig.userId{
                                        self.whenInOtherScreen(messageInfo: data)
                                        NotificationCenter.default.post(name: NSNotification.updateChatBadgeCount, object: nil, userInfo: nil)
                                    }
                                }
                            }
                        }
                    }
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": data,"error" : ""])
                case .failure(let error):
                    NotificationCenter.default.post(name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil,userInfo: ["data": "","error" : error])
                }
            }
        case .none:
            CallEventHandler.handleCallEvents(payload: message.payload)
            CallEventHandler.delegate = self
        }
    }
    
    public func whenInOtherScreen(messageInfo : ISMChatMessageDelivered){
        let viewModel = ChatsViewModel()
        if let converId = messageInfo.conversationId, let messId = messageInfo.messageId{
            ISMChatLocalNotificationManager.setNotification(1, of: .seconds, repeats: false, title: "\(messageInfo.senderName ?? "")", body: "\(messageInfo.notificationBody ?? (messageInfo.body ?? ""))", userInfo: ["senderId": messageInfo.senderId ?? "","senderName" : messageInfo.senderName ?? "","conversationId" : messageInfo.conversationId ?? "","body" : messageInfo.notificationBody ?? "","userIdentifier" : messageInfo.senderIdentifier ?? "","senderProfileImageUrl" : messageInfo.senderProfileImageUrl ?? ""])
            viewModel.deliveredMessageIndicator(conversationId: converId, messageId: messId) { _ in
                ISMChatHelper.print("Message marked delivered")
            }
        }
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        ISMChatHelper.print("subscribed: \(success), failed: \(failed)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        ISMChatHelper.print("topic: \(topics)")
    }
    
    public func mqttDidPing(_ mqtt: CocoaMQTT) {
        ISMChatHelper.print()
    }
    
    public func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        ISMChatHelper.print()
    }
    
    public func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        ISMChatHelper.print("\(err?.localizedDescription ?? "")")
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
        
        ISMChatHelper.print("[TRACE] [\(prettyName)]: \(message)")
    }
}


protocol ISMChatMQTTManagerDelegate: AnyObject {
    func didReceiveTypingEvent(data: ISMChatTypingEvent)
    func didReceiveConversationCreated(data: ISMChatCreateConversation)
    func didReceiveMessageDelivered(data: ISMChatMessageDelivered)
    func didReceiveMessageRead(data: ISMChatMessageDelivered)
    func didReceiveMessageDeleteForAll(data: ISMChatMessageDelivered)
    func didReceiveMultipleMessageRead(data: ISMChatMultipleMessageRead)
    func didReceiveMessage(data: ISMChatMessageDelivered)
    func didReceiveAddReaction(data: Data)
    func didReceiveRemoveReaction(data: Data)
    func didReceiveBlockAndUnBlockUser(data: ISMChatUserBlockAndUnblock)
    func didReceiveBlockAndUnBlockConversation(data: ISMChatMessageDelivered)
    func didReceiveMessageDetailUpdated(data: ISMChatMessageDelivered)
}


extension UIApplication {
    
    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController? {
            if let nav = viewController as? UINavigationController {
                return topViewController(nav.visibleViewController)
            }
            if let tab = viewController as? UITabBarController {
                if let selected = tab.selectedViewController {
                    return topViewController(selected)
                }
            }
            if let presented = viewController?.presentedViewController {
                return topViewController(presented)
            }
            return viewController
        }
}
