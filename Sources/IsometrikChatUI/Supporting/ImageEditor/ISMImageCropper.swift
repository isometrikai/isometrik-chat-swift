//
//  ISMImageCropper.swift
//  ISMChatSdk
//
//  Created by Rasika on 08/04/24.
//

import SwiftUI
import Mantis
import IsometrikChat

public struct ISMImageCropper : UIViewControllerRepresentable{
    public typealias Coordinator = ImageEditorCoordinator
    @Binding var imageUrl : URL?
    @Binding var isShowing : Bool
    
    public func makeCoordinator() -> ImageEditorCoordinator {
        return ImageEditorCoordinator(imageUrl: $imageUrl, isShowing: $isShowing)
    }
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    public func makeUIViewController(context: UIViewControllerRepresentableContext<ISMImageCropper>) -> Mantis.CropViewController {
        let editor = Mantis.cropViewController(image: UIImage(contentsOfFile: imageUrl?.path ?? "") ?? UIImage())
        editor.delegate = context.coordinator
        return editor
    }
}

public class ImageEditorCoordinator : NSObject, CropViewControllerDelegate{
    public func cropViewControllerDidFailToCrop(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        isShowing = false
    }
    
    public func cropViewControllerDidBeginResize(_ cropViewController: Mantis.CropViewController) {
        
    }
    
    public func cropViewControllerDidEndResize(_ cropViewController: Mantis.CropViewController, original: UIImage, cropInfo: Mantis.CropInfo) {
        
    }
    
    @Binding var imageUrl : URL?
    @Binding var isShowing : Bool
    public init(imageUrl: Binding<URL?>, isShowing: Binding<Bool>) {
        _imageUrl = imageUrl
        _isShowing = isShowing
    }
    public func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
        let croppedImageURL = ISMChatHelper.createImageURL()
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
    
    public func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        isShowing = false
    }
}
