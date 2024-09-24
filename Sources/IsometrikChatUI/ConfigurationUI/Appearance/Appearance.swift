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
    public var placeholders : ISMChatPlaceholders
    public var timeInsideBubble : Bool
    public init(
        colorPalette: ISMChatColorPalette = ISMChatColorPalette(),
        images: ISMChatImages = ISMChatImages(),
        fonts: ISMChatFonts = ISMChatFonts(),
        messageBubbleType : ISMChatBubbleType = .BubbleWithOutTail,
        placeholders: ISMChatPlaceholders = ISMChatPlaceholders(),
        timeInsideBubble : Bool = true
    ) {
        self.colorPalette = colorPalette
        self.images = images
        self.fonts = fonts
        self.messageBubbleType = messageBubbleType
        self.placeholders = placeholders
        self.timeInsideBubble = timeInsideBubble
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
