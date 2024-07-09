//
//  ISMMessageView+ActionSheets.swift
//  ISMChatSdk
//
//  Created by Rasika on 15/04/24.
//

import Foundation
import SwiftUI
import IsometrikChat

//MARK: - ACTION SHEETS
extension ISMMessageView{
    func attachmentActionSheetButtons() -> some View {
        VStack {
            ForEach(ISMChatSdkUI.getInstance().getChatProperties().attachments, id: \.self) { option in
                Button(option.name) {
                    if isMessagingEnabled() {
                        switch option {
                        case .camera:
                            selectedSheetIndex = 0
                            showSheet = true
                            break
                        case .gallery:
                            showVideoPicker = true
                            break
                        case .document:
                            selectedSheetIndex = 1
                            showSheet = true
                            break
                        case .location:
                            showLocationSharing = true
                            break
                        case .contact:
                            selectedSheetIndex = 2
                            showSheet = true
                            break
                        }
                    }
                }
            }
            Button("Cancel", role: .cancel) {
                // Handle cancel action if needed
            }
        }
    }
    
    
    func deleteActionSheetButtons() -> some View {
        VStack {
            if fromBroadCastFlow == true{
                Button("Delete for Everyone", role: .destructive) {
                    deleteMultipleBroadcastMessages(otherUserMessage: false, type: .DeleteForEveryone)
                    
                }
                Button("Delete for Me", role: .destructive) {
                    deleteMultipleBroadcastMessages(otherUserMessage: false, type: .DeleteForYou)
                }
            }else{
                if otherUserMessageDeleteForMe() {
                    //other user
                    Button("Delete for Me", role: .destructive) {
                        deleteMultipleMessages(otherUserMessage: true, type: .DeleteForYou)
                    }
                } else {
                    //my msg
                    Button("Delete for Everyone", role: .destructive) {
                        deleteMultipleMessages(otherUserMessage: false, type: .DeleteForEveryone)
                    }
                    Button("Delete for Me", role: .destructive) {
                        deleteMultipleMessages(otherUserMessage: false, type: .DeleteForYou)
                    }
                }
            }
            Button("Cancel", role: .cancel) {
                // Handle cancel action if needed
            }
        }
    }
    
    func otherUserMessageDeleteForMe() -> Bool {
        deleteMessage.contains(where: { msg in
            msg.senderInfo?.userIdentifier != userSession.getEmailId()
        })
    }
    
    func unblockActionSheetButton() -> some View {
        Button("Unblock") {
            conversationViewModel.blockUnBlockUser(opponentId: self.conversationDetail?.conversationDetails?.opponentDetails?.id ?? "", needToBlock: false) { obj in
                print("Success")
                self.conversationDetail?.conversationDetails?.messagingDisabled = false
//                getConversationDetail()
//                reload()
            }
        }
    }
}
