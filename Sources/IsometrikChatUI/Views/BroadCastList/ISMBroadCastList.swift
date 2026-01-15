//
//  ISMBroadCastList.swift
//  ISMChatSdk
//
//  Created by Rasika on 03/06/24.
//

import SwiftUI
import IsometrikChat

/// Protocol for handling broadcast list navigation events
public protocol ISMBroadCastListDelegate {
    /// Navigate to broadcast list messages
    /// - Parameters:
    ///   - groupcastId: Unique identifier of the broadcast
    ///   - groupCastTitle: Title of the broadcast
    ///   - groupcastImage: Image URL of the broadcast
    func navigateToBroadCastList(groupcastId: String, groupCastTitle: String, groupcastImage: String)
    
    /// Navigate to broadcast information screen
    /// - Parameters:
    ///   - groupcastId: Unique identifier of the broadcast
    ///   - groupcastTitle: Title of the broadcast 
    ///   - groupcastImage: Image URL of the broadcast
    func navigateToBroadCastInfo(groupcastId: String, groupcastTitle: String, groupcastImage: String)
}

/// View for displaying list of broadcast messages
public struct ISMBroadCastList: View {
    
    //MARK:  - PROPERTIES
    @Environment(\.dismiss) public var dismiss
    
    @ObservedObject public var viewModel = ChatsViewModel()
    @ObservedObject public var conversationviewModel = ConversationViewModel()
//    @EnvironmentObject public var realmManager : RealmManager
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @State public var navigateToBrocastDetail : ISMChatBroadCastDetail?
    @State public var navigateToBrocastInfo : Bool = false
    @State public var navigatetoCreatBroadCast : Bool = false
    @State public var navigatetoCreatGroup : Bool = false
    @State public var editBroadCastList : Bool = false
    
    @State public var navigateToGroupCastId : String = ""
    @State public var navigateToGroupCastTitle : String = ""
    
    @State public var navigateToMessageView : Bool = false
    @State public var groupCastIdToNavigate : String = ""
    @StateObject public var networkMonitor = NetworkMonitor()
    public var delegate : ISMBroadCastListDelegate? = nil
    @State public var query = ""
    @State var allBroadCasts : [ISMChatBroadCastDetail]? = []
    @State var storeBroadCasts : [ISMChatBroadCastDetail]? = []
    @StateObject public var realmManager = RealmManager.shared
    public init(delegate : ISMBroadCastListDelegate? = nil){
        self.delegate = delegate
    }
    
    //MARK:  - LIFECYCLE
    public var body: some View {
        ZStack {
            Color(uiColor: .white)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                if allBroadCasts?.count != 0 {
                    if ISMChatSdk.getInstance().getFramework() == .UIKit{
                        CustomSearchBar(searchText: $query, isDisabled: false).padding(.horizontal,15)
                    }
                    BroadcastListView()
                } 
                else {
                    EmptyStateView()
                }
            }
            .onAppear {
                realmManager.getAllLocalBroadCasts()
                navigateToBrocastInfo = false
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.refreshBroadCastListNotification)) { _ in
                getBroadcastList()
            }
            .refreshable {
                getBroadcastList()
            }
            .background(NavigationLinksView())
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Broadcast lists")
                        .font(appearance.fonts.navigationBarTitle)
                        .foregroundColor(appearance.colorPalette.navigationBarTitle)
                }
                ToolbarItem(placement: .topBarLeading) {
                    navBarLeadingBtn
                }
                if let list = allBroadCasts, list.count > 0{
                    ToolbarItem(placement: .topBarTrailing) {
                        navBarTrailingBtn
                    }
                }
            }
            .onChange(of: query, { _, newValue in
                if newValue.isEmpty {
                    allBroadCasts = storeBroadCasts
                } else {
                    searchInBroadCastList()
                }
            })
        }
        .onLoad {
            getBroadcastList()
        }
    }
    
    /// Fetches the list of broadcasts from the server
    func getBroadcastList(){
        self.viewModel.getBroadCastList { data in
            if let groupcast = data?.groupcasts{
                allBroadCasts = groupcast
            }
        }
    }
    
    /// Filters broadcast list based on search query
    /// Matches broadcast titles containing the search text
    func searchInBroadCastList(){
            let  conversation = storeBroadCasts
            allBroadCasts = conversation?.filter { conversation in
                let x = conversation.groupcastTitle?.contains(query) ?? false
                return x
            }
        }
    //MARK: - CONFIGURE
    
    
    /// Creates the main broadcast list view
    private func BroadcastListView() -> some View {
        List(allBroadCasts ?? []) { broadcast in
            BroadcastRowView(broadcast: broadcast)
        }
        .listStyle(.plain)
        .listRowSeparatorTint(Color.border)
        .keyboardType(.default)
        .textContentType(.oneTimeCode)
        .autocorrectionDisabled(true)
        .refreshable {
            // Refresh logic here if needed
        }
    }
    
    
    /// Creates a row view for a single broadcast
    /// - Parameter broadcast: Broadcast details to display
    private func BroadcastRowView(broadcast: ISMChatBroadCastDetail) -> some View {
        ZStack {
            HStack(spacing: 15) {
                if editBroadCastList {
                    DeleteButton(groupcastId: broadcast.groupcastId)
                }
                
                if ISMChatSdk.getInstance().getFramework() == .UIKit {
                    UserAvatarView(
                        avatar: broadcast.groupcastImageUrl ?? "",
                        showOnlineIndicator: false,
                        size: CGSize(width: 54, height: 54),
                        userName: broadcast.groupcastTitle ?? "",
                        font: appearance.fonts.messageListMessageText
                    )
                }
                
                BroadcastDetailsView(broadcast: broadcast)
                    .onTapGesture {
                        handleBroadcastTap(broadcast: broadcast)
                    }
                
                Spacer()
                
                BroadcastInfoButton(broadcast: broadcast)
            } .frame(maxHeight: 60)
        }
    }
    
    
    private func DeleteButton(groupcastId: String?) -> some View {
        Button {
            if let groupcastId = groupcastId {
                deleteBroadCastList(groupcastId: groupcastId)
            }
        } label: {
            appearance.images.removeMember
                .resizable()
                .frame(width: 20, height: 20, alignment: .center)
        }
        .buttonStyle(PlainButtonStyle())
    }

    
    
    private func BroadcastInfoButton(broadcast: ISMChatBroadCastDetail) -> some View {
        Button {
            if ISMChatSdk.getInstance().getFramework() == .SwiftUI {
                navigateToBrocastDetail = broadcast
                navigateToBrocastInfo = true
            } else {
                delegate?.navigateToBroadCastInfo(groupcastId: broadcast.groupcastId ?? "", groupcastTitle: broadcast.groupcastTitle ?? "", groupcastImage: broadcast.groupcastImageUrl ?? "")
            }
        } label: {
            appearance.images.broadcastInfo
                .resizable()
                .frame(width: 18, height: 18, alignment: .center)
        }
        .frame(width: 50)
    }

    
   
    private func BroadcastDetailsView(broadcast: ISMChatBroadCastDetail) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            if broadcast.groupcastTitle != "Default" {
                Text(broadcast.groupcastTitle ?? "")
                    .foregroundColor(appearance.colorPalette.chatListUserName)
                    .font(appearance.fonts.chatListUserName)
            } else {
                Text("Recipients: \(broadcast.membersCount ?? 0)")
                    .foregroundColor(appearance.colorPalette.chatListUserName)
                    .font(appearance.fonts.chatListUserName)
            }
            
            if let members = broadcast.metaData?.membersDetail {
                Text(members.map { $0.memberName ?? "" }.joined(separator: ", "))
                    .foregroundColor(appearance.colorPalette.chatListUserMessage)
                    .font(appearance.fonts.chatListUserMessage)
            }
        }
        
    }
    
    private func handleBroadcastTap(broadcast: ISMChatBroadCastDetail) {
        if ISMChatSdk.getInstance().getFramework() == .UIKit {
            delegate?.navigateToBroadCastList(
                groupcastId: broadcast.groupcastId ?? "",
                groupCastTitle: broadcast.groupcastTitle ?? "", groupcastImage: broadcast.groupcastImageUrl ?? ""
            )
        } else {
            // SwiftUI navigation
            navigateToGroupCastId = broadcast.groupcastId ?? ""
            navigateToGroupCastTitle = broadcast.groupcastTitle ?? ""
            navigateToMessageView = true
        }
    }

    
   
    /// Creates empty state view when no broadcasts exist
    private func EmptyStateView() -> some View {
        VStack{
            if ISMChatSdkUI.getInstance().getChatProperties().showCustomPlaceholder {
                appearance.placeholders.broadCastListPlaceholder
            } else {
                Spacer()
                Text("You should use broadcast lists to message multiple people at once.")
                    .font(appearance.fonts.messageListMessageText)
                    .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                    .padding(.horizontal, 35)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
    }
    
   
    private func NavigationLinksView() -> some View {
        Group {
            NavigationLink("", isActive: $navigateToBrocastInfo) {
                ISMChatBroadCastInfo(
                    broadcastTitle: navigateToBrocastDetail?.groupcastTitle ?? "",
                    groupcastId: navigateToBrocastDetail?.groupcastId ?? ""
                )
                .environmentObject(realmManager)
            }
            
            NavigationLink("", isActive: $navigatetoCreatBroadCast) {
                ISMCreateGroupConversationView(
                    showSheetView: $navigatetoCreatGroup,
                    viewModel: self.conversationviewModel,
                    selectUserFor: .BroadCast,
                    groupCastId: "",
                    groupCastIdToNavigate: $groupCastIdToNavigate
                )
                .environmentObject(realmManager)
            }
            
            NavigationLink("", isActive: $navigateToMessageView) {
                ISMMessageView(
                    conversationViewModel: self.conversationviewModel,
                    conversationID: self.navigateToGroupCastId ?? "",
                    opponenDetail: nil,
                    myUserId: "",
                    isGroup: false,
                    fromBroadCastFlow: true,
                    groupCastId: self.navigateToGroupCastId ?? "",
                    groupConversationTitle: navigateToGroupCastTitle ?? "",
                    groupImage: nil
                )
                .environmentObject(realmManager)
                .environmentObject(networkMonitor)
            }
        }
    }
    
   
    
    var navBarLeadingBtn : some View{
        if editBroadCastList == false{
            Button(action: { dismiss() }) {
                appearance.images.backButton
                    .resizable()
                    .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height)
            }
        }else{
            //don't show back button
            Button {
                
            } label: {
                Image("")
                    .resizable()
                    .frame(width: 29,height: 29)
            }
        }
    }
    var navBarTrailingBtn : some View{
        if editBroadCastList == false{
            if allBroadCasts?.count != 0 {
                Button(action: { editBroadCastList = true }) {
                    Text("Edit")
                        .font(appearance.fonts.messageListMessageText)
                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                }
            }else{
                Button {
                    
                } label: {
                    Text("")
                        .font(appearance.fonts.messageListMessageText)
                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                }
            }
        }else{
            Button(action: {
                    editBroadCastList = false
            }) {
                Text("Done")
                    .font(appearance.fonts.messageListMessageText)
                    .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
            }
        }
    }
    
    /// Deletes a broadcast list and its associated messages
    /// - Parameter groupcastId: ID of broadcast to delete
    func deleteBroadCastList(groupcastId : String){
        viewModel.deleteBroadCastList(groupcastId: groupcastId) { _ in
//            self.realmManager.deleteBroadCast(groupcastId: groupcastId)
//            self.realmManager.deleteMessagesThroughGroupCastId(groupcastId: groupcastId)
//            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
//                realmManager.getAllLocalBroadCasts()
//            })
            getBroadcastList()
        }
    }
}
