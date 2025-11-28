//
//  ISMUsersView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 13/04/23.
//

import SwiftUI
import Combine
import IsometrikChat


public struct ISMUsersView: View {
    
    //MARK:  - PROPERTIES
    // Environment dismiss action to close the view
    @Environment(\.dismiss) public var dismiss
    
    // Observed object for managing conversation data
    @ObservedObject public var viewModel = ConversationViewModel()
    
    // Binding properties for selected user and conversation ID
    @Binding public var selectedUser : UserDB
    @Binding public var selectedUserconversationId : String

    // State for creating a conversation response
    @State public var createconversation : ISMChatCreateConversationResponse?
   
    // State flags to show group and broadcast options based on chat properties
    @State public var showGroupOption = ISMChatSdkUI.getInstance().getChatProperties().conversationType.contains(.GroupConversation)
    @State public var showBroadCastOption = ISMChatSdkUI.getInstance().getChatProperties().conversationType.contains(.BroadCastConversation)
    
    // Environment object for managing Realm database
    @EnvironmentObject public var realmManager : RealmManager
    // State flags for navigation to create group or broadcast
    @State public var navigatetoCreatGroup : Bool = false
    @State public var navigatetoCreatBroadCast : Bool = false
    // Appearance settings for the chat UI
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @Binding public var groupCastIdToNavigate : String
    
    // Track if view has initially appeared to avoid resetting data when navigating back
    @State private var hasInitiallyAppeared = false
    
    //MARK:  - LIFECYCLE
    public var body: some View {
        ZStack{
            NavigationStack{
                VStack {
                    // Show a loading indicator if no users are available and we're currently fetching or on initial load
                    if viewModel.users.isEmpty && (viewModel.apiCalling || !hasInitiallyAppeared) {
                        ProgressView()
                    } else if !viewModel.users.isEmpty {
                        ScrollViewReader { proxy in
                            List {
                                // Display options for creating new group or broadcast if available
                                if showGroupOption == true || showBroadCastOption == true {
                                    Section {
                                        // Button to create a new group
                                        if showGroupOption {
                                            Button {
                                                navigatetoCreatGroup = true
                                            } label: {
                                                HStack{
                                                    Text("New Group")
                                                        .font(appearance.fonts.messageListMessageText)
                                                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                                    Spacer()
                                                    appearance.images.groupMembers
                                                        .resizable()
                                                        .frame(width: 18,height: 18)
                                                }
                                            }
                                        }
                                        // Button to create a new broadcast
                                        if showBroadCastOption {
                                            Button {
                                                navigatetoCreatBroadCast = true
                                            } label: {
                                                HStack{
                                                    Text("New Broadcast")
                                                        .font(appearance.fonts.messageListMessageText)
                                                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                                    Spacer()
                                                    appearance.images.broadcastInUserList
                                                        .resizable()
                                                        .frame(width: 18,height: 18)
                                                }
                                            }
                                        }
                                    } header: {
                                        Text("")
                                    } footer: {
                                        Text("")
                                    }
                                }
                                
                                // Display users grouped by sections
                                ForEach(viewModel.usersSectionDictionary.keys.sorted(), id:\.self) { key in
                                    let contacts = filteredContacts(for: key)
                                    if !contacts.isEmpty {
                                        Section(header: Text("\(key)")) {
                                            ForEach(contacts) { value in
                                                ZStack {
                                                    HStack(spacing:10) {
                                                        // Display user avatar and name
                                                        UserAvatarView(avatar: value.userProfileImageUrl ?? "", showOnlineIndicator: value.online ?? false, size: CGSize(width: 29, height: 29), userName: value.userName ?? "", font: .regular(size: 12))
                                                        VStack(alignment: .leading, spacing: 5, content: {
                                                            Text(value.userName ?? "User")
                                                                .font(appearance.fonts.messageListMessageText)
                                                                .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                                        })//:VStack
                                                    }//:HStack
                                                    .fixedSize(horizontal: true, vertical: true)
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                    // Button to select a user
                                                    Button {
                                                        // Set selected user and conversation ID
                                                        self.selectedUserconversationId = realmManager.getConversationId(opponentUserId: value.userId ?? "", myUserId: ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userId ?? "")
                                                        let data = UserDB()
                                                        data.userId = value.userId
                                                        data.online = value.online
                                                        data.userProfileImageUrl = value.userProfileImageUrl
                                                        data.userName = value.userName
                                                        data.lastSeen = value.lastSeen
                                                        data.userIdentifier = value.userIdentifier
                                                        
                                                        selectedUser = data
                                                        
                                                        dismiss() // Dismiss the view
                                                        
                                                    } label: {
                                                    }
                                                }//:ZStack
                                                .onAppear {
                                                    // Load more users if necessary
                                                    if viewModel.moreDataAvailableForGetUsers && viewModel.apiCalling == false {
                                                        if isLastVisibleUser(value) {
                                                            self.getUsers()
                                                        }
                                                    }
                                                }// For LoadMore
                                            }
                                        }
                                    }
                                }
                            }.listStyle(DefaultListStyle())
                                .listRowSeparatorTint(appearance.colorPalette.chatListSeparatorColor)
                        }
                    }
                }//:VStack
                // Navigation destinations for creating group and broadcast conversations
                .navigationDestination(isPresented: $navigatetoCreatGroup, destination: {
                    ISMCreateGroupConversationView(showSheetView : $navigatetoCreatGroup, viewModel: self.viewModel, selectUserFor: .Group, groupCastId: "", groupCastIdToNavigate : $groupCastIdToNavigate).environmentObject(realmManager)
                })
                .navigationDestination(isPresented: $navigatetoCreatBroadCast, destination: {
                    ISMCreateGroupConversationView(showSheetView : $navigatetoCreatGroup, viewModel: self.viewModel, selectUserFor: .BroadCast, groupCastId: "", groupCastIdToNavigate : $groupCastIdToNavigate).environmentObject(realmManager)
                })
                .searchable(text: $viewModel.searchedText, placement: .navigationBarDrawer(displayMode: .always))
                .onChange(of: viewModel.debounceSearchedText, { _, _ in
                    // Reset user data and fetch users on search text change
                    print("~~SEARCHING WITH DEBOUNCING \(viewModel.searchedText)")
                    self.viewModel.resetGetUsersdata()
                    getUsers()
                })
                .onChange(of: navigatetoCreatGroup, { oldValue, newValue in
                    // Track when returning from create group view
                    if oldValue == true && newValue == false {
                        // Just returned from create group, mark as appeared to prevent reset
                        hasInitiallyAppeared = true
                    }
                })
                .onChange(of: navigatetoCreatBroadCast, { oldValue, newValue in
                    // Track when returning from create broadcast view
                    if oldValue == true && newValue == false {
                        // Just returned from create broadcast, mark as appeared to prevent reset
                        hasInitiallyAppeared = true
                    }
                })
                .onDisappear {
                    // Clear search text on view disappear
                    viewModel.searchedText = ""
                    viewModel.debounceSearchedText = ""
                    // Reset flag only when view is completely dismissed (not just navigating to child)
                    // This allows fresh load when view is reopened after being completely dismissed
                    if !navigatetoCreatGroup && !navigatetoCreatBroadCast {
                        hasInitiallyAppeared = false
                    }
                }
                .onAppear {
                    // Only reset and fetch on initial appear, not when navigating back from child views
                    if !hasInitiallyAppeared {
                        hasInitiallyAppeared = true
                        self.viewModel.resetGetUsersdata()
                        getUsers()
                    } else if viewModel.users.isEmpty && !viewModel.apiCalling {
                        // If users are empty when coming back (edge case), fetch without resetting
                        getUsers()
                    }
                }
                .refreshable {
                    // Refresh user list
                    refreshUsers()
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading : navBarLeadingBtn)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("New Chat")
                                .font(appearance.fonts.navigationBarTitle)
                                .foregroundColor(appearance.colorPalette.navigationBarTitle)
                        }
                    }
                }
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    //MARK: - CONFIGURE
    
    // Function to display section index titles for the user list
    func sectionIndexTitles(proxy: ScrollViewProxy) -> some View {
        SectionIndexTitles(proxy: proxy, titles: viewModel.usersSectionDictionary.keys.sorted())
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding()
    }
    
    // Function to fetch users based on search text
    func getUsers() {
        guard viewModel.apiCalling == false else { return }
        viewModel.apiCalling = true
        viewModel.getUsers(search: viewModel.searchedText) { data in
            viewModel.apiCalling = false
            viewModel.users.append(contentsOf: data?.users ?? [])
            viewModel.usersSectionDictionary = viewModel.getSectionedDictionary(data: viewModel.users)
        }
    }
    
    // Function to refresh the user list
    func refreshUsers() {
        self.viewModel.resetGetUsersdata()
        viewModel.refreshGetUser() { users in
            if let appendUser = users?.users {
                viewModel.users.append(contentsOf: appendUser)
                viewModel.usersSectionDictionary = viewModel.getSectionedDictionary(data: viewModel.users)
            }
        }
    }
    
    // Navigation bar leading button to dismiss the view
    var navBarLeadingBtn : some View {
        Button(action: { dismiss() }) {
            appearance.images.CloseSheet
                .resizable()
                .frame(width: 17,height: 17)
        }
    }
    
    private func filteredContacts(for key: String) -> [ISMChatUser] {
        guard let contacts = viewModel.usersSectionDictionary[key] else {
            return []
        }
        guard viewModel.searchedText.isEmpty == false else {
            return contacts
        }
        return contacts.filter {
            "\($0)".lowercased().contains(viewModel.searchedText.lowercased())
        }
    }
    
    private func lastVisibleContactId() -> String? {
        let sortedKeys = viewModel.usersSectionDictionary.keys.sorted().reversed()
        for key in sortedKeys {
            let contacts = filteredContacts(for: key)
            if let lastId = contacts.last?.userId {
                return lastId
            }
        }
        return nil
    }
    
    private func isLastVisibleUser(_ user: ISMChatUser) -> Bool {
        guard let lastId = lastVisibleContactId(), let userId = user.userId else {
            return false
        }
        return lastId == userId
    }
}
