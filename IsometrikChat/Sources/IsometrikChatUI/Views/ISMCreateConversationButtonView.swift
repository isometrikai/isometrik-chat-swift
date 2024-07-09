//
//  ISMCreateConversationButtonView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 04/07/23.
//

import SwiftUI
import IsometrikChat

struct ISMCreateConversationButtonView: View {
    
    //MARK:  - PROPERTIES
    
    @Binding var navigate : Bool
    @Binding var showOfflinePopUp : Bool
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var themeImage = ISMChatSdk.getInstance().getAppAppearance().appearance.images
    
    //MARK:  - BODY
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    if !networkMonitor.isConnected {
                        showOfflinePopUp = true
                    }else{
                        navigate = true
                    }
                }, label: {
                    themeImage.addConversation
                        .resizable()
                        .frame(width: 58, height: 58)
                })
                .padding()
            }
        }
    }
}
