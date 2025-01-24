//
//  ISMBroadCastSubView.swift
//  ISMChatSdk
//
//  Created by Rasika on 04/06/24.
//

import SwiftUI
import IsometrikChat

/// A SwiftUI view that displays broadcast chat details including recipient count and member names
/// This view is used as a subview in the chat list to show broadcast message information
struct ISMBroadCastSubView: View {
    
    // MARK: - Properties
    
    /// The broadcast chat details containing member information and metadata
    let chat: ISMChatBroadCastDetail
    
    /// UI appearance configuration obtained from the SDK singleton
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    /// Comma-separated string of recipient names, updated when view appears
    @State var usersNames: String = ""
    
    // MARK: - View Body
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                // Display total number of recipients
                Text("Recipients: \(chat.membersCount ?? 0)")
                    .foregroundColor(appearance.colorPalette.chatListUserName)
                    .font(appearance.fonts.chatListUserName)
                
                // Display comma-separated list of recipient names
                Text(usersNames)
                    .foregroundColor(appearance.colorPalette.chatListUserMessage)
                    .font(appearance.fonts.chatListUserMessage)
            }
            Spacer()
            
            // TODO: Add appropriate image asset name or remove if not needed
            Image("")
        }
        .onAppear {
            // When view appears, create comma-separated string of member names
            if let members = chat.metaData?.membersDetail {
                self.usersNames = members.map { $0.memberName ?? "" }.joined(separator: ", ")
            }
        }
    }
}
