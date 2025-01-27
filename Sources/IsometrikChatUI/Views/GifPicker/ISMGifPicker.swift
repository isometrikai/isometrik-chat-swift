//
//  File.swift
//  
//
//  Created by Rasika Bharati on 30/09/24.
//

import Foundation
import SwiftUI
import GiphyUISDK
import WebKit
import IsometrikChat

/// A SwiftUI wrapper for the Giphy SDK's GIF picker interface
/// This view controller allows users to search and select GIFs, stickers, and emojis from Giphy
struct ISMGiphyPicker: UIViewControllerRepresentable {
    /// Callback closure that handles the selected media
    /// - Parameter GPHMedia?: The selected media object or nil if dismissed
    let didSelectMedia: (GPHMedia?) -> Void
    
    /// Giphy API key retrieved from IsometrikChat SDK instance
    let giphyApiKey = ISMChatSdk.getInstance().getGiphyApiKey()
    
    /// Creates and configures the Giphy view controller
    /// - Parameter context: The context in which the view controller is created
    /// - Returns: A configured GiphyViewController instance
    func makeUIViewController(context: UIViewControllerRepresentableContext<ISMGiphyPicker>) -> GiphyViewController {
        // Configure Giphy SDK with API key
        Giphy.configure(apiKey: giphyApiKey)
        
        // Initialize and configure the Giphy view controller
        let giphy = GiphyViewController()
        giphy.delegate = context.coordinator
        // Configure available media types (recents, stickers, emoji, and GIFs)
        giphy.mediaTypeConfig = [.recents, .stickers, .emoji, .gifs]
        // Set the tray to take up full height
        GiphyViewController.trayHeightMultiplier = 1.0
        // Enable SwiftUI compatibility
        giphy.swiftUIEnabled = true
        // Enable search localization
        giphy.shouldLocalizeSearch = true
        // Enable background dimming
        giphy.dimBackground = true
        giphy.modalPresentationStyle = .currentContext
        // Set light blur theme
        giphy.theme = GPHTheme(type: .lightBlur)
        
        return giphy
    }
    
    /// Updates the view controller (not used in this implementation)
    func updateUIViewController(_ uiViewController: GiphyViewController, context: Context) {}
    
    /// Creates a coordinator to handle the Giphy delegate callbacks
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// Coordinator class that handles Giphy delegate methods
    final class Coordinator: NSObject, GiphyDelegate {
        /// Reference to the parent ISMGiphyPicker
        var parent: ISMGiphyPicker
        
        /// Initializes the coordinator with a reference to the parent picker
        /// - Parameter parent: The ISMGiphyPicker instance
        init(_ parent: ISMGiphyPicker) {
            self.parent = parent
        }
        
        /// Called when a user selects a media item
        /// - Parameters:
        ///   - giphyViewController: The active Giphy view controller
        ///   - media: The selected media object
        func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
            print(media)
            parent.didSelectMedia(media)
        }
        
        /// Called when the Giphy picker is dismissed
        /// - Parameter controller: The dismissed Giphy view controller
        func didDismiss(controller: GiphyUISDK.GiphyViewController?) {
            parent.didSelectMedia(nil)
        }
    }
}

