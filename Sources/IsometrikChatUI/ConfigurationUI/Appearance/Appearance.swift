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
    public var messageCustomBubbleView : ISMChatMessageCustomBubble
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
        messageCustomBubbleView : ISMChatMessageCustomBubble = ISMChatMessageCustomBubble(),
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
        self.messageCustomBubbleView = messageCustomBubbleView
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
    public var endToEndEncrypted : String = "Messages are end to end encrypted. No one \noutside of this chat can read to them."
    public var messageInputTextViewPlaceholder : String = "Type a message"
    public var messageDeletedByMe : String = "You deleted this message."
    public var messageDeletedByOther : String = "This message was deleted."
    public init(){}
    public init(endToEndEncrypted: String? = nil,messageInputTextViewPlaceholder : String? = nil,messageDeletedByMe : String? = nil,messageDeletedByOther : String? = nil) {
        self.endToEndEncrypted = endToEndEncrypted ?? ""
        self.messageInputTextViewPlaceholder = messageInputTextViewPlaceholder ?? ""
        self.messageDeletedByMe = messageDeletedByMe ?? ""
        self.messageDeletedByOther = messageDeletedByOther ?? ""
    }
}

public class ISMChatPlaceholders {
    public var chatListPlaceholder : AnyView = AnyView(VStack{})
    public var messageListPlaceholder : AnyView  = AnyView(VStack{})
    public var otherchatListPlaceholder : AnyView  = AnyView(VStack{})
    public var broadCastListPlaceholder : AnyView  = AnyView(VStack{})
    public var groupInfo_groupMembers : AnyView = AnyView(VStack{})
    public init(){}
    public init(chatListPlaceholder: AnyView, messageListPlaceholder: AnyView, otherchatListPlaceholder: AnyView, broadCastListPlaceholder: AnyView,groupInfo_groupMembers: AnyView) {
        self.chatListPlaceholder = chatListPlaceholder
        self.messageListPlaceholder = messageListPlaceholder
        self.otherchatListPlaceholder = otherchatListPlaceholder
        self.broadCastListPlaceholder = broadCastListPlaceholder
        self.groupInfo_groupMembers = groupInfo_groupMembers
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
    public var semibold : String = "ProductSans-Bold"
    public var italic : String = "ProductSans-Italic"
    public init(){}
    public init(light: String, regular: String, bold: String,semiBold : String, medium: String, italic: String) {
        self.light = light
        self.regular = regular
        self.bold = bold
        self.semibold = semiBold
        self.medium = medium
        self.italic = italic
    }
}

public class ISMChatCustomSearchBar{
    public var height : Int
    public var cornerRadius : Int
    public var borderWidth : Double
    public var searchBarBackgroundColor : Color
    public var searchBarBorderColor : Color
    public var showCrossButton : Bool
    public var searchBarSearchIcon : Image
    public var searchCrossIcon : Image
    public var sizeOfSearchIcon : CGSize
    public var sizeofCrossIcon : CGSize
    public var searchPlaceholderText : String
    public var searchPlaceholderTextColor : Color
    public var searchTextFont : Font
    public init(height: Int,cornerRadius: Int,borderWidth: Double,searchBarBackgroundColor : Color,searchBarBorderColor: Color,showCrossButton: Bool,searchBarSearchIcon: Image,searchCrossIcon: Image,sizeOfSearchIcon: CGSize,sizeofCrossIcon: CGSize,searchPlaceholderText: String,searchPlaceholderTextColor: Color,searchTextFont: Font){
        self.height = height
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.searchBarBackgroundColor = searchBarBackgroundColor
        self.searchBarBorderColor = searchBarBorderColor
        self.showCrossButton = showCrossButton
        self.searchBarSearchIcon = searchBarSearchIcon
        self.searchCrossIcon = searchCrossIcon
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
