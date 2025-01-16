//
//  ChatsView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 23/01/23.
//

import UIKit
import SwiftUI

    public struct ISMChatFonts {

        public var navigationBarTitle : Font = Font.bold(size: 14)
        //alerts
        public var alertText : Font = Font.regular(size: 14)
        public var cancelButton : Font = Font.bold(size: 14)
        //userownProfile
        public var userProfileDescription : Font = Font.regular(size: 14)
        public var userProfileeditText : Font = Font.regular(size: 14)
        public var userProfilefields : Font = Font.regular(size: 16)
        public var userProfilesectionHeader : Font = Font.regular(size: 14)
        public var userProfileDoneButton : Font = Font.regular(size: 16)

        
        //chatList
        public var chatListTitle : Font = Font.bold(size: 25)
        public var chatListUserName : Font = Font.regular(size: 16)
        public var chatListUserMessage : Font = Font.regular(size: 13)
        public var chatListLastMessageTime : Font = Font.regular(size: 12)
        public var chatListUnreadMessageCount : Font = Font.regular(size: 12)
        
        //messageList
        public var messageListHeaderTitle : Font = Font.regular(size: 18)
        public var messageListHeaderDescription : Font = Font.regular(size: 12)
        public var messageListSectionHeaderText : Font = Font.regular(size: 14)
        public var messageListMessageText : Font = Font.regular(size: 16)
        public var messageListMessageMoreAndLess : Font = Font.regular(size: 16)
        public var messageListMessageForwarded : Font = Font.italic(size: 12)
        public var messageListMessageDeleted : Font = Font.italic(size: 16)
        public var messageListMessageEdited : Font = Font.italic(size: 12)
        public var messageListMessageTime : Font = Font.regular(size: 12)
        public var messageListTextViewText : Font = Font.regular(size: 16)
        public var messageListActionText : Font = Font.regular(size: 14)
        public var messageListReplyToolbarHeader : Font = Font.regular(size: 14)
        public var messageListReplyToolbarDescription : Font = Font.regular(size: 12)
        public var messageListtoolbarSelected : Font = Font.regular(size: 16)
        public var messageListtoolbarAction : Font = Font.bold(size: 16)
        public var messageListreactionCount : Font = Font.regular(size: 14)
        public var messageListgroupMemberUserName : Font = Font.regular(size: 12)
        public var messageListcallingHeader : Font = Font.bold(size: 12)
        public var messageListcallingTime : Font = Font.regular(size: 12)
        //mediaSlider
        public var mediaSliderHeader : Font = Font.regular(size: 16)
        public var mediaSliderDescription : Font = Font.regular(size: 12)
        
        //contactInfo
        public var contactInfoHeader : Font = Font.bold(size: 20)
        
        public var searchbarText : Font = Font.regular(size: 14)
        
        public var avatarText : Font = Font.medium(size: 16)
        
        public var contextMenuOptions : Font = Font.regular(size: 16)
        public var attachmentsText : Font = Font.regular(size: 12)
        public var locationMessageTitle : Font = Font.regular(size: 16)
        public var locationMessageDescription : Font = Font.regular(size: 12)
        
        public var contactMessageTitle : Font = Font.bold(size: 14)
        public var contactMessageButton : Font = Font.bold(size: 12)
        
        public var contactDetailsTitle : Font = Font.bold(size: 14)
        public var contactDetailsNumber : Font = Font.regular(size: 14)
        public var contactDetailButtons : Font = Font.bold(size: 12)
        
        public init(
            navigationBarTitle: Font = .bold(size: 14),
            alertText: Font = .regular(size: 14),
            userProfileDescription: Font = .regular(size: 14),
            userProfileeditText: Font = .regular(size: 14),
            userProfilefields: Font = .regular(size: 16),
            userProfilesectionHeader: Font = .regular(size: 14),
            userProfileDoneButton: Font = .regular(size: 16),
            chatListTitle: Font = .bold(size: 25),
            chatListUserName: Font = .regular(size: 16),
            chatListUserMessage: Font = .regular(size: 13),
            chatListLastMessageTime: Font = .regular(size: 12),
            chatListUnreadMessageCount: Font = .regular(size: 12),
            messageListHeaderTitle: Font = .regular(size: 18),
            messageListHeaderDescription: Font = .regular(size: 12),
            messageListSectionHeaderText: Font = .regular(size: 14),
            messageListMessageText: Font = .regular(size: 16),
            messageListMessageMoreAndLess: Font = .regular(size: 16),
            messageListMessageForwarded: Font = .italic(size: 12),
            messageListMessageDeleted: Font = .italic(size: 16),
            messageListMessageEdited: Font = .italic(size: 12),
            messageListMessageTime: Font = .regular(size: 12),
            messageListTextViewText: Font = .regular(size: 16),
            messageListActionText: Font = .regular(size: 14),
            messageListReplyToolbarHeader: Font = .regular(size: 14),
            messageListReplyToolbarDescription: Font = .regular(size: 12),
            messageListtoolbarSelected: Font = .regular(size: 16),
            messageListtoolbarAction: Font = .bold(size: 16),
            messageListreactionCount: Font = .regular(size: 14),
            messageListgroupMemberUserName: Font = .regular(size: 12),
            messageListcallingHeader: Font = .bold(size: 12),
            messageListcallingTime: Font = .regular(size: 12),
            mediaSliderHeader: Font = .regular(size: 16),
            mediaSliderDescription: Font = .regular(size: 12),
            contactInfoHeader: Font = .bold(size: 20),
            searchbarText: Font = .regular(size: 14),
            avatarText: Font = .medium(size: 16),
            contextMenuOptions: Font = .regular(size: 16),
            attachmentsText: Font = .regular(size: 12),
            locationMessageTitle: Font = .regular(size: 16),
            locationMessageDescription: Font = .regular(size: 12),
            contactMessageTitle: Font = .bold(size: 14),
            contactMessageButton: Font = .bold(size: 12),
            contactDetailsTitle: Font = .bold(size: 14),
            contactDetailsNumber: Font = .regular(size: 14),
            contactDetailButtons: Font = .bold(size: 12)
        ) {
            self.navigationBarTitle = navigationBarTitle
            self.alertText = alertText
            self.userProfileDescription = userProfileDescription
            self.userProfileeditText = userProfileeditText
            self.userProfilefields = userProfilefields
            self.userProfilesectionHeader = userProfilesectionHeader
            self.userProfileDoneButton = userProfileDoneButton
            self.chatListTitle = chatListTitle
            self.chatListUserName = chatListUserName
            self.chatListUserMessage = chatListUserMessage
            self.chatListLastMessageTime = chatListLastMessageTime
            self.chatListUnreadMessageCount = chatListUnreadMessageCount
            self.messageListHeaderTitle = messageListHeaderTitle
            self.messageListHeaderDescription = messageListHeaderDescription
            self.messageListSectionHeaderText = messageListSectionHeaderText
            self.messageListMessageText = messageListMessageText
            self.messageListMessageMoreAndLess = messageListMessageMoreAndLess
            self.messageListMessageForwarded = messageListMessageForwarded
            self.messageListMessageDeleted = messageListMessageDeleted
            self.messageListMessageEdited = messageListMessageEdited
            self.messageListMessageTime = messageListMessageTime
            self.messageListTextViewText = messageListTextViewText
            self.messageListActionText = messageListActionText
            self.messageListReplyToolbarHeader = messageListReplyToolbarHeader
            self.messageListReplyToolbarDescription = messageListReplyToolbarDescription
            self.messageListtoolbarSelected = messageListtoolbarSelected
            self.messageListtoolbarAction = messageListtoolbarAction
            self.messageListreactionCount = messageListreactionCount
            self.messageListgroupMemberUserName = messageListgroupMemberUserName
            self.messageListcallingHeader = messageListcallingHeader
            self.messageListcallingTime = messageListcallingTime
            self.mediaSliderHeader = mediaSliderHeader
            self.mediaSliderDescription = mediaSliderDescription
            self.contactInfoHeader = contactInfoHeader
            self.searchbarText = searchbarText
            self.avatarText = avatarText
            self.contextMenuOptions = contextMenuOptions
            self.attachmentsText = attachmentsText
            self.locationMessageTitle = locationMessageTitle
            self.locationMessageDescription = locationMessageDescription
            self.contactMessageTitle = contactMessageTitle ?? Font.bold(size: 14)
            self.contactMessageButton = contactMessageButton ?? Font.bold(size: 12)
            self.contactDetailsTitle = contactDetailsTitle ?? Font.bold(size: 14)
            self.contactDetailsNumber = contactDetailsNumber ?? Font.regular(size: 14)
            self.contactDetailButtons = contactDetailButtons ?? Font.bold(size: 12)
        }

    }


 extension Font {
     func light(size: CGFloat) -> Font {
        return Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().light, size: size)
    }
    
     func regular(size: CGFloat) -> Font {
        return Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: size)
    }
    
     func medium(size: CGFloat) -> Font {
        return Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().medium, size: size)
    }
    
     func bold(size: CGFloat) -> Font {
        return Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().bold, size: size)
    }
    
     func italic(size: CGFloat) -> Font {
        return Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().italic, size: size)
    }
}


 extension UIFont {
     func light(size: CGFloat) -> UIFont {
        return UIFont(name: ISMChatSdkUI.getInstance().getCustomFontNames().light, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
     func regular(size: CGFloat) -> UIFont {
        return UIFont(name: ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
     func medium(size: CGFloat) -> UIFont {
        return UIFont(name: ISMChatSdkUI.getInstance().getCustomFontNames().medium, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
     func bold(size: CGFloat) -> UIFont {
        return UIFont(name: ISMChatSdkUI.getInstance().getCustomFontNames().bold, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
     func italic(size: CGFloat) -> UIFont {
        return UIFont(name: ISMChatSdkUI.getInstance().getCustomFontNames().italic, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
