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
    func navigateToCustomSearchOnTapOfSearchBar()
}

public struct ISMConversationView : View {
    
    //MARK:  - PROPERTIES
    @State public var navigateToMessages : Bool = false
    //search
    @State public var query = ""
    
    //alert
    @State public var showingNoInternetAlert = false
    
    @State private var hasAppeared = false
    
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
    
    @ObservedObject public var viewModel = ConversationViewModel()
    @StateObject public var realmManager = RealmManager.shared
    @StateObject public var networkMonitor = NetworkMonitor()
    @ObservedObject public var chatViewModel = ChatsViewModel()
    @State public var showBroadCastOption = ISMChatSdkUI.getInstance().getChatProperties().conversationType.contains(.BroadCastConversation)
    
    public let NC = NotificationCenter.default
    @State public var onConversationList = false
    
    //local notification
    @State public var navigateToMessageViewFromLocalNotification : Bool = false
    @State public var conversationIdForNotification : String?
    @State public var opponentDetailforNotification : UserDB?
    @State public var isGroupFromNotification : Bool = false
    @State public var groupTitleFromNotification : String?
    @State public var groupImageFromNotification : String?
    
    @State public var groupCastIdToNavigate : String = ""
    @State public var navigateToBroadCastMessages : Bool = false
    
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    var myUserData = ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig
     var hideNavigationBar = ISMChatSdkUI.getInstance().getChatProperties().hideNavigationBarForConversationList
    
    public var delegate : ISMConversationViewDelegate? = nil
    @State public var showMenuForConversationType : Bool = false
    @State public var isTextFieldFocused : Bool = false
    
    @State var path = NavigationPath()
    
    public init(delegate : ISMConversationViewDelegate? = nil){
        self.delegate = delegate
    }
    
    
    
    //MARK:  - BODY
    public var body: some View {
        NavigationStack(path: $path) {
            ZStack{
                appearance.colorPalette.chatListBackground.edgesIgnoringSafeArea(.all)
                VStack {
                    if shouldShowPlaceholder {
                        Spacer()
                        showPlaceholderView
                        Spacer()
                    } else {
                        if ISMChatSdk.getInstance().getFramework() == .UIKit{
                            CustomSearchBar(searchText:  $query, isDisabled: ISMChatSdkUI.getInstance().getChatProperties().onTapOfSearchBarOpenNewScreen == true).padding(.horizontal,15)
                                .onTapGesture {
                                    if ISMChatSdkUI.getInstance().getChatProperties().onTapOfSearchBarOpenNewScreen == true{
                                        self.delegate?.navigateToCustomSearchOnTapOfSearchBar()
                                    }
                                }
                        }
                        if conversationData.count == 0{
                            Spacer()
                            showPlaceholderView
                            Spacer()
                        }else{
                            conversationListView
                        }
                    }
                }
                .onChange(of: query, {_ , newValue in
                    if newValue == "" {
                        realmManager.conversations = realmManager.storeConv
                        isTextFieldFocused = false
                    }else {
                        searchInConversationList()
                    }
                })
                .onChange(of: groupCastIdToNavigate, { _, _ in
                    if groupCastIdToNavigate != "" {
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
                .onChange(of: selectedUserToNavigate, { _, _ in
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
                .navigationDestination(isPresented: $navigatetoSelectedUser) {
                    ISMMessageView(conversationViewModel : self.viewModel,conversationID: selectedUserConversationId,opponenDetail: selectedUserToNavigate,myUserId: viewModel.userData?.userId ?? "", isGroup: false,fromBroadCastFlow: false,groupCastId: "", groupConversationTitle: nil, groupImage: nil)
                        .environmentObject(realmManager)
                }
                .navigationDestination(isPresented: $navigateToMessageViewFromLocalNotification) {
                    ISMMessageView(conversationViewModel : self.viewModel,conversationID: conversationIdForNotification ,opponenDetail : opponentDetailforNotification, myUserId: myUserData?.userId, isGroup: isGroupFromNotification,fromBroadCastFlow: false,groupCastId: "", groupConversationTitle: groupTitleFromNotification ?? "", groupImage: groupImageFromNotification ?? "").environmentObject(realmManager).onAppear{onConversationList = false}
                }
                .navigationDestination(isPresented: $navigateToBroadCastMessages) {
                    ISMMessageView(conversationViewModel : self.viewModel,conversationID: "",opponenDetail: nil,myUserId: viewModel.userData?.userId ?? "", isGroup: false,fromBroadCastFlow: true,groupCastId: self.groupCastIdToNavigate, groupConversationTitle: nil, groupImage: nil).environmentObject(realmManager).onAppear{onConversationList = false}
                }
                .onAppear {
                    onConversationList = true
                    self.viewModel.resetdata()
                    self.viewModel.clearMessages()
                    realmManager.getAllConversations()
                }
                .onDisappear {
                    onConversationList = false
                    NotificationCenter.default.removeObserver(self, name: ISMChatMQTTNotificationType.mqttConversationCreated.name, object: nil)
                    NotificationCenter.default.removeObserver(self, name: ISMChatMQTTNotificationType.mqttUpdateUser.name, object: nil)
                    NotificationCenter.default.removeObserver(self, name: ISMChatMQTTNotificationType.mqttmessageDetailsUpdated.name, object: nil)
                    NotificationCenter.default.removeObserver(self, name: ISMChatMQTTNotificationType.mqttMessageNewReceived.name, object: nil)
                    NotificationCenter.default.removeObserver(self, name: ISMChatMQTTNotificationType.mqttTypingEvent.name, object: nil)
                    NotificationCenter.default.removeObserver(self, name: ISMChatMQTTNotificationType.mqttMessageDeleteForAll.name, object: nil)
                    NotificationCenter.default.removeObserver(self, name: ISMChatMQTTNotificationType.mqttUserBlockConversation.name, object: nil)
                    NotificationCenter.default.removeObserver(self, name: ISMChatMQTTNotificationType.mqttUserUnblockConversation.name, object: nil)
                    NotificationCenter.default.removeObserver(self, name: NSNotification.refreshConvList, object: nil)
                    NotificationCenter.default.removeObserver(self, name: NSNotification.refrestConversationListLocally, object: nil)
                    NotificationCenter.default.removeObserver(self, name: NSNotification.localNotification, object: nil)
                    NotificationCenter.default.removeObserver(self, name: ISMChatMQTTNotificationType.mqttAddReaction.name, object: nil)
                    NotificationCenter.default.removeObserver(self, name: ISMChatMQTTNotificationType.mqttRemoveReaction.name, object: nil)
                    NotificationCenter.default.removeObserver(self, name: ISMChatMQTTNotificationType.mqttMeetingEnded.name, object: nil)
                    NotificationCenter.default.removeObserver(self)
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
                    if ISMChatSdk.sharedInstance.getFramework() == .SwiftUI{
                        self.getuserData { _ in
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttmessageDetailsUpdated.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChatMessageDelivered else {
                        return
                    }
                    ISMChatHelper.print("MESSAGE UPDATED ----------------->\(messageInfo)")
                    realmManager.updateMessageBody(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", body: messageInfo.details?.body ?? "", metaData: messageInfo.details?.metaData ?? ISMChatMetaData(), customType: messageInfo.details?.customType ?? "")
                    if let url = messageInfo.details?.metaData?.url{
                        realmManager.updateLastMessageOnEdit(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", newBody: url,metaData: messageInfo.details?.metaData ?? ISMChatMetaData())
                    }else{
                        realmManager.updateLastMessageOnEdit(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", newBody: messageInfo.details?.body ?? "",metaData: messageInfo.details?.metaData ?? ISMChatMetaData())
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttMessageNewReceived.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChatMessageDelivered else {
                        return
                    }
                    ISMChatHelper.print("MESSAGE RECEIVED IN CONVERSATION LIST----------------->\(messageInfo)")
                    self.msgReceived(messageInfo: messageInfo)
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttTypingEvent.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChatTypingEvent else {
                        return
                    }
                    ISMChatHelper.print("TYPING EVENT----------------->\(messageInfo)")
                    if onConversationList == true && myUserData?.userId != messageInfo.userId{
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
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttClearConversation.name)){
                    notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChatMessageDelivered else {
                        return
                    }
                    ISMChatHelper.print("clear conversation ----------------->\(messageInfo)")
                    self.viewModel.resetdata()
                    self.getConversationList()
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.mqttUpdateReadStatus)) { data in
                    self.viewModel.resetdata()
                    self.viewModel.clearMessages()
                    realmManager.getAllConversations()
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.mqttUnreadCountReset)) { data in
                    if let conversationId = data.userInfo?["conversationId"] as? String{
                        realmManager.updateUnreadCountThroughConId(conId: conversationId,count: 0,reset:true)
                        self.viewModel.resetdata()
                        self.viewModel.clearMessages()
                        realmManager.getAllConversations()
                    }
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
                        chatViewModel.deliveredMessageIndicator(conversationId: conversationId, messageId: messageId) { _ in
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
                .onReceive(NotificationCenter.default.publisher(for: ISMChatMQTTNotificationType.mqttMeetingEnded.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMMeeting else {
                        return
                    }
                    ISMChatHelper.print("Meeting ended----------------->\(messageInfo)")
                    if onConversationList == true{
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
                                    appearance.images.addConversation
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
            if !hasAppeared {
                hasAppeared = true
                onload()
                onConversationList = true
            }
        }
    }//:Body
    
    
    // MARK: - Helper Computed Properties
    
//    private mutating func handleNewMessage(_ messageInfo: ISMChatMessageDelivered) {
//            let now = Date()
//            guard now.timeIntervalSince(lastProcessingTime) >= processingInterval else { return }
//            lastProcessingTime = now
//            
//            autoreleasepool {
//                // Handle realm updates
//                self.realmManager.newMessageReceived(myuserId: self.myUserData.userId, messageInfo: messageInfo) {
//                    
//                    self.getConversationList()
//                    
//                }
//                
//                // Update conversation list
////                self.updateConversationObj(
////                    conversations: self.getSortedFilteredChats(
////                        conversation: self.conversations,
////                        query: self.query
////                    )
////                )
//                
//                self.viewModel.updateConversationObj(conversations: viewModel.getSortedFilteredChats(conversation: viewModel.conversations, query: query))
//                
//                // Handle message delivery status
//                if let converId = messageInfo.conversationId,
//                   let messId = messageInfo.messageId {
//                    DispatchQueue.global(qos: .utility).async {
//                        self.chatViewModel.deliveredMessageIndicator(
//                            conversationId: converId,
//                            messageId: messId
//                        ) { _ in }
//                    }
//                }
//                
//                // Handle notifications
//                if onScreen && myUserData.allowNotification {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        ISMChatLocalNotificationManager.setNotification(
//                            1,
//                            of: .seconds,
//                            repeats: false,
//                            title: messageInfo.senderName ?? "",
//                            body: messageInfo.notificationBody ?? (messageInfo.body ?? ""),
//                            userInfo: [
//                                "senderId": messageInfo.senderId ?? "",
//                                "senderName": messageInfo.senderName ?? "",
//                                "conversationId": messageInfo.conversationId ?? "",
//                                "body": messageInfo.notificationBody ?? "",
//                                "userIdentifier": messageInfo.senderIdentifier ?? "",
//                                "messageId": messageInfo.messageId ?? ""
//                            ]
//                        )
//                    }
//                }
//                
//                self.localNotificationForActions(messageInfo: messageInfo)
//            }
//        }
    
    func onload(){
        self.viewModel.resetdata()
        self.viewModel.clearMessages()
        realmManager.getAllConversations()
        
        realmManager.hardDeleteAll()
//            self.viewModel.userData = UserDefaults.standard.retrieveCodable(for: "userInfo")
        self.getConversationList()
        self.realmManager.hardDeleteMsgs()
        if !networkMonitor.isConnected {
            showingNoInternetAlert = true
        }
        getuserData{ userId in
            //self.chatViewModel.getAllMessagesWhichWereSendToMeWhenOfflineMarkThemAsDelivered(myUserId: userId ?? "")
        }
    }

    private var shouldShowPlaceholder: Bool {
        let isOtherConversationList = ISMChatSdkUI.getInstance().getChatProperties().otherConversationList
        let conversationCount = isOtherConversationList ? realmManager.getPrimaryConversationCount() : realmManager.getConversationCount()
        return conversationCount == 0 && query.isEmpty
    }

    private var showPlaceholderView: some View {
        Group {
            if ISMChatSdkUI.getInstance().getChatProperties().showCustomPlaceholder {
                appearance.placeholders.chatListPlaceholder
            } else {
                Button {
                    if ISMChatSdk.getInstance().getFramework() == .SwiftUI {
                        createChat = true
                    }
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                } label: {
                    appearance.images.conversationListPlaceholder
                        .resizable()
                        .frame(width: 251, height: 163)
                }
            }
        }
    }

    private var conversationListView: some View {
        List {
            ForEach(conversationData) { data in
                VStack(spacing: 0) {
                    if ISMChatSdk.getInstance().getFramework() == .UIKit {
                        Button {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            navigateToMessageList(for: data)
                        } label: {
                            conversationSubView(for: data)
                                .onAppear {
                                    handlePagination(for: data)
                                }
                        }
                    } else {
                        ZStack {
                            conversationSubView(for: data)
                                .onAppear {
                                    handlePagination(for: data)
                                }
                            NavigationLink(destination: messageView(for: data)) {
                                EmptyView()
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 0)
                            .opacity(0)
                        }
                    }
                    
                    
                    Rectangle()
                        .fill(appearance.colorPalette.chatListSeparatorColor)
                        .frame(height: 1)
                        .padding(.horizontal, ISMChatSdkUI.getInstance().getChatProperties().chatListSeperatorShouldMeetEnds ? 0 : 15)
                    
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
//            .onDelete(perform: handleDelete)
            .listRowBackground(Color.clear)
        }
        .gesture(
            DragGesture().onChanged { _ in
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        )
        .listStyle(.plain)
        .keyboardType(.default)
        .textContentType(.oneTimeCode)
        .autocorrectionDisabled(true)
        .refreshable {
            viewModel.resetdata()
            getConversationList()
        }
    }

    // MARK: - Helper Methods

    var conversationData: [ConversationDB] {
        let isOtherConversationList = ISMChatSdkUI.getInstance().getChatProperties().otherConversationList
        return isOtherConversationList ? realmManager.getPrimaryConversation() : realmManager.getConversation()
    }

    private func navigateToMessageList(for data: ConversationDB) {
        delegate?.navigateToMessageList(
            selectedUserToNavigate: data.opponentDetails,
            conversationId: data.lastMessageDetails?.conversationId,
            isGroup: data.isGroup,
            groupImage: data.conversationImageUrl,
            groupName: data.conversationTitle
        )
    }

    private func conversationSubView(for data: ConversationDB) -> some View {
        ISMConversationSubView(chat: data, hasUnreadCount: data.unreadMessagesCount > 0)
            .padding(.horizontal,15).padding(.vertical,10)
    }

    private func handlePagination(for data: ConversationDB) {
        if shouldLoadMoreData(data) {
            loadMoreData()
        }
    }

    private func handleDelete(offsets: IndexSet) {
        for row in offsets {
            showDeleteOptions = true
            selectedForDelete = realmManager.conversations[row]
        }
    }

    private func messageView(for data: ConversationDB) -> some View {
        ISMMessageView(
            conversationViewModel: viewModel,
            conversationID: data.lastMessageDetails?.conversationId,
            opponenDetail: data.opponentDetails,
            myUserId: viewModel.userData?.userId ?? "",
            isGroup: data.isGroup,
            fromBroadCastFlow: false,
            groupCastId: "",
            groupConversationTitle: data.conversationTitle,
            groupImage: data.conversationImageUrl
        )
        .environmentObject(realmManager)
        .onAppear {
            onConversationList = false
            query = ""
        }
    }
}


//actor MessageQueue {
//    private var queue: [ISMChatMessageDelivered] = []
//    private var isProcessing = false
//    private var lastProcessedMessageId: String?
//    private var lastProcessingTime: Date = .distantPast
//    private let processingInterval: TimeInterval = 0.5
//    
//    func enqueue(_ message: ISMChatMessageDelivered, handler: @escaping (ISMChatMessageDelivered) -> Void) async {
//        // Check for duplicate messages
//        guard message.messageId != lastProcessedMessageId else { return }
//        lastProcessedMessageId = message.messageId
//        
//        // Check processing interval
//        let now = Date()
//        guard now.timeIntervalSince(lastProcessingTime) >= processingInterval else { return }
//        lastProcessingTime = now
//        
//        queue.append(message)
//        if !isProcessing {
//            await processQueue(handler: handler)
//        }
//    }
//    
//    private func processQueue(handler: @escaping (ISMChatMessageDelivered) -> Void) async {
//        guard !isProcessing else { return }
//        isProcessing = true
//        
//        while !queue.isEmpty {
//            let messagesToProcess = Array(queue.prefix(10))
//            queue.removeFirst(min(10, queue.count))
//            
//            await MainActor.run {
//                messagesToProcess.forEach { message in
//                    handler(message)
//                }
//            }
//            
//            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms delay
//        }
//        
//        isProcessing = false
//    }
//}
