//
//  ChatsView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 23/01/23.
//

import SwiftUI
import UserNotifications
import Combine
import ISMSwiftCall
import IsometrikChat

public protocol ISMConversationViewDelegate{
    func navigateToMessageList(selectedUserToNavigate : UserDB?,conversationId : String?,isGroup : Bool?,groupImage : String?,groupName : String?)
    func navigateToUsersListToCreateChat(conversationType : ISMChatConversationTypeConfig)
}

public struct ISMConversationView : View {
    
    //MARK:  - PROPERTIES
//    @AppStorage("isDarkMode") public var isDarkMode = false
    
    @State public var navigateToMessages : Bool = false
    
    //search
    @State public var query = ""
    
    //alert
    @State public var showingNoInternetAlert = false
    
    //sheet
    @State public var showProfile : Bool = false
    @State public var createChat : Bool = false
  
    @State public var navigateToBlockUsers = false
    @State public var navigateToBroadcastList = false
    
    //action
    @State public var showOptionView = false
    @State public var showDeleteOptions : Bool = false
    @State public var selectedForDelete : ConversationDB?
    
    //1 to 1 conversation
    @State public var selectedUserToNavigate : UserDB = UserDB()
    @State public var selectedUserConversationId : String = ""
    @State public var navigatetoSelectedUser : Bool = false
    
    @ObservedObject public var viewModel = ConversationViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @StateObject public var realmManager = RealmManager()
    @StateObject public var networkMonitor = NetworkMonitor()
    @ObservedObject public var chatViewModel = ChatsViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @State public var showBroadCastOption = ISMChatSdkUI.getInstance().getChatProperties().conversationType.contains(.BroadCastConversation)
    
    public let NC = NotificationCenter.default
    @State public var onScreen = false
    
    //local notification
    @State public var navigateToMessageViewFromLocalNotification : Bool = false
    @State public var conversationIdForNotification : String?
    @State public var opponentDetailforNotification : UserDB?
    @State public var isGroupFromNotification : Bool = false
    @State public var groupTitleFromNotification : String?
    @State public var groupImageFromNotification : String?
    
    @State public var groupCastIdToNavigate : String = ""
    @State public var navigateToBroadCastMessages : Bool = false
    
    @State public var themeImages = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    @State public var themeText = ISMChatSdkUI.getInstance().getAppAppearance().appearance.text
    @State public var themeFont = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State public var userSession = ISMChatSdk.getInstance().getUserSession()
    @State public var hideNavigationBar = ISMChatSdkUI.getInstance().getChatProperties().hideNavigationBarForConversationList
    
    public var delegate : ISMConversationViewDelegate? = nil
    @State public var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State public var showMenuForConversationType : Bool = false
    @State public var isTextFieldFocused : Bool = false
    
    public init(delegate : ISMConversationViewDelegate? = nil){
        self.delegate = delegate
    }
    
    
    
    //MARK:  - BODY
    public var body: some View {
        NavigationView {
            ZStack{
                themeColor.chatListBackground.edgesIgnoringSafeArea(.all)
                VStack {
                    
//                    if ISMChatSdk.getInstance().getFramework() == .UIKit{
//                        HStack {
//                            themeImages.searchIcon
//                                .resizable()
//                                .frame(width: 15,height: 15)
//                            TextField("Search", text: $query)
//                                .foregroundColor(themeColor.chatListUserName)
//                                .padding(.vertical, 8)
//                                .background(Color.clear)
//                                .onTapGesture {
//                                    isTextFieldFocused = true
//                                }
//                            if !query.isEmpty {
//                                Button(action: {
//                                    query = ""
//                                }) {
//                                    Image(systemName: "xmark.circle.fill")
//                                        .foregroundColor(Color.gray)
//                                }
//                            }
//                        }
//                        .padding(5)
//                        .padding(.horizontal,5)
//                        .background(Color(UIColor.systemGray6))
//                        .cornerRadius(10)
//                        .padding(.horizontal, 15)
//                    }
                    
                    
                    if (ISMChatSdkUI.getInstance().getChatProperties().otherConversationList == true ? realmManager.getPrimaryConversationCount() : realmManager.getConversationCount()) == 0 && query == ""{
                        // default placeholder
                        Button {
                            if ISMChatSdk.getInstance().getFramework() == .SwiftUI{
                                createChat = true
                            }
                        } label: {
                            VStack(spacing:20){
                                themeImages.conversationListPlaceholder
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 169, height: 169, alignment: .center)
                                if !themeText.conversationListPlaceholderText.isEmpty{
                                    Text(themeText.conversationListPlaceholderText)
                                        .font(themeFont.navigationBarTitle)
                                        .font(themeColor.navigationBarTitle)
                                }
                            }
                        }
                    }else{
                        List{
                            ForEach(ISMChatSdkUI.getInstance().getChatProperties().otherConversationList == true ? realmManager.getPrimaryConversation() : realmManager.getConversation()){ data in
                                if ISMChatSdk.getInstance().getFramework() == .UIKit{
                                    Button {
                                        delegate?.navigateToMessageList(selectedUserToNavigate: data.opponentDetails, conversationId: data.lastMessageDetails?.conversationId, isGroup: data.isGroup, groupImage: data.conversationImageUrl,groupName: data.conversationTitle)
                                    } label: {
                                        ISMConversationSubView(chat: data, hasUnreadCount: (data.unreadMessagesCount) > 0)
                                            .onAppear {
                                                // pagination code
                                                if self.shouldLoadMoreData(data) {
                                                    self.loadMoreData()
                                                }
                                            }
                                    }
                                }else{
                                    ZStack{
                                        ISMConversationSubView(chat: data, hasUnreadCount: (data.unreadMessagesCount ) > 0)
                                            .onAppear {
                                                // pagination code
                                                if self.shouldLoadMoreData(data) {
                                                    self.loadMoreData()
                                                }
                                            }
                                        NavigationLink {
                                            //navigation to chat
                                            ISMMessageView(conversationViewModel : self.viewModel,conversationID: data.lastMessageDetails?.conversationId,opponenDetail : data.opponentDetails,myUserId: viewModel.userData?.userId ?? "", isGroup: data.isGroup,fromBroadCastFlow: false,groupCastId: "",groupConversationTitle: data.conversationTitle,groupImage: data.conversationImageUrl)
                                                .environmentObject(realmManager)
                                                .onAppear{
                                                    onScreen = false
                                                    query = ""
                                                }
                                        } label: {
                                            EmptyView()
                                        }.buttonStyle(PlainButtonStyle())
                                            .frame(width :0)
                                            .opacity(0)
                                    }
                                    //:ZStack
                                }
                            }//:FOREACH
                            .onDelete { offsets in   //on slide of item in list give delete option
                                for row in offsets{
                                    print(row)
                                    showDeleteOptions = true
                                    selectedForDelete = realmManager.conversations[row]
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                        .listStyle(.plain)
                        .listRowSeparatorTint(Color.border)
//                        .searchable(text: $query)
                        .keyboardType(.default)
                        .textContentType(.oneTimeCode)
                        .autocorrectionDisabled(true)
                        .refreshable {
                            self.viewModel.resetdata()
                            self.getConversationList()
                        }
                    }
                }//:VStack
                .onChange(of: query, perform: { newValue in
                    if newValue == "" {
                        realmManager.conversations = realmManager.storeConv
                        isTextFieldFocused = false
                    }else {
                        searchInConversationList()
                    }
                })
                .onChange(of: groupCastIdToNavigate, perform: { newValue in
                    if groupCastIdToNavigate != "" || groupCastIdToNavigate != nil {
                        navigateToBroadCastMessages = true
                        createChat = false
                    }
                })
                .sheet(isPresented: $createChat, content: {
                    //create chat flow
                    ISMUsersView(viewModel: self.viewModel, selectedUser: $selectedUserToNavigate, selectedUserconversationId: $selectedUserConversationId,groupCastIdToNavigate: $groupCastIdToNavigate)
                        .environmentObject(realmManager)
                })
                .fullScreenCover(isPresented: $showProfile, content: {
                    // profile of user
                    ISMProfileView(viewModel: viewModel)
                        .environmentObject(realmManager)
                    
                })
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("")
                .navigationBarHidden(hideNavigationBar)
                .navigationBarItems(leading: navigationLeading(),
                                    trailing: navigationTrailing())
                .onChange(of: selectedUserToNavigate, perform: { newValue in
                    if ISMChatSdk.getInstance().getFramework() == .SwiftUI{
                        navigatetoSelectedUser = true
                    }else{
                        self.delegate?.navigateToMessageList(selectedUserToNavigate: selectedUserToNavigate, conversationId: selectedUserConversationId, isGroup: false, groupImage: nil,groupName: nil)
                    }
                })
                .confirmationDialog("", isPresented: $showDeleteOptions) {
                    Button {
                        self.clearConversation(conversationId: self.selectedForDelete?.conversationId ?? "")
                    } label: {
                        Text("Clear Chat")
                    }
                    
                    Button(selectedForDelete?.isGroup == true ? "Exit group" : "Delete Chat", role: .destructive) {
                        if selectedForDelete?.isGroup == true{
                            self.exitGroup(conversationId: self.selectedForDelete?.conversationId ?? "")
                        }else{
                            self.deleteConversation(conversationId: self.selectedForDelete?.conversationId ?? "")
                        }
                    }
                }
                .background(NavigationLink("", destination:  ISMMessageView(conversationViewModel : self.viewModel,conversationID: selectedUserConversationId,opponenDetail: selectedUserToNavigate,myUserId: viewModel.userData?.userId ?? "", isGroup: false,fromBroadCastFlow: false,groupCastId: "", groupConversationTitle: nil, groupImage: nil)
                    .environmentObject(realmManager), isActive: $navigatetoSelectedUser))
                .background(NavigationLink("", destination:  ISMBlockUserView(conversationViewModel: self.viewModel), isActive: $navigateToBlockUsers))
                .background(NavigationLink("", destination:  ISMBroadCastList()
                    .environmentObject(realmManager), isActive: $navigateToBroadcastList))
                .background(NavigationLink(
                    "",
                   destination:
                        ISMMessageView(conversationViewModel : self.viewModel,conversationID: conversationIdForNotification ,opponenDetail : opponentDetailforNotification, myUserId: userSession.getUserId() ?? "", isGroup: isGroupFromNotification,fromBroadCastFlow: false,groupCastId: "", groupConversationTitle: groupTitleFromNotification ?? "", groupImage: groupImageFromNotification ?? "").environmentObject(realmManager).onAppear{onScreen = false},
                   isActive: $navigateToMessageViewFromLocalNotification)
                )
                .background(NavigationLink("", destination:  ISMMessageView(conversationViewModel : self.viewModel,conversationID: "",opponenDetail: nil,myUserId: viewModel.userData?.userId ?? "", isGroup: false,fromBroadCastFlow: true,groupCastId: self.groupCastIdToNavigate ?? "", groupConversationTitle: nil, groupImage: nil)
                    .environmentObject(realmManager).onAppear{onScreen = false}, isActive: $navigateToBroadCastMessages))
                .onAppear {
                    onScreen = true
                    self.viewModel.resetdata()
                    self.viewModel.clearMessages()
                    realmManager.getAllConversations()
                }
                .onDisappear{
                    onScreen = false
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttConversationCreated.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChatCreateConversation else {
                        return
                    }
                    ISMChatHelper.print("CREATE CONVERSATION ----------------->\(messageInfo)")
                    self.viewModel.resetdata()
                    self.getConversationList()
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttUpdateUser.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChatMessageDelivered else {
                        return
                    }
                    ISMChatHelper.print("USER UPDATED ----------------->\(messageInfo)")
                    self.userData { _ in
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttmessageDetailsUpdated.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChatMessageDelivered else {
                        return
                    }
                    ISMChatHelper.print("MESSAGE UPDATED ----------------->\(messageInfo)")
                    realmManager.updateMessageBody(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", body: messageInfo.details?.body ?? "")
                    realmManager.updateLastMessageOnEdit(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", newBody: messageInfo.details?.body ?? "")
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttMessageNewReceived.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChatMessageDelivered else {
                        return
                    }
                    ISMChatHelper.print("MESSAGE New Received----------------->\(messageInfo)")
                    self.msgReceived(messageInfo: messageInfo)
                    self.localNotificationForActions(messageInfo: messageInfo)
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttTypingEvent.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChatTypingEvent else {
                        return
                    }
                    ISMChatHelper.print("TYPING EVENT----------------->\(messageInfo)")
                    if onScreen == true{
                        self.typingStatus(obj: messageInfo)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttMessageDeleteForAll.name)){
                    notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChatMessageDelivered else {
                        return
                    }
                    ISMChatHelper.print("MESSAGE DELETE FOR ALL ----------------->\(messageInfo)")
                    messageDeleteForAll(messageInfo: messageInfo)
                    realmManager.getAllConversations()
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttMessageDelivered.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChatMessageDelivered else {
                        return
                    }
                    ISMChatHelper.print("MESSAGE DELIVERED----------------->\(messageInfo)")
                    self.msgDelivered(messageInfo: messageInfo)
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttUserBlockConversation.name)){
                    notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChatUserBlockAndUnblock else {
                        return
                    }
                    ISMChatHelper.print("USER BLOCKED ----------------->\(messageInfo)")
                    blockUnblockUserEvent(messageInfo: messageInfo)
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttUserUnblockConversation.name)){
                    notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChatUserBlockAndUnblock else {
                        return
                    }
                    ISMChatHelper.print("USER UNBLOCKED ----------------->\(messageInfo)")
                    blockUnblockUserEvent(messageInfo: messageInfo)
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttMultipleMessageRead.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChatMultipleMessageRead else {
                        return
                    }
                    ISMChatHelper.print("MESSAGE READ ALL ----------------->\(messageInfo)")
                    messageRead(messageInfo: messageInfo)
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.refreshConvList)) { _ in
                    self.viewModel.resetdata()
                    self.getConversationList()
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.refrestConversationListLocally)) { _ in
                    self.viewModel.resetdata()
                    self.viewModel.clearMessages()
                    realmManager.getAllConversations()
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.localNotification)) { data in
                    if let conversationId = data.userInfo?["conversationId"] as? String, let messageId = data.userInfo?["messageId"] as? String{
                        handleLocalNotification(conversationId: conversationId)
                        viewModel.deliveredMessageIndicator(conversationId: conversationId, messageId: messageId) { _ in
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttAddReaction.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChatReactions else {
                        return
                    }
                    ISMChatHelper.print("Add Reaction ----------------->\(messageInfo)")
                    addReaction(messageInfo: messageInfo)
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttRemoveReaction.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChatReactions else {
                        return
                    }
                    ISMChatHelper.print("Remove Reaction ----------------->\(messageInfo)")
                    removeReaction(messageInfo: messageInfo)
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttMeetingCreated.name)){ notification in
//                    guard let messageInfo = notification.userInfo?["data"] as? ISMCall_Meeting else {
//                        return
//                    }
//                    ISMChatHelper.print("Meeting craeted----------------->\(messageInfo)")
//                    if onScreen == true{
//                        self.viewModel.resetdata()
//                        self.getConversationList()
//                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttMeetingEnded.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMMeeting else {
                        return
                    }
                    ISMChatHelper.print("Meeting ended----------------->\(messageInfo)")
                    if onScreen == true{
                        self.viewModel.resetdata()
                        self.getConversationList()
                    }
                }
                
                if ISMChatSdkUI.getInstance().getChatProperties().createConversationFromChatList == true{
                    //create conversation button
                    if ISMChatSdk.getInstance().getFramework() == .UIKit{
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    showMenuForConversationType.toggle()
                                }, label: {
                                    themeImages.addConversation
                                        .resizable()
                                        .frame(width: 58, height: 58)
                                })
                                .padding()
                            }
                        }
                    }else{
                        ISMCreateConversationButtonView(navigate: $createChat,showOfflinePopUp: $showingNoInternetAlert)
                    }
                }
            }
        }//:NavigationView
        .confirmationDialog("", isPresented: $showMenuForConversationType, titleVisibility: .hidden) {
            VStack {
                ForEach(ISMChatSdkUI.getInstance().getChatProperties().conversationType, id: \.self) { option in
                    Button(option.name) {
                        self.delegate?.navigateToUsersListToCreateChat(conversationType: option)
                    }
                }
                Button("Cancel", role: .cancel) {
                    // Handle cancel action if needed
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("Ooops! It looks like your internet connection is not working at the moment. Please check your network settings and make sure you're connected to a Wi-Fi network or cellular data.", isPresented: $showingNoInternetAlert) {
            Button("OK", role: .cancel) { }
        }
        .onLoad{
            realmManager.hardDeleteAll()
            self.viewModel.userData = UserDefaults.standard.retrieveCodable(for: "userInfo")
            self.getConversationList()
            self.realmManager.hardDeleteMsgs()
            if !networkMonitor.isConnected {
                showingNoInternetAlert = true
            }
            userData { userId in
                self.chatViewModel.getAllMessagesWhichWereSendToMeWhenOfflineMarkThemAsDelivered(myUserId: userId ?? "")
            }
        }
    }//:Body
}
