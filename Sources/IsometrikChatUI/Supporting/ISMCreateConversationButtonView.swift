//
//  ISMCreateConversationButtonView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 04/07/23.
//

import SwiftUI
import IsometrikChat

struct ISMCreateConversationButtonView: View {
    
    //MARK: - PROPERTIES
    
    /// Controls navigation state to the conversation view
    @Binding var navigate: Bool
    
    /// Controls visibility of the offline alert popup
    @Binding var showOfflinePopUp: Bool
    
    /// Monitors network connectivity status
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    /// UI appearance configuration from the SDK
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    //MARK: - BODY
    
    /// The main view layout
    /// Displays a floating action button in the bottom-right corner that:
    /// - Shows offline popup when there's no internet connection
    /// - Triggers navigation to create conversation when online
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    // Check network connectivity before proceeding
                    if !networkMonitor.isConnected {
                        // Show offline popup if no internet connection
                        showOfflinePopUp = true
                    } else {
                        // Trigger navigation when online
                        navigate = true
                    }
                }, label: {
                    // Display add conversation button using configured appearance
                    appearance.images.addConversation
                        .resizable()
                        .frame(width: 58, height: 58)
                })
                .padding()
            }
        }
    }
}
