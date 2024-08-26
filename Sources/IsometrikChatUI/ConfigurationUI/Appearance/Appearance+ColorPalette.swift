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
    public var messageListMessageBorderColor : Color = .ismChatSdkListSeperator
    
    public var messageListMessageTextSend : Color = .ismChatSdkAccentPrimary
    public var messageListMessageTextReceived : Color = .ismChatSdkAccentPrimary
    
    
    public var messageListMessageForwarded : Color = .ismChatSdkGray
    public var messageListMessageDeleted : Color = .ismChatSdkAccentPrimary
    public var messageListMessageEdited : Color = .ismChatSdkGray
    
    public var messageListMessageTimeSend : Color = .ismChatSdkGray
    public var messageListMessageTimeReceived : Color = .ismChatSdkGray
    
    public var messageListToolBarBackground : Color = .ismChatSdkWhite
    public var messageListReplyToolBarBackground : Color = .ismChatSdkWhite
    public var messageListTextViewBackground : Color = .clear
    public var messageListTextViewText : UIColor = UIColor.label
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
    
    public init(){
    }
    
    public init(navigationBarTitle: Color, alertText: Color, alertBackground: Color, userProfileDescription: Color, userProfileeditText: Color, userProfilefields: Color, userProfilesectionHeader: Color, userProfileSeparator: Color, userProfileDoneButton: Color, chatListTitle: Color, chatListUserName: Color, chatListUserMessage: Color, chatListLastMessageTime: Color, chatListUnreadMessageCount: Color, chatListUnreadMessageCountBackground: Color, chatListBackground: Color, chatListseparatorColor: Color, messageListHeaderBackgroundColor: Color, messageListHeaderTitle: Color, messageListHeaderDescription: Color, messageListIcons: Color, messageListSectionHeaderBackground: Color, messageListSectionHeaderText: Color, messageListBackgroundColor: Color, messageListSendMessageBackgroundColor: Color, messageListReceivedMessageBackgroundColor: Color, messageListMessageBorderColor: Color, messageListMessageTextSend: Color,messageListMessageTextReceived: Color, messageListMessageForwarded: Color, messageListMessageDeleted: Color, messageListMessageEdited: Color, messageListMessageTimeSend: Color,messageListMessageTimeReceived: Color, messageListToolBarBackground: Color,messageListReplyToolBarBackground: Color, messageListTextViewBackground: Color, messageListTextViewText: UIColor, messageListTextViewBoarder: Color, messageListActionText: Color, messageListActionBackground: Color, messageListTextViewPlaceholder: Color, messageListReplyToolbarRectangle: Color, messageListReplyToolbarHeader: Color, messageListReplyToolbarDescription: Color, messageListtoolbarSelected: Color, messageListtoolbarAction: Color, messageListreactionCount: Color, messageListgroupMemberUserName: Color, messageListcallingHeader: Color, messageListcallingTime: Color, messageListattachmentBackground: Color, mediaSliderHeader: Color, mediaSliderDescription: Color,audioBarDefault : Color,audioBarWhilePlaying : Color,avatarBackground : Color,avatarText : Color) {
        self.navigationBarTitle = navigationBarTitle
        self.alertText = alertText
        self.alertBackground = alertBackground
        self.userProfileDescription = userProfileDescription
        self.userProfileEditText = userProfileeditText
        self.userProfileFields = userProfilefields
        self.userProfileSectionHeader = userProfilesectionHeader
        self.userProfileSeparator = userProfileSeparator
        self.userProfileDoneButton = userProfileDoneButton
        self.chatListTitle = chatListTitle
        self.chatListUserName = chatListUserName
        self.chatListUserMessage = chatListUserMessage
        self.chatListLastMessageTime = chatListLastMessageTime
        self.chatListUnreadMessageCount = chatListUnreadMessageCount
        self.chatListUnreadMessageCountBackground = chatListUnreadMessageCountBackground
        self.chatListBackground = chatListBackground
        self.chatListSeparatorColor = chatListseparatorColor
        self.messageListHeaderBackgroundColor = messageListHeaderBackgroundColor
        self.messageListHeaderTitle = messageListHeaderTitle
        self.messageListHeaderDescription = messageListHeaderDescription
        self.messageListIcons = messageListIcons
        self.messageListSectionHeaderBackground = messageListSectionHeaderBackground
        self.messageListSectionHeaderText = messageListSectionHeaderText
        self.messageListBackgroundColor = messageListBackgroundColor
        self.messageListSendMessageBackgroundColor = messageListSendMessageBackgroundColor
        self.messageListReceivedMessageBackgroundColor = messageListReceivedMessageBackgroundColor
        self.messageListMessageBorderColor = messageListMessageBorderColor
        self.messageListMessageTextSend = messageListMessageTextSend
        self.messageListMessageTextReceived = messageListMessageTextReceived
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
    }
}



private extension Color {
    
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
