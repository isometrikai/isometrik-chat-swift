//
//  ChatsView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 23/01/23.
//

import Foundation

public class ISMChat_Appearance {
    public var appearance: ISMAppearance
    public init(
        appearance: ISMAppearance = ISMAppearance()
    ) {
        self.appearance = appearance
    }
}

public class ISMAppearance {
    public var colorPalette : ISMChat_ColorPalette
    public var fonts : ISMChat_Fonts
    public var images :  ISMChat_Images
    public var messageBubbleType : ISMChat_BubbleType
    public init(
        colorPalette: ISMChat_ColorPalette = ISMChat_ColorPalette(),
        images: ISMChat_Images = ISMChat_Images(),
        fonts: ISMChat_Fonts = ISMChat_Fonts(),
        messageBubbleType : ISMChat_BubbleType = .BubbleWithOutTail
    ) {
        self.colorPalette = colorPalette
        self.images = images
        self.fonts = fonts
        self.messageBubbleType = messageBubbleType
    }
}


public enum ISMChat_BubbleType: Sendable{
    case BubbleWithTail
    case BubbleWithOutTail
}
