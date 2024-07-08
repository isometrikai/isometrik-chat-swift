//
//  ISMChatPageProperty.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 17/11/23.
//

import Foundation
import SwiftUI

public struct ISMChat_PageProperties {
    var attachments: [ISMChat_ConfigAttachmentType] // Array of attachment types
    var features : [ISMChat_ConfigFeature] // Array of chat features
    var conversationType : [ISMChat_ConversationTypeConfig] // Array of conversation types
}
