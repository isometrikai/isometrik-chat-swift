//
//  ISMAddParticipants.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 18/09/23.
//

import SwiftUI
import IsometrikChat

/// A view that displays a list of users that can be added as participants to a group conversation
struct ISMAddParticipantsView: View {
    
    //MARK: - PROPERTIES
    @Environment(\.dismiss) var dismiss
    
    /// Array of selected users to be added to the group
    @State private var userSelected : [ISMChatUser] = []
    /// View model handling conversation-related operations
    @ObservedObject var viewModel = ConversationViewModel()
    /// View model handling chat-related operations
    @ObservedObject var chatViewModel = ChatsViewModel()
    /// ID of the existing conversation if adding members to an existing group
    var conversationId : String? = nil
    @EnvironmentObject var realmManager : RealmManager
    /// UI appearance configuration
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    //MARK: - BODY
    var body: some View {
        ZStack{
            VStack {
                ScrollViewReader { proxy in
                    List {
                        if userSelected.count > 0{
                            HeaderView()
                        }
                        ForEach(viewModel.elogibleUsersSectionDictionary.keys.sorted(), id:\.self) { key in
                            if let contacts = viewModel.elogibleUsersSectionDictionary[key]?.filter({ contact in
                                self.viewModel.searchedText.isEmpty ? true : "\(contact)".lowercased().contains(self.viewModel.searchedText.lowercased())
                            }), !contacts.isEmpty {
                                Section(header: Text("\(key)")) {
                                    ForEach(contacts){ value in
                                        participantsSubView(value: value)
                                            .onAppear {
                                                if viewModel.moreDataAvailableForGetUsers && viewModel.apiCalling == false{
                                                    if self.viewModel.eligibleUsers.last?.userId == value.userId {
                                                        self.getUsers()
                                                    }
                                                }
                                            }// For LoadMore
                                    }
                                }
                            }
                        }
                    }//:LIST
                    .searchable(text:  $viewModel.searchedText, placement: .navigationBarDrawer(displayMode: .always)) {}
                    .navigationBarBackButtonHidden(true)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            VStack {
                                Text("Add members")
                                    .font(appearance.fonts.navigationBarTitle)
                                    .foregroundColor(appearance.colorPalette.navigationBarTitle)
                            }
                        }
                    }
                    .navigationBarItems(leading: navBarLeadingBtn,trailing: navBarTrailingBtn)
                }
            }//:VStack
            .onChange(of: viewModel.debounceSearchedText){ 
                print("~~SEARCHING WITH DEBOUNCING \(viewModel.searchedText)")
                self.viewModel.resetEligibleUsersdata()
                getUsers()
            }
            .onDisappear {
                viewModel.searchedText = ""
                viewModel.debounceSearchedText = ""
            }
            .onAppear {
                self.viewModel.resetEligibleUsersdata()
                getUsers()
            }
            if chatViewModel.isBusy{
                //Custom Progress View
                ActivityIndicatorView(isPresented: $chatViewModel.isBusy)
            }
        }
    }
    
    
    //MARK:  - CONFIGURE
    
    /// Creates a cell view for each participant in the list
    /// - Parameter value: User object containing participant details
    func participantsSubView(value : ISMChatUser) -> some View{
        ZStack{
            HStack(alignment: .center, spacing:20){
                UserAvatarView(avatar: value.userProfileImageUrl ?? "", showOnlineIndicator: value.online ?? false,size: CGSize(width: 29, height: 29), userName : value.userName ?? "",font: .regular(size: 12))
                VStack(alignment: .leading, spacing: 5, content: {
                    Text(value.userName ?? "User")
                        .font(appearance.fonts.messageListMessageText)
                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                    if ISMChatSdk.getInstance().getFramework() == .SwiftUI{
                        Text(value.userIdentifier ?? "")
                            .font(appearance.fonts.chatListUserMessage)
                            .foregroundColor(appearance.colorPalette.chatListUserMessage)
                            .lineLimit(2)
                    }
                    
                })//:VStack
                Spacer()
                
                if userSelected.contains(where: { user in
                    user.id == value.id
                }) {
                    appearance.images.selected
                        .resizable()
                        .frame(width: 20, height: 20)
                }else{
                    appearance.images.deselected
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }//:HStack
            Button {
                if userSelected.contains(where: { user in
                    user.id == value.id
                }){
                    userSelected.removeAll(where: { $0.id == value.id })
                }else{
                    userSelected.append(value)
                }
            } label: {
                
            }
            
        }//:Zstack
    }
    
    
    /// Creates a horizontal scrollable header showing selected users
    func HeaderView() -> some View{
        HStack(alignment: .top){
            ScrollViewReader { reader in  // read scroll position and scroll to
                ScrollView(.horizontal,showsIndicators: false) {
                    LazyHStack(alignment: .top){
                        ForEach(userSelected) { user in
                            ZStack{
                                VStack(spacing: 3){
                                    ZStack(alignment: .topTrailing) {
                                        UserAvatarView(avatar: user.userProfileImageUrl ?? "", showOnlineIndicator: false, size: CGSize(width: 48, height: 48), userName:  user.userName ?? "",font: .regular(size: 20))
                                        appearance.images.removeUserFromSelectedFromList
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    }
                                    
                                    Text(user.userName ?? "")
                                        .font(appearance.fonts.chatListUserMessage)
                                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                        .lineLimit(2)
                                }.onTapGesture {
                                    if userSelected.contains(where: { user1 in
                                        user1.id == user.id
                                    }){
                                        userSelected.removeAll(where: { $0.id == user.id })
                                    }
                                }
                            }.frame(width: 60)
                                .id(user.id)
                        }
                    }
                } .onChange(of: userSelected.count, { _, _ in
                    withAnimation {  // add animation for scroll to top
                        reader.scrollTo(userSelected.last?.id, anchor: .center) // scroll
                    }
                })
            }
        }.padding(.vertical,5)
    }
    
    /// Handles adding selected participants to the group
    /// If conversationId exists, adds members to existing group
    /// Otherwise creates a new group with selected members
    func addParticipant(){
        let member = userSelected.map { $0.id }
        
        if let conversationId = conversationId {
            chatViewModel.addMembersInAlredyExistingGroup(members: member, conversationId: conversationId) { data in
                // Update local database member count
                realmManager.updateMemberCount(convId: conversationId, inc: true, dec: false, count: 1)
                // Notify observers about member changes
                NotificationCenter.default.post(name: NSNotification.memberAddAndRemove,object: nil)
                self.dismiss()
            }
        }
    }
    
    var navBarLeadingBtn : some View{
        Button(action: { dismiss() }) {
            appearance.images.backButton
                .resizable()
                .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
        }
    }
    
    var navBarTrailingBtn: some View {
        VStack{
            Button(action: {
                addParticipant()
            }) {
                Text("Add")
                    .font(appearance.fonts.messageListMessageText)
                    .foregroundColor(userSelected.count == 0 ? Color.gray : appearance.colorPalette.userProfileEditText)
            }.disabled(userSelected.count == 0)
        }
    }
    
    func sectionIndexTitles(proxy: ScrollViewProxy) -> some View {
        SectionIndexTitles(proxy: proxy, titles: viewModel.elogibleUsersSectionDictionary.keys.sorted())
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
    }
    
    /// Fetches eligible users that can be added to the group
    /// - Handles pagination through viewModel.moreDataAvailableForGetUsers
    /// - Updates viewModel.eligibleUsers with fetched results
    func getUsers(){
        viewModel.apiCalling = true
        viewModel.getEligibleUsers(search: viewModel.searchedText, conversationId: self.conversationId ?? "") {  data in
            viewModel.apiCalling = false
        }
    }
}
