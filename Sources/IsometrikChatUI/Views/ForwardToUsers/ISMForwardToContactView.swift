//
//  ISMForwardToContact.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 20/03/23.
//

import SwiftUI
import IsometrikChat

/// A view that allows users to forward messages to one or more contacts
/// Supports selecting up to 5 contacts and handles message forwarding with attachments
struct ISMForwardToContactView: View {
    
    //MARK: - PROPERTIES
    /// Environment variable to dismiss the view
    @Environment(\.dismiss) var dismiss
    
    /// Array of selected users to forward messages to
    @State var selections: [ISMChatUser] = []
    
    /// View model instances for chat and conversation management
    var viewModel = ChatsViewModel()
    @ObservedObject var conversationViewModel = ConversationViewModel()
    
    /// Messages to be forwarded
    @Binding var messages: [MessagesDB]
    
    /// Array of selected usernames for display
    @State var selectedUser: [String] = []
    
    /// Controls visibility of the forward message view
    @Binding var showforwardMultipleMessage: Bool
    
    /// Alert state for when user tries to select more than 5 contacts
    @State var showAlertFormoreThan5: Bool = false
    
    /// UI appearance configuration
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    //MARK:  - LIFECYCLE
    var body: some View {
        ZStack{
            VStack{
                List{
                    ForEach(conversationViewModel.usersSectionDictionary.keys.sorted(), id:\.self) { key in
                        if let contacts = conversationViewModel.usersSectionDictionary[key]?.filter({ (contact) -> Bool in
                            self.conversationViewModel.searchedText.isEmpty ? true :
                            "\(contact)".lowercased().contains(self.conversationViewModel.searchedText.lowercased())}), !contacts.isEmpty{
                            Section(header: Text("\(key)")) {
                                ForEach(contacts){ value in
                                    ZStack{
                                        HStack(spacing: 5){
                                            UserAvatarView(avatar: value.userProfileImageUrl ?? "", showOnlineIndicator: value.online ?? false,size: CGSize(width: 29, height: 29), userName: value.userName ?? "",font: .regular(size: 12))
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(value.userName ?? "")
                                                    .font(appearance.fonts.messageListMessageText)
                                                    .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                                    .lineLimit(nil)
                                                
//                                                Text(value.userIdentifier ?? "")
//                                                    .font(themeFonts.chatListUserMessage)
//                                                    .foregroundColor(themeColor.chatListUserMessage)
                                            }
                                            Spacer()
                                            
                                            if selections.contains(where: { user in
                                                user.id == value.id
                                            }){
                                                appearance.images.selected
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                            }else{
                                                appearance.images.deselected
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                            }
                                        }
                                        
                                        
                                        Button {
                                            if let index = self.selections.firstIndex(where: { $0.id == value.id }) {
                                                self.selections.remove(at: index)
                                                selectedUser.removeAll(where: { $0 == value.userName })
                                            } else {
                                                if selections.count < 5{
                                                    self.selections.append(value)
                                                    selectedUser.append(value.userName ?? "")
                                                }else{
                                                    showAlertFormoreThan5 = true
                                                }
                                            }
                                        } label: {
                                            
                                        }
                                        
                            
                                        
                                        
                                    }//:ZStack
                                    .onAppear {
                                        if conversationViewModel.moreDataAvailableForGetUsers && conversationViewModel.apiCalling == false {
                                            if value.userId == contacts.last?.userId {
                                                self.getUsers()
                                            }
                                        }
                                    }// For LoadMore
                                }
                            }
                        }
                    }
                }//:LIST
                .listRowSeparatorTint(Color.border)
                .listStyle(DefaultListStyle())
                .background(Color.listBackground)
                .scrollContentBackground(.hidden)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Send To")
                                .font(appearance.fonts.navigationBarTitle)
                                .foregroundColor(appearance.colorPalette.navigationBarTitle)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            self.messages.removeAll()
                            dismiss()
                        }) {
                            appearance.images.backButton
                                .resizable()
                                .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
                        }
                    }
                }
                
                //bottomView
                if selections.count > 0{
                    HStack(alignment: .center){
                        ScrollView(.horizontal) {
                            Text(selectedUser.joined(separator: ", "))
                                .font(appearance.fonts.messageListMessageText)
                                .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                .id("combinedText")
                            
                            .padding()
                        }
                        Spacer()
                        Button(action : {forwardMsg()}) {
                            Text("Forward")
                                .font(appearance.fonts.messageListReplyToolbarHeader)
                                .foregroundStyle(appearance.colorPalette.userProfileEditText)
                            
                            .padding()
                        }//:BUTTON
                    }//:HSTACK
                    .frame(height: 50)
                    .background(.white)
                }
            }//:VSTACK
            .onAppear {
                self.conversationViewModel.resetGetUsersdata()
                getUsers()
            }
            
            if showAlertFormoreThan5 == true{
                Text("You can only share with up to 5 chats.")
                    .font(Font.caption)
                    .padding()
                    .background(.black.opacity(0.4))
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showAlertFormoreThan5 = false
                        }
                    }
            }
        }//:ZSTACK
        .searchable(text: $conversationViewModel.searchedText, placement: .navigationBarDrawer(displayMode: .always))
        .onChange(of: conversationViewModel.debounceSearchedText, { _, _ in
            print("~~SEARCHING WITH DEBOUNCING \(conversationViewModel.searchedText)")
            self.conversationViewModel.resetGetUsersdata()
            getUsers()
        })
        .onDisappear {
            conversationViewModel.searchedText = ""
            conversationViewModel.debounceSearchedText = ""
        }
    }
    
    //MARK: - CONFIGURE
    
    func getUsers(){
        conversationViewModel.getUsers(search: conversationViewModel.searchedText) { data in
            conversationViewModel.users.append(contentsOf: data?.users ?? [])
            conversationViewModel.usersSectionDictionary = conversationViewModel.getSectionedDictionary(data: conversationViewModel.users)
        }
    }
    
    func createConversation(user: String, completion: @escaping (String) -> Void) {
        if let conversation = conversationViewModel.conversations.first(where: { data in
            data.opponentDetails?.userId == user
        }) {
            if let conversationId = conversation.lastMessageDetails?.conversationId {
                completion(conversationId)
            }
        }
    }
}

/// Extension for handling toolbar-related views
private extension ISMForwardToContactView {
    func ToolBarView() -> some View {
        VStack{
            Spacer()
            
        }
    }
}

//MARK: - FORWARD MESSAGE
private extension ISMForwardToContactView {
    /// Handles the forwarding of messages to selected contacts
    /// Process:
    /// 1. Creates new conversations with selected users if they don't exist
    /// 2. Forwards all selected messages to each conversation
    /// 3. Uses dispatch groups to handle async operations
    /// 4. Updates UI and dismisses view when complete
    func forwardMsg() {
        // Input validation
        guard !selections.isEmpty else {
            return
        }
        
        // Track new conversation IDs
        var newConversationIds: [String] = []

        DispatchQueue.global(qos: .userInitiated).async {
            let conversationGroup = DispatchGroup()

            for newUser in selections {
                conversationGroup.enter()
                let user = ISMChatUserDB(userId: newUser.userId ?? "", userProfileImageUrl: newUser.userProfileImageUrl ?? "", userName: newUser.userName ?? "", userIdentifier: newUser.userIdentifier ?? "", online: newUser.online ?? false, lastSeen: newUser.lastSeen ?? 0, metaData: ISMChatUserMetaDataDB(userId: newUser.metaData?.userId ?? "", userType: newUser.metaData?.userType ?? 0, isStarUser: newUser.metaData?.isStarUser ?? false, userTypeString: newUser.metaData?.userTypeString ?? ""))

                viewModel.createConversation(user: user) { data,_  in
                    guard let conversationId = data?.conversationId else {
                        conversationGroup.leave()
                        return
                    }

                    newConversationIds.append(conversationId)
                    conversationGroup.leave()
                }
            }

            conversationGroup.notify(queue: .main) {
                guard !newConversationIds.isEmpty else {
                    showforwardMultipleMessage = false
                    dismiss()
                    print("No conversations created.")
                    return
                }

                let messageGroup = DispatchGroup()

                for singleMessage in messages {
                    for conversationId in newConversationIds {
                        messageGroup.enter()
                        viewModel.forwardMessage(conversationIds: [conversationId],
                                                 message: singleMessage.body,
                                                 attachments: singleMessage.customType == ISMChatMediaType.Text.value ? nil : singleMessage.attachments.first,
                                                 customType: singleMessage.customType,
                                                 placeName: singleMessage.metaData?.locationAddress,
                                                 metaData: singleMessage.metaData ?? nil) {
                            ISMChatHelper.print("Message Forwarded")
                            NotificationCenter.default.post(name: NSNotification.refreshConvList, object: nil)
                            messageGroup.leave()
                        }
                    }
                }

                messageGroup.notify(queue: .main) {
                    showforwardMultipleMessage = false
                    self.messages.removeAll()
                    dismiss()
                    print("All messages forwarded and view dismissed!")
                }
            }
        }
    }
}
