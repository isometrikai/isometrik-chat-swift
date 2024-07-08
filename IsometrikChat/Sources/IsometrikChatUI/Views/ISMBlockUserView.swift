//
//  ISMBlockUserView.swift
//  ISMChatSdk
//
//  Created by Rahul Iphone123 on 22/06/23.
//

import SwiftUI

struct ISMBlockUserView: View {
    
    //MARK:  - PROPERTIES
    @ObservedObject var conversationViewModel = ConversationViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @Environment(\.dismiss) var dismiss
    @State var edit : Bool = false
    @State var blockedUser : [ISMChat_User] = []
    @State var removedUser : [ISMChat_User] = []
    @State var themeFonts = ISMChatSdk.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdk.getInstance().getAppAppearance().appearance.colorPalette
    @State var themeImage = ISMChatSdk.getInstance().getAppAppearance().appearance.images
    
    //MARK:  - BODY
    var body: some View {
        ZStack{
            VStack {
                NavigationView {
                    List {
                        ForEach(blockedUser){ obj in
                            ZStack{
                                HStack(spacing:10){
                                    if edit == true{
                                        Button {
                                            removedUser.append(obj)
                                        } label: {
                                            themeImage.removeMember
                                                .resizable()
                                                .frame(width: 20, height: 20, alignment: .center)
                                            
                                        }.buttonStyle(PlainButtonStyle())
                                    }
                                    
                                    UserAvatarView(avatar: obj.userProfileImageUrl ?? "", showOnlineIndicator: obj.online ?? false,size: CGSize(width: 29, height: 29), userName: obj.userName ?? "",font: .regular(size: 12))
                                    VStack(alignment: .leading, spacing: 5, content: {
                                        Text(obj.userName ?? "")
                                            .font(themeFonts.messageList_MessageText)
                                            .foregroundColor(themeColor.messageList_MessageText)
                                        Text(obj.userIdentifier ?? "")
                                            .font(themeFonts.chatList_UserMessage)
                                            .foregroundColor(themeColor.chatList_UserMessage)
                                            .lineLimit(2)
                                        
                                    })//:VStack
                                }//:HStack
                                .buttonStyle(.bordered)
                                .onChange(of: removedUser) {
                                    blockedUser = blockedUser.filter({ user in
                                        !removedUser.contains(where: { $0.id == user.id })
                                    })
                                }
                            }//:ZStack
                        }
                    }
                }.navigationViewStyle(StackNavigationViewStyle())
                    .navigationBarBackButtonHidden()
                    .navigationBarItems(leading: Button {
                        dismiss()
                    } label: {
                        themeImage.CloseSheet
                            .resizable()
                            .tint(.black)
                            .foregroundColor(.black)
                            .frame(width: 17,height: 17)
                    },trailing: navigationTrailing())
            }.listStyle(DefaultListStyle())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Blocked")
                                .font(themeFonts.navigationBar_Title)
                                .foregroundColor(themeColor.navigationBar_Title)
                        }
                    }
                }
                .onAppear {
                    refreshBlockUser()
                }
                .refreshable {
                    refreshBlockUser()
                }
            if self.conversationViewModel.getBlockUser().count == 0{
                VStack{
                    Spacer()
                    themeImage.blockedUserListPlaceholder
                        .resizable().frame(width: 206, height: 138, alignment: .center)
                    Spacer()
                }
            }
        }
    }
    
    //MARK:  - CONFIGURE
    func refreshBlockUser() {
        conversationViewModel.getBlockUsers { obj in
            self.blockedUser = obj?.users ?? []
        }
    }
    
    func navigationTrailing() -> some View{
        Button(action: {
            if edit == true{
                if removedUser.count > 0{
                    for obj in removedUser{
                        self.conversationViewModel.blockUnBlockUser(opponentId: obj.id, needToBlock: false) { value in
                            self.conversationViewModel.removeBlockUser(obj: obj)
                            NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                            edit = false
                        }
                    }
                }else{
                    dismiss()
                }
            }else{
                edit.toggle()
            }
        }, label: {
            Text(edit == true ? "Done" : "Edit")
                .font(themeFonts.messageList_ReplyToolbarHeader)
                .foregroundColor(themeColor.userProfile_editText)
        })
    }
}
