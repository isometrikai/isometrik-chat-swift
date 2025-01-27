//
//  ISMImageViewer.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 24/04/23.
//

import SwiftUI
import IsometrikChat

/// A SwiftUI view that displays a remote image with caching support
/// 
/// Use this view to load and display images from a URL while maintaining aspect ratio
/// and applying optional corner radius. The view handles image caching internally.
struct ISMImageViewer: View {
    // MARK: - Properties
    
    /// The remote URL string for the image to be displayed
    let url: String
    
    /// The desired size of the image container
    let size: CGSize
    
    /// Optional corner radius to apply to the image (defaults to 0 if nil)
    let cornerRadius: CGFloat?
    
    /// Creates a new image viewer with the specified parameters
    /// - Parameters:
    ///   - url: The remote URL string for the image
    ///   - size: The desired size of the image container
    ///   - cornerRadius: Optional corner radius to apply to the image (defaults to nil)
    public init(url: String, size: CGSize, cornerRadius: CGFloat? = nil) {
        self.url = url
        self.size = size
        self.cornerRadius = cornerRadius
    }
    
    // MARK: - View Body
    
    var body: some View {
        ISMChatImageCahcingManger.viewImage(url: url)
            .scaledToFill()  // Maintains aspect ratio while filling the frame
            .frame(width: size.width, height: size.height)
            .cornerRadius(cornerRadius ?? 0)  // Applies corner radius if provided, otherwise 0
    }
}
