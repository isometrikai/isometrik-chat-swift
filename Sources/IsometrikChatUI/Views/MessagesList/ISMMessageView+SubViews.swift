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
    func getMessagesView(scrollReader : ScrollViewProxy,viewWidth : CGFloat) -> some View{
        LazyVGrid(columns: columns,spacing: 0/*,pinnedViews: [.sectionHeaders]*/) {
            let sectionMessages = realmManager.messages
            ForEach(sectionMessages.indices, id: \.self){ index in
                let messages = sectionMessages[index]
                Section(header: sectionHeader(firstMessage: messages.first ?? MessagesDB(), color: appearance.colorPalette.userProfileSectionHeader, font: appearance.fonts.messageListSectionHeaderText)){
                    ForEach(messages) { message in
                        VStack{
                            if ISMChatHelper.getMessageType(message: message) == .blockUser{
                                grpHeader(action: .userBlock, userName: message.userName, senderId: message.initiatorId)
                            }else if ISMChatHelper.getMessageType(message: message) == .unblockUser{
                                grpHeader(action: .userUnblock, userName: message.userName, senderId: message.initiatorId)
                            }else if ISMChatHelper.getMessageType(message: message) == .conversationTitleUpdate{
                                grpHeader(action: .conversationTitleUpdated, userName: message.userId == userData?.userId ? ConstantStrings.you : message.userName, senderId: message.initiatorId)
                            }else if ISMChatHelper.getMessageType(message: message) == .conversationImageUpdated{
                                grpHeader(action: .conversationImageUpdated, userName: message.userId == userData?.userId ? ConstantStrings.you : message.userName, senderId: message.initiatorId)
                            }else if ISMChatHelper.getMessageType(message: message) == .conversationCreated{
                                grpHeader(action: .conversationCreated, userName: message.userId == userData?.userId ? ConstantStrings.you :  message.userName, senderId: message.initiatorId,isGroup : conversationDetail?.conversationDetails?.isGroup)
                            }else if ISMChatHelper.getMessageType(message: message) == .membersAdd{
                                grpHeader(action: .membersAdd, userName: message.userId == userData?.userId ? ConstantStrings.you : message.userName, senderId: message.initiatorId,member: message.members.last?.memberName ?? "",memberId : message.members.last?.memberIdentifier ?? "")
                            }else if ISMChatHelper.getMessageType(message: message) == .memberLeave{
                                grpHeader(action: .memberLeave, userName: message.userId == userData?.userId ? ConstantStrings.you : message.userName, senderId: message.initiatorId,member: message.members.last?.memberName ?? "",memberId : message.members.last?.memberIdentifier ?? "")
                            }else if ISMChatHelper.getMessageType(message: message) == .membersRemove{
                                grpHeader(action: .membersRemove, userName: message.userId == userData?.userId ? ConstantStrings.you : message.userName, senderId: message.initiatorId,member: message.members.last?.memberName ?? "",memberId : message.members.last?.memberIdentifier ?? "")
                            }else if ISMChatHelper.getMessageType(message: message) == .addAdmin{
                                grpHeader(action: .addAdmin, userName: message.initiatorId == userData?.userId ? ConstantStrings.you :  message.initiatorName, senderId: message.initiatorId,member: message.memberId == userData?.userId ? ConstantStrings.you.lowercased() : message.memberName)
                            }else if ISMChatHelper.getMessageType(message: message) == .removeAdmin{
                                grpHeader(action: .removeAdmin, userName: message.initiatorId == userData?.userId ? ConstantStrings.you :  message.initiatorName, senderId: message.initiatorId,member: message.memberId == userData?.userId ? ConstantStrings.you.lowercased() : message.memberName)
                            }else if ISMChatHelper.getMessageType(message: message) == .conversationSettingsUpdated{
                                grpHeader(action: .conversationSettingsUpdated, userName: message.initiatorId == userData?.userId ? ConstantStrings.you :  message.initiatorName, senderId: message.initiatorId,member: message.memberId == userData?.userId ? ConstantStrings.you.lowercased() : message.memberName)
                            }else{
                                defaultMessageView(message: message, scrollReader: scrollReader, viewWidth: viewWidth)
                                    .onTapGesture {
                                        if stateViewModel.showforwardMultipleMessage == true{
                                            self.forwardMessageView(message: message)
                                        }else if stateViewModel.showDeleteMultipleMessage == true{
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
                                    stateViewModel.showScrollToBottomView = false
                                }
                            }
                            .onDisappear{
                                //show scroll to bottom button if not at last message
                                if message.id.description ==  realmManager.messages.last?.last?.id.description{
                                    stateViewModel.showScrollToBottomView = true
                                }
                            }
                    }
                }//:SECTION
            }//:ForEach
            .onAppear(perform: {
                if stateViewModel.onLoad == true{
                    if let messageIdToScroll =  realmManager.messages.last?.last?.id.description{
                        scrollTo(messageId: messageIdToScroll, anchor: .bottom, shouldAnimate: false, scrollReader: scrollReader)
                    }
                }
            })
            .onChange(of: parentMessageIdToScroll, { _, _ in
                if parentMessageIdToScroll != ""{
                    scrollTo(messageId: parentMessageIdToScroll,  anchor: .bottom, shouldAnimate: false, scrollReader: scrollReader)
                }
            })
            .onChange(of: parentMsgToScroll, { _, _ in
                //scroll to parent msg, if tap on reply message view
                if parentMsgToScroll != nil{
                    if let msg = parentMsgToScroll{
                        scrollToParentMessage(message: msg, scrollReader: scrollReader)
                        parentMsgToScroll = nil
                    }
                }
            })
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
            if stateViewModel.showforwardMultipleMessage == true && (ISMChatHelper.getMessageType(message: message) != .AudioCall && ISMChatHelper.getMessageType(message: message) != .VideoCall){
                multipleForwardMessageButtonView(message: message)
            }
            if stateViewModel.showDeleteMultipleMessage == true{
                multipleDeleteMessageButtonView(message: message)
            }
            ISMMessageSubView(messageType: ISMChatHelper.getMessageType(message: message),
                              viewWidth: viewWidth,
                              isReceived: getIsReceived(message: message),
                              messageDeliveredType: ISMChatHelper.checkMessageDeliveryType(message: message, isGroup: self.isGroup ?? false,memberCount: realmManager.getMemberCount(convId: self.conversationID ?? ""), isOneToOneGroup: ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup),
                              conversationId: self.conversationID ?? "",
                              groupconversationMember: self.conversationDetail?.conversationDetails?.members ?? [],
                              opponentDeatil: (self.conversationDetail?.conversationDetails?.opponentDetails ?? ISMChatUser()),
                              isGroup:  self.isGroup,
                              fromBroadCastFlow: self.fromBroadCastFlow,
                              navigateToDeletePopUp: $stateViewModel.showDeleteMultipleMessage,
                              selectedMessageToReply: $selectedMsgToReply,
                              messageCopied: $stateViewModel.messageCopied,
                              previousAudioRef: $previousAudioRef,
                              updateMessage: $updateMessage,
                              showForward: $stateViewModel.showforwardMultipleMessage,
                              navigateToLocationDetail: $navigateToLocationDetail,
                              selectedReaction:  $selectedReaction,
                              sentRecationToMessageId: $sentRecationToMessageId,
                              audioCallToUser: $stateViewModel.audioCallToUser,
                              videoCallToUser: $stateViewModel.videoCallToUser,
                              parentMsgToScroll: $parentMsgToScroll,
                              navigateToMediaSliderId: $navigateToMediaSliderId, navigateToDocumentUrl: $navigateToDocumentUrl,
                              message: message, 
                              postIdToNavigate: $postIdToNavigate,
                              productIdToNavigate: $productIdToNavigate, navigateToSocialProfileId: $navigateToSocialProfileId, navigateToExternalUserListToAddInGroup: $stateViewModel.navigateToAddParticipantsInGroupViaDelegate, navigateToProductLink: $navigateToProductLink, navigateToSocialLink: $navigateToSocialLink, navigateToCollectionLink: $navigateToCollectionLink)
            .environmentObject(self.realmManager)
        }
    }
    func getIsReceived(message : MessagesDB) -> Bool{
        if self.fromBroadCastFlow == true{
            return false
        }else{
            return (message.senderInfo?.userId ?? message.initiatorId) != myUserId
        }
    }
    
    //MARK: - GROUP HEADERS
    func grpHeader(action: ISMChatActionType, userName: String, senderId: String,member : String? = nil,memberId : String? = nil,isGroup : Bool? = true) -> some View {
        ZStack {
            let userId = userData?.userId
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
                if let isGroup = isGroup{
                    if isGroup == false{
                        let text = appearance.constantStrings.endToEndEncrypted
                        customTextWithImage(text: text, image: appearance.images.messageLock)
                    }else{
                        let text = senderId == userId ? "You created group" : "\(userName) created group"
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
    
     func sectionHeader(firstMessage message : MessagesDB,color : Color,font : Font) -> some View{
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
        HStack(alignment: .top,spacing: 5){
            image
                .resizable()
                .frame(width: 10,height: 13)
                .foregroundColor(appearance.colorPalette.messageListActionText)
                .padding(.top,2)
            Text(text)
                .foregroundColor(appearance.colorPalette.messageListActionText)
                .font(appearance.fonts.messageListActionText)
                
        }.frame(width: text.widthOfString(usingFont: UIFont.regular(size: 13)))
            .padding(.vertical, 5)
            .background(appearance.colorPalette.messageListActionBackground)
            .cornerRadius(5)
    }
}
