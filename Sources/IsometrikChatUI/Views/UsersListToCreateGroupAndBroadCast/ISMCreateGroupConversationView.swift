//
//  ISMCreateGroupConversationView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 18/07/23.
//

import SwiftUI
import IsometrikChat

public enum SelectUserFor: CaseIterable{
    case Group
    case BroadCast
    case AddMemberInBroadcast
}

public struct ISMCreateGroupConversationView: View {
    
    //MARK:  - PROPERTIES
    // Environment and binding properties for managing view state
    @Environment(\.dismiss) public var dismiss
    @Binding public var showSheetView : Bool
    @State public var image : UIImage?
    @State public var groupName = ""
    @State public var userSelected : [ISMChatUser] = []
    @ObservedObject public var viewModel = ConversationViewModel()
    @ObservedObject public var chatViewModel = ChatsViewModel()
    public var conversationId : String? = nil
    public var selectUserFor : SelectUserFor = .Group
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    public let groupCastId : String?
    @Binding public var groupCastIdToNavigate : String
    
    //MARK:  - BODY
    public var body: some View {
        NavigationStack{
            ZStack{
                VStack {
                    //                ScrollViewReader { proxy in
                    List {
                        // Display header if users are selected
                        if userSelected.count > 0 {
                            HeaderView()
                        }
                        // Iterate through user sections
                        ForEach(viewModel.usersSectionDictionary.keys.sorted(), id:\.self) { key in
                            // Filter contacts based on search text
                            if let contacts = viewModel.usersSectionDictionary[key]?.filter({ (contact) -> Bool in
                                self.viewModel.searchedText.isEmpty ? true :
                                "\(contact)".lowercased().contains(self.viewModel.searchedText.lowercased())}), !contacts.isEmpty{
                                Section(header: Text("\(key)")) {
                                    // Display each contact in the section
                                    ForEach(contacts){ value in
                                        ZStack{
                                            HStack(spacing:5){
                                                // User avatar and details
                                                //                                                UserAvatarView(avatar: value.userProfileImageUrl ?? "", showOnlineIndicator: value.online ?? false,size: CGSize(width: 40, height: 40), userName: value.userName ?? "",font: .regular(size: 14))
                                                VStack(alignment: .leading, spacing: 5, content: {
                                                    Text(value.userName ?? "User")
                                                        .font(appearance.fonts.messageListMessageText)
                                                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                                    Text(value.userIdentifier ?? "")
                                                        .font(appearance.fonts.chatListUserMessage)
                                                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                                        .lineLimit(2)
                                                })//:VStack
                                                
                                                Spacer()
                                                
                                                // Indicate if user is selected
                                                if userSelected.contains(where: { user in
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
                                            }//:HStack
                                            
                                            // Button to select/deselect user
                                            Button {
                                                userselectedHere(value: value)
                                            } label: {
                                            }
                                            
                                        }//:Zstack
                                        .onAppear {
                                            // Load more users if needed
                                            if viewModel.moreDataAvailableForGetUsers && viewModel.apiCalling == false{
                                                if self.viewModel.users.last?.userId == contacts.last?.userId {
                                                    self.getUsers()
                                                }
                                            }
                                        }// For LoadMore
                                    }
                                }
                            }
                        }
                    }//:LIST
                    // Additional UI configurations
                    .listStyle(DefaultListStyle())
                    .navigationBarBackButtonHidden(true)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            VStack {
                                // Set navigation title based on user selection type
                                if selectUserFor == .Group{
                                    Text("Add Members")
                                        .font(appearance.fonts.navigationBarTitle)
                                        .foregroundColor(appearance.colorPalette.navigationBarTitle)
                                }else{
                                    Text("Recipients")
                                        .font(appearance.fonts.navigationBarTitle)
                                        .foregroundColor(appearance.colorPalette.navigationBarTitle)
                                }
                            }
                        }
                    }
                    .navigationBarItems(leading: navBarLeadingBtn, trailing: navBarTrailingBtn)
                    //                }
                }//:VStack
                .onLoad {
                    // Reset and fetch users on appear
                    self.viewModel.resetGetUsersdata()
                    getUsers()
                }
                .refreshable {
                    refreshUsers()
                }
                .searchable(text: $viewModel.searchedText, placement: .navigationBarDrawer(displayMode: .always))
                .onChange(of: viewModel.debounceSearchedText, { _, _ in
                    // Handle search text changes
                    print("~~SEARCHING WITH DEBOUNCING \(viewModel.searchedText)")
                    self.viewModel.resetGetUsersdata()
                    getUsers()
                })
                .onDisappear {
                    // Clear search text on disappear
                    viewModel.searchedText = ""
                    viewModel.debounceSearchedText = ""
                }
            }
        }
    }
    
    //MARK:  - CONFIGURE
    
    // Function to select or deselect a user
    func userselectedHere(value : ISMChatUser){
        if userSelected.contains(where: { user in
            user.id == value.id
        }){
            userSelected.removeAll(where: { $0.id == value.id })
        }else{
            userSelected.append(value)
        }
        viewModel.searchedText = ""
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
    
    // Function to create the header view for selected users
    func HeaderView() -> some View{
        HStack(alignment: .top){
            ScrollViewReader { reader in  // read scroll position and scroll to
                ScrollView(.horizontal,showsIndicators: false) {
                    LazyHStack(alignment: .top){
                        ForEach(userSelected) { user in
                            ZStack{
                                VStack(spacing: 3){
                                    ZStack(alignment: .topTrailing) {
                                        UserAvatarView(avatar: user.userProfileImageUrl ?? "", showOnlineIndicator: false, size: CGSize(width: 48, height: 48), userName:  user.userName ?? "",font: .regular(size: 14))
                                        appearance.images.removeUserFromSelectedFromList
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    }
                                    
                                    Text(user.userName ?? "")
                                        .font(appearance.fonts.chatListUserMessage)
                                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                        .lineLimit(2)
                                }.onTapGesture {
                                    // Remove user from selection on tap
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
                } 
                .onChange(of: userSelected.count, { _, _ in
                    withAnimation {  // add animation for scroll to top
                        reader.scrollTo(userSelected.last?.id, anchor: .center) // scroll
                    }
                })
            }
        }.padding(.vertical,5)
    }
    
    // Navigation button for proceeding to the next step
    var navBarTrailingBtn: some View {
        VStack{
            ZStack{
                if userSelected.count > 0{
                    if selectUserFor == .Group{
                        NavigationLink {
                            ISMGroupCreate(showSheetView: self.$showSheetView, userSelected: self.$userSelected,viewModel: self.viewModel, chatViewModel: self.chatViewModel)
                        } label: {
                            Text("Next")
                                .font(appearance.fonts.messageListMessageText)
                                .foregroundColor(userSelected.count > 0 ? appearance.colorPalette.userProfileEditText: .gray)
                        }
                    }else if selectUserFor == .AddMemberInBroadcast{
                        Button {
                            chatViewModel.addMemberInBroadCast(members: userSelected, groupcastId: self.groupCastId ?? "") { _ in
                                ISMChatHelper.print("success")
                                dismiss()
                            }
                        } label: {
                            Text("Next")
                                .font(appearance.fonts.messageListMessageText)
                                .foregroundColor(userSelected.count > 0 ? appearance.colorPalette.userProfileEditText: .gray)
                        }
                    }else{
                        Button {
                            // Create broadcast with selected users
                            chatViewModel.createBroadCast(users: self.userSelected) { data in
                                if let groupcastId = data?.groupcastId{
                                    groupCastIdToNavigate = groupcastId
                                    showSheetView = false
                                }
                            }
                            
                        } label: {
                            Text("Create")
                                .font(appearance.fonts.messageListMessageText)
                                .foregroundColor(userSelected.count > 0 ? appearance.colorPalette.userProfileEditText: .gray)
                        }
                    }
                }
            }
        }
    }
    
    // Navigation button for going back
    var navBarLeadingBtn: some View {
        Button(action: { dismiss() }) {
            appearance.images.backButton
                .resizable()
                .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
        }
    }
    
    // Function to get users based on the selected type
    func getUsers(){
        viewModel.apiCalling = true
        if selectUserFor == .AddMemberInBroadcast{
            viewModel.getBroadCastEligibleUsers(groupCastId : self.groupCastId ?? "",search: viewModel.searchedText) { data in
                viewModel.apiCalling = false
                viewModel.users.append(contentsOf: data?.groupcastEligibleMembers ?? [])
                viewModel.usersSectionDictionary = viewModel.getSectionedDictionary(data: viewModel.users)
            }
        }else{
            viewModel.getUsers(search: viewModel.searchedText) { data in
                viewModel.apiCalling = false
                viewModel.users.append(contentsOf: data?.users ?? [])
                viewModel.usersSectionDictionary = viewModel.getSectionedDictionary(data: viewModel.users)
            }
        }
    }
    
    // Function to refresh the user list
    func refreshUsers(){
        self.viewModel.resetGetUsersdata()
        viewModel.refreshGetUser() { users in
            if let appendUser = users?.users{
                viewModel.users.append(contentsOf: appendUser)
                viewModel.usersSectionDictionary = viewModel.getSectionedDictionary(data: viewModel.users)
            }
        }
    }
}

