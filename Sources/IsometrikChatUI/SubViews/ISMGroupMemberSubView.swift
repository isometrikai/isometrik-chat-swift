//
//  ISMGroupMemberSubView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 25/07/23.
//

import SwiftUI
import IsometrikChat

struct ISMGroupMemberSubView: View {
    
    //MARK: - PROPERTIES
    let member : ISMChatGroupMember
    var hideDisclosure : Bool? = false
    @Binding var selectedMember : ISMChatGroupMember
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    var userData = ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig
    //MARK: - BODY
    var body: some View {
        Button {
            selectedMember = member
        } label: {
            HStack(spacing: 12){
                UserAvatarView(avatar: member.userProfileImageUrl ?? "", showOnlineIndicator: false,size: CGSize(width: 29, height: 29), userName: member.userId != userData?.userId ? (member.userName ?? "") : "You",font: appearance.fonts.chatListUserMessage)
                
                VStack(alignment: .leading,spacing: 5){
                    if member.userId != userData?.userId{
                        Text(member.userName?.capitalizingFirstLetter() ?? "")
                            .font(appearance.fonts.messageListMessageText)
                            .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                    }else{
                        Text(ConstantStrings.you)
                            .font(appearance.fonts.messageListMessageText)
                            .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                    }
                }
                Spacer()
                
                if member.isAdmin == true{
                    Text("Admin")
                        .font(appearance.fonts.chatListUserMessage)
                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                }
//                if member.userId != userData.userId{
//                    if hideDisclosure == false{
//                        Image("chevron_right")
//                            .resizable()
//                            .frame(width: 20,height: 20)
//                    }
//                }
            }
        }
    }
}
