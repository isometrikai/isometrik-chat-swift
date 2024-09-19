//
//  ISMChatBroadCastInfo.swift
//  ISMChatSdk
//
//  Created by Rasika on 04/06/24.
//

import SwiftUI
import IsometrikChat

struct ISMChatBroadCastInfo: View {
    
    //MARK: - PROPERTIES
    let broadcastTitle : String?
    let groupcastId : String?
    
    @ObservedObject var viewModel = ChatsViewModel()
    @ObservedObject var conversationviewModel = ConversationViewModel()
    @EnvironmentObject var realmManager : RealmManager
    @State var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State var themeImage = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    @State var listName : String = ""
    @Environment(\.dismiss) var dismiss
    @State var membersInfo : ISMChatBroadCastMembers? = nil
    @State var navigatetoAddMember : Bool = false
    @State var groupCastIdToNavigate : String = ""
    @State var navigatetoCreatGroup : Bool = false
    
    //MARK: - BODY
    var body: some View {
        ZStack {
            themeColor.messageListBackgroundColor.edgesIgnoringSafeArea(.all)
            VStack(alignment: .center){
                List {
                    Section(header: Text("")) {
                        ZStack(alignment: .leading) {
                            if listName.isEmpty || listName == "Default"{
                                Text("List name")
                                    .font(themeFonts.userProfilefields)
                                    .foregroundColor(themeColor.userProfileFields)
                            }
                            TextField("", text: $listName)
                                .font(themeFonts.userProfilefields)
                                .foregroundColor(themeColor.userProfileFields)
                        }
                    }
                    
                    Section(header: Text("List Recipients : \(membersInfo?.membersCount ?? 0)")) {
                        if let members = membersInfo?.members{
                            ForEach(members) { mem in
                                HStack(spacing: 10) {
                                    UserAvatarView(avatar: mem.memberInfo?.userProfileImageUrl ?? "", showOnlineIndicator: false, size: CGSize(width: 25, height: 25), userName: mem.memberInfo?.userName ?? "",font: .regular(size: 12))
                                    Text(mem.memberInfo?.userName ?? "")
                                        .font(themeFonts.messageListMessageText)
                                        .foregroundColor(themeColor.messageListHeaderTitle)
                                }
                            }
                            Button {
                                navigatetoAddMember = true
                                
                            } label: {
                                Text("Edit list....")
                                    .font(themeFonts.messageListMessageText)
                                    .overlay {
                                        LinearGradient(
                                            colors: [Color(hex: "#A399F7"),Color(hex: "#7062E9")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .mask(
                                            Text("Edit list....")
                                                .font(themeFonts.messageListMessageText)
                                        )
                                    }
                            }
                        }
                    }
                }
                .listStyle(DefaultListStyle())
            }
            
        }.navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("List info")
                            .font(themeFonts.navigationBarTitle)
                            .foregroundColor(themeColor.navigationBarTitle)
                    }
                }
            }
            .navigationBarItems(leading : navBarLeadingBtn,trailing: trailingBarLeadingBtn)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigatetoAddMember, destination: {
                ISMCreateGroupConversationView(showSheetView : $navigatetoCreatGroup, viewModel: self.conversationviewModel,selectUserFor: .AddMemberInBroadcast,groupCastId: self.groupcastId ?? "", groupCastIdToNavigate : $groupCastIdToNavigate).environmentObject(realmManager)
            })
            .onAppear {
                viewModel.getBroadMembers(groupcastId: self.groupcastId ?? "") { data in
                    membersInfo = data
                }
                if let broadcastTitle =  broadcastTitle, !broadcastTitle.isEmpty && broadcastTitle != "Default"{
                    self.listName = broadcastTitle
                }
            }
    }
    
    var navBarLeadingBtn : some View{
        Button {
            dismiss()
        } label: {
            themeImage.backButton
                .resizable()
                .frame(width: 18, height: 18)
        }
    }
    var trailingBarLeadingBtn : some View{
        if listName != broadcastTitle{
            Button {
                viewModel.updateBroadCastTitle(groupcastId: self.groupcastId ?? "", broadcastTitle: listName) { data in
                    ISMChatHelper.print("Success")
                    NotificationCenter.default.post(name: NSNotification.refreshBroadCastListNotification,object: nil)
                    dismiss()
                }
            } label: {
                Text("Save")
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
    }
}
