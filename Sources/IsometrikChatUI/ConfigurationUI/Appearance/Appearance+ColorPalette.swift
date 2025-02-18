//
//  ChatsView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 23/01/23.
//

import UIKit
import SwiftUI


public struct ISMChatColorPalette {
    
    public var navigationBarTitle : Color = .ismChatSdkAccentPrimary
    //alerts
    public var alertText : Color = .ismChatSdkWhite
    public var alertBackground : Color = Color.black.opacity(0.4)
    public var cancelButton : Color = .ismChatCancelButton
    public var confirmButton : Color = .ismchatConfirmButton
    //userownProfile
    public var userProfileDescription : Color = .ismChatSdkGray
    public var userProfileEditText : Color = .ismChatSdkToolBarAction
    public var userProfileFields : Color = .ismChatSdkAccentPrimary
    public var userProfileSectionHeader : Color = .ismChatSdkGray
    public var userProfileSeparator : Color = .ismChatSdkListSeperator
    public var userProfileDoneButton : Color = .ismChatSdkToolBarAction
    
    //conversationList
    public var chatListTitle : Color = .ismChatSdkAccentPrimary
    public var chatListUserName : Color = .ismChatSdkAccentPrimary
    public var chatListUserMessage : Color = .ismChatSdkGray
    public var chatListLastMessageTime : Color = .ismChatSdkGray
    public var chatListUnreadMessageCount : Color = .ismChatSdkWhite
    public var chatListUnreadMessageCountBackground : Color = .ismChatSdkRed
    public var chatListBackground : Color = .ismChatSdkWhite
    public var chatListSeparatorColor : Color = .ismChatSdkListSeperator
    
    //message List
    public var messageListHeaderBackgroundColor : Color = .ismChatSdkWhite
    public var messageListHeaderTitle : Color = .ismChatSdkAccentPrimary
    public var messageListHeaderDescription : Color = .ismChatSdkGray
    public var messageListIcons : Color = .ismChatSdkAccentPrimary
    public var messageListSectionHeaderBackground : Color = .clear
    public var messageListSectionHeaderText : Color = .ismChatSdkGray
    public var messageListBackgroundColor : Color = .ismChatSdkScreenBackground
    public var messageListSendMessageBackgroundColor : Color = .ismChatSdkWhite
    public var messageListReceivedMessageBackgroundColor : Color = .ismChatSdkWhite
    public var messageListSendReplyMessageBackgroundColor : Color = .ismChatSdkWhite
    public var messageListReceivedReplyMessageBackgroundColor : Color = .ismChatSdkWhite
    public var messageListMessageBorderColor : Color = .ismChatSdkListSeperator
    
    public var messageListMessageTextSend : Color = .ismChatSdkAccentPrimary
    public var messageListMessageTextReceived : Color = .ismChatSdkAccentPrimary
    
    public var messageListMessageMoreAndLessSend : Color = .ismChatSdkAccentPrimary
    public var messageListMessageMoreAndLessReceived : Color = .ismChatSdkAccentPrimary
    
    
    public var messageListMessageForwarded : Color = .ismChatSdkGray
    public var messageListMessageDeleted : Color = .ismChatSdkAccentPrimary
    public var messageListMessageEdited : Color = .ismChatSdkGray
    
    public var messageListMessageTimeSend : Color = .ismChatSdkGray
    public var messageListMessageTimeReceived : Color = .ismChatSdkGray
    
    public var messageListToolBarBackground : Color = .ismChatSdkWhite
    public var messageListReplyToolBarBackground : Color = .ismChatSdkWhite
    public var messageListTextViewBackground : Color = .clear
    public var messageListTextViewText : Color = Color.black
    public var messageListTextViewBoarder : Color = .ismChatSdkListSeperator
    public var messageListActionText : Color = .ismChatSdkGray
    public var messageListActionBackground : Color = .ismChatSdkActionBackground
    public var messageListTextViewPlaceholder : Color = .ismChatSdkGray
    public var messageListReplyToolbarRectangle : Color = .ismChatSdkBGGradientFrom
    public var messageListReplyToolbarHeader : Color = .ismChatSdkAccentPrimary
    public var messageListReplyToolbarDescription : Color = .ismChatSdkGray
    public var messageListtoolbarSelected : Color  = .ismChatSdkGray
    public var messageListtoolbarAction : Color = .ismChatSdkToolBarAction
    public var messageListreactionCount : Color = .ismChatSdkAccentPrimary
    public var messageListgroupMemberUserName : Color = .ismChatSdkRed
    public var messageListcallingHeader : Color = .ismChatSdkAccentPrimary
    public var messageListcallingTime : Color = .ismChatSdkGray
    public var messageListattachmentBackground : Color = .ismChatSdkAttachmentBackground
    
    //Media Slider
    public var mediaSliderHeader : Color = .ismChatSdkAccentPrimary
    public var mediaSliderDescription : Color = .ismChatSdkGray
    
    public var audioBarDefault : Color = .ismChatSdkBGGradientTo
    public var audioBarWhilePlaying : Color = .ismChatSdkListSeperator
    
    public var searchBarBackground : Color = Color(hex: "#F2F2F5")
    
    public var avatarBackground : Color = Color(hex: "EDEBFE")
    public var avatarText : Color = Color(hex: "7062E9")
    
    public var attachmentsText : Color = Color(hex: "#121511")
    public var attachmentsBackground : Color = Color(hex: "#F5F5F2")
    public var mediaPickerButton : Color = .ismChatSdkBGGradientFrom
    
    public init(){
    }
    
    public init(
            navigationBarTitle: Color = .ismChatSdkAccentPrimary,
            alertText: Color = .ismChatSdkWhite,
            alertBackground: Color = Color.black.opacity(0.4),
            cancelButton: Color = .ismChatCancelButton,
            confirmButton: Color = .ismchatConfirmButton,
            userProfileDescription: Color = .ismChatSdkGray,
            userProfileEditText: Color = .ismChatSdkToolBarAction,
            userProfileFields: Color = .ismChatSdkAccentPrimary,
            userProfileSectionHeader: Color = .ismChatSdkGray,
            userProfileSeparator: Color = .ismChatSdkListSeperator,
            userProfileDoneButton: Color = .ismChatSdkToolBarAction,
            chatListTitle: Color = .ismChatSdkAccentPrimary,
            chatListUserName: Color = .ismChatSdkAccentPrimary,
            chatListUserMessage: Color = .ismChatSdkGray,
            chatListLastMessageTime: Color = .ismChatSdkGray,
            chatListUnreadMessageCount: Color = .ismChatSdkWhite,
            chatListUnreadMessageCountBackground: Color = .ismChatSdkRed,
            chatListBackground: Color = .ismChatSdkWhite,
            chatListSeparatorColor: Color = .ismChatSdkListSeperator,
            messageListHeaderBackgroundColor: Color = .ismChatSdkWhite,
            messageListHeaderTitle: Color = .ismChatSdkAccentPrimary,
            messageListHeaderDescription: Color = .ismChatSdkGray,
            messageListIcons: Color = .ismChatSdkAccentPrimary,
            messageListSectionHeaderBackground: Color = .clear,
            messageListSectionHeaderText: Color = .ismChatSdkGray,
            messageListBackgroundColor: Color = .ismChatSdkScreenBackground,
            messageListSendMessageBackgroundColor: Color = .ismChatSdkWhite,
            messageListReceivedMessageBackgroundColor: Color = .ismChatSdkWhite,
            messageListSendReplyMessageBackgroundColor: Color = .ismChatSdkWhite,
            messageListReceivedReplyMessageBackgroundColor: Color = .ismChatSdkWhite,
            messageListMessageBorderColor: Color = .ismChatSdkListSeperator,
            messageListMessageTextSend: Color = .ismChatSdkAccentPrimary,
            messageListMessageTextReceived: Color = .ismChatSdkAccentPrimary,
            messageListMessageMoreAndLessSend: Color = .ismChatSdkAccentPrimary,
            messageListMessageMoreAndLessReceived: Color = .ismChatSdkAccentPrimary,
            messageListMessageForwarded: Color = .ismChatSdkGray,
            messageListMessageDeleted: Color = .ismChatSdkAccentPrimary,
            messageListMessageEdited: Color = .ismChatSdkGray,
            messageListMessageTimeSend: Color = .ismChatSdkGray,
            messageListMessageTimeReceived: Color = .ismChatSdkGray,
            messageListToolBarBackground: Color = .ismChatSdkWhite,
            messageListReplyToolBarBackground: Color = .ismChatSdkWhite,
            messageListTextViewBackground: Color = .clear,
            messageListTextViewText: Color = .black,
            messageListTextViewBoarder: Color = .ismChatSdkListSeperator,
            messageListActionText: Color = .ismChatSdkGray,
            messageListActionBackground: Color = .ismChatSdkActionBackground,
            messageListTextViewPlaceholder: Color = .ismChatSdkGray,
            messageListReplyToolbarRectangle: Color = .ismChatSdkBGGradientFrom,
            messageListReplyToolbarHeader: Color = .ismChatSdkAccentPrimary,
            messageListReplyToolbarDescription: Color = .ismChatSdkGray,
            messageListtoolbarSelected: Color = .ismChatSdkGray,
            messageListtoolbarAction: Color = .ismChatSdkToolBarAction,
            messageListreactionCount: Color = .ismChatSdkAccentPrimary,
            messageListgroupMemberUserName: Color = .ismChatSdkRed,
            messageListcallingHeader: Color = .ismChatSdkAccentPrimary,
            messageListcallingTime: Color = .ismChatSdkGray,
            messageListattachmentBackground: Color = .ismChatSdkAttachmentBackground,
            mediaSliderHeader: Color = .ismChatSdkAccentPrimary,
            mediaSliderDescription: Color = .ismChatSdkGray,
            audioBarDefault: Color = .ismChatSdkBGGradientTo,
            audioBarWhilePlaying: Color = .ismChatSdkListSeperator,
            searchBarBackground: Color = Color(hex: "#F2F2F5"),
            avatarBackground: Color = Color(hex: "EDEBFE"),
            avatarText: Color = Color(hex: "7062E9"),
            attachmentsText: Color = Color(hex: "#121511"),
            attachmentsBackground: Color = Color(hex: "#F5F5F2"),
            mediaPickerButton : Color = .ismChatSdkBGGradientFrom
        )  {
        self.navigationBarTitle = navigationBarTitle
        self.alertText = alertText
        self.alertBackground = alertBackground
        self.userProfileDescription = userProfileDescription
        self.userProfileEditText = userProfileEditText
        self.userProfileFields = userProfileFields
        self.userProfileSectionHeader = userProfileSectionHeader
        self.userProfileSeparator = userProfileSeparator
        self.userProfileDoneButton = userProfileDoneButton
        self.chatListTitle = chatListTitle
        self.chatListUserName = chatListUserName
        self.chatListUserMessage = chatListUserMessage
        self.chatListLastMessageTime = chatListLastMessageTime
        self.chatListUnreadMessageCount = chatListUnreadMessageCount
        self.chatListUnreadMessageCountBackground = chatListUnreadMessageCountBackground
        self.chatListBackground = chatListBackground
        self.chatListSeparatorColor = chatListSeparatorColor
        self.messageListHeaderBackgroundColor = messageListHeaderBackgroundColor
        self.messageListHeaderTitle = messageListHeaderTitle
        self.messageListHeaderDescription = messageListHeaderDescription
        self.messageListIcons = messageListIcons
        self.messageListSectionHeaderBackground = messageListSectionHeaderBackground
        self.messageListSectionHeaderText = messageListSectionHeaderText
        self.messageListBackgroundColor = messageListBackgroundColor
        self.messageListSendMessageBackgroundColor = messageListSendMessageBackgroundColor
        self.messageListReceivedMessageBackgroundColor = messageListReceivedMessageBackgroundColor
        self.messageListSendReplyMessageBackgroundColor = messageListSendReplyMessageBackgroundColor
        self.messageListReceivedReplyMessageBackgroundColor = messageListReceivedReplyMessageBackgroundColor
        self.messageListMessageBorderColor = messageListMessageBorderColor
        self.messageListMessageTextSend = messageListMessageTextSend
        self.messageListMessageTextReceived = messageListMessageTextReceived
        self.messageListMessageMoreAndLessSend = messageListMessageMoreAndLessSend
        self.messageListMessageMoreAndLessReceived = messageListMessageMoreAndLessReceived
        self.messageListMessageForwarded = messageListMessageForwarded
        self.messageListMessageDeleted = messageListMessageDeleted
        self.messageListMessageEdited = messageListMessageEdited
        self.messageListMessageTimeSend = messageListMessageTimeSend
        self.messageListMessageTimeReceived = messageListMessageTimeReceived
        self.messageListToolBarBackground = messageListToolBarBackground
        self.messageListReplyToolBarBackground = messageListReplyToolBarBackground
        self.messageListTextViewBackground = messageListTextViewBackground
        self.messageListTextViewText = messageListTextViewText
        self.messageListTextViewBoarder = messageListTextViewBoarder
        self.messageListActionText = messageListActionText
        self.messageListActionBackground = messageListActionBackground
        self.messageListTextViewPlaceholder = messageListTextViewPlaceholder
        self.messageListReplyToolbarRectangle = messageListReplyToolbarRectangle
        self.messageListReplyToolbarHeader = messageListReplyToolbarHeader
        self.messageListReplyToolbarDescription = messageListReplyToolbarDescription
        self.messageListtoolbarSelected = messageListtoolbarSelected
        self.messageListtoolbarAction = messageListtoolbarAction
        self.messageListreactionCount = messageListreactionCount
        self.messageListgroupMemberUserName = messageListgroupMemberUserName
        self.messageListcallingHeader = messageListcallingHeader
        self.messageListcallingTime = messageListcallingTime
        self.messageListattachmentBackground = messageListattachmentBackground
        self.mediaSliderHeader = mediaSliderHeader
        self.mediaSliderDescription = mediaSliderDescription
        self.audioBarDefault = audioBarDefault
        self.audioBarWhilePlaying = audioBarWhilePlaying
        self.avatarBackground = avatarBackground
        self.avatarText = avatarText
        self.attachmentsText = attachmentsText
            self.mediaPickerButton = mediaPickerButton
    }
}



public extension Color {
    
    static let ismChatSdkAccentPrimary = mode(0x294566, 0x294566)
    static let ismChatSdkGray = mode(0x9EA4C3, 0x9EA4C3)
    static let ismChatSdkWhite = mode(0xffffff, 0xffffff)
    static let ismChatSdkRed = mode(0xF15C46, 0xF15C46)
    static let ismChatSdkWhiteStatic = mode(0xffffff, 0xffffff)
    static let ismChatSdkBlackStatic = mode(0x000000, 0x000000)
    static let ismChatSdkBGGradientFrom = mode(0xA399F7, 0xA399F7)
    static let ismChatSdkBGGradientTo = mode(0x7062E9, 0x7062E9)
    static let ismChatSdkScreenBackground = mode(0xF3F6FB, 0xF3F6FB)
    static let ismChatSdkListSeperator = mode(0xCBE3FF, 0xCBE3FF)
    static let ismChatSdkActionBackground = mode(0xE3EEFF, 0xE3EEFF)
    static let ismChatSdkToolBarAction = mode(0x00A2F3, 0x00A2F3)
    static let ismChatSdkAttachmentBackground = mode(0xE8EFF9, 0xE3EEFF)
    static let ismChatCancelButton = mode(0x163300, 0x163300)
    static let ismchatConfirmButton = mode(0xFF3B30, 0xFF3B30)
    
    
    
    static func mode(_ light: Int, lightAlpha: CGFloat = 1.0, _ dark: Int, darkAlpha: CGFloat = 1.0) -> Color {
        if #available(iOS 13.0, *) {
            return Color(UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? UIColor(rgb: dark).withAlphaComponent(darkAlpha)
                : UIColor(rgb: light).withAlphaComponent(lightAlpha)
            })
        } else {
            return Color(UIColor(rgb: light).withAlphaComponent(lightAlpha))
        }
    }
}
