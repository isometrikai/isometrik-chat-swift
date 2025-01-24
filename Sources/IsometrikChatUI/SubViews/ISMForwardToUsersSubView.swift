//
//  ISMForwardToUsersSubView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 22/06/23.
//

import SwiftUI
import IsometrikChat

/// A SwiftUI view that represents a selectable user row for forwarding messages
/// This view displays user information and handles selection/deselection logic with a limit of 5 users
struct ISMForwardToUsersSubView: View {
    
    //MARK:  - PROPERTIES
    
    /// Array of selected users for forwarding
    @Binding var selections: [ISMChatUser]
    /// Controls visibility of the send view
    @Binding  var showSendView : Bool
    /// The user data to display in this row
    let user : ISMChatUser
    /// Array of selected usernames
    @Binding var selectedUser : [String]
    /// Controls visibility of the maximum selection alert
    @Binding var showAlert : Bool
    /// Tracks the selection state of this specific user row
    @State var showSelected : Bool = false
    /// UI appearance configuration
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    //MARK:  - BODY
    var body: some View {
        HStack(spacing: 5) {
            // Image
            UserAvatarView(avatar: user.userProfileImageUrl ?? "",
                           showOnlineIndicator: user.online ?? false,
                           size: CGSize(width: 29, height: 29),
                           userName: user.userName ?? "",
                           font: appearance.fonts.messageListMessageText)
            
            // UserName
            Text(user.userName?.capitalizingFirstLetter() ?? "")
                .font(appearance.fonts.messageListMessageText)
                .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
            
            // Selection Icon
            Spacer()
            Image(systemName: showSelected ? "selected" : "unselected")
                .resizable()
                .frame(width: 20, height: 20)
        }
        .frame(height: 50)
        .onTapGesture {
            // Handle user selection/deselection
            if let index = self.selections.firstIndex(where: { $0.userId == user.userId }) {
                // Deselect user if already selected
                self.selections.remove(at: index)
                selectedUser.removeAll(where: { $0 == user.userName })
                showSelected = false
                showSendView = !self.selections.isEmpty
            } else {
                // Select user if under the 5 user limit
                if selections.count < 5 {
                    showSelected = true
                    self.selections.append(user)
                    selectedUser.append(user.userName ?? "")
                    showSendView = true
                } else {
                    // Show alert if attempting to select more than 5 users
                    showAlert = true
                }
            }
        }
    }
}
