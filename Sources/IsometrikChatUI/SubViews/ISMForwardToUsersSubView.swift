//
//  ISMForwardToUsersSubView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 22/06/23.
//

import SwiftUI
import IsometrikChat

struct ISMForwardToUsersSubView: View {
    
    //MARK:  - PROPERTIES
    
    @Binding var selections: [ISMChatUser]
    @Binding  var showSendView : Bool
    let user : ISMChatUser
    @Binding var selectedUser : [String]
    @Binding var showAlert : Bool
    @State var showSelected : Bool = false
    @State var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    
    //MARK:  - BODY
    var body: some View {
        HStack(spacing: 5) {
            // Image
            UserAvatarView(avatar: user.userProfileImageUrl ?? "",
                           showOnlineIndicator: user.online ?? false,
                           size: CGSize(width: 29, height: 29),
                           userName: user.userName ?? "",
                           font: themeFonts.messageListMessageText)
            
            // UserName
            Text(user.userName?.capitalizingFirstLetter() ?? "")
                .font(themeFonts.messageListMessageText)
                .foregroundColor(themeColor.messageListHeaderTitle)
            
            // Selection Icon
            Spacer()
            Image(systemName: showSelected ? "selected" : "unselected")
                .resizable()
                .frame(width: 20, height: 20)
        }
        .frame(height: 50)
        .onTapGesture {
            if let index = self.selections.firstIndex(where: { $0.userId == user.userId }) {
                self.selections.remove(at: index)
                selectedUser.removeAll(where: { $0 == user.userName })
                showSelected = false
                showSendView = !self.selections.isEmpty
            } else {
                if selections.count < 5{
                    showSelected = true
                    self.selections.append(user)
                    selectedUser.append(user.userName ?? "")
                    showSendView = true
                }else{
                    showAlert = true
                }
            }
        }
    }
}
