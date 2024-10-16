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
                if option == .camera {
                    Button(action: {
                        selectedSheetIndex = 0
                        DispatchQueue.main.async {
                            stateViewModel.showSheet = true
                        }
                    }) {
                        Text(option.name)
                    }
                }
                else if option == .gallery{
                    Button(action: {
                        DispatchQueue.main.async {
                            stateViewModel.showVideoPicker = true
                        }
                    }) {
                        Text(option.name)
                    }
                    
                }else if option == .document{
                    Button(action: {
                        selectedSheetIndex = 1
                        DispatchQueue.main.async {
                            stateViewModel.showSheet = true
                        }
                    }) {
                        Text(option.name)
                    }
                    
                }else if option == .contact{
                    Button(action: {
                        selectedSheetIndex = 2
                        DispatchQueue.main.async {
                            stateViewModel.showSheet = true
                        }
                    }) {
                        Text(option.name)
                    }
                    
                }else if option == .location {
                    Button(action: {
                        DispatchQueue.main.async {
                            stateViewModel.showLocationSharing = true
                        }
                    }) {
                        Text(option.name)
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
            msg.senderInfo?.userId != userData.userId
        })
    }
    
    func unblockActionSheetButton() -> some View {
        Button("Unblock") {
            conversationViewModel.blockUnBlockUser(opponentId: self.conversationDetail?.conversationDetails?.opponentDetails?.id ?? "", needToBlock: false) { obj in
                print("Success")
                self.conversationDetail?.conversationDetails?.messagingDisabled = false
                self.delegate?.externalBlockMechanism(appUserId: self.conversationDetail?.conversationDetails?.opponentDetails?.metaData?.userId ?? "", block: false)
//                getConversationDetail()
//                reload()
            }
        }
    }
}
