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
        NavigationStack{
        ZStack{
            BackdropBlurView(radius: 6)
                .ignoresSafeArea()
            VStack(alignment: isReceived ? .leading : .trailing) {
                Spacer()
                
                if showReactionsOption && ISMChatHelper.getMessageType(message: message) != .AudioCall && ISMChatHelper.getMessageType(message: message) != .VideoCall{
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
                
                ISMMessageInfoSubView(previousAudioRef: $previousAudioRef, messageType: ISMChatHelper.getMessageType(message: message), message: message, viewWidth: viewWidth, isReceived: self.isReceived, messageDeliveredType: ISMChatHelper.checkMessageDeliveryType(message: message, isGroup: self.isGroup ,memberCount: realmManager.getMemberCount(convId: self.conversationId)), conversationId: conversationId,isGroup: self.isGroup, groupconversationMember: [], fromBroadCastFlow: self.fromBroadCastFlow)
                    .padding(.horizontal,15)
                    .environmentObject(self.realmManager)
                VStack {
                    if showReplyOption && fromBroadCastFlow != true  && ISMChatHelper.getMessageType(message: message) != .AudioCall && ISMChatHelper.getMessageType(message: message) != .VideoCall{
                        Button {
                            selectedMessageToReply = message
                            dismiss()
                        } label: {
                            HStack{
                                Text("Reply")
                                    .font(Font.regular(size: 16))
                                    .foregroundColor(Color(hex: "#294566"))
                                Spacer()
                                appearance.images.contextMenureply
                                    .resizable()
                                    .frame(width: 18, height: 18, alignment: .center)
                            }.padding(.horizontal,15).padding(.vertical,10)
                        }
                        Rectangle().fill(Color(hex: "#CBE3FF")).frame(height: 1).padding(.leading,15)
                    }
                    if showForwardOption && ISMChatHelper.getMessageType(message: message) != .AudioCall && ISMChatHelper.getMessageType(message: message) != .VideoCall{
                        Button {
                            showForward = true
                            dismiss()
                        } label: {
                            HStack{
                                Text("Forward")
                                    .font(Font.regular(size: 16))
                                    .foregroundColor(Color(hex: "#294566"))
                                Spacer()
                                appearance.images.contextMenuforward
                                    .resizable()
                                    .frame(width: 18, height: 18, alignment: .center)
                            }.padding(.horizontal,15).padding(.vertical,10)
                        }
                        Rectangle().fill(Color(hex: "#CBE3FF")).frame(height: 1).padding(.leading,15)
                    }
                    
                    if showEditOption && !isReceived && ISMChatHelper.getMessageType(message: message) == .text && fromBroadCastFlow != true{
                        Button {
                            updateMessage = message
                            dismiss()
                        } label: {
                            HStack{
                                Text("Edit")
                                    .font(Font.regular(size: 16))
                                    .foregroundColor(Color(hex: "#294566"))
                                Spacer()
                                appearance.images.contextMenuedit
                                    .resizable()
                                    .frame(width: 18, height: 18, alignment: .center)
                            }.padding(.horizontal,15).padding(.vertical,10)
                        }
                        Rectangle().fill(Color(hex: "#CBE3FF")).frame(height: 1).padding(.leading,15)
                    }
                    if ISMChatHelper.getMessageType(message: message) == .text{
                        Button {
                            pasteboard.string = message.body
                            messageCopied = true
                            dismiss()
                        } label: {
                            HStack{
                                Text("Copy")
                                    .font(Font.regular(size: 16))
                                    .foregroundColor(Color(hex: "#294566"))
                                Spacer()
                                appearance.images.contextMenucopy
                                    .resizable()
                                    .frame(width: 18, height: 18, alignment: .center)
                            }.padding(.horizontal,15).padding(.vertical,10)
                        }
                        Rectangle().fill(Color(hex: "#CBE3FF")).frame(height: 1).padding(.leading,15)
                    }
                    
                    if !isReceived && ISMChatHelper.getMessageType(message: message) != .AudioCall && ISMChatHelper.getMessageType(message: message) != .VideoCall{
                        
                        NavigationLink {
                            ISMMessageInfoView(conversationId: conversationId,message: message, viewWidth: 250,mediaType: .Image, isGroup: self.isGroup ?? false, groupMember: self.groupconversationMember,fromBroadCastFlow: self.fromBroadCastFlow,onClose: {
                                dismiss()
                            }).environmentObject(self.realmManager)
                        } label: {
                            HStack{
                                Text("Info")
                                    .font(Font.regular(size: 16))
                                    .foregroundColor(Color(hex: "#294566"))
                                Spacer()
                                appearance.images.contextMenuinfo
                                    .resizable()
                                    .frame(width: 18, height: 18, alignment: .center)
                            }.padding(.horizontal,15).padding(.vertical,10)
                        }
                        Rectangle().fill(Color(hex: "#CBE3FF")).frame(height: 1).padding(.leading,15)
                    }
                    Button(role: .destructive) {
                        navigateToDeletePopUp = true
                        dismiss()
                    } label: {
                        HStack{
                            Text("Delete")
                                .font(Font.regular(size: 16))
                                .foregroundColor(Color(hex: "#DD3719"))
                            Spacer()
                            appearance.images.contextMenudelete
                                .resizable()
                                .frame(width: 18, height: 18, alignment: .center)
                        }.padding(.horizontal,15).padding(.vertical,10)
                    }
                }
                .background(Color.white)
                .cornerRadius(8)
                .frame(width: 236, alignment: .center)
                .padding(.horizontal,15)
                Spacer()
            }
            .edgesIgnoringSafeArea(.all)
            .background(Color.clear)
            
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color.clear)
        .onTapGesture {
            dismiss()
        }
    }
    }
}


struct BackdropView: UIViewRepresentable {

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView()
        let blur = UIBlurEffect()
        let animator = UIViewPropertyAnimator()
        animator.addAnimations { view.effect = blur }
        animator.fractionComplete = 0
        animator.stopAnimation(false)
        animator.finishAnimation(at: .current)
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { }
    
}

/// A transparent View that blurs its background
struct BackdropBlurView: View {
    
    let radius: CGFloat
    
    @ViewBuilder
    var body: some View {
        BackdropView().blur(radius: radius)
    }
    
}
