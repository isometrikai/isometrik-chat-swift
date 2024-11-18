//
//  ISMMessageInfo.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 16/03/23.
//

import SwiftUI
import IsometrikChat

public struct ISMMessageInfoView: View {
    
    //MARK:  - PROPERTIES
//    @Environment(\.dismiss) var dismiss
    
    @State var previousAudioRef: AudioPlayViewModel?
    
    let conversationId : String
    let message : MessagesDB
    let viewWidth : CGFloat
    let mediaType : ISMChatMediaType
    var viewModel = ChatsViewModel()
    let isGroup : Bool
    let groupMember : [ISMChatGroupMember]
    let fromBroadCastFlow : Bool?
    @State  var deliveredAt : Double?
    @State  var readAt : Double?
    @EnvironmentObject var realmManager : RealmManager
    @State var deliveredUsers : [ISMChatUser]?
    @State var readUsers : [ISMChatUser]?
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    var onClose: () -> Void
    
    //MARK:  - LIFECYCLE
    public var body: some View {
        ZStack{
            appearance.colorPalette.chatListBackground.edgesIgnoringSafeArea(.all)
            VStack{
                VStack(alignment  :.trailing,spacing: 0){
                    //Header
                    sectionHeader(firstMessage: message, color: appearance.colorPalette.messageListSectionHeaderText, font: appearance.fonts.messageListSectionHeaderText)
                    
                    ISMMessageInfoSubView(previousAudioRef: $previousAudioRef, messageType: ISMChatHelper.getMessageType(message: message), message: message, viewWidth: viewWidth, isReceived: false, messageDeliveredType: ISMChatHelper.checkMessageDeliveryType(message: message, isGroup: self.isGroup ,memberCount: realmManager.getMemberCount(convId: self.conversationId), isOneToOneGroup: ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup), conversationId: conversationId,isGroup: self.isGroup, groupconversationMember: groupMember, fromBroadCastFlow: self.fromBroadCastFlow)
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
                                            .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                            .font(appearance.fonts.chatListUserMessage)
                                            .padding(.horizontal,10)
                                        Spacer()
                                    }
                                }
                            }else{
                                HStack{
                                    Spacer()
                                    Text("---")
                                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                        .font(appearance.fonts.chatListUserMessage)
                                        .padding(.horizontal,10)
                                    Spacer()
                                }
                            }
                        } header: {
                            HStack(spacing : 5){
                                appearance.images.messageRead
                                    .resizable().frame(width: 15, height: 9, alignment: .center)
                                
                                Text("READ BY")
                                    .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                    .font(appearance.fonts.chatListUserMessage)
                                    .textCase(nil)
                                
                            }.listRowInsets(EdgeInsets())
                        } footer: {
                            Text("")
                        }.listRowBackground(Color.white)
                        
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
                                            .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                            .font(appearance.fonts.chatListUserMessage)
                                            .padding(.horizontal,10)
                                        Spacer()
                                    }
                                }
                            }else{
                                HStack{
                                    Spacer()
                                    Text("---")
                                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                        .font(appearance.fonts.chatListUserMessage)
                                        .padding(.horizontal,10)
                                    Spacer()
                                }
                            }
                        } header: {
                            HStack(spacing : 5){
                                appearance.images.messageDelivered
                                    .resizable().frame(width: 15, height: 9, alignment: .center)
                                Text("DELIVERED TO")
                                    .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                    .font(appearance.fonts.chatListUserMessage)
                                    .textCase(nil)
                                
                            }.listRowInsets(EdgeInsets())
                        } footer: {
                            Text("")
                        }.listRowBackground(Color.white)
                    }else{
                        Section {
                            HStack{
                                appearance.images.messageRead
                                    .resizable().frame(width: 15, height: 9, alignment: .center).padding(.horizontal,10)
                                Text("Read")
                                    .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                    .font(appearance.fonts.messageListMessageText)
                                Spacer()
                                if let readAtTime = self.readAt{
                                    let text = NSDate().descriptiveStringMessageInfo(time: readAtTime)
                                    Text(text)
                                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                        .font(appearance.fonts.chatListUserMessage)
                                        .padding(.horizontal,10)
                                }else{
                                    Text("---")
                                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                        .font(appearance.fonts.chatListUserMessage)
                                        .padding(.horizontal,10)
                                }
                            }//:HSTACK
                            
                            HStack{
                                appearance.images.messageDelivered
                                    .resizable().frame(width: 15, height: 9, alignment: .center).padding(.horizontal,10)
                                Text("Delivered")
                                    .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                                    .font(appearance.fonts.messageListMessageText)
                                Spacer()
                                if let deliveredAtTime = self.deliveredAt{
                                    let text = NSDate().descriptiveStringMessageInfo(time: deliveredAtTime)
                                    Text(text)
                                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                        .font(appearance.fonts.chatListUserMessage)
                                        .padding(.horizontal,10)
                                }else{
                                    Text("---")
                                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                                        .font(appearance.fonts.chatListUserMessage)
                                        .padding(.horizontal,10)
                                }
                                
                            }//:HSTACK
                            
                        } header: {
                            Text("")
                        } footer: {
                            Text("")
                        }.listRowBackground(Color.white) 
                    }
                }.listRowSeparatorTint(Color.border)
                    .background(appearance.colorPalette.chatListBackground)
                        .scrollContentBackground(.hidden)
                
            }//:VSTACK
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Message Info")
                            .font(appearance.fonts.navigationBarTitle)
                            .foregroundColor(appearance.colorPalette.navigationBarTitle)
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
    
    func sectionHeader(firstMessage message : MessagesDB,color : Color,font : Font) -> some View{
       let sentAt = message.sentAt
       let date = NSDate().descriptiveStringLastSeen(time: sentAt,isSectionHeader: true)
        return ZStack{
            Text(ISMChatSdkUI.getInstance().getChatProperties().captializeMessageListHeaders ? date.uppercased() :  date)
               .foregroundColor(color)
               .font(font)
               .padding(.vertical,5)
           
       }//:ZStack
       .frame(width: date.widthOfString(usingFont: UIFont.regular(size: 14)) + 20)
       .padding(.vertical, 5)
       .background(appearance.colorPalette.messageListActionBackground)
       .cornerRadius(5)
   }
    
    func updateDeliveredUsers(readUsers : [ISMChatUser]?) {
        if let readUserIds = readUsers?.map({ $0.userId }),
           let currentDeliveredUsers = deliveredUsers {
            deliveredUsers = currentDeliveredUsers.filter { !readUserIds.contains($0.userId) }
        }
    }
    
    func navigationBarLeadingButtons()  -> some View {
        Button(action: {onClose()}) {
            appearance.images.CloseSheet
                .resizable()
                .tint(.black)
                .foregroundColor(.black)
                .frame(width: 17,height: 17)
        }
    }
}


struct ISMMessageInfoDetailUserSubView : View {
    
    let user : ISMChatUser
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    var body: some View {
        HStack(spacing: 10){
            UserAvatarView(
                avatar:  user.userProfileImageUrl ?? "",
                showOnlineIndicator: false,
                size: CGSize(width: 24, height: 24), userName: user.userName ?? "",font: .regular(size: 12))
            
            Text(user.userName ?? "")
                .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                .font(appearance.fonts.messageListMessageText)
            
            Spacer()
            
            let text = NSDate().descriptiveStringMessageInfo(time: user.timestamp ?? 0)
            Text(text)
                .foregroundColor(appearance.colorPalette.chatListUserMessage)
                .font(appearance.fonts.chatListUserMessage)
        }
    }
}
