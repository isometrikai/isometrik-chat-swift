//
//  MQTTEventResponse.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 26/04/23.
//

import Foundation


extension ISMChatMQTTManager {
    
    //MARK: - TYPING MESSAGE
    func typingEventResponse(_ data: Data, completionHandler: @escaping(ISMChatMqttResult<ISMChatTypingEvent>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChatTypingEvent
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChatError(errorMessage: "Error while parsing  TypingEvent .")
            completionHandler(.failure(error))
        }
    }
    
    //MARK: - CREATE CONVERSATION
    func conversationCreatedResponse(_ data: Data, completionHandler: @escaping(ISMChatMqttResult<ISMChatCreateConversation>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChatCreateConversation
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChatError(errorMessage: "Error while parsing  CreateConversation .")
            completionHandler(.failure(error))
        }
    }
    
    //MARK: - MESSAGE DELEIVERED
    func messageDelivered(_ data: Data, completionHandler: @escaping(ISMChatMqttResult<ISMChatMessageDelivered>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChatMessageDelivered
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChatError(errorMessage: "Error while parsing MessageDelivered .")
            completionHandler(.failure(error))
        }
    }
    
    //MARK: - NEW MESSAGE RECEIVED
    func messageReceived(_ data: Data, completionHandler: @escaping(ISMChatMqttResult<ISMChatMessageDelivered>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChatMessageDelivered
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChatError(errorMessage: "Error while parsing MessageDelivered .")
            completionHandler(.failure(error))
        }
    }
    
    //MARK: - MESSAGE READ
    func messageRead(_ data: Data, completionHandler: @escaping(ISMChatMqttResult<ISMChatMessageDelivered>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChatMessageDelivered
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChatError(errorMessage: "Error while parsing MessageDelivered .")
            completionHandler(.failure(error))
        }
    }
    
    //MARK: - MULTIPLE MESSAGE READ
    func multipleMessageRead(_ data: Data, completionHandler: @escaping(ISMChatMqttResult<ISMChatMultipleMessageRead>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChatMultipleMessageRead
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChatError(errorMessage: "Error while parsing MessageDelivered .")
            completionHandler(.failure(error))
        }
    }
    
    func blockedUserAndUnBlocked(_ data: Data, completionHandler: @escaping(ISMChatMqttResult<ISMChatMessageDelivered>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChatMessageDelivered
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChatError(errorMessage: "Error while parsing MessageDelivered .")
            completionHandler(.failure(error))
        }
    }
    
    func messageDeleteForAll(_ data: Data, completionHandler: @escaping(ISMChatMqttResult<ISMChatMessageDelivered>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChatMessageDelivered
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChatError(errorMessage: "Error while parsing MessageDelivered .")
            completionHandler(.failure(error))
        }
    }
    
    //MARK: - MESSAGE UPDATED
    func messageUpdated(_ data: Data, completionHandler: @escaping(ISMChatMqttResult<ISMChatMessageDelivered>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChatMessageDelivered
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChatError(errorMessage: "Error while parsing MessageDelivered .")
            completionHandler(.failure(error))
        }
    }
    
    //MARK: - REACTIONS
    func reactions(_ data: Data, completionHandler: @escaping(ISMChatMqttResult<ISMChatReactions>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChatReactions
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChatError(errorMessage: "Error while parsing MessageDelivered .")
            completionHandler(.failure(error))
        }
    }
    
    //MARK: - BLOCK UNBLOCK
    func blockedUserAndUnBlockedUser(_ data: Data, completionHandler: @escaping(ISMChatMqttResult<ISMChatUserBlockAndUnblock>) -> Void) {
        do {
            let moderatorObj = try data.decode() as ISMChatUserBlockAndUnblock
            completionHandler(.success(moderatorObj))
        } catch {
            let error = ISMChatError(errorMessage: "Error while parsing MessageDelivered .")
            completionHandler(.failure(error))
        }
    }
}
