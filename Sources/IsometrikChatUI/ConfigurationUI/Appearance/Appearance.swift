//
//  ChatsView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 23/01/23.
//

import Foundation
import SwiftUI

public class ISMChatAppearance {
    public var appearance: ISMAppearance
    public init(
        appearance: ISMAppearance = ISMAppearance()
    ) {
        self.appearance = appearance
    }
}

public class ISMAppearance {
    public var colorPalette : ISMChatColorPalette
    public var fonts : ISMChatFonts
    public var images :  ISMChatImages
    public var messageBubbleType : ISMChatBubbleType
    public var messageBubbleTailPosition : ISMChatTailPosition
    public var placeholders : ISMChatPlaceholders
    public var timeInsideBubble : Bool
    public var imagesSize : ISMChatImageSizes
    public var constantStrings : ISMChatStrings
    public var messageListBackgroundImage : String?
    public var dateFormats : ISMChatDateFormats
    public init(
        colorPalette: ISMChatColorPalette = ISMChatColorPalette(),
        images: ISMChatImages = ISMChatImages(),
        fonts: ISMChatFonts = ISMChatFonts(),
        messageBubbleType : ISMChatBubbleType = .BubbleWithOutTail,
        messageBubbleTailPosition : ISMChatTailPosition = .bottom,
        placeholders: ISMChatPlaceholders = ISMChatPlaceholders(),
        timeInsideBubble : Bool = true,
        imagesSize : ISMChatImageSizes = ISMChatImageSizes(),
        constantStrings : ISMChatStrings = ISMChatStrings(),
        messageListBackgroundImage: String? = nil,
        dateFormats : ISMChatDateFormats = ISMChatDateFormats()
    ) {
        self.colorPalette = colorPalette
        self.images = images
        self.fonts = fonts
        self.messageBubbleType = messageBubbleType
        self.messageBubbleTailPosition = messageBubbleTailPosition
        self.placeholders = placeholders
        self.timeInsideBubble = timeInsideBubble
        self.imagesSize = imagesSize
        self.constantStrings = constantStrings
        self.messageListBackgroundImage = messageListBackgroundImage ??  ""
        self.dateFormats = dateFormats
    }
}

public class ISMChatDateFormats{
    public var conversationListLastMessageDate : String = "dd/MM/yyyy"
    public init(){}
    public init(conversationListLastMessageDate: String) {
        self.conversationListLastMessageDate = conversationListLastMessageDate
    }
}
public class ISMChatStrings {
    public var endToEndEncrypted : String = "Messages are end to end encrypted. No one outside of this chat can read to them."
    public var messageInputTextViewPlaceholder : String = "Type a message"
    public var messageDeletedByMe : String = "You deleted this message."
    public var messageDeletedByOther : String = "This message was deleted."
    public init(){}
    public init(endToEndEncrypted: String? = nil,messageInputTextViewPlaceholder : String? = nil,messageDeletedByMe : String? = nil,messageDeletedByOther : String? = nil) {
        self.endToEndEncrypted = endToEndEncrypted ?? self.endToEndEncrypted
        self.messageInputTextViewPlaceholder = messageInputTextViewPlaceholder ?? self.messageInputTextViewPlaceholder
        self.messageDeletedByMe = messageDeletedByMe ?? self.messageDeletedByMe
        self.messageDeletedByOther = messageDeletedByOther ?? self.messageDeletedByOther
    }
}

public class ISMChatPlaceholders {
    let images: ISMChatImages = ISMChatImages()
    public var chatListPlaceholder: AnyView
    public var messageListPlaceholder: AnyView
    public var otherchatListPlaceholder: AnyView
    public var broadCastListPlaceholder: AnyView
    public var groupInfo_groupMembers: AnyView
    
    public init(
        chatListPlaceholder: AnyView? = nil,
        messageListPlaceholder: AnyView? = nil,
        otherchatListPlaceholder: AnyView? = nil,
        broadCastListPlaceholder: AnyView? = nil,
        groupInfo_groupMembers: AnyView? = nil
    ) {
        self.chatListPlaceholder = chatListPlaceholder ??
            ISMChatPlaceholders.defaultPlaceholder(
                imageName: images.chatListPlaceHolder,
                text: "No chats found!"
            )
        self.messageListPlaceholder = messageListPlaceholder ??
            ISMChatPlaceholders.defaultPlaceholder(
                imageName: images.messagesPlaceHolder,
                text: "No message here yet!"
            )
        self.otherchatListPlaceholder = otherchatListPlaceholder ??
            ISMChatPlaceholders.defaultPlaceholder(
                imageName: images.chatListPlaceHolder,
                text: "No chats found!"
            )
        self.broadCastListPlaceholder = broadCastListPlaceholder ??
            ISMChatPlaceholders.defaultPlaceholder(
                imageName: images.bordCastPlaceHolder,
                text: "No broadcast list found!"
            )
        self.groupInfo_groupMembers = groupInfo_groupMembers ??
            ISMChatPlaceholders.defaultPlaceholder(
                imageName: images.membersPlaceHolder,
                text: "No such member found!"
            )
    }

    public static func defaultPlaceholder(imageName: Image, text: String) -> AnyView {
        AnyView(
            VStack(spacing: 20) {
                imageName
                    .frame(width: 120, height: 120)
                Text(text)
                    .foregroundColor(Color(hex: "#242424"))
                    .font(.system(size: 16, weight: .bold))
            }
        )
    }
}

public enum ISMChatTailPosition: Sendable {
    case top
    case bottom
}
public enum ISMChatBubbleType: Sendable{
    case BubbleWithTail
    case BubbleWithOutTail
}

public class ISMChatCustomFontNames{
    public var light : String = "ProductSans-Light"
    public var regular : String = "ProductSans-Regular"
    public var medium : String = "ProductSans-Medium"
    public var bold : String = "ProductSans-Bold"
    public var semibold : String = "ProductSans-SemiBold"
    public var italic : String = "ProductSans-Italic"
    public init(){}
    public init(light: String? = nil, regular: String? = nil, bold: String? = nil,semiBold : String? = nil, medium: String? = nil, italic: String? = nil) {
        self.light = light ?? self.light
        self.regular = regular ?? self.regular
        self.bold = bold ?? self.bold
        self.semibold = semiBold ?? self.semibold
        self.medium = medium ?? self.medium
        self.italic = italic ?? self.italic
    }
}

public class ISMChatCustomSearchBar {
    let images: ISMChatImages = ISMChatImages()
    
    public var height: Int
    public var cornerRadius: Int
    public var borderWidth: Double
    public var searchBarBackgroundColor: Color
    public var searchBarBorderColor: Color
    public var showCrossButton: Bool
    public var searchBarSearchIcon: Image
    public var searchCrossIcon: Image
    public var sizeOfSearchIcon: CGSize
    public var sizeofCrossIcon: CGSize
    public var searchPlaceholderText: String
    public var searchPlaceholderTextColor: Color
    public var searchTextFont: Font
    
    public init(
        height: Int = 44,
        cornerRadius: Int = 8,
        borderWidth: Double = 1.0,
        searchBarBackgroundColor: Color = .white,
        searchBarBorderColor: Color = .gray,
        showCrossButton: Bool = true,
        searchBarSearchIcon: Image? = nil,
        searchCrossIcon: Image? = nil,
        sizeOfSearchIcon: CGSize = CGSize(width: 20, height: 20),
        sizeofCrossIcon: CGSize = CGSize(width: 20, height: 20),
        searchPlaceholderText: String = "Search",
        searchPlaceholderTextColor: Color = .gray,
        searchTextFont: Font = .system(size: 14)
    ) {
        self.height = height
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.searchBarBackgroundColor = searchBarBackgroundColor
        self.searchBarBorderColor = searchBarBorderColor
        self.showCrossButton = showCrossButton
        self.searchBarSearchIcon = searchBarSearchIcon ?? images.searchIcon
        self.searchCrossIcon = searchCrossIcon ?? images.cancelWithGreyBackground
        self.sizeOfSearchIcon = sizeOfSearchIcon
        self.sizeofCrossIcon = sizeofCrossIcon
        self.searchPlaceholderText = searchPlaceholderText
        self.searchPlaceholderTextColor = searchPlaceholderTextColor
        self.searchTextFont = searchTextFont
    }
}


public class ISMChatImageSizes{
    public var backButton : CGSize = CGSize(width: 18, height: 18)
    public var messageRead : CGSize = CGSize(width: 15, height: 9)
    public var messageDelivered : CGSize = CGSize(width: 15, height: 9)
    public var messageSend : CGSize = CGSize(width: 11, height: 9)
    public var messagePending : CGSize = CGSize(width: 9, height: 9)
    public var messageInfo_replyIcon : CGSize = CGSize(width: 18, height: 18)
    public var messageInfo_forwardIcon : CGSize = CGSize(width: 18, height: 18)
    public var messageInfo_editIcon : CGSize = CGSize(width: 18, height: 18)
    public var messageInfo_copyIcon : CGSize = CGSize(width: 23, height: 23)
    public var messageInfo_infoIcon : CGSize = CGSize(width: 23, height: 23)
    public var messageInfo_deleteIcon : CGSize = CGSize(width: 18, height: 18)
    public var messageAudioButton : CGSize = CGSize(width: 24, height: 24)
    public var addAttachmentIcon : CGSize = CGSize(width: 20, height: 20)
    public var deletedMessageLogo : CGSize = CGSize(width: 18, height: 18)
    public var documentIcon : CGSize = CGSize(width: 30, height: 30)
    public var mapPinLogo : CGSize = CGSize(width: 30, height: 30)
    public var cancelReplyMessage : CGSize = CGSize(width: 20, height: 20)
    public init(){}
    public init(backButton: CGSize? = nil,messageRead: CGSize? = nil,messageDelivered : CGSize? = nil,messageSend : CGSize? = nil,messagePending : CGSize? = nil,messageInfo_replyIcon: CGSize? = nil,messageInfo_forwardIcon: CGSize? = nil,messageInfo_editIcon: CGSize? = nil,messageInfo_copyIcon: CGSize? = nil,messageInfo_infoIcon: CGSize? = nil,messageInfo_deleteIcon: CGSize? = nil,messageAudioButton : CGSize? = nil,addAttachmentIcon : CGSize? = nil,deletedMessageLogo : CGSize? = nil,documentIcon : CGSize? = nil,mapPinLogo: CGSize? = nil,cancelReplyMessage: CGSize? = nil) {
        self.backButton = backButton ?? CGSize(width: 18, height: 18)
        self.messageRead = messageRead ?? CGSize(width: 15, height: 9)
        self.messageDelivered = messageDelivered ?? CGSize(width: 15, height: 9)
        self.messageSend = messageSend ?? CGSize(width: 11, height: 9)
        self.messagePending = messagePending ?? CGSize(width: 11, height: 9)
        self.messageInfo_replyIcon = messageInfo_replyIcon ?? CGSize(width: 18, height: 18)
        self.messageInfo_forwardIcon = messageInfo_forwardIcon ?? CGSize(width: 18, height: 18)
        self.messageInfo_editIcon = messageInfo_editIcon ?? CGSize(width: 18, height: 18)
        self.messageInfo_copyIcon = messageInfo_copyIcon ?? CGSize(width: 18, height: 18)
        self.messageInfo_infoIcon = messageInfo_infoIcon ?? CGSize(width: 18, height: 18)
        self.messageInfo_deleteIcon = messageInfo_deleteIcon ?? CGSize(width: 18, height: 18)
        self.messageAudioButton = messageAudioButton ?? CGSize(width: 24, height: 24)
        self.addAttachmentIcon = addAttachmentIcon ?? CGSize(width: 20, height: 20)
        self.deletedMessageLogo = deletedMessageLogo ?? CGSize(width: 18, height: 18)
        self.documentIcon = documentIcon ?? CGSize(width: 30, height: 30)
        self.mapPinLogo = mapPinLogo ?? CGSize(width: 30, height: 30)
        self.cancelReplyMessage = cancelReplyMessage ?? CGSize(width: 20, height: 20)
    }
}
