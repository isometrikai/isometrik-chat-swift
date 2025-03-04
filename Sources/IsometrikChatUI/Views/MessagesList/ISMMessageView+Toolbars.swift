//
//  ISMMessageView+Toolbars.swift
//  ISMChatSdk
//
//  Created by Rasika on 15/04/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import IsometrikChat

extension ISMMessageView{
    
    // Function to display a toolbar message indicating the user is no longer a member of the group
    func NoLongerMemberToolBar() -> some View{
        VStack{
            HStack{
                Text("You can't send messages to this group because you're no longer a member.")
                    .foregroundColor(appearance.colorPalette.messageListTextViewPlaceholder)
                    .font(appearance.fonts.messageListMessageText)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical,10)
            .padding(.horizontal,20)
        }
        .frame(height: 80)
        .background(appearance.colorPalette.messageListToolBarBackground)
    }
    
    // Function to determine which toolbar to display based on the current state
//    func toolBarView() -> some View {
//        Group {
//            switch toolbarState {
//            case .mention:
//                MentionUserList(showMentionList: $stateViewModel.showMentionList,filteredUsers: $filteredUsers, mentionUsers: $mentionUsers, textFieldtxt: $textFieldtxt)
//            case .forward:
//                ForwardMessageToolBar(forwardMessageSelected: $forwardMessageSelected,movetoForwardList: $stateViewModel.movetoForwardList) {
//                    self.stateViewModel.showforwardMultipleMessage = false
//                    self.delegate?.navigateToUserListToForward(messages: forwardMessageSelected)
//                }
//            case .delete:
//                DelegateMessageToolBar(deleteMessage: $deleteMessage,showDeleteActionSheet: $stateViewModel.showDeleteActionSheet)
//            case .normal:
//                BasicToolBarView(textFieldtxt: $textFieldtxt, selectedMsgToReply: $selectedMsgToReply, parentMessageIdToScroll: $parentMessageIdToScroll, audioLocked: $stateViewModel.audioLocked, isClicked: $stateViewModel.isClicked, uAreBlock: $stateViewModel.uAreBlock, showUnblockPopUp: $stateViewModel.showUnblockPopUp, isShowingRedTimerStart: $stateViewModel.isShowingRedTimerStart, showActionSheet: $stateViewModel.showActionSheet, showGifPicker: $stateViewModel.showGifPicker,audioPermissionCheck: $audioPermissionCheck,keyboardFocused: $stateViewModel.keyboardFocused) {
//                    sendMessage(msgType: .text)
//                }.environmentObject(self.realmManager)
//                    .environmentObject(self.chatViewModel)
//            }
//        }
//    }
    // Computed property to determine the current state of the toolbar
    var toolbarState: ToolbarState {
        if stateViewModel.showMentionList && isGroup == true && !filteredUsers.isEmpty { return .mention }
        if stateViewModel.showforwardMultipleMessage { return .forward }
        if stateViewModel.showDeleteMultipleMessage && chatProperties.customMenu == false { return .delete }
        return .normal
    }

    
    
    // Function to check if the user has the option to allow messaging based on their profile type and conversation details
    func showOptionToAllow() -> Bool {
        let myProfileType = userData?.userProfileType
        let userId = userData?.userId
        
        // Ensure conversation detail is available
        guard let conversation = conversationDetail?.conversationDetails else {
            return false
        }

        // Check if the current user is not the one who created the conversation
        if conversation.createdBy != userId {
            switch myProfileType {
            case ISMChatUserProfileType.NormalUser.value:
                return false
                
            case ISMChatUserProfileType.Influencer.value:
                if conversation.opponentDetails?.metaData?.userType == 1 && conversation.opponentDetails?.metaData?.isStarUser != true &&
                    conversation.metaData?.chatStatus != ISMChatStatus.Reject.value {
                    return true
                } else {
                    return false
                }
                
            case ISMChatUserProfileType.Bussiness.value:
                if conversation.opponentDetails?.metaData?.userType == 1 &&
                    conversation.metaData?.chatStatus != ISMChatStatus.Reject.value {
                    return true
                } else {
                    return false
                }
                
            default:
                return false
            }
        }
        
        return false
    }
    
    // Function to display the accept/reject view for message requests
    func acceptRejectView() -> some View{
        VStack{
            Divider()
            Text("Accept message request from \(self.opponenDetail?.userName ?? "")?")
                .font(appearance.fonts.messageListMessageText)
                .foregroundColor(appearance.colorPalette.chatListUserName)
                .padding(.top,34)
                .padding(.horizontal,15)
                .padding(.bottom,10)
                .multilineTextAlignment(.leading)
                
            Text("If you accept, you both can see information such as when you've read messages.")
                .font(appearance.fonts.messageListMessageText)
                .foregroundColor(appearance.colorPalette.chatListUserMessage)
                .padding(.horizontal,15)
                .padding(.bottom,29)
                .multilineTextAlignment(.leading)
            
            HStack(spacing: 14){
                Button {
                    presentationMode.wrappedValue.dismiss()
                    // Dismiss the view without taking action
//                    self.messageVCDelegate?.navigateBack(isFromProfile: self.fromProfile ?? false, isfromBroadcast: self.fromBroadCastFlow ?? false)
                } label: {
                    Text("Reject")
                        .font(appearance.fonts.navigationBarTitle)
                        .foregroundColor(appearance.colorPalette.chatListUnreadMessageCountBackground)
                        .frame(maxWidth: .infinity, minHeight: 49)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(appearance.colorPalette.chatListUnreadMessageCountBackground, lineWidth: 1)
                        )
                }
                
                Button {
                    // Call API to accept the message request
                    chatViewModel.acceptRequestToAllowMessage(conversationId: self.conversationID ?? "", completion: { _ in
                        NotificationCenter.default.post(name: NSNotification.refreshConvList,object: nil)
                        getConversationDetail()
                    })
                } label: {
                    Text("Accept")
                        .font(appearance.fonts.navigationBarTitle)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 49)
                        .background(appearance.colorPalette.chatListUnreadMessageCountBackground)
                        .cornerRadius(10)
                }
                
            }.padding(.horizontal,20)
        }
    }
}
