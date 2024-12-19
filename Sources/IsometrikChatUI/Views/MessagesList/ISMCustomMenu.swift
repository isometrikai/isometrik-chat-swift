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
                        .foregroundColor(.red)
                    Text("Clear chat")
                        .foregroundColor(.black)
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding()
            }
            // Block User Button
            Button(action: blockUserAction) {
                HStack(spacing: 12) {
                    appearance.images.contextBlockUser
                        .foregroundColor(.gray)
                    Text("Block user")
                        .foregroundColor(.black)
                        .fontWeight(.medium)
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
    var message: String
    var confirmButtonTitle: String
    var cancelButtonTitle: String
    var confirmAction: () -> Void
    var cancelAction: () -> Void
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Button(action: cancelAction) {
                    Text(cancelButtonTitle)
                        .font(appearance.fonts.alertText)
                        .foregroundColor(appearance.colorPalette.cancelButton)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.white)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(appearance.colorPalette.cancelButton, lineWidth: 1)
                        )
                }
                Button(action: confirmAction) {
                    Text(confirmButtonTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(appearance.colorPalette.confirmButton)
                        .cornerRadius(24)
                }
            }
        }
        .padding()
        .background(Color.white)
        .padding(.horizontal, 0)
    }
}
