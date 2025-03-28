//
//  ISMChatPageProperty.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 17/11/23.
//

import Foundation
import SwiftUI

public struct ISMChatPageProperties {
    public var attachments: [ISMChatConfigAttachmentType] = [.camera,.gallery,.contact,.document,.location,.sticker] // Array of attachment types
    public var features : [ISMChatConfigFeature] = [.reply,.forward,.edit,.audio,.reaction,.audiocall,.videocall,.gif,.reel] // Array of chat features
    public var conversationType : [ISMChatConversationTypeConfig] = [.OneToOneConversation,.GroupConversation,.BroadCastConversation] // Array of conversation types
    public var hideNavigationBarForConversationList : Bool = false
    public var navigateToAppProfileFromMessageList : Bool = false
    public var createConversationFromChatList : Bool = false
    public var otherConversationList : Bool = false
    public var showCustomPlaceholder : Bool = false
    public var isOneToOneGroup : Bool = false
    public var customJobCardInMessageList : Bool = false
    public var externalMemberAddInGroup : Bool = false
    public var captializeMessageListHeaders : Bool = false
    public var hideLinkPreview : Bool = false
    public var maskNumberAndEmail : Bool = false
    public var hideSendButtonUntilEmptyTextView = false
    public var gifLogoOnTextViewLeft = false
    public var showUserTypeInConversationListAfterName : Bool = false
    public var showSearchCrossButton : Bool = false
    public var chatListSeperatorShouldMeetEnds : Bool = false
    public var messageListReplyBarMeetEnds : Bool = false
    public var hideUserProfileImageFromAudioMessage : Bool = false
    public var hideDocumentPreview : Bool = false
    public var customShareContactFlow : Bool = false
    public var shareOnlyCurrentLocation : Bool = false
    public var replyMessageInsideInputView : Bool = false
    public var messageInfoBelowMessage : Bool = false
    public var customMenu: Bool = false
    public var editMessageForOnly15Mins : Bool = false
    public var onTapOfSearchBarOpenNewScreen : Bool = false
    public var useCustomViewRegistered : Bool = false
    public var dontShowBlockedStatusinConversationList : Bool = false
    public var dontShowCreateButtonTillNoConversation : Bool = false
    public var multipleSelectionOfMessageForDelete : Bool = true
    public init(attachments: [ISMChatConfigAttachmentType]? = nil, features: [ISMChatConfigFeature]? = nil, conversationType: [ISMChatConversationTypeConfig]? = nil, hideNavigationBarForConversationList: Bool? = false, navigateToAppProfileFromMessageList: Bool? = false, createConversationFromChatList: Bool? = false, otherConversationList: Bool? = false, showCustomPlaceholder: Bool? = false, isOneToOneGroup: Bool? = false,customJobCardInMessageList : Bool? = false,externalMemberAddInGroup : Bool? = false,captializeMessageListHeaders : Bool? = false,hideLinkPreview : Bool? = false,maskNumberAndEmail : Bool? = false,hideSendButtonUntilEmptyTextView: Bool? = false,gifLogoOnTextViewLeft : Bool? = false,showUserTypeInConversationListAfterName : Bool? = false,showSearchCrossButton:  Bool? = false,chatListSeperatorShouldMeetEnds : Bool? = false,messageListReplyBarMeetEnds : Bool? = false,hideUserProfileImageFromAudioMessage : Bool? = false,hideDocumentPreview : Bool? = false,customShareContactFlow : Bool? = false,shareOnlyCurrentLocation : Bool? = false,replyMessageInsideInputView : Bool? = false,messageInfoBelowMessage : Bool? = false,customMenu :Bool? = false,editMessageForOnly15Mins : Bool? = false,onTapOfSearchBarOpenNewScreen : Bool? = false,useCustomViewRegistered: Bool? = false,dontShowBlockedStatusinConversationList : Bool? = false,dontShowCreateButtonTillNoConversation : Bool? = false,multipleSelectionOfMessageForDelete : Bool? = true) {
        self.attachments = attachments ?? self.attachments
        self.features = features ?? self.features
        self.conversationType = conversationType ?? self.conversationType
        self.hideNavigationBarForConversationList = hideNavigationBarForConversationList ?? false
        self.navigateToAppProfileFromMessageList = navigateToAppProfileFromMessageList ?? false
        self.createConversationFromChatList = createConversationFromChatList ?? false
        self.otherConversationList = otherConversationList ?? false
        self.showCustomPlaceholder = showCustomPlaceholder ?? false
        self.isOneToOneGroup = isOneToOneGroup ?? false
        self.customJobCardInMessageList = customJobCardInMessageList ?? false
        self.externalMemberAddInGroup = externalMemberAddInGroup ?? false
        self.captializeMessageListHeaders = captializeMessageListHeaders ?? false
        self.hideLinkPreview = hideLinkPreview ?? false
        self.maskNumberAndEmail = maskNumberAndEmail ?? false
        self.hideSendButtonUntilEmptyTextView = hideSendButtonUntilEmptyTextView ?? false
        self.gifLogoOnTextViewLeft = gifLogoOnTextViewLeft ?? false
        self.showUserTypeInConversationListAfterName = showUserTypeInConversationListAfterName ?? false
        self.showSearchCrossButton = showSearchCrossButton ?? false
        self.chatListSeperatorShouldMeetEnds = chatListSeperatorShouldMeetEnds ?? false
        self.messageListReplyBarMeetEnds = messageListReplyBarMeetEnds ?? false
        self.hideUserProfileImageFromAudioMessage = hideUserProfileImageFromAudioMessage ?? false
        self.hideDocumentPreview = hideDocumentPreview ?? false
        self.customShareContactFlow = customShareContactFlow ?? false
        self.shareOnlyCurrentLocation = shareOnlyCurrentLocation ?? false
        self.replyMessageInsideInputView = replyMessageInsideInputView ?? false
        self.messageInfoBelowMessage = messageInfoBelowMessage ?? false
        self.customMenu = customMenu ?? false
        self.editMessageForOnly15Mins = editMessageForOnly15Mins ?? false
        self.onTapOfSearchBarOpenNewScreen = onTapOfSearchBarOpenNewScreen ?? false
        self.useCustomViewRegistered = useCustomViewRegistered ?? false
        self.dontShowBlockedStatusinConversationList = dontShowBlockedStatusinConversationList ?? false
        self.dontShowCreateButtonTillNoConversation = dontShowCreateButtonTillNoConversation ?? false
        self.multipleSelectionOfMessageForDelete = multipleSelectionOfMessageForDelete ?? true
    }
}
