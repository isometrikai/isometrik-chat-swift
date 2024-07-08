//
//  ISMImageViewer.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 24/04/23.
//

import SwiftUI

struct ISMImageViewer: View {
    //MARK:  - PROPERTIES
    var message : ISMChat_Message
    //MARK:  - LIFECYCLE
    var body: some View {
        ISMChat_ImageCahcingManger.networkImage(url:message.body ?? "", isprofileImage: false)
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
