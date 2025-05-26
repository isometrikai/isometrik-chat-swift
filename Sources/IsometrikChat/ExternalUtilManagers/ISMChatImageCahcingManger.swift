//
//  ImageCachingManger.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 20/04/23.
//

import SwiftUI
import SDWebImageSwiftUI

public class ISMChatImageCahcingManger {
    
    /// Loads an image from a URL with a placeholder
    static public func networkImage(url: String, isProfileImage: Bool, size: CGSize? = nil, placeholderView: some View) -> some View {
        WebImage(url: URL(string: url))
            .resizable()
            .indicator(.activity) // Show loading spinner
            .transition(.fade) // Smooth fade-in effect
            .scaledToFill()
            .background(
                AnyView(
                    isProfileImage ? AnyView(placeholderView) :
                        AnyView(Image("loading")
                            .resizable()
                            .frame(width: 20, height: 20))
                )
            )
    }
    
    /// Loads an image from a URL with a default loading indicator
    static public func viewImage(url: String) -> some View {
        Group {
            if let thumbnailUrl = URL(string: url) {
                if ISMChatHelper.isVideo(media: thumbnailUrl) {
                    // For video thumbnails, use async view
                    AsyncThumbnailView(videoUrl: thumbnailUrl)
                } else {
                    // For regular images
                    WebImage(url: URL(string: url))
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade)
                        .scaledToFill()
                }
            } else {
                // For invalid URLs
                WebImage(url: URL(string: url))
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade)
                    .scaledToFill()
            }
        }
    }

    // Helper view for async thumbnail generation
    struct AsyncThumbnailView: View {
        let videoUrl: URL
        @State private var thumbnailUrl: URL?
        
        var body: some View {
            Group {
                if let thumbnailUrl = thumbnailUrl {
                    WebImage(url: thumbnailUrl)
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade)
                        .scaledToFill()
                } else {
                    ProgressView()
                }
            }
            .onAppear {
                if let cached = ThumbnailCache.shared.get(for: videoUrl) {
                    self.thumbnailUrl = cached
                } else {
                    ISMChatHelper.generateThumbnailImageURL(from: videoUrl) { imageUrl in
                        DispatchQueue.main.async {
                            if let imageUrl{
                                ThumbnailCache.shared.set(thumbnail: imageUrl, for: videoUrl)
                                self.thumbnailUrl = imageUrl
                            }
                        }
                    }
                }
            }

        }
    }
}
