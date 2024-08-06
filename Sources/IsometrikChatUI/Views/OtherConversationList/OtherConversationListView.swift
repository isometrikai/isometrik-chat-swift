//
//  SwiftUIView.swift
//  
//
//  Created by Rasika Bharati on 06/08/24.
//

import SwiftUI
import IsometrikChat

protocol OtherConversationListViewDelegate{
    func navigateToMessageVc(selectedUserToNavigate : UserDB?,conversationId : String?)
}

struct OtherConversationListView : View {
    @StateObject var realmManager = RealmManager()
    var delegate: OtherConversationListViewDelegate?
    @State public var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State public var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State public var themeImage = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    
    var body: some View {
        NavigationView {
            ZStack{
                themeColor.chatListBackground.edgesIgnoringSafeArea(.all)
                VStack {
                    if realmManager.getOtherConversationCount() == 0{
                        Text("No other chats found!")
                    }else{
                        List{
                            ForEach(realmManager.getOtherConversation()){ data in
                                ZStack{
                                    VStack{
                                        Button {
                                            delegate?.navigateToMessageVc(selectedUserToNavigate: data.opponentDetails, conversationId: data.lastMessageDetails?.conversationId)
                                        } label: {
                                            ISMConversationSubView(chat: data, hasUnreadCount: (data.unreadMessagesCount) > 0)
                                        }.padding(.bottom,10)
                                        Divider()//.padding(.horizontal,15)
                                    }//.frame(height: 40)
                                }
                                //:ZStack
                            }//:FOREACH
                           
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                        .keyboardType(.default)
                        .textContentType(.oneTimeCode)
                        .autocorrectionDisabled(true)
//                        .refreshable {
//                            self.viewModel.resetdata()
//                            self.getConversationList()
//                        }
                        
                        
                        Text("Open a chat to get more info about who’s messaging you. They won’t know that you’ve seen it until you accept.")
                            .foregroundColor(Color(hex: "#FF4E00"))
                            .font(themeFonts.chatListUserMessage)
                            .padding(.horizontal,35)
                            .padding(.vertical,15)
                            .background(Color(hex: "#F5F5F5"))
                            .frame(maxWidth: .infinity)
                        
                    }
                }//:VStack
                .navigationBarHidden(true)
                .navigationBarTitleDisplayMode(.inline)
            }
        }//:NavigationView
        .navigationViewStyle(.stack)
        .onLoad{
           
        }
    }
}

