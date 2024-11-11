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
    public var conversationListPlaceholder : Image = loadImageSafely(with: "default_Placeholder_CL")
    
    
    //messageList
    public var backButton : Image = loadImageSafely(with: "Back")
    public var backButtonGrey : Image = loadImageSafely(with: "back_Button")
    public var videoCall : Image = loadImageSafely(with: "video_Calling")
    public var audioCall : Image = loadImageSafely(with: "audio_Calling")
    public var threeDots : Image = loadImageSafely(with: "more")
    
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
    
    public var refreshLocationLogo : Image = loadImageSafely(with: "refreshLogo")
    public var locationLogo : Image = loadImageSafely(with: "near_me")
    
    
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
    public var broadcastMessageStatus : Image = loadImageSafely(with: "broadcastMessageIcon")
    
    //contextMenu
    public var contextMenureply : Image = loadImageSafely(with: "reply_CM")
    public var contextMenuforward : Image = loadImageSafely(with: "forward_CM")
    public var contextMenuedit : Image = loadImageSafely(with: "edit_CM")
    public var contextMenucopy : Image = loadImageSafely(with: "copy_CM")
    public var contextMenuinfo : Image = loadImageSafely(with: "info_CM")
    public var contextMenudelete : Image = loadImageSafely(with: "delete_CM")
    
    
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
    public var sendMessage : Image = loadImageSafely(with: "sendMessage")
    public var sendMedia : Image = loadImageSafely(with: "send_Media")
    public var mapTarget : Image = loadImageSafely(with: "target")
    public var noMessagePlaceholder : Image = loadImageSafely(with: "NoMessages")
    
    public var postIcon : Image = loadImageSafely(with: "postIcon")
    public var forwardedIcon : Image = loadImageSafely(with: "forwarded")
    
    //
    public var chevronright : Image = loadImageSafely(with: "chevron_right")
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
    public var searchIcon : Image = loadImageSafely(with: "search-normal")
    
    public var influencerUserIcon : Image = loadImageSafely(with: "gif_logo")
    public var businessUserIcon : Image = loadImageSafely(with: "gif_logo")
    
    public var calanderLogo : Image = loadImageSafely(with: "gif_logo")
    
    public var mediaEditorCrop : Image = loadImageSafely(with: "crop_Image")
    public var mediaEditorText : Image = loadImageSafely(with: "AddText")
    public var mediaEditorEdit : Image = loadImageSafely(with: "edit_Image")
    public var mediaEditorCancel : Image = loadImageSafely(with: "close_black_background")
    
    public var audioPlayIcon : Image = loadImageSafely(with: "Audio_play")
    public var audioPauseIcon : Image = loadImageSafely(with: "Audio_pause")
    public var messageLock : Image = loadSafely(systemName: "lock.fill", assetsFallback: "lock.fill")
    
    public init(){}
    
    public init(
        addConversation: Image? = nil,
        conversationListPlaceholder: Image? = nil,
        backButton: Image? = nil,
        backButtonGrey: Image? = nil,
        videoCall: Image? = nil,
        audioCall: Image? = nil,
        threeDots: Image? = nil,
        blockedUserListPlaceholder: Image? = nil,
        scrollToBottomArrow: Image? = nil,
        broadCastLogo: Image? = nil,
        broadCastMessageLogo: Image? = nil,
        broadcastInUserList: Image? = nil,
        forwardLogo: Image? = nil,
        gifLogo: Image? = nil,
        stickerLogo: Image? = nil,
        linkLogo: Image? = nil,
        mapPinLogo: Image? = nil,
        pdfLogo: Image? = nil,
        playVideo: Image? = nil,
        pauseVideo: Image? = nil,
        cropImageButton: Image? = nil,
        addTextOnImageButton: Image? = nil,
        editImageButton: Image? = nil,
        deleteImageButton: Image? = nil,
        messagePending: Image? = nil,
        messageSent: Image? = nil,
        messageDelivered: Image? = nil,
        messageRead: Image? = nil,
        broadcastMessageStatus: Image? = nil,
        contextMenureply: Image? = nil,
        contextMenuforward: Image? = nil,
        contextMenuedit: Image? = nil,
        contextMenucopy: Image? = nil,
        contextMenuinfo: Image? = nil,
        contextMenudelete: Image? = nil,
        audioIncoming: Image? = nil,
        audioOutgoing: Image? = nil,
        audioMissedCall: Image? = nil,
        videoIncoming: Image? = nil,
        videoOutgoing: Image? = nil,
        videoMissedCall: Image? = nil,
        cancel: Image? = nil,
        cancelWithBlackBackground: Image? = nil,
        cancelWithGreyBackground: Image? = nil,
        disclouser: Image? = nil,
        broadcastInfo: Image? = nil,
        imageLoading: Image? = nil,
        removeMember: Image? = nil,
        removeUserFromSelectedFromList: Image? = nil,
        selected: Image? = nil,
        deselected: Image? = nil,
        sendMessage: Image? = nil,
        mapTarget: Image? = nil,
        noMessagePlaceholder: Image? = nil,
        postIcon: Image? = nil,
        chevronright: Image? = nil,
        CloseSheet: Image? = nil,
        LogoutIcon: Image? = nil,
        mediaIcon: Image? = nil,
        NotificationsIcon: Image? = nil,
        searchMagnifingGlass: Image? = nil,
        addMembers: Image? = nil,
        groupMembers: Image? = nil,
        noDocPlaceholder: Image? = nil,
        noLinkPlaceholder: Image? = nil,
        noMediaPlaceholder: Image? = nil,
        replyVideoIcon: Image? = nil,
        replyCameraIcon: Image? = nil,
        replyAudioIcon: Image? = nil,
        replyDocumentIcon: Image? = nil,
        replyLocationIcon: Image? = nil,
        replyContactIcon: Image? = nil,
        replyGifIcon: Image? = nil,
        cancelReplyMessageSelected: Image? = nil,
        addAttcahment: Image? = nil,
        addSticker: Image? = nil,
        addAudio: Image? = nil,
        chevranbackward: Image? = nil,
        trash: Image? = nil,
        audioLock: Image? = nil,
        blockIcon: Image? = nil,
        fileFallback: Image? = nil,
        searchIcon : Image? = nil,
        influencerUserIcon : Image? = nil,
        businessUserIcon : Image? = nil,
        calanderLogo : Image? = nil,
        messageLock : Image? = nil
    ) {
        if let addConversation = addConversation { self.addConversation = addConversation }
        if let conversationListPlaceholder = conversationListPlaceholder { self.conversationListPlaceholder = conversationListPlaceholder }
        if let backButton = backButton { self.backButton = backButton }
        if let backButtonGrey = backButtonGrey { self.backButtonGrey = backButtonGrey }
        if let videoCall = videoCall { self.videoCall = videoCall }
        if let audioCall = audioCall { self.audioCall = audioCall }
        if let threeDots = threeDots { self.threeDots = threeDots }
        if let blockedUserListPlaceholder = blockedUserListPlaceholder { self.blockedUserListPlaceholder = blockedUserListPlaceholder }
        if let scrollToBottomArrow = scrollToBottomArrow { self.scrollToBottomArrow = scrollToBottomArrow }
        if let broadCastLogo = broadCastLogo { self.broadCastLogo = broadCastLogo }
        if let broadCastMessageLogo = broadCastMessageLogo { self.broadCastMessageLogo = broadCastMessageLogo }
        if let broadcastInUserList = broadcastInUserList { self.broadcastInUserList = broadcastInUserList }
        if let forwardLogo = forwardLogo { self.forwardLogo = forwardLogo }
        if let gifLogo = gifLogo { self.gifLogo = gifLogo }
        if let stickerLogo = stickerLogo { self.stickerLogo = stickerLogo }
        if let linkLogo = linkLogo { self.linkLogo = linkLogo }
        if let mapPinLogo = mapPinLogo { self.mapPinLogo = mapPinLogo }
        if let pdfLogo = pdfLogo { self.pdfLogo = pdfLogo }
        if let playVideo = playVideo { self.playVideo = playVideo }
        if let pauseVideo = pauseVideo { self.pauseVideo = pauseVideo }
        if let cropImageButton = cropImageButton { self.cropImageButton = cropImageButton }
        if let addTextOnImageButton = addTextOnImageButton { self.addTextOnImageButton = addTextOnImageButton }
        if let editImageButton = editImageButton { self.editImageButton = editImageButton }
        if let deleteImageButton = deleteImageButton { self.deleteImageButton = deleteImageButton }
        if let messagePending = messagePending { self.messagePending = messagePending }
        if let messageSent = messageSent { self.messageSent = messageSent }
        if let messageDelivered = messageDelivered { self.messageDelivered = messageDelivered }
        if let messageRead = messageRead { self.messageRead = messageRead }
        if let broadcastMessageStatus = broadcastMessageStatus { self.broadcastMessageStatus = broadcastMessageStatus}
        if let contextMenureply = contextMenureply { self.contextMenureply = contextMenureply }
        if let contextMenuforward = contextMenuforward { self.contextMenuforward = contextMenuforward }
        if let contextMenuedit = contextMenuedit { self.contextMenuedit = contextMenuedit }
        if let contextMenucopy = contextMenucopy { self.contextMenucopy = contextMenucopy }
        if let contextMenuinfo = contextMenuinfo { self.contextMenuinfo = contextMenuinfo }
        if let contextMenudelete = contextMenudelete { self.contextMenudelete = contextMenudelete }
        if let audioIncoming = audioIncoming { self.audioIncoming = audioIncoming }
        if let audioOutgoing = audioOutgoing { self.audioOutgoing = audioOutgoing }
        if let audioMissedCall = audioMissedCall { self.audioMissedCall = audioMissedCall }
        if let videoIncoming = videoIncoming { self.videoIncoming = videoIncoming }
        if let videoOutgoing = videoOutgoing { self.videoOutgoing = videoOutgoing }
        if let videoMissedCall = videoMissedCall { self.videoMissedCall = videoMissedCall }
        if let cancel = cancel { self.cancel = cancel }
        if let cancelWithBlackBackground = cancelWithBlackBackground { self.cancelWithBlackBackground = cancelWithBlackBackground }
        if let cancelWithGreyBackground = cancelWithGreyBackground { self.cancelWithGreyBackground = cancelWithGreyBackground }
        if let disclouser = disclouser { self.disclouser = disclouser }
        if let broadcastInfo = broadcastInfo { self.broadcastInfo = broadcastInfo }
        if let imageLoading = imageLoading { self.imageLoading = imageLoading }
        if let removeMember = removeMember { self.removeMember = removeMember }
        if let removeUserFromSelectedFromList = removeUserFromSelectedFromList { self.removeUserFromSelectedFromList = removeUserFromSelectedFromList }
        if let selected = selected { self.selected = selected }
        if let deselected = deselected { self.deselected = deselected }
        if let sendMessage = sendMessage { self.sendMessage = sendMessage }
        if let mapTarget = mapTarget { self.mapTarget = mapTarget }
        if let noMessagePlaceholder = noMessagePlaceholder { self.noMessagePlaceholder = noMessagePlaceholder }
        if let postIcon = postIcon { self.postIcon = postIcon }
        if let chevronright = chevronright { self.chevronright = chevronright }
        if let CloseSheet = CloseSheet { self.CloseSheet = CloseSheet }
        if let LogoutIcon = LogoutIcon { self.LogoutIcon = LogoutIcon }
        if let mediaIcon = mediaIcon { self.mediaIcon = mediaIcon }
        if let NotificationsIcon = NotificationsIcon { self.NotificationsIcon = NotificationsIcon }
        if let searchMagnifingGlass = searchMagnifingGlass { self.searchMagnifingGlass = searchMagnifingGlass }
        if let addMembers = addMembers { self.addMembers = addMembers }
        if let groupMembers = groupMembers { self.groupMembers = groupMembers }
        if let noDocPlaceholder = noDocPlaceholder { self.noDocPlaceholder = noDocPlaceholder }
        if let noLinkPlaceholder = noLinkPlaceholder { self.noLinkPlaceholder = noLinkPlaceholder }
        if let noMediaPlaceholder = noMediaPlaceholder { self.noMediaPlaceholder = noMediaPlaceholder }
        if let replyVideoIcon = replyVideoIcon { self.replyVideoIcon = replyVideoIcon }
        if let replyCameraIcon = replyCameraIcon { self.replyCameraIcon = replyCameraIcon }
        if let replyAudioIcon = replyAudioIcon { self.replyAudioIcon = replyAudioIcon }
        if let replyDocumentIcon = replyDocumentIcon { self.replyDocumentIcon = replyDocumentIcon }
        if let replyLocationIcon = replyLocationIcon { self.replyLocationIcon = replyLocationIcon }
        if let replyContactIcon = replyContactIcon { self.replyContactIcon = replyContactIcon }
        if let replyGifIcon = replyGifIcon { self.replyGifIcon = replyGifIcon }
        if let cancelReplyMessageSelected = cancelReplyMessageSelected { self.cancelReplyMessageSelected = cancelReplyMessageSelected }
        if let addAttcahment = addAttcahment { self.addAttcahment = addAttcahment }
        if let addSticker = addSticker { self.addSticker = addSticker }
        if let addAudio = addAudio { self.addAudio = addAudio }
        if let chevranbackward = chevranbackward { self.chevranbackward = chevranbackward }
        if let trash = trash { self.trash = trash }
        if let audioLock = audioLock { self.audioLock = audioLock }
        if let blockIcon = blockIcon { self.blockIcon = blockIcon }
        if let fileFallback = fileFallback { self.fileFallback = fileFallback }
        if let searchIcon = searchIcon { self.searchIcon = searchIcon }
        if let influencerUserIcon = influencerUserIcon { self.influencerUserIcon = influencerUserIcon }
        if let businessUserIcon = businessUserIcon { self.businessUserIcon = businessUserIcon }
        if let calanderLogo = calanderLogo { self.calanderLogo = calanderLogo }
        if let messageLock = messageLock { self.messageLock = messageLock }
    }
    
}

