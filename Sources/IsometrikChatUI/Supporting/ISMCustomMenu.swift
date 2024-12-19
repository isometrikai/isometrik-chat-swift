//
//  CustomMenuView.swift
//  IsometrikChat
//
//  Created by My Book on 17/12/24.
//


import SwiftUI

struct ISMCustomMenu: View {
    // Actions for each button
    var clearChatAction: () -> Void
    var blockUserAction: () -> Void
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: clearChatAction) {
                HStack(spacing: 12) {
                    appearance.images.contextClearChat
                        .resizable()
                        .frame(width: 48, height: 48, alignment: .center)
                    Text("Clear chat")
                        .foregroundColor(appearance.colorPalette.messageListMessageTextReceived)
                        .font(appearance.fonts.messageListMessageText)
                    Spacer()
                }
                .padding()
            }
            // Block User Button
            Button(action: blockUserAction) {
                HStack(spacing: 12) {
                    appearance.images.contextBlockUser
                        .resizable()
                        .frame(width: 48, height: 48, alignment: .center)
                    Text("Block user")
                        .foregroundColor(appearance.colorPalette.messageListMessageTextReceived)
                        .font(appearance.fonts.messageListMessageText)
                    Spacer()
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

struct ConfirmationPopup: View {
    var title: String
    var message: AttributedString
    var confirmButtonTitle: String
    var cancelButtonTitle: String
    var confirmAction: () -> Void
    var cancelAction: () -> Void
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    var body: some View {
        VStack(spacing: 32) {
            Text(title)
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                .foregroundColor(appearance.colorPalette.messageListMessageTextReceived)
            
            Text(message)
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 14))
                .foregroundColor(Color(hex: "#454745"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Button(action: cancelAction) {
                    Text(cancelButtonTitle)
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                        .foregroundColor(Color(hex: "#163300"))
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.white)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color(hex: "#163300"), lineWidth: 1)
                        )
                }
                Button(action: confirmAction) {
                    Text(confirmButtonTitle)
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color(hex: "#FF3B30"))
                        .cornerRadius(24)
                }
            }
        }
        .padding()
        .background(Color.white)
        .padding(.horizontal, 0)
    }
}
