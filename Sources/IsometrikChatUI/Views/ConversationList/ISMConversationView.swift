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
    @EnvironmentObject public var networkMonitor: NetworkMonitor
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
    @State public var userSession = ISMChatSdk.getInstance().getUserSession()
    
//    public var delegate : ChatVCDelegate? = nil
    
//    public var ismChatSDK: ISMChatSdk?
//    public init(ismChatSDK: ISMChatSdk) {
//        self.ismChatSDK = ismChatSDK
//        self.delegate = delegate
//    }
    
    //MARK:  - BODY
    public var body: some View {
        NavigationView {
            ZStack{
                Color(uiColor: .white).edgesIgnoringSafeArea(.all)
                VStack {
                    if realmManager.getConversationCount() == 0 && query == ""{
                        // default placeholder
                        Button {
                            createChat = true
                        } label: {
                            themeImages.conversationListPlaceholder
                                .resizable()
                                .frame(width: 251, height: 163, alignment: .center)
                        }
                    }else{
                        List{
                            ForEach(realmManager.getConversation()){ data in
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
                                        ISMMessageView(conversationViewModel : self.viewModel,conversationID: data.lastMessageDetails?.conversationId,opponenDetail : data.opponentDetails,userId: viewModel.userData?.userIdentifier, isGroup: data.isGroup,fromBroadCastFlow: false,groupCastId: "",groupConversationTitle: data.conversationTitle,groupImage: data.conversationImageUrl)
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
                        .searchable(text: $query)
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
                .navigationBarItems(leading: navigationLeading(),
                                    trailing: navigationTrailing())
                .onChange(of: selectedUserToNavigate, perform: { newValue in
                    navigatetoSelectedUser = true
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
                .background(NavigationLink("", destination:  ISMMessageView(conversationViewModel : self.viewModel,conversationID: selectedUserConversationId,opponenDetail: selectedUserToNavigate,userId: viewModel.userData?.userIdentifier, isGroup: false,fromBroadCastFlow: false,groupCastId: "", groupConversationTitle: nil, groupImage: nil)
                    .environmentObject(realmManager), isActive: $navigatetoSelectedUser))
                .background(NavigationLink("", destination:  ISMBlockUserView(conversationViewModel: self.viewModel), isActive: $navigateToBlockUsers))
                .background(NavigationLink("", destination:  ISMBroadCastList()
                    .environmentObject(realmManager), isActive: $navigateToBroadcastList))
                .background(NavigationLink(
                    "",
                   destination:
                        ISMMessageView(conversationViewModel : self.viewModel,conversationID: conversationIdForNotification ,opponenDetail : opponentDetailforNotification, userId: userSession.getUserId() ?? "", isGroup: isGroupFromNotification,fromBroadCastFlow: false,groupCastId: "", groupConversationTitle: groupTitleFromNotification ?? "", groupImage: groupImageFromNotification ?? "").environmentObject(realmManager).onAppear{onScreen = false},
                   isActive: $navigateToMessageViewFromLocalNotification)
                )
                .background(NavigationLink("", destination:  ISMMessageView(conversationViewModel : self.viewModel,conversationID: "",opponenDetail: nil,userId: viewModel.userData?.userIdentifier, isGroup: false,fromBroadCastFlow: true,groupCastId: self.groupCastIdToNavigate ?? "", groupConversationTitle: nil, groupImage: nil)
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
                //create conversation button
                ISMCreateConversationButtonView(navigate: $createChat,showOfflinePopUp: $showingNoInternetAlert)
            }
        }//:NavigationView
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

