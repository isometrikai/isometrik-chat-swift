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
    @Environment(\.dismiss) public var dismiss
    
    @ObservedObject public var viewModel = ConversationViewModel()
    
    @Binding public var selectedUser : UserDB
    @Binding public var selectedUserconversationId : String

    @State public var createconversation : ISMChatCreateConversationResponse?
   
    @State public var showGroupOption = ISMChatSdkUI.getInstance().getChatProperties().conversationType.contains(.GroupConversation)
    @State public var showBroadCastOption = ISMChatSdkUI.getInstance().getChatProperties().conversationType.contains(.BroadCastConversation)
    
    @EnvironmentObject public var realmManager : RealmManager
    @State public var navigatetoCreatGroup : Bool = false
    @State public var navigatetoCreatBroadCast : Bool = false
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @Binding public var groupCastIdToNavigate : String
    
    //MARK:  - LIFECYCLE
    public var body: some View {
        ZStack{
            NavigationStack{
                VStack {
                    if viewModel.users.count == 0{
                        ProgressView()
                    }else{
                        ScrollViewReader { proxy in
                            List {
                                if showGroupOption == true || showBroadCastOption == true{
                                    Section {
                                        if showGroupOption{
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
                                        if showBroadCastOption{
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
                                
                                ForEach(viewModel.usersSectionDictionary.keys.sorted(), id:\.self) { key in
                                    if let contacts = viewModel.usersSectionDictionary[key]?.filter({ (contact) -> Bool in
                                        self.viewModel.searchedText.isEmpty ? true :
                                        "\(contact)".lowercased().contains(self.viewModel.searchedText.lowercased())}), !contacts.isEmpty{
                                        Section(header: Text("\(key)")) {
                                            ForEach(contacts){ value in
                                                ZStack{
                                                    HStack(spacing:10){
                                                        UserAvatarView(avatar: value.userProfileImageUrl ?? "", showOnlineIndicator: value.online ?? false,size: CGSize(width: 29, height: 29), userName: value.userName ?? "",font: .regular(size: 12))
                                                        VStack(alignment: .leading, spacing: 5, content: {
                                                            Text(value.userName ?? "User")
                                                                .font(appearance.fonts.messageListMessageText)
                                                                .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
//                                                            Text(value.metaData?.about ?? "Hey there! I am using Wetalk.")
//                                                                .font(themeFonts.chatListUserMessage)
//                                                                .foregroundColor(themeColor.chatListUserMessage)
//                                                                .lineLimit(2)
                                                            
                                                        })//:VStack
                                                    }//:HStack
                                                    .fixedSize(horizontal: true, vertical: true)
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                    Button {
                                                        
                                                        self.selectedUserconversationId = realmManager.getConversationId(opponentUserId: value.userId ?? "", myUserId: ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig.userId ?? "")
                                                        let data = UserDB()
                                                        data.userId = value.userId
                                                        data.online = value.online
                                                        data.userProfileImageUrl = value.userProfileImageUrl
                                                        data.userName = value.userName
                                                        data.lastSeen = value.lastSeen
                                                        data.userIdentifier = value.userIdentifier
                                                        
                                                        selectedUser = data
                                                        
                                                        dismiss()
                                                        
                                                    } label: {
                                                    }
                                                }//:ZStack
                                                .onAppear {
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
                            //                            .overlay(sectionIndexTitles(proxy: proxy))
                        }
                    }
                }//:VStack
                .navigationDestination(isPresented: $navigatetoCreatGroup, destination: {
                    ISMCreateGroupConversationView(showSheetView : $navigatetoCreatGroup,viewModel: self.viewModel,selectUserFor: .Group,groupCastId: "", groupCastIdToNavigate : $groupCastIdToNavigate).environmentObject(realmManager)
                })
                .navigationDestination(isPresented: $navigatetoCreatBroadCast, destination: {
                    ISMCreateGroupConversationView(showSheetView : $navigatetoCreatGroup,viewModel: self.viewModel,selectUserFor: .BroadCast,groupCastId: "", groupCastIdToNavigate : $groupCastIdToNavigate).environmentObject(realmManager)
                })
                
//                .background(NavigationLink("", destination: ISMCreateGroupConversationView(showSheetView : $navigatetoCreatGroup,viewModel: self.viewModel,selectUserFor: .Group,groupCastId: "", groupCastIdToNavigate : $groupCastIdToNavigate),isActive: $navigatetoCreatGroup).environmentObject(realmManager))
//                .background(NavigationLink("", destination: ISMCreateGroupConversationView(showSheetView : $navigatetoCreatGroup,viewModel: self.viewModel,selectUserFor: .BroadCast,groupCastId: "", groupCastIdToNavigate : $groupCastIdToNavigate),isActive: $navigatetoCreatBroadCast).environmentObject(realmManager))
                .searchable(text: $viewModel.searchedText, placement: .navigationBarDrawer(displayMode: .always))
                .onChange(of: viewModel.debounceSearchedText, { _, _ in
                    print("~~SEARCHING WITH DEBOUNCING \(viewModel.searchedText)")
                    self.viewModel.resetGetUsersdata()
                    getUsers()
                })
                .onDisappear {
                    viewModel.searchedText = ""
                    viewModel.debounceSearchedText = ""
                }
                .onAppear {
                    self.viewModel.resetGetUsersdata()
                    getUsers()
                }
                .refreshable {
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
    
    func sectionIndexTitles(proxy: ScrollViewProxy) -> some View {
        SectionIndexTitles(proxy: proxy, titles: viewModel.usersSectionDictionary.keys.sorted())
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding()
    }
    
    func getUsers(){
        viewModel.apiCalling = true
        viewModel.getUsers(search: viewModel.searchedText) { data in
            viewModel.users.append(contentsOf: data?.users ?? [])
            viewModel.usersSectionDictionary = viewModel.getSectionedDictionary(data: viewModel.users)
        }
    }
    
    func refreshUsers(){
        self.viewModel.resetGetUsersdata()
        viewModel.refreshGetUser() { users in
            if let appendUser = users?.users{
                viewModel.users.append(contentsOf: appendUser)
                viewModel.usersSectionDictionary = viewModel.getSectionedDictionary(data: viewModel.users)
            }
        }
    }
    
    var navBarLeadingBtn : some View{
        Button(action: { dismiss() }) {
            appearance.images.CloseSheet
                .resizable()
                .frame(width: 17,height: 17)
        }
    }
}
