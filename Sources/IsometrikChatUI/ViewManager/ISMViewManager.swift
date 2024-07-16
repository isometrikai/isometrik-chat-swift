//
//  File.swift
//  
//
//  Created by Rasika on 15/07/24.
//

import Foundation
import SwiftUI
import IsometrikChat


public class ISMViewManager{
    public init(){}
    
    public func conversationList(delegete : ISMConversationViewDelegate? = nil) -> some View {
        return ISMConversationView(delegate: delegete)
    }
    
    public func messageList(conversationViewModel : ConversationViewModel,conversationId: String,user : UserDB,isGroup : Bool,fromBroadCastFlow : Bool,groupCastId : String,groupConversationTitle : String,groupImage : String) -> some View{
        return ISMMessageView(conversationViewModel: conversationViewModel, conversationID: conversationId, opponenDetail: user, isGroup: isGroup, fromBroadCastFlow: fromBroadCastFlow, groupCastId: groupCastId,groupConversationTitle : groupConversationTitle,groupImage : groupImage)
    }
}
