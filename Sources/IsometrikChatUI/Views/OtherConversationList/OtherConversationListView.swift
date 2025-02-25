//
//  SwiftUIView.swift
//  
//
//  Created by Rasika Bharati on 06/08/24.
//

import SwiftUI
import IsometrikChat

//public protocol OtherConversationListViewDelegate{
//    func navigateToMessageVc(selectedUserToNavigate : UserDB?,conversationId : String?)
//}

//public struct OtherConversationListView : View {
//    // StateObject to manage realm data
//    @StateObject public var realmManager = RealmManager.shared
//    // Delegate for navigation actions
//    public var delegate: OtherConversationListViewDelegate?
//    // Appearance settings for the chat UI
//    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
//    
//    public var body: some View {
//        NavigationStack {
//            ZStack {
//                // Set background color for the chat list
//                appearance.colorPalette.chatListBackground.edgesIgnoringSafeArea(.all)
//                VStack {
//                    // Check if there are any other conversations
//                    if realmManager.getOtherConversationCount() == 0 {
//                        // Display custom placeholder if enabled
//                        if ISMChatSdkUI.getInstance().getChatProperties().showCustomPlaceholder == true {
//                            appearance.placeholders.otherchatListPlaceholder
//                        } else {
//                            // Default message when no chats are found
//                            Text("No other chats found!")
//                        }
//                    } else {
//                        // Display the list of conversations
//                        List {
//                            ForEach(realmManager.getOtherConversation()) { data in
//                                ZStack {
//                                    VStack {
//                                        // Button to navigate to the message view
//                                        Button {
//                                            delegate?.navigateToMessageVc(selectedUserToNavigate: data.opponentDetails, conversationId: data.lastMessageDetails?.conversationId)
//                                        } label: {
//                                            // Subview for displaying conversation details
//                                            ISMConversationSubView(chat: data, hasUnreadCount: (data.unreadMessagesCount) > 0)
//                                        }
//                                        .padding(.bottom, 10)
//                                        Divider() // Divider between conversations
//                                    }
//                                }
//                            } // End of ForEach
//                            .listRowBackground(Color.clear) // Clear background for list rows
//                            .listRowSeparator(.hidden) // Hide row separators
//                        }
//                        .listStyle(.plain) // Set list style
//                        .keyboardType(.default) // Default keyboard type
//                        .textContentType(.oneTimeCode) // Set text content type
//                        .autocorrectionDisabled(true) // Disable autocorrection
//                        
//                        // Instruction text for users
//                        Text("Open a chat to get more info about who's messaging you. They won't know that you've seen it until you accept.")
//                            .foregroundColor(Color(hex: "#FF4E00")) // Set text color
//                            .font(appearance.fonts.chatListUserMessage) // Set font style
//                            .padding(.horizontal, 35) // Horizontal padding
//                            .padding(.vertical, 15) // Vertical padding
//                            .background(Color(hex: "#F5F5F5")) // Background color
//                            .frame(maxWidth: .infinity) // Full width frame
//                    }
//                } // End of VStack
//                .navigationBarHidden(true) // Hide navigation bar
//                .navigationBarTitleDisplayMode(.inline) // Set title display mode
//            } // End of ZStack
//        } // End of NavigationStack
//        .navigationViewStyle(.stack) // Set navigation view style
//        .onLoad {
//            // Load additional data or perform actions on view load
//        }
//    }
//}

