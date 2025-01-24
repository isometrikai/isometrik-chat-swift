//
//  ISMGroupMemberSubView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 25/07/23.
//

import SwiftUI
import IsometrikChat

/// A SwiftUI view that displays a single group member in a list
/// This view is responsible for showing member details including their avatar, name, and admin status
struct ISMGroupMemberSubView: View {
    
    //MARK: - PROPERTIES
    /// The group member to display
    let member: ISMChatGroupMember
    
    /// Controls whether to show the disclosure indicator (chevron)
    /// Defaults to false if not specified
    var hideDisclosure: Bool? = false
    
    /// Binding to track the currently selected member
    /// Updates when this member cell is tapped
    @Binding var selectedMember: ISMChatGroupMember
    
    /// UI appearance configuration from the SDK
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    /// Current user configuration from the SDK
    var userData = ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig
    
    //MARK: - BODY
    var body: some View {
        // Tapping the cell selects this member
        Button {
            selectedMember = member
        } label: {
            HStack(spacing: 12) {
                // User avatar with profile image or fallback to username
                UserAvatarView(
                    avatar: member.userProfileImageUrl ?? "",
                    showOnlineIndicator: false,
                    size: CGSize(width: 29, height: 29),
                    userName: member.userId != userData?.userId ? (member.userName ?? "") : "You",
                    font: appearance.fonts.chatListUserMessage
                )
                
                // Member name display
                VStack(alignment: .leading, spacing: 5) {
                    if member.userId != userData?.userId {
                        // Show member name for other users
                        Text(member.userName?.capitalizingFirstLetter() ?? "")
                            .font(appearance.fonts.messageListMessageText)
                            .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                    } else {
                        // Show "You" for the current user
                        Text(ConstantStrings.you)
                            .font(appearance.fonts.messageListMessageText)
                            .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                    }
                }
                Spacer()
                
                // Display admin badge if the member is an admin
                if member.isAdmin == true {
                    Text("Admin")
                        .font(appearance.fonts.chatListUserMessage)
                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                }
                
                // Note: Disclosure indicator is currently commented out
                // Uncomment and modify if needed for navigation
            }
        }
    }
}
