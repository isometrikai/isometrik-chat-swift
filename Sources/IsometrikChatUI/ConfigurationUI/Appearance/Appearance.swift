//
//  ChatsView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 23/01/23.
//

import Foundation

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
    public var text : ISMChatText
    public var messageBubbleType : ISMChatBubbleType
    public init(
        colorPalette: ISMChatColorPalette = ISMChatColorPalette(),
        images: ISMChatImages = ISMChatImages(),
        fonts: ISMChatFonts = ISMChatFonts(),
        text : ISMChatText = ISMChatText(),
        messageBubbleType : ISMChatBubbleType = .BubbleWithOutTail
    ) {
        self.colorPalette = colorPalette
        self.images = images
        self.fonts = fonts
        self.text = text
        self.messageBubbleType = messageBubbleType
    }
}


public enum ISMChatBubbleType: Sendable{
    case BubbleWithTail
    case BubbleWithOutTail
}



public struct ISMChatText{
    var conversationListPlaceholderText : String = ""
    var messagesListPlaceholderText : String = ""
    var broadcastListPlaceholderText : String = ""
    var otherconversationText : String = ""
    
    public init(conversationListPlaceholderText: String? = "", messagesListPlaceholderText: String? = "", broadcastListPlaceholderText: String? = "", otherconversationText: String? = "") {
        self.conversationListPlaceholderText = conversationListPlaceholderText ?? ""
        self.messagesListPlaceholderText = messagesListPlaceholderText ?? ""
        self.broadcastListPlaceholderText = broadcastListPlaceholderText ?? ""
        self.otherconversationText = otherconversationText ?? ""
    }
    
    public init(){}
    
    
}
