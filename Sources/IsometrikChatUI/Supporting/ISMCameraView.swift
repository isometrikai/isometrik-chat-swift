//
//  ISMCameraView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 05/07/23.
//
import Foundation
import UIKit
import SwiftUI
import AVFoundation
import IsometrikChat

public struct ISMCameraView: UIViewControllerRepresentable {
    
    public enum ISMCameraMediaType {
        case image
        case video
        case both
    }
    
    public typealias UIViewControllerType = UIImagePickerController
    @Binding public var media: URL?
    @Binding public var isShown: Bool
    @Binding public var uploadMedia: Bool
    public var mediaType: ISMCameraMediaType  // New property for media type
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        let viewController = UIImagePickerController()
        viewController.delegate = context.coordinator
        
        // Check if the camera is available and supports the desired mode
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            viewController.sourceType = .camera
            
            // Setup media types and capture mode based on the selected media type
            switch mediaType {
            case .image:
                viewController.mediaTypes = ["public.image"]
                viewController.cameraCaptureMode = .photo
            case .video:
                viewController.mediaTypes = ["public.movie"]
                viewController.cameraCaptureMode = .video
            case .both:
                viewController.mediaTypes = ["public.image", "public.movie"]
                viewController.cameraCaptureMode = .photo  // Set default as photo
            }
            
            // Check if the device supports specific camera devices
            if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                viewController.cameraDevice = .rear
            } else {
                print("Rear camera not available, falling back to front camera")
                viewController.cameraDevice = .front
            }
        } else {
            print("Camera not available, falling back to photo library")
            viewController.sourceType = .photoLibrary
        }
        
        // Manage AVAudioSession
        AudioSessionManager.shared.activateSession()
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Update the view controller if needed
    }
    
    public func makeCoordinator() -> ISMCameraView.Coordinator {
        return Coordinator(self, media: $media, isShown: $isShown, uploadMedia: $uploadMedia)
    }
}

extension ISMCameraView {
    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ISMCameraView
        @Binding var media: URL?
        @Binding var isShown: Bool
        @Binding var uploadMedia: Bool
        
        public init(_ parent: ISMCameraView, media: Binding<URL?>, isShown: Binding<Bool>, uploadMedia: Binding<Bool>) {
            self.parent = parent
            _media = media
            _isShown = isShown
            _uploadMedia = uploadMedia
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            AudioSessionManager.shared.deactivateSession()
            isShown = false
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            let imagePath = documentsPath?.appendingPathComponent("\(UUID().uuidString).jpg")
            
            if let pickedImage = info[.originalImage] as? UIImage {
                if let fixedImage = pickedImage.fixOrientation() {
                    if let imageData = fixedImage.pngData() {
                        try? imageData.write(to: imagePath!)
                        self.media = imagePath
                        self.uploadMedia = true
                    }
                }
            } else if let pickedVideo = info[.mediaURL] as? URL {
                self.media = pickedVideo
                self.uploadMedia = true
            }
            AudioSessionManager.shared.deactivateSession()
            self.isShown = false
        }
    }
}



public class AudioSessionManager {
    static let shared = AudioSessionManager()
    
    public func activateSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .videoRecording, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to activate audio session: \(error)")
        }
    }
    
    public func deactivateSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    public func setupInterruptionHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc public func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        if type == .began {
            // Interruption began, take appropriate actions
        } else if type == .ended {
            // Interruption ended, reactivate session if needed
            try? AVAudioSession.sharedInstance().setActive(true)
        }
    }
}
