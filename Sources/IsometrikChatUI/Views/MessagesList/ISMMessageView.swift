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

import AVFoundation

import GiphyUISDK
import ISMSwiftCall
import IsometrikChat

public protocol ISMMessageViewDelegate{
    func navigateToAppProfile(userId : String,userType : Int)
    func navigateToPost(postId : String)
    func navigateToProduct(productId : String,productCategoryId : String)
    func navigateToUserListToForward(messages : [MessagesDB])
    func navigateToAppMemberInGroup(conversationId : String,groupMembers : [ISMChatGroupMember]?)
    func uploadOnExternalCDN(messageKind : ISMChatMessageType,mediaUrl : URL,completion:@escaping(String,Int)->())
    func externalBlockMechanism(appUserId : String,block: Bool)
    func navigateToBroadCastInfo(groupcastId : String,groupcastTitle : String,groupcastImage : String)
    func navigateToJobDetail(jobId : String)
}

public struct ISMMessageView: View {
    
    //MARK: - PROPERTIES
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject public var chatViewModel = ChatsViewModel()
    public var conversationViewModel: ConversationViewModel
    @ObservedObject public var stateViewModel = UIStateViewModel()
    
    @EnvironmentObject public var realmManager : RealmManager
    @EnvironmentObject public var networkMonitor: NetworkMonitor
    
    let chatFeatures = ISMChatSdkUI.getInstance().getChatProperties().features
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    let userData = ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig
    
    let columns = [GridItem(.flexible(minimum: 10))]
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    let onlinetimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    @State var OnScreen : Bool = false
    
    
    @State var navigateToMediaSliderId : String = ""
    
    @State var mediaSelectedFromPicker : [ISMMediaUpload] = []
    @State var mediaCaption : String = ""
    
    @State var selectedGIF : GPHMedia? = nil
    
    
    @State var text = ""
    @State var textFieldtxt = ""
    
    @State var conversationID : String?
    public let opponenDetail : UserDB?
    public var myUserId : String?
    public let isGroup : Bool?
    public let fromBroadCastFlow : Bool?
    public let groupCastId : String?

    @State var textViewHeight : CGFloat = 32
    
    
    @State var selectedSheetIndex : Int = 0
    
    
    @State var selectedContactToShare : [ISMChatPhoneContact] = []
   
    
    
    @State var conversationDetail : ISMChatConversationDetail?
    
    
    
    
    @State var previousAudioRef: AudioPlayViewModel?
    
    
   
    @State var deleteMessage : [MessagesDB] = []
    
    
    @State var selectedMsgToReply : MessagesDB = MessagesDB()
    @State var parentMessage : ISMChatMessage = ISMChatMessage()
    
   
    @State var forwardMessageSelected : [MessagesDB] = []
    
    
    
    
    @State var memberString : String?
    
    
    
    //location
    @State var longitude : Double?
    @State var latitude : Double?
    @State var placeId : String?
    @State var placeName : String?
    @State var placeAddress : String?
    
    @State var typingUserName : String?
   
    
    @State var startDate = Date.now
    @State var timeElapsed: Int = 0
   
    
    
    @State var startTimeForOnline = Date.now
    @State var timeElapsedForOnline: Int = 0
    
    
    
    
    
    public let groupConversationTitle : String?
    public let groupImage : String?
    
    @State var navigateToLocationDetail : ISMChatLocationData = ISMChatLocationData()
    
    
    @State var updateMessage : MessagesDB = MessagesDB()
    
    @State var selectedUserToMention : String?
    
    @State var mentionUsers: [ISMChatGroupMember] = []
    @State var filteredUsers: [ISMChatGroupMember] = []
    
    
    //camera click
    @State var cameraImageToUse : URL?
    
    //reaction
    @State var selectedReaction : String? = nil
    @State var sentRecationToMessageId : String = ""
    // call
    
    @State var parentMsgToScroll : MessagesDB? =  nil
    
    
    
    @State var postIdToNavigate : String = ""
    @State var productIdToNavigate = ProductDB()
    
    
    public var delegate : ISMMessageViewDelegate?
    
    @State var navigateToSocialProfileId : String = ""
    @State private var cancellables = Set<AnyCancellable>()
    @State var navigateToJobId : String = ""
    
    //MARK: - BODY
    public var body: some View {
        VStack{
            ZStack{
                appearance.colorPalette.chatListBackground.edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    if ISMChatSdkUI.getInstance().getChatProperties().customJobCardInMessageList == true {
                        if let conversation = self.conversationDetail?.conversationDetails,
                           let metaData = conversation.metaData {
                            JobCardView(jobTitle: metaData.jobTitle ?? "", jobId: metaData.jobId ?? "", startDate: metaData.startDate ?? "", endDate: metaData.endDate ?? "")
                                .onTapGesture {
                                    self.delegate?.navigateToJobDetail(jobId: metaData.jobId ?? "")
                                }
                        }
                    }
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
                            .overlay(stateViewModel.showScrollToBottomView ? scrollToBottomButton() : nil, alignment: Alignment.bottomTrailing)
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
                            }).highPriorityGesture(DragGesture())
                        }.padding(.bottom,5)
                        //No Message View
                        if realmManager.allMessages?.count == 0 || realmManager.messages.count == 0{
                            //
                            if ISMChatSdkUI.getInstance().getChatProperties().showCustomPlaceholder == true{
                                appearance.placeholders.messageListPlaceholder
                            }else{
                                appearance.images.noMessagePlaceholder
                                    .resizable()
                                    .frame(width: 206, height: 144, alignment: .center)
                            }
                            
                        }
                    }.onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    bottomView()
                }//VStack
                .onAppear {
                    OnScreen = true
                    setupOnAppear()
                    stateViewModel.navigateToImageEditor = false
                    addNotificationObservers()
                }
                .onDisappear{
                    OnScreen = false
                    stateViewModel.executeRepeatly = false
                    stateViewModel.executeRepeatlyForOfflineMessage = false
                    stateViewModel.onLoad = false
                    removeObservers()
                }
                //zstack views
                if chatViewModel.isBusy{
                    //Custom Progress View
                    ActivityIndicatorView(isPresented: $chatViewModel.isBusy)
                }
                if stateViewModel.messageCopied == true{
                    Text("Message copied")
                        .font(appearance.fonts.alertText)
                        .padding()
                        .background(appearance.colorPalette.alertBackground)
                        .foregroundColor(appearance.colorPalette.alertText)
                        .cornerRadius(5)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                stateViewModel.messageCopied = false
                            }
                        }
                }
            }
        }//:vStack
        .padding(.top, 5)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(leading: navigationBarLeadingButtons(), trailing: navigationBarTrailingButtons())
        .navigationBarBackButtonHidden(true)
        .confirmationDialog("", isPresented: $stateViewModel.showActionSheet, titleVisibility: .hidden) {
            attachmentActionSheetButtons()
        }
        .confirmationDialog("", isPresented: $stateViewModel.showDeleteActionSheet, titleVisibility: .hidden) {
            deleteActionSheetButtons()
        }
        .confirmationDialog("", isPresented: $stateViewModel.showUnblockPopUp) {
            unblockActionSheetButton()
        } message: {
            Text("Unblock contact to send a message")
        }
        .confirmationDialog("", isPresented: $stateViewModel.uAreBlock) {
        } message: {
            Text("Action not allowed, the user has already blocked You")
        }
        .confirmationDialog("", isPresented: $stateViewModel.clearThisChat) {
            Button("Delete", role: .destructive) {
                clearChat()
            }
        } message: {
            Text("Clear all messages from \(conversationDetail?.conversationDetails?.opponentDetails?.userName ?? "this chat")? \n This chat will be empty but will remain in your chat list.")
        }
        .confirmationDialog("", isPresented: $stateViewModel.blockThisChat) {
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
            if OnScreen && !(self.realmManager.doesMessageExistInMessagesDB(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "")){
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
        .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttTypingEvent.name)){ notification in
            guard let messageInfo = notification.userInfo?["data"] as? ISMChatTypingEvent else {
                return
            }
            ISMChatHelper.print("TYPING EVENT----------------->\(messageInfo)")
            userTyping(messageInfo: messageInfo)
        }
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.refrestMessagesListLocally)) { _ in
            getMessages()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.updateGroupInfo)) { _ in
            self.getConversationDetail()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.memberAddAndRemove)) { _ in
            self.getConversationDetail()
        }
        .onChange(of: chatViewModel.documentSelectedFromPicker, { _, _ in
            sendMessageIfDocumentSelected()
        })
        .onChange(of: selectedReaction, { _, _ in
            if selectedReaction != nil{
                sendReaction()
            }
        })
        .onChange(of: navigateToMediaSliderId, { _, _ in
            if !navigateToMediaSliderId.isEmpty{
                stateViewModel.navigateToMediaSlider = true
            }
        })
        .onChange(of: textFieldtxt, { _, _ in
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
                        stateViewModel.showMentionList = false
                    }
                } else {
                    filteredUsers = mentionUsers
                }
            }
        })
        .onChange(of: navigateToLocationDetail.title, { _, _ in
            stateViewModel.navigateToLocation = true
        })
        .onChange(of: stateViewModel.audioCallToUser, { _, _ in
            if stateViewModel.audioCallToUser == true{
                stateViewModel.showCallPopUp = true
            }
        })
        .onChange(of: stateViewModel.videoCallToUser, { _, _ in
            if stateViewModel.videoCallToUser == true{
                stateViewModel.showCallPopUp = true
            }
        })
        .onChange(of: cameraImageToUse, { _, _ in
            if cameraImageToUse != nil {
                sendMessage(msgType: .photo)
            }
        })
        .onChange(of: chatViewModel.audioUrl, { _, _ in
            sendMessageIfAudioUrl()
        })
        .onChange(of: stateViewModel.keyboardFocused, { _, _ in
            if conversationDetail != nil{
                sendMessageTypingIndicator()
            }
        })
        .onChange(of: selectedGIF, { _, _ in
            sendMessageIfGif()
        })
        .onChange(of: stateViewModel.sendMedia, { _, _ in
            if stateViewModel.sendMedia == true{
                stateViewModel.sendMedia = false
                sendMessageIfUploadMedia()
            }
        })
        .onChange(of: updateMessage.body, { _, _ in
            self.textFieldtxt = updateMessage.body
            stateViewModel.keyboardFocused = true
        })
        .onChange(of: self.placeId, { _, _ in
            sendMessageIfPlaceId()
        })
        .onChange(of: stateViewModel.navigateToAddParticipantsInGroupViaDelegate, { _, _ in
            if stateViewModel.navigateToAddParticipantsInGroupViaDelegate == true{
                delegate?.navigateToAppMemberInGroup(conversationId: self.conversationID ?? "", groupMembers: self.conversationDetail?.conversationDetails?.members)
                stateViewModel.navigateToAddParticipantsInGroupViaDelegate = false
            }
        })
        .onChange(of: chatViewModel.timerValue, { _, _ in
            withAnimation {
                stateViewModel.isShowingRedTimerStart.toggle()
            }
        })
        .onChange(of: navigateToSocialProfileId, { _, _ in
            if !navigateToSocialProfileId.isEmpty {
                delegate?.navigateToAppProfile(userId: navigateToSocialProfileId, userType: 0)
                navigateToSocialProfileId = ""
            }
        })
        .onChange(of: postIdToNavigate, { _, _ in
            if !postIdToNavigate.isEmpty{
                delegate?.navigateToPost(postId: postIdToNavigate)
                postIdToNavigate = ""
            }
        })
        .onChange(of: productIdToNavigate, { _, _ in
            if let productId = productIdToNavigate.productId, !productId.isEmpty{
                delegate?.navigateToProduct(productId: productId, productCategoryId: productIdToNavigate.productCategoryId ?? "")
                productIdToNavigate = ProductDB()
            }
        })
        .onChange(of: stateViewModel.shareContact, { _, _ in
            if !self.selectedContactToShare.isEmpty {
                sendMessage(msgType: .contact)
                stateViewModel.shareContact = false
            }
        })
        .sheet(isPresented: $stateViewModel.showGifPicker, content: {
            ISMGiphyPicker { media in
                if let media = media{
                    selectedGIF = media
                    stateViewModel.showGifPicker = false
                }
            }
        })
        .sheet(isPresented: $stateViewModel.showSheet){
            if selectedSheetIndex == 0 {
                ISMCameraView(media : $cameraImageToUse, isShown: $stateViewModel.showSheet, uploadMedia: $stateViewModel.uploadMedia)
            } else if selectedSheetIndex == 1 {
                DocumentPicker(documents: $chatViewModel.documentSelectedFromPicker, isShown: self.$stateViewModel.showSheet)
            } else{
                ISMShareContactList(dissmiss: $stateViewModel.showSheet , selectedContact: self.$selectedContactToShare, shareContact: $stateViewModel.shareContact)
            }
        }
        .sheet(isPresented: self.$stateViewModel.showVideoPicker) {
            ISMMediaPicker(isPresented: self.$stateViewModel.showVideoPicker, sendMedias: $mediaSelectedFromPicker,opponenetName: isGroup == true ? (self.conversationDetail?.conversationDetails?.conversationTitle ?? "" ) : (self.conversationDetail?.conversationDetails?.opponentDetails?.userName ?? ""),mediaCaption: $mediaCaption,sendMediaToMessage: $stateViewModel.sendMedia)
        }
        .fullScreenCover(isPresented: $stateViewModel.navigateToUserProfile, onDismiss: {
            stateViewModel.navigateToUserProfile = false
        }, content: {
            ISMContactInfoView(conversationID: self.conversationID,conversationDetail : self.conversationDetail, viewModel:self.chatViewModel, isGroup: self.isGroup,navigateToSocialProfileId: $navigateToSocialProfileId).environmentObject(self.realmManager)
                .onAppear {
                    OnScreen = false
                }
        })
        .fullScreenCover(isPresented: $stateViewModel.navigateToMediaSlider) {
            let attachments = self.realmManager.medias ?? []
            let currentMediaId = navigateToMediaSliderId
            //reset value
            let index = attachments.firstIndex { $0.messageId == currentMediaId } ?? 0
            ISMChatMediaViewer(viewModel: ISMChatMediaViewerViewModel(attachments: attachments, index: index)) {
                stateViewModel.navigateToMediaSlider = false
            }.onAppear {
                self.navigateToMediaSliderId = ""
            }
        }
        .navigationDestination(isPresented: $stateViewModel.movetoForwardList, destination: {
            ISMForwardToContactView(viewModel : self.chatViewModel, conversationViewModel : self.conversationViewModel, messages: $forwardMessageSelected, showforwardMultipleMessage: $stateViewModel.showforwardMultipleMessage)
        })
        .fullScreenCover(isPresented: $stateViewModel.navigateToLocation) {
            ISMMapDetailView(data: navigateToLocationDetail)
                .onDisappear {
                    stateViewModel.navigateToLocation = false
                }
        }
        //        .background(NavigationLink("", destination: ISMChatBroadCastInfo(broadcastTitle: (self.groupConversationTitle ?? ""),groupCastId: self.groupCastId ?? "").environmentObject(self.realmManager),isActive: $navigateToGroupCastInfo))
//        .background(NavigationLink("", destination: ISMContactInfoView(conversationID: self.conversationID,conversationDetail : self.conversationDetail, viewModel:self.chatViewModel, isGroup: self.isGroup,navigateToAddParticipantsInGroupViaDelegate: $stateViewModel.navigateToAddParticipantsInGroupViaDelegate,navigateToSocialProfileId: $navigateToSocialProfileId).environmentObject(self.realmManager),isActive: $stateViewModel.navigateToProfile))
        //        .background(NavigationLink("", destination: ISMMapDetailView(data: navigateToLocationDetail),isActive: $navigateToLocation))
        .onReceive(timer, perform: { firedDate in
            print("timer fired")
            timeElapsed = Int(firedDate.timeIntervalSince(startDate))
            if stateViewModel.executeRepeatly == true && fromBroadCastFlow != true{
                self.executeRepeatedly()
            }
        })
        .onReceive(onlinetimer, perform: { firedtime in
            if OnScreen == true{
                print("online timer fired")
                timeElapsedForOnline = Int(firedtime.timeIntervalSince(startTimeForOnline))
                if stateViewModel.executeRepeatlyForOfflineMessage == true{
                    sendLocalMsg()
                }
            }
        })
        .alert("Ooops! It looks like your internet connection is not working at the moment. Please check your network settings and make sure you're connected to a Wi-Fi network or cellular data.", isPresented: $stateViewModel.showingNoInternetAlert) {
            Button("OK", role: .cancel) { }
        }
        .alert("Call \(self.opponenDetail?.userName ?? "")", isPresented: $stateViewModel.showCallPopUp) {
            Button("Cancel", role: .cancel) {
                if stateViewModel.audioCallToUser == true{
                    stateViewModel.audioCallToUser = false
                }
                if stateViewModel.videoCallToUser == true{
                    stateViewModel.videoCallToUser = false
                }
            }
            if stateViewModel.audioCallToUser {
                Button("Voice Call") {
                    stateViewModel.audioCallToUser = false
                    calling(type: .AudioCall)
                }
            }
            if stateViewModel.videoCallToUser {
                Button("Video Call") {
                    stateViewModel.videoCallToUser = false
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
            if chatFeatures.contains(.audio) == true{
                checkAudioPermission()
            }
            realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
            realmManager.fetchFiles(conId: self.conversationID ?? "")
            realmManager.fetchLinks(conId: self.conversationID ?? "")
            
            realmManager.updateUnreadCountThroughConId(conId: self.conversationID ?? "",count: 0,reset:true)
            if !networkMonitor.isConnected {
                stateViewModel.showingNoInternetAlert = true
            }
            //fix to don't show scroll to Bottom button when message count is zero
            if realmManager.allMessages?.count == 0{
                stateViewModel.showScrollToBottomView = false
            }
            stateViewModel.onLoad = true
        }
    }
    
    
    func bottomView() -> some View{
        HStack {
            if !networkMonitor.isConnected {
                toolBarView()
                //in some apps if booking is closed then we can't messsage
            }else if conversationDetail?.conversationDetails?.customType == "CLOSED"{
            }else{
                if isGroup == true {
                    if let members = conversationDetail?.conversationDetails?.members,
                       !members.contains(where: { $0.userId == userData.userId }) {
                        NoLongerMemberToolBar()
                    } else {
                        toolBarView()
                    }
                } else {
                    let chatProperties = ISMChatSdkUI.getInstance().getChatProperties()
                    if chatProperties.otherConversationList && showOptionToAllow() {
                        acceptRejectView()
                    } else {
                        toolBarView()
                    }
                }
            }
        }
    }
    
    
    //MARK: - CONFIGURE
    
    //locally getting messages here
    func getMessages() {
        realmManager.getMsgsThroughConversationId(conversationId: self.conversationID ?? "")
        self.realmManager.messages = chatViewModel.getSectionMessage(for: self.realmManager.allMessages ?? [])
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
            if realmManager.messages.last?.last?.initiatorId != userData.userId{
                stateViewModel.uAreBlock = true
            }else{
                stateViewModel.showUnblockPopUp = true
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
            chatViewModel.getConversationDetail(conversationId: self.conversationID ?? "", isGroup: self.isGroup ?? false) { data in
                self.conversationDetail = data
                if isGroup == true{
                    if let members = data?.conversationDetails?.members {
                        if members.count >= 2{
                            self.memberString = members.prefix(1).map { $0.userName ?? "" }.joined(separator: ", ")
                            if members.count > 2 {
                                self.memberString! += ", and others"
                            }
                        }else{
                            self.memberString = members.map { $0.userName ?? "" }.joined(separator: ", ")
                        }
                        //mentionUser Flow
                        mentionUsers.removeAll()
                        filteredUsers.removeAll()
                        let filteredMembers = members.filter { $0.userId != userData.userId }
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
            chatViewModel.getBroadCastMessages(groupcastId: groupCastId, lastMessageTimestamp: lastSent) { msg in
                if let msg = msg {
                    self.chatViewModel.allMessages = msg.messages
                    self.chatViewModel.allMessages = self.chatViewModel.allMessages?.filter { message in
                        return message.action != "clearConversation" && message.action != "deleteConversationLocally" && message.action != "reactionAdd" && message.action != "reactionRemove" && message.action != "messageDetailsUpdated" && message.action != "conversationSettingsUpdated" && message.action != "meetingCreated"
                    }
                    self.realmManager.manageMessagesList(arr: self.chatViewModel.allMessages ?? [])
                    realmManager.parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
                    self.getMessages()
                    realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
                    realmManager.fetchFiles(conId: self.conversationID ?? "")
                    realmManager.fetchLinks(conId: self.conversationID ?? "")
                }
                //only call read api when there are any new msg in conversation
                if networkMonitor.isConnected{
                    chatViewModel.markMessagesAsRead(conversationId: self.conversationID ?? "")
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
            chatViewModel.getMessages(conversationId: conversationID ,lastMessageTimestamp: lastSent) { msg in
                if let msg = msg {
                    self.chatViewModel.allMessages = msg.messages
                    self.chatViewModel.allMessages = self.chatViewModel.allMessages?.filter { message in
                        if ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == true{
                            return message.action != "clearConversation" && message.action != "deleteConversationLocally" && message.action != "reactionAdd" && message.action != "reactionRemove" && message.action != "messageDetailsUpdated" && message.action != "conversationSettingsUpdated" && message.action != "meetingCreated" && message.action != ISMChatActionType.conversationCreated.value
                        }else if isGroup == false {
                            return message.action != "clearConversation" && message.action != "deleteConversationLocally" && message.action != "reactionAdd" && message.action != "reactionRemove" && message.action != "messageDetailsUpdated" && message.action != "conversationSettingsUpdated" && message.action != "meetingCreated"
                        } else {
                            return message.action != "clearConversation" && message.action != "deleteConversationLocally" && message.action != "reactionAdd" && message.action != "reactionRemove" && message.action != "messageDetailsUpdated" && message.action != "conversationSettingsUpdated" && message.action != "meetingCreated"
                        }
                    }
                    self.realmManager.manageMessagesList(arr: self.chatViewModel.allMessages ?? [])
                    realmManager.parentMessageIdToScroll = self.realmManager.messages.last?.last?.id.description ?? ""
                    self.getMessages()
                    realmManager.fetchPhotosAndVideos(conId: self.conversationID ?? "")
                    realmManager.fetchFiles(conId: self.conversationID ?? "")
                    realmManager.fetchLinks(conId: self.conversationID ?? "")
                }
//                //only call read api when there are any new msg in conversation
//                if networkMonitor.isConnected{
//                    viewModel.markMessagesAsRead(conversationId: self.conversationID ?? "")
//                }
                self.sendLocalMsg()
            }
        }
        //unread count is not getting updated
        if networkMonitor.isConnected{
            chatViewModel.markMessagesAsRead(conversationId: self.conversationID ?? "")
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
        chatViewModel.getConversationDetail(conversationId: self.conversationID ?? "", isGroup: self.isGroup ?? false) { data in
            self.conversationDetail = data
        }
    }
}

extension ISMMessageView{
    private func addNotificationObservers() {
            // List of notification types you want to observe
            let notificationTypes: [Notification.Name] = [
                ISMChatMQTTNotificationType.mqttUserBlockConversation.name,
                ISMChatMQTTNotificationType.mqttUserUnblockConversation.name,
            ]

            // Iterate over each notification type and add a subscriber
            for notificationType in notificationTypes {
                NotificationCenter.default.publisher(for: notificationType)
                    .sink { notification in
                        handleNotification(notification, type: notificationType)
                    }
                    .store(in: &cancellables)
            }
        }

        private func handleNotification(_ notification: Notification, type: Notification.Name) {
            // Handle the notification based on its type
            switch type {
            case ISMChatMQTTNotificationType.mqttUserBlockConversation.name:
                if let messageInfo = notification.userInfo?["data"] as? ISMChatMessageDelivered {
                    ISMChatHelper.print("USER BLOCKED ----------------->\(messageInfo)")
                    messageReceived(messageInfo: messageInfo)
                }
                
            case ISMChatMQTTNotificationType.mqttUserUnblockConversation.name:
                if let messageInfo = notification.userInfo?["data"] as? ISMChatMessageDelivered {
                    ISMChatHelper.print("USER UNBLOCKED ----------------->\(messageInfo)")
                    messageReceived(messageInfo: messageInfo)
                }
            default:
                break
            }
        }

        private func removeObservers() {
            // Cancel all observers
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
        }
}
