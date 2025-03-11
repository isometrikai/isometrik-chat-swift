//
//  SwiftUIView.swift
//  
//
//  Created by Rasika Bharati on 19/09/24.
//

import SwiftUI
import IsometrikChat

/// A SwiftUI view that displays media attachments in a chat interface
/// This cell handles different types of media including videos, GIFs, and images
struct ISMChatAttachmentCell: View {
    
    // MARK: - Properties
    
    /// The media attachment to be displayed
    let attachment: ISMChatMediaDB
    
    /// Callback closure triggered when the attachment is tapped
    let onTap: (ISMChatMediaDB) -> Void
    
    /// UI appearance configuration for the chat SDK
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    // MARK: - Body
    
    var body: some View {
        Group {
            // Handle different media types with appropriate display logic
            if ISMChatHelper.isVideoString(media: attachment.mediaUrl) {
                // For videos, display the thumbnail image
                ISMChatImageCahcingManger.viewImage(url: attachment.thumbnailUrl)
            } else if attachment.mediaUrl.contains("gif") {
                // For GIFs, display the direct media URL
                ISMChatImageCahcingManger.viewImage(url: attachment.mediaUrl)
            } else {
                // For regular images, display the direct media URL
                ISMChatImageCahcingManger.viewImage(url: attachment.mediaUrl)
            }
        }
        // Make the entire cell tappable
        .contentShape(Rectangle())
        .onTapGesture {
            onTap(attachment)
        }
    }
}
