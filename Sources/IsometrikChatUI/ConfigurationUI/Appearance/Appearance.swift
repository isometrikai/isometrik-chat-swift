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
    public init(
        colorPalette: ISMChatColorPalette = ISMChatColorPalette(),
        images: ISMChatImages = ISMChatImages(),
        fonts: ISMChatFonts = ISMChatFonts(),
        messageBubbleType : ISMChatBubbleType = .BubbleWithOutTail,
        messageBubbleTailPosition : ISMChatTailPosition = .bottom,
        placeholders: ISMChatPlaceholders = ISMChatPlaceholders(),
        timeInsideBubble : Bool = true,
        imagesSize : ISMChatImageSizes = ISMChatImageSizes(),
        constantStrings : ISMChatStrings = ISMChatStrings()
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
    }
}


public class ISMChatStrings {
    public var endToEndEncrypted : String = "Messages are end to end encrypted. No one \noutside of this chat can read to them."
    public init(){}
    public init(endToEndEncrypted: String) {
        self.endToEndEncrypted = endToEndEncrypted
    }
}

public class ISMChatPlaceholders {
    public var chatListPlaceholder : AnyView = AnyView(VStack{})
    public var messageListPlaceholder : AnyView  = AnyView(VStack{})
    public var otherchatListPlaceholder : AnyView  = AnyView(VStack{})
    public var broadCastListPlaceholder : AnyView  = AnyView(VStack{})
    public init(){}
    public init(chatListPlaceholder: AnyView, messageListPlaceholder: AnyView, otherchatListPlaceholder: AnyView, broadCastListPlaceholder: AnyView) {
        self.chatListPlaceholder = chatListPlaceholder
        self.messageListPlaceholder = messageListPlaceholder
        self.otherchatListPlaceholder = otherchatListPlaceholder
        self.broadCastListPlaceholder = broadCastListPlaceholder
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
    public var italic : String = "ProductSans-Italic"
    public init(){}
    public init(light: String, regular: String, bold: String, medium: String, italic: String) {
        self.light = light
        self.regular = regular
        self.bold = bold
        self.medium = medium
        self.italic = italic
    }
}


public class ISMChatImageSizes{
    public var backButton : CGSize = CGSize(width: 18, height: 18)
    public var messageRead : CGSize = CGSize(width: 15, height: 9)
    public var messageDelivered : CGSize = CGSize(width: 15, height: 9)
    public var messageSend : CGSize = CGSize(width: 11, height: 9)
    public var messagePending : CGSize = CGSize(width: 9, height: 9)
    public init(){}
    public init(backButton: CGSize,messageRead: CGSize,messageDelivered : CGSize,messageSend : CGSize,messagePending : CGSize) {
        self.backButton = backButton
        self.messageRead = messageRead
        self.messageDelivered = messageDelivered
        self.messageSend = messageSend
        self.messagePending = messagePending
    }
}
