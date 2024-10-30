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
                    .font(appearance.fonts.messageListtoolbarSelected)
                    .foregroundColor(appearance.colorPalette.messageListtoolbarSelected)
                Spacer()
                Button {
                    if ISMChatSdk.getInstance().getFramework() == .UIKit{
                        self.delegate?.navigateToUserListToForward(messages: forwardMessageSelected)
                    }else{
                        DispatchQueue.main.async {
                            stateViewModel.movetoForwardList = true
                        }
                    }
                } label: {
                    Text("Forward")
                        .foregroundColor(forwardMessageSelected.count == 0 ? appearance.colorPalette.messageListTextViewPlaceholder : appearance.colorPalette.messageListtoolbarAction)
                        .font(appearance.fonts.messageListtoolbarAction)
                }
                .disabled(forwardMessageSelected.count == 0)
            }
            .frame(height: 40)
            .padding(.vertical,10)
            .padding(.horizontal,20)
        }
        .background(appearance.colorPalette.messageListToolBarBackground)
    }
    
    //MARK: - NO LONGER MEMBER TOOLBAR
    
    func NoLongerMemberToolBar() -> some View{
        VStack{
            HStack{
                Text("You can't send messages to this group because you're no longer a member.")
                    .foregroundColor(appearance.colorPalette.messageListTextViewPlaceholder)
                    .font(appearance.fonts.messageListMessageText)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical,10)
            .padding(.horizontal,20)
        }
        .frame(height: 80)
        .background(appearance.colorPalette.messageListToolBarBackground)
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
        .background(appearance.colorPalette.messageListToolBarBackground)
    }
    
    //MARK: - REPLY MESSAGE TOOLBAR
    
    func replyMessageToolBarView() -> some View {
        HStack {
            Rectangle()
                .frame(width: 5, height: 50)
                .foregroundColor(appearance.colorPalette.messageListReplyToolbarRectangle)
            Spacer()
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text((selectedMsgToReply.senderInfo?.userId ?? selectedMsgToReply.initiatorId) != myUserId ? "\(selectedMsgToReply.senderInfo?.userName ?? selectedMsgToReply.initiatorName)" : ConstantStrings.you)
                        .font(appearance.fonts.messageListReplyToolbarHeader)
                        .foregroundColor(appearance.colorPalette.messageListReplyToolbarHeader)
                    
                    let msg = selectedMsgToReply.body
                    switch ISMChatHelper.getMessageType(message: selectedMsgToReply) {
                    case .video:
                        Label {
                            Text(selectedMsgToReply.metaData?.captionMessage != nil ? (selectedMsgToReply.metaData?.captionMessage ?? "Video") : "Video")
                                .font(appearance.fonts.messageListReplyToolbarDescription)
                                .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            appearance.images.replyVideoIcon
                                .resizable()
                                .frame(width: 14,height: 12)
                                .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                        }
                    case .photo:
                        Label {
                            Text(selectedMsgToReply.metaData?.captionMessage != nil ? (selectedMsgToReply.metaData?.captionMessage ?? "Photo") : "Photo")
                                .font(appearance.fonts.messageListReplyToolbarDescription)
                                .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            appearance.images.replyCameraIcon
                                .resizable()
                                .frame(width: 14,height: 12)
                                .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                        }
                    case .audio:
                        Label {
                            Text("Audio")
                                .font(appearance.fonts.messageListReplyToolbarDescription)
                                .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            appearance.images.replyAudioIcon
                                .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                        }
                    case .document:
                        Label {
                            let str = URL(string: selectedMsgToReply.attachments.first?.mediaUrl ?? "")?.lastPathComponent.components(separatedBy: "_").last
                            Text(str ?? "Document")
                                .font(appearance.fonts.messageListReplyToolbarDescription)
                                .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            appearance.images.replyDocumentIcon
                                .resizable()
                                .frame(width: 14,height: 12)
                                .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                        }
                    case .location:
                        Label {
                            let location = "\(selectedMsgToReply.attachments.first?.title ?? "Location") \(selectedMsgToReply.attachments.first?.address ?? "")"
                            Text(location)
                                .font(appearance.fonts.messageListReplyToolbarDescription)
                                .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            appearance.images.replyLocationIcon
                                .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                        }
                    case .contact:
                        Label {
                            if let count = selectedMsgToReply.metaData?.contacts.count{
                                if count == 1{
                                    let contactText = "\(selectedMsgToReply.metaData?.contacts.first?.contactName ?? "")"
                                    Text(contactText)
                                        .font(appearance.fonts.messageListReplyToolbarDescription)
                                        .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                                        .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                                }else{
                                    let contactText = "\(selectedMsgToReply.metaData?.contacts.first?.contactName ?? "") and \(count - 1) other contacts"
                                    Text(contactText)
                                        .font(appearance.fonts.messageListReplyToolbarDescription)
                                        .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                                        .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                                }
                            }else{
                                let contactText = "Contacts"
                                Text(contactText)
                                    .font(appearance.fonts.messageListReplyToolbarDescription)
                                    .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                                    .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                            }
                        } icon: {
                            appearance.images.replyContactIcon
                                .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                        }
                    case .sticker:
                        AnimatedImage(url: URL(string: selectedMsgToReply.attachments.first?.mediaUrl ?? ""))
                            .resizable()
                            .frame(width: 40, height: 40)
                    case .gif:
                        Label {
                            Text("GIF")
                                .font(appearance.fonts.messageListReplyToolbarDescription)
                                .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            appearance.images.replyGifIcon
                                .resizable()
                                .frame(width: 20, height: 15)
                        }
                    case .AudioCall:
                        Label {
                            Text("Audio Call")
                                .font(appearance.fonts.messageListReplyToolbarDescription)
                                .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            appearance.images.audioCall
                                .resizable()
                                .frame(width: 20, height: 15)
                        }
                    case .VideoCall:
                        Label {
                            Text("Video Call")
                                .font(appearance.fonts.messageListReplyToolbarDescription)
                                .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            appearance.images.videoCall
                                .resizable()
                                .frame(width: 20, height: 15)
                        }
                    default:
                        Text(msg)
                            .font(appearance.fonts.messageListReplyToolbarDescription)
                            .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
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
                    ISMChatImageCahcingManger.viewImage(url: selectedMsgToReply.attachments.first?.mediaUrl ?? "")
                        .frame(width: 40, height: 40, alignment: .center)
                        .cornerRadius(5)
                }else if ISMChatHelper.getMessageType(message: selectedMsgToReply) == .video{
                    ISMChatImageCahcingManger.viewImage(url: selectedMsgToReply.attachments.first?.thumbnailUrl ?? "")
                        .frame(width: 40, height: 40, alignment: .center)
                        .cornerRadius(5)
                }else if ISMChatHelper.getMessageType(message: selectedMsgToReply) == .document{
//                    if let documentUrl = URL(string: selectedMsgToReply.attachments.first?.mediaUrl ?? ""){
                        appearance.images.pdfLogo
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40, alignment: .center)
//                    }
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
                    appearance.images.cancelReplyMessageSelected
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .padding()
            }
        }
        .background(appearance.colorPalette.messageListReplyToolBarBackground)
        .frame(height: 50)
    }
    
    func regularToolbarContent() -> some View {
        VStack(spacing: 0) {
            // Reply View
            if !selectedMsgToReply.messageId.isEmpty || ISMChatHelper.getMessageType(message: selectedMsgToReply) == .AudioCall || ISMChatHelper.getMessageType(message: selectedMsgToReply) == .VideoCall {
                replyMessageToolBarView()
            }
            
            // Link Preview
            if textFieldtxt.isValidURL {
                Divider()
                LinkPreviewToolBarView(text: textFieldtxt)
            }
            
            // Main Toolbar
            mainToolbarContent
        }
    }
    
    private var mainToolbarContent: some View {
        VStack {
            HStack {
                if !chatViewModel.isRecording {
                    Button(action: {
                        DispatchQueue.main.async {
                            stateViewModel.showActionSheet = true
                        }
                    }) {
                        appearance.images.addAttcahment
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(.horizontal, 5)
                    }
                    
                    HStack(spacing: 5) {
                        textView()
                        
                        if chatFeatures.contains(.gif), textFieldtxt.isEmpty {
                            Button {
                                DispatchQueue.main.async {
                                    stateViewModel.showGifPicker = true
                                }
                            } label: {
                                appearance.images.addSticker
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .padding(.horizontal, 10)
                            }
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(appearance.colorPalette.messageListTextViewBoarder, lineWidth: 1)
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
        .background(appearance.colorPalette.messageListToolBarBackground)
    }
    
    //MARK: - DEFAULT TOOLBAR VIEW
    
    func toolBarView() -> some View {
        VStack(spacing: 0) {
            if stateViewModel.showMentionList && isGroup == true && !filteredUsers.isEmpty {
                mentionUserList()
            } else if stateViewModel.showforwardMultipleMessage {
                forwardMessageToolBarView()
            } else if stateViewModel.showDeleteMultipleMessage {
                deleteMessageToolBarView()
            } else {
                regularToolbarContent()
            }
//            if stateViewModel.showMentionList, isGroup == true, !filteredUsers.isEmpty {
//                mentionUserList()
//            }
//            if stateViewModel.showforwardMultipleMessage {
//                forwardMessageToolBarView()
//            } else if stateViewModel.showDeleteMultipleMessage {
//                deleteMessageToolBarView()
//            } else {
//                if !selectedMsgToReply.messageId.isEmpty || ISMChatHelper.getMessageType(message: selectedMsgToReply) == .AudioCall || ISMChatHelper.getMessageType(message: selectedMsgToReply) == .VideoCall {
//                    replyMessageToolBarView()
//                }
//                if textFieldtxt.isValidURL {
//                     LinkPreviewToolBarView(text: textFieldtxt)
//                }
//                
//                // Main Toolbar Content
//                VStack {
//                    HStack {
//                        if !chatViewModel.isRecording {
//                            Button(action: {
//                                DispatchQueue.main.async {
//                                    stateViewModel.showActionSheet = true
//                                }
//                            }) {
//                                appearance.images.addAttcahment
//                                    .resizable()
//                                    .frame(width: 20, height: 20)
//                                    .padding(.horizontal, 5)
//                            }
//                            
//                            HStack(spacing: 5) {
//                                textView()
//                                
//                                if chatFeatures.contains(.gif), textFieldtxt.isEmpty {
//                                    Button {
//                                        DispatchQueue.main.async {
//                                            stateViewModel.showGifPicker = true
//                                        }
//                                    } label: {
//                                        appearance.images.addSticker
//                                            .resizable()
//                                            .frame(width: 15, height: 15)
//                                            .padding(.horizontal, 10)
//                                    }
//                                }
//                            }
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 16)
//                                    .stroke(appearance.colorPalette.messageListTextViewBoarder, lineWidth: 1)
//                            )
//                        } else {
//                            audioToolbarContent()
//                        }
//                        
//                        sendMessageButton()
//                    }
//                }
//                .padding(.top, 10)
//                .padding(.bottom, 20)
//                .padding(.horizontal, 10)
//                .background(appearance.colorPalette.messageListToolBarBackground)
//            }
        }
    }

    // Split audio toolbar content into a separate function
    func audioToolbarContent() -> some View {
        HStack{
            if stateViewModel.audioLocked == false {
                appearance.images.addAudio
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(stateViewModel.isShowingRedTimerStart ? .red : .clear)
                    .padding(.leading)
                
                Text(chatViewModel.timerValue)
                    .font(appearance.fonts.messageListMessageText)
                    .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                
                Spacer()
                
                Text("Slide to cancel")
                    .foregroundStyle(Color.gray)
                    .font(appearance.fonts.messageListMessageText)
                
                appearance.images.chevranbackward
                    .tint(.gray)
            } else {
                VStack(alignment: .leading) {
                    Text(chatViewModel.timerValue)
                        .font(appearance.fonts.messageListMessageText)
                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                    HStack(alignment: .center) {
                        Button(action: cancelRecording) {
                            appearance.images.trash
                                .resizable()
                                .frame(width: 25, height: 28)
                                .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                        }
                        Spacer()
                        Text("Audio Locked")
                            .foregroundColor(appearance.colorPalette.messageListTextViewPlaceholder)
                            .font(appearance.fonts.messageListMessageText)
                        Spacer()
                        Button(action: stopRecording) {
                            appearance.images.sendMessage
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
            if !textFieldtxt.isEmpty || chatFeatures.contains(.audio) == false {
                Button(action: { sendMessage(msgType: .text) }) {
                    appearance.images.sendMessage
                        .resizable()
                        .frame(width: 32, height: 32)
                        .padding(.horizontal, 5)
                }
            } else {
                ZStack {
                    if !stateViewModel.audioLocked {
                        if chatViewModel.isRecording {
                            VStack {
                                appearance.images.audioLock
                                    .padding()
                                Spacer()
                            }
                            .background(appearance.colorPalette.messageListToolBarBackground)
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
            chatViewModel.isRecording = false
            stateViewModel.isClicked = false
            stateViewModel.audioLocked = false
            chatViewModel.stopRecording { _ in }
        }
    }

    // Stop recording action handler
    func stopRecording() {
        if stateViewModel.isClicked {
            chatViewModel.isRecording = false
            stateViewModel.isClicked = false
            stateViewModel.audioLocked = false
            chatViewModel.stopRecording { url in
                chatViewModel.audioUrl = url
            }
        }
    }

    
    func textView() -> some View{
        TextField("", text: $textFieldtxt, axis: .vertical)
            .onChange(of: textFieldtxt, { _, newValue in
                // Update showMentionList based on conditions
                if newValue.last == "@" {
                    stateViewModel.showMentionList = true
                } else if !newValue.contains("@") || newValue.isEmpty {
                    stateViewModel.showMentionList = false
                }
            })
            .placeholder(when: textFieldtxt.isEmpty) {
                Text("Type a message")
                    .foregroundColor(appearance.colorPalette.messageListTextViewPlaceholder)
            }
            .foregroundColor(appearance.colorPalette.messageListTextViewText)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
    }
    
    private func styledText(for text: String) -> AttributedString {
            var attributedText = AttributedString(text)
            
            if let range = text.range(of: "@\\w+", options: .regularExpression) {
                let nsRange = NSRange(range, in: text)
                if let attributedRange = Range<AttributedString.Index>(nsRange, in: attributedText) {
                    attributedText[attributedRange].foregroundColor = .blue // Color the mention
                }
            }
            
            return attributedText
        }
    private func appendUserToText(user: String) {
        let trimmedText = textFieldtxt.trimmingCharacters(in: .whitespacesAndNewlines) // Trim any whitespace/newline
        print("Current trimmed text: \(trimmedText)")
        
        // Get the first name (first word of the user)
        let firstName = user.components(separatedBy: " ").first ?? user
        
        if let atSymbolRange = trimmedText.range(of: "@", options: .backwards) {
            let prefixText = trimmedText[..<atSymbolRange.upperBound]
            
            // Combine the prefix and the selected first name
            let combinedText = prefixText + firstName + " "
            
            // Create an AttributedString for the combined text
            var attributedText = AttributedString(combinedText)
            
            // Find the range of the "@username"
            if let mentionRange = combinedText.range(of: "@\(firstName)") {
                let nsRange = NSRange(mentionRange, in: combinedText)
                if let attributedRange = Range<AttributedString.Index>(nsRange, in: attributedText) {
                    attributedText[attributedRange].foregroundColor = .blue // Set blue color to @username
                }
            }
            
            // Convert AttributedString back to String to update the text
            textFieldtxt = String(attributedText.characters)
            
            stateViewModel.showMentionList = false
            print("Updated text: \(text)")
        } else {
            print("No @ symbol found")
        }
    }


    
    func mentionUserList() -> some View{
        VStack{
            Divider()
            List(filteredUsers, id: \.self){ user in
                if let userName = user.userName {
                    Button {
                        appendUserToText(user: userName)
                    } label: {
                        HStack(spacing : 5){
                            UserAvatarView(
                                avatar: user.userProfileImageUrl ?? "",
                                showOnlineIndicator: false,
                                size: CGSize(width: 35, height: 35),
                                userName: userName,font: appearance.fonts.messageListMessageText)
                            Text(userName)
                                .font(appearance.fonts.messageListMessageText)
                            Spacer()
                        }
                    }
                }
            }
            .onDisappear(perform: {
                filteredUsers = mentionUsers
            })
            .listStyle(.plain)
            .frame(height: min(CGFloat(filteredUsers.count) * 35,200))
            .background(Color.white)
        }
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
                .font(appearance.fonts.messageListMessageText)
                .foregroundColor(appearance.colorPalette.chatListUserName)
                .padding(.top,34)
                .padding(.horizontal,15)
                .padding(.bottom,10)
                .multilineTextAlignment(.leading)
                
            Text("If you accept, you both can see information such as when you’ve read messages.")
                .font(appearance.fonts.messageListMessageText)
                .foregroundColor(appearance.colorPalette.chatListUserMessage)
                .padding(.horizontal,15)
                .padding(.bottom,29)
                .multilineTextAlignment(.leading)
            
            HStack(spacing: 14){
                Button {
                    presentationMode.wrappedValue.dismiss()
//                    self.messageVCDelegate?.navigateBack(isFromProfile: self.fromProfile ?? false, isfromBroadcast: self.fromBroadCastFlow ?? false)
                } label: {
                    Text("Reject")
                        .font(appearance.fonts.navigationBarTitle)
                        .foregroundColor(appearance.colorPalette.chatListUnreadMessageCountBackground)
                        .frame(maxWidth: .infinity, minHeight: 49)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(appearance.colorPalette.chatListUnreadMessageCountBackground, lineWidth: 1)
                        )
                }
                
                Button {
                    //call api
                    chatViewModel.acceptRequestToAllowMessage(conversationId: self.conversationID ?? "", completion: { _ in
                        NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                        getConversationDetail()
                    })
                } label: {
                    Text("Accept")
                        .font(appearance.fonts.navigationBarTitle)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 49)
                        .background(appearance.colorPalette.chatListUnreadMessageCountBackground)
                        .cornerRadius(10)
                }
                
            }.padding(.horizontal,20)
        }
    }
}
