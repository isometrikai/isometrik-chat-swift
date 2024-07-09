//
//  ChatsView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 23/01/23.
//

import UIKit
import SwiftUI


    public struct ISMChat_Fonts {

        public var navigationBar_Title : Font = Font.bold(size: 18)
        //alerts
        public var alertText : Font = Font.regular(size: 14)
        //userownProfile
        public var userProfile_Description : Font = Font.regular(size: 14)
        public var userProfile_editText : Font = Font.regular(size: 14)
        public var userProfile_fields : Font = Font.regular(size: 16)
        public var userProfile_sectionHeader : Font = Font.regular(size: 14)
        public var userProfile_DoneButton : Font = Font.regular(size: 16)

        
        //chatList
        public var chatList_Title : Font = Font.bold(size: 25)
        public var chatList_UserName : Font = Font.regular(size: 16)
        public var chatList_UserMessage : Font = Font.regular(size: 13)
        public var chatList_LastMessageTime : Font = Font.regular(size: 12)
        public var chatList_UnreadMessageCount : Font = Font.regular(size: 12)
        
        //messageList
        public var messageList_HeaderTitle : Font = Font.regular(size: 18)
        public var messageList_HeaderDescription : Font = Font.regular(size: 12)
        public var messageList_SectionHeaderText : Font = Font.regular(size: 14)
        public var messageList_MessageText : Font = Font.regular(size: 16)
        public var messageList_MessageForwarded : Font = Font.italic(size: 12)
        public var messageList_MessageDeleted : Font = Font.italic(size: 16)
        public var messageList_MessageEdited : Font = Font.italic(size: 12)
        public var messageList_MessageTime : Font = Font.regular(size: 12)
        public var messageList_TextViewText : Font = Font.regular(size: 16)
        public var messageList_ActionText : Font = Font.regular(size: 14)
        public var messageList_ReplyToolbarHeader : Font = Font.regular(size: 14)
        public var messageList_ReplyToolbarDescription : Font = Font.regular(size: 12)
        public var messageList_toolbarSelected : Font = Font.regular(size: 16)
        public var messageList_toolbarAction : Font = Font.bold(size: 16)
        public var messageList_reactionCount : Font = Font.regular(size: 14)
        public var messageList_groupMemberUserName : Font = Font.regular(size: 12)
        public var messageList_callingHeader : Font = Font.bold(size: 12)
        public var messageList_callingTime : Font = Font.regular(size: 12)
        //mediaSlider
        public var mediaSliderHeader : Font = Font.regular(size: 16)
        public var mediaSliderDescription : Font = Font.regular(size: 12)
        
        //contactInfo
        public var contactInfoHeader : Font = Font.bold(size: 20)
        
        public init(){}
        
        public init(navigationBar_Title: Font, alertText: Font, userProfile_Description: Font, userProfile_editText: Font, userProfile_fields: Font, userProfile_sectionHeader: Font, userProfile_DoneButton: Font, chatList_Title: Font, chatList_UserName: Font, chatList_UserMessage: Font, chatList_LastMessageTime: Font, chatList_UnreadMessageCount: Font, messageList_HeaderTitle: Font, messageList_HeaderDescription: Font, messageList_SectionHeaderText: Font, messageList_MessageText: Font, messageList_MessageForwarded: Font, messageList_MessageDeleted: Font, messageList_MessageEdited: Font, messageList_MessageTime: Font, messageList_TextViewText: Font, messageList_ActionText: Font, messageList_ReplyToolbarHeader: Font, messageList_ReplyToolbarDescription: Font, messageList_toolbarSelected: Font, messageList_toolbarAction: Font, messageList_reactionCount: Font, messageList_groupMemberUserName: Font, messageList_callingHeader: Font, messageList_callingTime: Font, mediaSliderHeader: Font, mediaSliderDescription: Font, contactInfoHeader: Font) {
            self.navigationBar_Title = navigationBar_Title
            self.alertText = alertText
            self.userProfile_Description = userProfile_Description
            self.userProfile_editText = userProfile_editText
            self.userProfile_fields = userProfile_fields
            self.userProfile_sectionHeader = userProfile_sectionHeader
            self.userProfile_DoneButton = userProfile_DoneButton
            self.chatList_Title = chatList_Title
            self.chatList_UserName = chatList_UserName
            self.chatList_UserMessage = chatList_UserMessage
            self.chatList_LastMessageTime = chatList_LastMessageTime
            self.chatList_UnreadMessageCount = chatList_UnreadMessageCount
            self.messageList_HeaderTitle = messageList_HeaderTitle
            self.messageList_HeaderDescription = messageList_HeaderDescription
            self.messageList_SectionHeaderText = messageList_SectionHeaderText
            self.messageList_MessageText = messageList_MessageText
            self.messageList_MessageForwarded = messageList_MessageForwarded
            self.messageList_MessageDeleted = messageList_MessageDeleted
            self.messageList_MessageEdited = messageList_MessageEdited
            self.messageList_MessageTime = messageList_MessageTime
            self.messageList_TextViewText = messageList_TextViewText
            self.messageList_ActionText = messageList_ActionText
            self.messageList_ReplyToolbarHeader = messageList_ReplyToolbarHeader
            self.messageList_ReplyToolbarDescription = messageList_ReplyToolbarDescription
            self.messageList_toolbarSelected = messageList_toolbarSelected
            self.messageList_toolbarAction = messageList_toolbarAction
            self.messageList_reactionCount = messageList_reactionCount
            self.messageList_groupMemberUserName = messageList_groupMemberUserName
            self.messageList_callingHeader = messageList_callingHeader
            self.messageList_callingTime = messageList_callingTime
            self.mediaSliderHeader = mediaSliderHeader
            self.mediaSliderDescription = mediaSliderDescription
            self.contactInfoHeader = contactInfoHeader
        }

    }


public extension Font {
    public func light(size: CGFloat) -> Font {
        return Font.custom("ProductSans-Light", size: size)
    }
    
    public func regular(size: CGFloat) -> Font {
        return Font.custom("ProductSans-Regular", size: size)
    }
    
    public func medium(size: CGFloat) -> Font {
        return Font.custom("ProductSans-Medium", size: size)
    }
    
    public func bold(size: CGFloat) -> Font {
        return Font.custom("ProductSans-Bold", size: size)
    }
    
    public func italic(size: CGFloat) -> Font {
        return Font.custom("ProductSans-Italic", size: size)
    }
}
