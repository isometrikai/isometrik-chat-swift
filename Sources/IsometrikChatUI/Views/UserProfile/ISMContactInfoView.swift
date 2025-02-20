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
    // Environment and state variables for managing the view's state and behavior
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showingAlert = false // Flag to show alerts
    @State private var alertStr = "" // Alert message string
    @State private var buttonAlrtStr = "" // Button text for alert
    var conversationViewModel = ConversationViewModel() // ViewModel for conversation management
    let conversationID : String? // ID of the current conversation
    @State var conversationDetail : ISMChatConversationDetail? // Details of the conversation
    @EnvironmentObject var realmManager : RealmManager // Realm database manager
    @State private var selectedOption : ISMChatContactInfo = .BlockUser // Selected contact option
    var viewModel = ChatsViewModel() // ViewModel for chat management
    let isGroup : Bool? // Flag to determine if the conversation is a group
    @State var navigatetoAddparticipant : Bool = false // Navigation flag for adding participants
    @State var navigatetoMedia : Bool = false // Navigation flag for media view
    @State var navigatetoInfo : Bool = false // Navigation flag for info view
    @State var navigatetoAddMember : Bool = false // Navigation flag for adding members
    
    // State variables for UI visibility
    @State var showOptions : Bool = false // Flag to show options
    @State var showInfo : Bool = false // Flag to show info
    @State var selectedMember : ISMChatGroupMember = ISMChatGroupMember() // Currently selected group member
    
    @State var onlyInfo : Bool = false // Flag to show only info
    
    @State var selectedToShowInfo : ISMChatGroupMember? // Member to show info for
    
    @State var selectedConversationId : String? // ID of the selected conversation
    @State private var showEdit : Bool = false // Flag to show edit view
    @State private var showSearch : Bool = false // Flag to show search view
    
    @State private var showFullScreenImage = false // Flag to show full-screen image
    @State private var fullScreenImageURL: String? // URL for the full-screen image
    
    // Appearance settings from the SDK
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    var userData = ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig // User configuration data
    
    // Binding variables for navigation
    @Binding var navigateToSocialProfileId : String
    @Binding var navigateToExternalUserListToAddInGroup : Bool
    @Binding var navigateToChatList : Bool
    
    //MARK:  - BODY
    var body: some View {
        // Main view structure
        VStack {
            if showFullScreenImage {
                // Display full-screen image when tapped
                ISMChatImageCahcingManger.viewImage(url: fullScreenImageURL ?? "")
                    .resizable()
                    .scaledToFit()
            } else {
                GeometryReader { geometry in
                    List {
                        // Section for user bio and profile information
                        Section {
                            // Header for the section
                            HStack(alignment: .center) {
                                Spacer()
                                customHeaderView() // Custom header view for user info
                                    .listRowInsets(EdgeInsets())
                                Spacer()
                            }
                        }.listRowSeparatorTint(Color.border)
                            .listRowBackground(Color.clear)
                        
                        // Display conversation details if not a group
                        if isGroup == false {
                            Section {
                                // Display opponent's bio or profile
                                if ISMChatSdk.getInstance().getFramework() == .SwiftUI {
                                    Text(conversationDetail?.conversationDetails?.opponentDetails?.metaData?.about ?? "Hey there!")
                                        .font(appearance.fonts.messageListMessageText)
                                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                } else {
                                    // Button to view profile
                                    Button {
                                        // Set navigation ID based on info state
                                        if onlyInfo == true {
                                            navigateToSocialProfileId = selectedToShowInfo?.userIdentifier ?? ""
                                        } else {
                                            navigateToSocialProfileId = self.conversationDetail?.conversationDetails?.opponentDetails?.userIdentifier ?? ""
                                        }
                                    } label: {
                                        HStack {
                                            appearance.images.mediaIcon
                                                .resizable()
                                                .frame(width: 29, height: 29)
                                            Text("View Profile")
                                                .font(appearance.fonts.messageListMessageText)
                                                .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                            Spacer()
                                        }
                                    }
                                }
                            }.listRowSeparatorTint(Color.border)
                        }
                        // Section for media, links, and documents
                        Section {
                            NavigationLink {
                                ISMUserMediaView(viewModel: viewModel)
                                    .environmentObject(self.realmManager)
                            } label: {
                                HStack {
                                    appearance.images.mediaIcon
                                        .resizable()
                                        .frame(width: 29, height: 29)
                                    Text("Media, Links and Docs")
                                        .font(appearance.fonts.messageListMessageText)
                                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                    Spacer()
                                    // Count of media items
                                    let count = ((realmManager.medias?.count ?? 0) + (realmManager.filesMedia?.count ?? 0) + (realmManager.linksMedia?.count ?? 0))
                                    Text(count.description)
                                        .font(appearance.fonts.messageListMessageText)
                                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                }
                            }
                        } header: {
                            // Additional header UI can be added here
                        }.listRowSeparatorTint(Color.border)
                        
                        // Section for group members if it's a group
                        if isGroup == true {
                            Section {
                                // Check if the user is an admin
                                if conversationDetail?.conversationDetails?.usersOwnDetails?.isAdmin == true {
                                    // Button to add members
                                    Button {
                                        // Navigate based on external member add property
                                        if ISMChatSdkUI.getInstance().getChatProperties().externalMemberAddInGroup == true {
                                            navigateToExternalUserListToAddInGroup = true
                                        } else {
                                            navigatetoAddMember = true
                                        }
                                    } label: {
                                        HStack(spacing: 12) {
                                            appearance.images.addMembers
                                                .resizable()
                                                .frame(width: 29, height: 29, alignment: .center)
                                            Text("Add Members")
                                                .font(appearance.fonts.messageListMessageText)
                                                .foregroundColor(appearance.colorPalette.messageListReplyToolbarRectangle)
                                        }
                                    }
                                }
                                // Display group members
                                if let members = conversationDetail?.conversationDetails?.members {
                                    ForEach(members, id: \.self) { member in
                                        ISMGroupMemberSubView(member: member, selectedMember: $selectedMember) // Subview for each group member
                                    }
                                }
                            } header: {
                                // Header showing the count of members
                                HStack {
                                    Text("\(conversationDetail?.conversationDetails?.members?.count ?? 0) Members")
                                        .font(appearance.fonts.contactInfoHeader)
                                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                        .textCase(nil)
                                    Spacer()
                                    // Navigation link to search participants
                                    NavigationLink {
                                        ISMSearchParticipants(viewModel: self.viewModel, conversationViewModel: self.conversationViewModel, conversationID: self.conversationID)
                                    } label: {
                                        appearance.images.searchMagnifingGlass
                                            .resizable()
                                            .frame(width: 28, height: 28, alignment: .center)
                                            .padding(8)
                                    }
                                }.listRowInsets(EdgeInsets())
                            } footer: {
                                Text("") // Footer can be customized
                            }.listRowSeparatorTint(Color.border)
                        }
                        otherSection() // Additional sections can be added here
                    }.background(Color.backgroundView)
                        .scrollContentBackground(.hidden)
                        // Disable scrolling if content fits in screen
//                        .scrollDisabled(geometry.size.height >= geometry.frame(in: .global).height)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline) // Set navigation bar title display mode
        .navigationBarBackButtonHidden(true) // Hide back button
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    // Set title based on group status
                    Text(isGroup == false ? "Contact Info" : "Group Info")
                        .font(appearance.fonts.navigationBarTitle)
                        .foregroundColor(appearance.colorPalette.navigationBarTitle)
                }
            }
        }
        .fullScreenCover(isPresented: $showEdit, content: {
            NavigationStack{
                ISMEditGroupView(viewModel: self.viewModel, conversationViewModel: self.conversationViewModel, existingGroupName: conversationDetail?.conversationDetails?.conversationTitle ?? "", existingImage: conversationDetail?.conversationDetails?.conversationImageUrl ?? "", conversationId: self.conversationID)
            }
        })
        .navigationBarItems(leading: navBarLeadingBtn, trailing: navBarTrailingBtn) // Set navigation bar items
        // Navigation links for various views can be added here
        .onChange(of: selectedMember, { _, _ in
            // Show options if selected member is not the current user
            if selectedMember.userId != userData?.userId {
                showOptions = true
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.memberAddAndRemove)) { _ in
            getConversationDetail {} // Refresh conversation details on member add/remove
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.updateGroupInfo)) { _ in
            getConversationDetail {
                // Update group image and name
                realmManager.updateImageAndNameOfGroup(name: conversationDetail?.conversationDetails?.conversationTitle ?? "", image: conversationDetail?.conversationDetails?.conversationImageUrl ?? "", convID: self.conversationID ?? "")
            }
        }
        // Navigation links for various views can be added here
        .confirmationDialog("", isPresented: $showOptions) {
            Button {
                navigatetoInfo = true // Navigate to info view
            } label: {
                Text("Info")
            }
            // Admin options for group management
            if checkIfAdmin() == true {
                Button {
                    makeGroupAdmin() // Toggle group admin status
                } label: {
                    Text(selectedMember.isAdmin == false ? "Make Group Admin" : "Dismiss as Admin")
                }
                Button {
                    removefromGroup() // Remove member from group
                } label: {
                    Text("Remove from Group")
                }
            }
            Button("Cancel", role: .cancel, action: {}) // Cancel button
        } message: {
            Text(selectedMember.userName ?? "") // Display selected member's name
        }
    }
    
    //MARK:  - CONFIGURE
    // Function to check if the current user is an admin
    func checkIfAdmin() -> Bool {
        if conversationDetail?.conversationDetails?.usersOwnDetails?.isAdmin == true {
            return true // The user is an admin
        } else {
            return false // The user is not an admin
        }
    }
    
    // Function to create the other section of the view
    func otherSection() -> some View {
        return Section {
            let blocked = conversationDetail?.conversationDetails?.messagingDisabled // Check if messaging is disabled
            let unmuted = conversationDetail?.conversationDetails?.config?.pushNotifications // Check if notifications are enabled
            let contactOptions = ISMChatContactInfo.options(blocked: blocked ?? false, unmuted: unmuted ?? false, singleConversation: !(isGroup ?? false), onlyInfo: self.onlyInfo) // Get contact options
            ForEach(contactOptions, id: \.self) { obj in
                HStack {
                    Text(obj.title) // Display option title
                        .font(appearance.fonts.messageListMessageText)
                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                    Button {
                        // Set alert message based on selected option
                        if obj == .BlockUser {
                            self.alertStr = "Do you want to Block this User?"
                            self.buttonAlrtStr = "Block"
                        } else if obj == .ClearChat {
                            self.alertStr = "Clear all messages from \(conversationDetail?.conversationDetails?.opponentDetails?.userName ?? "this chat")? \n This chat will be empty but will remain in your chat list."
                            self.buttonAlrtStr = "Delete"
                        } else if obj == .DeleteUser {
                            self.alertStr = "Delete Chat?"
                            self.buttonAlrtStr = "Delete"
                        } else if obj == .UnBlockUser {
                            self.alertStr = "Do you want to UnBlock this User?"
                            self.buttonAlrtStr = "UnBlock"
                        } else if obj == .ExitGroup {
                            self.alertStr = "Do you want to exit this group?"
                            self.buttonAlrtStr = "Yes"
                        } else if obj == .MuteNotification {
                            self.alertStr = "Disable notifications?"
                            self.buttonAlrtStr = "Yes"
                        } else if obj == .UnMuteNotification {
                            self.alertStr = "Enable notifications?"
                            self.buttonAlrtStr = "Yes"
                        }
                        self.selectedOption = obj // Set selected option
                        showingAlert = true // Show alert
                    } label: {
                        // Button label can be customized
                    }
                }
                .confirmationDialog("", isPresented: $showingAlert) {
                    Button(buttonAlrtStr, role: .destructive) {
                        manageFlow() // Manage the flow based on selected option
                    }
                } message: {
                    Text(alertStr) // Display alert message
                }
            }
        } header: {
            Text("") // Header can be customized
        } footer: {
            // Footer for group creation details
            if isGroup == true {
                let dateVar = NSDate()
                let date = dateVar.doubletoDate(time: conversationDetail?.conversationDetails?.createdAt ?? 0)
                VStack(alignment: .leading) {
                    let user = userData?.userName == (conversationDetail?.conversationDetails?.createdByUserName ?? "") ? ConstantStrings.you.lowercased() : (conversationDetail?.conversationDetails?.createdByUserName ?? "")
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
    
    // Function to manage the flow based on selected options
    func manageFlow() {
        if selectedOption == .BlockUser {
            // Block user logic
            conversationViewModel.blockUnBlockUser(opponentId: (conversationDetail?.conversationDetails?.opponentDetails?.userId ?? selectedToShowInfo?.userId) ?? "", needToBlock: true) { obj in
                print("Success")
                presentationMode.wrappedValue.dismiss() // Dismiss the view
            }
        } else if selectedOption == .UnBlockUser {
            // Unblock user logic
            conversationViewModel.blockUnBlockUser(opponentId: conversationDetail?.conversationDetails?.opponentDetails?.userId ?? (selectedToShowInfo?.userId ?? ""), needToBlock: false) { obj in
                print("Success")
                presentationMode.wrappedValue.dismiss() // Dismiss the view
            }
        } else if selectedOption == .ClearChat {
            // Clear chat logic
            conversationViewModel.clearChat(conversationId: conversationID ?? "") {
                self.realmManager.clearMessages() // Clear messages from realm
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    self.realmManager.clearMessages(convID: conversationID ?? "") // Clear messages for specific conversation
                    navigateToChatList = true // Navigate to chat list
                })
            }
        } else if selectedOption == .DeleteUser {
            // Delete conversation logic
            conversationViewModel.deleteConversation(conversationId: conversationID ?? "") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    realmManager.deleteConversation(convID: conversationID ?? "") // Delete conversation from realm
                    navigateToChatList = true // Navigate to chat list
                })
            }
        } else if selectedOption == .ExitGroup {
            // Exit group logic
            viewModel.exitGroup(conversationId: conversationID ?? "") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    realmManager.deleteConversation(convID: conversationID ?? "") // Delete conversation from realm
                    realmManager.deleteMessagesThroughConvId(convID: conversationID ?? "") // Delete messages for conversation
                    realmManager.deleteMediaThroughConversationId(convID: conversationID ?? "") // Delete media for conversation
                    NavigationUtil.popToRootView() // Navigate back to root view
                })
            }
        } else if selectedOption == .MuteNotification {
            // Mute notifications logic
            conversationViewModel.muteUnmuteNotification(conversationId: conversationID ?? "", pushNotifications: false) { _ in
                print("Success")
                conversationDetail?.conversationDetails?.config?.pushNotifications = false // Update notification status
            }
        } else if selectedOption == .UnMuteNotification {
            // Unmute notifications logic
            conversationViewModel.muteUnmuteNotification(conversationId: conversationID ?? "", pushNotifications: true) { _ in
                print("Success")
                conversationDetail?.conversationDetails?.config?.pushNotifications = true // Update notification status
            }
        }
    }
    
    // Function to create the custom header view
    func customHeaderView() -> some View {
        VStack(alignment: .center) {
            if onlyInfo == true {
                // Display user avatar based on user type
                if conversationDetail?.conversationDetails?.opponentDetails?.metaData?.userType == 9 && appearance.images.defaultImagePlaceholderForBussinessUser != nil, let avatar = conversationDetail?.conversationDetails?.opponentDetails?.userProfileImageUrl, ISMChatHelper.shouldShowPlaceholder(avatar: avatar) {
                    appearance.images.defaultImagePlaceholderForBussinessUser?
                        .resizable()
                        .frame(width: 116, height: 116, alignment: .center)
                        .cornerRadius(116/2)
                        .onTapGesture {
                            let image = conversationDetail?.conversationDetails?.opponentDetails?.userProfileImageUrl ?? (selectedToShowInfo?.userProfileImageUrl ?? "")
                            if shouldShowImage(avatar: image) {
                                fullScreenImageURL = image // Set full-screen image URL
                                withAnimation {
                                    showFullScreenImage = true // Show full-screen image
                                }
                            }
                        }
                } else if conversationDetail?.conversationDetails?.opponentDetails?.metaData?.userType == 1 && appearance.images.defaultImagePlaceholderForNormalUser != nil, let avatar = conversationDetail?.conversationDetails?.opponentDetails?.userProfileImageUrl, ISMChatHelper.shouldShowPlaceholder(avatar: avatar) {
                    appearance.images.defaultImagePlaceholderForNormalUser?
                        .resizable()
                        .frame(width: 116, height: 116, alignment: .center)
                        .cornerRadius(116/2)
                        .onTapGesture {
                            let image = conversationDetail?.conversationDetails?.opponentDetails?.userProfileImageUrl ?? (selectedToShowInfo?.userProfileImageUrl ?? "")
                            if shouldShowImage(avatar: image) {
                                fullScreenImageURL = image // Set full-screen image URL
                                withAnimation {
                                    showFullScreenImage = true // Show full-screen image
                                }
                            }
                        }
                } else {
                    UserAvatarView(avatar: (conversationDetail?.conversationDetails?.opponentDetails?.userProfileImageUrl ?? (selectedToShowInfo?.userProfileImageUrl ?? "")), showOnlineIndicator: conversationDetail?.conversationDetails?.opponentDetails?.online ?? (selectedToShowInfo?.online ?? false), size: CGSize(width: 116, height: 116), userName: conversationDetail?.conversationDetails?.opponentDetails?.userName ?? (selectedToShowInfo?.userName ?? ""), font: .regular(size: 50))
                        .onTapGesture {
                            let image = conversationDetail?.conversationDetails?.opponentDetails?.userProfileImageUrl ?? (selectedToShowInfo?.userProfileImageUrl ?? "")
                            if shouldShowImage(avatar: image) {
                                fullScreenImageURL = image // Set full-screen image URL
                                withAnimation {
                                    showFullScreenImage = true // Show full-screen image
                                }
                            }
                        }
                }
                
                Spacer(minLength: 10)
                // Display user name
                Text(conversationDetail?.conversationDetails?.opponentDetails?.userName?.capitalizingFirstLetter() ?? (selectedToShowInfo?.userName?.capitalizingFirstLetter() ?? ""))
                    .font(appearance.fonts.chatListTitle)
                    .foregroundColor(appearance.colorPalette.chatListTitle)
                    .textCase(nil)
                Spacer()
                
                // Display last seen or online status
                let date = NSDate().descriptiveStringLastSeen(time: conversationDetail?.conversationDetails?.opponentDetails?.lastSeen ?? 0)
                if let text = self.conversationDetail?.conversationDetails?.opponentDetails?.online == true ? "Online" : "Last seen \(date)" {
                    Text(text)
                        .font(appearance.fonts.messageListMessageText)
                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                        .padding(.bottom, 15)
                        .textCase(nil)
                }
            } else {
                // Similar logic for displaying user avatar and info when not in onlyInfo mode
                if conversationDetail?.conversationDetails?.opponentDetails?.metaData?.userType == 9 && appearance.images.defaultImagePlaceholderForBussinessUser != nil, let avatar = conversationDetail?.conversationDetails?.opponentDetails?.userProfileImageUrl, ISMChatHelper.shouldShowPlaceholder(avatar: avatar) {
                    appearance.images.defaultImagePlaceholderForBussinessUser?
                        .resizable()
                        .frame(width: 116, height: 116, alignment: .center)
                        .cornerRadius(116/2)
                        .onTapGesture {
                            let image = conversationDetail?.conversationDetails?.opponentDetails?.userProfileImageUrl ?? (selectedToShowInfo?.userProfileImageUrl ?? "")
                            if shouldShowImage(avatar: image) {
                                fullScreenImageURL = image // Set full-screen image URL
                                withAnimation {
                                    showFullScreenImage = true // Show full-screen image
                                }
                            }
                        }
                } else if conversationDetail?.conversationDetails?.opponentDetails?.metaData?.userType == 1 && appearance.images.defaultImagePlaceholderForNormalUser != nil, let avatar = conversationDetail?.conversationDetails?.opponentDetails?.userProfileImageUrl, ISMChatHelper.shouldShowPlaceholder(avatar: avatar) {
                    appearance.images.defaultImagePlaceholderForNormalUser?
                        .resizable()
                        .frame(width: 116, height: 116, alignment: .center)
                        .cornerRadius(116/2)
                        .onTapGesture {
                            let image = conversationDetail?.conversationDetails?.opponentDetails?.userProfileImageUrl ?? (selectedToShowInfo?.userProfileImageUrl ?? "")
                            if shouldShowImage(avatar: image) {
                                fullScreenImageURL = image // Set full-screen image URL
                                withAnimation {
                                    showFullScreenImage = true // Show full-screen image
                                }
                            }
                        }
                } else {
                    UserAvatarView(avatar: isGroup == false ? (conversationDetail?.conversationDetails?.opponentDetails?.userProfileImageUrl ?? "") : (conversationDetail?.conversationDetails?.conversationImageUrl ?? ""), showOnlineIndicator: conversationDetail?.conversationDetails?.opponentDetails?.online ?? false, size: CGSize(width: 116, height: 116), userName: isGroup == false ? (conversationDetail?.conversationDetails?.opponentDetails?.userName ?? "") : (conversationDetail?.conversationDetails?.conversationTitle ?? ""), font: .regular(size: 50))
                        .onTapGesture {
                            let image = isGroup == true ? (conversationDetail?.conversationDetails?.conversationImageUrl ?? "") : (conversationDetail?.conversationDetails?.opponentDetails?.userProfileImageUrl ?? "")
                            if shouldShowImage(avatar: image) {
                                fullScreenImageURL = image // Set full-screen image URL
                                withAnimation {
                                    showFullScreenImage = true // Show full-screen image
                                }
                            }
                        }
                }
                
                Spacer(minLength: 10)
                
                // Display user name or group title
                Text(isGroup == false ? (conversationDetail?.conversationDetails?.opponentDetails?.userName?.capitalizingFirstLetter() ?? "") : (conversationDetail?.conversationDetails?.conversationTitle?.capitalizingFirstLetter() ?? ""))
                    .font(appearance.fonts.chatListTitle)
                    .foregroundColor(appearance.colorPalette.chatListTitle)
                    .textCase(nil)
                Spacer()
                
                // Display last seen or group member count
                let date = NSDate().descriptiveStringLastSeen(time: conversationDetail?.conversationDetails?.opponentDetails?.lastSeen ?? 0)
                if let text = self.conversationDetail?.conversationDetails?.opponentDetails?.online == true ? "Online" : "Last seen \(date)" {
                    Text(isGroup == false ? text : ("Group  •  \(conversationDetail?.conversationDetails?.members?.count ?? 0) members"))
                        .font(appearance.fonts.messageListMessageText)
                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                        .padding(.bottom, 15)
                        .textCase(nil)
                }
            }
        }
    }
    
    // Function to check if the avatar should be shown
    private func shouldShowImage(avatar: String) -> Bool {
        return avatar.isEmpty == false &&
               avatar != "https://res.cloudinary.com/dxkoc9aao/image/upload/v1616075844/kesvhgzyiwchzge7qlsz_yfrh9x.jpg" &&
               avatar != "https://admin-media.isometrik.io/profile/def_profile.png" &&
               avatar.contains("svg") == false
    }
    
    // Function to get conversation details
    func getConversationDetail(completion: @escaping () -> ()) {
        viewModel.getConversationDetail(conversationId: self.conversationID ?? "", isGroup: self.isGroup ?? false) { data in
            self.conversationDetail = data // Update conversation details
            completion() // Call completion handler
        }
    }
    
    // Function to toggle group admin status
    func makeGroupAdmin() {
        if selectedMember.isAdmin == false {
            viewModel.addGroupAdmin(memberId: selectedMember.userId ?? "", conversationId: conversationID ?? "") { data in
                getConversationDetail {} // Refresh conversation details
            }
        } else {
            viewModel.removeGroupAdmin(memberId: selectedMember.userId ?? "", conversationId: conversationID ?? "") { data in
                getConversationDetail {} // Refresh conversation details
            }
        }
    }
    
    // Function to remove a member from the group
    func removefromGroup() {
        viewModel.removeUserFromGroup(members: selectedMember.userId ?? "", conversationId: conversationID ?? "") { _ in
            getConversationDetail {} // Refresh conversation details
            NotificationCenter.default.post(name: NSNotification.memberAddAndRemove, object: nil) // Notify member add/remove
        }
    }
    
    // Navigation button for the trailing item in the navigation bar
    var navBarTrailingBtn: some View {
        VStack {
            if isGroup == true {
                Button {
                    showEdit = true
                } label: {
                    Text("Edit")
                        .font(appearance.fonts.messageListMessageText)
                        .foregroundColor(appearance.colorPalette.userProfileEditText)
                }

//                NavigationLink {
//                    ISMEditGroupView(viewModel: self.viewModel, conversationViewModel: self.conversationViewModel, existingGroupName: conversationDetail?.conversationDetails?.conversationTitle ?? "", existingImage: conversationDetail?.conversationDetails?.conversationImageUrl ?? "", conversationId: self.conversationID)
//                } label: {
//                    
//                }
            } else {
                Text("") // Placeholder for non-group case
            }
        }
    }
    
    // Navigation button for the leading item in the navigation bar
    var navBarLeadingBtn: some View {
        HStack {
            if showFullScreenImage == true {
                Button {
                    withAnimation {
                        showFullScreenImage = false // Close full-screen image
                    }
                } label: {
                    Text("Close")
                        .font(appearance.fonts.messageListMessageText)
                        .foregroundColor(appearance.colorPalette.userProfileEditText)
                }
            } else {
                Button {
                    presentationMode.wrappedValue.dismiss() // Dismiss the view
                } label: {
                    appearance.images.backButton
                        .resizable()
                        .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
                }
            }
        }
    }
}


