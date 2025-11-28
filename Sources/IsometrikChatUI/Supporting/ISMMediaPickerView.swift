//
//  ISMMediaPickerView.swift
//  ISMChatSdk
//
//  Created by Rasika on 06/03/24.
//

import SwiftUI
import Foundation
import UIKit
import YPImagePicker
import IsometrikChat

/// A SwiftUI view that provides media picking functionality using YPImagePicker
/// This view can be used for both profile picture selection and general media selection
public struct ISMMediaPickerView: View {
    
    //MARK:  - PROPERTIES
    /// Array of selected media URLs (for videos)
    @Binding public var selectedMedia: [URL]
    /// Array of selected profile pictures (for images)
    @Binding public var selectedProfilePicture: [UIImage]
    /// Flag to handle cancellation
    @State public var cancel: Bool = false
    /// Environment variable to handle view dismissal
    @Environment(\.dismiss) public var dismiss
    @Environment(\.presentationMode) public var presentationMode
    /// Flag to determine if picker is being used for profile picture selection
    public var isProfile: Bool = false
    /// UI appearance configuration
    public let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    //MARK:  - LIFECYCLE
    public var body: some View {
        ZStack{
            VStack{
                YPImagePickerWrapper(selectedProfile: $selectedProfilePicture, selectedVideos: $selectedMedia, isProfile: isProfile) {
                    dismiss()
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("")
                            .font(appearance.fonts.navigationBarTitle)
                            .foregroundColor(appearance.colorPalette.navigationBarTitle)
                    }
                }
            }
        }
    }
}

/// UIViewControllerRepresentable wrapper for YPImagePicker to use in SwiftUI
struct YPImagePickerWrapper: UIViewControllerRepresentable {
    /// Selected profile pictures binding
    @Binding var selectedProfile: [UIImage]
    /// Selected video URLs binding
    @Binding var selectedVideos: [URL]
    /// Flag for profile picture mode
    var isProfile: Bool = false
    /// Closure to handle picker dismissal
    var dismissalHandler: () -> Void
    
    /// Coordinator class to handle YPImagePicker delegate methods
    class Coordinator: NSObject, UINavigationControllerDelegate {
        var parent: YPImagePickerWrapper
        
        init(parent: YPImagePickerWrapper) {
            self.parent = parent
        }
        
        /// Handles the completion of media selection
        func imagePicker(_ picker: YPImagePicker, didFinishWith items: [YPMediaItem]) {
            // Clear existing selections
            parent.selectedVideos.removeAll()
            parent.selectedProfile.removeAll()
            
            // Process selected items
            for item in items {
                switch item {
                case .photo(let photo):
                    print(photo.image)
                case .video(let video):
                    parent.selectedVideos.append(video.url)
                }
            }
            parent.dismissalHandler()
        }
        
        /// Handles picker cancellation
        func imagePickerDidCancel(_ picker: YPImagePicker) {
            parent.dismissalHandler()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        // Configure YPImagePicker based on use case
        var config = YPImagePickerConfiguration()
        
        // Special configuration for profile picture selection
        if isProfile {
            config.screens = [.library]
            config.library.maxNumberOfItems = 1
            config.showsCrop = .circle
            config.library.mediaType = YPlibraryMediaType.photo
            config.shouldSaveNewPicturesToAlbum = false
        }
        
        // Initialize and configure the picker
        let picker = YPImagePicker(configuration: config)
        picker.modalPresentationStyle = .fullScreen
        
        // Handle selection completion
        picker.didFinishPicking { items, cancelled in
            if cancelled {
                dismissalHandler()
                return
            }
            
            // Clear existing selections
            selectedVideos.removeAll()
            selectedProfile.removeAll()
            
            // Process selected items
            for item in items {
                switch item {
                case .photo(let photo):
                    if isProfile {
                        selectedProfile.append(photo.image)
                    }
                case .video(let video):
                    selectedVideos.append(video.url)
                }
            }
            dismissalHandler()
        }
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the view controller if needed
    }
}
