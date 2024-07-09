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
    var viewModel = ChatsViewModel(ismChatSDK: ISMChatSdk.getInstance())
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
    @Binding var navigatetoMessageInfo : Bool
    @Binding var navigateToDeletePopUp : Bool
    
    @State var emojiOptions: [ISMChat_EmojiReaction] = ISMChat_EmojiReaction.allCases
    @Binding var selectedReaction : String?
    @Binding var sentRecationToMessageId : String
    
    let fromBroadCastFlow : Bool?
    
    @State var themeImage = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    
    
    var body: some View {
        ZStack{
            BackdropBlurView(radius: 6)
                .ignoresSafeArea()
            VStack(alignment: isReceived ? .leading : .trailing) {
                Spacer()
                
                if showReactionsOption && ISMChat_Helper.getMessageType(message: message) != .AudioCall && ISMChat_Helper.getMessageType(message: message) != .VideoCall{
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
                
                ISMMessageInfoSubView(previousAudioRef: $previousAudioRef, messageType: ISMChat_Helper.getMessageType(message: message), message: message, viewWidth: viewWidth, isReceived: self.isReceived, messageDeliveredType: ISMChat_Helper.checkMessageDeliveryType(message: message, isGroup: self.isGroup ,memberCount: realmManager.getMemberCount(convId: self.conversationId)), conversationId: conversationId,isGroup: self.isGroup, groupconversationMember: [], fromBroadCastFlow: self.fromBroadCastFlow)
                    .padding(.horizontal,15)
                    .environmentObject(self.realmManager)
                VStack {
                    if showReplyOption && fromBroadCastFlow != true  && ISMChat_Helper.getMessageType(message: message) != .AudioCall && ISMChat_Helper.getMessageType(message: message) != .VideoCall{
                        Button {
                            selectedMessageToReply = message
                            dismiss()
                        } label: {
                            HStack{
                                Text("Reply")
                                    .font(Font.regular(size: 16))
                                    .foregroundColor(Color(hex: "#294566"))
                                Spacer()
                                themeImage.contextMenu_reply
                                    .resizable()
                                    .frame(width: 18, height: 18, alignment: .center)
                            }.padding(.horizontal,15).padding(.vertical,10)
                        }
                        Rectangle().fill(Color(hex: "#CBE3FF")).frame(height: 1).padding(.leading,15)
                    }
                    if showForwardOption && ISMChat_Helper.getMessageType(message: message) != .AudioCall && ISMChat_Helper.getMessageType(message: message) != .VideoCall{
                        Button {
                            showForward = true
                            dismiss()
                        } label: {
                            HStack{
                                Text("Forward")
                                    .font(Font.regular(size: 16))
                                    .foregroundColor(Color(hex: "#294566"))
                                Spacer()
                                themeImage.contextMenu_forward
                                    .resizable()
                                    .frame(width: 18, height: 18, alignment: .center)
                            }.padding(.horizontal,15).padding(.vertical,10)
                        }
                        Rectangle().fill(Color(hex: "#CBE3FF")).frame(height: 1).padding(.leading,15)
                    }
                    
                    if showEditOption && !isReceived && ISMChat_Helper.getMessageType(message: message) == .text && fromBroadCastFlow != true{
                        Button {
                            updateMessage = message
                            dismiss()
                        } label: {
                            HStack{
                                Text("Edit")
                                    .font(Font.regular(size: 16))
                                    .foregroundColor(Color(hex: "#294566"))
                                Spacer()
                                themeImage.contextMenu_edit
                                    .resizable()
                                    .frame(width: 18, height: 18, alignment: .center)
                            }.padding(.horizontal,15).padding(.vertical,10)
                        }
                        Rectangle().fill(Color(hex: "#CBE3FF")).frame(height: 1).padding(.leading,15)
                    }
                    if ISMChat_Helper.getMessageType(message: message) == .text{
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
                                themeImage.contextMenu_copy
                                    .resizable()
                                    .frame(width: 18, height: 18, alignment: .center)
                            }.padding(.horizontal,15).padding(.vertical,10)
                        }
                        Rectangle().fill(Color(hex: "#CBE3FF")).frame(height: 1).padding(.leading,15)
                    }
                    
                    if !isReceived && ISMChat_Helper.getMessageType(message: message) != .AudioCall && ISMChat_Helper.getMessageType(message: message) != .VideoCall{
                        Button {
                            navigatetoMessageInfo = true
                            dismiss()
                        } label: {
                            HStack{
                                Text("Info")
                                    .font(Font.regular(size: 16))
                                    .foregroundColor(Color(hex: "#294566"))
                                Spacer()
                                themeImage.contextMenu_info
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
                            themeImage.contextMenu_delete
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
