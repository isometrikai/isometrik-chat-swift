//
//  ISMAudioPreviewModel.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 15/05/23.
//

import Foundation
import SwiftUI

public struct ISMChat_AudioPreviewModel: Hashable {
    public var magnitude: Float
    public var color: Color
}

public struct ISMChat_Recording : Equatable {
    public let fileURL : URL
    public let createdAt : Date
    public var isPlaying : Bool
}
