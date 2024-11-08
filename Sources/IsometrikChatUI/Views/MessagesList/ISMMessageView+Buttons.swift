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
    func AudioMessageButton(height : CGFloat) -> some View{
        HStack{
            Button(action: {
                ISMChatHelper.print("recording done")
                if stateViewModel.isClicked == true{
                    chatViewModel.isRecording = false
                    stateViewModel.isClicked = false
                    chatViewModel.stopRecording { url in
                        chatViewModel.audioUrl = url
                    }
                }
            }) {
                ZStack {
                    appearance.images.addAudio
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.horizontal,5)
                }
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.1)
                    .onEnded { value in
                        ISMChatHelper.print("Tap currently holded")
                        if isMessagingEnabled() == true && chatViewModel.isBusy == false{
                            if audioPermissionCheck == true{
                                stateViewModel.isClicked = true
                                chatViewModel.isRecording = true
                                chatViewModel.startRecording()
                            }else{
                                ISMChatHelper.print("Access Denied for audio permission")
                            }
                        }
                    }
                    .sequenced(before:
                                DragGesture(minimumDistance: 2)
                        .onEnded { value in
                            if value.translation.width < -50 {
                                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                                if stateViewModel.isClicked == true{
                                    chatViewModel.isRecording = false
                                    stateViewModel.isClicked = false
                                    chatViewModel.stopRecording { url in
                                    }
                                }
                            }else if chatViewModel.isRecording && value.translation.height < -50 {
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                print("Dragged up")
                                stateViewModel.audioLocked = true
                            }
                        }
                              )
            )
        }
    }
    
    func showPermissionDeniedAlert() {
        let alertController = UIAlertController(
            title: "Audio Permission Required",
            message: "We need access to your microphone for recording audio. Please enable it in Settings.",
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        // Assuming this is within a UIViewController context:
        DispatchQueue.main.async {
            UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK: - MULTIPLE FORWARD MESSAGE BUTTON VIEW
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
    func navigationBarLeadingButtons() -> some View {
        HStack {
            backButtonView()
            
            Spacer().frame(width: 15)
            
            if self.fromBroadCastFlow  == true{
                broadcastButtonView()
            } else {
                profileButtonView()
            }
        }
    }

     func backButtonView() -> some View {
        Button(action: {
            //just resetting unread count for this conversation while going back to conversation list
            realmManager.updateUnreadCountThroughConId(conId: self.conversationID ?? "",count: 0,reset:true)
            //sometimes keyboard doesn't get dismissed
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            //dismiss
            presentationMode.wrappedValue.dismiss()
        }) {
            appearance.images.backButton
                .resizable()
                .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
        }
    }

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

     func getBroadcastTitle() -> String {
        if let groupConversationTitle = groupConversationTitle, !groupConversationTitle.isEmpty, groupConversationTitle != "Default" {
            return groupConversationTitle
        } else {
            return "Messages"
        }
    }

    func profileButtonView() -> some View {
        HStack {
            if ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup != true {
                Button {
                    // Action Logic for Button based on conditions
                    if ISMChatSdkUI.getInstance().getChatProperties().navigateToAppProfileFromMessageList == true {
                        if (isGroup ?? false) == true {
                            self.stateViewModel.navigateToUserProfile = true
                        } else if let userId = (self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.storeId ?? "") != "0"
                                    ? self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.storeId
                                    : opponenDetail?.metaData?.userId {
                            delegate?.navigateToAppProfile(userId: userId, userType: self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.userType ?? 0)
                        } else if let userId = self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.userId
                                   ?? opponenDetail?.metaData?.userId
                                   ?? self.conversationDetail?.conversationDetails?.opponentDetails?.userIdentifier {
                            delegate?.navigateToAppProfile(userId: userId, userType: self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.userType ?? 0)
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
    
    func customView() -> some View{
        HStack{
            UserAvatarView(
                avatar: getAvatarUrl(),
                showOnlineIndicator: self.conversationDetail?.conversationDetails?.opponentDetails?.online ?? false,
                size: CGSize(width: 40, height: 40),
                userName: getProfileName(),
                font: .regular(size: 14)
            )
            .padding(.trailing, 5)
            
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

     func getAvatarUrl() -> String {
        if ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup {
            return ISMChatHelper.getOpponentForOneToOneGroup(myUserId: myUserId ?? "", members: self.conversationDetail?.conversationDetails?.members ?? [])?.userProfileImageUrl ?? ""
        } else {
            return (isGroup == true) ? self.conversationDetail?.conversationDetails?.conversationImageUrl ?? (self.groupImage ?? "") : opponenDetail?.userProfileImageUrl ?? ""
        }
    }

     func getProfileName() -> String {
        if ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup {
            return ISMChatHelper.getOpponentForOneToOneGroup(myUserId: myUserId ?? "", members: self.conversationDetail?.conversationDetails?.members ?? [])?.userName ?? ""
        } else {
            return (isGroup == true) ? self.conversationDetail?.conversationDetails?.conversationTitle ?? "" : opponenDetail?.userName ?? ""
        }
    }

     func getProfileTitle() -> String {
        if ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup {
            return ISMChatHelper.getOpponentForOneToOneGroup(myUserId: myUserId ?? "", members: self.conversationDetail?.conversationDetails?.members ?? [])?.userName ?? ""
        } else {
            return (isGroup == true) ? self.conversationDetail?.conversationDetails?.conversationTitle ?? (self.groupConversationTitle ?? "") : opponenDetail?.userName ?? ""
        }
    }

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
            } else if let lastSeen = self.conversationDetail?.conversationDetails?.opponentDetails?.lastSeen, lastSeen != -1, self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.showlastSeen == true {
                let date = NSDate().descriptiveStringLastSeen(time: lastSeen)
                return "last seen \(date)"
            } else if let lastSeen = self.opponenDetail?.lastSeen, lastSeen != -1, self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.showlastSeen == true {
                let date = NSDate().descriptiveStringLastSeen(time: lastSeen)
                return "last seen \(date)"
            }else{
                return "tap here for more info"
            }
        }
    }

    
    //MARK: - NAVIGATION TRAILING BUTTONS
    
    
    func navigationBarTrailingButtons() -> some View {
        HStack {
            if stateViewModel.showforwardMultipleMessage || stateViewModel.showDeleteMultipleMessage {
                Button {
                    stateViewModel.showforwardMultipleMessage = false
                    forwardMessageSelected.removeAll()
                    stateViewModel.showDeleteMultipleMessage = false
                    deleteMessage.removeAll()
                } label: {
                    Text("Cancel")
                }
            }else {
                
                if isGroup == false && opponenDetail?.userId == nil && opponenDetail?.userName == nil{
                    //BroadCast Message
                    EmptyView()
                }else{
//                    if self.conversationDetail != nil{
                        //calling Button
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
                            Menu {
                                clearChatButton()
                                if isGroup == false{
                                    blockUserButton()
                                }
                            } label: {
                                appearance.images.threeDots
                                        .frame(width: 20, height: 20, alignment: .center)
                            }
                        }
//                    }
                }
            }
        }
    }
    
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
                if self.conversationDetail?.conversationDetails?.messagingDisabled == true && realmManager.messages.last?.last?.initiatorId == userData.userId{
                    Text("UnBlock User")
                }else{
                    Text("Block User")
                }
            }
        }
    }
}
