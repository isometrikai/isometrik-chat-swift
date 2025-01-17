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
    
    public func messageList(conversationViewModel : ConversationViewModel,conversationId: String,user : UserDB? = nil,isGroup : Bool,fromBroadCastFlow : Bool,groupCastId : String,groupConversationTitle : String,groupImage : String,delegate : ISMMessageViewDelegate? = nil,myIsometrikUserId : String,myAppUserId: String) -> some View{
        return ISMMessageView(conversationViewModel: conversationViewModel, conversationID: conversationId, opponenDetail: user, myUserId: myIsometrikUserId,myAppUserId: myAppUserId, isGroup: isGroup, fromBroadCastFlow: fromBroadCastFlow, groupCastId: groupCastId,groupConversationTitle : groupConversationTitle,groupImage : groupImage,delegate:delegate)
    }
    
    public func otherconversationList(delegete : OtherConversationListViewDelegate? = nil) -> some View {
        return OtherConversationListView(delegate: delegete)
    }
    
    public func broadcastList(delegete : ISMBroadCastListDelegate? = nil) -> some View{
        return ISMBroadCastList(delegate: delegete)
    }
}
