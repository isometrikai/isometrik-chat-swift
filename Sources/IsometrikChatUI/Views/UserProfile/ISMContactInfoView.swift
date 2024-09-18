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
    @State var updateData : Bool = false
    
    @State var onlyInfo : Bool = false
    
    @State var selectedToShowInfo : ISMChatGroupMember?
    
    @State var selectedConversationId : String?
    @State private var showEdit : Bool = false
    @State private var showSearch : Bool = false
    
    @State private var showFullScreenImage = false
    @State private var fullScreenImageURL: String?
    
    @State var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State var themeImage = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    @State public var userData = ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig
    
    @Binding var navigateToAddParticipantsInGroupViaDelegate : Bool
    @Binding var navigateToSocialProfileId : String
    
    //MARK:  - BODY
    var body: some View {
        VStack{
            if showFullScreenImage {
                // To show profile Image on tap of user Image
                ISMChatImageCahcingManger.networkImage(url: fullScreenImageURL ?? "",isprofileImage: false)
                    .resizable()
                    .scaledToFit()
            }else{
                List {
                    //Bio
                    if isGroup == false{
                        Section {
                            if ISMChatSdk.getInstance().getFramework() == .SwiftUI{
                                Text(conversationDetail?.conversationDetails?.opponentDetails?.metaData?.about ?? "")
                                    .font(themeFonts.messageListMessageText)
                                    .foregroundColor(themeColor.messageListHeaderTitle)
                            }else{
                                Button {
                                    navigateToSocialProfileId = conversationDetail?.conversationDetails?.opponentDetails?.metaData?.userId ?? ""
                                } label: {
                                    HStack{
                                        themeImage.mediaIcon
                                            .resizable()
                                            .frame(width: 29,height: 29)
                                        Text("View Social Profile")
                                            .font(themeFonts.messageListMessageText)
                                            .foregroundColor(themeColor.messageListHeaderTitle)
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
                        Button {
                            navigatetoMedia = true
                        } label: {
                            HStack{
                                themeImage.mediaIcon
                                    .resizable()
                                    .frame(width: 29,height: 29)
                                Text("Media, Links and Docs")
                                    .font(themeFonts.messageListMessageText)
                                    .foregroundColor(themeColor.messageListHeaderTitle)
                                Spacer()
                                let count = ((realmManager.medias?.count ?? 0) + (realmManager.filesMedia?.count ?? 0) + (realmManager.linksMedia?.count ?? 0))
                                Text(count.description)
                                    .font(themeFonts.messageListMessageText)
                                    .foregroundColor(themeColor.chatListUserMessage)
                                themeImage.disclouser
                                    .resizable()
                                    .frame(width: 7,height: 12)
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
                                Button {
                                    if ISMChatSdk.getInstance().getFramework() == .UIKit{
                                        navigateToAddParticipantsInGroupViaDelegate = true
                                    }else{
                                        navigatetoAddparticipant = true
                                    }
                                } label: {
                                    HStack(spacing: 12){
                                        
                                        themeImage.addMembers
                                            .resizable()
                                            .frame(width: 29, height: 29, alignment: .center)
                                        
                                        Text("Add Members")
                                            .font(themeFonts.messageListMessageText)
                                            .foregroundColor(themeColor.messageListReplyToolbarRectangle)
                                    }
                                }.frame(height: 50)
                            }
                            
                            
                            if let members = conversationDetail?.conversationDetails?.members{
                                ForEach(members, id: \.self) { member in
                                    ISMGroupMemberSubView(member: member, selectedMember: $selectedMember)
                                        .frame(height: 50)
                                }
                            }
                        } header: {
                            HStack{
                                Text("\(conversationDetail?.conversationDetails?.members?.count ?? 0) Members")
                                    .font(themeFonts.contactInfoHeader)
                                    .foregroundColor(themeColor.messageListHeaderTitle)
                                    .textCase(nil)
                                Spacer()
                                Button {
                                    showSearch = true
                                } label: {
                                    themeImage.searchMagnifingGlass
                                        .resizable()
                                        .frame(width: 28, height: 28, alignment: .center)
                                        .padding(8)
                                }
                                
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
                        .font(themeFonts.navigationBarTitle)
                        .foregroundColor(themeColor.navigationBarTitle)
                }
            }
        }
        .navigationBarItems(leading: navBarLeadingBtn, trailing: navBarTrailingBtn)
        .background(NavigationLink("", destination:  ISMAddParticipantsView(viewModel: self.conversationViewModel,conversationId: self.conversationID).environmentObject(realmManager), isActive: $navigatetoAddparticipant))
        .background(NavigationLink("", destination:  ISMUserMediaView(viewModel:viewModel)
            .environmentObject(self.realmManager), isActive: $navigatetoMedia))
        .background(NavigationLink("", destination:  ISMContactInfoView(conversationID: self.selectedConversationId,viewModel:self.viewModel, isGroup: false,onlyInfo: true,selectedToShowInfo : self.selectedToShowInfo,navigateToAddParticipantsInGroupViaDelegate: $navigateToAddParticipantsInGroupViaDelegate,navigateToSocialProfileId: $navigateToSocialProfileId).environmentObject(self.realmManager), isActive: $showInfo))
        .background(NavigationLink("", destination:  ISMSearchParticipants(viewModel: self.viewModel, conversationViewModel: self.conversationViewModel ,conversationID: self.conversationID), isActive: $showSearch))
        .background(NavigationLink("", destination:  ISMEditGroupView(viewModel: self.viewModel, conversationViewModel: self.conversationViewModel, existingGroupName: conversationDetail?.conversationDetails?.conversationTitle ?? "", existingImage: conversationDetail?.conversationDetails?.conversationImageUrl ?? "", conversationId: self.conversationID,updateData : $updateData), isActive: $showEdit))
        .onChange(of: selectedMember, { _, _ in
            if selectedMember.userId != userData.userId{
                showOptions = true
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.memberAddAndRemove)) { _ in
            getConversationDetail {}
        }
        .onChange(of: updateData, { _, _ in
            getConversationDetail {
                realmManager.updateImageAndNameOfGroup(name: conversationDetail?.conversationDetails?.conversationTitle ?? "", image: conversationDetail?.conversationDetails?.conversationImageUrl ?? "", convID: self.conversationID ?? "")
            }
        })
        .confirmationDialog("", isPresented: $showOptions) {
            Button {
                selectedToShowInfo = selectedMember
                selectedConversationId = realmManager.getConversationId(userId: selectedMember.userId ?? "")
                showInfo = true
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
                        .font(themeFonts.messageListMessageText)
                        .foregroundColor(themeColor.messageListHeaderTitle)
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
                        .font(themeFonts.chatListUserMessage)
                        .foregroundColor(themeColor.chatListUserMessage)
                    Text("Created on \(date)")
                        .font(themeFonts.chatListUserMessage)
                        .foregroundColor(themeColor.chatListUserMessage)
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
                    .font(themeFonts.chatListTitle)
                    .foregroundColor(themeColor.chatListTitle)
                    .textCase(nil)
                Spacer()
                let text = NSDate().descriptiveStringLastSeen(time: conversationDetail?.conversationDetails?.opponentDetails?.lastSeen ?? 0)
                Text(text)
                    .font(themeFonts.messageListMessageText)
                    .foregroundColor(themeColor.chatListUserMessage)
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
                    .font(themeFonts.chatListTitle)
                    .foregroundColor(themeColor.chatListTitle)
                    .textCase(nil)
                Spacer()
                
                Text(isGroup == false ? (conversationDetail?.conversationDetails?.opponentDetails?.userIdentifier ?? "") : ("Group  •  \(conversationDetail?.conversationDetails?.members?.count ?? 0) members"))
                    .font(themeFonts.messageListMessageText)
                    .foregroundColor(themeColor.chatListUserMessage)
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
                Button {
                   showEdit = true
                } label: {
                    Text("Edit")
                        .font(themeFonts.messageListMessageText)
                        .foregroundColor(themeColor.userProfileEditText)
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
                        .font(themeFonts.messageListMessageText)
                        .foregroundColor(themeColor.userProfileEditText)
                }
            }else{
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    themeImage.CloseSheet
                        .resizable()
                        .tint(.black)
                        .foregroundColor(.black)
                        .frame(width: 17,height: 17)
                }
            }
        }
    }
}


