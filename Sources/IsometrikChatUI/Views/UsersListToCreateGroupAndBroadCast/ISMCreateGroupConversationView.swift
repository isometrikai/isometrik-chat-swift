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
    @Environment(\.dismiss) public var dismiss
    @Binding public var showSheetView : Bool
    @State public var image : UIImage?
    @State public var groupName = ""
    @State public var userSelected : [ISMChatUser] = []
    @ObservedObject public var viewModel = ConversationViewModel()
    @ObservedObject public var chatViewModel = ChatsViewModel()
    public var conversationId : String? = nil
    public var selectUserFor : SelectUserFor = .Group
    @State public var navigateTocreateGroup : Bool = false
//    @State var navigateToMessageView : Bool = false
    @State public var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State public var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State public var themeImage = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    public let groupCastId : String?
    @EnvironmentObject public var realmManager : RealmManager
    @Binding public var groupCastIdToNavigate : String
    
    //MARK:  - BODY
    public var body: some View {
        ZStack{
            VStack {
                ScrollViewReader { proxy in
                    List {
                        if userSelected.count > 0 {
                            HeaderView()
                        }
                        ForEach(viewModel.usersSectionDictionary.keys.sorted(), id:\.self) { key in
                            if let contacts = viewModel.usersSectionDictionary[key]?.filter({ (contact) -> Bool in
                                self.viewModel.searchedText.isEmpty ? true :
                                "\(contact)".lowercased().contains(self.viewModel.searchedText.lowercased())}), !contacts.isEmpty{
                                Section(header: Text("\(key)")) {
                                    ForEach(contacts){ value in
                                        ZStack{
                                            HStack(spacing:5){
                                                UserAvatarView(avatar: value.userProfileImageUrl ?? "", showOnlineIndicator: value.online ?? false,size: CGSize(width: 40, height: 40), userName: value.userName ?? "",font: .regular(size: 14))
                                                VStack(alignment: .leading, spacing: 5, content: {
                                                    Text(value.userName ?? "User")
                                                        .font(themeFonts.messageListMessageText)
                                                        .foregroundColor(themeColor.messageListHeaderTitle)
                                                    Text(value.userIdentifier ?? "")
                                                        .font(themeFonts.chatListUserMessage)
                                                        .foregroundColor(themeColor.chatListUserMessage)
                                                        .lineLimit(2)
                                                    
                                                })//:VStack
                                                
                                                Spacer()
                                                
                                                if userSelected.contains(where: { user in
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
                                            }//:HStack
                                            
                                            Button {
                                                userselectedHere(value: value)
                                            } label: {
                                            }
                                            
                                        }//:Zstack
                                        .onAppear {
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
                    .listStyle(DefaultListStyle())
                    //                        .overlay(sectionIndexTitles(proxy: proxy))
                    .navigationBarBackButtonHidden(true)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            VStack {
                                if selectUserFor == .Group{
                                    Text("Add Members")
                                        .font(themeFonts.navigationBarTitle)
                                        .foregroundColor(themeColor.navigationBarTitle)
                                }else{
                                    Text("Recipients")
                                        .font(themeFonts.navigationBarTitle)
                                        .foregroundColor(themeColor.navigationBarTitle)
                                }
                            }
                        }
                    }
                    .navigationBarItems(leading: navBarLeadingBtn, trailing: navBarTrailingBtn)
                    .background(NavigationLink("", destination: ISMGroupCreate(showSheetView: self.$showSheetView, userSelected: self.$userSelected,viewModel: self.viewModel, chatViewModel: self.chatViewModel),isActive: $navigateTocreateGroup))
//                    .background(NavigationLink("", destination:  ISMMessageView(conversationViewModel : self.viewModel,conversationID: "",opponenDetail: nil,userId: viewModel.userData?.userIdentifier, isGroup: false,fromBroadCastFlow: true,groupCastId: self.groupCastId ?? "", groupConversationTitle: nil, groupImage: nil)
//                        .environmentObject(realmManager), isActive: $navigateToMessageView))
                }
            }//:VStack
            .onAppear {
                self.viewModel.resetGetUsersdata()
                getUsers()
            }
            .refreshable {
                refreshUsers()
            }
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
        }
    }
    
    //MARK:  - CONFIGURE
    
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
                                        themeImage.removeUserFromSelectedFromList
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    }
                                    
                                    Text(user.userName ?? "")
                                        .font(themeFonts.chatListUserMessage)
                                        .foregroundColor(themeColor.chatListUserMessage)
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
                } 
                .onChange(of: userSelected.count, { _, _ in
                    withAnimation {  // add animation for scroll to top
                        reader.scrollTo(userSelected.last?.id, anchor: .center) // scroll
                    }
                })
            }
        }.padding(.vertical,5)
    }
    
    var navBarTrailingBtn: some View {
        VStack{
            ZStack{
                if userSelected.count > 0{
                    if selectUserFor == .Group{
                        Button {
                            navigateTocreateGroup = true
                        } label: {
                            Text("Next")
                                .font(themeFonts.messageListMessageText)
                                .foregroundColor(userSelected.count > 0 ? themeColor.userProfileEditText: .gray)
                        }
                    }else if selectUserFor == .AddMemberInBroadcast{
                        Button {
                            chatViewModel.addMemberInBroadCast(members: userSelected, groupcastId: self.groupCastId ?? "") { _ in
                                ISMChatHelper.print("success")
                                dismiss()
                            }
                        } label: {
                            Text("Next")
                                .font(themeFonts.messageListMessageText)
                                .foregroundColor(userSelected.count > 0 ? themeColor.userProfileEditText: .gray)
                        }
                    }else{
                        Button {
                            
                            chatViewModel.createBroadCast(users: self.userSelected) { data in
                                if let groupcastId = data?.groupcastId{
                                    groupCastIdToNavigate = groupcastId
                                    showSheetView = false
                                }
                            }
                            
                        } label: {
                            Text("Create")
                                .font(themeFonts.messageListMessageText)
                                .foregroundColor(userSelected.count > 0 ? themeColor.userProfileEditText: .gray)
                        }
                    }
                }
            }
        }
    }
    
    var navBarLeadingBtn: some View {
        Button(action: { dismiss() }) {
            themeImage.backButton
                .resizable()
                .frame(width: 29, height: 29, alignment: .center)
        }
    }
    
    func sectionIndexTitles(proxy: ScrollViewProxy) -> some View {
        SectionIndexTitles(proxy: proxy, titles: viewModel.usersSectionDictionary.keys.sorted())
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
    }
    
    func getUsers(){
        viewModel.apiCalling = true
        if selectUserFor == .AddMemberInBroadcast{
            viewModel.getBroadCastEligibleUsers(groupCastId : self.groupCastId ?? "",search: viewModel.searchedText) { data in
                viewModel.users.append(contentsOf: data?.groupcastEligibleMembers ?? [])
                viewModel.usersSectionDictionary = viewModel.getSectionedDictionary(data: viewModel.users)
            }
        }else{
            viewModel.getUsers(search: viewModel.searchedText) { data in
                viewModel.users.append(contentsOf: data?.users ?? [])
                viewModel.usersSectionDictionary = viewModel.getSectionedDictionary(data: viewModel.users)
            }
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
}

