//
//  SwiftUIView.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 20/01/25.
//

import SwiftUI
import IsometrikChat

/// A SwiftUI view that displays a list of invitees in a popup format
/// This view is used to show all members who have been invited to a particular chat or event
struct InviteeListPopUpView: View {
    // MARK: - Properties
    
    /// The appearance configuration for the chat SDK UI
    var appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    /// The message database object containing invitee information
    var message: MessagesDB
    
    /// Closure to handle dismissal of the popup
    var cancel: () -> ()
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header section with dismiss button and title
            HStack {
                // Dismiss button
                Button {
                    cancel()
                } label: {
                    appearance.images.dismissButton
                        .resizable()
                        .frame(width: appearance.imagesSize.backButton.width, 
                               height: appearance.imagesSize.backButton.height)
                }
                
                Spacer()
                
                // Title
                Text("Invitees")
                    .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().bold, size: 16))
                    .foregroundColor(Color(hex: "#0E0F0C"))
                
                Spacer()
                
                // Empty image for layout symmetry
                Image("")
                    .resizable()
                    .frame(width: appearance.imagesSize.backButton.width, 
                           height: appearance.imagesSize.backButton.height)
            }
            .padding(.horizontal, 15)
            .padding(.top, 20)
        }
        
        // List of invitees
        if let memebersInvited = message.metaData?.inviteMembers {
            List {
                ForEach(memebersInvited, id: \.self) { member in
                    // Individual member row
                    HStack(spacing: 8) {
                        // Member avatar
                        UserAvatarView(
                            avatar: member.userProfileImage ?? "",
                            showOnlineIndicator: false,
                            size: CGSize(width: 40, height: 40),
                            userName: member.userName ?? ""
                        )
                        
                        // Member name
                        Text(member.userName ?? "")
                            .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 16))
                            .foregroundColor(Color(hex: "#0E0F0C"))
                        
                        Spacer()
                    }
                    .padding(.vertical, 7)
                    .contentShape(Rectangle())
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)
        }
    }
}

