//
//  SwiftUIView.swift
//  
//
//  Created by Rasika Bharati on 27/11/24.
//

import SwiftUI
import IsometrikChat
import SDWebImageSwiftUI
import AVKit

enum ToolbarState {
    case mention
    case forward
    case delete
    case normal
}




struct MentionUserList : View{
    @Binding var showMentionList : Bool
    @Binding var filteredUsers: [ISMChatGroupMember]
    @Binding var mentionUsers: [ISMChatGroupMember]
    @Binding var textFieldtxt : String
    @State var appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    var body: some View {
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
            
            showMentionList = false
            print("Updated text: \(textFieldtxt)")
        } else {
            print("No @ symbol found")
        }
    }
}


struct ForwardMessageToolBar : View {
    @State var appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @Binding var forwardMessageSelected : [MessagesDB]
    @Binding var movetoForwardList : Bool
    var navigateToForwardList : () -> ()
    var body: some View {
        VStack{
            Divider()
            HStack{
                Text("\(forwardMessageSelected.count) Selected")
                    .font(appearance.fonts.messageListtoolbarSelected)
                    .foregroundColor(appearance.colorPalette.messageListtoolbarSelected)
                Spacer()
                Button {
                    if ISMChatSdk.getInstance().getFramework() == .UIKit{
                        navigateToForwardList()
                    }else{
                        DispatchQueue.main.async {
                            movetoForwardList = true
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
}


struct DelegateMessageToolBar : View {
    @State var appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @Binding var deleteMessage : [MessagesDB]
    @Binding var showDeleteActionSheet : Bool
    var body: some View {
        VStack{
            HStack{
                Text("\(deleteMessage.count) Selected")
                    .font(Font.regular(size: 16))
                Spacer()
                Button {
                    showDeleteActionSheet = true
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
}


struct BasicToolBarView : View {
    @Binding var textFieldtxt : String
    @Binding var selectedMsgToReply : MessagesDB
    @Binding var parentMessageIdToScroll : String
    @Binding var audioLocked : Bool
    @Binding var isClicked : Bool
    @Binding var uAreBlock : Bool
    @Binding var showUnblockPopUp : Bool
    @Binding var isShowingRedTimerStart : Bool
    @Binding var showActionSheet : Bool
    @Binding var showGifPicker : Bool
    @Binding var audioPermissionCheck :Bool
    @Binding var keyboardFocused : Bool
    @EnvironmentObject var realmManager : RealmManager
    @EnvironmentObject var chatViewModel : ChatsViewModel
    var onSendMessage : () -> ()
    var body: some View {
        VStack(spacing: 0) {
            if !selectedMsgToReply.messageId.isEmpty || ISMChatHelper.getMessageType(message: selectedMsgToReply) == .AudioCall || ISMChatHelper.getMessageType(message: selectedMsgToReply) == .VideoCall {
                ReplyToolBarView(selectedMsgToReply: $selectedMsgToReply)
            }
            
            if textFieldtxt.isValidURL && !ISMChatSdkUI.getInstance().getChatProperties().hideLinkPreview {
                Divider()
                LinkPreviewToolBarView(text: textFieldtxt)
            }
            
            MainToolBarView(textFieldtxt: $textFieldtxt, parentMessageIdToScroll: $parentMessageIdToScroll, audioLocked: $audioLocked, isClicked: $isClicked,uAreBlock: $uAreBlock,showUnblockPopUp: $showUnblockPopUp,isShowingRedTimerStart: $isShowingRedTimerStart,showActionSheet: $showActionSheet,showGifPicker: $showGifPicker,audioPermissionCheck: $audioPermissionCheck, keyboardFocused: $keyboardFocused, onSendMessage: {
                onSendMessage()
            })
                .environmentObject(self.realmManager)
                .environmentObject(self.chatViewModel)
        }
    }
}

struct MainToolBarView : View {
    @EnvironmentObject var chatViewModel : ChatsViewModel
    @State var appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @State var chatFeatures = ISMChatSdkUI.getInstance().getChatProperties().features
    @Binding var textFieldtxt : String
    @Binding var parentMessageIdToScroll : String
    @Binding var audioLocked : Bool
    @Binding var isClicked : Bool
    @Binding var uAreBlock : Bool
    @Binding var showUnblockPopUp : Bool
    @Binding var isShowingRedTimerStart : Bool
    @Binding var showActionSheet : Bool
    @Binding var showGifPicker : Bool
    @Binding var audioPermissionCheck :Bool
    @Binding var keyboardFocused : Bool
    @EnvironmentObject var realmManager : RealmManager
    var conversationDetail : ISMChatConversationDetail?
    var onSendMessage : () -> ()
    var body: some View {
        HStack {
            if !chatViewModel.isRecording {
                inputTextView()
            } else {
                audioToolbarContent()
            }
            sendMessageButton()
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
        .padding(.horizontal, 10)
        .background(appearance.colorPalette.messageListToolBarBackground)
    }
    
    
    func sendMessageButton() -> some View {
        Group {
            if shouldShowSendButton {
                sendButton
            } else {
                audioButton
            }
        }
    }
    
    private var shouldShowSendButton: Bool {
        !textFieldtxt.isEmpty || !chatFeatures.contains(.audio)
    }

    // MARK: - Subviews

    private var sendButton: some View {
        Group {
            if ISMChatSdkUI.getInstance().getChatProperties().hideSendButtonUntilEmptyTextView {
                if !textFieldtxt.isEmpty {
                    sendMessageButtonView
                }
            } else {
                sendMessageButtonView
            }
        }
    }

    private var sendMessageButtonView: some View {
        Button(action: {
            onSendMessage()
        }) {
            appearance.images.sendMessage
                .resizable()
                .frame(width: 32, height: 32)
                .padding(.horizontal, 5)
        }
    }

    private var audioButton: some View {
        ZStack {
            if !audioLocked {
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
    
    func AudioMessageButton(height : CGFloat) -> some View{
        Button(action: {
            ISMChatHelper.print("recording done")
            if isClicked == true{
                chatViewModel.isRecording = false
                isClicked = false
                chatViewModel.stopRecording { url in
                    chatViewModel.audioUrl = url
                }
            }
        }) {
            appearance.images.addAudio
                .resizable()
                .frame(width: appearance.imagesSize.messageAudioButton.width, height: appearance.imagesSize.messageAudioButton.height)
                .padding(.horizontal,5)
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.1)
                .onEnded { value in
                    ISMChatHelper.print("Tap currently holded")
                    if isMessagingEnabled() == true && chatViewModel.isBusy == false{
                        if audioPermissionCheck == true{
                            isClicked = true
                            chatViewModel.isRecording = true
                            chatViewModel.startRecording()
                        }else{
                            checkAudioPermission()
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
                                chatViewModel.isRecording = false
                                self.chatViewModel.countSec = 0
                                self.chatViewModel.timerValue = "0:00"
                                isClicked = false
                                chatViewModel.stopRecording { url in
                                }
                            }
                        }else if chatViewModel.isRecording && value.translation.height < -50 {
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            print("Dragged up")
                            audioLocked = true
                        }
                    }
                          )
        )
    }
    
    
    func checkAudioPermission() {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            audioPermissionCheck = true
        case .denied:
            audioPermissionCheck = false
        case .undetermined:
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        audioPermissionCheck = true
                    } else {
                        audioPermissionCheck = false
                    }
                }
            }
        default:
            break
        }
    }

    // MARK: - Action Handlers

    private func stopRecordingAction() {
        ISMChatHelper.print("Recording done")
        if isClicked {
            chatViewModel.isRecording = false
            isClicked = false
            chatViewModel.stopRecording { url in
                chatViewModel.audioUrl = url
            }
        }
    }

    private func handleLongPressGesture() {
        ISMChatHelper.print("Tap currently held")
        if isMessagingEnabled() && !chatViewModel.isBusy {
            if audioPermissionCheck {
                isClicked = true
                chatViewModel.isRecording = true
                chatViewModel.startRecording()
            } else {
                ISMChatHelper.print("Access Denied for audio permission")
            }
        }
    }
    
    func isMessagingEnabled() -> Bool{
        if self.conversationDetail?.conversationDetails?.messagingDisabled == true{
            if realmManager.messages.last?.last?.initiatorId != ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig.userId{
                uAreBlock = true
            }else{
                showUnblockPopUp = true
            }
            return false
        }else{
            return true
        }
    }

    private func handleDragGesture(_ value: DragGesture.Value) {
        if value.translation.width < -50 {
            // Swipe left to cancel recording
            cancelRecordingOnDrag()
        } else if chatViewModel.isRecording && value.translation.height < -50 {
            // Drag up to lock recording
            lockRecordingOnDrag()
        }
    }

    // MARK: - Helper Functions

    private func cancelRecordingOnDrag() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        if isClicked {
            chatViewModel.isRecording = false
            isClicked = false
            chatViewModel.stopRecording { _ in }
        }
    }

    private func lockRecordingOnDrag() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        ISMChatHelper.print("Dragged up to lock recording")
        
        audioLocked = true
    }


    
    func audioToolbarContent() -> some View {
        HStack{
            if audioLocked == false {
                appearance.images.addAudio
                    .resizable()
                    .frame(width: appearance.imagesSize.messageAudioButton.width, height: appearance.imagesSize.messageAudioButton.height)
                    .foregroundColor(isShowingRedTimerStart ? .red : .clear)
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
    
    func cancelRecording() {
        if isClicked {
            self.chatViewModel.countSec = 0
            self.chatViewModel.timerValue = "0:00"
            chatViewModel.isRecording = false
            isClicked = false
            audioLocked = false
            chatViewModel.stopRecording { _ in }
        }
    }

    // Stop recording action handler
    func stopRecording() {
        if isClicked {
            chatViewModel.isRecording = false
            self.chatViewModel.countSec = 0
            self.chatViewModel.timerValue = "0:00"
            isClicked = false
            audioLocked = false
            chatViewModel.stopRecording { url in
                chatViewModel.audioUrl = url
            }
        }
    }
    
    func inputTextView() -> some View {
        HStack {
            // Attachment Button
            if !ISMChatSdkUI.getInstance().getChatProperties().attachments.isEmpty {
                attachmentButton
            }
            
            HStack(spacing: 5) {
                // GIF Button (on left)
                if chatFeatures.contains(.gif),
                   ISMChatSdkUI.getInstance().getChatProperties().gifLogoOnTextViewLeft == true {
                    gifButton
                        .padding(.leading, 10)
                }
                
                // Text Field
                messageTextField
                
                // GIF Button (on right, when TextField is empty)
                if chatFeatures.contains(.gif),
                   textFieldtxt.isEmpty,
                   ISMChatSdkUI.getInstance().getChatProperties().gifLogoOnTextViewLeft == false {
                    gifButton
                        .frame(width: 15, height: 15)
                        .padding(.horizontal, 10)
                }
            }.padding(.vertical,5)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(appearance.colorPalette.messageListTextViewBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(appearance.colorPalette.messageListTextViewBoarder, lineWidth: 1)
            )
        }
    }

    // MARK: - Subviews
    private var attachmentButton: some View {
        Button(action: {
            DispatchQueue.main.async {
                showActionSheet = true
            }
        }) {
            appearance.images.addAttcahment
                .resizable()
                .frame(width: appearance.imagesSize.addAttachmentIcon.width, height: appearance.imagesSize.addAttachmentIcon.height)
                .padding(.horizontal, 5)
        }
    }

    private var gifButton: some View {
        Button {
            DispatchQueue.main.async {
                showGifPicker = true
            }
        } label: {
            appearance.images.addSticker
                .resizable()
                .frame(width: 20, height: 20)
        }
    }

    private var messageTextField: some View {
        TextField(appearance.constantStrings.messageInputTextViewPlaceholder, text: $textFieldtxt, axis: .vertical)
            .textInputAutocapitalization(.never) // Prevents autocapitalization
            .disableAutocorrection(true) 
            .lineLimit(5)
            .onTapGesture {
                scrollToLastMessage()
            }
            .font(appearance.fonts.messageListTextViewText ?? .body)
            .foregroundColor(appearance.colorPalette.messageListTextViewText ?? .black)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                keyboardFocused = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardFocused = false
            }
    }
    
    private func scrollToLastMessage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if let lastMessageId = realmManager.messages.last?.last?.id.description {
                parentMessageIdToScroll = lastMessageId
            } else {
                print("No last message found in Realm")
            }
        }
    }
}


struct ReplyToolBarView : View {
    @Binding var selectedMsgToReply : MessagesDB
    @State var appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @ObservedObject public var stateViewModel = UIStateViewModel()
    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 5, height: 50)
                .foregroundColor(appearance.colorPalette.messageListReplyToolbarRectangle)
            Spacer()
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    let myUserId = ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig.userId
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
                        appearance.images.pdfLogo
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40, alignment: .center)
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
}
