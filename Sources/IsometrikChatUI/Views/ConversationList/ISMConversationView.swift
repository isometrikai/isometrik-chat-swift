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
    func navigateToPreviousScreen()
}

public struct ISMConversationView : View {
    
    // MARK: - PROPERTIES
    // State variables to manage navigation and UI states
    @State public var navigateToMessages : Bool = false // Flag to navigate to messages
    @State public var query = "" // Search query for conversations
    @State public var showingNoInternetAlert = false // Alert for no internet connection
    @State private var hasAppeared = false // Track if the view has appeared
    @State public var showProfile : Bool = false // Flag to show user profile
    @State public var createChat : Bool = false // Flag to initiate chat creation
    @State public var navigateToBlockUsers = false // Flag for blocking users
    @State public var navigateToBroadcastList = false // Flag for navigating to broadcast list
    @State public var showOptionView = false // Flag to show options view
    @State public var showDeleteOptions : Bool = false // Flag to show delete options
    @State public var selectedForDelete : ConversationDB? // Selected conversation for deletion
    @State public var selectedUserToNavigate : UserDB = UserDB() // User selected for navigation
    @State public var selectedUserConversationId : String = "" // ID of the selected user's conversation
    @State public var navigatetoSelectedUser : Bool = false // Flag to navigate to selected user
    @ObservedObject public var viewModel = ConversationViewModel() // ViewModel for conversation data
    @StateObject public var realmManager = RealmManager.shared // Realm manager for data persistence
    @StateObject public var networkMonitor = NetworkMonitor() // Monitor for network status
    @ObservedObject public var chatViewModel = ChatsViewModel() // ViewModel for chat data
    @State public var showBroadCastOption = ISMChatSdkUI.getInstance().getChatProperties().conversationType.contains(.BroadCastConversation) // Flag for showing broadcast options
    public let NC = NotificationCenter.default // Notification center for handling notifications
    @State public var onConversationList = false // Flag to track if on conversation list
    
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
    @State var offset = CGSize.zero
    
    public init(delegate : ISMConversationViewDelegate? = nil){
        self.delegate = delegate
    }
    
    
    
    // MARK: - BODY
    public var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                appearance.colorPalette.chatListBackground.edgesIgnoringSafeArea(.all) // Background color
                VStack {
                    // Show placeholder if no conversations are available
                    if shouldShowPlaceholder {
                        Spacer()
                        showPlaceholderView
                        Spacer()
                    } else {
                        // Search bar for filtering conversations
                        if ISMChatSdk.getInstance().getFramework() == .UIKit {
                            CustomSearchBar(searchText:  $query, isDisabled: ISMChatSdkUI.getInstance().getChatProperties().onTapOfSearchBarOpenNewScreen == true)
                                .padding(.horizontal, 15)
                                .onTapGesture {
                                    // Navigate to custom search on tap
                                    if ISMChatSdkUI.getInstance().getChatProperties().onTapOfSearchBarOpenNewScreen == true {
                                        self.delegate?.navigateToCustomSearchOnTapOfSearchBar()
                                    }
                                }
                        }
                        // Show placeholder if no conversation data is available
                        if conversationData.count == 0 {
                            Spacer()
                            showPlaceholderView
                            Spacer()
                        } else {
                            conversationListView // Display the list of conversations
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
                        if ISMChatSdkUI.getInstance().getChatProperties().dontShowCreateButtonTillNoConversation == true && conversationData.count > 0{
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
                        }else if ISMChatSdkUI.getInstance().getChatProperties().dontShowCreateButtonTillNoConversation == false{
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
    
    func detectDirection(value: DragGesture.Value) -> SwipeHVDirection {
        if value.translation.width < -30 {
            return .left
        } else if value.translation.width > 30 {
            return .right
        } else {
            return .none
        }
    }
    
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
        // Determine if the placeholder should be shown based on conversation count and search query
        let isOtherConversationList = ISMChatSdkUI.getInstance().getChatProperties().otherConversationList
        let conversationCount = isOtherConversationList ? realmManager.getPrimaryConversationCount() : realmManager.getConversationCount()
        return conversationCount == 0 && query.isEmpty
    }

    private var showPlaceholderView: some View {
        // View to display when there are no conversations
        Group {
            if ISMChatSdkUI.getInstance().getChatProperties().showCustomPlaceholder {
                appearance.placeholders.chatListPlaceholder
            } else {
                Button {
                    // Action to create a new chat
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
        // View to display the list of conversations
        List {
            ForEach(conversationData) { data in
                VStack(spacing: 0) {
                    // Button to navigate to the selected conversation
                    if ISMChatSdk.getInstance().getFramework() == .UIKit {
                        Button {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            navigateToMessageList(for: data) // Navigate to message list for selected conversation
                        } label: {
                            conversationSubView(for: data) // Display conversation subview
                                .onAppear {
                                    handlePagination(for: data) // Handle pagination for loading more data
                                }
                        }
                    } else {
                        // SwiftUI navigation link for conversation
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
        .gesture(DragGesture().onChanged { value in
            // Handle drag gesture for navigation
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            offset = value.translation
        }.onEnded { value in
            offset = .zero
            ISMChatHelper.print("value ",value.translation.width)
            let direction = self.detectDirection(value: value) // Detect swipe direction
            if direction == .right {
                self.delegate?.navigateToPreviousScreen() // Navigate back on right swipe
            }
        })
        .listStyle(.plain)
        .keyboardType(.default)
        .textContentType(.oneTimeCode)
        .autocorrectionDisabled(true)
        .refreshable {
            viewModel.resetdata() // Reset view model data on refresh
            getConversationList() // Fetch updated conversation list
        }
    }

    // MARK: - Helper Methods

    var conversationData: [ConversationDB] {
        let isOtherConversationList = ISMChatSdkUI.getInstance().getChatProperties().otherConversationList
        return isOtherConversationList ? realmManager.getPrimaryConversation() : realmManager.getConversation()
    }

    private func navigateToMessageList(for data: ConversationDB) {
        // Navigate to the message list for the selected conversation
        delegate?.navigateToMessageList(
            selectedUserToNavigate: data.opponentDetails,
            conversationId: data.lastMessageDetails?.conversationId,
            isGroup: data.isGroup,
            groupImage: data.conversationImageUrl,
            groupName: data.conversationTitle
        )
    }

    private func conversationSubView(for data: ConversationDB) -> some View {
        // Subview for displaying individual conversation details
        HStack{
            if ISMChatSdkUI.getInstance().getChatProperties().useCustomViewRegistered == true{
                CustomConversationListCellViewRegistry.shared.view(for: data)
                    .padding(.horizontal,15).padding(.vertical,10)
            }else{
                ISMConversationSubView(chat: data, hasUnreadCount: data.unreadMessagesCount > 0)
                    .padding(.horizontal,15).padding(.vertical,10)
            }
        }
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
