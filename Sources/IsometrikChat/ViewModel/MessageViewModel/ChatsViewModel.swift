//
//  ChatViewModel.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 30/01/23.
//

import Foundation
import UIKit
import Alamofire
import LinkPresentation
import AVFoundation
import AVKit
import SwiftUI
import Combine
//import TUSKit
//import TransloaditKit

public class ChatsViewModel : NSObject ,ObservableObject,AVAudioPlayerDelegate{
    
    //MARK:  - PROPERTIES
    @Published public var messages : [[ISMChatMessage]]?
    @Published public var allMessages : [ISMChatMessage]? = []
    @Published public var forwardToConversations : [ISMChatConversationsDetail] = []
    @Published public var documentSelectedFromPicker : URL?
    
    public var skip : Int = 0
    public var skipUser : Int = 0
    @Published public var isBusy = false
    
    //audio recorder
    public var audioRecorder : AVAudioRecorder!
    public var audioPlayer : AVAudioPlayer!
    public var audioUrl : URL?
    public var indexOfPlayer = 0
    @Published public var isRecording : Bool = false
    @Published public var countSec = 0
    @Published public var timerCount : Timer?
    @Published public var blinkingCount : Timer?
    @Published public var timerValue : String = "0:00"
    @Published public var toggleColor : Bool = false
    
    @Published public var recordingsList = [ISMChatRecording]()
    
    //grp
    @Published public var groupTitleImage : URL?

 
    //MARK: - get conversation Detail
    public func getConversationDetail(conversationId : String,isGroup : Bool,completion:@escaping(ISMChatConversationDetail?)->()){
        
        let endPoint = ISMChatConversationEndpoint.conversationDetail(conversationId: conversationId, includeMembers: true, isGroup: isGroup)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatConversationDetail, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("Get CONVERSATION detail Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - message read info
    public func getMessageReadInfo(messageId : String,conversationId : String,completion:@escaping(ISMChatConversationDetail?)->()){
        
        let endPoint = ISMChatMessagesEndpoint.messageReadInfo(conversationId: conversationId, messageId: messageId)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatConversationDetail, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(_) :
                ISMChatHelper.print("Message Read Info Failed")
            }
        }
    }
    
    //MARK: - message delivered info
    public func getMessageDeliveredInfo(messageId : String,conversationId : String,completion:@escaping(ISMChatConversationDetail?)->()){
        
        let endPoint = ISMChatMessagesEndpoint.messageDeliveredInfo(conversationId: conversationId, messageId: messageId)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatConversationDetail, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(_) :
                ISMChatHelper.print("Message deleivered Info Failed")
            }
        }
    }
  
    
    //MARK: - create conversation
    public func createConversation(user : UserDB,chatStatus : String? = nil,completion:@escaping(ISMChatCreateConversationResponse?)->()){
        var body : [String : Any]
        let metaDataValue : [String : Any] = ["chatStatus" : chatStatus ?? ""]
        body = ["typingEvents" : true ,
                "readEvents" : true,
                "pushNotifications" : true,
                "members" : [user.userId],
                "isGroup" : false,
                "conversationType" : 0,
                "metaData" : metaDataValue] as [String : Any]
        
        
        let endPoint = ISMChatConversationEndpoint.createConversation
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("Create Conversation Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - accept rquest to chat
    public func acceptRequestToAllowMessage(conversationId : String,completion:@escaping(ISMChatCreateConversationResponse?)->()){
        var body : [String : Any]
        let metaData = ["chatStatus" : ISMChatStatus.Accept.value]
        body = ["metaData" : metaData,"conversationId" : conversationId] as [String : Any]
        
        let endPoint = ISMChatConversationEndpoint.updateConversationDetail
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                completion(data)
            case .failure(let error) :
                ISMChatHelper.print("Meta data changed to allow message -----> \(String(describing: error))")
            }
        }
    }
    
    
    //MARK: - get all messages not delivered yet
    public func getAllMessagesWhichWereSendToMeWhenOfflineMarkThemAsDelivered(myUserId : String,skip : Int = 0){
        let limit = 20
        
        let endPoint = ISMChatMessagesEndpoint.allUnreadMessagesFromAllConversation(senderIdsExclusive: true, deliveredToMe: false, senderIds: myUserId, limit: limit, skip: skip, sort: -1)
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: [])
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatMessages, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                print("success")
                let filteredMessages = data.messages?.filter { message in
                    return message.action != ISMChatActionType.userBlock.value &&
                    message.action != ISMChatActionType.userUnblock.value &&
                    message.action != ISMChatActionType.userBlockConversation.value &&
                    message.action != ISMChatActionType.userUnblockConversation.value &&
                    message.action != ISMChatActionType.deleteConversationLocally.value &&
                    message.action != ISMChatActionType.conversationTitleUpdated.value &&
                    message.action != ISMChatActionType.conversationImageUpdated.value &&
                    message.action != ISMChatActionType.conversationCreated.value &&
                    message.action != ISMChatActionType.membersAdd.value &&
                    message.action != ISMChatActionType.memberLeave.value &&
                    message.action != ISMChatActionType.addAdmin.value &&
                    message.action != ISMChatActionType.removeAdmin.value &&
                    message.action != ISMChatActionType.membersRemove.value &&
                    message.action != ISMChatActionType.messageDetailsUpdated.value &&
                    message.action != ISMChatActionType.reactionAdd.value &&
                    message.action != ISMChatActionType.reactionRemove.value &&
                    message.action != ISMChatActionType.conversationSettingsUpdated.value &&
                    message.action != ISMChatActionType.meetingCreated.value &&
                    message.action != ISMChatActionType.meetingEndedDueToRejectionByAll.value &&
                    message.action != ISMChatActionType.meetingEndedDueToNoUserPublishing.value &&
                    message.action != ISMChatActionType.userUpdate.value
                }
                if let messagesToDeliver = filteredMessages {
                    for message in messagesToDeliver {
                        guard let conversationId = message.conversationId,
                              let messageId = message.messageId else {
                            continue // Skip this message if conversationId or messageId is nil
                        }
                        
                        let myUserId = ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig.userId
                        
                        // Check if your userId is contained in the deliveredTo array
                        let containsUserId = message.deliveredTo?.contains(where: { $0.userId == myUserId }) ?? false
                        
                        if !containsUserId {
                            // Call your delivered API if your userId is not contained in deliveredTo
                            self.deliveredMessageIndicator(conversationId: conversationId, messageId: messageId) { value in
                                if value == true {
                                    // Do something if the message was delivered successfully
                                }
                            }
                        }
                    }
                    if messagesToDeliver.count == limit {
                        self.getAllMessagesWhichWereSendToMeWhenOfflineMarkThemAsDelivered(myUserId: myUserId, skip: skip + limit)
                    } else {
                        print("Pagination stopped")
                    }
                }
            case .failure(let error) :
                ISMChatHelper.print("get all messages Api fail -----> \(String(describing: error))")
            }
        }
    }
    
    
    //MARK: - mark message as read
    public func markMessagesAsRead(conversationId : String){
        var body : [String : Any]
        let timeStamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
        body = ["conversationId" : conversationId ,
                "timestamp" : timeStamp] as [String : Any]
        
        let endPoint = ISMChatMessagesEndpoint.markMessageStatusRead
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                ISMChatHelper.print("Mark Message Read Api succedded -----> \(String(describing: data.msg))")
            case .failure(let error) :
                ISMChatHelper.print("Mark Message Read Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - read message indicator
    public func readMessageIndicator(conversationId : String,messageId : String,completion:@escaping(Bool?)->()){
        var body : [String : Any]
        body = ["conversationId" : conversationId ,
                "messageId" : messageId] as [String : Any]
        
        let endPoint = ISMChatIndicatorEndpoint.readIndicator
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                ISMChatHelper.print("Read Message Indicator Api succedded -----> \(String(describing: data.msg))")
                completion(true)
            case .failure(let error) :
                ISMChatHelper.print("Read Message Indicator Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - typing message indicator
    public func typingMessageIndicator(conversationId : String){
        var body : [String : Any]
        body = ["conversationId" : conversationId] as [String : Any]
        
        let endPoint = ISMChatIndicatorEndpoint.typingIndicator
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                ISMChatHelper.print("Typing Message Indicator Api succedded -----> \(String(describing: data.msg))")
            case .failure(let error) :
                ISMChatHelper.print("Typing Message Indicator Api failed -----> \(String(describing: error))")
            }
        }
    }
    
    //MARK: - delivered message indicator
    public func deliveredMessageIndicator(conversationId : String,messageId : String,completion:@escaping(Bool?)->()){
        var body : [String : Any]
        body = ["conversationId" : conversationId ,
                "messageId" : messageId] as [String : Any]
        
        let endPoint = ISMChatIndicatorEndpoint.deliveredIndicator
        let request =  ISMChatAPIRequest(endPoint: endPoint, requestBody: body)
        
        ISMChatNewAPIManager.sendRequest(request: request) {  (result : ISMChatResult<ISMChatCreateConversationResponse, ISMChatNewAPIError>) in
            switch result{
            case .success(let data,_) :
                ISMChatHelper.print("Delivered Message Indicator Api succedded -----> \(String(describing: data.msg))")
                completion(true)
            case .failure(let error) :
                ISMChatHelper.print("Delivered Message Indicator Api failed -----> \(String(describing: error))")
            }
        }
    }
}

extension ChatsViewModel{
    public func getSectionMessage(for chat : [MessagesDB]) -> [[MessagesDB]] {
        var res = [[MessagesDB]]()
        let groupedMessages = Dictionary(grouping: chat) { (element) -> Date in
            
            //timestamp
            let timeStamp = element.sentAt
            let unixTimeStamp: Double = Double(timeStamp ) / 1000.0
            let dateFormatt = DateFormatter()
            dateFormatt.dateFormat = "dd/MM/yyy"
            //conver to string
            let strDate = dateFormatt.string(from: Date(timeIntervalSince1970: unixTimeStamp) as Date)
            //str to date
            return dateFormatt.date(from: strDate) ?? Date()
        }
        let sortedKeys = groupedMessages.keys.sorted()
        sortedKeys.forEach { (key) in
            var values = groupedMessages[key]
            values?.sort { Double($0.sentAt ) / 1000.0 < Double($1.sentAt ) / 1000.0 }
            res.append(values ?? [])
        }
        return res
    }
}
