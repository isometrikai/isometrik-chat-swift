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
                    .font(themeFonts.messageList_toolbarSelected)
                    .foregroundColor(themeColor.messageList_toolbarSelected)
                Spacer()
                Button {
                    movetoForwardList = true
                } label: {
                    Text("Forward")
                        .foregroundColor(forwardMessageSelected.count == 0 ? themeColor.messageList_TextViewPlaceholder : themeColor.messageList_toolbarAction)
                        .font(themeFonts.messageList_toolbarAction)
                }
                .disabled(forwardMessageSelected.count == 0)
            }
            .frame(height: 40)
            .padding(.vertical,10)
            .padding(.horizontal,20)
        }
        .background(themeColor.messageList_ToolBarBackground)
    }
    
    //MARK: - NO LONGER MEMBER TOOLBAR
    
    func NoLongerMemberToolBar() -> some View{
        VStack{
            HStack{
                Text("You can't send messages to this group because you're no longer a member.")
                    .foregroundColor(themeColor.messageList_TextViewPlaceholder)
                    .font(themeFonts.messageList_MessageText)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical,10)
            .padding(.horizontal,20)
        }
        .frame(height: 80)
        .background(themeColor.messageList_ToolBarBackground)
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
        .background(themeColor.messageList_ToolBarBackground)
    }
    
    //MARK: - REPLY MESSAGE TOOLBAR
    
    func replyMessageToolBarView() -> some View {
        HStack {
            Rectangle()
                .frame(width: 5, height: 50)
                .foregroundColor(themeColor.messageList_ReplyToolbarRectangle)
            Spacer()
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedMsgToReply.senderInfo?.userIdentifier != userId ? "\(selectedMsgToReply.senderInfo?.userName ?? "")" : ConstantStrings.you)
                        .font(themeFonts.messageList_ReplyToolbarHeader)
                        .foregroundColor(themeColor.messageList_ReplyToolbarHeader)
                    
                    let msg = selectedMsgToReply.body
                    switch ISMChat_Helper.getMessageType(message: selectedMsgToReply) {
                    case .video:
                        Label {
                            Text(selectedMsgToReply.metaData?.captionMessage != nil ? (selectedMsgToReply.metaData?.captionMessage ?? "Video") : "Video")
                                .font(themeFonts.messageList_ReplyToolbarDescription)
                                .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            themeImages.replyVideoIcon
                                .resizable()
                                .frame(width: 14,height: 12)
                                .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                        }
                    case .photo:
                        Label {
                            Text(selectedMsgToReply.metaData?.captionMessage != nil ? (selectedMsgToReply.metaData?.captionMessage ?? "Photo") : "Photo")
                                .font(themeFonts.messageList_ReplyToolbarDescription)
                                .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            themeImages.replyCameraIcon
                                .resizable()
                                .frame(width: 14,height: 12)
                                .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                        }
                    case .audio:
                        Label {
                            Text("Audio")
                                .font(themeFonts.messageList_ReplyToolbarDescription)
                                .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            themeImages.replyAudioIcon
                                .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                        }
                    case .document:
                        Label {
                            let str = URL(string: selectedMsgToReply.attachments.first?.mediaUrl ?? "")?.lastPathComponent.components(separatedBy: "_").last
                            Text(str ?? "Document")
                                .font(themeFonts.messageList_ReplyToolbarDescription)
                                .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            themeImages.replyDocumentIcon
                                .resizable()
                                .frame(width: 14,height: 12)
                                .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                        }
                    case .location:
                        Label {
                            let location = "\(selectedMsgToReply.attachments.first?.title ?? "Location") \(selectedMsgToReply.attachments.first?.address ?? "")"
                            Text(location)
                                .font(themeFonts.messageList_ReplyToolbarDescription)
                                .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            themeImages.replyLocationIcon
                                .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                        }
                    case .contact:
                        Label {
                            if let count = selectedMsgToReply.metaData?.contacts.count{
                                if count == 1{
                                    let contactText = "\(selectedMsgToReply.metaData?.contacts.first?.contactName ?? "")"
                                    Text(contactText)
                                        .font(themeFonts.messageList_ReplyToolbarDescription)
                                        .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                                        .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                                }else{
                                    let contactText = "\(selectedMsgToReply.metaData?.contacts.first?.contactName ?? "") and \(count - 1) other contacts"
                                    Text(contactText)
                                        .font(themeFonts.messageList_ReplyToolbarDescription)
                                        .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                                        .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                                }
                            }else{
                                let contactText = "Contacts"
                                Text(contactText)
                                    .font(themeFonts.messageList_ReplyToolbarDescription)
                                    .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                                    .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                            }
                        } icon: {
                            themeImages.replyContactIcon
                                .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                        }
                    case .sticker:
                        AnimatedImage(url: URL(string: selectedMsgToReply.attachments.first?.mediaUrl ?? ""))
                            .resizable()
                            .frame(width: 40, height: 40)
                    case .gif:
                        Label {
                            Text("GIF")
                                .font(themeFonts.messageList_ReplyToolbarDescription)
                                .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                        } icon: {
                            themeImages.replyGifIcon
                                .resizable()
                                .frame(width: 20, height: 15)
                        }
                    default:
                        Text(msg)
                            .font(themeFonts.messageList_ReplyToolbarDescription)
                            .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
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
                if ISMChat_Helper.getMessageType(message: selectedMsgToReply) == .photo{
                    ISMChat_ImageCahcingManger.networkImage(url: selectedMsgToReply.attachments.first?.mediaUrl ?? "",isprofileImage: false)
                        .frame(width: 40, height: 40, alignment: .center)
                        .cornerRadius(5)
                }else if ISMChat_Helper.getMessageType(message: selectedMsgToReply) == .video{
                    ISMChat_ImageCahcingManger.networkImage(url: selectedMsgToReply.attachments.first?.thumbnailUrl ?? "",isprofileImage: false)
                        .frame(width: 40, height: 40, alignment: .center)
                        .cornerRadius(5)
                }else if ISMChat_Helper.getMessageType(message: selectedMsgToReply) == .document{
                    if let documentUrl = URL(string: selectedMsgToReply.attachments.first?.mediaUrl ?? ""){
                        themeImages.pdfLogo
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40, alignment: .center)
                    }
                }
                else if ISMChat_Helper.getMessageType(message: selectedMsgToReply) == .gif{
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
        .background(themeColor.messageList_ToolBarBackground)
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
                                    userName: userName,font: themeFonts.chatList_UserMessage)
                                Text(userName)
                                    .font(themeFonts.chatList_UserMessage)
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
                                ResizeableTextView(text: $textFieldtxt, height: $textViewHeight, typingStarted: $keyboardFocused, placeholderText: "Type a message", showMentionList: $showMentionList,filteredMentionUserCount: filteredUsers.count,mentionUser : $selectedUserToMention, placeholderColor : themeColor.messageList_TextViewPlaceholder,textViewColor : themeColor.messageList_TextViewText)
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
                                    .font(themeFonts.messageList_MessageText)
                                    .foregroundColor(themeColor.messageList_MessageText)
                                
                                Spacer()
                                
                                Text("Slide to cancel")
                                    .foregroundStyle(Color.gray)
                                    .font(themeFonts.messageList_MessageText)
                                
                                themeImages.chevranbackward
                                    .tint(.gray)
                            }else{
                                VStack(alignment: .leading){
                                    Text(viewModel.timerValue)
                                        .font(themeFonts.messageList_MessageText)
                                        .foregroundColor(themeColor.messageList_MessageText)
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
                                                .foregroundColor(themeColor.messageList_MessageText)
                                        })
                                        Spacer()
                                        
                                        Text("Audio Locked")
                                            .foregroundColor(themeColor.messageList_TextViewPlaceholder)
                                            .font(themeFonts.messageList_MessageText)
                                        
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
                                        }.background(themeColor.messageList_ToolBarBackground)
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
                .background(themeColor.messageList_ToolBarBackground)
            }
        }
    }
}
