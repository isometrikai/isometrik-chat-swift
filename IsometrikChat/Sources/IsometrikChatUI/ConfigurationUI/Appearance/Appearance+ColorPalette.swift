//
//  ChatsView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 23/01/23.
//

import UIKit
import SwiftUI


public struct ISMChat_ColorPalette {
    
    public var navigationBar_Title : Color = .ismChatSdkAccentPrimary
    //alerts
    public var alertText : Color = .ismChatSdkWhite
    public var alertBackground : Color = Color.black.opacity(0.4)
    //userownProfile
    public var userProfile_Description : Color = .ismChatSdkGray
    public var userProfile_editText : Color = .ismChatSdkToolBarAction
    public var userProfile_fields : Color = .ismChatSdkAccentPrimary
    public var userProfile_sectionHeader : Color = .ismChatSdkGray
    public var userProfile_Separator : Color = .ismChatSdkListSeperator
    public var userProfile_DoneButton : Color = .ismChatSdkToolBarAction
    
    //conversationList
    public var chatList_Title : Color = .ismChatSdkAccentPrimary
    public var chatList_UserName : Color = .ismChatSdkAccentPrimary
    public var chatList_UserMessage : Color = .ismChatSdkGray
    public var chatList_LastMessageTime : Color = .ismChatSdkGray
    public var chatList_UnreadMessageCount : Color = .ismChatSdkWhite
    public var chatList_UnreadMessageCountBackground : Color = .ismChatSdkRed
    public var chatList_Background : Color = .ismChatSdkWhite
    public var chatList_separatorColor : Color = .ismChatSdkListSeperator
    
    //message List
    public var messageList_HeaderBackgroundColor : Color = .ismChatSdkWhite
    public var messageList_HeaderTitle : Color = .ismChatSdkAccentPrimary
    public var messageList_HeaderDescription : Color = .ismChatSdkGray
    public var messageList_Icons : Color = .ismChatSdkAccentPrimary
    public var messageList_SectionHeaderBackground : Color = .clear
    public var messageList_SectionHeaderText : Color = .ismChatSdkGray
    public var messageList_BackgroundColor : Color = .ismChatSdkScreenBackground
    public var messageList_SendMessageBackgroundColor : Color = .ismChatSdkWhite
    public var messageList_ReceivedMessageBackgroundColor : Color = .ismChatSdkWhite
    public var messageList_MessageBorderColor : Color = .ismChatSdkListSeperator
    public var messageList_MessageText : Color = .ismChatSdkAccentPrimary
    public var messageList_MessageForwarded : Color = .ismChatSdkGray
    public var messageList_MessageDeleted : Color = .ismChatSdkAccentPrimary
    public var messageList_MessageEdited : Color = .ismChatSdkGray
    public var messageList_MessageTime : Color = .ismChatSdkGray
    public var messageList_ToolBarBackground : Color = .ismChatSdkWhite
    public var messageList_TextViewBackground : Color = .clear
    public var messageList_TextViewText : Color = .ismChatSdkAccentPrimary
    public var messageList_TextViewBoarder : Color = .ismChatSdkListSeperator
    public var messageList_ActionText : Color = .ismChatSdkGray
    public var messageList_ActionBackground : Color = .ismChatSdkActionBackground
    public var messageList_TextViewPlaceholder : Color = .ismChatSdkGray
    public var messageList_ReplyToolbarRectangle : Color = .ismChatSdkBGGradientFrom
    public var messageList_ReplyToolbarHeader : Color = .ismChatSdkAccentPrimary
    public var messageList_ReplyToolbarDescription : Color = .ismChatSdkGray
    public var messageList_toolbarSelected : Color  = .ismChatSdkGray
    public var messageList_toolbarAction : Color = .ismChatSdkToolBarAction
    public var messageList_reactionCount : Color = .ismChatSdkAccentPrimary
    public var messageList_groupMemberUserName : Color = .ismChatSdkRed
    public var messageList_callingHeader : Color = .ismChatSdkAccentPrimary
    public var messageList_callingTime : Color = .ismChatSdkGray
    public var messageList_attachmentBackground : Color = .ismChatSdkAttachmentBackground
    
    //Media Slider
    public var mediaSliderHeader : Color = .ismChatSdkAccentPrimary
    public var mediaSliderDescription : Color = .ismChatSdkGray
    
    public var audioBarDefault : Color = .ismChatSdkBGGradientTo
    public var audioBarWhilePlaying : Color = .ismChatSdkListSeperator
    
    public init(){
    }
    
    public init(navigationBar_Title: Color, alertText: Color, alertBackground: Color, userProfile_Description: Color, userProfile_editText: Color, userProfile_fields: Color, userProfile_sectionHeader: Color, userProfile_Separator: Color, userProfile_DoneButton: Color, chatList_Title: Color, chatList_UserName: Color, chatList_UserMessage: Color, chatList_LastMessageTime: Color, chatList_UnreadMessageCount: Color, chatList_UnreadMessageCountBackground: Color, chatList_Background: Color, chatList_separatorColor: Color, messageList_HeaderBackgroundColor: Color, messageList_HeaderTitle: Color, messageList_HeaderDescription: Color, messageList_Icons: Color, messageList_SectionHeaderBackground: Color, messageList_SectionHeaderText: Color, messageList_BackgroundColor: Color, messageList_SendMessageBackgroundColor: Color, messageList_ReceivedMessageBackgroundColor: Color, messageList_MessageBorderColor: Color, messageList_MessageText: Color, messageList_MessageForwarded: Color, messageList_MessageDeleted: Color, messageList_MessageEdited: Color, messageList_MessageTime: Color, messageList_ToolBarBackground: Color, messageList_TextViewBackground: Color, messageList_TextViewText: Color, messageList_TextViewBoarder: Color, messageList_ActionText: Color, messageList_ActionBackground: Color, messageList_TextViewPlaceholder: Color, messageList_ReplyToolbarRectangle: Color, messageList_ReplyToolbarHeader: Color, messageList_ReplyToolbarDescription: Color, messageList_toolbarSelected: Color, messageList_toolbarAction: Color, messageList_reactionCount: Color, messageList_groupMemberUserName: Color, messageList_callingHeader: Color, messageList_callingTime: Color, messageList_attachmentBackground: Color, mediaSliderHeader: Color, mediaSliderDescription: Color,audioBarDefault : Color,audioBarWhilePlaying : Color) {
        self.navigationBar_Title = navigationBar_Title
        self.alertText = alertText
        self.alertBackground = alertBackground
        self.userProfile_Description = userProfile_Description
        self.userProfile_editText = userProfile_editText
        self.userProfile_fields = userProfile_fields
        self.userProfile_sectionHeader = userProfile_sectionHeader
        self.userProfile_Separator = userProfile_Separator
        self.userProfile_DoneButton = userProfile_DoneButton
        self.chatList_Title = chatList_Title
        self.chatList_UserName = chatList_UserName
        self.chatList_UserMessage = chatList_UserMessage
        self.chatList_LastMessageTime = chatList_LastMessageTime
        self.chatList_UnreadMessageCount = chatList_UnreadMessageCount
        self.chatList_UnreadMessageCountBackground = chatList_UnreadMessageCountBackground
        self.chatList_Background = chatList_Background
        self.chatList_separatorColor = chatList_separatorColor
        self.messageList_HeaderBackgroundColor = messageList_HeaderBackgroundColor
        self.messageList_HeaderTitle = messageList_HeaderTitle
        self.messageList_HeaderDescription = messageList_HeaderDescription
        self.messageList_Icons = messageList_Icons
        self.messageList_SectionHeaderBackground = messageList_SectionHeaderBackground
        self.messageList_SectionHeaderText = messageList_SectionHeaderText
        self.messageList_BackgroundColor = messageList_BackgroundColor
        self.messageList_SendMessageBackgroundColor = messageList_SendMessageBackgroundColor
        self.messageList_ReceivedMessageBackgroundColor = messageList_ReceivedMessageBackgroundColor
        self.messageList_MessageBorderColor = messageList_MessageBorderColor
        self.messageList_MessageText = messageList_MessageText
        self.messageList_MessageForwarded = messageList_MessageForwarded
        self.messageList_MessageDeleted = messageList_MessageDeleted
        self.messageList_MessageEdited = messageList_MessageEdited
        self.messageList_MessageTime = messageList_MessageTime
        self.messageList_ToolBarBackground = messageList_ToolBarBackground
        self.messageList_TextViewBackground = messageList_TextViewBackground
        self.messageList_TextViewText = messageList_TextViewText
        self.messageList_TextViewBoarder = messageList_TextViewBoarder
        self.messageList_ActionText = messageList_ActionText
        self.messageList_ActionBackground = messageList_ActionBackground
        self.messageList_TextViewPlaceholder = messageList_TextViewPlaceholder
        self.messageList_ReplyToolbarRectangle = messageList_ReplyToolbarRectangle
        self.messageList_ReplyToolbarHeader = messageList_ReplyToolbarHeader
        self.messageList_ReplyToolbarDescription = messageList_ReplyToolbarDescription
        self.messageList_toolbarSelected = messageList_toolbarSelected
        self.messageList_toolbarAction = messageList_toolbarAction
        self.messageList_reactionCount = messageList_reactionCount
        self.messageList_groupMemberUserName = messageList_groupMemberUserName
        self.messageList_callingHeader = messageList_callingHeader
        self.messageList_callingTime = messageList_callingTime
        self.messageList_attachmentBackground = messageList_attachmentBackground
        self.mediaSliderHeader = mediaSliderHeader
        self.mediaSliderDescription = mediaSliderDescription
        self.audioBarDefault = audioBarDefault
        self.audioBarWhilePlaying = audioBarWhilePlaying
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
