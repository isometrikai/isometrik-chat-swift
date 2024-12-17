//
//  ISMCustomContextMenu.swift
//  ISMChatSdk
//
//  Created by Rasika on 15/04/24.
//

import Foundation
import SwiftUI
import IsometrikChat

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
    @Binding var showForward: Bool
    @Binding var updateMessage : MessagesDB
    @Binding var messageCopied : Bool
    @State private var navigatetoMessageInfo : Bool = false
    @Binding var navigateToDeletePopUp : Bool
    
    @State var emojiOptions: [ISMChatEmojiReaction] = ISMChatEmojiReaction.allCases
    @Binding var selectedReaction : String?
    @Binding var sentRecationToMessageId : String
    
    let fromBroadCastFlow : Bool?
    
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    let groupconversationMember : [ISMChatGroupMember]
    
    
    var body: some View {
        ZStack {
            // Semi-transparent overlay
            Rectangle()
                .fill(.black.opacity(0.2))
                .background(.ultraThinMaterial)
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
                    if showReplyOption && fromBroadCastFlow != true  && ISMChatHelper.getMessageType(message: message) != .AudioCall && ISMChatHelper.getMessageType(message: message) != .VideoCall && message.deletedMessage == false{
                        Button {
                            selectedMessageToReply = message
                            dismiss()
                        } label: {
                            HStack{
                                Text("Reply")
                                    .font(appearance.fonts.contextMenuOptions)
                                    .foregroundColor(Color(hex: "#294566"))
                                Spacer()
                                appearance.images.contextMenureply
                                    .resizable()
                                    .frame(width: appearance.imagesSize.messageInfo_replyIcon.width, height: appearance.imagesSize.messageInfo_replyIcon.height, alignment: .center)
                            }.padding(.horizontal,15).padding(.vertical,10)
                        }.padding(.top,5)
                        Rectangle().fill(Color(hex: "#111111").opacity(0.25)).frame(height: 0.5)
                    }
                    if showForwardOption && ISMChatHelper.getMessageType(message: message) != .AudioCall && ISMChatHelper.getMessageType(message: message) != .VideoCall && message.deletedMessage == false{
                        Button {
                            showForward = true
                            dismiss()
                        } label: {
                            HStack{
                                Text("Forward")
                                    .font(appearance.fonts.contextMenuOptions)
                                    .foregroundColor(Color(hex: "#294566"))
                                Spacer()
                                appearance.images.contextMenuforward
                                    .resizable()
                                    .frame(width: appearance.imagesSize.messageInfo_forwardIcon.width, height: appearance.imagesSize.messageInfo_forwardIcon.height, alignment: .center)
                            }.padding(.horizontal,15).padding(.vertical,10)
                        }
                        Rectangle().fill(Color(hex: "#111111").opacity(0.25)).frame(height: 0.5)
                    }
                    
                    if showEditOption && !isReceived && ISMChatHelper.getMessageType(message: message) == .text && fromBroadCastFlow != true && message.deletedMessage == false{
                        Button {
                            updateMessage = message
                            dismiss()
                        } label: {
                            HStack{
                                Text("Edit")
                                    .font(appearance.fonts.contextMenuOptions)
                                    .foregroundColor(Color(hex: "#294566"))
                                Spacer()
                                appearance.images.contextMenuedit
                                    .resizable()
                                    .frame(width: appearance.imagesSize.messageInfo_editIcon.width, height: appearance.imagesSize.messageInfo_editIcon.height, alignment: .center)
                            }.padding(.horizontal,15).padding(.vertical,10)
                        }
                        Rectangle().fill(Color(hex: "#111111").opacity(0.25)).frame(height: 0.5)
                    }
                    if ISMChatHelper.getMessageType(message: message) == .text && message.deletedMessage == false{
                        Button {
                            pasteboard.string = message.body
                            messageCopied = true
                            dismiss()
                        } label: {
                            HStack{
                                Text("Copy")
                                    .font(appearance.fonts.contextMenuOptions)
                                    .foregroundColor(Color(hex: "#294566"))
                                Spacer()
                                appearance.images.contextMenucopy
                                    .resizable()
                                    .frame(width: appearance.imagesSize.messageInfo_copyIcon.width, height: appearance.imagesSize.messageInfo_copyIcon.height, alignment: .center)
                            }.padding(.horizontal,15).padding(.vertical,10)
                        }
                        Rectangle().fill(Color(hex: "#111111").opacity(0.25)).frame(height: 0.5)
                    }
                    
                    if !isReceived && ISMChatHelper.getMessageType(message: message) != .AudioCall && ISMChatHelper.getMessageType(message: message) != .VideoCall && message.deletedMessage == false{
                        
                        Button {
                            if ISMChatSdkUI.getInstance().getChatProperties().messageInfoBelowMessage == false{
                                navigateToMessageInfo = true
                            }else{
                                showMessageInfoInsideMessage = true
                            }
                            dismiss()
                        } label: {
                            HStack{
                                Text("Info")
                                    .font(appearance.fonts.contextMenuOptions)
                                    .foregroundColor(Color(hex: "#294566"))
                                Spacer()
                                appearance.images.contextMenuinfo
                                    .resizable()
                                    .frame(width: appearance.imagesSize.messageInfo_infoIcon.width, height: appearance.imagesSize.messageInfo_infoIcon.height, alignment: .center)
                            }.padding(.horizontal,15).padding(.vertical,10)
                        }
                        Rectangle().fill(Color(hex: "#111111").opacity(0.25)).frame(height: 0.5)
                    }
                    Button(role: .destructive) {
                        navigateToDeletePopUp = true
                        dismiss()
                    } label: {
                        HStack{
                            Text("Delete")
                                .font(appearance.fonts.contextMenuOptions)
                                .foregroundColor(Color(hex: "#DD3719"))
                            Spacer()
                            appearance.images.contextMenudelete
                                .resizable()
                                .frame(width: appearance.imagesSize.messageInfo_deleteIcon.width, height: appearance.imagesSize.messageInfo_deleteIcon.height, alignment: .center)
                        }.padding(.horizontal,15).padding(.vertical,10)
                    }.padding(.bottom,5)
                }
                .background(Color.white)
                .cornerRadius(8)
                .frame(width: 236, alignment: .center)
                .padding(.horizontal,15)
                Spacer()
            }
        }
        .background(Color.clear)
    }
}
