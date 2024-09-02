//
//  ISMAddParticipants.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 18/09/23.
//

import SwiftUI
import IsometrikChat

struct ISMAddParticipantsView: View {
    
    //MARK: - PROPERTIES
    @Environment(\.dismiss) var dismiss
    
    @State private var userSelected : [ISMChatUser] = []
    @ObservedObject var viewModel = ConversationViewModel()
    @ObservedObject var chatViewModel = ChatsViewModel()
    var conversationId : String? = nil
    @EnvironmentObject var realmManager : RealmManager
    @State var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State var themeImage = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    
    //MARK: - BODY
    var body: some View {
        ZStack{
//            VStack {
//                ScrollViewReader { proxy in
//                    List {
//                        if userSelected.count > 0{
//                            HeaderView()
//                        }
//                        ForEach(viewModel.elogibleUsersSectionDictionary.keys.sorted(), id:\.self) { key in
//                            if let contacts = viewModel.elogibleUsersSectionDictionary[key]?.filter({ (contact) -> Bool in
//                                self.viewModel.searchedText.isEmpty ? true :
//                                "\(contact)".lowercased().contains(self.viewModel.searchedText.lowercased())}), !contacts.isEmpty{
//                                Section(header: Text("\(key)")) {
//                                    ForEach(contacts){ value in
//                                        ZStack{
//                                            HStack(alignment: .center, spacing:20){
//                                                UserAvatarView(avatar: value.userProfileImageUrl ?? "", showOnlineIndicator: value.online ?? false,size: CGSize(width: 29, height: 29), userName : value.userName ?? "",font: .regular(size: 12))
//                                                VStack(alignment: .leading, spacing: 5, content: {
//                                                    Text(value.userName ?? "User")
//                                                        .font(themeFonts.messageListMessageText)
//                                                        .foregroundColor(themeColor.messageListMessageText)
//                                                    Text(value.userIdentifier ?? "")
//                                                        .font(themeFonts.chatListUserMessage)
//                                                        .foregroundColor(themeColor.chatListUserMessage)
//                                                        .lineLimit(2)
//                                                    
//                                                })//:VStack
//                                                Spacer()
//                                                
//                                                if userSelected.contains(where: { user in
//                                                    user.id == value.id
//                                                }) {
//                                                    themeImage.selected
//                                                        .resizable()
//                                                        .frame(width: 20, height: 20)
//                                                }else{
//                                                    themeImage.deselected
//                                                        .resizable()
//                                                        .frame(width: 20, height: 20)
//                                                }
//                                            }//:HStack
//                                            Button {
//                                                if userSelected.contains(where: { user in
//                                                    user.id == value.id
//                                                }){
//                                                    userSelected.removeAll(where: { $0.id == value.id })
//                                                }else{
//                                                    userSelected.append(value)
//                                                }
//                                            } label: {
//                                                
//                                            }
//                                            
//                                        }//:Zstack
//                                        .onAppear {
//                                            if viewModel.moreDataAvailableForGetUsers && viewModel.apiCalling == false{
//                                                if self.viewModel.eligibleUsers.last?.userId == contacts.last?.userId {
//                                                    self.getUsers()
//                                                }
//                                            }
//                                        }// For LoadMore
//                                    }
//                                }
//                            }
//                        }
//                    }//:LIST
//                    .searchable(text:  $viewModel.searchedText, placement: .navigationBarDrawer(displayMode: .always)) {}
//                    .navigationBarBackButtonHidden(true)
//                    .navigationBarTitleDisplayMode(.inline)
//                    .toolbar {
//                        ToolbarItem(placement: .principal) {
//                            VStack {
//                                Text("Add participants")
//                                    .font(themeFonts.navigationBarTitle)
//                                    .foregroundColor(themeColor.navigationBarTitle)
//                            }
//                        }
//                    }
//                    .navigationBarItems(leading: navBarLeadingBtn,trailing: navBarTrailingBtn)
//                }
//            }//:VStack
//            .onChange(of: viewModel.debounceSearchedText, perform: { newValue in
//                print("~~SEARCHING WITH DEBOUNCING \(viewModel.searchedText)")
//                self.viewModel.resetEligibleUsersdata()
//                getUsers()
//            })
//            .onDisappear {
//                viewModel.searchedText = ""
//                viewModel.debounceSearchedText = ""
//            }
//            .onAppear {
//                self.viewModel.resetEligibleUsersdata()
//                getUsers()
//            }
//            .onLoad{
//                
//            }
//            if chatViewModel.isBusy{
//                //Custom Progress View
//                ActivityIndicatorView(isPresented: $chatViewModel.isBusy)
//            }
        }
    }
    
    
    //MARK:  - CONFIGURE
    
    
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
                                        themeImage.removeUserFromSelectedFromList
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    }
                                    
                                    Text(user.userName ?? "")
                                        .font(themeFonts.chatListUserMessage)
                                        .foregroundColor(themeColor.messageListHeaderTitle)
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
                } .onChange(of: userSelected.count) { _ in
                    withAnimation {  // add animation for scroll to top
                        reader.scrollTo(userSelected.last?.id, anchor: .center) // scroll
                    }
                }
            }
        }.padding(.vertical,5)
    }
    
    func addParticipant(){
        //create grp API
        let member = userSelected.map { $0.id }
        //add participant in already exist grp
        if let conversationId = conversationId{
            chatViewModel.addMembersInAlredyExistingGroup(members: member, conversationId: conversationId) { data in
                realmManager.updateMemberCount(convId: conversationId, inc: true, dec: false, count: 1)
                NotificationCenter.default.post(name: NSNotification.memberAddAndRemove,object: nil)
                self.dismiss()
            }
        }
    }
    
    var navBarLeadingBtn : some View{
        Button(action: { dismiss() }) {
            themeImage.backButton
                .resizable()
                .frame(width: 29, height: 29)
        }
    }
    
    var navBarTrailingBtn: some View {
        VStack{
            Button(action: {
                addParticipant()
            }) {
                Text("Add")
                    .font(themeFonts.messageListMessageText)
                    .foregroundColor(userSelected.count == 0 ? Color.gray : themeColor.userProfileEditText)
            }.disabled(userSelected.count == 0)
        }
    }
    
    func sectionIndexTitles(proxy: ScrollViewProxy) -> some View {
        SectionIndexTitles(proxy: proxy, titles: viewModel.elogibleUsersSectionDictionary.keys.sorted())
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
    }
    
    func getUsers(){
        viewModel.apiCalling = true
        viewModel.getEligibleUsers(search: viewModel.searchedText, conversationId: self.conversationId ?? "") {  data in
            viewModel.eligibleUsers.append(contentsOf: data?.conversationEligibleMembers ?? [])
            viewModel.elogibleUsersSectionDictionary = viewModel.getSectionedDictionary(data: viewModel.eligibleUsers)
        }
    }
}
