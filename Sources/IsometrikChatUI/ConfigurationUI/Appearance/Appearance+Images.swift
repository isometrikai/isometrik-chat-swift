//
//  ChatsView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 23/01/23.
//


import UIKit
import SwiftUI


public struct ISMChatImages {
    
    private static func loadImageSafely(with imageName: String) -> Image {
        return Image(imageName, bundle: .isometrikChat)
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
    public var conversationListPlaceholder : Image = loadImageSafely(with: "defaultPlaceholderCL")
    
    
    //messageList
    public var backButton : Image = loadImageSafely(with: "Back")
    public var backButtonGrey : Image = loadImageSafely(with: "backButton")
    public var videoCall : Image = loadImageSafely(with: "videoCalling")
    public var audioCall : Image = loadImageSafely(with: "audioCalling")
    public var threeDots : Image = loadSafely(systemName: "ellipsis", assetsFallback: "ellipsis")
    
    public var blockedUserListPlaceholder : Image = loadImageSafely(with: "BlockedUser")
    public var scrollToBottomArrow : Image = loadImageSafely(with: "bottomarrow")
    public var broadCastLogo : Image = loadImageSafely(with: "broadCastlogo")
    public var broadCastMessageLogo : Image = loadImageSafely(with: "broadcastMessageIcon")
    public var broadcastInUserList : Image = loadImageSafely(with: "megaphone")
    public var forwardLogo : Image = loadImageSafely(with: "forwarded")
    public var gifLogo : Image = loadImageSafely(with: "giflogo")
    public var stickerLogo : Image = loadImageSafely(with: "gifsticker")
    public var linkLogo : Image = loadImageSafely(with: "link")
    public var mapPinLogo : Image = loadImageSafely(with: "mapPin")
    public var pdfLogo : Image = loadImageSafely(with: "pdfNew")
    
    public var playVideo : Image = loadImageSafely(with: "play")
    public var pauseVideo : Image = loadImageSafely(with: "pause")
    
    
    
    
    //editor
    public var cropImageButton : Image = loadImageSafely(with: "cropImage")
    public var addTextOnImageButton : Image = loadImageSafely(with: "AddText")
    public var editImageButton : Image = loadImageSafely(with: "editImage")
    public var deleteImageButton : Image = loadImageSafely(with: "DeleteImage")
    
    //messageStatus
    
    public var messagePending : Image = loadImageSafely(with: "clock")
    public var messageSent : Image = loadImageSafely(with: "singleticksent")
    public var messageDelivered : Image = loadImageSafely(with: "doubleticksent")
    public var messageRead : Image = loadImageSafely(with: "doubletickreceived")
    
    //contextMenu
    public var contextMenureply : Image = loadImageSafely(with: "replyCM")
    public var contextMenuforward : Image = loadImageSafely(with: "forwardCM")
    public var contextMenuedit : Image = loadImageSafely(with: "editCM")
    public var contextMenucopy : Image = loadImageSafely(with: "copyCM")
    public var contextMenuinfo : Image = loadImageSafely(with: "infoCM")
    public var contextMenudelete : Image = loadImageSafely(with: "deleteCM")
    
    
    //calling
    public var audioIncoming : Image = loadImageSafely(with: "audioincoming")
    public var audioOutgoing : Image = loadImageSafely(with: "audiooutgoing")
    public var audioMissedCall : Image = loadImageSafely(with: "audiomissedCall")
    public var videoIncoming : Image = loadImageSafely(with: "videoincoming")
    public var videoOutgoing : Image = loadImageSafely(with: "videooutgoing")
    public var videoMissedCall : Image = loadImageSafely(with: "videomissedCall")
    
    public var cancel : Image = loadImageSafely(with: "cancelReply")
    public var cancelWithBlackBackground : Image = loadImageSafely(with: "closeblackbackground")
    public var cancelWithGreyBackground : Image = loadImageSafely(with: "closeGroup")
    public var disclouser: Image = loadImageSafely(with: "disclouser")
    public var broadcastInfo : Image = loadImageSafely(with: "infobroadcast")
    public var imageLoading : Image = loadImageSafely(with: "loading")
    
    
    //User remove
    public var removeMember : Image = loadImageSafely(with: "removeMember")
    public var removeUserFromSelectedFromList : Image = loadImageSafely(with: "removeUser")
    
    //message
    public var selected : Image = loadImageSafely(with: "selected")
    public var deselected : Image = loadImageSafely(with: "unselected")
    public var sendMessage : Image = loadImageSafely(with: "sendMedia")
    public var mapTarget : Image = loadImageSafely(with: "target")
    public var noMessagePlaceholder : Image = loadImageSafely(with: "NoMessages")
    
    
    //
    public var chevronright : Image = loadImageSafely(with: "chevronright")
    public var removeSearchText : Image = loadSafely(systemName: "xmark.circle.fill", assetsFallback: "xmark.circle.fill")
    public var CloseSheet : Image = loadImageSafely(with: "CloseScreen")
    public var LogoutIcon : Image = loadImageSafely(with: "Logout")
    public var mediaIcon : Image = loadImageSafely(with: "media")
    public var NotificationsIcon : Image = loadImageSafely(with: "Notifications")
    public var lastSeenIcon : Image = loadImageSafely(with: "lastSeen")
    public var searchMagnifingGlass : Image = loadImageSafely(with: "searchParticipant")
    
    //contactInfo
    public var addMembers : Image = loadImageSafely(with: "Addparticipants")
    public var groupMembers : Image = loadImageSafely(with: "GroupMember")
    public var noDocPlaceholder : Image = loadImageSafely(with: "NoDocs")
    public var noLinkPlaceholder : Image = loadImageSafely(with: "NoLinks")
    public var noMediaPlaceholder : Image = loadImageSafely(with: "NoMedia")
    
    public var share : Image = loadSafely(systemName: "square.and.arrow.up", assetsFallback: "square.and.arrow.up")
    
    
    
    
    
    //reply toolbar
    public var replyVideoIcon : Image = loadSafely(systemName: "video.fill", assetsFallback: "video.fill")
    public var replyCameraIcon : Image = loadSafely(systemName: "camera.fill", assetsFallback: "camera.fill")
    public var replyAudioIcon : Image = loadSafely(systemName: "mic", assetsFallback: "mic")
    public var replyDocumentIcon : Image = loadImageSafely(with: "pdfNew")
    public var replyLocationIcon : Image = loadSafely(systemName: "location.fill", assetsFallback: "location.fill")
    public var replyContactIcon : Image = loadSafely(systemName: "person.crop.circle.fill", assetsFallback: "person.crop.circle.fill")
    public var replyGifIcon : Image = loadImageSafely(with: "giflogo")
    public var cancelReplyMessageSelected : Image = loadImageSafely(with: "cancelReply")
    
    //toolbar
    public var addAttcahment : Image = loadImageSafely(with: "addAttachments")
    public var addSticker : Image = loadImageSafely(with: "gifsticker")
    public var addAudio : Image = loadImageSafely(with: "audio")
    public var chevranbackward : Image = loadSafely(systemName: "chevron.backward", assetsFallback: "chevron.backward")
    public var trash : Image = loadSafely(systemName: "trash", assetsFallback: "trash")
    public var audioLock : Image = loadSafely(systemName: "lock", assetsFallback: "lock")
    public var blockIcon : Image = loadSafely(systemName: "circle.slash", assetsFallback: "circle.slash")
    
    
    public var fileFallback: Image = loadImageSafely(with: "generic")
    
    public init(){}
    
    public init(addConversation: Image, conversationListPlaceholder: Image, backButton: Image, backButtonGrey: Image, videoCall: Image, audioCall: Image, threeDots: Image, blockedUserListPlaceholder: Image, scrollToBottomArrow: Image, broadCastLogo: Image, broadCastMessageLogo: Image, broadcastInUserList: Image, forwardLogo: Image, gifLogo: Image, stickerLogo: Image, linkLogo: Image, mapPinLogo: Image, pdfLogo: Image, playVideo: Image, pauseVideo: Image, cropImageButton: Image, addTextOnImageButton: Image, editImageButton: Image, deleteImageButton: Image, messagePending: Image, messageSent: Image, messageDelivered: Image, messageRead: Image, contextMenureply: Image, contextMenuforward: Image, contextMenuedit: Image, contextMenucopy: Image, contextMenuinfo: Image, contextMenudelete: Image, audioIncoming: Image, audioOutgoing: Image, audioMissedCall: Image, videoIncoming: Image, videoOutgoing: Image, videoMissedCall: Image, cancel: Image, cancelWithBlackBackground: Image, cancelWithGreyBackground: Image, disclouser: Image, broadcastInfo: Image, imageLoading: Image, removeMemberIncoming: Image, removeUserFromSelected: Image, selected: Image, deselected: Image, sendMessage: Image, mapTarget: Image, noMessagePlaceholder: Image, chevronright: Image, CloseSheet: Image, LogoutIcon: Image, mediaIcon: Image, NotificationsIcon: Image, searchMagnifingGlass: Image, addMembers: Image, groupMembers: Image, noDocPlaceholder: Image, noLinkPlaceholder: Image, noMediaPlaceholder: Image, replyVideoIcon: Image, replyCameraIcon: Image, replyAudioIcon: Image, replyDocumentIcon: Image, replyLocationIcon: Image, replyContactIcon: Image, replyGifIcon: Image, cancelReplyMessageSelected: Image, addAttcahment: Image, addSticker: Image, addAudio: Image, chevranbackward: Image, trash: Image, audioLock: Image, blockIcon: Image, fileFallback: Image) {
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
        self.contextMenureply = contextMenureply
        self.contextMenuforward = contextMenuforward
        self.contextMenuedit = contextMenuedit
        self.contextMenucopy = contextMenucopy
        self.contextMenuinfo = contextMenuinfo
        self.contextMenudelete = contextMenudelete
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
        self.chevronright = chevronright
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

