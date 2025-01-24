////
////  ISMLinkPreviewSubView.swift
////  ISMChatSdk
////
////  Created by Rahul Sharma on 04/04/23.
////
//
import Foundation
import SwiftUI
import LinkPresentation

/// A view that displays a preview toolbar for URLs with metadata
struct LinkPreviewToolBarView : View {
    let text : String
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @State private var metadata: LPLinkMetadata?
    @State private var isLoading = true
    
    var body : some View{
        VStack {
            if let metadata = metadata {
                HStack(spacing: 8) {
                    // Display preview image if available
                    if let imageProvider = metadata.imageProvider {
                        LinkPreviewImage(imageProvider: imageProvider)
                            .frame(width: 45, height: 45)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .clipped()
                    }
                    
                    // Display title and description
                    VStack(alignment: .leading, spacing: 4) {
                        Text(metadata.title ?? "")
                            .font(appearance.fonts.messageListReplyToolbarHeader)
                            .foregroundColor(appearance.colorPalette.messageListReplyToolbarHeader)
                            .lineLimit(1)
                        
                        
                        Text(text)
                            .font(appearance.fonts.messageListReplyToolbarDescription)
                            .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                    }
                    Spacer()
                }
            } else if isLoading {
                ProgressView()
            }
        }
        .onAppear {
            loadMetadata()
        }
        .background(appearance.colorPalette.messageListattachmentBackground)
        .frame(height: 70)
    }
    
    /// Fetches metadata for the URL
    /// - Note: Adds https:// prefix if not present in the URL
    private func loadMetadata() {
        let provider = LPMetadataProvider()
        var url = URL(string: text)
        if !text.contains("https"){
            let URLString = "https://" + text.trimmingCharacters(in: .whitespaces)
            url = URL(string: URLString)
        }
        
        provider.startFetchingMetadata(for: url!) { metadata, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.metadata = metadata
                self.isLoading = false
            }
        }
    }
}

/// A view that displays a rich preview for URLs including image and metadata
struct ISMLinkPreview: View {
    // Input properties
    let url: URL
    let isRecived : Bool
    
    // State management
    @State private var metadata: LPLinkMetadata?
    @State private var isLoading = true
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    var body: some View {
        Group {
            if let metadata = metadata {
                VStack(alignment: .leading, spacing: 8) {
                    if let imageProvider = metadata.imageProvider {
                        LinkPreviewImage(imageProvider: imageProvider)
                            .frame(width: 280, height: 200)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .clipped()
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(metadata.title ?? "")
                            .font(appearance.fonts.messageListMessageText)
                            .foregroundColor(isRecived ? appearance.colorPalette.messageListMessageTextReceived   : appearance.colorPalette.messageListMessageTextSend)
                            .lineLimit(2)
                        
                        
                        Text(url.host ?? "")
                            .font(appearance.fonts.messageListMessageTime)
                            .foregroundColor(isRecived ? appearance.colorPalette.messageListMessageTimeReceived : appearance.colorPalette.messageListMessageTimeSend)
                    }
                    .padding(.horizontal,5)
                }
                .cornerRadius(8)
            } else if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            }
        }
        .onAppear {
            loadMetadata()
        }
    }
    
    /// Fetches metadata for the provided URL using LinkPresentation framework
    private func loadMetadata() {
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { metadata, error in
            DispatchQueue.main.async {
                self.metadata = metadata
                self.isLoading = false
            }
        }
    }
}

/// A view that handles loading and displaying preview images from NSItemProvider
struct LinkPreviewImage: View {
    let imageProvider: NSItemProvider
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // Show placeholder while image loads
                Color.gray.opacity(0.3)
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    /// Asynchronously loads the image from the NSItemProvider
    private func loadImage() {
        imageProvider.loadObject(ofClass: UIImage.self) { image, error in
            if let image = image as? UIImage {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}


