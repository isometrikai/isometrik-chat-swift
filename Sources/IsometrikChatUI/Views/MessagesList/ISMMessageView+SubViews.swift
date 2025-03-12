//
//  ISMMessageView+SubViews.swift
//  ISMChatSdk
//
//  Created by Rasika on 15/04/24.
//

import Foundation
import SwiftUI
import IsometrikChat

extension ISMMessageView{
    
    //MARK: - GET MESSAGE VIEW
    /// Generates the view for displaying messages in a grid format.
    /// - Parameters:
    ///   - scrollReader: A proxy for scrolling the view.
    ///   - viewWidth: The width of the view.
    /// - Returns: A view containing the messages.
    func getMessagesView(scrollReader: ScrollViewProxy, viewWidth: CGFloat) -> some View {
        LazyVGrid(columns: columns, spacing: 0) {
            let sectionMessages = viewModelNew.messages

            ForEach(Array(sectionMessages.enumerated()), id: \.offset) { index, messages in
                if let firstMessage = messages.first {
                    Section(
                        header: sectionHeader(
                            firstMessage: firstMessage,
                            color: appearance.colorPalette.userProfileSectionHeader,
                            font: appearance.fonts.messageListSectionHeaderText
                        )
                    ) {
                        ForEach(messages, id: \.id) { message in
                            VStack {
                                getMessageView(for: message, scrollReader: scrollReader, viewWidth: viewWidth)
                            }
                            .id(message.id.description)
                            .onAppear { handleOnAppear(for: message) }
                            .onDisappear { handleOnDisappear(for: message) }
                        }
                    }
                }
            }
        }
        .onAppear { handleInitialScroll(scrollReader) }
        .onChange(of: parentMessageIdToScroll) { _, _ in handleParentMessageScroll(scrollReader) }
        .onChange(of: parentMsgToScroll) { _, _ in handleReplyMessageScroll(scrollReader) }
    }
    
    @ViewBuilder
    func getMessageView(for message: ISMChatMessagesDB, scrollReader: ScrollViewProxy, viewWidth: CGFloat) -> some View {
        switch ISMChatHelper.getMessageType(message: message) {
        case .blockUser:
            grpHeader(action: .userBlock, userName: message.userName, senderId: message.initiatorId)
        case .unblockUser:
            grpHeader(action: .userUnblock, userName: message.userName, senderId: message.initiatorId)
        case .conversationTitleUpdate:
            grpHeader(action: .conversationTitleUpdated, userName: message.userId == userData?.userId ? ConstantStrings.you : message.userName, senderId: message.initiatorId)
        case .conversationImageUpdated:
            grpHeader(action: .conversationImageUpdated, userName: message.userId == userData?.userId ? ConstantStrings.you : message.userName, senderId: message.initiatorId)
        case .conversationCreated:
            grpHeader(action: .conversationCreated, userName: message.userId == userData?.userId ? ConstantStrings.you : message.userName, senderId: message.initiatorId, isGroup: conversationDetail?.conversationDetails?.isGroup)
        case .membersAdd:
            grpHeader(action: .membersAdd, userName: message.userId == userData?.userId ? ConstantStrings.you : message.userName, senderId: message.initiatorId, member: message.members?.last?.memberName ?? "", memberId: message.members?.last?.memberIdentifier ?? "")
        case .memberLeave:
            grpHeader(action: .memberLeave, userName: message.userId == userData?.userId ? ConstantStrings.you : message.userName, senderId: message.initiatorId, member: message.members?.last?.memberName ?? "", memberId: message.members?.last?.memberIdentifier ?? "")
        case .membersRemove:
            grpHeader(action: .membersRemove, userName: message.userId == userData?.userId ? ConstantStrings.you : message.userName, senderId: message.initiatorId, member: message.members?.last?.memberName ?? "", memberId: message.members?.last?.memberIdentifier ?? "")
        case .addAdmin:
            grpHeader(action: .addAdmin, userName: message.initiatorId == userData?.userId ? ConstantStrings.you : message.initiatorName, senderId: message.initiatorId, member: message.memberId == userData?.userId ? ConstantStrings.you.lowercased() : message.memberName)
        case .removeAdmin:
            grpHeader(action: .removeAdmin, userName: message.initiatorId == userData?.userId ? ConstantStrings.you : message.initiatorName, senderId: message.initiatorId, member: message.memberId == userData?.userId ? ConstantStrings.you.lowercased() : message.memberName)
        case .conversationSettingsUpdated:
            grpHeader(action: .conversationSettingsUpdated, userName: message.initiatorId == userData?.userId ? ConstantStrings.you : message.initiatorName, senderId: message.initiatorId, member: message.memberId == userData?.userId ? ConstantStrings.you.lowercased() : message.memberName)
        default:
            defaultMessageView(message: message, scrollReader: scrollReader, viewWidth: viewWidth)
                .onTapGesture { handleTapGesture(for: message, scrollReader: scrollReader) }
        }
    }
    
    func handleOnAppear(for message: ISMChatMessagesDB) {
        if message.id == viewModelNew.messages.last?.last?.id {
            stateViewModel.showScrollToBottomView = false
        }
    }

    func handleOnDisappear(for message: ISMChatMessagesDB) {
        if message.id.description == viewModelNew.messages.last?.last?.id.description {
            stateViewModel.showScrollToBottomView = true
        }
    }

    func handleInitialScroll(_ scrollReader: ScrollViewProxy) {
        if stateViewModel.onLoad {
            if let messageIdToScroll = viewModelNew.messages.last?.last?.id.description {
                scrollTo(messageId: messageIdToScroll, anchor: .bottom, shouldAnimate: false, scrollReader: scrollReader)
            }
        }
    }

    func handleParentMessageScroll(_ scrollReader: ScrollViewProxy) {
        if !parentMessageIdToScroll.isEmpty {
            scrollTo(messageId: parentMessageIdToScroll, anchor: .bottom, shouldAnimate: false, scrollReader: scrollReader)
        }
    }

    func handleReplyMessageScroll(_ scrollReader: ScrollViewProxy) {
        if let msg = parentMsgToScroll {
            scrollToParentMessage(message: msg, scrollReader: scrollReader)
            parentMsgToScroll = nil
        }
    }
    
    func handleTapGesture(for message: ISMChatMessagesDB,scrollReader : ScrollViewProxy) {
        if stateViewModel.showforwardMultipleMessage {
            forwardMessageView(message: message)
        } else if stateViewModel.showDeleteMultipleMessage {
            deleteMsgFromView(message: message)
        } else {
            scrollToParentMessage(message: message, scrollReader: scrollReader)
        }
    }




    
    /// Displays the default message view for a given message.
    /// - Parameters:
    ///   - message: The message to display.
    ///   - scrollReader: A proxy for scrolling the view.
    ///   - viewWidth: The width of the view.
    /// - Returns: A view representing the default message.
    func defaultMessageView(message : ISMChatMessagesDB,scrollReader : ScrollViewProxy,viewWidth : CGFloat) -> some View{
        HStack{
            // Show forward button if applicable
            if stateViewModel.showforwardMultipleMessage == true && (ISMChatHelper.getMessageType(message: message) != .AudioCall && ISMChatHelper.getMessageType(message: message) != .VideoCall){
                multipleForwardMessageButtonView(message: message)
            }
            // Show delete button if applicable
            if ISMChatSdkUI.getInstance().getChatProperties().multipleSelectionOfMessageForDelete == true{
                if stateViewModel.showDeleteMultipleMessage == true{
                    multipleDeleteMessageButtonView(message: message)
                }
            }
            ISMMessageSubView(messageType: ISMChatHelper.getMessageType(message: message),
                              viewWidth: viewWidth,
                              isReceived: getIsReceived(message: message),
                              messageDeliveredType: ISMChatHelper.checkMessageDeliveryType(message: message, isGroup: self.isGroup ?? false,memberCount: /*realmManager.getMemberCount(convId: self.conversationID ?? "")*/0, isOneToOneGroup: ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup),
                              conversationId: self.conversationID ?? "",
                              groupconversationMember: self.conversationDetail?.conversationDetails?.members ?? [],
                              opponentDeatil: (self.conversationDetail?.conversationDetails?.opponentDetails ?? ISMChatUser()),
                              isGroup:  self.isGroup,
                              fromBroadCastFlow: self.fromBroadCastFlow,
                              navigateToDeletePopUp: chatProperties.multipleSelectionOfMessageForDelete == true ? $stateViewModel.showDeleteMultipleMessage : $stateViewModel.showDeleteSingleMessage,
                              selectedMessageToReply: $selectedMsgToReply,
                              messageCopied: $stateViewModel.messageCopied,
                              previousAudioRef: $previousAudioRef,
                              updateMessage: $updateMessage,
                              forwardMessageSelected: $forwardMessageSelectedToShow,
                              navigateToLocationDetail: $navigateToLocationDetail,
                              selectedReaction:  $selectedReaction,
                              sentRecationToMessageId: $sentRecationToMessageId,
                              audioCallToUser: $stateViewModel.audioCallToUser,
                              videoCallToUser: $stateViewModel.videoCallToUser,
                              parentMsgToScroll: $parentMsgToScroll,
                              navigateToMediaSliderId: $navigateToMediaSliderId, navigateToDocumentUrl: $navigateToDocumentUrl, deleteMessage: $deleteMessage,
                              message: message, 
                              postIdToNavigate: $postIdToNavigate,
                              productIdToNavigate: $productIdToNavigate,
                              navigateToSocialProfileId: $navigateToSocialProfileId,
                              navigateToExternalUserListToAddInGroup: $stateViewModel.navigateToAddParticipantsInGroupViaDelegate,
                              navigateToProductLink: $navigateToProductLink,
                              navigateToSocialLink: $navigateToSocialLink,
                              navigateToCollectionLink: $navigateToCollectionLink,
                              viewDetailsForPaymentRequest: $viewDetailsForPaymentRequest,
                              declinePaymentRequest: $declinePaymentRequest,
                              showInviteeListInDineInRequest: $showInviteeListInDineInRequest)
//            .environmentObject(self.realmManager)
        }
    }
    
    
    func getIsReceived(message: ISMChatMessagesDB) -> Bool {
        if self.fromBroadCastFlow == true {
            return false
        }
        
        guard let senderInfo = message.senderInfo else {
            print("Warning: senderInfo is nil or invalid")
            return false // Or handle it accordingly
        }
        
        return senderInfo.userId != myUserId
    }

    
    //MARK: - GROUP HEADERS
    func grpHeader(action: ISMChatActionType, userName: String, senderId: String,member : String? = nil,memberId : String? = nil,isGroup : Bool? = true) -> some View {
        ZStack {
            let userId = userData?.userId
            if action == .userBlock{
                let text = senderId == userId ? "You blocked this user" : "youAreBlocked".localized()
                customText(text: text)
            }else if action == .userUnblock{
                let text = senderId == userId ? "You unblocked this user".localized() : "youAreUnblocked".localized()
                customText(text: text)
            }else if action == .conversationTitleUpdated{
                let text = senderId == userId ? "You changed this group title".localized() : "\(userName) changed this group title".localized()
                customText(text: text)
            }else if action == .conversationImageUpdated{
                let text = senderId == userId ? "You changed this group image".localized() : "\(userName) changed this group image".localized()
                customText(text: text)
            }else if action == .conversationCreated{
                if let isGroup = isGroup{
                    if isGroup == false{
                        let text = appearance.constantStrings.endToEndEncrypted
                        customTextWithImage(text: text, image: appearance.images.messageLock)
                    }else{
                        let text = senderId == userId ? "You created group".localized() : "\(userName) created group"
                        customText(text: text)
                    }
                }else{
                    let text = appearance.constantStrings.endToEndEncrypted
                    customTextWithImage(text: text, image: appearance.images.messageLock)
                }
            }else if action == .membersAdd{
                let memberName = memberId == userId ? ConstantStrings.you.lowercased() : "\(member ?? "")"
                let text = senderId == userId ? "You added \(member ?? "")" : "\(userName) added \(memberName)"
                customText(text: text)
            }else if action == .memberLeave{
                let text = senderId == userId ? "You has left".localized() : "\(userName) has left"
                customText(text: text)
            }else if action == .membersRemove{
                let memberName = memberId == userId ? ConstantStrings.you.lowercased() : "\(member ?? "")"
                let text = senderId == userName ? "You removed \(member ?? "")" : "\(userName) removed \(memberName)"
                customText(text: text)
            }else if action == .addAdmin{
                let text = "\(userName) added \(member ?? "") as an Admin"
                customText(text: text)
            }else if action == .removeAdmin{
                let text = "\(userName) removed \(member ?? "") as an Admin"
                customText(text: text)
            }else if action == .conversationSettingsUpdated{
                let text = senderId == userId ? "You updated notifications setting".localized() : "\(userName) updated notifications setting"
                customText(text: text)
            }
        }
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
    }
    
     func sectionHeader(firstMessage message : ISMChatMessagesDB,color : Color,font : Font) -> some View{
        let sentAt = message.sentAt
        let date = NSDate().descriptiveStringLastSeen(time: sentAt,isSectionHeader: true)
         return ZStack{
             Text(ISMChatSdkUI.getInstance().getChatProperties().captializeMessageListHeaders ? date.uppercased() :  date)
                .foregroundColor(color)
                .font(font)
            
        }//:ZStack
        .frame(width: date.widthOfString(usingFont: UIFont.regular(size: 14)) + 20)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(appearance.colorPalette.messageListActionBackground)
        )
        .cornerRadius(5)
    }
    
    func customText(text : String) -> some View{
        HStack{
            Text(text)
                .foregroundColor(appearance.colorPalette.messageListActionText)
                .font(appearance.fonts.messageListActionText)
                .frame(width: text.widthOfString(usingFont: UIFont.regular(size: 14)) + 20)
                .padding(.vertical, 5)
                .background(appearance.colorPalette.messageListActionBackground)
                .cornerRadius(5)
        }
    }
    
    func customTextWithImage(text : String, image : Image) -> some View{
        let screenWidth = UIScreen.main.bounds.width - 60
        return HStack(alignment: .top,spacing: 5){
            image
                .resizable()
                .frame(width: 10,height: 13)
                .foregroundColor(appearance.colorPalette.messageListActionText)
                .padding(.top,2)
            Text(text)
                .multilineTextAlignment(.center)
                .foregroundColor(appearance.colorPalette.messageListActionText)
                .font(appearance.fonts.messageListActionText)
                
        }.frame(width: screenWidth)
            .padding(.vertical, 5)
            .background(appearance.colorPalette.messageListActionBackground)
            .cornerRadius(5)
    }
}
