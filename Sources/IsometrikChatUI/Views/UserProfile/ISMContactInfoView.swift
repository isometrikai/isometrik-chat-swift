//
//  ISMUserInfoView.swift
//  ISMChatSdk
//
//  Created by Rahul Iphone123 on 20/06/23.
//

import SwiftUI
import UIKit
import IsometrikChat

struct ISMContactInfoView: View {
    
    //MARK:  - PROPERTIES
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showingAlert = false
    @State private var alertStr = ""
    var conversationViewModel = ConversationViewModel()
    let conversationID : String?
    @State var conversationDetail : ISMChatConversationDetail?
    @EnvironmentObject var realmManager : RealmManager
    @State private var selectedOption : ISMChatContactInfo = .BlockUser
    var viewModel = ChatsViewModel()
    let isGroup : Bool?
    @State var navigatetoAddparticipant : Bool = false
    @State var navigatetoMedia : Bool = false
    
    @State var showOptions : Bool = false
    @State var showInfo : Bool = false
    @State var selectedMember : ISMChatGroupMember = ISMChatGroupMember()
    
    @State var onlyInfo : Bool = false
    
    @State var selectedToShowInfo : ISMChatGroupMember?
    
    @State var selectedConversationId : String?
    @State private var showEdit : Bool = false
    @State private var showSearch : Bool = false
    
    @State private var showFullScreenImage = false
    @State private var fullScreenImageURL: String?
    
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @State public var userData = ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig
    
    @Binding var navigateToSocialProfileId : String
    
    //MARK:  - BODY
    var body: some View {
        NavigationStack{
            VStack{
                if showFullScreenImage {
                    // To show profile Image on tap of user Image
                    ISMChatImageCahcingManger.viewImage(url: fullScreenImageURL ?? "")
                        .resizable()
                        .scaledToFit()
                }else{
                    List {
                        //Bio
                        if isGroup == false{
                            Section {
                                if ISMChatSdk.getInstance().getFramework() == .SwiftUI{
                                    Text(conversationDetail?.conversationDetails?.opponentDetails?.metaData?.about ?? "Hey there!")
                                        .font(appearance.fonts.messageListMessageText)
                                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                }else{
                                    Button {
                                        navigateToSocialProfileId = conversationDetail?.conversationDetails?.opponentDetails?.metaData?.userId ?? ""
                                    } label: {
                                        HStack{
                                            appearance.images.mediaIcon
                                                .resizable()
                                                .frame(width: 29,height: 29)
                                            Text("View Social Profile")
                                                .font(appearance.fonts.messageListMessageText)
                                                .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                            Spacer()
                                        }
                                    }
                                }
                            } header: {
                                HStack(alignment: .center){
                                    Spacer()
                                    customHeaderView()
                                        .listRowInsets(EdgeInsets())
                                    Spacer()
                                }
                            }.listRowSeparatorTint(Color.border)
                        }
                        //media, link and doc
                        Section {
                            NavigationLink {
                                ISMUserMediaView(viewModel:viewModel)
                                    .environmentObject(self.realmManager)
                            } label: {
                                HStack{
                                    appearance.images.mediaIcon
                                        .resizable()
                                        .frame(width: 29,height: 29)
                                    Text("Media, Links and Docs")
                                        .font(appearance.fonts.messageListMessageText)
                                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                    Spacer()
                                    let count = ((realmManager.medias?.count ?? 0) + (realmManager.filesMedia?.count ?? 0) + (realmManager.linksMedia?.count ?? 0))
                                    Text(count.description)
                                        .font(appearance.fonts.messageListMessageText)
                                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                }
                            }
                        } header: {
                            if isGroup == true{
                                HStack(alignment: .center){
                                    Spacer()
                                    customHeaderView()
                                        .listRowInsets(EdgeInsets())
                                    Spacer()
                                }
                            }
                        }.listRowSeparatorTint(Color.border)
                        
                        if isGroup == true{
                            Section {
                                
                                if conversationDetail?.conversationDetails?.usersOwnDetails?.isAdmin == true{
                                    NavigationLink {
                                        ISMAddParticipantsView(viewModel: self.conversationViewModel,conversationId: self.conversationID).environmentObject(realmManager)
                                    } label: {
                                        HStack(spacing: 12){
                                            
                                            appearance.images.addMembers
                                                .resizable()
                                                .frame(width: 29, height: 29, alignment: .center)
                                            
                                            Text("Add Members")
                                                .font(appearance.fonts.messageListMessageText)
                                                .foregroundColor(appearance.colorPalette.messageListReplyToolbarRectangle)
                                        }
                                    }
                                }
                                if let members = conversationDetail?.conversationDetails?.members{
                                    ForEach(members, id: \.self) { member in
                                        ISMGroupMemberSubView(member: member, selectedMember: $selectedMember)
                                    }
                                }
                            } header: {
                                HStack{
                                    Text("\(conversationDetail?.conversationDetails?.members?.count ?? 0) Members")
                                        .font(appearance.fonts.contactInfoHeader)
                                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                        .textCase(nil)
                                    Spacer()
                                    
                                    NavigationLink {
                                        ISMSearchParticipants(viewModel: self.viewModel, conversationViewModel: self.conversationViewModel ,conversationID: self.conversationID)
                                    } label: {
                                        appearance.images.searchMagnifingGlass
                                            .resizable()
                                            .frame(width: 28, height: 28, alignment: .center)
                                            .padding(8)
                                    }
                                    
                                    //                                Button {
                                    //                                    showSearch = true
                                    //                                } label: {
                                    //                                    themeImage.searchMagnifingGlass
                                    //                                        .resizable()
                                    //                                        .frame(width: 28, height: 28, alignment: .center)
                                    //                                        .padding(8)
                                    //                                }
                                    
                                }.listRowInsets(EdgeInsets())
                            } footer: {
                                Text("")
                            }.listRowSeparatorTint(Color.border)
                        }
                        otherSection()
                        
                    }.background(Color.backgroundView)
                        .scrollContentBackground(.hidden)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(isGroup == false ? "Contact Info" : "Group Info")
                            .font(appearance.fonts.navigationBarTitle)
                            .foregroundColor(appearance.colorPalette.navigationBarTitle)
                    }
                }
            }
            .navigationBarItems(leading: navBarLeadingBtn, trailing: navBarTrailingBtn)
            //        .navigationDestination(isPresented: $navigatetoAddparticipant) {
            //            ISMAddParticipantsView(viewModel: self.conversationViewModel,conversationId: self.conversationID).environmentObject(realmManager)
            //        }
            //        .background(NavigationLink("", destination:  ISMAddParticipantsView(viewModel: self.conversationViewModel,conversationId: self.conversationID).environmentObject(realmManager), isActive: $navigatetoAddparticipant))
            //        .background(NavigationLink("", destination:  , isActive: $navigatetoMedia))
            //        .background(NavigationLink("", destination:  , isActive: $showInfo))
            //        .background(NavigationLink("", destination:  ISMSearchParticipants(viewModel: self.viewModel, conversationViewModel: self.conversationViewModel ,conversationID: self.conversationID), isActive: $showSearch))
            //        .background(NavigationLink("", destination:  , isActive: $showEdit))
            .onChange(of: selectedMember, { _, _ in
                if selectedMember.userId != userData.userId{
                    showOptions = true
                }
            })
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.memberAddAndRemove)) { _ in
                getConversationDetail {}
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.updateGroupInfo)) { _ in
                getConversationDetail {
                    realmManager.updateImageAndNameOfGroup(name: conversationDetail?.conversationDetails?.conversationTitle ?? "", image: conversationDetail?.conversationDetails?.conversationImageUrl ?? "", convID: self.conversationID ?? "")
                }
            }
            .confirmationDialog("", isPresented: $showOptions) {
                NavigationLink {
                    ISMContactInfoView(conversationID: realmManager.getConversationId(userId: selectedMember.userId ?? ""),viewModel:self.viewModel, isGroup: false,onlyInfo: true,selectedToShowInfo : selectedMember,navigateToSocialProfileId: $navigateToSocialProfileId).environmentObject(self.realmManager)
                } label: {
                    Text("Info")
                }
                if checkIfAdmin() == true{
                    Button {
                        makeGroupAdmin()
                    } label: {
                        Text(selectedMember.isAdmin == false ? "Make Group Admin" : "Dismiss as Admin")
                    }
                    Button {
                        removefromGroup()
                    } label: {
                        Text("Remove from Group")
                    }
                }
                Button("Cancel", role: .cancel, action: {})
            } message: {
                Text(selectedMember.userName ?? "")
            }
        }
    }
    
    //MARK:  - CONFIGURE
    func checkIfAdmin() -> Bool {
        if conversationDetail?.conversationDetails?.usersOwnDetails?.isAdmin == true{
            return true // The user is an admin
        } else {
            return false // The user is not an admin
        }
    }
    
    func otherSection() -> some View{
        return Section {
            let blocked = conversationDetail?.conversationDetails?.messagingDisabled
            let unmuted = conversationDetail?.conversationDetails?.config?.pushNotifications
            let contactOptions = ISMChatContactInfo.options(blocked: blocked ?? false, unmuted: unmuted ?? false,singleConversation: !(isGroup ?? false),onlyInfo : self.onlyInfo)
            ForEach(contactOptions, id: \.self) { obj in
                HStack {
                    Text(obj.title)
                        .font(appearance.fonts.messageListMessageText)
                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                    Button {
                        showingAlert = true
                        if obj == .BlockUser {
                            self.alertStr = "Do you want to Block this User?"
                        }else if obj == .ClearChat {
                            self.alertStr = "Clear All Messages?"
                        }else if obj == .DeleteUser {
                            self.alertStr = "Delete Chat?"
                        }else if obj == .UnBlockUser{
                            self.alertStr = "Do you want to UnBlock this User?"
                        }else if obj == .ExitGroup{
                            self.alertStr = "Do you want to exit this group?"
                        }else if obj == .MuteNotification{
                            self.alertStr = "Disable notifications?"
                        }else if obj == .UnMuteNotification{
                            self.alertStr = "Enable notifications?"
                        }
                        self.selectedOption = obj
                    } label: {
                        
                    }
                }
                .alert(alertStr, isPresented: $showingAlert) {
                    Button("No", role: .cancel) { }
                    Button("Yes", role: .destructive) {
                        manageFlow()
                    }
                }
            }//.foregroundColor(Color(uiColor: colors.alert))
        } header: {
            Text("")
        } footer: {
            if isGroup == true{
                let dateVar = NSDate()
                let date = dateVar.doubletoDate(time: conversationDetail?.conversationDetails?.createdAt ?? 0)
                VStack(alignment: .leading){
                    let user = userData.userName == (conversationDetail?.conversationDetails?.createdByUserName ?? "") ? ConstantStrings.you.lowercased() : (conversationDetail?.conversationDetails?.createdByUserName ?? "")
                    Text("Group created by \(user)")
                        .font(appearance.fonts.chatListUserMessage)
                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                    Text("Created on \(date)")
                        .font(appearance.fonts.chatListUserMessage)
                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                }.padding(.top)
            }
        }.listRowSeparatorTint(Color.border)
    }
    
    func manageFlow() {
        if selectedOption == .BlockUser {
            conversationViewModel.blockUnBlockUser(opponentId: (conversationDetail?.conversationDetails?.opponentDetails?.userId ?? selectedToShowInfo?.userId) ?? "", needToBlock: true) { obj in
                print("Success")
                presentationMode.wrappedValue.dismiss()
            }
        }else if selectedOption == .UnBlockUser {
            conversationViewModel.blockUnBlockUser(opponentId: conversationDetail?.conversationDetails?.opponentDetails?.userId ?? (selectedToShowInfo?.userId ?? ""), needToBlock: false) { obj in
                print("Success")
                presentationMode.wrappedValue.dismiss()
            }
        }else if selectedOption == .ClearChat {
            conversationViewModel.clearChat(conversationId: conversationID ?? "") {
                self.realmManager.clearMessages()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    self.realmManager.clearMessages(convID: conversationID ?? "")
                    NavigationUtil.popToRootView()
                })
            }
        }else if selectedOption == .DeleteUser {
            conversationViewModel.deleteConversation(conversationId: conversationID ?? "") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    realmManager.deleteConversation(convID: conversationID ?? "")
                    NavigationUtil.popToRootView()
                })
            }
        }else if selectedOption == .ExitGroup{
            viewModel.exitGroup(conversationId: conversationID ?? "") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    realmManager.deleteConversation(convID: conversationID ?? "")
                    realmManager.deleteMessagesThroughConvId(convID: conversationID ?? "")
                    realmManager.deleteMediaThroughConversationId(convID: conversationID ?? "")
                    NavigationUtil.popToRootView()
                })
            }
        }else if selectedOption == .MuteNotification{
            conversationViewModel.muteUnmuteNotification(conversationId: conversationID ?? "", pushNotifications: false) { _ in
                print("Success")
                conversationDetail?.conversationDetails?.config?.pushNotifications = false
            }
        }else if selectedOption == .UnMuteNotification{
            conversationViewModel.muteUnmuteNotification(conversationId: conversationID ?? "", pushNotifications: true) { _ in
                print("Success")
                conversationDetail?.conversationDetails?.config?.pushNotifications = true
            }
        }
    }
    
    func customHeaderView() -> some View{
        VStack(alignment: .center){
            if onlyInfo == true{
                UserAvatarView(avatar: (conversationDetail?.conversationDetails?.opponentDetails?.userProfileImageUrl ?? (selectedToShowInfo?.userProfileImageUrl ?? "")), showOnlineIndicator: conversationDetail?.conversationDetails?.opponentDetails?.online ?? (selectedToShowInfo?.online ?? false),size: CGSize(width: 116, height: 116), userName: conversationDetail?.conversationDetails?.opponentDetails?.userName ?? (selectedToShowInfo?.userName ?? ""),font: .regular(size: 50))
                    .onTapGesture {
                        fullScreenImageURL = conversationDetail?.conversationDetails?.opponentDetails?.userProfileImageUrl ?? (selectedToShowInfo?.userProfileImageUrl ?? "")
                        withAnimation {
                            showFullScreenImage = true
                        }
                    }
                
                Spacer(minLength: 10)
                Text(conversationDetail?.conversationDetails?.opponentDetails?.userName?.capitalizingFirstLetter() ?? (selectedToShowInfo?.userName?.capitalizingFirstLetter() ?? ""))
                    .font(appearance.fonts.chatListTitle)
                    .foregroundColor(appearance.colorPalette.chatListTitle)
                    .textCase(nil)
                Spacer()
                let text = NSDate().descriptiveStringLastSeen(time: conversationDetail?.conversationDetails?.opponentDetails?.lastSeen ?? 0)
                Text("Last seen \(text)")
                    .font(appearance.fonts.messageListMessageText)
                    .foregroundColor(appearance.colorPalette.chatListUserMessage)
                    .padding(.bottom,15)
                    .textCase(nil)
            }else{
                UserAvatarView(avatar: isGroup == false ? (conversationDetail?.conversationDetails?.opponentDetails?.userProfileImageUrl ?? "") : (conversationDetail?.conversationDetails?.conversationImageUrl ?? ""), showOnlineIndicator: conversationDetail?.conversationDetails?.opponentDetails?.online ?? false,size: CGSize(width: 116, height: 116), userName: isGroup == false ? (conversationDetail?.conversationDetails?.opponentDetails?.userName ?? "") : (conversationDetail?.conversationDetails?.conversationTitle ?? ""),font: .regular(size: 50))
                    .onTapGesture {
                        fullScreenImageURL = conversationDetail?.conversationDetails?.opponentDetails?.userProfileImageUrl ?? ""
                        withAnimation {
                            showFullScreenImage = true
                        }
                    }
                
                Spacer(minLength: 10)
                
                Text(isGroup == false ? (conversationDetail?.conversationDetails?.opponentDetails?.userName?.capitalizingFirstLetter() ?? "") : (conversationDetail?.conversationDetails?.conversationTitle?.capitalizingFirstLetter() ?? ""))
                    .font(appearance.fonts.chatListTitle)
                    .foregroundColor(appearance.colorPalette.chatListTitle)
                    .textCase(nil)
                Spacer()
                
                let text = NSDate().descriptiveStringLastSeen(time: conversationDetail?.conversationDetails?.opponentDetails?.lastSeen ?? 0)
                Text(isGroup == false ? ("Last seen \(text)") : ("Group  •  \(conversationDetail?.conversationDetails?.members?.count ?? 0) members"))
                    .font(appearance.fonts.messageListMessageText)
                    .foregroundColor(appearance.colorPalette.chatListUserMessage)
                    .padding(.bottom,15)
                    .textCase(nil)
            }
        }
    }
    
    func getConversationDetail(completion:@escaping()->()){
        viewModel.getConversationDetail(conversationId: self.conversationID ?? "", isGroup: self.isGroup ?? false) { data in
            self.conversationDetail = data
            completion()
        }
    }
    
    func makeGroupAdmin(){
        if selectedMember.isAdmin == false{
            viewModel.addGroupAdmin(memberId: selectedMember.userId ?? "", conversationId: conversationID ?? "") { data in
                getConversationDetail {
                }
            }
        }else{
            viewModel.removeGroupAdmin(memberId: selectedMember.userId ?? "", conversationId: conversationID ?? "") { data in
                getConversationDetail {
                    
                }
            }
        }
    }
    
    func removefromGroup(){
        viewModel.removeUserFromGroup(members: selectedMember.userId ?? "", conversationId: conversationID ?? "") { _ in
            getConversationDetail {
                
            }
            NotificationCenter.default.post(name: NSNotification.memberAddAndRemove,object: nil)
        }
    }
    
    var navBarTrailingBtn: some View {
        VStack{
            if isGroup == true{
                NavigationLink {
                    ISMEditGroupView(viewModel: self.viewModel, conversationViewModel: self.conversationViewModel, existingGroupName: conversationDetail?.conversationDetails?.conversationTitle ?? "", existingImage: conversationDetail?.conversationDetails?.conversationImageUrl ?? "", conversationId: self.conversationID)
                } label: {
                    Text("Edit")
                        .font(appearance.fonts.messageListMessageText)
                        .foregroundColor(appearance.colorPalette.userProfileEditText)
                }
            }else{
                Text("")
            }
        }
    }
    
    var navBarLeadingBtn: some View {
        HStack{
            if showFullScreenImage == true{
                Button {
                    withAnimation{
                        showFullScreenImage = false
                    }
                } label: {
                    Text("Close")
                        .font(appearance.fonts.messageListMessageText)
                        .foregroundColor(appearance.colorPalette.userProfileEditText)
                }
            }else{
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    appearance.images.CloseSheet
                        .resizable()
                        .tint(.black)
                        .foregroundColor(.black)
                        .frame(width: 17,height: 17)
                }
            }
        }
    }
}


