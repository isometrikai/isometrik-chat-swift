//
//  ChatsView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 23/01/23.
//

import UIKit
import SwiftUI
import UIKit


    public struct ISMChatFonts {

        public var navigationBarTitle : Font = Font.bold(size: 14)
        //alerts
        public var alertText : Font = Font.regular(size: 14)
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
        
        public init(){}
        
        public init(navigationBarTitle: Font, alertText: Font, userProfileDescription: Font, userProfileeditText: Font, userProfilefields: Font, userProfilesectionHeader: Font, userProfileDoneButton: Font, chatListTitle: Font, chatListUserName: Font, chatListUserMessage: Font, chatListLastMessageTime: Font, chatListUnreadMessageCount: Font, messageListHeaderTitle: Font, messageListHeaderDescription: Font, messageListSectionHeaderText: Font, messageListMessageText: Font,messageListMessageMoreAndLess: Font, messageListMessageForwarded: Font, messageListMessageDeleted: Font, messageListMessageEdited: Font, messageListMessageTime: Font, messageListTextViewText: Font, messageListActionText: Font, messageListReplyToolbarHeader: Font, messageListReplyToolbarDescription: Font, messageListtoolbarSelected: Font, messageListtoolbarAction: Font, messageListreactionCount: Font, messageListgroupMemberUserName: Font, messageListcallingHeader: Font, messageListcallingTime: Font, mediaSliderHeader: Font, mediaSliderDescription: Font, contactInfoHeader: Font,searchbarText :Font,avatarText : Font,contextMenuOptions : Font,attachmentsText : Font,locationMessageTitle : Font,locationMessageDescription: Font) {
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
