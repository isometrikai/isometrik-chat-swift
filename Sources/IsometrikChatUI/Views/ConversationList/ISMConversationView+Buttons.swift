//
//  ISMConversationView+Buttons.swift
//  ISMChatSdk
//
//  Created by Rasika on 02/05/24.
//

import Foundation
import SwiftUI

extension ISMConversationView {
    /// Creates the leading navigation view with a user avatar and a "Chats" label.
    /// - Returns: A view containing the user avatar and the "Chats" text.
    func navigationLeading() -> some View {
        HStack {
            // Button to show the user's profile when tapped
            Button {
                showProfile = true
            } label: {
                // Displays the user's avatar with a default image if none is available
                UserAvatarView(avatar: myUserData?.userProfileImage ?? "", showOnlineIndicator: false, size: CGSize(width: 38, height: 38), userName: myUserData?.userName ?? "", font: .regular(size: 14))
            }
            // Displays the "Chats" label with bold font
            Text("Chats")
                .font(Font.bold(size: 25))
        }
    }
    
    /// Creates the trailing navigation menu with options for blocking users and viewing broadcast lists.
    /// - Returns: A view containing a menu with navigation links.
    func navigationTrailing() -> some View {
        Menu {
            // Navigation link to the blocked users view
            NavigationLink {
                ISMBlockUserView(conversationViewModel: self.viewModel)
            } label: {
                Label("Blocked Users", systemImage: "circle.slash")
            }

            // Conditional display of the broadcast lists option
            if showBroadCastOption == true {
                // Navigation link to the broadcast lists view
                NavigationLink {
                    ISMBroadCastList(viewModelNew : self.viewModelNew)
                } label: {
                    Label("Broadcast Lists", systemImage: "circle.slash")
                }
            }
        } label: {
            // Displays the three dots icon for the menu
            appearance.images.threeDots
                .resizable()
                .frame(width: 5, height: 20, alignment: .center)
        }
    }
}
