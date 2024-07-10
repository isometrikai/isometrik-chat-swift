//
//  ISMBroadCastSubView.swift
//  ISMChatSdk
//
//  Created by Rasika on 04/06/24.
//

import SwiftUI
import IsometrikChat

struct ISMBroadCastSubView: View {
    
    let chat : ISMChatBroadCastDetail
    @State var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State var usersNames : String = ""
    
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 8) {
                Text("Recipients: \(chat.membersCount ?? 0)")
                    .foregroundColor(themeColor.chatListUserName)
                    .font(themeFonts.chatListUserName)
                Text(usersNames)
                    .foregroundColor(themeColor.chatListUserMessage)
                    .font(themeFonts.chatListUserMessage)
            }
            Spacer()
            
            Image("")
        }.onAppear {
            if let members = chat.metaData?.membersDetail {
                self.usersNames = members.map { $0.memberName ?? "" }.joined(separator: ", ")
            }
        }
    }
}
