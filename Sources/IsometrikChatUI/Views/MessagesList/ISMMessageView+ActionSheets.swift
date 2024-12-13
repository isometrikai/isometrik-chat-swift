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
    
    func attachmentsView() -> some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        return LazyVGrid(columns: columns, spacing: 20) {
            ForEach(chatProperties.attachments, id: \.self) { item in
                
                    Button {
                        if item.name == ISMChatConfigAttachmentType.camera.name{
                            selectedSheetIndex = 0
                            DispatchQueue.main.async {
                                stateViewModel.showSheet = true
                                stateViewModel.showActionSheet = false
                            }
                        }else if item.name == ISMChatConfigAttachmentType.gallery.name{
                            DispatchQueue.main.async {
                                stateViewModel.showVideoPicker = true
                                stateViewModel.showActionSheet = false
                            }
                        }else if item.name == ISMChatConfigAttachmentType.document.name{
                            selectedSheetIndex = 1
                            DispatchQueue.main.async {
                                stateViewModel.showSheet = true
                                stateViewModel.showActionSheet = false
                            }
                            
                        }else if item.name == ISMChatConfigAttachmentType.location.name{
                            DispatchQueue.main.async {
                                stateViewModel.showLocationSharing = true
                                stateViewModel.showActionSheet = false
                            }
                        }else if item.name == ISMChatConfigAttachmentType.contact.name{
                            if chatProperties.customShareContactFlow == true{
                                self.delegate?.navigateToShareContact(conversationId: self.conversationID ?? "")
                                stateViewModel.showActionSheet = false
                            }else{
                                selectedSheetIndex = 2
                                DispatchQueue.main.async {
                                    stateViewModel.showSheet = true
                                    stateViewModel.showActionSheet = false
                                }
                            }
                        }else if item.name == ISMChatConfigAttachmentType.sticker.name{
                            DispatchQueue.main.async {
                                stateViewModel.showGifPicker = true
                                stateViewModel.showActionSheet = false
                            }
                        }
                    } label: {
                        VStack(spacing: 8){
                            if item.name == ISMChatConfigAttachmentType.camera.name{
                                appearance.images.attachment_Camera
                                    .resizable()
                                    .frame(width: 48, height: 48, alignment: .center)
                            }else if item.name == ISMChatConfigAttachmentType.gallery.name{
                                appearance.images.attachment_Gallery
                                    .resizable()
                                    .frame(width: 48, height: 48, alignment: .center)
                            }else if item.name == ISMChatConfigAttachmentType.document.name{
                                appearance.images.attachment_Document
                                    .resizable()
                                    .frame(width: 48, height: 48, alignment: .center)
                            }else if item.name == ISMChatConfigAttachmentType.location.name{
                                appearance.images.attachment_Location
                                    .resizable()
                                    .frame(width: 48, height: 48, alignment: .center)
                            }else if item.name == ISMChatConfigAttachmentType.contact.name{
                                appearance.images.attachment_Contact
                                    .resizable()
                                    .frame(width: 48, height: 48, alignment: .center)
                            }else if item.name == ISMChatConfigAttachmentType.sticker.name{
                                appearance.images.attachment_Sticker
                                    .resizable()
                                    .frame(width: 48, height: 48, alignment: .center)
                            }
                            Text(item.name)
                                .font(appearance.fonts.attachmentsText)
                                .foregroundColor(appearance.colorPalette.attachmentsText)
                        }
                    }
            }
        }
        .padding()
        .background(appearance.colorPalette.attachmentsBackground)
        .cornerRadius(22)
    }
    func attachmentActionSheetButtons() -> some View {
        VStack {
            ForEach(chatProperties.attachments, id: \.self) { option in
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
                        
                        if chatProperties.customShareContactFlow == true{
                            self.delegate?.navigateToShareContact(conversationId: self.conversationID ?? "")
                        }else{
                            selectedSheetIndex = 2
                            DispatchQueue.main.async {
                                stateViewModel.showSheet = true
                            }
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
                }else if option == .sticker {
                    Button(action: {
                        DispatchQueue.main.async {
                            stateViewModel.showGifPicker = true
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
            msg.senderInfo?.userId != userData?.userId
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
