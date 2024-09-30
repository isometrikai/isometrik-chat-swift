//
//  SwiftUIView.swift
//  
//
//  Created by Rasika Bharati on 19/09/24.
//

import SwiftUI
import IsometrikChat
import SDWebImageSwiftUI

struct ISMChatMediaView : View {

    @EnvironmentObject var mediaPagesViewModel: ISMChatMediaViewerViewModel

    let attachment: MediaDB

    var body: some View {
        if ISMChatHelper.isVideoString(media: attachment.mediaUrl) {
            ISMChatVideoView(viewModel: ISMChatVideoViewModel(attachment: attachment))
        }else if attachment.mediaUrl.contains("gif"){
            AnimatedImage(url: URL(string: attachment.mediaUrl ?? ""))
        }else{
            ISMChatImageCahcingManger.viewImage(url: attachment.mediaUrl)
        }
    }
}
