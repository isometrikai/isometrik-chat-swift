//
//  ISMImageCropper.swift
//  ISMChatSdk
//
//  Created by Rasika on 08/04/24.
//

import SwiftUI
import Mantis

struct ISMImageCropper : UIViewControllerRepresentable{
    typealias Coordinator = ImageEditorCoordinator
    @Binding var imageUrl : URL
    @Binding var isShowing : Bool
    
    func makeCoordinator() -> ImageEditorCoordinator {
        return ImageEditorCoordinator(imageUrl: $imageUrl, isShowing: $isShowing)
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    func makeUIViewController(context: UIViewControllerRepresentableContext<ISMImageCropper>) -> Mantis.CropViewController {
        let editor = Mantis.cropViewController(image: UIImage(contentsOfFile: imageUrl.path) ?? UIImage())
        editor.delegate = context.coordinator
        return editor
    }
}

class ImageEditorCoordinator : NSObject, CropViewControllerDelegate{
    func cropViewControllerDidFailToCrop(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        isShowing = false
    }
    
    func cropViewControllerDidBeginResize(_ cropViewController: Mantis.CropViewController) {
        
    }
    
    func cropViewControllerDidEndResize(_ cropViewController: Mantis.CropViewController, original: UIImage, cropInfo: Mantis.CropInfo) {
        
    }
    
    @Binding var imageUrl : URL
    @Binding var isShowing : Bool
    init(imageUrl: Binding<URL>, isShowing: Binding<Bool>) {
        _imageUrl = imageUrl
        _isShowing = isShowing
    }
    func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
        let croppedImageURL = ISMChat_Helper.createImageURL()
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
    
    func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        isShowing = false
    }
}
