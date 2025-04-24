//
//  DineInStatusUI.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 24/04/25.
//

import SwiftUI
import IsometrikChat

struct ISMDineInStatusUI : View{
    var status: ISMChatPaymentRequestStatus
    var isReceived : Bool
    var message : MessagesDB
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(status == .Accepted ? "Accepted" : "Can’t attend")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                .foregroundColor(status == .Accepted ? Color(hex: "#121511") : Color.white)
                .frame(height: 73)
                .frame(maxWidth: .infinity)
                .background(status == .Accepted ? Color(hex: "#86EA5D") : Color(hex: "#FF3B30"))
                .cornerRadius(10, corners: [.topLeft, .topRight])
                .padding(.bottom,status == .Accepted ? 8 : 16)
            
            if status == .Accepted{
                appearance.images.acceptDineInRequest
                    .resizable()
                    .frame(width: 40, height: 40, alignment: .center)
                    .padding(.bottom,8)
            }
            
            Text(message.metaData?.inviteTitle ?? "")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                .foregroundColor(Color(hex: "#0E0F0C"))
                .padding(.bottom,8)
            
            Text(status == .Accepted ? "\(message.senderInfo?.userName ?? "") accepted the invitation!" : "\(message.senderInfo?.userName ?? "") can’t attend the event.")
                .multilineTextAlignment(.center)
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 14))
                .foregroundColor(Color(hex: "#454745"))
                .padding(.bottom,8)
                .padding(.horizontal,15)
            
        }
    }
}
