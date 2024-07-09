//
//  ISM_MessageInfo.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 16/03/23.
//

import SwiftUI
import IsometrikChat

public struct ISMMessageInfoView: View {
    
    //MARK:  - PROPERTIES
    @Environment(\.dismiss) var dismiss
    
    @State var previousAudioRef: AudioPlayViewModel?
    
    let conversationId : String
    let message : MessagesDB
    let viewWidth : CGFloat
    let mediaType : ISMChat_MediaType
    var viewModel = ChatsViewModel(ismChatSDK: ISMChatSdk.getInstance())
    let isGroup : Bool
    let groupMember : [ISMChat_GroupMember]
    let fromBroadCastFlow : Bool?
    @State  var deliveredAt : Double?
    @State  var readAt : Double?
    @EnvironmentObject var realmManager : RealmManager
    @State var deliveredUsers : [ISMChat_User]?
    @State var readUsers : [ISMChat_User]?
    @State var themeFonts = ISMChatSdk.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdk.getInstance().getAppAppearance().appearance.colorPalette
    @State var themeImage = ISMChatSdk.getInstance().getAppAppearance().appearance.images
    
    //MARK:  - LIFECYCLE
    public var body: some View {
        ZStack{
            Color.backgroundView.edgesIgnoringSafeArea(.all)
            VStack{
                VStack(alignment  :.trailing,spacing: 0){
                    //Header
                    ISMChat_Helper.sectionHeader(firstMessage: message, color: themeColor.messageList_SectionHeaderText, font: themeFonts.messageList_SectionHeaderText)
                    
                    ISMMessageInfoSubView(previousAudioRef: $previousAudioRef, messageType: ISMChat_Helper.getMessageType(message: message), message: message, viewWidth: viewWidth, isReceived: false, messageDeliveredType: ISMChat_Helper.checkMessageDeliveryType(message: message, isGroup: self.isGroup ,memberCount: realmManager.getMemberCount(convId: self.conversationId)), conversationId: conversationId,isGroup: self.isGroup, groupconversationMember: groupMember, fromBroadCastFlow: self.fromBroadCastFlow)
                        .padding(.trailing,15)
                        .environmentObject(self.realmManager)
                    
                }
                List{
                    if isGroup == true || fromBroadCastFlow == true{
                        Section {
                            if let members = readUsers{
                                if members.count > 0{
                                    ForEach(members, id: \.self) { member in
                                        ISMMessageInfoDetailUserSubView(user: member)
                                    }
                                }else{
                                    HStack{
                                        Spacer()
                                        Text("---")
                                            .foregroundColor(themeColor.chatList_UserMessage)
                                            .font(themeFonts.chatList_UserMessage)
                                            .padding(.horizontal,10)
                                        Spacer()
                                    }
                                }
                            }else{
                                HStack{
                                    Spacer()
                                    Text("---")
                                        .foregroundColor(themeColor.chatList_UserMessage)
                                        .font(themeFonts.chatList_UserMessage)
                                        .padding(.horizontal,10)
                                    Spacer()
                                }
                            }
                        } header: {
                            HStack(spacing : 5){
                                themeImage.messageRead
                                    .resizable().frame(width: 15, height: 9, alignment: .center)
                                
                                Text("READ BY")
                                    .foregroundColor(themeColor.chatList_UserMessage)
                                    .font(themeFonts.chatList_UserMessage)
                                    .textCase(nil)
                                
                            }.listRowInsets(EdgeInsets())
                        } footer: {
                            Text("")
                        }
                        
                        Section {
                            if let members = deliveredUsers{
                                if members.count > 0{
                                    ForEach(members, id: \.self) { member in
                                        ISMMessageInfoDetailUserSubView(user: member)
                                    }
                                }else{
                                    HStack{
                                        Spacer()
                                        Text("---")
                                            .foregroundColor(themeColor.chatList_UserMessage)
                                            .font(themeFonts.chatList_UserMessage)
                                            .padding(.horizontal,10)
                                        Spacer()
                                    }
                                }
                            }else{
                                HStack{
                                    Spacer()
                                    Text("---")
                                        .foregroundColor(themeColor.chatList_UserMessage)
                                        .font(themeFonts.chatList_UserMessage)
                                        .padding(.horizontal,10)
                                    Spacer()
                                }
                            }
                        } header: {
                            HStack(spacing : 5){
                                themeImage.messageDelivered
                                    .resizable().frame(width: 15, height: 9, alignment: .center)
                                Text("DELIVERED TO")
                                    .foregroundColor(themeColor.chatList_UserMessage)
                                    .font(themeFonts.chatList_UserMessage)
                                    .textCase(nil)
                                
                            }.listRowInsets(EdgeInsets())
                        } footer: {
                            Text("")
                        }
                    }else{
                        Section {
                            HStack{
                                themeImage.messageRead
                                    .resizable().frame(width: 15, height: 9, alignment: .center).padding(.horizontal,10)
                                Text("Read")
                                    .foregroundColor(themeColor.messageList_MessageText)
                                    .font(themeFonts.messageList_MessageText)
                                Spacer()
                                if let readAtTime = self.readAt{
                                    let text = NSDate().descriptiveStringLastSeen(time: readAtTime)
                                    Text(text)
                                        .foregroundColor(themeColor.chatList_UserMessage)
                                        .font(themeFonts.chatList_UserMessage)
                                        .padding(.horizontal,10)
                                }else{
                                    Text("---")
                                        .foregroundColor(themeColor.chatList_UserMessage)
                                        .font(themeFonts.chatList_UserMessage)
                                        .padding(.horizontal,10)
                                }
                            }//:HSTACK
                            
                            HStack{
                                themeImage.messageDelivered
                                    .resizable().frame(width: 15, height: 9, alignment: .center).padding(.horizontal,10)
                                Text("Delivered")
                                    .foregroundColor(themeColor.messageList_MessageText)
                                    .font(themeFonts.messageList_MessageText)
                                Spacer()
                                if let deliveredAtTime = self.deliveredAt{
                                    let text = NSDate().descriptiveStringLastSeen(time: deliveredAtTime)
                                    Text(text)
                                        .foregroundColor(themeColor.chatList_UserMessage)
                                        .font(themeFonts.chatList_UserMessage)
                                        .padding(.horizontal,10)
                                }else{
                                    Text("---")
                                        .foregroundColor(themeColor.chatList_UserMessage)
                                        .font(themeFonts.chatList_UserMessage)
                                        .padding(.horizontal,10)
                                }
                                
                            }//:HSTACK
                            
                        } header: {
                            Text("")
                        } footer: {
                            Text("")
                        }
                    }
                }.listRowSeparatorTint(Color.border)
                    .background(Color.listBackground)
                        .scrollContentBackground(.hidden)
                
            }//:VSTACK
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Message Info")
                            .font(themeFonts.navigationBar_Title)
                            .foregroundColor(themeColor.navigationBar_Title)
                    }
                }
            }
            .navigationBarItems(leading: navigationBarLeadingButtons())
            .navigationBarBackButtonHidden(true)
            .onAppear {
                if fromBroadCastFlow == true{
                    getGroupCastData()
                }else{
                    getData()
                }
               
                UITableView.appearance().backgroundColor = UIColor(Color.clear)
            }
            .onDisappear {
                if let previousAudioRef {
                    previousAudioRef.pauseAudio()
                    previousAudioRef.removeAudio()
                }
            }
        }
    }
    //MARK: - CONFIGURE
    func getData(){
        viewModel.getMessageDeliveredInfo(messageId: message.messageId , conversationId: conversationId) { info in
            self.deliveredAt = info?.users?.first?.timestamp ?? 0
            self.deliveredUsers = info?.users
            viewModel.getMessageReadInfo(messageId: message.messageId , conversationId: conversationId) { data in
                self.readAt = data?.users?.first?.timestamp ?? 0
                updateDeliveredUsers(readUsers: data?.users)
                self.readUsers = data?.users
            }
        }
    }
    
    func getGroupCastData(){
        viewModel.getGroupCastMessageDeliveredInfo(messageId: message.messageId, groupcastId: message.groupcastId ?? "") { info in
            self.deliveredAt = info?.users?.first?.timestamp ?? 0
            self.deliveredUsers = info?.users
            viewModel.getGroupCastMessageReadInfo(messageId:  message.messageId, groupcastId: message.groupcastId ?? "") { data in
                self.readAt = data?.users?.first?.timestamp ?? 0
                updateDeliveredUsers(readUsers: data?.users)
                self.readUsers = data?.users
            }
        }
    }
    
    func updateDeliveredUsers(readUsers : [ISMChat_User]?) {
        if let readUserIds = readUsers?.map({ $0.userId }),
           let currentDeliveredUsers = deliveredUsers {
            deliveredUsers = currentDeliveredUsers.filter { !readUserIds.contains($0.userId) }
        }
    }
    
    func navigationBarLeadingButtons()  -> some View {
        Button(action : {}) {
            HStack{
                Button(action: {
                    dismiss()
                }) {
                    themeImage.CloseSheet
                        .resizable()
                        .tint(.black)
                        .foregroundColor(.black)
                        .frame(width: 17,height: 17)
                }
            }
        }
    }
}


struct ISMMessageInfoDetailUserSubView : View {
    
    let user : ISMChat_User
    @State var themeFonts = ISMChatSdk.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdk.getInstance().getAppAppearance().appearance.colorPalette
    
    var body: some View {
        HStack(spacing: 10){
            UserAvatarView(
                avatar:  user.userProfileImageUrl ?? "",
                showOnlineIndicator: false,
                size: CGSize(width: 24, height: 24), userName: user.userName ?? "",font: .regular(size: 12))
            
            Text(user.userName ?? "")
                .foregroundColor(themeColor.messageList_MessageText)
                .font(themeFonts.messageList_MessageText)
            
            Spacer()
            
            let text = NSDate().descriptiveStringLastSeen(time: user.timestamp ?? 0)
            Text(text)
                .foregroundColor(themeColor.chatList_UserMessage)
                .font(themeFonts.chatList_UserMessage)
        }
    }
}
