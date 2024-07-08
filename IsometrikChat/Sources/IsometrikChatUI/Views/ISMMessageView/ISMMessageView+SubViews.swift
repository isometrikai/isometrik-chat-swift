//
//  ISMMessageView+SubViews.swift
//  ISMChatSdk
//
//  Created by Rasika on 15/04/24.
//

import Foundation
import SwiftUI

extension ISMMessageView{
    
    //MARK: - GET MESSAGE VIEW
    func getMessagesView(scrollReader : ScrollViewProxy,viewWidth : CGFloat) -> some View{
        LazyVGrid(columns: columns,spacing: 0/*,pinnedViews: [.sectionHeaders]*/) {
            let sectionMessages = realmManager.messages
            ForEach(sectionMessages.indices, id: \.self){ index in
                let messages = sectionMessages[index]
                Section(header: ISMChat_Helper.sectionHeader(firstMessage: messages.first ?? MessagesDB(), color: themeColor.userProfile_sectionHeader, font: themeFonts.userProfile_sectionHeader)){
                    ForEach(messages) { message in
                        VStack{
                            if ISMChat_Helper.getMessageType(message: message) == .blockUser{
                                grpHeader(action: .userBlock, userName: message.userName, senderId: message.initiatorIdentifier)
                            }else if ISMChat_Helper.getMessageType(message: message) == .unblockUser{
                                grpHeader(action: .userUnblock, userName: message.userName, senderId: message.initiatorIdentifier)
                            }else if ISMChat_Helper.getMessageType(message: message) == .conversationTitleUpdate{
                                grpHeader(action: .conversationTitleUpdated, userName: message.userId == userSession.getUserId() ? ConstantStrings.you : message.userName, senderId: message.initiatorIdentifier)
                            }else if ISMChat_Helper.getMessageType(message: message) == .conversationImageUpdated{
                                grpHeader(action: .conversationImageUpdated, userName: message.userId == userSession.getUserId() ? ConstantStrings.you : message.userName, senderId: message.initiatorIdentifier)
                            }else if ISMChat_Helper.getMessageType(message: message) == .conversationCreated{
                                grpHeader(action: .conversationCreated, userName: message.userId == userSession.getUserId() ? ConstantStrings.you :  message.userName, senderId: message.initiatorIdentifier,isGroup : conversationDetail?.conversationDetails?.isGroup)
                            }else if ISMChat_Helper.getMessageType(message: message) == .membersAdd{
                                grpHeader(action: .membersAdd, userName: message.userId == userSession.getUserId() ? ConstantStrings.you : message.userName, senderId: message.initiatorIdentifier,member: message.members.last?.memberName ?? "",memberId : message.members.last?.memberIdentifier ?? "")
                            }else if ISMChat_Helper.getMessageType(message: message) == .memberLeave{
                                grpHeader(action: .memberLeave, userName: message.userId == userSession.getUserId() ? ConstantStrings.you : message.userName, senderId: message.initiatorIdentifier,member: message.members.last?.memberName ?? "",memberId : message.members.last?.memberIdentifier ?? "")
                            }else if ISMChat_Helper.getMessageType(message: message) == .membersRemove{
                                grpHeader(action: .membersRemove, userName: message.userId == userSession.getUserId() ? ConstantStrings.you : message.userName, senderId: message.initiatorIdentifier,member: message.members.last?.memberName ?? "",memberId : message.members.last?.memberIdentifier ?? "")
                            }else if ISMChat_Helper.getMessageType(message: message) == .addAdmin{
                                grpHeader(action: .addAdmin, userName: message.initiatorId == userSession.getUserId() ? ConstantStrings.you :  message.initiatorName, senderId: message.initiatorIdentifier,member: message.memberId == userSession.getUserId() ? ConstantStrings.you.lowercased() : message.memberName)
                            }else if ISMChat_Helper.getMessageType(message: message) == .removeAdmin{
                                grpHeader(action: .removeAdmin, userName: message.initiatorId == userSession.getUserId() ? ConstantStrings.you :  message.initiatorName, senderId: message.initiatorIdentifier,member: message.memberId == userSession.getUserId() ? ConstantStrings.you.lowercased() : message.memberName)
                            }else if ISMChat_Helper.getMessageType(message: message) == .conversationSettingsUpdated{
                                grpHeader(action: .conversationSettingsUpdated, userName: message.initiatorId == userSession.getUserId() ? ConstantStrings.you :  message.initiatorName, senderId: message.initiatorIdentifier,member: message.memberId == userSession.getUserId() ? ConstantStrings.you.lowercased() : message.memberName)
                            }else{
                                defaultMessageView(message: message, scrollReader: scrollReader, viewWidth: viewWidth)
                                    .onTapGesture {
                                        if showforwardMultipleMessage == true{
                                            self.forwardMessageView(message: message)
                                        }else if showDeleteMultipleMessage == true{
                                            self.deleteMsgFromView(message: message)
                                        }else {
                                            scrollToParentMessage(message: message, scrollReader: scrollReader)
                                        }
                                    }
                            }
                        }.id(message.id.description)
                            .onAppear{
                                //hide scroll to bottom button at last message
                                if message.id ==  realmManager.messages.last?.last?.id{
                                    showScrollToBottomView = false
                                }
                            }
                            .onDisappear{
                                //show scroll to bottom button if not at last message
                                if message.id.description ==  realmManager.messages.last?.last?.id.description{
                                    showScrollToBottomView = true
                                }
                            }
                    }
                }//:SECTION
            }//:ForEach
            .onAppear(perform: {
                if onLoad == true{
                    if let messageIdToScroll =  realmManager.messages.last?.last?.id.description{
                        scrollTo(messageId: messageIdToScroll, anchor: .bottom, shouldAnimate: false, scrollReader: scrollReader)
                    }
                }
            })
            .onChange(of: realmManager.parentMessageIdToScroll) { _ in
                if realmManager.parentMessageIdToScroll != ""{
                    scrollTo(messageId: realmManager.parentMessageIdToScroll,  anchor: .bottom, shouldAnimate: false, scrollReader: scrollReader)
                }
            }
            .onChange(of: parentMsgToScroll){
                //scroll to parent msg, if tap on reply message view
                if parentMsgToScroll != nil{
                    if let msg = parentMsgToScroll{
                        scrollToParentMessage(message: msg, scrollReader: scrollReader)
                        parentMsgToScroll = nil
                    }
                }
            }
            .onDisappear {
                if let previousAudioRef {
                    previousAudioRef.pauseAudio()
                    previousAudioRef.removeAudio()
                }
            }
        }//:LazyVGrid
    }
    
    func defaultMessageView(message : MessagesDB,scrollReader : ScrollViewProxy,viewWidth : CGFloat) -> some View{
        HStack{
            if showforwardMultipleMessage == true{
                multipleForwardMessageButtonView(message: message)
            }
            if showDeleteMultipleMessage == true{
                multipleDeleteMessageButtonView(message: message)
            }
            ISMMessageSubView(messageType: ISMChat_Helper.getMessageType(message: message),
                              viewWidth: viewWidth,
                              isReceived: (message.senderInfo?.userIdentifier ?? message.initiatorIdentifier) != userId,
                              messageDeliveredType: ISMChat_Helper.checkMessageDeliveryType(message: message, isGroup: self.isGroup ?? false,memberCount: realmManager.getMemberCount(convId: self.conversationID ?? "")),
                              conversationId: self.conversationID ?? "",
                              groupconversationMember: self.conversationDetail?.conversationDetails?.members ?? [],
                              opponentDeatil: (self.conversationDetail?.conversationDetails?.opponentDetails ?? ISMChat_User()),
                              isGroup:  self.isGroup,
                              fromBroadCastFlow: self.fromBroadCastFlow,
                              navigateToDeletePopUp: $showDeleteMultipleMessage,
                              selectedMessageToReply: $selectedMsgToReply,
                              messageCopied: $messageCopied,
                              previousAudioRef: $previousAudioRef,
                              updateMessage: $updateMessage,
                              showForward: $showforwardMultipleMessage,
                              navigateToLocationDetail: $navigateToLocationDetail,
                              selectedReaction:  $selectedReaction,
                              sentRecationToMessageId: $sentRecationToMessageId,
                              audioCallToUser: $audioCallToUser,
                              videoCallToUser: $videoCallToUser,
                              parentMsgToScroll: $parentMsgToScroll,
                              message: message) .environmentObject(self.realmManager)
               
        }
    }
    
    //MARK: - GROUP HEADERS
    func grpHeader(action: ISMChat_ActionType, userName: String, senderId: String,member : String? = nil,memberId : String? = nil,isGroup : Bool? = true) -> some View {
        ZStack {
            let userId = userSession.getEmailId()
            if action == .userBlock{
                let text = senderId == userId ? "You blocked this user" : "You are blocked"
                customText(text: text)
            }else if action == .userUnblock{
                let text = senderId == userId ? "You unblocked this user" : "You are unblocked"
                customText(text: text)
            }else if action == .conversationTitleUpdated{
                let text = senderId == userId ? "You changed this group title" : "\(userName) changed this group title"
                customText(text: text)
            }else if action == .conversationImageUpdated{
                let text = senderId == userId ? "You changed this group image" : "\(userName) changed this group image"
                customText(text: text)
            }else if action == .conversationCreated{
                if isGroup == false{
                    let text = "Messages are end to end encrypted. No one \noutside of this chat can read to them."
                    customText(text: text)
                }else{
                    let text = senderId == userId ? "You created group" : "\(userName) created group"
                    customText(text: text)
                }
            }else if action == .membersAdd{
                let memberName = memberId == userId ? ConstantStrings.you.lowercased() : "\(member ?? "")"
                let text = senderId == userId ? "You added \(member ?? "")" : "\(userName) added \(memberName)"
                customText(text: text)
            }else if action == .memberLeave{
                let text = senderId == userId ? "You has left" : "\(userName) has left"
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
                let text = senderId == userId ? "You updated notifications setting" : "\(userName) updated notifications setting"
                customText(text: text)
            }
        }
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
    }
    
    func customText(text : String) -> some View{
        HStack{
            Text(text)
                .foregroundColor(themeColor.messageList_ActionText)
                .font(themeFonts.messageList_ActionText)
                .frame(width: text.widthOfString(usingFont: UIFont.regular(size: 14)) + 20)
                .padding(.vertical, 5)
                .background(themeColor.messageList_ActionBackground)
                .cornerRadius(5)
        }
    }
}
