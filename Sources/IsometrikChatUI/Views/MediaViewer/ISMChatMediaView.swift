//
//  SwiftUIView.swift
//  
//
//  Created by Rasika Bharati on 19/09/24.
//

import SwiftUI
import IsometrikChat
import SDWebImageSwiftUI

/// A SwiftUI view that handles the display of different types of media (videos, GIFs, and images)
/// in the chat interface.
struct ISMChatMediaView : View {
    /// View model that manages the media viewer's state and navigation
    @EnvironmentObject var mediaPagesViewModel: ISMChatMediaViewerViewModel
    
    /// The media attachment data to be displayed
    let attachment: ISMChatMediaDB
    
    var body: some View {
        // Determine the type of media and display appropriate view
        if ISMChatHelper.isVideoString(media: attachment.mediaUrl) {
            // For video content, use the video player view
            ISMChatVideoView(viewModel: ISMChatVideoViewModel(attachment: attachment))
        } else if attachment.mediaUrl.contains("gif") {
            // For GIF content, use SDWebImage's AnimatedImage view
            AnimatedImage(url: URL(string: attachment.mediaUrl ?? ""))
        } else {
            // For static images, use cached image view with aspect ratio fitting
            ISMChatImageCahcingManger.viewImage(url: attachment.mediaUrl)
                .aspectRatio(contentMode: .fit)
        }
    }
}
