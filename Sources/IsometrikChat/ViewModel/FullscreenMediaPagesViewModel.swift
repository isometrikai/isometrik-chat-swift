//
//  File.swift
//  
//
//  Created by Rasika Bharati on 19/09/24.
//

import Foundation
import UIKit

public class ISMChatMediaViewerViewModel: ObservableObject {
    public var attachments: [MediaDB]
    @Published public var index: Int

    @Published public var showMinis = true
    @Published public var offset: CGSize = .zero

    @Published public var videoPlaying = false
    @Published public var videoMuted = false

    @Published public var toggleVideoPlaying = {}
    @Published public var toggleVideoMuted = {}

    public init(attachments: [MediaDB], index: Int) {
        self.attachments = attachments
        self.index = index
    }
}
