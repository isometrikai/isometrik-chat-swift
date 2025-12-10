//
//  ImageCachingManger.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 20/04/23.
//

import SwiftUI
import SDWebImageSwiftUI
import SDWebImage

public class ISMChatImageCahcingManger {
    
    /// Configures SDWebImage cache settings for optimal performance
    /// Should be called during app initialization
    static public func configureImageCache() {
        let imageCache = SDImageCache.shared
        let config = imageCache.config
        
        // Configure memory cache (default is 50MB, increase for better performance)
        config.maxMemoryCost = 100 * 1024 * 1024 // 100 MB memory cache
        
        // Configure disk cache (default is 50MB, increase for chat apps with many images)
        config.maxDiskSize = 200 * 1024 * 1024 // 200 MB disk cache
        
        // Set disk cache expiration to 30 days (images should persist)
        config.maxDiskAge = 60 * 60 * 24 * 30 // 30 days in seconds
        
        // Enable disk cache compression for better storage
        config.shouldCacheImagesInMemory = true
        config.shouldUseWeakMemoryCache = true
        
        // Set cache type to use both memory and disk
//        config.diskCacheExpirationType = .accessDate
        
        ISMChatHelper.print("SDWebImage cache configured: Memory=100MB, Disk=200MB, Expiration=30 days")
    }
    
    /// Loads an image from a URL with a placeholder
    /// Images are loaded asynchronously and cached automatically
    static public func networkImage(url: String, isProfileImage: Bool, size: CGSize? = nil, placeholderView: some View) -> some View {
        WebImage(url: URL(string: url))
            .onSuccess { image, data, cacheType in
                // Image loaded successfully - cache is handled automatically by SDWebImage
            }
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
    /// Images are loaded asynchronously and cached automatically (memory + disk)
    static public func viewImage(url: String) -> some View {
        Group {
            if let thumbnailUrl = URL(string: url) {
                if ISMChatHelper.isVideo(media: thumbnailUrl) {
                    // For video thumbnails, use async view
                    AsyncThumbnailView(videoUrl: thumbnailUrl)
                } else {
                    // For regular images - WebImage handles async loading and caching automatically
                    WebImage(url: URL(string: url))
                        .onSuccess { image, data, cacheType in
                            // Image loaded successfully - cache is handled automatically
                            // cacheType indicates if image came from memory, disk, or network
                        }
                        .resizable()
                        .indicator(.activity) // Shows loading indicator while loading
                        .transition(.fade) // Smooth fade-in when image loads
                        .scaledToFill()
                }
            } else {
                // For invalid URLs
                WebImage(url: URL(string: url))
                    .onSuccess { image, data, cacheType in
                        // Image loaded successfully
                    }
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
                // Check cache first for video thumbnails
                if let cached = ThumbnailCache.shared.get(for: videoUrl) {
                    self.thumbnailUrl = cached
                } else {
                    // Generate thumbnail asynchronously if not cached
                    ISMChatHelper.generateThumbnailImageURL(from: videoUrl) { imageUrl in
                        DispatchQueue.main.async {
                            if let imageUrl{
                                // Cache the thumbnail for future use
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
