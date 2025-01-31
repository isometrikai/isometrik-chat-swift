//
//  SwiftUIView.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 31/01/25.
//

import Foundation
import CocoaMQTT
import UIKit
import ISMSwiftCall

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
