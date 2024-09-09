//
//  ISMMessageView+Toolbars.swift
//  ISMChatSdk
//
//  Created by Rasika on 15/04/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import IsometrikChat

extension ISMMessageView{
    //MARK: - FORWARD MESSAGE TOOLBAR
    
    func forwardMessageToolBarView() -> some View{
        VStack{
            Divider()
            HStack{
                Text("\(forwardMessageSelected.count) Selected")
                    .font(themeFonts.messageListtoolbarSelected)
                    .foregroundColor(themeColor.messageListtoolbarSelected)
                Spacer()
                Button {
                    if ISMChatSdk.getInstance().getFramework() == .UIKit{
                        self.delegate?.navigateToUserListToForward(messages: forwardMessageSelected)
                    }else{
                        stateViewModel.movetoForwardList = true
                    }
                } label: {
                    Text("Forward")
                        .foregroundColor(forwardMessageSelected.count == 0 ? themeColor.messageListTextViewPlaceholder : themeColor.messageListtoolbarAction)
                        .font(themeFonts.messageListtoolbarAction)
                }
                .disabled(forwardMessageSelected.count == 0)
            }
            .frame(height: 40)
            .padding(.vertical,10)
            .padding(.horizontal,20)
        }
        .background(themeColor.messageListToolBarBackground)
    }
    
    //MARK: - NO LONGER MEMBER TOOLBAR
    
    func NoLongerMemberToolBar() -> some View{
        VStack{
            HStack{
                Text("You can't send messages to this group because you're no longer a member.")
                    .foregroundColor(themeColor.messageListTextViewPlaceholder)
                    .font(themeFonts.messageListMessageText)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical,10)
            .padding(.horizontal,20)
        }
        .frame(height: 80)
        .background(themeColor.messageListToolBarBackground)
    }
    
    //MARK: - DELETE MESSAGE TOOLBAR
    
    func deleteMessageToolBarView() -> some View{
        VStack{
            HStack{
                Text("\(deleteMessage.count) Selected")
                    .font(Font.regular(size: 16))
                Spacer()
                Button {
                    stateViewModel.showDeleteActionSheet = true
                } label: {
                    Text("Delete")
                        .foregroundColor(deleteMessage.count == 0 ? Color.onboardingPlaceholder : .red)
                        .font(Font.regular(size: 16))
                }
                .disabled(deleteMessage.count == 0)
            }
            .padding(.vertical,10)
            .padding(.horizontal,20)
        }
        .frame(height: 50)
        .background(themeColor.messageListToolBarBackground)
    }
    
    //MARK: - REPLY MESSAGE TOOLBAR
    
    func replyMessageToolBarView() -> some View {
        HStack {
            Rectangle()
                .frame(width: 5, height: 50)
                .foregroundColor(themeColor.messageListReplyToolbarRectangle)
            Spacer()
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text((selectedMsgToReply.senderInfo?.userId ?? selectedMsgToReply.initiatorId) != myUserId ? "\(selectedMsgToReply.senderInfo?.userName ?? selectedMsgToReply.initiatorName)" : ConstantStrings.you)
                        .font(themeFonts.messageListReplyToolbarHeader)
                        .foregroundColor(themeColor.messageListReplyToolbarHeader)
                    
                    let msg = selectedMsgToReply.body
                    switch ISMChatHelper.getMessageType(message: selectedMsgToReply) {
                    case .video:
                        Label {
                            Text(selectedMsgToReply.metaData?.captionMessage != nil ? (selectedMsgToReply.metaData?.captionMessage ?? "Video") : "Video")
                                .font(themeFonts.messageListReplyToolbarDescription)
                                .foregroundColor(themeColor.messageListReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            themeImages.replyVideoIcon
                                .resizable()
                                .frame(width: 14,height: 12)
                                .foregroundColor(themeColor.messageListReplyToolbarDescription)
                        }
                    case .photo:
                        Label {
                            Text(selectedMsgToReply.metaData?.captionMessage != nil ? (selectedMsgToReply.metaData?.captionMessage ?? "Photo") : "Photo")
                                .font(themeFonts.messageListReplyToolbarDescription)
                                .foregroundColor(themeColor.messageListReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            themeImages.replyCameraIcon
                                .resizable()
                                .frame(width: 14,height: 12)
                                .foregroundColor(themeColor.messageListReplyToolbarDescription)
                        }
                    case .audio:
                        Label {
                            Text("Audio")
                                .font(themeFonts.messageListReplyToolbarDescription)
                                .foregroundColor(themeColor.messageListReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            themeImages.replyAudioIcon
                                .foregroundColor(themeColor.messageListReplyToolbarDescription)
                        }
                    case .document:
                        Label {
                            let str = URL(string: selectedMsgToReply.attachments.first?.mediaUrl ?? "")?.lastPathComponent.components(separatedBy: "_").last
                            Text(str ?? "Document")
                                .font(themeFonts.messageListReplyToolbarDescription)
                                .foregroundColor(themeColor.messageListReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            themeImages.replyDocumentIcon
                                .resizable()
                                .frame(width: 14,height: 12)
                                .foregroundColor(themeColor.messageListReplyToolbarDescription)
                        }
                    case .location:
                        Label {
                            let location = "\(selectedMsgToReply.attachments.first?.title ?? "Location") \(selectedMsgToReply.attachments.first?.address ?? "")"
                            Text(location)
                                .font(themeFonts.messageListReplyToolbarDescription)
                                .foregroundColor(themeColor.messageListReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            themeImages.replyLocationIcon
                                .foregroundColor(themeColor.messageListReplyToolbarDescription)
                        }
                    case .contact:
                        Label {
                            if let count = selectedMsgToReply.metaData?.contacts.count{
                                if count == 1{
                                    let contactText = "\(selectedMsgToReply.metaData?.contacts.first?.contactName ?? "")"
                                    Text(contactText)
                                        .font(themeFonts.messageListReplyToolbarDescription)
                                        .foregroundColor(themeColor.messageListReplyToolbarDescription)
                                        .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                                }else{
                                    let contactText = "\(selectedMsgToReply.metaData?.contacts.first?.contactName ?? "") and \(count - 1) other contacts"
                                    Text(contactText)
                                        .font(themeFonts.messageListReplyToolbarDescription)
                                        .foregroundColor(themeColor.messageListReplyToolbarDescription)
                                        .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                                }
                            }else{
                                let contactText = "Contacts"
                                Text(contactText)
                                    .font(themeFonts.messageListReplyToolbarDescription)
                                    .foregroundColor(themeColor.messageListReplyToolbarDescription)
                                    .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                            }
                        } icon: {
                            themeImages.replyContactIcon
                                .foregroundColor(themeColor.messageListReplyToolbarDescription)
                        }
                    case .sticker:
                        AnimatedImage(url: URL(string: selectedMsgToReply.attachments.first?.mediaUrl ?? ""))
                            .resizable()
                            .frame(width: 40, height: 40)
                    case .gif:
                        Label {
                            Text("GIF")
                                .font(themeFonts.messageListReplyToolbarDescription)
                                .foregroundColor(themeColor.messageListReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            themeImages.replyGifIcon
                                .resizable()
                                .frame(width: 20, height: 15)
                        }
                    case .AudioCall:
                        Label {
                            Text("Audio Call")
                                .font(themeFonts.messageListReplyToolbarDescription)
                                .foregroundColor(themeColor.messageListReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            themeImages.audioCall
                                .resizable()
                                .frame(width: 20, height: 15)
                        }
                    case .VideoCall:
                        Label {
                            Text("Video Call")
                                .font(themeFonts.messageListReplyToolbarDescription)
                                .foregroundColor(themeColor.messageListReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            themeImages.videoCall
                                .resizable()
                                .frame(width: 20, height: 15)
                        }
                    default:
                        Text(msg)
                            .font(themeFonts.messageListReplyToolbarDescription)
                            .foregroundColor(themeColor.messageListReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                            .overlay(
                                GeometryReader { proxy in
                                    Color
                                        .clear
                                        .preference(key: ContentLengthPreference.self,
                                                    value: proxy.size.height)
                                }
                            )
                    }
                }
                Spacer()
                if ISMChatHelper.getMessageType(message: selectedMsgToReply) == .photo{
                    ISMChatImageCahcingManger.networkImage(url: selectedMsgToReply.attachments.first?.mediaUrl ?? "",isprofileImage: false)
                        .frame(width: 40, height: 40, alignment: .center)
                        .cornerRadius(5)
                }else if ISMChatHelper.getMessageType(message: selectedMsgToReply) == .video{
                    ISMChatImageCahcingManger.networkImage(url: selectedMsgToReply.attachments.first?.thumbnailUrl ?? "",isprofileImage: false)
                        .frame(width: 40, height: 40, alignment: .center)
                        .cornerRadius(5)
                }else if ISMChatHelper.getMessageType(message: selectedMsgToReply) == .document{
                    if let documentUrl = URL(string: selectedMsgToReply.attachments.first?.mediaUrl ?? ""){
                        themeImages.pdfLogo
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40, alignment: .center)
                    }
                }
                else if ISMChatHelper.getMessageType(message: selectedMsgToReply) == .gif{
                    AnimatedImage(url: URL(string: selectedMsgToReply.attachments.first?.mediaUrl ?? ""),isAnimating: $stateViewModel.isAnimating)
                        .resizable()
                        .frame(width: 45, height: 40)
                        .cornerRadius(5)
                        .overlay(
                            LinearGradient(gradient: Gradient(colors: [.clear,.clear,.clear, Color.black.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                .frame(width: 45, height: 40)
                                .mask(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.white)
                                )
                        )
                }
                Button {
                    selectedMsgToReply = MessagesDB()
                } label: {
                    themeImages.cancelReplyMessageSelected
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .padding()
            }
        }
        .background(themeColor.messageListReplyToolBarBackground)
        .frame(height: 50)
    }
    
    //MARK: - DEFAULT TOOLBAR VIEW
    
    func toolBarView() -> some View {
        VStack(spacing: 0) {
            if stateViewModel.showMentionList, isGroup == true, !filteredUsers.isEmpty {
                mentionUserList()
            }
            if stateViewModel.showforwardMultipleMessage {
                forwardMessageToolBarView()
            } else if stateViewModel.showDeleteMultipleMessage {
                deleteMessageToolBarView()
            } else {
                if !selectedMsgToReply.messageId.isEmpty || ISMChatHelper.getMessageType(message: selectedMsgToReply) == .AudioCall || ISMChatHelper.getMessageType(message: selectedMsgToReply) == .VideoCall {
                    replyMessageToolBarView()
                }
                if textFieldtxt.isValidURL {
                    // LinkPreviewToolBarView(text: textFieldtxt)
                }
                
                // Main Toolbar Content
                VStack {
                    let height: CGFloat = 20
                    
                    HStack {
                        if !viewModel.isRecording {
                            Button(action: { stateViewModel.showActionSheet = true }) {
                                themeImages.addAttcahment
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(.horizontal, 5)
                            }
                            
                            HStack(spacing: 5) {
                                textView()
                                
                                if showGifOption, textFieldtxt.isEmpty {
                                    Button {
                                        stateViewModel.showGifPicker = true
                                    } label: {
                                        themeImages.addSticker
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .padding(.horizontal, 10)
                                    }
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(themeColor.messageListTextViewBoarder, lineWidth: 1)
                            )
                        } else {
                            audioToolbarContent()
                        }
                        
                        sendMessageButton()
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 20)
                .padding(.horizontal, 10)
                .background(themeColor.messageListToolBarBackground)
            }
        }
    }

    // Split audio toolbar content into a separate function
    func audioToolbarContent() -> some View {
        HStack{
            if stateViewModel.audioLocked == false {
                themeImages.addAudio
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(stateViewModel.isShowingRedTimerStart ? .red : .clear)
                    .padding(.leading)
                
                Text(viewModel.timerValue)
                    .font(themeFonts.messageListMessageText)
                    .foregroundColor(themeColor.messageListHeaderTitle)
                
                Spacer()
                
                Text("Slide to cancel")
                    .foregroundStyle(Color.gray)
                    .font(themeFonts.messageListMessageText)
                
                themeImages.chevranbackward
                    .tint(.gray)
            } else {
                VStack(alignment: .leading) {
                    Text(viewModel.timerValue)
                        .font(themeFonts.messageListMessageText)
                        .foregroundColor(themeColor.messageListHeaderTitle)
                    HStack(alignment: .center) {
                        Button(action: cancelRecording) {
                            themeImages.trash
                                .resizable()
                                .frame(width: 25, height: 28)
                                .foregroundColor(themeColor.messageListHeaderTitle)
                        }
                        Spacer()
                        Text("Audio Locked")
                            .foregroundColor(themeColor.messageListTextViewPlaceholder)
                            .font(themeFonts.messageListMessageText)
                        Spacer()
                        Button(action: stopRecording) {
                            themeImages.sendMessage
                                .resizable()
                                .frame(width: 32, height: 32)
                        }
                    }
                }
            }
        }
    }

    // Separate sendMessage button for readability and isolation
    func sendMessageButton() -> some View {
        VStack{
            if !textFieldtxt.isEmpty || showAudioOption == false {
                Button(action: { sendMessage(msgType: .text) }) {
                    themeImages.sendMessage
                        .resizable()
                        .frame(width: 32, height: 32)
                        .padding(.horizontal, 5)
                }
            } else {
                ZStack {
                    if !stateViewModel.audioLocked {
                        if viewModel.isRecording {
                            VStack {
                                themeImages.audioLock
                                    .padding()
                                Spacer()
                            }
                            .background(themeColor.messageListToolBarBackground)
                            .cornerRadius(20, corners: .topLeft)
                            .cornerRadius(20, corners: .topRight)
                            .frame(width: 30, height: 50)
                            .offset(y: -50)
                        }
                        AudioMessageButton(height: 20)
                    }
                }
            }
        }
    }


    // Cancel recording action handler
    func cancelRecording() {
        if stateViewModel.isClicked {
            viewModel.isRecording = false
            stateViewModel.isClicked = false
            stateViewModel.audioLocked = false
            viewModel.stopRecording { _ in }
        }
    }

    // Stop recording action handler
    func stopRecording() {
        if stateViewModel.isClicked {
            viewModel.isRecording = false
            stateViewModel.isClicked = false
            stateViewModel.audioLocked = false
            viewModel.stopRecording { url in
                viewModel.audioUrl = url
            }
        }
    }

    
    func textView() -> some View{
        ResizeableTextView(text: $textFieldtxt, height: $textViewHeight, typingStarted: $stateViewModel.keyboardFocused, placeholderText: "Type a message", showMentionList: $stateViewModel.showMentionList, filteredMentionUserCount: filteredUsers.count, mentionUser: $selectedUserToMention, placeholderColor: themeColor.messageListTextViewPlaceholder, textViewColor: themeColor.messageListTextViewText)
            .frame(height: textViewHeight < 160 ? self.textViewHeight : 160)
    }
    
    func mentionUserList() -> some View{
        List{
            ForEach(filteredUsers) { user in
                if let userName = user.userName {
                    HStack(spacing : 5){
                        UserAvatarView(
                            avatar: user.userProfileImageUrl ?? "",
                            showOnlineIndicator: false,
                            size: CGSize(width: 29, height: 29),
                            userName: userName,font: themeFonts.chatListUserMessage)
                        Text(userName)
                            .font(themeFonts.chatListUserMessage)
                        Spacer()
                    }
                    .onTapGesture {
                        self.selectedUserToMention = userName
                        if let lastAtIndex = textFieldtxt.range(of: "@", options: .backwards)?.lowerBound {
                            textFieldtxt.replaceSubrange(lastAtIndex..., with: "@\(userName)")
                            selectedUserToMention = nil
                        }
                        stateViewModel.showMentionList = false
                    }
                }
            }
        }
        .onDisappear(perform: {
            filteredUsers = mentionUsers
        })
        .listStyle(.plain)
        .frame(height: min(CGFloat(filteredUsers.count) * 40,200))
        .background(Color.gray.opacity(0.2))
    }
    
    func showOptionToAllow() -> Bool {
        let myProfileType = userData.userProfileType
        let userId = userData.userId
        
        // Ensure conversation detail is available
        guard let conversation = conversationDetail?.conversationDetails else {
            return false
        }

        // Check if the current user is not the one who created the conversation
        if conversation.createdBy != userId {
            switch myProfileType {
            case ISMChatUserProfileType.NormalUser.value:
                return false
                
            case ISMChatUserProfileType.Influencer.value:
                if conversation.opponentDetails?.metaData?.userType == 1 && conversation.opponentDetails?.metaData?.isStarUser != true &&
                    conversation.metaData?.chatStatus != ISMChatStatus.Reject.value {
                    return true
                } else {
                    return false
                }
                
            case ISMChatUserProfileType.Bussiness.value:
                if conversation.opponentDetails?.metaData?.userType == 1 &&
                    conversation.metaData?.chatStatus != ISMChatStatus.Reject.value {
                    return true
                } else {
                    return false
                }
                
            default:
                return false
            }
        }
        
        return false
    }
    
    func acceptRejectView() -> some View{
        VStack{
            Divider()
            Text("Accept message request from \(self.opponenDetail?.userName ?? "")?")
                .font(themeFonts.messageListMessageText)
                .foregroundColor(themeColor.chatListUserName)
                .padding(.top,34)
                .padding(.horizontal,15)
                .padding(.bottom,10)
                .multilineTextAlignment(.leading)
                
            Text("If you accept, you both can see information such as when you’ve read messages.")
                .font(themeFonts.messageListMessageText)
                .foregroundColor(themeColor.chatListUserMessage)
                .padding(.horizontal,15)
                .padding(.bottom,29)
                .multilineTextAlignment(.leading)
            
            HStack(spacing: 14){
                Button {
                    dismiss()
//                    self.messageVCDelegate?.navigateBack(isFromProfile: self.fromProfile ?? false, isfromBroadcast: self.fromBroadCastFlow ?? false)
                } label: {
                    Text("Reject")
                        .font(themeFonts.navigationBarTitle)
                        .foregroundColor(themeColor.chatListUnreadMessageCountBackground)
                        .frame(maxWidth: .infinity, minHeight: 49)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(themeColor.chatListUnreadMessageCountBackground, lineWidth: 1)
                        )
                }
                
                Button {
                    //call api
                    viewModel.acceptRequestToAllowMessage(conversationId: self.conversationID ?? "", completion: { _ in
                        NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                        getConversationDetail()
                    })
                } label: {
                    Text("Accept")
                        .font(themeFonts.navigationBarTitle)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 49)
                        .background(themeColor.chatListUnreadMessageCountBackground)
                        .cornerRadius(10)
                }
                
            }.padding(.horizontal,20)
        }
    }
}
