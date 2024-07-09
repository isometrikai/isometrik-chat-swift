//
//  ISM_ForwardToContact.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 20/03/23.
//

import SwiftUI
import IsometrikChat

struct ISMForwardToContactView: View {
    
    //MARK: - PROPERTIES
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @State var selections: [ISMChat_User] = []
    @State var showSendView = false
    var viewModel = ChatsViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @ObservedObject var conversationViewModel = ConversationViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @Binding var messages : [MessagesDB]
    @State var selectedUser : [String] = []
    @Binding var showforwardMultipleMessage : Bool
    @State var showAlertFormoreThan5 : Bool = false
    @State var themeFonts = ISMChatSdk.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdk.getInstance().getAppAppearance().appearance.colorPalette
    @State var themeImage = ISMChatSdk.getInstance().getAppAppearance().appearance.images
    
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
                                                    .font(themeFonts.messageList_MessageText)
                                                    .foregroundColor(themeColor.messageList_MessageText)
                                                    .lineLimit(nil)
                                                
                                                Text(value.userIdentifier ?? "")
                                                    .font(themeFonts.chatList_UserMessage)
                                                    .foregroundColor(themeColor.chatList_UserMessage)
                                            }
                                            Spacer()
                                            
                                            if selections.contains(where: { user in
                                                user.id == value.id
                                            }){
                                                themeImage.selected
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                            }else{
                                                themeImage.deselected
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
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Send To")
                                .font(themeFonts.navigationBar_Title)
                                .foregroundColor(themeColor.navigationBar_Title)
                        }
                    }
                }
                
                //bottomView
                if selections.count > 0{
                    HStack(alignment: .center){
                        ScrollView(.horizontal) {
                            Text(selectedUser.joined(separator: ", "))
                                .font(themeFonts.messageList_MessageText)
                                .foregroundColor(themeColor.messageList_MessageText)
                                .id("combinedText")
                            
                            .padding()
                        }
                        Spacer()
                        Button(action : {forwardMsg()}) {
                            Text("Forward")
                                .font(themeFonts.messageList_ReplyToolbarHeader)
                                .foregroundStyle(themeColor.userProfile_editText)
                            
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
        .onChange(of: conversationViewModel.debounceSearchedText, perform: { newValue in
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


//MARK: - TOOLBAR
private extension ISMForwardToContactView{
    func ToolBarView() -> some View{
        VStack{
            Spacer()
            
        }
    }
}

//MARK: - FORWARD MESSAGE
private extension ISMForwardToContactView{
    func forwardMsg() {
        guard !selections.isEmpty else {
            return
        }
        
        let userIds = selections.compactMap({ $0.userId })
        var newConversationId : [String] = []
        
        // Define a counter to keep track of conversations created
        var conversationsCreatedCount = 0
        
        DispatchQueue.global(qos: .userInitiated).async {
            for newUserId in userIds {
                viewModel.createConversation(userId: newUserId) { data in
                    guard let conversationId = data?.conversationId else {
                        return
                    }
                    
                    // Increment the counter when a conversation is created
                    conversationsCreatedCount += 1
                    newConversationId.append(conversationId)
                    
                    // Check if all conversations are created
                    if conversationsCreatedCount == userIds.count {
                        // All conversations are created, so print your string here
                        print("All conversations are created!")
                        for singleMessage in messages{
                            viewModel.forwardMessage(conversationIds: newConversationId,
                                                     message: singleMessage.body ,
                                                     attachments: singleMessage.attachments.first,customType: singleMessage.customType,placeName: singleMessage.metaData?.locationAddress,metaData: singleMessage.metaData ?? nil) {
                                ISMChat_Helper.print("Message Forwarded")
                                NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                            }
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                showforwardMultipleMessage = false
                self.mode.wrappedValue.dismiss()
            }
        }
    }
}
