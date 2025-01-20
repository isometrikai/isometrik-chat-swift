//
//  SwiftUIView.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 20/01/25.
//

import SwiftUI
import IsometrikChat

struct InviteeListPopUpView: View {
    var appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    var message : MessagesDB
    @Binding var isPresented : Bool
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            HStack{
                Button {
                    isPresented = false
                } label: {
                    appearance.images.dismissButton
                        .resizable()
                        .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
                }
                
                Spacer()
                
                Text("Invitees")
                    .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().bold, size: 16))
                    .foregroundColor(Color(hex: "#0E0F0C"))
                
                Spacer()
                
                Image("")
                    .resizable()
                    .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
            }
        }
        if let memebersInvited = message.metaData?.inviteMembers{
            List {
                ForEach(memebersInvited, id: \.self) { member in
                    HStack(spacing: 8) {
                       
                        UserAvatarView(avatar: member.userProfileImage ?? "", showOnlineIndicator: false,size: CGSize(width: 40, height: 40), userName: member.userName ?? "")
                        
                        // Option text
                        Text(member.userName ?? "")
                            .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 16))
                            .foregroundColor(Color(hex: "#0E0F0C"))
                        
                        Spacer()
                    }.padding(.vertical,7)
                    .contentShape(Rectangle())
                }.listRowSeparator(.hidden)
            }.listStyle(.plain)
                .listRowSeparator(.hidden)
        }
    }
}

