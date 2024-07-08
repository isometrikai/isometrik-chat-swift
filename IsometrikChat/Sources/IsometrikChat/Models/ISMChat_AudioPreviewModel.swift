//
//  ISMAudioPreviewModel.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 15/05/23.
//

import Foundation
import SwiftUI

struct ISMChat_AudioPreviewModel: Hashable {
    var magnitude: Float
    var color: Color
}

struct ISMChat_Recording : Equatable {
    let fileURL : URL
    let createdAt : Date
    var isPlaying : Bool
}
