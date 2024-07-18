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
                    movetoForwardList = true
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
                    Text(selectedMsgToReply.senderInfo?.userId != myUserId ? "\(selectedMsgToReply.senderInfo?.userName ?? "")" : ConstantStrings.you)
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
                    AnimatedImage(url: URL(string: selectedMsgToReply.attachments.first?.mediaUrl ?? ""),isAnimating: $isAnimating)
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
        .background(themeColor.messageListToolBarBackground)
        .frame(height: 50)
    }
    
    //MARK: - DEFAULT TOOLBAR VIEW
    
    func toolBarView() -> some View {
        VStack(spacing: 0) {
            if showMentionList && isGroup == true && filteredUsers.count > 0{
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
                                self.showMentionList = false
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
            if showforwardMultipleMessage {
                forwardMessageToolBarView()
            } else if showDeleteMultipleMessage {
                deleteMessageToolBarView()
            } else {
                if (selectedMsgToReply.messageId != "") {
                    replyMessageToolBarView()
                }
                if textFieldtxt.isValidURL{
                   // LinkPreviewToolBarView(text: textFieldtxt)
                }
                VStack {
                    let height: CGFloat = 20
                    
                    HStack {
                        if !viewModel.isRecording {
                            Button(action: { showActionSheet = true }) {
                                themeImages.addAttcahment
                                    .resizable()
                                    .frame(width: 20,height: 20)
                                    .padding(.horizontal,5)
                            }
                            
                            HStack(spacing : 5){
                                ResizeableTextView(text: $textFieldtxt, height: $textViewHeight, typingStarted: $keyboardFocused, placeholderText: "Type a message", showMentionList: $showMentionList,filteredMentionUserCount: filteredUsers.count,mentionUser : $selectedUserToMention, placeholderColor : themeColor.messageListTextViewPlaceholder,textViewColor : themeColor.messageListTextViewText)
                                    .frame(height: textViewHeight < 160 ? self.textViewHeight : 160)
                                if showGifOption == true && textFieldtxt.isEmpty{
                                    Button {
                                        showGifPicker = true
                                    } label: {
                                        themeImages.addSticker
                                            .resizable()
                                            .frame(width: 15,height: 15)
                                            .padding(.horizontal,10)
                                    }
                                }
                            }.overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.border, lineWidth: 1)
                            )
                        } else {
                            if audioLocked == false{
                                
                                themeImages.addAudio
                                    .resizable()
                                    .frame(width: 24,height: 24)
                                    .foregroundColor(isShowingRedTimerStart ? .red : .clear)
                                    .padding(.leading)
                                
                                Text(viewModel.timerValue)
                                    .font(themeFonts.messageListMessageText)
                                    .foregroundColor(themeColor.messageListMessageText)
                                
                                Spacer()
                                
                                Text("Slide to cancel")
                                    .foregroundStyle(Color.gray)
                                    .font(themeFonts.messageListMessageText)
                                
                                themeImages.chevranbackward
                                    .tint(.gray)
                            }else{
                                VStack(alignment: .leading){
                                    Text(viewModel.timerValue)
                                        .font(themeFonts.messageListMessageText)
                                        .foregroundColor(themeColor.messageListMessageText)
                                    HStack(alignment : .center){
                                        Button(action: {
                                            if isClicked == true{
                                                viewModel.isRecording = false
                                                self.isClicked = false
                                                self.audioLocked = false
                                                viewModel.stopRecording { url in
                                                }
                                            }
                                        }, label: {
                                            themeImages.trash
                                                .resizable()
                                                .frame(width: 25, height: 28, alignment: .center)
                                                .foregroundColor(themeColor.messageListMessageText)
                                        })
                                        Spacer()
                                        
                                        Text("Audio Locked")
                                            .foregroundColor(themeColor.messageListTextViewPlaceholder)
                                            .font(themeFonts.messageListMessageText)
                                        
                                        Spacer()
                                        Button(action: {
                                            if isClicked == true{
                                                viewModel.isRecording = false
                                                self.isClicked = false
                                                self.audioLocked = false
                                                viewModel.stopRecording { url in
                                                    viewModel.audioUrl = url
                                                }
                                            }
                                        }, label: {
                                            themeImages.sendMessage
                                                .resizable()
                                                .frame(width: 32, height: 32, alignment: .center)
                                        })
                                    }
                                }
                            }
                        }
                        
                        if !textFieldtxt.isEmpty ||  showAudioOption == false{
                            Button(action: { sendMessage(msgType: .text) }) {
                                themeImages.sendMessage
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .padding(.horizontal,5)
                            }
                        } else {
                            ZStack{
                                if audioLocked == false{
                                    if viewModel.isRecording{
                                        VStack{
                                            themeImages.audioLock
                                                .padding()
                                            Spacer()
                                        }.background(themeColor.messageListToolBarBackground)
                                            .cornerRadius(20,corners: .topLeft)
                                            .cornerRadius(20,corners: .topRight)
                                            .frame(width: 30, height: 50, alignment: .center)
                                            .offset(y : -50)
                                    }
                                    AudioMessageButton(height: height)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.bottom,20)
                .padding(.horizontal, 10)
                .background(themeColor.messageListToolBarBackground)
            }
        }
    }
}
