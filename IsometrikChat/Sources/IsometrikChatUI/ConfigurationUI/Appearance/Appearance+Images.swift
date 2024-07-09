//
//  ChatsView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 23/01/23.
//


import UIKit
import SwiftUI


    public struct ISMChat_Images {
        
        private static func loadImageSafely(with imageName: String) -> Image {
            return Image(imageName, bundle: .isometrikChat)
//            if let image = UIImage(named: imageName, in: .isometrikChat) {
//                return image
//            } else {
//                print(
//                    """
//                    \(imageName) image has failed to load from the bundle please make sure it's included in your assets folder.
//                    A default 'red' circle image has been added.
//                    """
//                )
//                return UIImage.circleImage
//            }
        }

        private static func loadSafely(systemName: String, assetsFallback: String) -> Image {
            if #available(iOS 13.0, *) {
                return Image(systemName: systemName)
            } else {
                return loadImageSafely(with: assetsFallback)
            }
        }
        
        
        
        //conversationList
        public var addConversation : Image = loadImageSafely(with: "AddHome")
        public var conversationListPlaceholder : Image = loadImageSafely(with: "default_Placeholder_CL")
        
        
        //messageList
        public var backButton : Image = loadImageSafely(with: "Back")
        public var backButtonGrey : Image = loadImageSafely(with: "back_Button")
        public var videoCall : Image = loadImageSafely(with: "video_Calling")
        public var audioCall : Image = loadImageSafely(with: "audio_Calling")
        public var threeDots : Image = loadSafely(systemName: "ellipsis", assetsFallback: "ellipsis")
       
        public var blockedUserListPlaceholder : Image = loadImageSafely(with: "BlockedUser")
        public var scrollToBottomArrow : Image = loadImageSafely(with: "bottomarrow")
        public var broadCastLogo : Image = loadImageSafely(with: "broadCast_logo")
        public var broadCastMessageLogo : Image = loadImageSafely(with: "broadcastMessageIcon")
        public var broadcastInUserList : Image = loadImageSafely(with: "megaphone")
        public var forwardLogo : Image = loadImageSafely(with: "forwarded")
        public var gifLogo : Image = loadImageSafely(with: "gif_logo")
        public var stickerLogo : Image = loadImageSafely(with: "gif_sticker")
        public var linkLogo : Image = loadImageSafely(with: "link")
        public var mapPinLogo : Image = loadImageSafely(with: "map_Pin")
        public var pdfLogo : Image = loadImageSafely(with: "pdf_New")
        
        public var playVideo : Image = loadImageSafely(with: "play")
        public var pauseVideo : Image = loadImageSafely(with: "pause")
        
        
        
        
        //editor
        public var cropImageButton : Image = loadImageSafely(with: "crop_Image")
        public var addTextOnImageButton : Image = loadImageSafely(with: "AddText")
        public var editImageButton : Image = loadImageSafely(with: "edit_Image")
        public var deleteImageButton : Image = loadImageSafely(with: "Delete_Image")
        
        //messageStatus
        
        public var messagePending : Image = loadImageSafely(with: "clock")
        public var messageSent : Image = loadImageSafely(with: "single_tick_sent")
        public var messageDelivered : Image = loadImageSafely(with: "double_tick_sent")
        public var messageRead : Image = loadImageSafely(with: "double_tick_received")
        
        //contextMenu
        public var contextMenu_reply : Image = loadImageSafely(with: "reply_CM")
        public var contextMenu_forward : Image = loadImageSafely(with: "forward_CM")
        public var contextMenu_edit : Image = loadImageSafely(with: "edit_CM")
        public var contextMenu_copy : Image = loadImageSafely(with: "copy_CM")
        public var contextMenu_info : Image = loadImageSafely(with: "info_CM")
        public var contextMenu_delete : Image = loadImageSafely(with: "delete_CM")
        
        
        //calling
        public var audioIncoming : Image = loadImageSafely(with: "audio_incoming")
        public var audioOutgoing : Image = loadImageSafely(with: "audio_outgoing")
        public var audioMissedCall : Image = loadImageSafely(with: "audio_missedCall")
        public var videoIncoming : Image = loadImageSafely(with: "video_incoming")
        public var videoOutgoing : Image = loadImageSafely(with: "video_outgoing")
        public var videoMissedCall : Image = loadImageSafely(with: "video_missedCall")
        
        public var cancel : Image = loadImageSafely(with: "cancel_Reply")
        public var cancelWithBlackBackground : Image = loadImageSafely(with: "close_black_background")
        public var cancelWithGreyBackground : Image = loadImageSafely(with: "closeGroup")
        public var disclouser: Image = loadImageSafely(with: "disclouser")
        public var broadcastInfo : Image = loadImageSafely(with: "info_broadcast")
        public var imageLoading : Image = loadImageSafely(with: "loading")
        
        
        //User remove
        public var removeMember : Image = loadImageSafely(with: "removeMember")
        public var removeUserFromSelectedFromList : Image = loadImageSafely(with: "removeUser")
        
        //message
        public var selected : Image = loadImageSafely(with: "selected")
        public var deselected : Image = loadImageSafely(with: "unselected")
        public var sendMessage : Image = loadImageSafely(with: "send_Media")
        public var mapTarget : Image = loadImageSafely(with: "target")
        public var noMessagePlaceholder : Image = loadImageSafely(with: "NoMessages")
        
        
        //
        public var chevron_right : Image = loadImageSafely(with: "chevron_right")
        public var removeSearchText : Image = loadSafely(systemName: "xmark.circle.fill", assetsFallback: "xmark.circle.fill")
        public var CloseSheet : Image = loadImageSafely(with: "CloseScreen")
        public var LogoutIcon : Image = loadImageSafely(with: "Logout")
        public var mediaIcon : Image = loadImageSafely(with: "media")
        public var NotificationsIcon : Image = loadImageSafely(with: "Notifications")
        public var lastSeenIcon : Image = loadImageSafely(with: "lastSeen")
        public var searchMagnifingGlass : Image = loadImageSafely(with: "searchParticipant")
        
        //contactInfo
        public var addMembers : Image = loadImageSafely(with: "Addparticipants")
        public var groupMembers : Image = loadImageSafely(with: "Group_Member")
        public var noDocPlaceholder : Image = loadImageSafely(with: "No_Docs")
        public var noLinkPlaceholder : Image = loadImageSafely(with: "No_Links")
        public var noMediaPlaceholder : Image = loadImageSafely(with: "No_Media")
        
        public var share : Image = loadSafely(systemName: "square.and.arrow.up", assetsFallback: "square.and.arrow.up")
        
        
        
        
        
        //reply toolbar
        public var replyVideoIcon : Image = loadSafely(systemName: "video.fill", assetsFallback: "video.fill")
        public var replyCameraIcon : Image = loadSafely(systemName: "camera.fill", assetsFallback: "camera.fill")
        public var replyAudioIcon : Image = loadSafely(systemName: "mic", assetsFallback: "mic")
        public var replyDocumentIcon : Image = loadImageSafely(with: "pdf_New")
        public var replyLocationIcon : Image = loadSafely(systemName: "location.fill", assetsFallback: "location.fill")
        public var replyContactIcon : Image = loadSafely(systemName: "person.crop.circle.fill", assetsFallback: "person.crop.circle.fill")
        public var replyGifIcon : Image = loadImageSafely(with: "gif_logo")
        public var cancelReplyMessageSelected : Image = loadImageSafely(with: "cancel_Reply")
        
        //toolbar
        public var addAttcahment : Image = loadImageSafely(with: "addAttachments")
        public var addSticker : Image = loadImageSafely(with: "gif_sticker")
        public var addAudio : Image = loadImageSafely(with: "audio")
        public var chevranbackward : Image = loadSafely(systemName: "chevron.backward", assetsFallback: "chevron.backward")
        public var trash : Image = loadSafely(systemName: "trash", assetsFallback: "trash")
        public var audioLock : Image = loadSafely(systemName: "lock", assetsFallback: "lock")
        public var blockIcon : Image = loadSafely(systemName: "circle.slash", assetsFallback: "circle.slash")
        

        public var fileFallback: Image = loadImageSafely(with: "generic")
        
        public init(){}
        
        public init(addConversation: Image, conversationListPlaceholder: Image, backButton: Image, backButtonGrey: Image, videoCall: Image, audioCall: Image, threeDots: Image, blockedUserListPlaceholder: Image, scrollToBottomArrow: Image, broadCastLogo: Image, broadCastMessageLogo: Image, broadcastInUserList: Image, forwardLogo: Image, gifLogo: Image, stickerLogo: Image, linkLogo: Image, mapPinLogo: Image, pdfLogo: Image, playVideo: Image, pauseVideo: Image, cropImageButton: Image, addTextOnImageButton: Image, editImageButton: Image, deleteImageButton: Image, messagePending: Image, messageSent: Image, messageDelivered: Image, messageRead: Image, contextMenu_reply: Image, contextMenu_forward: Image, contextMenu_edit: Image, contextMenu_copy: Image, contextMenu_info: Image, contextMenu_delete: Image, audioIncoming: Image, audioOutgoing: Image, audioMissedCall: Image, videoIncoming: Image, videoOutgoing: Image, videoMissedCall: Image, cancel: Image, cancelWithBlackBackground: Image, cancelWithGreyBackground: Image, disclouser: Image, broadcastInfo: Image, imageLoading: Image, removeMemberIncoming: Image, removeUserFromSelected: Image, selected: Image, deselected: Image, sendMessage: Image, mapTarget: Image, noMessagePlaceholder: Image, chevron_right: Image, CloseSheet: Image, LogoutIcon: Image, mediaIcon: Image, NotificationsIcon: Image, searchMagnifingGlass: Image, addMembers: Image, groupMembers: Image, noDocPlaceholder: Image, noLinkPlaceholder: Image, noMediaPlaceholder: Image, replyVideoIcon: Image, replyCameraIcon: Image, replyAudioIcon: Image, replyDocumentIcon: Image, replyLocationIcon: Image, replyContactIcon: Image, replyGifIcon: Image, cancelReplyMessageSelected: Image, addAttcahment: Image, addSticker: Image, addAudio: Image, chevranbackward: Image, trash: Image, audioLock: Image, blockIcon: Image, fileFallback: Image) {
            self.addConversation = addConversation
            self.conversationListPlaceholder = conversationListPlaceholder
            self.backButton = backButton
            self.backButtonGrey = backButtonGrey
            self.videoCall = videoCall
            self.audioCall = audioCall
            self.threeDots = threeDots
            self.blockedUserListPlaceholder = blockedUserListPlaceholder
            self.scrollToBottomArrow = scrollToBottomArrow
            self.broadCastLogo = broadCastLogo
            self.broadCastMessageLogo = broadCastMessageLogo
            self.broadcastInUserList = broadcastInUserList
            self.forwardLogo = forwardLogo
            self.gifLogo = gifLogo
            self.stickerLogo = stickerLogo
            self.linkLogo = linkLogo
            self.mapPinLogo = mapPinLogo
            self.pdfLogo = pdfLogo
            self.playVideo = playVideo
            self.pauseVideo = pauseVideo
            self.cropImageButton = cropImageButton
            self.addTextOnImageButton = addTextOnImageButton
            self.editImageButton = editImageButton
            self.deleteImageButton = deleteImageButton
            self.messagePending = messagePending
            self.messageSent = messageSent
            self.messageDelivered = messageDelivered
            self.messageRead = messageRead
            self.contextMenu_reply = contextMenu_reply
            self.contextMenu_forward = contextMenu_forward
            self.contextMenu_edit = contextMenu_edit
            self.contextMenu_copy = contextMenu_copy
            self.contextMenu_info = contextMenu_info
            self.contextMenu_delete = contextMenu_delete
            self.audioIncoming = audioIncoming
            self.audioOutgoing = audioOutgoing
            self.audioMissedCall = audioMissedCall
            self.videoIncoming = videoIncoming
            self.videoOutgoing = videoOutgoing
            self.videoMissedCall = videoMissedCall
            self.cancel = cancel
            self.cancelWithBlackBackground = cancelWithBlackBackground
            self.cancelWithGreyBackground = cancelWithGreyBackground
            self.disclouser = disclouser
            self.broadcastInfo = broadcastInfo
            self.imageLoading = imageLoading
            self.removeMember = removeMemberIncoming
            self.removeUserFromSelectedFromList = removeUserFromSelected
            self.selected = selected
            self.deselected = deselected
            self.sendMessage = sendMessage
            self.mapTarget = mapTarget
            self.noMessagePlaceholder = noMessagePlaceholder
            self.chevron_right = chevron_right
            self.CloseSheet = CloseSheet
            self.LogoutIcon = LogoutIcon
            self.mediaIcon = mediaIcon
            self.NotificationsIcon = NotificationsIcon
            self.searchMagnifingGlass = searchMagnifingGlass
            self.addMembers = addMembers
            self.groupMembers = groupMembers
            self.noDocPlaceholder = noDocPlaceholder
            self.noLinkPlaceholder = noLinkPlaceholder
            self.noMediaPlaceholder = noMediaPlaceholder
            self.replyVideoIcon = replyVideoIcon
            self.replyCameraIcon = replyCameraIcon
            self.replyAudioIcon = replyAudioIcon
            self.replyDocumentIcon = replyDocumentIcon
            self.replyLocationIcon = replyLocationIcon
            self.replyContactIcon = replyContactIcon
            self.replyGifIcon = replyGifIcon
            self.cancelReplyMessageSelected = cancelReplyMessageSelected
            self.addAttcahment = addAttcahment
            self.addSticker = addSticker
            self.addAudio = addAudio
            self.chevranbackward = chevranbackward
            self.trash = trash
            self.audioLock = audioLock
            self.blockIcon = blockIcon
            self.fileFallback = fileFallback
        }

    }

