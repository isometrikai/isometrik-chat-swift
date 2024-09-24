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
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @State var usersNames : String = ""
    
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 8) {
                Text("Recipients: \(chat.membersCount ?? 0)")
                    .foregroundColor(appearance.colorPalette.chatListUserName)
                    .font(appearance.fonts.chatListUserName)
                Text(usersNames)
                    .foregroundColor(appearance.colorPalette.chatListUserMessage)
                    .font(appearance.fonts.chatListUserMessage)
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
