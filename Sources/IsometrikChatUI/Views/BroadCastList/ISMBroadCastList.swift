//
//  ISMBroadCastList.swift
//  ISMChatSdk
//
//  Created by Rasika on 03/06/24.
//

import SwiftUI
import IsometrikChat

public struct ISMBroadCastList: View {
    
    //MARK:  - PROPERTIES
    @Environment(\.dismiss) public var dismiss
    
    @ObservedObject public var viewModel = ChatsViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @ObservedObject public var conversationviewModel = ConversationViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @EnvironmentObject public var realmManager : RealmManager
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
    @State public var themeText = ISMChatSdkUI.getInstance().getAppAppearance().appearance.text
    
    
    //MARK:  - LIFECYCLE
    public var body: some View {
        ZStack{
            Color(uiColor: .white).edgesIgnoringSafeArea(.all)
                VStack {
                    if realmManager.getBroadCastsCount() != 0{
                        List(realmManager.getBroadCasts()) { broadcast in
                                ZStack{
                                    HStack(spacing: 10){
                                        if editBroadCastList == true{
                                            Button {
                                                deleteBroadCastList(groupcastId: broadcast.groupcastId ?? "")
                                            } label: {
                                                themeImage.removeMember
                                                    .resizable()
                                                    .frame(width: 20, height: 20, alignment: .center)
                                                
                                            }.buttonStyle(PlainButtonStyle())
                                        }
                                       
                                            VStack(alignment: .leading, spacing: 8) {
                                                if broadcast.groupcastTitle != "Default"{
                                                    Text(broadcast.groupcastTitle ?? "")
                                                        .foregroundColor(themeColor.chatListUserName)
                                                        .font(themeFonts.chatListUserName)
                                                }else{
                                                    Text("Recipients: \(broadcast.membersCount ?? 0)")
                                                        .foregroundColor(themeColor.chatListUserName)
                                                        .font(themeFonts.chatListUserName)
                                                }
                                                
                                                if let members = broadcast.metaData?.membersDetail{
                                                    Text(members.map { $0.memberName ?? "" }.joined(separator: ", "))
                                                        .foregroundColor(themeColor.chatListUserMessage)
                                                        .font(themeFonts.chatListUserMessage)
                                                }
                                            }.onTapGesture {
                                                navigateToGroupCastId = broadcast.groupcastId ?? ""
                                                navigateToGroupCastTitle = broadcast.groupcastTitle ?? ""
                                                navigateToMessageView = true
                                            }
                                        
                                        Spacer()
                                        Button {
                                            navigateToBrocastDetail = broadcast
                                            navigateToBrocastInfo = true
                                        } label: {
                                            themeImage.broadcastInfo
                                                .resizable()
                                                .frame(width: 24, height: 24, alignment: .center)
                                        }.frame(width: 50)
                                    }
                                }
                        }
                        .listRowSeparatorTint(Color.border)
                        .keyboardType(.default)
                        .textContentType(.oneTimeCode)
                        .autocorrectionDisabled(true)
                        .refreshable {
                        }
                    }else{
                        
                        if ISMChatSdk.getInstance().getFramework() == .SwiftUI{
                            Spacer()
                            Text("You should use broadcast lists to message multiple people at once.")
                                .font(themeFonts.messageListMessageText)
                                .foregroundColor(themeColor.messageListHeaderTitle)
                                .padding(.horizontal,35)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }else{
                            placeholder
                        }
                    }
                    
//                    Button {
//                        navigatetoCreatBroadCast = true
//                    } label: {
//                        Text("New list")
//                            .font(themeFonts.messageListtoolbarAction)
//                            .foregroundColor(themeColor.messageListHeaderTitle)
//                    }

                    
                }//:VStack
                .onAppear {
                    realmManager.getBroadCasts()
                    navigateToBrocastInfo = false
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.refreshBroadCastListNotification)) { _ in
                    getBroadcastList()
                }
                .refreshable {
                    getBroadcastList()
                }
                .background(NavigationLink("", destination: ISMChatBroadCastInfo(broadcastTitle: navigateToBrocastDetail?.groupcastTitle ?? "", groupcastId: navigateToBrocastDetail?.groupcastId ?? "").environmentObject(realmManager), isActive: $navigateToBrocastInfo))
                .background(NavigationLink("", destination: ISMCreateGroupConversationView(showSheetView : $navigatetoCreatGroup,viewModel: self.conversationviewModel,selectUserFor: .BroadCast, groupCastId: "", groupCastIdToNavigate: $groupCastIdToNavigate).environmentObject(realmManager),isActive: $navigatetoCreatBroadCast))
                .background(NavigationLink("", destination:  ISMMessageView(conversationViewModel : self.conversationviewModel,conversationID:  self.navigateToGroupCastId ?? "",opponenDetail: nil,myUserId: "", isGroup: false,fromBroadCastFlow: true,groupCastId: self.navigateToGroupCastId ?? "", groupConversationTitle: navigateToGroupCastTitle ?? "", groupImage: nil)
                    .environmentObject(realmManager).environmentObject(networkMonitor), isActive: $navigateToMessageView))
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading : navBarLeadingBtn,trailing: navBarTrailingBtn)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Broadcast lists")
                                .font(themeFonts.navigationBarTitle)
                                .foregroundColor(themeColor.navigationBarTitle)
                        }
                    }
                }
        }.onLoad{
            getBroadcastList()
        }
    }
    
    //MARK: - CONFIGURE
    
    
    func getBroadcastList(){
        viewModel.getBroadCastList { data in
//            self.broadCastList = data?.groupcasts ?? []
            if let groupcast = data?.groupcasts{
                realmManager.manageBroadCastList(arr: groupcast)
            }
        }
    }
    
    var placeholder : some View{
        VStack(spacing:20){
            themeImage.broadCastListPlaceholder
                .resizable()
                .scaledToFit()
                .frame(width: 169, height: 169, alignment: .center)
            if !themeText.broadcastListPlaceholderText.isEmpty{
                Text(themeText.broadcastListPlaceholderText)
                    .font(themeFonts.navigationBarTitle)
                    .foregroundColor(themeColor.navigationBarTitle)
            }
        }
    }
    
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
            if realmManager.getBroadCastsCount() != 0 {
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
            self.realmManager.deleteBroadCast(groupcastId: groupcastId)
            self.realmManager.deleteMessagesThroughGroupCastId(groupcastId: groupcastId)
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                realmManager.getAllBroadCasts()
            })
        }
    }
}
