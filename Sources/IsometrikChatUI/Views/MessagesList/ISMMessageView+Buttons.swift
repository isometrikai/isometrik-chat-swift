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
                if isClicked == true{
                    viewModel.isRecording = false
                    self.isClicked = false
                    viewModel.stopRecording { url in
                        viewModel.audioUrl = url
                    }
                }
            }) {
                ZStack {
                    themeImages.addAudio
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.horizontal,5)
                }
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.1)
                    .onEnded { value in
                        ISMChatHelper.print("Tap currently holded")
                        if isMessagingEnabled() == true && viewModel.isBusy == false{
                            if audioPermissionCheck == true{
                                isClicked = true
                                viewModel.isRecording = true
                                viewModel.startRecording()
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
                                if isClicked == true{
                                    viewModel.isRecording = false
                                    self.isClicked = false
                                    viewModel.stopRecording { url in
                                    }
                                }
                            }else if viewModel.isRecording && value.translation.height < -50 {
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                print("Dragged up")
                                audioLocked = true
                            }
                        }
                              )
            )
        }
    }
    
    //MARK: - MULTIPLE FORWARD MESSAGE BUTTON VIEW
    func multipleForwardMessageButtonView(message : MessagesDB) -> some View{
        if forwardMessageSelected.contains(where: { msg in
            msg.messageId == message.messageId
        }){
            return   themeImages.selected
                .resizable()
                .frame(width: 20, height: 20)
        }else{
            return    themeImages.deselected
                .resizable()
                .frame(width: 20, height: 20)
        }
    }
    
    //MARK: - MULTIPLE DELETE MESSAGE BUTTON VIEW
    func multipleDeleteMessageButtonView(message: MessagesDB) -> some View {
        if deleteMessage.contains(where: { msg in
            msg.messageId == message.messageId
        }) {
            return  themeImages.selected
                .resizable()
                .frame(width: 20, height: 20)
        } else {
            return themeImages.deselected
                .resizable()
                .frame(width: 20, height: 20)
        }
    }
    
    //MARK: - SCROLL TO BOTTOM MESSAGE
    func scrollToBottomButton() -> some View {
        return Button(action: {
            realmManager.parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
        }, label: {
            themeImages.scrollToBottomArrow
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
        Button(action: {}) {
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
    }

     func backButtonView() -> some View {
        Button(action: {
            dismiss()
        }) {
            themeImages.backButton
                .resizable()
                .frame(width: 18, height: 18)
        }
    }

     func broadcastButtonView() -> some View {
        Button {
            if ISMChatSdk.getInstance().getFramework() == .UIKit {
                delegate?.navigateToBroadCastInfo(groupcastId: self.groupCastId ?? "", groupcastTitle: self.groupConversationTitle ?? "", groupcastImage: self.groupImage ?? "")
                
            } else {
                navigateToGroupCastInfo = true
            }
        } label: {
            if ISMChatSdk.getInstance().getFramework() == .UIKit {
                UserAvatarView(
                    avatar: groupImage ?? "",
                    showOnlineIndicator: false,
                    size: CGSize(width: 40, height: 40),
                    userName: groupConversationTitle ?? "",
                    font: themeFonts.messageListMessageText
                )
            }else{
                BroadCastAvatarView(
                    size: CGSize(width: 40, height: 40),
                    broadCastImageSize: CGSize(width: 17.7, height: 17.7),
                    broadCastLogo: themeImages.broadCastLogo
                )
            }
            Text(getBroadcastTitle())
                .frame(width: 200,alignment: .leading)
                .foregroundColor(themeColor.messageListHeaderTitle)
                .font(themeFonts.messageListHeaderTitle)
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
        Button {
            handleProfileNavigation()
        } label: {
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
                    .frame(width: 200,alignment: .leading)
                    .foregroundColor(themeColor.messageListHeaderTitle)
                    .font(themeFonts.messageListHeaderTitle)
                
                Text(getProfileSubtitle())
                    .foregroundColor(themeColor.messageListHeaderDescription)
                    .font(themeFonts.messageListHeaderDescription)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.3)))
            }
        }
    }

     func handleProfileNavigation() {
         if ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup != true{
             if ISMChatSdkUI.getInstance().getChatProperties().navigateToAppProfileFromMessageList == true{
                 if isGroup == true {
                     navigateToProfile = true
                 } else if let userId = self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.userId
                            ?? opponenDetail?.metaData?.userId
                            ?? self.conversationDetail?.conversationDetails?.opponentDetails?.userIdentifier {
                     delegate?.navigateToAppProfile(userId: userId, userType: self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.userType ?? 0)
                 }
             }else{
                 navigateToProfile = true
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
            return self.conversationDetail?.conversationDetails?.conversationTitle ?? ""
        } else {
            return (isGroup == true) ? self.conversationDetail?.conversationDetails?.conversationTitle ?? (self.groupConversationTitle ?? "") : opponenDetail?.userName ?? ""
        }
    }

     func getProfileSubtitle() -> String {
        if ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup {
            return ISMChatHelper.getOpponentForOneToOneGroup(myUserId: myUserId ?? "", members: self.conversationDetail?.conversationDetails?.members ?? [])?.userName ?? ""
        } else if (isGroup == true) {
            if otherUserTyping {
                return "\(typingUserName ?? "") is typing..."
            } else if let memberString = memberString, !memberString.isEmpty {
                return memberString
            } else {
                return "Tap here for more info"
            }
        } else {
            if otherUserTyping {
                return "Typing..."
            } else if let lastSeen = self.conversationDetail?.conversationDetails?.opponentDetails?.lastSeen, lastSeen != -1, self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.showlastSeen == true {
                let date = NSDate().descriptiveStringLastSeen(time: lastSeen)
                return "Last seen at \(date)"
            } else if let lastSeen = self.opponenDetail?.lastSeen, lastSeen != -1, self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.showlastSeen == true {
                let date = NSDate().descriptiveStringLastSeen(time: lastSeen)
                return "Last seen at \(date)"
            } else if self.conversationDetail?.conversationDetails?.opponentDetails?.online == true{
                return "Online"
            }else{
                return "Tap here for more info"
            }
        }
    }

    
    //MARK: - NAVIGATION TRAILING BUTTONS
    
    
    func navigationBarTrailingButtons() -> some View {
        HStack {
            if showforwardMultipleMessage || showDeleteMultipleMessage {
                Button {
                    showforwardMultipleMessage = false
                    forwardMessageSelected.removeAll()
                    showDeleteMultipleMessage = false
                    deleteMessage.removeAll()
                } label: {
                    Text("Cancel")
                }
            }else {
                
                if isGroup == false && opponenDetail?.userId == nil && opponenDetail?.userName == nil{
                    //BroadCast Message
                    EmptyView()
                }else{
                    if self.conversationDetail != nil{
                        //calling Button
                        if showVideoCallingOption == true{
                            Button {
                                calling(type: .VideoCall)
                            } label: {
                                themeImages.videoCall
                                    .resizable()
                                    .frame(width: 26, height: 26, alignment: .center)
                            }
                        }
                        
                        if showAudioCallingOption == true{
                            Button {
                                calling(type: .AudioCall)
                            } label: {
                                themeImages.audioCall
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
                                themeImages.threeDots
                                    .resizable()
                                    .frame(width: 5, height: 20, alignment: .center)
                            }
                        }
                    }
                }
            }
        }.background(NavigationLink("", destination:  ISMBlockUserView(conversationViewModel: self.conversationViewModel), isActive: $navigateToBlockUsers))
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
            clearThisChat = true
        } label: {
            HStack(spacing: 10){
                themeImages.trash
                Text("Clear Chat")
            }
        }
    }
    
    func blockUserButton() -> some View{
        Button {
            if isMessagingEnabled(){
                blockThisChat = true
            }
        } label: {
            HStack(spacing: 10){
                themeImages.blockIcon
                if self.conversationDetail?.conversationDetails?.messagingDisabled == true && realmManager.messages.last?.last?.initiatorId == userData.userId{
                    Text("UnBlock User")
                }else{
                    Text("Block User")
                }
            }
        }
    }
}
