//
//  ISMConversationView+Buttons.swift
//  ISMChatSdk
//
//  Created by Rasika on 02/05/24.
//

import Foundation
import SwiftUI

extension ISMConversationView{
    func navigationLeading() -> some View{
        HStack{
            Button {
                showProfile = true
            } label: {
                UserAvatarView(avatar: userSession.getUserProfilePicture() , showOnlineIndicator: false,size: CGSize(width: 38, height: 38),userName : userSession.getUserName() ,font: .regular(size: 14))
            }
            Text("Chats")
                .font(Font.bold(size: 25))
        }
    }
    
    func navigationTrailing() -> some View{
        Menu {
            Button {
                navigateToBlockUsers = true
            } label: {
                Label("Blocked Users", systemImage: "circle.slash")
            }
            if showBroadCastOption == true{
                Button {
                    navigateToBroadcastList = true
                } label: {
                    Label("Broadcast Lists", systemImage: "circle.slash")
                }
            }
//                            Button {
//                                isDarkMode.toggle()
//                            } label: {
//                                Label(isDarkMode ? "Light Mode" : " Dark Mode", systemImage: isDarkMode ?  "sun.max.fill" : "moon.fill")
//                            }
        } label: {
            themeImages.threeDots
                .rotationEffect(.degrees(-90))
                .foregroundColor(.black)
            
        }
    }
}
