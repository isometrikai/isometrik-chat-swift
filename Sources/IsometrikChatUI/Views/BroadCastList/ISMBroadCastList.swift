//
//  ISMBroadCastList.swift
//  ISMChatSdk
//
//  Created by Rasika on 03/06/24.
//

import SwiftUI
import IsometrikChat

public protocol ISMBroadCastListDelegate{
    func navigateToBroadCastList(groupcastId : String,groupCastTitle : String)
    func navigateToBroadCastInfo(groupcastId : String)
}

public struct ISMBroadCastList: View {
    
    //MARK:  - PROPERTIES
    @Environment(\.dismiss) public var dismiss
    
    @ObservedObject public var viewModel = ChatsViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @ObservedObject public var conversationviewModel = ConversationViewModel(ismChatSDK: ISMChatSdk.getInstance())
//    @EnvironmentObject public var realmManager : RealmManager
    @State public var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State public var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State public var navigateToBrocastDetail : BroadCastListDB?
    @State public var navigateToBrocastInfo : Bool = false
    @State public var navigatetoCreatBroadCast : Bool = false
    @State public var navigatetoCreatGroup : Bool = false
    @State public var editBroadCastList : Bool = false
    
    @State public var navigateToGroupCastId : String = ""
    @State public var navigateToGroupCastTitle : String = ""
    
    @State public var navigateToMessageView : Bool = false
    @State public var groupCastIdToNavigate : String = ""
    @StateObject public var networkMonitor = NetworkMonitor()
    @State public var themeImage = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    @State public var themePlaceholder = ISMChatSdkUI.getInstance().getAppAppearance().appearance.placeholders
    public var delegate : ISMBroadCastListDelegate? = nil
    @State public var query = ""
    @State var allBroadCasts : [ISMChatBroadCastDetail]? = []
    @State var storeBroadCasts : [ISMChatBroadCastDetail]? = []
    
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
                        CustomSearchBar(searchText: $query).padding(.horizontal,15)
                    }
                    BroadcastListView()
                } 
                else {
                    EmptyStateView()
                }
            }
            .onAppear {
//                realmManager.getAllLocalBroadCasts()
                navigateToBrocastInfo = false
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.refreshBroadCastListNotification)) { _ in
                getBroadcastList()
            }
            .refreshable {
                getBroadcastList()
            }
//            .background(NavigationLinksView())
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: navBarLeadingBtn, trailing: navBarTrailingBtn)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Broadcast lists")
                        .font(themeFonts.navigationBarTitle)
                        .foregroundColor(themeColor.navigationBarTitle)
                }
            }
            .onChange(of: query) { newValue in
                if newValue.isEmpty {
                    allBroadCasts = storeBroadCasts
                } else {
                    searchInBroadCastList()
                }
            }
        }
        .onLoad {
            getBroadcastList()
        }
    }
    
    func getBroadcastList(){
        self.viewModel.getBroadCastList { data in
            if let groupcast = data?.groupcasts{
                allBroadCasts = groupcast
            }
        }
    }
    
    func searchInBroadCastList(){
            let  conversation = storeBroadCasts
            allBroadCasts = conversation?.filter { conversation in
                let x = conversation.groupcastTitle?.contains(query) ?? false
                return x
            }
        }
    //MARK: - CONFIGURE
    
    
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
                        font: themeFonts.messageListMessageText
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
            themeImage.removeMember
                .resizable()
                .frame(width: 20, height: 20, alignment: .center)
        }
        .buttonStyle(PlainButtonStyle())
    }

    
    
    private func BroadcastInfoButton(broadcast: ISMChatBroadCastDetail) -> some View {
        Button {
            if ISMChatSdk.getInstance().getFramework() == .SwiftUI {
//                navigateToBrocastDetail = broadcast
//                navigateToBrocastInfo = true
            } else {
                delegate?.navigateToBroadCastInfo(groupcastId: broadcast.groupcastId ?? "")
            }
        } label: {
            themeImage.broadcastInfo
                .resizable()
                .frame(width: 18, height: 18, alignment: .center)
        }
        .frame(width: 50)
    }

    
   
    private func BroadcastDetailsView(broadcast: ISMChatBroadCastDetail) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            if broadcast.groupcastTitle != "Default" {
                Text(broadcast.groupcastTitle ?? "")
                    .foregroundColor(themeColor.chatListUserName)
                    .font(themeFonts.chatListUserName)
            } else {
                Text("Recipients: \(broadcast.membersCount ?? 0)")
                    .foregroundColor(themeColor.chatListUserName)
                    .font(themeFonts.chatListUserName)
            }
            
            if let members = broadcast.metaData?.membersDetail {
                Text(members.map { $0.memberName ?? "" }.joined(separator: ", "))
                    .foregroundColor(themeColor.chatListUserMessage)
                    .font(themeFonts.chatListUserMessage)
            }
        }
        
    }
    
    private func handleBroadcastTap(broadcast: ISMChatBroadCastDetail) {
        if ISMChatSdk.getInstance().getFramework() == .UIKit {
            delegate?.navigateToBroadCastList(
                groupcastId: broadcast.groupcastId ?? "",
                groupCastTitle: broadcast.groupcastTitle ?? ""
            )
        } else {
            // SwiftUI navigation
            navigateToGroupCastId = broadcast.groupcastId ?? ""
            navigateToGroupCastTitle = broadcast.groupcastTitle ?? ""
            navigateToMessageView = true
        }
    }

    
   
    private func EmptyStateView() -> some View {
        VStack{
            if ISMChatSdkUI.getInstance().getChatProperties().showCustomPlaceholder {
                themePlaceholder.broadCastListPlaceholder
            } else {
                Spacer()
                Text("You should use broadcast lists to message multiple people at once.")
                    .font(themeFonts.messageListMessageText)
                    .foregroundColor(themeColor.messageListHeaderTitle)
                    .padding(.horizontal, 35)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
    }
    
   
//    private func NavigationLinksView() -> some View {
//        Group {
//            NavigationLink("", isActive: $navigateToBrocastInfo) {
//                ISMChatBroadCastInfo(
//                    broadcastTitle: navigateToBrocastDetail?.groupcastTitle ?? "",
//                    groupcastId: navigateToBrocastDetail?.groupcastId ?? ""
//                )
//                .environmentObject(realmManager)
//            }
//            
//            NavigationLink("", isActive: $navigatetoCreatBroadCast) {
//                ISMCreateGroupConversationView(
//                    showSheetView: $navigatetoCreatGroup,
//                    viewModel: self.conversationviewModel,
//                    selectUserFor: .BroadCast,
//                    groupCastId: "",
//                    groupCastIdToNavigate: $groupCastIdToNavigate
//                )
//                .environmentObject(realmManager)
//            }
//            
//            NavigationLink("", isActive: $navigateToMessageView) {
//                ISMMessageView(
//                    conversationViewModel: self.conversationviewModel,
//                    conversationID: self.navigateToGroupCastId ?? "",
//                    opponenDetail: nil,
//                    myUserId: "",
//                    isGroup: false,
//                    fromBroadCastFlow: true,
//                    groupCastId: self.navigateToGroupCastId ?? "",
//                    groupConversationTitle: navigateToGroupCastTitle ?? "",
//                    groupImage: nil
//                )
//                .environmentObject(realmManager)
//                .environmentObject(networkMonitor)
//            }
//        }
//    }
    
   
    
    var navBarLeadingBtn : some View{
        if editBroadCastList == false{
            Button(action: { dismiss() }) {
                themeImage.backButton
                    .resizable()
                    .frame(width: 29,height: 29)
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
                        .font(themeFonts.messageListMessageText)
                        .foregroundColor(themeColor.messageListHeaderTitle)
                }
            }else{
                Button {
                    
                } label: {
                    Text("")
                        .font(themeFonts.messageListMessageText)
                        .foregroundColor(themeColor.messageListHeaderTitle)
                }
            }
        }else{
            Button(action: {
                    editBroadCastList = false
            }) {
                Text("Done")
                    .font(themeFonts.messageListMessageText)
                    .foregroundColor(themeColor.messageListHeaderTitle)
            }
        }
    }
    
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
