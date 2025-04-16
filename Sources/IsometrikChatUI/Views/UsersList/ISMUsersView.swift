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
    @Binding public var selectedUser : ISMChatUserDB?
    @Binding public var selectedUserconversationId : String

    // State for creating a conversation response
    @State public var createconversation : ISMChatCreateConversationResponse?
   
    // State flags to show group and broadcast options based on chat properties
    @State public var showGroupOption = ISMChatSdkUI.getInstance().getChatProperties().conversationType.contains(.GroupConversation)
    @State public var showBroadCastOption = ISMChatSdkUI.getInstance().getChatProperties().conversationType.contains(.BroadCastConversation)
    @State public var navigatetoCreatGroup : Bool = false
    @State public var navigatetoCreatBroadCast : Bool = false
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @Binding public var groupCastIdToNavigate : String
    
    @ObservedObject var viewModelNew: ConversationsViewModel
    
    //MARK:  - LIFECYCLE
    public var body: some View {
        ZStack{
            NavigationStack{
                VStack {
                    // Show a loading indicator if no users are available
                    if viewModel.users.count == 0{
                        ProgressView()
                    } else {
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
                                    if let contacts = viewModel.usersSectionDictionary[key]?.filter({ (contact) -> Bool in
                                        self.viewModel.searchedText.isEmpty ? true :
                                        "\(contact)".lowercased().contains(self.viewModel.searchedText.lowercased())}), !contacts.isEmpty {
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
                                                        Task{
                                                            self.selectedUserconversationId = await viewModelNew.getConversationIdFromUserId(opponentUserId: value.userId ?? "", myUserId: ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userId ?? "")
                                                            let data = ISMChatUserDB(userId: value.userId, userProfileImageUrl: value.userProfileImageUrl, userName: value.userName, userIdentifier: value.userIdentifier, online: value.online, lastSeen: value.lastSeen, metaData: nil)
                                                            selectedUser = data
                                                            dismiss() // Dismiss the view
                                                        }
                                                        
                                                    } label: {
                                                    }
                                                }//:ZStack
                                                .onAppear {
                                                    // Load more users if necessary
                                                    if viewModel.moreDataAvailableForGetUsers && viewModel.apiCalling == false {
                                                        if let contactIndex = viewModel.usersSectionDictionary.values.flatMap({ $0 }).firstIndex(where: { $0.userId == value.userId }) {
                                                            let totalCount = viewModel.usersSectionDictionary.values.flatMap({ $0 }).count
                                                            // Check if this is the last contact and the total count is a multiple of 20
                                                            if contactIndex == totalCount - 1 && totalCount % 20 == 0 {
                                                                // Call the API to load more users
                                                                self.getUsers()
                                                            }
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
                .fullScreenCover(isPresented: $navigatetoCreatGroup, onDismiss: {
                    self.dismiss
                }, content: {
                    ISMCreateGroupConversationView(showSheetView : $navigatetoCreatGroup, viewModel: self.viewModel, selectUserFor: .Group, groupCastId: "", groupCastIdToNavigate : $groupCastIdToNavigate)
                })
                    .fullScreenCover(isPresented: $navigatetoCreatBroadCast, onDismiss: {
                        self.dismiss
                    }, content: {
                        ISMCreateGroupConversationView(showSheetView : $navigatetoCreatGroup, viewModel: self.viewModel, selectUserFor: .BroadCast, groupCastId: "", groupCastIdToNavigate : $groupCastIdToNavigate)
                    })
//                .navigationDestination(isPresented: $navigatetoCreatGroup, destination: {
//                    ISMCreateGroupConversationView(showSheetView : $navigatetoCreatGroup, viewModel: self.viewModel, selectUserFor: .Group, groupCastId: "", groupCastIdToNavigate : $groupCastIdToNavigate)
//                })
//                .navigationDestination(isPresented: $navigatetoCreatBroadCast, destination: {
//                    ISMCreateGroupConversationView(showSheetView : $navigatetoCreatGroup, viewModel: self.viewModel, selectUserFor: .BroadCast, groupCastId: "", groupCastIdToNavigate : $groupCastIdToNavigate)
//                })
                .searchable(text: $viewModel.searchedText, placement: .navigationBarDrawer(displayMode: .always))
                .onChange(of: viewModel.debounceSearchedText, { _, _ in
                    // Reset user data and fetch users on search text change
                    print("~~SEARCHING WITH DEBOUNCING \(viewModel.searchedText)")
                    self.viewModel.resetGetUsersdata()
                    getUsers()
                })
                .onDisappear {
                    // Clear search text on view disappear
                    viewModel.searchedText = ""
                    viewModel.debounceSearchedText = ""
                }
                .onLoad {
                    // Reset user data and fetch users on view appear
                    self.viewModel.resetGetUsersdata()
                    getUsers()
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
}
