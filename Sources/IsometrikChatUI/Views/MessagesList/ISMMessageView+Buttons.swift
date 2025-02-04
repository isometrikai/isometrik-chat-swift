//
//  ISMMessageView+Buttons.swift
//  ISMChatSdk
//
//  Created by Rasika on 15/04/24.
//

import Foundation
import SwiftUI
import ISMSwiftCall
import IsometrikChat


extension ISMMessageView{
    
    //MARK: - AUDIO MESSAGE BUTTON
    
    /// Displays an alert when microphone permission is denied.
    func showPermissionDeniedAlert() {
        let alertController = UIAlertController(
            title: "Audio Permission Required",
            message: "We need access to your microphone for recording audio. Please enable it in Settings.",
            preferredStyle: .alert
        )
        
        // Action to open app settings
        let settingsAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            }
        }
        
        // Action to cancel the alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        // Presenting the alert on the main thread
        DispatchQueue.main.async {
            UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK: - MULTIPLE FORWARD MESSAGE BUTTON VIEW
    
    /// Returns a view for the forward message button based on selection state.
    func multipleForwardMessageButtonView(message : MessagesDB) -> some View{
        if forwardMessageSelected.contains(where: { msg in
            msg.messageId == message.messageId
        }){
            return   appearance.images.selected
                .resizable()
                .frame(width: 20, height: 20)
        }else{
            return    appearance.images.deselected
                .resizable()
                .frame(width: 20, height: 20)
        }
    }
    
    //MARK: - MULTIPLE DELETE MESSAGE BUTTON VIEW
    
    /// Returns a view for the delete message button based on selection state.
    func multipleDeleteMessageButtonView(message: MessagesDB) -> some View {
        if deleteMessage.contains(where: { msg in
            msg.messageId == message.messageId
        }) {
            return  appearance.images.selected
                .resizable()
                .frame(width: 20, height: 20)
        } else {
            return appearance.images.deselected
                .resizable()
                .frame(width: 20, height: 20)
        }
    }
    
    //MARK: - SCROLL TO BOTTOM MESSAGE
    
    /// Returns a button that scrolls to the bottom of the message list.
    func scrollToBottomButton() -> some View {
        return Button(action: {
            parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
        }, label: {
            appearance.images.scrollToBottomArrow
                .resizable()
                .frame(width: 32, height: 32)
                .padding()
        })
        .shadow(color: Color.black.opacity(0.3),
                radius: 3,
                x: 3,
                y: 3)
    }
    
    //MARK: - NAVIGATION LEADING BUTTON
    
    /// Returns a view containing navigation buttons on the leading side of the navigation bar.
    func navigationBarLeadingButtons() -> some View {
        HStack {
            backButtonView()
            
            Spacer().frame(width: 8)
            
            if self.fromBroadCastFlow  == true{
                broadcastButtonView()
            } else {
                profileButtonView()
            }
        }
    }
    
    /// Saves the last input text if it has not been sent.
    func saveMyLastInputTextIfNotSent(){
        self.realmManager.saveLastInputTextInConversation(text: textFieldtxt, conversationId: self.conversationID ?? "")
    }
    
    /// Returns a view for the back button with appropriate actions based on the state.
    func backButtonView() -> some View {
        HStack{
            if stateViewModel.showforwardMultipleMessage || (stateViewModel.showDeleteMultipleMessage && chatProperties.multipleSelectionOfMessageForDelete == true) {
                Button {
                    stateViewModel.showforwardMultipleMessage = false
                    forwardMessageSelected.removeAll()
                    stateViewModel.showDeleteMultipleMessage = false
                    deleteMessage.removeAll()
                } label: {
                    appearance.images.dismissButton
                        .resizable()
                        .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
                }
            }else {
                Button(action: {
                    backButtonAction()
                }) {
                    appearance.images.backButton
                        .resizable()
                        .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
                }
            }
        }
    }
    
    /// Handles the action when the back button is pressed.
    func backButtonAction(){
        //just resetting unread count for this conversation while going back to conversation list
        //            realmManager.updateUnreadCountThroughConId(conId: self.conversationID ?? "",count: 0,reset:true)
        //sometimes keyboard doesn't get dismissed
        saveMyLastInputTextIfNotSent()
        OndisappearOnBack()
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        NotificationCenter.default.post(name: NSNotification.updateChatBadgeCount, object: nil, userInfo: nil)
        //dismiss
        delegate?.backButtonAction()
        presentationMode.wrappedValue.dismiss()
    }
    
    /// Detects the swipe direction based on the drag gesture value.
    func detectDirection(value: DragGesture.Value) -> SwipeHVDirection {
        if value.translation.width < -60 {
            return .left
        } else if value.translation.width > 60 {
            return .right
        } else {
            return .none
        }
    }
    
    /// Returns a view for the broadcast button with appropriate actions.
    func broadcastButtonView() -> some View {
        Button {
            if ISMChatSdk.getInstance().getFramework() == .UIKit {
                delegate?.navigateToBroadCastInfo(groupcastId: self.groupCastId ?? "", groupcastTitle: self.groupConversationTitle ?? "", groupcastImage: self.groupImage ?? "")
                
            } else {
                stateViewModel.navigateToGroupCastInfo = true
            }
        } label: {
            if ISMChatSdk.getInstance().getFramework() == .UIKit {
                UserAvatarView(
                    avatar: groupImage ?? "",
                    showOnlineIndicator: false,
                    size: CGSize(width: 40, height: 40),
                    userName: groupConversationTitle ?? "",
                    font: appearance.fonts.messageListMessageText
                )
            }else{
                BroadCastAvatarView(
                    size: CGSize(width: 40, height: 40),
                    broadCastImageSize: CGSize(width: 17.7, height: 17.7),
                    broadCastLogo: appearance.images.broadCastLogo
                )
            }
            Text(getBroadcastTitle())
                .frame(width: 200,alignment: .leading)
                .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                .font(appearance.fonts.messageListHeaderTitle)
        }
    }
    
    /// Returns the title for the broadcast based on available data.
    func getBroadcastTitle() -> String {
        if let groupConversationTitle = groupConversationTitle, !groupConversationTitle.isEmpty, groupConversationTitle != "Default" {
            return groupConversationTitle
        } else {
            return "Messages"
        }
    }
    
    /// Returns a view for the profile button with appropriate actions based on conditions.
    func profileButtonView() -> some View {
        HStack {
            if ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup != true {
                Button {
                    // Action Logic for Button based on conditions
                    if ISMChatSdkUI.getInstance().getChatProperties().navigateToAppProfileFromMessageList == true {
                        if (isGroup ?? false) == true {
                            self.stateViewModel.navigateToUserProfile = true
                        } else {
                            let storeId = self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.storeId
                            let userId = self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.userId
                            ?? opponenDetail?.metaData?.userId ?? opponenDetail?.userIdentifier
                            ?? self.conversationDetail?.conversationDetails?.opponentDetails?.userIdentifier
                            
                            delegate?.navigateToAppProfile(userId: userId ?? "", storeId: storeId ?? "", userType: self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.userType ?? 0)
                        }
                    } else {
                        self.stateViewModel.navigateToUserProfile = true
                    }
                } label: {
                    customView() // Your custom view for the button
                }
            } else {
                customView() // No button, just the view for groups
            }
        }
    }
    
    /// Returns a custom view for displaying user information.
    func customView() -> some View{
        HStack{
            if opponenDetail?.metaData?.userType == 9 && appearance.images.defaultImagePlaceholderForBussinessUser != nil, let avatar =  opponenDetail?.userProfileImageUrl, ISMChatHelper.shouldShowPlaceholder(avatar: avatar) {
                appearance.images.defaultImagePlaceholderForBussinessUser?
                    .resizable()
                    .frame(width: 40, height: 40, alignment: .center)
                    .cornerRadius(20)
                    .padding(.trailing, 5)
            }else if opponenDetail?.metaData?.userType == 1 && appearance.images.defaultImagePlaceholderForNormalUser != nil , let avatar =  opponenDetail?.userProfileImageUrl, ISMChatHelper.shouldShowPlaceholder(avatar: avatar){
                appearance.images.defaultImagePlaceholderForNormalUser?
                    .resizable()
                    .frame(width: 40, height: 40, alignment: .center)
                    .cornerRadius(20)
                    .padding(.trailing, 5)
            }else{
                UserAvatarView(
                    avatar: getAvatarUrl(),
                    showOnlineIndicator: self.conversationDetail?.conversationDetails?.opponentDetails?.online ?? (self.opponenDetail?.online ?? false),
                    size: CGSize(width: 40, height: 40),
                    userName: getProfileName(),
                    font: .regular(size: 14)
                )
                .padding(.trailing, 5)
            }
            
            VStack(alignment: .leading) {
                Text(getProfileTitle())
                    .frame(width: chatFeatures.contains(.videocall) && self.fromBroadCastFlow == false ? 120 : 200,alignment: .leading)
                    .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                    .font(appearance.fonts.messageListHeaderTitle)
                
                Text(getProfileSubtitle())
                    .foregroundColor(appearance.colorPalette.messageListHeaderDescription)
                    .font(appearance.fonts.messageListHeaderDescription)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.3)))
            }
        }
    }
    
    /// Returns the avatar URL based on the chat properties.
    func getAvatarUrl() -> String {
        if ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup {
            return ISMChatHelper.getOpponentForOneToOneGroup(myUserId: myUserId ?? "", members: self.conversationDetail?.conversationDetails?.members ?? [])?.userProfileImageUrl ?? ""
        } else {
            return (isGroup == true) ? self.conversationDetail?.conversationDetails?.conversationImageUrl ?? (self.groupImage ?? "") : opponenDetail?.userProfileImageUrl ?? ""
        }
    }
    
    /// Returns the profile name based on the chat properties.
    func getProfileName() -> String {
        if ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup {
            return ISMChatHelper.getOpponentForOneToOneGroup(myUserId: myUserId ?? "", members: self.conversationDetail?.conversationDetails?.members ?? [])?.userName ?? ""
        } else {
            return (isGroup == true) ? self.conversationDetail?.conversationDetails?.conversationTitle ?? "" : opponenDetail?.userName ?? ""
        }
    }
    
    /// Returns the profile title based on the chat properties.
    func getProfileTitle() -> String {
        if ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup {
            return ISMChatHelper.getOpponentForOneToOneGroup(myUserId: myUserId ?? "", members: self.conversationDetail?.conversationDetails?.members ?? [])?.userName ?? ""
        } else {
            return (isGroup == true) ? self.conversationDetail?.conversationDetails?.conversationTitle ?? (self.groupConversationTitle ?? "") : opponenDetail?.userName ?? ""
        }
    }
    
    /// Returns the profile subtitle based on the chat properties and user status.
    func getProfileSubtitle() -> String {
        if ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup {
            let title = self.conversationDetail?.conversationDetails?.conversationTitle ?? ""
            return title.count > 40 ? String(title.prefix(40)) + "..." : title
        } else if (isGroup == true) {
            if stateViewModel.otherUserTyping {
                return "\(typingUserName ?? "") is typing..."
            } else if let memberString = memberString, !memberString.isEmpty {
                return memberString
            } else {
                return "tap here for more info"
            }
        } else {
            if stateViewModel.otherUserTyping {
                return "typing..."
            } else if self.conversationDetail?.conversationDetails?.opponentDetails?.online == true{
                return "online"
            }else if self.opponenDetail?.online == true{
                return "online"
            }else if let lastSeen = self.conversationDetail?.conversationDetails?.opponentDetails?.lastSeen, lastSeen != -1, self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.showlastSeen == true {
                let date = NSDate().descriptiveStringLastSeen(time: lastSeen)
                return "Last seen \(date)"
            } else if let lastSeen = self.opponenDetail?.lastSeen, lastSeen != -1 ,self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.showlastSeen == true{
                let date = NSDate().descriptiveStringLastSeen(time: lastSeen)
                return "Last seen \(date)"
            }else{
                return "tap here for more info"
            }
        }
    }
    
    
    //MARK: - NAVIGATION TRAILING BUTTONS
    
    
    /// Returns a view containing navigation buttons on the trailing side of the navigation bar.
    func navigationBarTrailingButtons() -> some View {
        HStack {
            if stateViewModel.showforwardMultipleMessage || (stateViewModel.showDeleteMultipleMessage && chatProperties.multipleSelectionOfMessageForDelete == true){
               
            }else {
                
                if isGroup == false && opponenDetail?.userId == nil && opponenDetail?.userName == nil{
                    //BroadCast Message
                    EmptyView()
                }else{
                    if chatFeatures.contains(.videocall) == true{
                        Button {
                            if self.conversationDetail != nil{
                                calling(type: .VideoCall)
                            }else{
                                self.createConversation { _ in
                                    calling(type: .VideoCall)
                                }
                            }
                        } label: {
                            appearance.images.videoCall
                                .resizable()
                                .frame(width: 26, height: 26, alignment: .center)
                        }
                    }
                    
                    if chatFeatures.contains(.audiocall) == true{
                        Button {
                            if self.conversationDetail != nil{
                                calling(type: .AudioCall)
                            }else{
                                self.createConversation { _ in
                                    calling(type: .AudioCall)
                                }
                            }
                        } label: {
                            appearance.images.audioCall
                                .resizable()
                                .frame(width: 26, height: 26, alignment: .center)
                        }
                    }
                    if ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup != true{
                        if  ISMChatSdkUI.getInstance().getChatProperties().customMenu == true{
                            Button {
                                stateViewModel.showCustomMenu = true
                            } label: {
                                appearance.images.threeDots
                                    .frame(width: 20, height: 20, alignment: .center)
                            }

                        }else{
                            Menu {
                                if realmManager.allMessages?.count != 0 || realmManager.messages.count != 0{
                                    clearChatButton()
                                }
                                if isGroup == false{
                                    blockUserButton()
                                }
                            } label: {
                                appearance.images.threeDots
                                    .frame(width: 20, height: 20, alignment: .center)
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    /// Initiates a call based on the specified type (audio or video).
    func calling(type : ISMLiveCallType){
        self.endEditing(true)
        if self.isGroup == true{
            if let chatMembers = self.conversationDetail?.conversationDetails?.members {
                let callMembers = chatMembers.map { member in
                    ISMCallMember(
                        memberName: member.userName ?? "",
                        memberIdentifier: member.userIdentifier ?? "",
                        memberId: member.userId ?? "",
                        isPublishing: false,
                        isAdmin: member.isAdmin,
                        memberProfileImageURL: member.userProfileImageUrl ?? ""
                    )
                }
                let callsdk = IsometrikCall()
                
                callsdk.startGroupCall(with: callMembers, conversationId: self.conversationID, callType: .GroupCall,groupName: self.conversationDetail?.conversationDetails?.conversationTitle ?? (self.groupConversationTitle ?? ""))
            }
        }else{
            let callsdk = IsometrikCall()
            callsdk.startCall(with: [ISMCallMember(memberName: opponenDetail?.userName ?? "", memberIdentifier: opponenDetail?.userIdentifier ?? "", memberId: opponenDetail?.userId ?? "", isPublishing: false, isAdmin: false, memberProfileImageURL: opponenDetail?.userProfileImageUrl ?? "")], conversationId: self.conversationID, callType: type)
        }
    }
    
    /// Returns a button to clear the chat.
    func clearChatButton() -> some View{
        Button {
            if self.conversationDetail != nil{
                stateViewModel.clearThisChat = true
            }else{
                self.createConversation { _ in
                    stateViewModel.clearThisChat = true
                }
            }
        } label: {
            HStack(spacing: 10){
                appearance.images.trash
                Text("Clear Chat")
            }
        }
    }
    
    /// Returns a button to block or unblock a user.
    func blockUserButton() -> some View{
        Button {
            if self.conversationDetail != nil{
                if isMessagingEnabled(){
                    stateViewModel.blockThisChat = true
                }
            }else{
                self.createConversation { _ in
                    if isMessagingEnabled(){
                        stateViewModel.blockThisChat = true
                    }
                }
            }
        } label: {
            HStack(spacing: 10){
                appearance.images.blockIcon
                if self.conversationDetail?.conversationDetails?.messagingDisabled == true && realmManager.messages.last?.last?.initiatorId == userData?.userId{
                    Text("UnBlock User")
                }else{
                    Text("Block User")
                }
            }
        }
    }
}
