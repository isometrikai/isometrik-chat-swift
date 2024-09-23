//
//  SwiftUIView.swift
//  
//
//  Created by Rasika Bharati on 06/08/24.
//

import SwiftUI
import IsometrikChat

public protocol OtherConversationListViewDelegate{
    func navigateToMessageVc(selectedUserToNavigate : UserDB?,conversationId : String?)
}

public struct OtherConversationListView : View {
    @StateObject public var realmManager = RealmManager()
    public var delegate: OtherConversationListViewDelegate?
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    public var body: some View {
        NavigationStack {
            ZStack{
                appearance.colorPalette.chatListBackground.edgesIgnoringSafeArea(.all)
                VStack {
                    if realmManager.getOtherConversationCount() == 0{
                        if ISMChatSdkUI.getInstance().getChatProperties().showCustomPlaceholder == true{
                            appearance.placeholders.otherchatListPlaceholder
                        }else{
                            Text("No other chats found!")
                        }
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
                            .font(appearance.fonts.chatListUserMessage)
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

