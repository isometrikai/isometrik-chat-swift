//
//  ISMBroadCastList.swift
//  ISMChatSdk
//
//  Created by Rasika on 03/06/24.
//

import SwiftUI
import IsometrikChat

struct ISMBroadCastList: View {
    
    //MARK:  - PROPERTIES
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var viewModel = ChatsViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @ObservedObject var conversationviewModel = ConversationViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @EnvironmentObject var realmManager : RealmManager
    @State var themeFonts = ISMChatSdk.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdk.getInstance().getAppAppearance().appearance.colorPalette
    @State var navigateToBrocastDetail : BroadCastListDB?
    @State var navigateToBrocastInfo : Bool = false
    @State var navigatetoCreatBroadCast : Bool = false
    @State var navigatetoCreatGroup : Bool = false
    @State var editBroadCastList : Bool = false
    
    @State var navigateToGroupCastId : String = ""
    @State var navigateToGroupCastTitle : String = ""
    
    @State var navigateToMessageView : Bool = false
    @State var groupCastIdToNavigate : String = ""
    
    @State var themeImage = ISMChatSdk.getInstance().getAppAppearance().appearance.images
    
    
    //MARK:  - LIFECYCLE
    var body: some View {
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
                                                        .foregroundColor(themeColor.chatList_UserName)
                                                        .font(themeFonts.chatList_UserName)
                                                }else{
                                                    Text("Recipients: \(broadcast.membersCount ?? 0)")
                                                        .foregroundColor(themeColor.chatList_UserName)
                                                        .font(themeFonts.chatList_UserName)
                                                }
                                                
                                                if let members = broadcast.metaData?.membersDetail{
                                                    Text(members.map { $0.memberName ?? "" }.joined(separator: ", "))
                                                        .foregroundColor(themeColor.chatList_UserMessage)
                                                        .font(themeFonts.chatList_UserMessage)
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
                        Spacer()
                        Text("You should use broadcast lists to message multiple people at once.")
                            .font(themeFonts.messageList_MessageText)
                            .foregroundColor(themeColor.messageList_MessageText)
                            .padding(.horizontal,35)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    
                    Button {
                        navigatetoCreatBroadCast = true
                    } label: {
                        Text("New list")
                            .font(themeFonts.messageList_toolbarAction)
                            .foregroundColor(themeColor.messageList_MessageText)
                    }

                    
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
                .background(NavigationLink("", destination: ISMChat_BroadCastInfo(broadcastTitle: navigateToBrocastDetail?.groupcastTitle ?? "", groupcastId: navigateToBrocastDetail?.groupcastId ?? "").environmentObject(realmManager), isActive: $navigateToBrocastInfo))
                .background(NavigationLink("", destination: ISMCreateGroupConversationView(showSheetView : $navigatetoCreatGroup,viewModel: self.conversationviewModel,selectUserFor: .BroadCast, groupCastId: "", groupCastIdToNavigate: $groupCastIdToNavigate).environmentObject(realmManager),isActive: $navigatetoCreatBroadCast))
                .background(NavigationLink("", destination:  ISMMessageView(conversationViewModel : self.conversationviewModel,conversationID:  self.navigateToGroupCastId ?? "",opponenDetail: nil,userId: "", isGroup: false,fromBroadCastFlow: true,groupCastId: self.navigateToGroupCastId ?? "", groupConversationTitle: navigateToGroupCastTitle ?? "", groupImage: nil)
                    .environmentObject(realmManager), isActive: $navigateToMessageView))
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading : navBarLeadingBtn,trailing: navBarTrailingBtn)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Broadcast lists")
                                .font(themeFonts.navigationBar_Title)
                                .foregroundColor(themeColor.navigationBar_Title)
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
                        .font(themeFonts.messageList_MessageText)
                        .foregroundColor(themeColor.messageList_MessageText)
                }
            }else{
                Button {
                    
                } label: {
                    Text("")
                        .font(themeFonts.messageList_MessageText)
                        .foregroundColor(themeColor.messageList_MessageText)
                }
            }
        }else{
            Button(action: {
                    editBroadCastList = false
            }) {
                Text("Done")
                    .font(themeFonts.messageList_MessageText)
                    .foregroundColor(themeColor.messageList_MessageText)
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
