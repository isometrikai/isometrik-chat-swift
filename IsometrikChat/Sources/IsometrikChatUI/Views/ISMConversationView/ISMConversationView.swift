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


struct ISMConversationView : View {
    
    //MARK:  - PROPERTIES
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @State var navigateToMessages : Bool = false
    
    //search
    @State var query = ""
    
    //alert
    @State var showingNoInternetAlert = false
    
    //sheet
    @State var showProfile : Bool = false
    @State var createChat : Bool = false
  
    @State var navigateToBlockUsers = false
    @State var navigateToBroadcastList = false
    
    //action
    @State var showOptionView = false
    @State var showDeleteOptions : Bool = false
    @State var selectedForDelete : ConversationDB?
    
    //1 to 1 conversation
    @State var selectedUserToNavigate : UserDB = UserDB()
    @State var selectedUserConversationId : String = ""
    @State var navigatetoSelectedUser : Bool = false
    
    @ObservedObject var viewModel = ConversationViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @StateObject var realmManager = RealmManager()
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @ObservedObject var chatViewModel = ChatsViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @State var showBroadCastOption = ISMChatSdk.getInstance().getChatClient().getChatPageProperties().conversationType.contains(.BroadCastConversation)
    
    let NC = NotificationCenter.default
    @State var onScreen = false
    
    //local notification
    @State var navigateToMessageViewFromLocalNotification : Bool = false
    @State var conversationIdForNotification : String?
    @State var opponentDetailforNotification : UserDB?
    @State var isGroupFromNotification : Bool = false
    @State var groupTitleFromNotification : String?
    @State var groupImageFromNotification : String?
    
    @State var groupCastIdToNavigate : String = ""
    @State var navigateToBroadCastMessages : Bool = false
    
    @State var themeImages = ISMChatSdk.getInstance().getAppAppearance().appearance.images
    @State var userSession = ISMChatSdk.getInstance().getUserSession()
    
    var delegate : ChatVCDelegate? = nil
    
    var ismChatSDK: ISMChatSdk?
    init(ismChatSDK: ISMChatSdk,delegate : ChatVCDelegate? = nil) {
        self.ismChatSDK = ismChatSDK
        self.delegate = delegate
    }
    
    //MARK:  - BODY
    var body: some View {
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
                    ISMProfileView(viewModel: viewModel,ismChatSDK : self.ismChatSDK)
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
                .onReceive(NotificationCenter.default.publisher(for: ISMChat_MQTTNotificationType.mqttConversationCreated.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChat_CreateConversation else {
                        return
                    }
                    ISMChat_Helper.print("CREATE CONVERSATION ----------------->\(messageInfo)")
                    self.viewModel.resetdata()
                    self.getConversationList()
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChat_MQTTNotificationType.mqttUpdateUser.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChat_MessageDelivered else {
                        return
                    }
                    ISMChat_Helper.print("USER UPDATED ----------------->\(messageInfo)")
                    self.userData { _ in
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChat_MQTTNotificationType.mqttmessageDetailsUpdated.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChat_MessageDelivered else {
                        return
                    }
                    ISMChat_Helper.print("MESSAGE UPDATED ----------------->\(messageInfo)")
                    realmManager.updateMessageBody(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", body: messageInfo.details?.body ?? "")
                    realmManager.updateLastMessageOnEdit(conversationId: messageInfo.conversationId ?? "", messageId: messageInfo.messageId ?? "", newBody: messageInfo.details?.body ?? "")
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChat_MQTTNotificationType.mqttMessageNewReceived.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChat_MessageDelivered else {
                        return
                    }
                    ISMChat_Helper.print("MESSAGE New Received----------------->\(messageInfo)")
                    self.msgReceived(messageInfo: messageInfo)
                    self.localNotificationForActions(messageInfo: messageInfo)
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChat_MQTTNotificationType.mqttTypingEvent.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChat_TypingEvent else {
                        return
                    }
                    ISMChat_Helper.print("TYPING EVENT----------------->\(messageInfo)")
                    if onScreen == true{
                        self.typingStatus(obj: messageInfo)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChat_MQTTNotificationType.mqttMessageDeleteForAll.name)){
                    notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChat_MessageDelivered else {
                        return
                    }
                    ISMChat_Helper.print("MESSAGE DELETE FOR ALL ----------------->\(messageInfo)")
                    messageDeleteForAll(messageInfo: messageInfo)
                    realmManager.getAllConversations()
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChat_MQTTNotificationType.mqttMessageDelivered.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChat_MessageDelivered else {
                        return
                    }
                    ISMChat_Helper.print("MESSAGE DELIVERED----------------->\(messageInfo)")
                    self.msgDelivered(messageInfo: messageInfo)
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChat_MQTTNotificationType.mqttUserBlockConversation.name)){
                    notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChat_UserBlockAndUnblock else {
                        return
                    }
                    ISMChat_Helper.print("USER BLOCKED ----------------->\(messageInfo)")
                    blockUnblockUserEvent(messageInfo: messageInfo)
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChat_MQTTNotificationType.mqttUserUnblockConversation.name)){
                    notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChat_UserBlockAndUnblock else {
                        return
                    }
                    ISMChat_Helper.print("USER UNBLOCKED ----------------->\(messageInfo)")
                    blockUnblockUserEvent(messageInfo: messageInfo)
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChat_MQTTNotificationType.mqttMultipleMessageRead.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChat_MultipleMessageRead else {
                        return
                    }
                    ISMChat_Helper.print("MESSAGE READ ALL ----------------->\(messageInfo)")
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
                .onReceive(NotificationCenter.default.publisher(for: ISMChat_MQTTNotificationType.mqttAddReaction.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChat_Reactions else {
                        return
                    }
                    ISMChat_Helper.print("Add Reaction ----------------->\(messageInfo)")
                    addReaction(messageInfo: messageInfo)
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChat_MQTTNotificationType.mqttRemoveReaction.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMChat_Reactions else {
                        return
                    }
                    ISMChat_Helper.print("Remove Reaction ----------------->\(messageInfo)")
                    removeReaction(messageInfo: messageInfo)
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChat_MQTTNotificationType.mqttMeetingCreated.name)){ notification in
//                    guard let messageInfo = notification.userInfo?["data"] as? ISMCall_Meeting else {
//                        return
//                    }
//                    ISMChat_Helper.print("Meeting craeted----------------->\(messageInfo)")
//                    if onScreen == true{
//                        self.viewModel.resetdata()
//                        self.getConversationList()
//                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: ISMChat_MQTTNotificationType.mqttMeetingEnded.name)){ notification in
                    guard let messageInfo = notification.userInfo?["data"] as? ISMMeeting else {
                        return
                    }
                    ISMChat_Helper.print("Meeting ended----------------->\(messageInfo)")
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

