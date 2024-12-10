//
//  ISMReactionDetailView.swift
//  ISMChatSdk
//
//  Created by Rasika on 19/04/24.
//

import SwiftUI
import Realm
import IsometrikChat

struct ISMReactionDetailView: View {
    
    //MARK:  - PROPERTIES
    let message : MessagesDB
    let groupconversationMember : [ISMChatGroupMember]
    let isGroup : Bool
    let opponentDeatil : ISMChatUser
    @State private var selectedTab: Int = 0
    @State private var allReactions : [String : [String]] = [:]
    var viewModel = ChatsViewModel()
    @Binding var showReactionDetail : Bool
    @Binding var reactionRemoved : String
    @EnvironmentObject var realmManager : RealmManager
     var userData = ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig
    
    //MARK:  - LIFECYCLE
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    Button(action: {
                        selectedTab = 0
                    }) {
                        VStack{
                            Spacer()
                            let count = message.reactions.count
                            Text("All \(count)")
                                .foregroundColor(Color(hex: "#294566"))
                                .font(Font.regular(size: 18))
                            Spacer()
                            if selectedTab == 0{
                                Rectangle()
                                    .fill(LinearGradient(
                                        gradient: .init(colors: [Color(hex: "#A399F7"), Color(hex: "#7062E9")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .frame(height: 4)
                            }
                        } .frame(width: 50)
                    }
                    ForEach(message.reactions.indices, id: \.self) { index in
                        Button(action: {
                            selectedTab = index + 1
                        }) {
                            let emoji = ISMChatHelper.getEmoji(valueString: message.reactions[index].reactionType)
                            VStack{
                                Spacer()
                                Text(emoji)
                                    .foregroundColor(Color(hex: "#294566"))
                                    .font(Font.regular(size: 18))
                                Spacer()
                                if selectedTab == index + 1{
                                    Rectangle()
                                        .fill(LinearGradient(
                                            gradient: .init(colors: [Color(hex: "#A399F7"), Color(hex: "#7062E9")]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                        .frame(height: 4)
                                }
                            }.frame(width: 50)
                        }
                    }
                }.frame(height: 50)
                    .padding()
            }
            
            if selectedTab == 0 {
                List {
                    ForEach(Array(allReactions.keys), id: \.self) { reactionType in
                        ForEach(allReactions[reactionType] ?? [], id: \.self) { user in
                            if isGroup == true{
                                subViewForGroup(userId: user, reactionType: reactionType)
                            }else{
                                subView(userId: user,
                                        profilePicture: user == userData.userId ? (userData.userProfileImage) : (opponentDeatil.userProfileImageUrl ?? ""),
                                        userName: user == userData.userId ? (userData.userName) : (opponentDeatil.userName ?? ""),
                                        userIdentifier: opponentDeatil.userIdentifier ?? "",
                                        reactionType: reactionType)
                            }
                        }
                    }
                }.listStyle(.plain)
            } else {
                List {
                    ForEach(Array(message.reactions[selectedTab - 1].users), id: \.self) { item in
                        if isGroup == true{
                            subViewForGroup(userId: item, reactionType: message.reactions[selectedTab - 1].reactionType)
                        }else{
                            subView(userId: item, profilePicture: item == userData.userId ? (userData.userProfileImage) : (opponentDeatil.userProfileImageUrl ?? ""),
                                    userName: opponentDeatil.userName ?? "",
                                    userIdentifier: opponentDeatil.userIdentifier ?? "",
                                    reactionType: message.reactions[selectedTab - 1].reactionType)
                        }
                    }
                }.listStyle(.plain)
            }
            Spacer()
        }.onAppear(perform: {
            for reaction in message.reactions {
                let usersArray = Array(reaction.users)
                if var users = allReactions[reaction.reactionType] {
                    users.append(contentsOf: usersArray)
                    allReactions[reaction.reactionType] = users
                } else {
                    allReactions[reaction.reactionType] = usersArray
                }
            }
        })
    }
    
    //MARK: - CONFIGURE
    func removeReaction(reaction : String){
        viewModel.removeReaction(conversationId: self.message.conversationId, messageId: self.message.messageId, emojiReaction: reaction) { _ in
            reactionRemoved = reaction
            showReactionDetail = false
            realmManager.addLastMessageOnAddAndRemoveReaction(conversationId: self.message.conversationId, action: ISMChatActionType.reactionRemove.value, emoji: reaction, userId: userData.userId)
        }
    }
    
    func subView(userId : String, profilePicture : String, userName : String,userIdentifier : String,reactionType : String) -> some View{
        HStack {
            UserAvatarView(avatar: profilePicture, showOnlineIndicator: false, size: CGSize(width: 38, height: 38), userName: userName, font: .regular(size: 14))
            VStack(alignment: .leading) {
                Text(userId == userData.userId ? ConstantStrings.you : userName)
                    .font(Font.regular(size: 16))
                    .foregroundColor(Color(hex: "#294566"))
                Text(userId == userData.userId ? ConstantStrings.tapToRemove : userIdentifier)
                    .font(Font.regular(size: 12))
                    .foregroundColor(Color(hex: "#9EA4C3"))
            }
            Spacer()
            Text(ISMChatHelper.getEmoji(valueString: reactionType))
                .font(Font.regular(size: 28))
        }.onTapGesture {
            if userId == userData.userId {
                removeReaction(reaction: reactionType)
            }
        }
    }
    
    func subViewForGroup(userId : String,reactionType : String) -> some View{
        HStack {
            let groupMember = groupconversationMember.first { member in
                member.userId == userId
            }
            UserAvatarView(avatar: groupMember?.userProfileImageUrl ?? "", showOnlineIndicator: false, size: CGSize(width: 38, height: 38), userName: groupMember?.userName ?? "", font: .regular(size: 14))
            VStack(alignment: .leading) {
                Text(groupMember?.userId == userData.userId ? ConstantStrings.you : (groupMember?.userName ?? ""))
                    .font(Font.regular(size: 16))
                    .foregroundColor(Color(hex: "#294566"))
                Text(groupMember?.userId == userData.userId ? ConstantStrings.tapToRemove : (groupMember?.userIdentifier ?? ""))
                    .font(Font.regular(size: 12))
                    .foregroundColor(Color(hex: "#9EA4C3"))
            }
            Spacer()
            Text(ISMChatHelper.getEmoji(valueString: reactionType))
                .font(Font.regular(size: 28))
        }.onTapGesture {
            if userId == userData.userId {
                removeReaction(reaction: reactionType)
            }
        }
    }
}
