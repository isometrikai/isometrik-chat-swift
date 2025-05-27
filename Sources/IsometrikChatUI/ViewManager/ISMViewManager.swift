//
//  File.swift
//  
//
//  Created by Rasika on 15/07/24.
//

import Foundation
import SwiftUI
import IsometrikChat

/// ISMViewManager is responsible for managing and providing access to different chat-related views
/// in the Isometrik Chat UI framework.
public class ISMViewManager{
    /// Initialize a new instance of ISMViewManager
    public init(){}
    
    /// Creates and returns a conversation list view
    /// - Parameter delegate: Optional delegate to handle conversation view events
    /// - Returns: A SwiftUI view displaying the list of conversations
    public func conversationList(delegete : ISMConversationViewDelegate? = nil, height: CGFloat? = nil) -> some View {
        return ISMConversationView(delegate: delegete)
            .frame(height: height)
    }
    
    /// Creates and returns a message list view for a specific conversation
    /// - Parameters:
    ///   - conversationViewModel: View model containing conversation data
    ///   - conversationId: Unique identifier for the conversation
    ///   - user: Optional user database object for individual chats
    ///   - isGroup: Boolean indicating if the conversation is a group chat
    ///   - fromBroadCastFlow: Boolean indicating if the view is accessed from broadcast flow
    ///   - groupCastId: Unique identifier for the broadcast
    ///   - groupConversationTitle: Title of the group conversation
    ///   - groupImage: URL or path to the group's image
    ///   - delegate: Optional delegate to handle message view events
    ///   - myIsometrikUserId: Current user's Isometrik platform ID
    ///   - myAppUserId: Current user's app-specific ID
    /// - Returns: A SwiftUI view displaying the message list
    public func messageList(
        conversationViewModel: ConversationViewModel,
        conversationId: String,
        user: UserDB? = nil,
        isGroup: Bool,
        fromBroadCastFlow: Bool,
        groupCastId: String,
        groupConversationTitle: String,
        groupImage: String,
        delegate: ISMMessageViewDelegate? = nil,
        myIsometrikUserId: String,
        myAppUserId: String
    ) -> some View {
        return ISMMessageView(
            conversationViewModel: conversationViewModel,
            conversationID: conversationId,
            opponenDetail: user,
            myUserId: myIsometrikUserId,
            myAppUserId: myAppUserId,
            isGroup: isGroup,
            fromBroadCastFlow: fromBroadCastFlow,
            groupCastId: groupCastId,
            groupConversationTitle: groupConversationTitle,
            groupImage: groupImage,
            delegate: delegate
        )
    }
    
    /// Creates and returns a view for other types of conversations
    /// - Parameter delegate: Optional delegate to handle other conversation list events
    /// - Returns: A SwiftUI view displaying the list of other conversations
    public func otherconversationList(delegete : OtherConversationListViewDelegate? = nil) -> some View {
        return OtherConversationListView(delegate: delegete)
    }
    
    /// Creates and returns a broadcast list view
    /// - Parameter delegate: Optional delegate to handle broadcast list events
    /// - Returns: A SwiftUI view displaying the list of broadcasts
    public func broadcastList(delegete : ISMBroadCastListDelegate? = nil) -> some View{
        return ISMBroadCastList(delegate: delegete)
    }
}
