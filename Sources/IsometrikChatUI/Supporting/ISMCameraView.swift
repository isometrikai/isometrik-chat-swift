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

struct CameraCaptureView: View {
    @State private var isRecording = false
    @State private var zoomLevel: CGFloat = 1.0
    @State private var selectedFilter: String = "None"
    @State private var showGallery = false
    @Binding var isShown : Bool
    @State private var capturedImage: UIImage? = nil
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance

    var body: some View {
        ZStack {
            if let capturedImage = capturedImage{
                Image(uiImage: capturedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.8))
                    .transition(.opacity)
            }else{
                CameraPreview(zoomLevel: $zoomLevel, isRecording: $isRecording, capturedImage: $capturedImage)
                    .edgesIgnoringSafeArea(.all)
            }

            VStack {
                // Top bar with options
                HStack {
                    Button(action: {
                        isShown = false
                    }) {
                        appearance.images.whiteCross
                            .resizable()
                            .frame(width: 40, height: 40, alignment: .center)
                    }

                    Spacer()

                    if let capturedImage = capturedImage{
                        
                    }else{
                        Button(action: {
                            // Filter action
                        }) {
                            appearance.images.flash
                                .resizable()
                                .frame(width: 24, height: 24, alignment: .center)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Filter action
                        }) {
                            Image(systemName: "")
                                .foregroundColor(.white)
                                .font(.title)
                                .padding()
                        }
                    }
                    
                }

                Spacer()

                // Bottom controls
                VStack(alignment: .center) {
                    // Zoom slider
                    HStack(spacing: 24){
                        Button(action: {
                            // Filter action
                        }) {
                            appearance.images.filter
                                .resizable()
                                .frame(width: 30, height: 30, alignment: .center)
                        }
                        
                        Button(action: {
                            // Filter action
                        }) {
                            Text("1x")
                                .font(appearance.fonts.contactDetailsTitle)
                                .foregroundColor(.white)
                        }
                    }.padding(.bottom,30)
                    
                    CaptureButton(isRecording: $isRecording) {
                                            NotificationCenter.default.post(name: NSNotification.Name("CapturePhoto"), object: nil)
                                        }

                    HStack {
                        // Gallery button
                        Button(action: {
                            showGallery = true
                        }) {
                            appearance.images.gallery
                                .resizable()
                                .frame(width: 40, height: 40, alignment: .center)
                        }

                        Spacer()

                        // Capture button
                        

                        Spacer()

                        // Flip camera button
                        Button(action: {
                            NotificationCenter.default.post(name: NSNotification.Name("FlipCamera"), object: nil)
                        }) {
                            appearance.images.flipCamera
                                .resizable()
                                .frame(width: 40, height: 40, alignment: .center)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showGallery) {
            // Gallery picker view
            PhotoPicker()
        }
    }
}

// Camera Preview using UIViewControllerRepresentable
struct CameraPreview: UIViewControllerRepresentable {
    @Binding var zoomLevel: CGFloat
    @Binding var isRecording: Bool
    @Binding var capturedImage: UIImage?

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.zoomLevel = zoomLevel
        controller.isRecording = isRecording

        NotificationCenter.default.addObserver(forName: NSNotification.Name("FlipCamera"), object: nil, queue: .main) { _ in
            controller.flipCamera()
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name("CapturePhoto"), object: nil, queue: .main) { _ in
            controller.capturePhoto()
        }

        controller.onCapture = { image in
            self.capturedImage = image
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        uiViewController.zoomLevel = zoomLevel
        uiViewController.isRecording = isRecording
    }
}



// UIKit Camera Controller
import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    var zoomLevel: CGFloat = 1.0
    var isRecording: Bool = false
    private var captureSession: AVCaptureSession!
    private var videoOutput: AVCaptureMovieFileOutput!
    private var photoOutput: AVCapturePhotoOutput! // Add photo output
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    var onCapture: ((UIImage) -> Void)? // Callback for captured image

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    /// Sets up the camera with the current position.
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        configureCamera(for: currentCameraPosition)
    }

    /// Configures the camera for a given position (front/back).
    private func configureCamera(for position: AVCaptureDevice.Position) {
        captureSession.beginConfiguration()

        // Remove existing inputs
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }

        // Get the desired camera
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            print("Failed to get camera at position: \(position)")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Error setting up camera input: \(error)")
        }

        // Configure video output (for recording)
        if videoOutput == nil {
            videoOutput = AVCaptureMovieFileOutput()
        }
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        // Configure photo output (for capturing images)
        if photoOutput == nil {
            photoOutput = AVCapturePhotoOutput()
        }
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        // Configure preview layer
        if previewLayer == nil {
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }

        captureSession.commitConfiguration()
        captureSession.startRunning()
    }

    /// Captures a photo
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    /// Toggles between front and back cameras.
    func flipCamera() {
        // Switch the camera position
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back

        // Reconfigure the camera for the new position
        configureCamera(for: currentCameraPosition)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        onCapture?(image) // Pass the captured image to the callback
    }
}



// Custom Capture Button
struct CaptureButton: View {
    @Binding var isRecording: Bool
    var onCapture: () -> Void

    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(lineWidth: 4)
                .foregroundColor(.white)
                .frame(width: 80, height: 80)
            
            // Middle ring
            Circle()
                .stroke(lineWidth: 4)
                .foregroundColor(.orange)
                .frame(width: 70, height: 70)
            
            // Inner circle
            Circle()
                .fill(isRecording ? Color.red.opacity(0.7) : Color.white)
                .frame(width: 60, height: 60)
        }
        .onTapGesture {
            onCapture()
        }
        .onLongPressGesture {
            // Start recording video action
            isRecording = true
        } onPressingChanged: { isPressing in
            if !isPressing {
                // Stop recording video action
                isRecording = false
            }
        }
    }
}

// Photo Picker for Gallery Access
struct PhotoPicker: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}



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
