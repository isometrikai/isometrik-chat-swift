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
    let member : ISMChat_GroupMember
    var hideDisclosure : Bool? = false
    @Binding var selectedMember : ISMChat_GroupMember
    @State var themeFonts = ISMChatSdk.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdk.getInstance().getAppAppearance().appearance.colorPalette
    @State var userSession = ISMChatSdk.getInstance().getUserSession()
    //MARK: - BODY
    var body: some View {
        Button {
            selectedMember = member
        } label: {
            HStack(spacing: 12){
                UserAvatarView(avatar: member.userProfileImageUrl ?? "", showOnlineIndicator: false,size: CGSize(width: 29, height: 29), userName: member.userName ?? "",font: themeFonts.chatList_UserMessage)
                
                VStack(alignment: .leading,spacing: 5){
                    if member.userId != userSession.getUserId(){
                        Text(member.userName?.capitalizingFirstLetter() ?? "")
                            .font(themeFonts.messageList_MessageText)
                            .foregroundColor(themeColor.messageList_MessageText)
                    }else{
                        Text(ConstantStrings.you)
                            .font(themeFonts.messageList_MessageText)
                            .foregroundColor(themeColor.messageList_MessageText)
                    }
                    Text(member.userIdentifier ?? "")
                        .font(themeFonts.chatList_UserMessage)
                        .foregroundColor(themeColor.chatList_UserMessage)
                        .lineLimit(2)
                }
                Spacer()
                
                if member.isAdmin == true{
                    Text("Admin")
                        .font(themeFonts.chatList_UserMessage)
                        .foregroundColor(themeColor.chatList_UserMessage)
                }
                if member.userId != userSession.getUserId(){
                    if hideDisclosure == false{
                        Image("chevron_right")
                            .resizable()
                            .frame(width: 20,height: 20)
                    }
                }
            }
        }
    }
}
