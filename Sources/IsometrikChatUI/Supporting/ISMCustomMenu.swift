//
//  CustomMenuView.swift
//  IsometrikChat
//
//  Created by My Book on 17/12/24.
//


import SwiftUI

/// A custom menu view that provides options for chat management
/// This view contains buttons for clearing chat history and blocking users
struct ISMCustomMenu: View {
    // MARK: - Properties
    
    /// Closure to handle clearing chat history
    var clearChatAction: () -> Void
    
    /// Closure to handle blocking a user
    var blockUserAction: () -> Void
    
    /// UI appearance configuration from the SDK
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    // MARK: - Body
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

/// Defines the types of popups available in the application
enum PopUpType: CaseIterable {
    /// Standard menu popup
    case Menu
    /// Delete confirmation popup
    case Delete
}

/// A customizable confirmation popup view
/// Used for displaying confirmations and alerts to the user
struct ConfirmationPopup: View {
    // MARK: - Properties
    
    /// The title displayed at the top of the popup
    var title: String
    
    /// The main message content of the popup
    var message: AttributedString
    
    /// Text for the confirm button
    var confirmButtonTitle: String
    
    /// Text for the cancel button
    var cancelButtonTitle: String
    
    /// Action to perform when confirm is pressed
    var confirmAction: () -> Void
    
    /// Action to perform when cancel is pressed
    var cancelAction: () -> Void
    
    /// Type of popup to display (affects styling)
    var popUpType: PopUpType
    
    /// UI appearance configuration from the SDK
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    /// Binding to control the popup's visibility
    @Binding var isPresented: Bool
    
    /// Determines if the dismiss button should be shown
    var showCrossButton: Bool
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 32) {
            HStack{
                if showCrossButton == true{
                    Button {
                        isPresented = false
                    } label: {
                        appearance.images.dismissButton
                            .resizable()
                            .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
                    }
                }else{
                    Image("")
                        .resizable()
                        .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
                }
                
                Spacer()
                
                Text(title)
                    .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                    .foregroundColor(appearance.colorPalette.messageListMessageTextReceived)
                
                Spacer()
                
                Image("")
                    .resizable()
                    .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
            }
            
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
                        .foregroundColor(popUpType == .Delete ? Color(hex: "#163300") : Color.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(popUpType == .Delete ? Color.white : Color(hex: "#FF3B30"))
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(popUpType == .Delete ? Color(hex: "#163300") : Color(hex: "#FF3B30"), lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(Color.white)
        .padding(.horizontal, 0)
    }
}
