//
//  ISMChatPageProperty.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 17/11/23.
//

import Foundation
import SwiftUI

public struct ISMChatPageProperties {
    public var attachments: [ISMChatConfigAttachmentType] // Array of attachment types
    public var features : [ISMChatConfigFeature] // Array of chat features
    public var conversationType : [ISMChatConversationTypeConfig] // Array of conversation types
    public var hideNavigationBarForConversationList : Bool
    public var hostFrameworksType : FrameworkType
}


public enum FrameworkType{
    case SwiftUI
    case UIKit
}
