//
//  Appearance+Strings.swift
//  IsometrikChat
//
//  Created by My Book on 30/12/24.
//


import Foundation
import SwiftUI

public struct ISMChatString {
    
    private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
        let format = ISMAppearance.localizationProvider(key, table)
        return String(format: format, locale: Locale.current, arguments: args)
    }
    // General Chat Strings
    public var chats: String = tr("Localizable", "chats")
    public var newChat: String = tr("Localizable", "newChat")
    public var tapHereForMoreInfo: String = tr("Localizable", "tapHereForMoreInfo")
    public var today: String = tr("Localizable", "today")
    public var endToEndEncryptedMessage: String = tr("Localizable", "endToEndEncryptedMessage")
    public var typeAMessage: String = tr("Localizable", "typeAMessage")
    public var youDeletedThisMessage: String = tr("Localizable", "youDeletedThisMessage")
    public var thisMessageWasDeleted: String = tr("Localizable", "thisMessageWasDeleted")
    public var sendTo: String = tr("Localizable", "sendTo")
    public var maxShareLimit: String = tr("Localizable", "maxShareLimit")
    public var messageForwarded: String = tr("Localizable", "messageForwarded")
    public var readBy: String = tr("Localizable", "readBy")
    public var deliveredTo: String = tr("Localizable", "deliveredTo")
    public var read: String = tr("Localizable", "read")
    public var delivered: String = tr("Localizable", "delivered")
    public var messageInfo: String = tr("Localizable", "messageInfo")
    public var messageCopied: String = tr("Localizable", "messageCopied")
    public var unblockContact: String = tr("Localizable", "unblockContact")

    // General UI and Errors
    public var ok: String = tr("Localizable", "ok")
    public var noInternetMessage: String = tr("Localizable", "noInternetMessage")
    public var call: String = tr("Localizable", "call")
    public var cancel: String = tr("Localizable", "cancel")
    public var voiceCall: String = tr("Localizable", "voiceCall")
    public var videoCall: String = tr("Localizable", "videoCall")
    public var andOthers: String = tr("Localizable", "andOthers")
    public var actionNotAllowedBlocked: String = tr("Localizable", "actionNotAllowedBlocked")
    public var clearAllMessages: String = tr("Localizable", "clearAllMessages")
    public var thisChat: String = tr("Localizable", "thisChat")
    public var emptyChatWarning: String = tr("Localizable", "emptyChatWarning")
    public var blockedUserWarning: String = tr("Localizable", "blockedUserWarning")

    // Decline/Confirmation Actions
    public var declineRequest: String = tr("Localizable", "declineRequest")
    public var declinePaymentRequestWarning: String = tr("Localizable", "declinePaymentRequestWarning")
    public var declineRequestButton: String = tr("Localizable", "declineRequestButton")
    public var deleteMessage: String = tr("Localizable", "deleteMessage")
    public var deleteMessageWarning: String = tr("Localizable", "deleteMessageWarning")
    public var deleteForEveryone: String = tr("Localizable", "deleteForEveryone")
    public var deleteForMe: String = tr("Localizable", "deleteForMe")
    public var unblock: String = tr("Localizable", "unblock")
    public var blocked: String = tr("Localizable", "blocked")
    public var unblocked: String = tr("Localizable", "Unblocked")

    // Audio Permission
    public var audioPermissionRequired: String = tr("Localizable", "audioPermissionRequired")
    public var microphoneAccessMessage: String = tr("Localizable", "microphoneAccessMessage")
    public var openSettings: String = tr("Localizable", "openSettings")

    // Chat Group Strings
    public var groupMemberRestriction: String = tr("Localizable", "groupMemberRestriction")
    public var youBlockedUser: String = tr("Localizable", "youBlockedUser")
    public var youAreBlocked: String = tr("Localizable", "youAreBlocked")
    public var youUnblockedUser: String = tr("Localizable", "youUnblockedUser")
    public var youAreUnblocked: String = tr("Localizable", "youAreUnblocked")
    public var changedGroupTitle: String = tr("Localizable", "changedGroupTitle")
    public var changedGroupImage: String = tr("Localizable", "changedGroupImage")
    public var createdGroup: String = tr("Localizable", "createdGroup")
    public var userLeft: String = tr("Localizable", "userLeft")
    public var updatedNotificationSetting: String = tr("Localizable", "updatedNotificationSetting")

    // Message Requests
    public var messageRequestInfo: String = tr("Localizable", "messageRequestInfo")
    public var acceptMessageRequest: String = tr("Localizable", "acceptMessageRequest")
    public var reject: String = tr("Localizable", "reject")
    public var accept: String = tr("Localizable", "accept")
    public var openChatMessage: String = tr("Localizable", "openChatMessage")
    public var noOtherChatsFound: String = tr("Localizable", "noOtherChatsFound")
    public var newBroadcast: String = tr("Localizable", "newBroadcast")
    public var newGroup: String = tr("Localizable", "newGroup")
    public var enterGroupName: String = tr("Localizable", "enterGroupName")
    public var conversationCreated: String = tr("Localizable", "conversationCreated")

    // Chat Location
    public var shareLocation: String = tr("Localizable", "shareLocation")
    public var useMyCurrentLocation: String = tr("Localizable", "useMyCurrentLocation")
    public var useThisLocation: String = tr("Localizable", "useThisLocation")
    public var openInMaps: String = tr("Localizable", "openInMaps")
    public var sendLocation: String = tr("Localizable", "sendLocation")
    public var permissionDenied: String = tr("Localizable", "permissionDenied")
    public var enablePermissionMessage: String = tr("Localizable", "enablePermissionMessage")
    public var goToSettings: String = tr("Localizable", "goToSettings")
    public var sendCurrentLocation: String = tr("Localizable", "sendCurrentLocation")
    public var accurateTo5Meters: String = tr("Localizable", "accurateTo5Meters")
    public var nearbyPlaces: String = tr("Localizable", "nearbyPlaces")
    public var openInGoogleMaps: String = tr("Localizable", "openInGoogleMaps")

    // Chat Group View
    public var writeGroupName: String = tr("Localizable", "writeGroupName")
    public var editGroup: String = tr("Localizable", "editGroup")
    public var remove: String = tr("Localizable", "remove")
    public var groupNameEmptyWarning: String = tr("Localizable", "groupNameEmptyWarning")
    public var makeGroupAdmin: String = tr("Localizable", "makeGroupAdmin")
    public var dismissAsAdmin: String = tr("Localizable", "dismissAsAdmin")
    public var searchMembers: String = tr("Localizable", "searchMembers")
    public var removeFromGroup: String = tr("Localizable", "removeFromGroup")

    // Chat Interface Actions
    public var forward: String = tr("Localizable", "forward")
    public var reply: String = tr("Localizable", "reply")
    public var copy: String = tr("Localizable", "copy")
    public var edit: String = tr("Localizable", "edit")
    public var info: String = tr("Localizable", "info")
    public var delete: String = tr("Localizable", "delete")
    public var block: String = tr("Localizable", "block")

    // Chat Status
    public var online: String = tr("Localizable", "online")
    public var offline: String = tr("Localizable", "offline")
    public var typing: String = tr("Localizable", "typing")
    public var isTyping: String = tr("Localizable", "isTyping")
    public var lastSeen: String = tr("Localizable", "lastSeen")

    // Error Messages
    public var error: String = tr("Localizable", "error")
    public var noInternetConnection: String = tr("Localizable", "noInternetConnection")
    public var failedToSendMessage: String = tr("Localizable", "failedToSendMessage")
    public var pleaseTryAgain: String = tr("Localizable", "pleaseTryAgain")

    // Chat Management
    public var clearChat: String = tr("Localizable", "clearChat")
    public var blockUser: String = tr("Localizable", "blockUser")
    public var clearChatConfirmation: String = tr("Localizable", "clearChatConfirmation")
    public var clearChatWarning: String = tr("Localizable", "clearChatWarning")
    public var yesClear: String = tr("Localizable", "yesClear")
    public var blockUserConfirmation: String = tr("Localizable", "blockUserConfirmation")
    public var blockConfirmation: String = tr("Localizable", "blockConfirmation")

    // Chat Attachment
    public var camera: String = tr("Localizable", "camera")
    public var gallery: String = tr("Localizable", "gallery")
    public var document: String = tr("Localizable", "document")
    public var location: String = tr("Localizable", "location")
    public var contact: String = tr("Localizable", "contact")
    public var sticker: String = tr("Localizable", "sticker")

    // Chat Contact Info
    public var viewProfile: String = tr("Localizable", "viewProfile")
    public var mediaLinksAndDocs: String = tr("Localizable", "mediaLinksAndDocs")
    public var deleteChat: String = tr("Localizable", "deleteChat")
    public var enterNameAndProfilePic: String = tr("Localizable", "enterNameAndProfilePic")
    public var enterName: String = tr("Localizable", "enterName")
    public var email: String = tr("Localizable", "email")
    public var enterEmail: String = tr("Localizable", "enterEmail")
    public var about: String = tr("Localizable", "about")
    public var editProfile: String = tr("Localizable", "editProfile")
    public var emailEmptyWarning: String = tr("Localizable", "emailEmptyWarning")
    public var usernameEmptyWarning: String = tr("Localizable", "usernameEmptyWarning")
    public var logout: String = tr("Localizable", "logout")
    public var lastSeenLabel: String = tr("Localizable", "lastSeenLabel")
    public var notifications: String = tr("Localizable", "notifications")

    // Chat Reaction
    public var reacted: String = tr("Localizable", "reacted")
    public var toAMessage: String = tr("Localizable", "toAMessage")

    
    public init(
        chats: String? = nil,
        newChat: String? = nil,
        tapHereForMoreInfo: String? = nil,
        today: String? = nil,
        endToEndEncryptedMessage: String? = nil,
        typeAMessage: String? = nil,
        youDeletedThisMessage: String? = nil,
        thisMessageWasDeleted: String? = nil,
        sendTo: String? = nil,
        maxShareLimit: String? = nil,
        messageForwarded: String? = nil,
        readBy: String? = nil,
        deliveredTo: String? = nil,
        read: String? = nil,
        delivered: String? = nil,
        messageInfo: String? = nil,
        messageCopied: String? = nil,
        unblockContact: String? = nil,
        ok: String? = nil,
        noInternetMessage: String? = nil,
        call: String? = nil,
        cancel: String? = nil,
        voiceCall: String? = nil,
        videoCall: String? = nil,
        andOthers: String? = nil,
        actionNotAllowedBlocked: String? = nil,
        clearAllMessages: String? = nil,
        thisChat: String? = nil,
        emptyChatWarning: String? = nil,
        blockedUserWarning: String? = nil,
        declineRequest: String? = nil,
        declinePaymentRequestWarning: String? = nil,
        declineRequestButton: String? = nil,
        deleteMessage: String? = nil,
        deleteMessageWarning: String? = nil,
        deleteForEveryone: String? = nil,
        deleteForMe: String? = nil,
        unblock: String? = nil,
        blocked: String? = nil,
        unblocked: String? = nil,
        audioPermissionRequired: String? = nil,
        microphoneAccessMessage: String? = nil,
        openSettings: String? = nil,
        groupMemberRestriction: String? = nil,
        youBlockedUser: String? = nil,
        youAreBlocked: String? = nil,
        youUnblockedUser: String? = nil,
        youAreUnblocked: String? = nil,
        changedGroupTitle: String? = nil,
        changedGroupImage: String? = nil,
        createdGroup: String? = nil,
        userLeft: String? = nil,
        updatedNotificationSetting: String? = nil,
        messageRequestInfo: String? = nil,
        acceptMessageRequest: String? = nil,
        reject: String? = nil,
        accept: String? = nil,
        openChatMessage: String? = nil,
        noOtherChatsFound: String? = nil,
        newBroadcast: String? = nil,
        newGroup: String? = nil,
        enterGroupName: String? = nil,
        shareLocation: String? = nil,
        useMyCurrentLocation: String? = nil,
        useThisLocation: String? = nil,
        openInMaps: String? = nil,
        sendLocation: String? = nil,
        permissionDenied: String? = nil,
        enablePermissionMessage: String? = nil,
        goToSettings: String? = nil,
        sendCurrentLocation: String? = nil,
        accurateTo5Meters: String? = nil,
        nearbyPlaces: String? = nil,
        openInGoogleMaps: String? = nil,
        writeGroupName: String? = nil,
        editGroup: String? = nil,
        remove: String? = nil,
        groupNameEmptyWarning: String? = nil,
        makeGroupAdmin: String? = nil,
        dismissAsAdmin: String? = nil,
        searchMembers: String? = nil,
        removeFromGroup: String? = nil,
        forward: String? = nil,
        reply: String? = nil,
        copy: String? = nil,
        edit: String? = nil,
        info: String? = nil,
        delete: String? = nil,
        block: String? = nil,
        online: String? = nil,
        offline: String? = nil,
        typing: String? = nil,
        isTyping: String? = nil,
        lastSeen: String? = nil,
        error: String? = nil,
        noInternetConnection: String? = nil,
        failedToSendMessage: String? = nil,
        pleaseTryAgain: String? = nil,
        clearChat: String? = nil,
        blockUser: String? = nil,
        clearChatConfirmation: String? = nil,
        clearChatWarning: String? = nil,
        yesClear: String? = nil,
        blockUserConfirmation: String? = nil,
        blockConfirmation: String? = nil,
        camera: String? = nil,
        gallery: String? = nil,
        document: String? = nil,
        location: String? = nil,
        contact: String? = nil,
        sticker: String? = nil,
        viewProfile: String? = nil,
        mediaLinksAndDocs: String? = nil,
        deleteChat: String? = nil,
        enterNameAndProfilePic: String? = nil,
        enterName: String? = nil,
        email: String? = nil,
        enterEmail: String? = nil,
        about: String? = nil,
        editProfile: String? = nil,
        emailEmptyWarning: String? = nil,
        usernameEmptyWarning: String? = nil,
        logout: String? = nil,
        lastSeenLabel: String? = nil,
        notifications: String? = nil,
        reacted: String? = nil,
        toAMessage: String? = nil

    ) {
        if let chats = chats { self.chats = chats }
        if let newChat = newChat { self.newChat = newChat }
        if let tapHereForMoreInfo = tapHereForMoreInfo { self.tapHereForMoreInfo = tapHereForMoreInfo }
        if let today = today { self.today = today }
        if let endToEndEncryptedMessage = endToEndEncryptedMessage { self.endToEndEncryptedMessage = endToEndEncryptedMessage }
        if let typeAMessage = typeAMessage { self.typeAMessage = typeAMessage }
        if let youDeletedThisMessage = youDeletedThisMessage { self.youDeletedThisMessage = youDeletedThisMessage }
        if let thisMessageWasDeleted = thisMessageWasDeleted { self.thisMessageWasDeleted = thisMessageWasDeleted }
        if let sendTo = sendTo { self.sendTo = sendTo }
        if let maxShareLimit = maxShareLimit { self.maxShareLimit = maxShareLimit }
        if let messageForwarded = messageForwarded { self.messageForwarded = messageForwarded }
        if let readBy = readBy { self.readBy = readBy }
        if let deliveredTo = deliveredTo { self.deliveredTo = deliveredTo }
        if let read = read { self.read = read }
        if let delivered = delivered { self.delivered = delivered }
        if let messageInfo = messageInfo { self.messageInfo = messageInfo }
        if let messageCopied = messageCopied { self.messageCopied = messageCopied }
        if let unblockContact = unblockContact { self.unblockContact = unblockContact }
        if let ok = ok { self.ok = ok }
        if let noInternetMessage = noInternetMessage { self.noInternetMessage = noInternetMessage }
        if let call = call { self.call = call }
        if let cancel = cancel { self.cancel = cancel }
        if let voiceCall = voiceCall { self.voiceCall = voiceCall }
        if let videoCall = videoCall { self.videoCall = videoCall }
        if let andOthers = andOthers { self.andOthers = andOthers }
        if let actionNotAllowedBlocked = actionNotAllowedBlocked { self.actionNotAllowedBlocked = actionNotAllowedBlocked }
        if let clearAllMessages = clearAllMessages { self.clearAllMessages = clearAllMessages }
        if let thisChat = thisChat { self.thisChat = thisChat }
        if let emptyChatWarning = emptyChatWarning { self.emptyChatWarning = emptyChatWarning }
        if let blockedUserWarning = blockedUserWarning { self.blockedUserWarning = blockedUserWarning }
        if let declineRequest = declineRequest { self.declineRequest = declineRequest }
        if let declinePaymentRequestWarning = declinePaymentRequestWarning { self.declinePaymentRequestWarning = declinePaymentRequestWarning }
        if let declineRequestButton = declineRequestButton { self.declineRequestButton = declineRequestButton }
        if let deleteMessage = deleteMessage { self.deleteMessage = deleteMessage }
        if let deleteMessageWarning = deleteMessageWarning { self.deleteMessageWarning = deleteMessageWarning }
        if let deleteForEveryone = deleteForEveryone { self.deleteForEveryone = deleteForEveryone }
        if let deleteForMe = deleteForMe { self.deleteForMe = deleteForMe }
        if let unblock = unblock { self.unblock = unblock }
        if let blocked = blockUser { self.blocked = blocked }
        if let unblocked = unblocked { self.unblocked = unblocked }
        if let audioPermissionRequired = audioPermissionRequired { self.audioPermissionRequired = audioPermissionRequired }
        if let microphoneAccessMessage = microphoneAccessMessage { self.microphoneAccessMessage = microphoneAccessMessage }
        if let openSettings = openSettings { self.openSettings = openSettings }
        if let groupMemberRestriction = groupMemberRestriction { self.groupMemberRestriction = groupMemberRestriction }
        if let youBlockedUser = youBlockedUser { self.youBlockedUser = youBlockedUser }
        if let youAreBlocked = youAreBlocked { self.youAreBlocked = youAreBlocked }
        if let youUnblockedUser = youUnblockedUser { self.youUnblockedUser = youUnblockedUser }
        if let youAreUnblocked = youAreUnblocked { self.youAreUnblocked = youAreUnblocked }
        if let changedGroupTitle = changedGroupTitle { self.changedGroupTitle = changedGroupTitle }
        if let changedGroupImage = changedGroupImage { self.changedGroupImage = changedGroupImage }
        if let createdGroup = createdGroup { self.createdGroup = createdGroup }
        if let userLeft = userLeft { self.userLeft = userLeft }
        if let updatedNotificationSetting = updatedNotificationSetting { self.updatedNotificationSetting = updatedNotificationSetting }
        if let messageRequestInfo = messageRequestInfo { self.messageRequestInfo = messageRequestInfo }
        if let acceptMessageRequest = acceptMessageRequest { self.acceptMessageRequest = acceptMessageRequest }
        if let reject = reject { self.reject = reject }
        if let accept = accept { self.accept = accept }
        if let openChatMessage = openChatMessage { self.openChatMessage = openChatMessage }
        if let noOtherChatsFound = noOtherChatsFound { self.noOtherChatsFound = noOtherChatsFound }
        if let newBroadcast = newBroadcast { self.newBroadcast = newBroadcast }
        if let newGroup = newGroup { self.newGroup = newGroup }
        if let enterGroupName = enterGroupName { self.enterGroupName = enterGroupName }
        if let shareLocation = shareLocation { self.shareLocation = shareLocation }
        if let useMyCurrentLocation = useMyCurrentLocation { self.useMyCurrentLocation = useMyCurrentLocation }
        if let useThisLocation = useThisLocation { self.useThisLocation = useThisLocation }
        if let openInMaps = openInMaps { self.openInMaps = openInMaps }
        if let sendLocation = sendLocation { self.sendLocation = sendLocation }
        if let permissionDenied = permissionDenied { self.permissionDenied = permissionDenied }
        if let enablePermissionMessage = enablePermissionMessage { self.enablePermissionMessage = enablePermissionMessage }
        if let goToSettings = goToSettings { self.goToSettings = goToSettings }
        if let sendCurrentLocation = sendCurrentLocation { self.sendCurrentLocation = sendCurrentLocation }
        if let accurateTo5Meters = accurateTo5Meters { self.accurateTo5Meters = accurateTo5Meters }
        if let nearbyPlaces = nearbyPlaces { self.nearbyPlaces = nearbyPlaces }
        if let openInGoogleMaps = openInGoogleMaps { self.openInGoogleMaps = openInGoogleMaps }
        if let writeGroupName = writeGroupName { self.writeGroupName = writeGroupName }
        if let editGroup = editGroup { self.editGroup = editGroup }
        if let remove = remove { self.remove = remove }
        if let groupNameEmptyWarning = groupNameEmptyWarning { self.groupNameEmptyWarning = groupNameEmptyWarning }
        if let makeGroupAdmin = makeGroupAdmin { self.makeGroupAdmin = makeGroupAdmin }
        if let dismissAsAdmin = dismissAsAdmin { self.dismissAsAdmin = dismissAsAdmin }
        if let searchMembers = searchMembers { self.searchMembers = searchMembers }
        if let removeFromGroup = removeFromGroup { self.removeFromGroup = removeFromGroup }
        if let forward = forward { self.forward = forward }
        if let reply = reply { self.reply = reply }
        if let copy = copy { self.copy = copy }
        if let edit = edit { self.edit = edit }
        if let info = info { self.info = info }
        if let delete = delete { self.delete = delete }
        if let block = block { self.block = block }
        if let online = online { self.online = online }
        if let offline = offline { self.offline = offline }
        if let typing = typing { self.typing = typing }
        if let isTyping = isTyping { self.isTyping = isTyping }
        if let lastSeen = lastSeen { self.lastSeen = lastSeen }
        if let error = error { self.error = error }
        if let noInternetConnection = noInternetConnection { self.noInternetConnection = noInternetConnection }
        if let failedToSendMessage = failedToSendMessage { self.failedToSendMessage = failedToSendMessage }
        if let pleaseTryAgain = pleaseTryAgain { self.pleaseTryAgain = pleaseTryAgain }
        if let clearChat = clearChat { self.clearChat = clearChat }
        if let blockUser = blockUser { self.blockUser = blockUser }
        if let clearChatConfirmation = clearChatConfirmation { self.clearChatConfirmation = clearChatConfirmation }
        if let clearChatWarning = clearChatWarning { self.clearChatWarning = clearChatWarning }
        if let yesClear = yesClear { self.yesClear = yesClear }
        if let blockUserConfirmation = blockUserConfirmation { self.blockUserConfirmation = blockUserConfirmation }
        if let blockConfirmation = blockConfirmation { self.blockConfirmation = blockConfirmation }
        if let camera = camera { self.camera = camera }
        if let gallery = gallery { self.gallery = gallery }
        if let document = document { self.document = document }
        if let location = location { self.location = location }
        if let contact = contact { self.contact = contact }
        if let sticker = sticker { self.sticker = sticker }
        if let viewProfile = viewProfile { self.viewProfile = viewProfile }
        if let mediaLinksAndDocs = mediaLinksAndDocs { self.mediaLinksAndDocs = mediaLinksAndDocs }
        if let deleteChat = deleteChat { self.deleteChat = deleteChat }
        if let enterNameAndProfilePic = enterNameAndProfilePic { self.enterNameAndProfilePic = enterNameAndProfilePic }
        if let enterName = enterName { self.enterName = enterName }
        if let email = email { self.email = email }
        if let enterEmail = enterEmail { self.enterEmail = enterEmail }
        if let about = about { self.about = about }
        if let editProfile = editProfile { self.editProfile = editProfile }
        if let emailEmptyWarning = emailEmptyWarning { self.emailEmptyWarning = emailEmptyWarning }
        if let usernameEmptyWarning = usernameEmptyWarning { self.usernameEmptyWarning = usernameEmptyWarning }
        if let logout = logout { self.logout = logout }
        if let lastSeenLabel = lastSeenLabel { self.lastSeenLabel = lastSeenLabel }
        if let notifications = notifications { self.notifications = notifications }
        if let reacted = reacted { self.reacted = reacted }
        if let toAMessage = toAMessage { self.toAMessage = toAMessage }
    }
}
