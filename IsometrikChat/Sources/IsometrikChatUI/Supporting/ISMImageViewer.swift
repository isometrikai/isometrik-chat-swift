//
//  ISMImageViewer.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 24/04/23.
//

import SwiftUI
import IsometrikChat

struct ISMImageViewer: View {
    //MARK:  - PROPERTIES
    var message : ISMChatMessage
    //MARK:  - LIFECYCLE
    var body: some View {
        ISMChatImageCahcingManger.networkImage(url:message.body ?? "", isprofileImage: false)
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
