//
//  MQTTEventResponse.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 26/04/23.
//

import Foundation


extension ISMChat_MQTTManager {
    
    //MARK: - TYPING MESSAGE
    func typingEventResponse(_ data: Data, completionHandler: @escaping(ISMChat_MqttResult<ISMChat_TypingEvent>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChat_TypingEvent
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChat_Error(errorMessage: "Error while parsing  TypingEvent .")
            completionHandler(.failure(error))
        }
    }
    
    //MARK: - CREATE CONVERSATION
    func conversationCreatedResponse(_ data: Data, completionHandler: @escaping(ISMChat_MqttResult<ISMChat_CreateConversation>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChat_CreateConversation
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChat_Error(errorMessage: "Error while parsing  CreateConversation .")
            completionHandler(.failure(error))
        }
    }
    
    //MARK: - MESSAGE DELEIVERED
    func messageDelivered(_ data: Data, completionHandler: @escaping(ISMChat_MqttResult<ISMChat_MessageDelivered>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChat_MessageDelivered
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChat_Error(errorMessage: "Error while parsing MessageDelivered .")
            completionHandler(.failure(error))
        }
    }
    
    //MARK: - NEW MESSAGE RECEIVED
    func messageReceived(_ data: Data, completionHandler: @escaping(ISMChat_MqttResult<ISMChat_MessageDelivered>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChat_MessageDelivered
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChat_Error(errorMessage: "Error while parsing MessageDelivered .")
            completionHandler(.failure(error))
        }
    }
    
    //MARK: - MESSAGE READ
    func messageRead(_ data: Data, completionHandler: @escaping(ISMChat_MqttResult<ISMChat_MessageDelivered>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChat_MessageDelivered
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChat_Error(errorMessage: "Error while parsing MessageDelivered .")
            completionHandler(.failure(error))
        }
    }
    
    //MARK: - MULTIPLE MESSAGE READ
    func multipleMessageRead(_ data: Data, completionHandler: @escaping(ISMChat_MqttResult<ISMChat_MultipleMessageRead>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChat_MultipleMessageRead
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChat_Error(errorMessage: "Error while parsing MessageDelivered .")
            completionHandler(.failure(error))
        }
    }
    
    func blockedUserAndUnBlocked(_ data: Data, completionHandler: @escaping(ISMChat_MqttResult<ISMChat_MessageDelivered>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChat_MessageDelivered
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChat_Error(errorMessage: "Error while parsing MessageDelivered .")
            completionHandler(.failure(error))
        }
    }
    
    func messageDeleteForAll(_ data: Data, completionHandler: @escaping(ISMChat_MqttResult<ISMChat_MessageDelivered>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChat_MessageDelivered
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChat_Error(errorMessage: "Error while parsing MessageDelivered .")
            completionHandler(.failure(error))
        }
    }
    
    //MARK: - MESSAGE UPDATED
    func messageUpdated(_ data: Data, completionHandler: @escaping(ISMChat_MqttResult<ISMChat_MessageDelivered>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChat_MessageDelivered
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChat_Error(errorMessage: "Error while parsing MessageDelivered .")
            completionHandler(.failure(error))
        }
    }
   func reactions(_ data: Data, completionHandler: @escaping(ISMChat_MqttResult<ISMChat_Reactions>) -> Void) {
       do {
           let moderatorObj = try data.decode() as ISMChat_Reactions
           completionHandler(.success(moderatorObj))
       } catch {
           let error = ISMChat_Error(errorMessage: "Error while parsing MessageDelivered .")
           completionHandler(.failure(error))
       }
   }
    
    
    //callkit
//    func meeting(_ data: Data, completionHandler: @escaping(ISMChat_MqttResult<ISMCall_Meeting>) -> Void) {
//        do {
//            let moderatorObj = try data.decode() as ISMMeeting
//            completionHandler(.success(moderatorObj))
//        } catch {
//            let error = ISMChat_Error(errorMessage: "Error while parsing Meeting Data .")
//            completionHandler(.failure(error))
//        }
//    }
    
    func blockedUserAndUnBlockedUser(_ data: Data, completionHandler: @escaping(ISMChat_MqttResult<ISMChat_UserBlockAndUnblock>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChat_UserBlockAndUnblock
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChat_Error(errorMessage: "Error while parsing MessageDelivered .")
            completionHandler(.failure(error))
        }
    }
    
}
