//
//  MessageList.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 24/01/23.
//

import SwiftUI
import Combine
import LinkPresentation
import UIKit
import _PhotosUI_SwiftUI
import MediaPicker
import AVFoundation
import PhotosUI
//import GiphyUISDK
import ISMSwiftCall
import IsometrikChat

public protocol ISMMessageViewDelegate{
    func navigateToAppProfile(appUserId : String)
    func navigateToPost(postId : String)
}

public struct ISMMessageView: View {
    
    //MARK: - PROPERTIES
    
    @Environment(\.dismiss) public var dismiss
    @ObservedObject public var viewModel = ChatsViewModel(ismChatSDK: ISMChatSdk.getInstance())
    public var conversationViewModel = ConversationViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @State public var text = ""
    @State public var textFieldtxt = ""
    @State public var keyboardFocused = false
    
    @State public var showActionSheet = false
    @State public var conversationID : String?
    public let opponenDetail : UserDB?
    public var myUserId : String?
    public let isGroup : Bool?
    public let fromBroadCastFlow : Bool?
    public let groupCastId : String?

    @State public var textViewHeight : CGFloat = 32
    
    @State public var showVideoPicker: Bool = false
    
    @State public var showLocationSharing: Bool = false
    
    @State public var showSheet : Bool = false
    @State public var selectedSheetIndex : Int = 0
    public let columns = [GridItem(.flexible(minimum: 10))]
    
    @State public var selectedContactToShare : [ISMChatPhoneContact] = []
    @State public var shareContact : Bool = false
    
    
    @State public var conversationDetail : ISMChatConversationDetail?
    @State public var showScrollToBottomView = true
    
    @EnvironmentObject public var realmManager : RealmManager
    
    @State public var previousAudioRef: AudioPlayViewModel?
    @State public var audioLocked : Bool = false
    
    @State public var isShowingRedTimerStart : Bool = false
    
    @State public var showDeleteMultipleMessage = false
    @State public var deleteMessage : [MessagesDB] = []
    @State public var showDeleteActionSheet = false
    
    @State public var selectedMsgToReply : MessagesDB = MessagesDB()
    @State public var parentMessage : ISMChatMessage = ISMChatMessage()
    
    @State public var showforwardMultipleMessage : Bool = false
    @State public var forwardMessageSelected : [MessagesDB] = []
    @State public var movetoForwardList : Bool = false
    @EnvironmentObject public var networkMonitor: NetworkMonitor
    
    @State public var isClicked : Bool = false
    @State public var uploadMedia : Bool = false
    
    @State public var audioPermissionCheck :Bool = false
    @State public var memberString : String?
    
    @State public var executeRepeatly : Bool = false
    @State public var otherUserTyping : Bool = false
    
    @State public var navigateToBlockUsers = false
    @State public var navigateToProfile = false
    @State public var navigateToGroupCastInfo  : Bool = false
    
    //location
    @State public var longitude : Double?
    @State public var latitude : Double?
    @State public var placeId : String?
    @State public var placeName : String?
    @State public var placeAddress : String?
    
    @State public var typingUserName : String?
    @State public var showUnblockPopUp : Bool = false
    @State public var uAreBlock : Bool = false
    
    @State public var clearThisChat : Bool = false
    @State public var blockThisChat : Bool = false
    
    @State public var startDate = Date.now
    @State public var timeElapsed: Int = 0
    @State public var showingNoInternetAlert = false
    public let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    @State public var startTimeForOnline = Date.now
    @State public var timeElapsedForOnline: Int = 0
    public let onlinetimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    @State public var executeRepeatlyForOfflineMessage : Bool = false
    
    @State public var onLoad : Bool = false
    
    @State public var messageCopied : Bool = false
    
    public let groupConversationTitle : String?
    public let groupImage : String?
    
    @State public var navigateToLocationDetail : ISMChatLocationData = ISMChatLocationData()
    @State public var navigateToLocation = false
    
    @State public var updateMessage : MessagesDB = MessagesDB()
    
    @State public var selectedUserToMention : String?
    @State public var showMentionList : Bool = false
    @State public var mentionUsers: [ISMChatGroupMember] = []
    @State public var filteredUsers: [ISMChatGroupMember] = []
    
    @State public var showAudioOption = ISMChatSdkUI.getInstance().getChatProperties().features.contains(.audio)
    @State public var showAudioCallingOption = ISMChatSdkUI.getInstance().getChatProperties().features.contains(.audiocall)
    @State public var showVideoCallingOption = ISMChatSdkUI.getInstance().getChatProperties().features.contains(.videocall)
    @State public var showGifOption = ISMChatSdkUI.getInstance().getChatProperties().features.contains(.gif)
    @State public var showGifPicker : Bool = false

    
    @State public var navigateToImageEditor : Bool = false
    @State public var sendMedia : Bool = false
    
    @State public var videoSelectedFromPicker : [ISMMediaUpload] = []
    
    //camera click
    @State public var cameraImageToUse : URL?
    
    //reaction
    @State public var selectedReaction : String? = nil
    @State public var sentRecationToMessageId : String = ""
    // call
    @State public var audioCallToUser : Bool = false
    @State public var videoCallToUser : Bool = false
    @State public var showCallPopUp : Bool = false
    @State public var isAnimating = false
    @State public var parentMsgToScroll : MessagesDB? =  nil
    
    @State public var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State public var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State public var themeImages = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    @State public var userSession = ISMChatSdk.getInstance().getUserSession()
    
    @State var postIdToNavigate : String = ""
    
    public var delegate : ISMMessageViewDelegate?
    
    //MARK: - BODY
    public var body: some View {
        VStack{
            ZStack{
                themeColor.chatListBackground.edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    ZStack{
                        GeometryReader{ reader in
                            ScrollView{
                                ScrollViewReader{ scrollReader in
                                    getMessagesView(scrollReader: scrollReader, viewWidth: reader.size.width)
                                        .padding(.horizontal)
                                }
                            }
                            .coordinateSpace(name: "scroll")
                            .coordinateSpace(name: "pullToRefresh")
                            .overlay(showScrollToBottomView ? scrollToBottomButton() : nil, alignment: Alignment.bottomTrailing)
                            .gesture(DragGesture().onChanged { value in
                                // Calculate the velocity
                                let velocity = value.predictedEndTranslation.height - value.translation.height
                                // Define a threshold value for fast scrolling
                                let fastScrollThreshold: CGFloat = 65
                                if velocity > fastScrollThreshold {
                                    //--------FAST SCROLL---------//
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                } else {
                                    //--------SLOW SCROLL---------//
                                }
                            })
                        }.padding(.bottom,5)
                        //No Message View
                        if realmManager.allMessages?.count == 0 || realmManager.messages.count == 0{
                            //
                            themeImages.noMessagePlaceholder
                                .resizable()
                                .frame(width: 206, height: 144, alignment: .center)
                            
                        }
                    }.onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    if isGroup == true{
                        if !networkMonitor.isConnected{
                            toolBarView()
                        }else{
                            //here we are checking if your a member of group anymore
                            if let conversation = conversationDetail?.conversationDetails{
                                if let members = conversation.members,
                                    members.contains(where: { member in
                                       return member.userId == userSession.getUserId()
                                   }) {
                                    toolBarView()
                                } else {
                                    NoLongerMemberToolBar()
                                }
                            }else{
                                toolBarView()
                            }
                        }
                    }else{
                        toolBarView()
                    }
                }//VStack
                .onAppear {
                    setupOnAppear()
                    navigateToImageEditor = false
                }
                .onDisappear{
                    executeRepeatly = false
                    executeRepeatlyForOfflineMessage = false
                    onLoad = false
                }
                //zstack views
                if viewModel.isBusy{
                    //Custom Progress View
                    ActivityIndicatorView(isPresented: $viewModel.isBusy)
                }
                if messageCopied == true{
                    Text("Message copied")
                        .font(themeFonts.alertText)
                        .padding()
                        .background(themeColor.alertBackground)
                        .foregroundColor(themeColor.alertText)
                        .cornerRadius(5)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                messageCopied = false
                            }
                        }
                }
            }
        }//:vStack
        .padding(.top, 5)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(leading: navigationBarLeadingButtons(), trailing: navigationBarTrailingButtons())
        .navigationBarBackButtonHidden(true)
        .confirmationDialog("", isPresented: $showActionSheet, titleVisibility: .hidden) {
            attachmentActionSheetButtons()
        }
        .confirmationDialog("", isPresented: $showDeleteActionSheet, titleVisibility: .hidden) {
            deleteActionSheetButtons()
        }
        .confirmationDialog("", isPresented: $showUnblockPopUp) {
            unblockActionSheetButton()
        } message: {
            Text("Unblock contact to send a message")
        }
        .confirmationDialog("", isPresented: $uAreBlock) {
        } message: {
            Text("Action not allowed, the user has already blocked You")
        }
        .confirmationDialog("", isPresented: $clearThisChat) {
            Button("Delete", role: .destructive) {
                clearChat()
            }
        } message: {
            Text("Clear all messages from \(conversationDetail?.conversationDetails?.opponentDetails?.userName ?? "this chat")? \n This chat will be empty but will remain in your chat list.")
        }
        .confirmationDialog("", isPresented: $blockThisChat) {
            Button("Block", role: .destructive) {
                blockChatFromUser()
            }
        } message: {
            Text("Block \(conversationDetail?.conversationDetails?.opponentDetails?.userName ?? "")? \n Blocked user will be no longer be able to send you messages.")
        }
        .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttMessageDelivered.name)){ notification in
            guard let messageInfo = notification.userInfo?["data"] as? ISMChatMessageDelivered else {
                return
            }
            ISMChatHelper.print("MESSAGE DELIVERED----------------->\(messageInfo)")
            messageDelivered(messageInfo: messageInfo)
        }
        .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttMessageNewReceived.name)){ notification in
            guard let messageInfo = notification.userInfo?["data"] as? ISMChatMessageDelivered else {
                return
            }
            ISMChatHelper.print("MESSAGE RECEIVED----------------->\(messageInfo)")
            //save in local db
            if !(self.realmManager.doesMessageExistInMessagesDB(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "")){
                messageReceived(messageInfo: messageInfo)
                //local notification
                sendLocalNotification(messageInfo: messageInfo)
                //action if required
                actionOnMessageDelivered(messageInfo: messageInfo)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttMessageRead.name)){ notification in
            guard let messageInfo = notification.userInfo?["data"] as? ISMChatMessageDelivered else {
                return
            }
            ISMChatHelper.print("MESSAGE READ ----------------->\(messageInfo)")
            messageRead(messageInfo: messageInfo)
        }
        .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttUserBlockConversation.name)){
            notification in
            guard let messageInfo = notification.userInfo?["data"] as? ISMChatMessageDelivered else {
                return
            }
            ISMChatHelper.print("USER BLOCKED ----------------->\(messageInfo)")
            if !(self.realmManager.doesMessageExistInMessagesDB(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "")){
                messageReceived(messageInfo: messageInfo)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttUserUnblockConversation.name)){
            notification in
            guard let messageInfo = notification.userInfo?["data"] as? ISMChatMessageDelivered else {
                return
            }
            ISMChatHelper.print("USER UNBLOCKED ----------------->\(messageInfo)")
            if !(self.realmManager.doesMessageExistInMessagesDB(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "")){
                messageReceived(messageInfo: messageInfo)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttUserBlock.name)){
            notification in
            guard let messageInfo = notification.userInfo?["data"] as? ISMChatUserBlockAndUnblock else {
                return
            }
            ISMChatHelper.print("USER BLOCKED ----------------->\(messageInfo)")
            if !(self.realmManager.doesMessageExistInMessagesDB(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "")){
                userBlockedAndUnblocked(messageInfo: messageInfo)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttUserUnblock.name)){
            notification in
            guard let messageInfo = notification.userInfo?["data"] as? ISMChatUserBlockAndUnblock else {
                return
            }
            ISMChatHelper.print("USER UNBLOCKED ----------------->\(messageInfo)")
            if !(self.realmManager.doesMessageExistInMessagesDB(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "")){
                userBlockedAndUnblocked(messageInfo: messageInfo)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttTypingEvent.name)){ notification in
            guard let messageInfo = notification.userInfo?["data"] as? ISMChatTypingEvent else {
                return
            }
            ISMChatHelper.print("TYPING EVENT----------------->\(messageInfo)")
            userTyping(messageInfo: messageInfo)
        }
//        .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttMeetingCreated.name)){ notification in
//            guard let messageInfo = notification.userInfo?["data"] as? ISMMeeting else {
//                return
//            }
//            ISMChatHelper.print("Meeting craeted----------------->\(messageInfo)")
//            if messageInfo.conversationId == self.conversationID{
//                addMeeting(messageInfo: messageInfo)
//            }
//        }
        .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttMeetingEnded.name)){ notification in
            guard let messageInfo = notification.userInfo?["data"] as? ISMMeeting else {
                return
            }
            ISMChatHelper.print("Meeting ended----------------->\(messageInfo)")
            if messageInfo.conversationId == self.conversationID{
                if !(self.realmManager.doesMessageExistInMessagesDB(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "")){
                    addMeeting(messageInfo: messageInfo)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttMultipleMessageRead.name)){ notification in
            guard let messageInfo = notification.userInfo?["data"] as? ISMChatMultipleMessageRead else {
                return
            }
            ISMChatHelper.print("MULTIPLE MESSAGE READ ----------------->\(messageInfo)")
            multipleMessageRead(messageInfo: messageInfo)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.memberAddAndRemove)) { _ in
            self.getConversationDetail()
        }
        .onChange(of: viewModel.documentSelectedFromPicker) { newValue in
            sendMessageIfDocumentSelected()
        }
        .onChange(of: selectedReaction) { newValue in
            if selectedReaction != nil{
                sendReaction()
            }
        }
        .onChange(of: textFieldtxt){ newValue in
            if isGroup == true{
                let filterUserName = getMentionedString(inputString: textFieldtxt)
                if !filterUserName.isEmpty {
                    filteredUsers = mentionUsers.filter { user in
                        let lowercasedUserName = (user.userName ?? "").lowercased()
                        return lowercasedUserName.contains(filterUserName.lowercased())
                    }
                    // If there are no matching users, set filteredUsers to an empty array
                    if filteredUsers.isEmpty {
                        filteredUsers = []
                        showMentionList = false
                    }
                } else {
                    filteredUsers = mentionUsers
                }
            }
        }
        .onChange(of: navigateToLocationDetail.title){
            navigateToLocation = true
        }
        .onChange(of: audioCallToUser, { _, _ in
            if audioCallToUser == true{
                showCallPopUp = true
            }
        })
        .onChange(of: videoCallToUser, { _, _ in
            if videoCallToUser == true{
                showCallPopUp = true
            }
        })
        .onChange(of: cameraImageToUse, { _, _ in
            if cameraImageToUse != nil {
                sendMessage(msgType: .photo)
            }
        })
        .onChange(of: viewModel.audioUrl) { newValue in
            sendMessageIfAudioUrl()
        }
        .onChange(of: keyboardFocused) { newValue in
            if conversationDetail != nil{
                sendMessageTypingIndicator()
            }
        }
//        .onChange(of: selectedGIF, { _, _ in
//            sendMessageIfGif()
//        })
        .onChange(of: sendMedia, { _, _ in
            sendMessageIfUploadMedia()
        })
        .onChange(of: updateMessage.body) { newValue in
            self.textFieldtxt = updateMessage.body
            keyboardFocused = true
        }
        .onChange(of: self.placeId) { newValue in
            sendMessageIfPlaceId()
        }
        .onChange(of: viewModel.timerValue, perform: { newValue in
            withAnimation {
                isShowingRedTimerStart.toggle()
            }
        })
        .onChange(of: postIdToNavigate) { newValue in
            if !postIdToNavigate.isEmpty{
                delegate?.navigateToPost(postId: postIdToNavigate)
                postIdToNavigate = ""
            }
        }
        .onChange(of: shareContact, perform: { newValue in
            if !self.selectedContactToShare.isEmpty {
                sendMessage(msgType: .contact)
                shareContact = false
            }
        })
        .sheet(isPresented: $showGifPicker, content: {
//            GiphyPicker { media in
//                if let media = media{
//                    selectedGIF = media
//                    showGifPicker = false
//                }
//            }
        })
        .sheet(isPresented: $showSheet){
            if selectedSheetIndex == 0 {
                ISMCameraView(media : $cameraImageToUse, isShown: self.$showSheet, uploadMedia: $uploadMedia)
            } else if selectedSheetIndex == 1 {
                DocumentPicker(documents: $viewModel.documentSelectedFromPicker, isShown: self.$showSheet)
            } else{
                ISMShareContactList(dissmiss: self.$showSheet , selectedContact: self.$selectedContactToShare, shareContact: self.$shareContact)
            }
        }
        .mediaImporter(
            isPresented: self.$showVideoPicker,
            allowedMediaTypes: [.videos, .images],
            allowsMultipleSelection: true,
            onCompletion: handleMediaImporterResult,
            loadingOverlay: { _ in
                ProgressView()
            }
        )
        .background(NavigationLink("", destination: ISMForwardToContactView(viewModel : self.viewModel, conversationViewModel : self.conversationViewModel, messages: $forwardMessageSelected, showforwardMultipleMessage: $showforwardMultipleMessage),isActive: $movetoForwardList))
        .background(NavigationLink("", destination: ISMLocationShareView(longitude: $longitude, latitude: $latitude, placeId: $placeId,placeName : $placeName, address: $placeAddress),isActive: $showLocationSharing))
//        .background(NavigationLink("", destination: ISMChatBroadCastInfo(broadcastTitle: (self.groupConversationTitle ?? ""),groupCastId: self.groupCastId ?? "").environmentObject(self.realmManager),isActive: $navigateToGroupCastInfo))
        .background(NavigationLink("", destination: ISMContactInfoView(conversationID: self.conversationID,conversationDetail : self.conversationDetail, viewModel:self.viewModel, isGroup: self.isGroup).environmentObject(self.realmManager),isActive: $navigateToProfile))
//        .background(NavigationLink("", destination: ISMMapDetailView(data: navigateToLocationDetail),isActive: $navigateToLocation))
        .background(NavigationLink("", destination: ISMImageAndViderEditor(media: $videoSelectedFromPicker, sendToUser: opponenDetail?.userName ?? "",sendMedia: $sendMedia),isActive: $navigateToImageEditor))
        .onReceive(timer, perform: { firedDate in
            print("timer fired")
            timeElapsed = Int(firedDate.timeIntervalSince(startDate))
            if executeRepeatly == true && fromBroadCastFlow != true{
                self.executeRepeatedly()
            }
        })
        .onReceive(onlinetimer, perform: { firedtime in
            print("online timer fired")
            timeElapsedForOnline = Int(firedtime.timeIntervalSince(startTimeForOnline))
            if executeRepeatlyForOfflineMessage == true{
                sendLocalMsg()
            }
        })
        .alert("Ooops! It looks like your internet connection is not working at the moment. Please check your network settings and make sure you're connected to a Wi-Fi network or cellular data.", isPresented: $showingNoInternetAlert) {
            Button("OK", role: .cancel) { }
        }
        .alert("Call \(self.opponenDetail?.userName ?? "")", isPresented: $showCallPopUp) {
            Button("Cancel", role: .cancel) {
                if audioCallToUser == true{
                    audioCallToUser = false
                }
                if videoCallToUser == true{
                    videoCallToUser = false
                }
            }
            if audioCallToUser {
                Button("Voice Call") {
                    audioCallToUser = false
                    calling(type: .AudioCall)
                }
            }
            if videoCallToUser {
                Button("Video Call") {
                    videoCallToUser = false
                    calling(type: .VideoCall)
                }
            }
        }
        .onLoad {
            self.realmManager.clearMessages()
            self.getMessages()
            //added this from on appear
           
            if fromBroadCastFlow == true{
                reloadBroadCastMessages()
            }else{
                getConversationDetail()
                reload()
            }
            if showAudioOption == true{
                checkAudioPermission()
            }
            realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
            realmManager.fetchFiles(conId: self.conversationID ?? "")
            realmManager.fetchLinks(conId: self.conversationID ?? "")
            
            realmManager.updateUnreadCountThroughConId(conId: self.conversationID ?? "",count: 0,reset:true)
            if !networkMonitor.isConnected {
                showingNoInternetAlert = true
            }
            //fix to don't show scroll to Bottom button when message count is zero
            if realmManager.allMessages?.count == 0{
                showScrollToBottomView = false
            }
            onLoad = true
            ISMChatSdk.getInstance().getUserDetail(isometrikUserId: self.opponenDetail?.userId ?? "", userName: self.opponenDetail?.userName ?? "", completion: { data in
                print(data)
            })
        }
    }
    
    
    
    
    
    //MARK: - CONFIGURE
    
    //locally getting messages here
    func getMessages() {
        realmManager.getMsgsThroughConversationId(conversationId: self.conversationID ?? "")
        self.realmManager.messages = viewModel.getSectionMessage(for: self.realmManager.allMessages ?? [])
        if self.realmManager.messages.count > 0 {
            if (self.realmManager.messages.last?.count ?? 0) > 0 {
                if let msgObj = self.realmManager.messages.last?.last {
                    //don't update last message if it action id reaction Add or Remove, as we filter those in message List
                    let action = realmManager.getConversationListLastMessageAction(conversationId: self.conversationID ?? "")
                    if action != ISMChatActionType.reactionAdd.value && action != ISMChatActionType.reactionRemove.value{
                        realmManager.updateLastMessageDetails(conId: self.conversationID ?? "", msgObj: msgObj)
                    }
                }
            }
        }
    }
    
    
    //checking if we are allowed to send message or not
    func isMessagingEnabled() -> Bool{
        if self.conversationDetail?.conversationDetails?.messagingDisabled == true{
            if realmManager.messages.last?.last?.initiatorId != userSession.getUserId(){
                uAreBlock = true
            }else{
                showUnblockPopUp = true
            }
            return false
        }else{
            return true
        }
    }
    
    //conversation Detail Api
    func getConversationDetail(){
        if self.conversationID != nil && self.conversationID != ""{
            //GET CONVERSATION DETAIL API
            viewModel.getConversationDetail(conversationId: self.conversationID ?? "", isGroup: self.isGroup ?? false) { data in
                self.conversationDetail = data
                if isGroup == true{
                    if let members = data?.conversationDetails?.members {
                        if members.count >= 2{
                            self.memberString = members.prefix(2).map { $0.userName ?? "" }.joined(separator: ", ")
                            if members.count > 2 {
                                self.memberString! += ", and others"
                            }
                        }else{
                            self.memberString = members.map { $0.userName ?? "" }.joined(separator: ", ")
                        }
                        //mentionUser Flow
                        mentionUsers.removeAll()
                        filteredUsers.removeAll()
                        let filteredMembers = members.filter { $0.userId != userSession.getUserId() }
                        mentionUsers.append(contentsOf: filteredMembers)
                    }
                    if self.isGroup == true{
                        realmManager.updateMemberCount(convId: (self.conversationID ?? ""), inc: false, dec: false, count: (data?.conversationDetails?.membersCount ?? 0))
                    }
                }
//                reload()
            }
        }
    }
    
    func reloadBroadCastMessages(){
//        
//        self.realmManager.getMsgsThroughGroupCastId(groupcastId: self.groupCastId ?? "")
//        realmManager.parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
//        var lastSent = Int(self.realmManager.messages.last?.last?.sentAt ?? 0.0).description
//        //GET ALL MESSAGES IN CONVERSTION API
//        if self.realmManager.allMessages?.count == 0 {
//            lastSent = ""
//        }
        self.realmManager.getMsgsThroughConversationId(conversationId: self.conversationID ?? "")
        realmManager.parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
        var lastSent = Int(self.realmManager.messages.last?.last?.sentAt ?? 0.0).description
        //GET ALL MESSAGES IN CONVERSTION API
        if self.realmManager.allMessages?.count == 0 {
            lastSent = ""
        }
        if let groupCastId = groupCastId, !groupCastId.isEmpty{
            viewModel.getBroadCastMessages(groupcastId: groupCastId, lastMessageTimestamp: lastSent ?? "") { msg in
                if let msg = msg {
                    self.viewModel.allMessages = msg.messages
                    self.viewModel.allMessages = self.viewModel.allMessages?.filter { message in
                        return message.action != "clearConversation" && message.action != "deleteConversationLocally" && message.action != "reactionAdd" && message.action != "reactionRemove" && message.action != "messageDetailsUpdated" && message.action != "conversationSettingsUpdated" && message.action != "meetingCreated"
                    }
                    self.realmManager.manageMessagesList(arr: self.viewModel.allMessages ?? [])
                    realmManager.parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
                    self.getMessages()
                    realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
                    realmManager.fetchFiles(conId: self.conversationID ?? "")
                    realmManager.fetchLinks(conId: self.conversationID ?? "")
                }
                //only call read api when there are any new msg in conversation
                if networkMonitor.isConnected{
                    viewModel.markMessagesAsRead(conversationId: self.conversationID ?? "")
                }
                self.sendLocalMsg()
            }
        }
    }
    
    func reload(){
        self.realmManager.getMsgsThroughConversationId(conversationId: self.conversationID ?? "")
        realmManager.parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
        var lastSent = self.realmManager.getlastMessageSentForConversation(conversationId: self.conversationID ?? "")
        //GET ALL MESSAGES IN CONVERSTION API
        if self.realmManager.allMessages?.count == 0 {
            lastSent = ""
        }
        if let conversationID = conversationID , !conversationID.isEmpty{
            viewModel.getMessages(conversationId: conversationID ,lastMessageTimestamp: lastSent) { msg in
                if let msg = msg {
                    self.viewModel.allMessages = msg.messages
                    self.viewModel.allMessages = self.viewModel.allMessages?.filter { message in
                        if isGroup == false {
                            return message.action != "clearConversation" && message.action != "deleteConversationLocally" && message.action != "reactionAdd" && message.action != "reactionRemove" && message.action != "messageDetailsUpdated" && message.action != "conversationSettingsUpdated" && message.action != "meetingCreated"
                        } else {
                            return message.action != "clearConversation" && message.action != "deleteConversationLocally" && message.action != "reactionAdd" && message.action != "reactionRemove" && message.action != "messageDetailsUpdated" && message.action != "conversationSettingsUpdated" && message.action != "meetingCreated"
                        }
                    }
                    self.realmManager.manageMessagesList(arr: self.viewModel.allMessages ?? [])
                    realmManager.parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
                    self.getMessages()
                    realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
                    realmManager.fetchFiles(conId: self.conversationID ?? "")
                    realmManager.fetchLinks(conId: self.conversationID ?? "")
                }
                //only call read api when there are any new msg in conversation
                if networkMonitor.isConnected{
                    viewModel.markMessagesAsRead(conversationId: self.conversationID ?? "")
                }
                self.sendLocalMsg()
            }
        }
    }
    
    //MARK: - SCROLL TO LAST MESSAGE
    
    func scrollTo(messageId: String, anchor: UnitPoint? = nil, shouldAnimate: Bool, scrollReader: ScrollViewProxy) {
        DispatchQueue.main.async {
            ISMChatHelper.print("Scrolling to messageId: \(messageId)")
            realmManager.parentMessageIdToScroll = ""
            withAnimation(Animation.easeOut(duration: 0.2)) {
                scrollReader.scrollTo(messageId, anchor: anchor)
            }
        }
    }
    
    private func executeRepeatedly() {
        viewModel.getConversationDetail(conversationId: self.conversationID ?? "", isGroup: self.isGroup ?? false) { data in
            self.conversationDetail = data
        }
    }
}

