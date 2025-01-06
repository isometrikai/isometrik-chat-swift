//
//  ISMCustomContextMenu.swift
//  ISMChatSdk
//
//  Created by Rasika on 15/04/24.
//

import Foundation
import SwiftUI
import IsometrikChat

struct ContextMenuAction {
    let label: String
    let icon: Image
    let condition: Bool
    let action: () -> Void
}

struct ISMCustomContextMenu: View {
    @Environment(\.dismiss) var dismiss
    
    @State var previousAudioRef: AudioPlayViewModel?
    let conversationId : String
    let message : MessagesDB
    let viewWidth : CGFloat
    var viewModel = ChatsViewModel()
    let isGroup : Bool
    let isReceived : Bool
    let pasteboard = UIPasteboard.general
    @EnvironmentObject var realmManager : RealmManager
    
    @Environment(\.viewController) public var viewControllerHolder: UIViewController?
    
    @State private var showReplyOption = ISMChatSdkUI.getInstance().getChatProperties().features.contains(.reply)
    
    @State private var showForwardOption = ISMChatSdkUI.getInstance().getChatProperties().features.contains(.forward)
    
    @State private var showEditOption = ISMChatSdkUI.getInstance().getChatProperties().features.contains(.edit)
    
    @State private var showReactionsOption = ISMChatSdkUI.getInstance().getChatProperties().features.contains(.reaction)
    
    @Binding var selectedMessageToReply : MessagesDB
    @Binding var navigateToMessageInfo : Bool
    @Binding var showMessageInfoInsideMessage : Bool
//    @Binding var showForward: Bool
    @Binding var forwardMessageSelected : MessagesDB
    @Binding var updateMessage : MessagesDB
    @Binding var messageCopied : Bool
    @State private var navigatetoMessageInfo : Bool = false
    @Binding var navigateToDeletePopUp : Bool
    
    @State var emojiOptions: [ISMChatEmojiReaction] = ISMChatEmojiReaction.allCases
    @Binding var selectedReaction : String?
    @Binding var sentRecationToMessageId : String
    @Binding var deleteMessage : [MessagesDB]
    
    let fromBroadCastFlow : Bool?
    
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    let groupconversationMember : [ISMChatGroupMember]
    
    
    var body: some View {
        ZStack {
            // Semi-transparent overlay
            Rectangle()
                .fill(.black.opacity(0.5))
//                .background(.ultraThinMaterial)
                .blur(radius: 0.7, opaque: false)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(alignment: isReceived ? .leading : .trailing) {
                Spacer()
                
                if showReactionsOption && ISMChatHelper.getMessageType(message: message) != .AudioCall && ISMChatHelper.getMessageType(message: message) != .VideoCall && message.deletedMessage == false{
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 35))],
                        spacing: 10
                    ) {
                        ForEach(emojiOptions, id: \.self) { item in
                            Button {
                                sentRecationToMessageId = self.message.messageId
                                selectedReaction = item.info.valueString
                                dismiss()
                            } label: {
                                Text(item.info.emoji)
                                    .font(Font.regular(size: 30))
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal,15)
                }
                
                ISMMessageInfoSubView(previousAudioRef: $previousAudioRef, messageType: ISMChatHelper.getMessageType(message: message), message: message, viewWidth: viewWidth, isReceived: self.isReceived, messageDeliveredType: ISMChatHelper.checkMessageDeliveryType(message: message, isGroup: self.isGroup ,memberCount: realmManager.getMemberCount(convId: self.conversationId), isOneToOneGroup: ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup), conversationId: conversationId,isGroup: self.isGroup, groupconversationMember: [], fromBroadCastFlow: self.fromBroadCastFlow)
                    .padding(.horizontal,15)
                    .environmentObject(self.realmManager)
                
               

                VStack {
                    ForEach(getContextMenuActions(), id: \.label) { action in
                        if action.condition {
                            Button {
                                action.action()
                            } label: {
                                HStack {
                                    Text(action.label)
                                        .font(appearance.fonts.contextMenuOptions)
                                        .foregroundColor(action.label == "Delete" ? Color(hex: "#DD3719") : Color.black)
                                    Spacer()
                                    action.icon
                                        .resizable()
                                        .frame(
                                            width: action.label == "Delete" ? appearance.imagesSize.messageInfo_deleteIcon.width :
                                                    appearance.imagesSize.messageInfo_replyIcon.width,
                                            height: action.label == "Delete" ? appearance.imagesSize.messageInfo_deleteIcon.height :
                                                    appearance.imagesSize.messageInfo_replyIcon.height,
                                            alignment: .center
                                        )
                                }
                                .padding(.horizontal, 15)
                                .frame(height: 38)
                            }
                            .frame(height: 38)
                            Rectangle()
                                .fill(Color(hex: "#111111").opacity(0.25))
                                .frame(height: 0.5)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .frame(width: 228, alignment: .center)
                .padding(.horizontal, 15)
                
                Spacer()

              
//                VStack {
//                    
//                    if showReplyOption && fromBroadCastFlow != true  && ISMChatHelper.getMessageType(message: message) != .AudioCall && ISMChatHelper.getMessageType(message: message) != .VideoCall && message.deletedMessage == false{
//                        Button {
//                            selectedMessageToReply = message
//                            dismiss()
//                        } label: {
//                            HStack{
//                                Text("Reply")
//                                    .font(appearance.fonts.contextMenuOptions)
//                                    .foregroundColor(Color.black)
//                                Spacer()
//                                appearance.images.contextMenureply
//                                    .resizable()
//                                    .frame(width: appearance.imagesSize.messageInfo_replyIcon.width, height: appearance.imagesSize.messageInfo_replyIcon.height, alignment: .center)
//                            }.padding(.horizontal,15)
//                                .frame(height: 44)
//                        }.frame(height: 44)
//                        Rectangle().fill(Color(hex: "#111111").opacity(0.25)).frame(height: 0.5)
//                    }
//                    if showForwardOption && ISMChatHelper.getMessageType(message: message) != .AudioCall && ISMChatHelper.getMessageType(message: message) != .VideoCall && message.deletedMessage == false{
//                        Button {
//                            showForward = true
//                            dismiss()
//                        } label: {
//                            HStack{
//                                Text("Forward")
//                                    .font(appearance.fonts.contextMenuOptions)
//                                    .foregroundColor(Color.black)
//                                Spacer()
//                                appearance.images.contextMenuforward
//                                    .resizable()
//                                    .frame(width: appearance.imagesSize.messageInfo_forwardIcon.width, height: appearance.imagesSize.messageInfo_forwardIcon.height, alignment: .center)
//                            }.padding(.horizontal,15)
//                                .frame(height: 44)
//                        }.frame(height: 44)
//                        Rectangle().fill(Color(hex: "#111111").opacity(0.25)).frame(height: 0.5)
//                    }
//                    
//                    if showEditOption && !isReceived && ISMChatHelper.getMessageType(message: message) == .text && fromBroadCastFlow != true && message.deletedMessage == false{
//                        Button {
//                            updateMessage = message
//                            dismiss()
//                        } label: {
//                            HStack{
//                                Text("Edit")
//                                    .font(appearance.fonts.contextMenuOptions)
//                                    .foregroundColor(Color.black)
//                                Spacer()
//                                appearance.images.contextMenuedit
//                                    .resizable()
//                                    .frame(width: appearance.imagesSize.messageInfo_editIcon.width, height: appearance.imagesSize.messageInfo_editIcon.height, alignment: .center)
//                            }.padding(.horizontal,15)
//                                .frame(height: 44)
//                        }.frame(height: 44)
//                        Rectangle().fill(Color(hex: "#111111").opacity(0.25)).frame(height: 0.5)
//                    }
//                    if ISMChatHelper.getMessageType(message: message) == .text && message.deletedMessage == false{
//                        Button {
//                            pasteboard.string = message.body
//                            messageCopied = true
//                            dismiss()
//                        } label: {
//                            HStack{
//                                Text("Copy")
//                                    .font(appearance.fonts.contextMenuOptions)
//                                    .foregroundColor(Color.black)
//                                Spacer()
//                                appearance.images.contextMenucopy
//                                    .resizable()
//                                    .frame(width: appearance.imagesSize.messageInfo_copyIcon.width, height: appearance.imagesSize.messageInfo_copyIcon.height, alignment: .center)
//                            }.padding(.horizontal,15).frame(height: 44)
//                        }.frame(height: 44)
//                        Rectangle().fill(Color(hex: "#111111").opacity(0.25)).frame(height: 0.5)
//                    }
//                    
//                    if !isReceived && ISMChatHelper.getMessageType(message: message) != .AudioCall && ISMChatHelper.getMessageType(message: message) != .VideoCall && message.deletedMessage == false{
//                        
//                        if ISMChatSdkUI.getInstance().getChatProperties().editMessageForOnly15Mins == true{
//                            if isSentTimeLessThan15MinutesAgo(sentTime: message.sentAt){
//                                Button {
//                                    if ISMChatSdkUI.getInstance().getChatProperties().messageInfoBelowMessage == false{
//                                        navigateToMessageInfo = true
//                                    }else{
//                                        showMessageInfoInsideMessage = true
//                                    }
//                                    dismiss()
//                                } label: {
//                                    HStack{
//                                        Text("Info")
//                                            .font(appearance.fonts.contextMenuOptions)
//                                            .foregroundColor(Color.black)
//                                        Spacer()
//                                        appearance.images.contextMenuinfo
//                                            .resizable()
//                                            .frame(width: appearance.imagesSize.messageInfo_infoIcon.width, height: appearance.imagesSize.messageInfo_infoIcon.height, alignment: .center)
//                                    }.padding(.horizontal,15).frame(height: 44)
//                                }.frame(height: 44)
//                                Rectangle().fill(Color(hex: "#111111").opacity(0.25)).frame(height: 0.5)
//                            }else{
//                                
//                            }
//                        }else{
//                            Button {
//                                if ISMChatSdkUI.getInstance().getChatProperties().messageInfoBelowMessage == false{
//                                    navigateToMessageInfo = true
//                                }else{
//                                    showMessageInfoInsideMessage = true
//                                }
//                                dismiss()
//                            } label: {
//                                HStack{
//                                    Text("Info")
//                                        .font(appearance.fonts.contextMenuOptions)
//                                        .foregroundColor(Color.black)
//                                    Spacer()
//                                    appearance.images.contextMenuinfo
//                                        .resizable()
//                                        .frame(width: appearance.imagesSize.messageInfo_infoIcon.width, height: appearance.imagesSize.messageInfo_infoIcon.height, alignment: .center)
//                                }.padding(.horizontal,15).frame(height: 40)
//                            }.frame(height: 40)
//                            Rectangle().fill(Color(hex: "#111111").opacity(0.25)).frame(height: 0.5)
//                        }
//                    }
//                    Button(role: .destructive) {
//                        deleteMessage.append(message)
//                        navigateToDeletePopUp = true
//                        dismiss()
//                    } label: {
//                        HStack{
//                            Text("Delete")
//                                .font(appearance.fonts.contextMenuOptions)
//                                .foregroundColor(Color(hex: "#DD3719"))
//                            Spacer()
//                            appearance.images.contextMenudelete
//                                .resizable()
//                                .frame(width: appearance.imagesSize.messageInfo_deleteIcon.width, height: appearance.imagesSize.messageInfo_deleteIcon.height, alignment: .center)
//                        }.padding(.horizontal,15).frame(height: 40)
//                    }.frame(height: 40)
//                }
//                .background(Color.white)
//                .cornerRadius(12)
//                .frame(width: 228, alignment: .center)
//                .padding(.horizontal,15)
//                Spacer()
            }
        }
        .background(Color.clear)
    }
    
    
    func getContextMenuActions() -> [ContextMenuAction] {
        return [
            ContextMenuAction(
                label: "Reply",
                icon: appearance.images.contextMenureply,
                condition: showReplyOption && fromBroadCastFlow != true &&
                           ISMChatHelper.getMessageType(message: message) != .AudioCall &&
                           ISMChatHelper.getMessageType(message: message) != .VideoCall &&
                           message.deletedMessage == false,
                action: {
                    selectedMessageToReply = message
                    dismiss()
                }
            ),
            ContextMenuAction(
                label: "Forward",
                icon: appearance.images.contextMenuforward,
                condition: showForwardOption &&
                           ISMChatHelper.getMessageType(message: message) != .AudioCall &&
                           ISMChatHelper.getMessageType(message: message) != .VideoCall &&
                           message.deletedMessage == false,
                action: {
                    forwardMessageSelected = message
//                    showForward = true
                    dismiss()
                }
            ),
            ContextMenuAction(
                label: "Edit",
                icon: appearance.images.contextMenuedit,
                condition: showEditOption &&
                !isReceived &&
                ISMChatHelper.getMessageType(message: message) == .text &&
                fromBroadCastFlow != true &&
                message.deletedMessage == false && sentTimeLessThan15MinutesAgo(sentTime: message.sentAt) == true,
                action: {
                    updateMessage = message
                    dismiss()
                }
            ),
            ContextMenuAction(
                label: "Copy",
                icon: appearance.images.contextMenucopy,
                condition: ISMChatHelper.getMessageType(message: message) == .text &&
                           message.deletedMessage == false,
                action: {
                    pasteboard.string = message.body
                    messageCopied = true
                    dismiss()
                }
            ),
            ContextMenuAction(
                label: "Info",
                icon: appearance.images.contextMenuinfo,
                condition: !isReceived &&
                           ISMChatHelper.getMessageType(message: message) != .AudioCall &&
                           ISMChatHelper.getMessageType(message: message) != .VideoCall &&
                           message.deletedMessage == false ,
                action: {
                    if ISMChatSdkUI.getInstance().getChatProperties().messageInfoBelowMessage == false {
                        navigateToMessageInfo = true
                    } else {
                        showMessageInfoInsideMessage = true
                    }
                    dismiss()
                }
            ),
            ContextMenuAction(
                label: "Delete",
                icon: appearance.images.contextMenudelete,
                condition: true,
                action: {
                    deleteMessage.append(message)
                    navigateToDeletePopUp = true
                    dismiss()
                }
            )
        ]
    }

    
    func sentTimeLessThan15MinutesAgo(sentTime: Double) -> Bool {
        // Check if the "editMessageForOnly15Mins" property is disabled
        guard ISMChatSdkUI.getInstance().getChatProperties().editMessageForOnly15Mins else {
            return true
        }
        
        let sentAtSeconds = sentTime / 1000.0
            
            // Get the current date's timestamp in seconds
            let currentTimeStamp = Date().timeIntervalSince1970
            
            // Calculate the time difference
            let timeDifference = currentTimeStamp - sentAtSeconds
            
            // Check if the time difference is less than 15 minutes
            return timeDifference < 15 * 60
    }
}
