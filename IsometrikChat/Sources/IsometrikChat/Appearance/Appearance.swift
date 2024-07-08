//
//  ChatsView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 23/01/23.
//

import Foundation

public class ISMChat_Appearance {
    var appearance: Appearance
    public init(
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
    }
}

public class Appearance {
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


public enum ISMChat_BubbleType{
    case BubbleWithTail
    case BubbleWithOutTail
}
