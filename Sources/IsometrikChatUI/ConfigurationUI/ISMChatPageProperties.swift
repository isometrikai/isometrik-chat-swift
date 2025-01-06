//
//  ISMChatPageProperty.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 17/11/23.
//

import Foundation
import SwiftUI

public struct ISMChatPageProperties {
    public var attachments: [ISMChatConfigAttachmentType] // Array of attachment types
    public var features : [ISMChatConfigFeature] // Array of chat features
    public var conversationType : [ISMChatConversationTypeConfig] // Array of conversation types
    public var hideNavigationBarForConversationList : Bool
    public var navigateToAppProfileFromMessageList : Bool
    public var createConversationFromChatList : Bool
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
    public init(attachments: [ISMChatConfigAttachmentType], features: [ISMChatConfigFeature], conversationType: [ISMChatConversationTypeConfig], hideNavigationBarForConversationList: Bool, navigateToAppProfileFromMessageList: Bool, createConversationFromChatList: Bool, otherConversationList: Bool, showCustomPlaceholder: Bool, isOneToOneGroup: Bool,customJobCardInMessageList : Bool,externalMemberAddInGroup : Bool,captializeMessageListHeaders : Bool? = false,hideLinkPreview : Bool? = false,maskNumberAndEmail : Bool? = false,hideSendButtonUntilEmptyTextView: Bool? = false,gifLogoOnTextViewLeft : Bool? = false,showUserTypeInConversationListAfterName : Bool? = false,showSearchCrossButton:  Bool? = false,chatListSeperatorShouldMeetEnds : Bool? = false,messageListReplyBarMeetEnds : Bool? = false,hideUserProfileImageFromAudioMessage : Bool? = false,hideDocumentPreview : Bool? = false,customShareContactFlow : Bool? = false,shareOnlyCurrentLocation : Bool? = false,replyMessageInsideInputView : Bool? = false,messageInfoBelowMessage : Bool? = false,customMenu :Bool? = false,editMessageForOnly15Mins : Bool? = false,onTapOfSearchBarOpenNewScreen : Bool? = false,useCustomViewRegistered: Bool? = false) {
        self.attachments = attachments
        self.features = features
        self.conversationType = conversationType
        self.hideNavigationBarForConversationList = hideNavigationBarForConversationList
        self.navigateToAppProfileFromMessageList = navigateToAppProfileFromMessageList
        self.createConversationFromChatList = createConversationFromChatList
        self.otherConversationList = otherConversationList
        self.showCustomPlaceholder = showCustomPlaceholder
        self.isOneToOneGroup = isOneToOneGroup
        self.customJobCardInMessageList = customJobCardInMessageList
        self.externalMemberAddInGroup = externalMemberAddInGroup
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
    }
}
