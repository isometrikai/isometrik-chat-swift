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
    let message : MessagesDB // The message object containing reaction data
    let groupconversationMember : [ISMChatGroupMember] // Members of the group conversation
    let isGroup : Bool // Flag to determine if the conversation is a group chat
    let opponentDeatil : ISMChatUser // Details of the opponent user
    @State private var selectedTab: Int = 0 // Tracks the currently selected tab
    @State private var allReactions : [String : [String]] = [:] // Dictionary to hold reactions and their corresponding users
    var viewModel = ChatsViewModel() // ViewModel for chat operations
    @Binding var showReactionDetail : Bool // Binding to control the visibility of the reaction detail view
    @Binding var reactionRemoved : String // Binding to track the removed reaction
    @EnvironmentObject var realmManager : RealmManager // Environment object for managing Realm database
    var userData = ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig // User configuration data
    
    //MARK:  - LIFECYCLE
    var body: some View {
        VStack {
            // Horizontal scroll view for tab buttons representing reactions
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    // Button for "All" reactions
                    Button(action: {
                        selectedTab = 0 // Set selected tab to "All"
                    }) {
                        VStack{
                            Spacer()
                            let count = message.reactions.count // Count of total reactions
                            Text("All \(count)")
                                .foregroundColor(Color(hex: "#294566"))
                                .font(Font.regular(size: 18))
                            Spacer()
                            // Highlight the button if selected
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
                    // Buttons for each reaction type
                    ForEach(message.reactions.indices, id: \.self) { index in
                        Button(action: {
                            selectedTab = index + 1 // Set selected tab to the corresponding reaction
                        }) {
                            let emoji = ISMChatHelper.getEmoji(valueString: message.reactions[index].reactionType) // Get emoji for the reaction
                            VStack{
                                Spacer()
                                Text(emoji)
                                    .foregroundColor(Color(hex: "#294566"))
                                    .font(Font.regular(size: 18))
                                Spacer()
                                // Highlight the button if selected
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
            
            // Display reactions based on the selected tab
            if selectedTab == 0 {
                List {
                    // List all reactions
                    ForEach(Array(allReactions.keys), id: \.self) { reactionType in
                        ForEach(allReactions[reactionType] ?? [], id: \.self) { user in
                            // Display user subview based on group or individual chat
                            if isGroup == true{
                                subViewForGroup(userId: user, reactionType: reactionType)
                            }else{
                                subView(userId: user,
                                        profilePicture: user == userData?.userId ? (userData?.userProfileImage ?? "") : (opponentDeatil.userProfileImageUrl ?? ""),
                                        userName: user == userData?.userId ? (userData?.userName ?? "") : (opponentDeatil.userName ?? ""),
                                        userIdentifier: opponentDeatil.userIdentifier ?? "",
                                        reactionType: reactionType)
                            }
                        }
                    }
                }.listStyle(.plain)
            } else {
                List {
                    // List users who reacted with the selected reaction
                    ForEach(Array(message.reactions[selectedTab - 1].users), id: \.self) { item in
                        if isGroup == true{
                            subViewForGroup(userId: item, reactionType: message.reactions[selectedTab - 1].reactionType)
                        }else{
                            subView(userId: item, profilePicture: item == userData?.userId ? (userData?.userProfileImage ?? "") : (opponentDeatil.userProfileImageUrl ?? ""),
                                    userName: opponentDeatil.userName ?? "",
                                    userIdentifier: opponentDeatil.userIdentifier ?? "",
                                    reactionType: message.reactions[selectedTab - 1].reactionType)
                        }
                    }
                }.listStyle(.plain)
            }
            Spacer()
        }.onAppear(perform: {
            // Populate allReactions dictionary when the view appears
            for reaction in message.reactions {
                let usersArray = Array(reaction.users) // Convert users set to array
                if var users = allReactions[reaction.reactionType] {
                    users.append(contentsOf: usersArray) // Append users to existing array
                    allReactions[reaction.reactionType] = users
                } else {
                    allReactions[reaction.reactionType] = usersArray // Create new entry for the reaction type
                }
            }
        })
    }
    
    //MARK: - CONFIGURE
    // Function to remove a reaction
    func removeReaction(reaction : String){
        viewModel.removeReaction(conversationId: self.message.conversationId, messageId: self.message.messageId, emojiReaction: reaction) { _ in
            reactionRemoved = reaction // Update the removed reaction
            showReactionDetail = false // Hide the reaction detail view
            // Log the action in the database
            realmManager.addLastMessageOnAddAndRemoveReaction(conversationId: self.message.conversationId, action: ISMChatActionType.reactionRemove.value, emoji: reaction, userId: userData?.userId ?? "")
        }
    }
    
    // Subview for displaying user information in individual chat
    func subView(userId : String, profilePicture : String, userName : String,userIdentifier : String,reactionType : String) -> some View{
        HStack {
            UserAvatarView(avatar: profilePicture, showOnlineIndicator: false, size: CGSize(width: 38, height: 38), userName: userName, font: .regular(size: 14))
            VStack(alignment: .leading) {
                Text(userId == userData?.userId ? ConstantStrings.you : userName)
                    .font(Font.regular(size: 16))
                    .foregroundColor(Color(hex: "#294566"))
                Text(userId == userData?.userId ? ConstantStrings.tapToRemove : userIdentifier)
                    .font(Font.regular(size: 12))
                    .foregroundColor(Color(hex: "#9EA4C3"))
            }
            Spacer()
            Text(ISMChatHelper.getEmoji(valueString: reactionType))
                .font(Font.regular(size: 28))
        }.onTapGesture {
            // Remove reaction if the user taps on their own reaction
            if userId == userData?.userId {
                removeReaction(reaction: reactionType)
            }
        }
    }
    
    // Subview for displaying group member information
    func subViewForGroup(userId : String,reactionType : String) -> some View{
        HStack {
            let groupMember = groupconversationMember.first { member in
                member.userId == userId // Find the group member by user ID
            }
            UserAvatarView(avatar: groupMember?.userProfileImageUrl ?? "", showOnlineIndicator: false, size: CGSize(width: 38, height: 38), userName: groupMember?.userName ?? "", font: .regular(size: 14))
            VStack(alignment: .leading) {
                Text(groupMember?.userId == userData?.userId ? ConstantStrings.you : (groupMember?.userName ?? ""))
                    .font(Font.regular(size: 16))
                    .foregroundColor(Color(hex: "#294566"))
                Text(groupMember?.userId == userData?.userId ? ConstantStrings.tapToRemove : (groupMember?.userIdentifier ?? ""))
                    .font(Font.regular(size: 12))
                    .foregroundColor(Color(hex: "#9EA4C3"))
            }
            Spacer()
            Text(ISMChatHelper.getEmoji(valueString: reactionType))
                .font(Font.regular(size: 28))
        }.onTapGesture {
            // Remove reaction if the user taps on their own reaction
            if userId == userData?.userId {
                removeReaction(reaction: reactionType)
            }
        }
    }
}
