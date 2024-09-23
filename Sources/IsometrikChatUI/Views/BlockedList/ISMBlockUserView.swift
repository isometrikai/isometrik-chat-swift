//
//  ISMBlockUserView.swift
//  ISMChatSdk
//
//  Created by Rahul Iphone123 on 22/06/23.
//

import SwiftUI
import IsometrikChat

public struct ISMBlockUserView: View {
    
    //MARK:  - PROPERTIES
    @ObservedObject public var conversationViewModel = ConversationViewModel()
    @Environment(\.dismiss) public var dismiss
    @State public var edit : Bool = false
    @State public var blockedUser : [ISMChatUser] = []
    @State public var removedUser : [ISMChatUser] = []
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    //MARK:  - BODY
    public var body: some View {
        ZStack{
            VStack {
                NavigationStack {
                    List {
                        ForEach(blockedUser){ obj in
                            ZStack{
                                HStack(spacing:10){
                                    if edit == true{
                                        Button {
                                            removedUser.append(obj)
                                        } label: {
                                            appearance.images.removeMember
                                                .resizable()
                                                .frame(width: 20, height: 20, alignment: .center)
                                            
                                        }.buttonStyle(PlainButtonStyle())
                                    }
                                    
                                    UserAvatarView(avatar: obj.userProfileImageUrl ?? "", showOnlineIndicator: obj.online ?? false,size: CGSize(width: 29, height: 29), userName: obj.userName ?? "",font: .regular(size: 12))
                                    VStack(alignment: .leading, spacing: 5, content: {
                                        Text(obj.userName ?? "")
                                            .font(appearance.fonts.messageListHeaderTitle)
                                            .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                        Text(obj.userIdentifier ?? "")
                                            .font(appearance.fonts.chatListUserMessage)
                                            .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                            .lineLimit(2)
                                        
                                    })//:VStack
                                }//:HStack
                                .buttonStyle(.bordered)
                                .onChange(of: removedUser, { _, _ in
                                    blockedUser = blockedUser.filter({ user in
                                        !removedUser.contains(where: { $0.id == user.id })
                                    })
                                })
                            }//:ZStack
                        }
                    }
                }.navigationViewStyle(StackNavigationViewStyle())
                    .navigationBarBackButtonHidden()
                    .navigationBarItems(leading: Button {
                        dismiss()
                    } label: {
                        appearance.images.CloseSheet
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
                                .font(appearance.fonts.navigationBarTitle)
                                .foregroundColor(appearance.colorPalette.navigationBarTitle)
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
                    appearance.images.blockedUserListPlaceholder
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
                .font(appearance.fonts.messageListReplyToolbarHeader)
                .foregroundColor(appearance.colorPalette.userProfileEditText)
        })
    }
}
