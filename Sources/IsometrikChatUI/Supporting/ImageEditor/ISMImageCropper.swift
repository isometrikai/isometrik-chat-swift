//
//  ISMImageCropper.swift
//  ISMChatSdk
//
//  Created by Rasika on 08/04/24.
//

import SwiftUI
import Mantis
import IsometrikChat

/// A SwiftUI view that wraps Mantis image cropping functionality
/// Allows users to crop and edit images within the app
public struct ISMImageCropper : UIViewControllerRepresentable{
    public typealias Coordinator = ImageEditorCoordinator
    
    /// The URL of the image being edited
    @Binding var imageUrl : URL?
    /// Controls the visibility of the image cropper
    @Binding var isShowing : Bool
    
    /// Creates and returns the coordinator that manages the image editing functionality
    public func makeCoordinator() -> ImageEditorCoordinator {
        return ImageEditorCoordinator(imageUrl: $imageUrl, isShowing: $isShowing)
    }
    
    /// Updates the view controller when SwiftUI updates
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // No update logic needed
    }
    
    /// Creates and configures the Mantis crop view controller
    public func makeUIViewController(context: UIViewControllerRepresentableContext<ISMImageCropper>) -> Mantis.CropViewController {
        // Initialize crop view controller with image from URL
        let editor = Mantis.cropViewController(image: UIImage(contentsOfFile: imageUrl?.path ?? "") ?? UIImage())
        editor.delegate = context.coordinator
        return editor
    }
}

/// Coordinator class that handles the image editing operations and delegate callbacks
public class ImageEditorCoordinator : NSObject, CropViewControllerDelegate{
    /// Binding to the image URL
    @Binding var imageUrl : URL?
    /// Binding to control cropper visibility
    @Binding var isShowing : Bool
    
    /// Initializes the coordinator with necessary bindings
    public init(imageUrl: Binding<URL?>, isShowing: Binding<Bool>) {
        _imageUrl = imageUrl
        _isShowing = isShowing
    }
    
    /// Called when image cropping fails
    public func cropViewControllerDidFailToCrop(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        isShowing = false
    }
    
    /// Called when resizing begins
    public func cropViewControllerDidBeginResize(_ cropViewController: Mantis.CropViewController) {
        // Handle resize begin if needed
    }
    
    /// Called when resizing ends
    public func cropViewControllerDidEndResize(_ cropViewController: Mantis.CropViewController, original: UIImage, cropInfo: Mantis.CropInfo) {
        // Handle resize end if needed
    }
    
    /// Called when image cropping is successful
    public func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
        // Generate a new URL for the cropped image
        let croppedImageURL = ISMChatHelper.createImageURL()
        
        // Convert cropped image to JPEG data and save to file
        if let imageData = cropped.jpegData(compressionQuality: 1.0) {
            do {
                try imageData.write(to: croppedImageURL)
                imageUrl = croppedImageURL
                isShowing = false
            } catch {
                print("Error writing cropped image: \(error)")
                isShowing = false
            }
        }
    }
    
    /// Called when user cancels the cropping operation
    public func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        isShowing = false
    }
}
