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
import PencilKit
import AVKit

/// A SwiftUI view that provides camera capture functionality with photo and video capabilities
struct CameraCaptureView: View {
    // State variables for camera control
    @State private var isRecording = false
    @State private var isVideo = false
    @State private var zoomLevel: CGFloat = 1.0
    @State private var selectedFilter: String = "None"
    @State private var showGallery = false
    @State private var isFlashOn: Bool = false
    @State private var isPlaying = true
    
    // Media handling state
    @Binding var isShown: Bool
    @State private var capturedURL: URL? = nil
    @Binding var textFieldtxt: String
    @State private var player: AVPlayer?
    @Binding var sendUrl: URL?
    
    // Drawing and editing state
    @State var showCropper: Bool = false
    @State var navigateToDraw: Bool = false
    @State var imageData: Data = Data(count: 0)
    @State var canvas = PKCanvasView()
    @State var toolpicker = PKToolPicker()
    @State var rect: CGRect = .zero

    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance

    var body: some View {
        ZStack {
            if let capturedURL = capturedURL {
                if navigateToDraw {
                    GeometryReader { geometry in
                        CanvasView(canvas: $canvas, imageData: $imageData, toolPicker:  $toolpicker, rect: geometry.size)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .onAppear {
                                rect = CGRect(origin: .zero, size: geometry.size)
                            }
                    }
                } else {
                    if ISMChatHelper.isVideoString(media: capturedURL.absoluteString) {
                        ZStack {
                            // Video Player
                            GeometryReader { geometry in
                                if let player = player {
                                    VideoPlayer(player: player)
                                        .scaledToFill()
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                        .clipped()
                                }
                            }
                        }
                        .onAppear {
                            player = AVPlayer(url: capturedURL)
                            player?.play()
                        }
                        .onDisappear {
                            player?.pause()
                        }
                    }else{
                        GeometryReader { geometry in
                            ISMChatImageCahcingManger.viewImage(url: capturedURL.absoluteString ?? "")
                                .scaledToFit()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .ignoresSafeArea()
                                .edgesIgnoringSafeArea(.all)
                        }
                    }
                }
            }else{
                CameraPreview(zoomLevel: $zoomLevel, isRecording: $isRecording, capturedURL: $capturedURL)
                    .edgesIgnoringSafeArea(.all)
            }

            VStack {
                // Top bar with options
                HStack {
                    Button(action: {
                        if navigateToDraw == true{
                            cancelDrawImage()
                        }else{
                            if capturedURL != nil {
                                capturedURL = nil
                            } else {
                                isShown = false
                            }
                        }
                    }) {
                        appearance.images.whiteCross
                            .resizable()
                            .frame(width: 40, height: 40, alignment: .center)
                    }.padding(.leading,5)

                    Spacer()

                    if let capturedURL = capturedURL{
                        if navigateToDraw == true{
                            HStack(spacing: 22){
                                Button(action: {
                                    undoLastStroke()
                                }) {
                                    appearance.images.undoLastStroke
                                        .resizable()
                                        .frame(width: 24, height: 16, alignment: .center)
                                }
                                Button(action: {
                                    saveAfterDraw()
                                }) {
                                    Text("Done")
                                        .font(appearance.fonts.contactMessageTitle)
                                        .foregroundColor(Color(hex: "#163300"))
                                        .frame(width: 69, height: 32, alignment: .center)
                                        .background(appearance.colorPalette.chatListUnreadMessageCountBackground)
                                        .cornerRadius(16)
                                        .padding(.horizontal,0.5)
                                }
                            }.padding(.trailing,15)
                        }else{
                            HStack(spacing: 22){
                                Button(action: {
                                    showCropper = true
                                }) {
                                    appearance.images.rotateImage
                                        .resizable()
                                        .frame(width: 20, height: 20, alignment: .center)
                                }
                                Button(action: {
                                    
                                }) {
                                    appearance.images.addStickerToImage
                                        .resizable()
                                        .frame(width: 20, height: 20, alignment: .center)
                                }
                                Button(action: {
                                    
                                }) {
                                    appearance.images.addTextToImage
                                        .resizable()
                                        .frame(width: 20, height: 20, alignment: .center)
                                }
                                Button(action: {
                                    navigateToDraw = true
                                }) {
                                    appearance.images.drawToImage
                                        .resizable()
                                        .frame(width: 20, height: 20, alignment: .center)
                                }
                            }.padding(.trailing,15)
                        }
                    }else{
                        Button(action: {
                            // Filter action
                            isFlashOn.toggle()
                                NotificationCenter.default.post(name: NSNotification.Name("ToggleFlash"), object: isFlashOn)
                        }) {
//                            Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash")
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
                    
                }.background(self.capturedURL != nil ? Color.black.opacity(0.6) : Color.clear)

                Spacer()

                if let capturedURL = capturedURL{
                    HStack(spacing: 10){
                        TextField(appearance.constantStrings.messageInputTextViewPlaceholder, text: $textFieldtxt, axis: .vertical)
                            .textInputAutocapitalization(.never) // Prevents autocapitalization
                            .disableAutocorrection(true)
                            .lineLimit(5)
                            .font(appearance.fonts.messageListTextViewText ?? .body)
                            .foregroundColor(appearance.colorPalette.messageListTextViewText ?? .black)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(appearance.colorPalette.messageListTextViewBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(appearance.colorPalette.messageListTextViewBoarder, lineWidth: 1)
                            )
                        
                        Button(action: {
                            self.sendUrl = capturedURL
                            isShown = false
                        }) {
                            appearance.images.sendMessage
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        
                    }.padding(.bottom,20).padding(.horizontal,15)
                }else{
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
                        
                        CaptureButton(isRecording: $isRecording, isVideo: $isVideo) {
                            NotificationCenter.default.post(name: NSNotification.Name("CapturePhoto"), object: nil)
                        }
                        
                        HStack {
                            // Gallery button
                            Button(action: {
                                //                            showGallery = true
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
        }
        .onChange(of: capturedURL, {
            if let capturedURL = capturedURL{
                fetchData(from: capturedURL)
            }
        })
        .fullScreenCover(isPresented: $showCropper, content: {
            ISMImageCropper(imageUrl: $capturedURL, isShowing: $showCropper)
        })
        .sheet(isPresented: $showGallery) {
            // Gallery picker view
            PhotoPicker()
        }
    }
    
    /// Removes the last drawn stroke from the canvas
    private func undoLastStroke() {
        var strokes = canvas.drawing.strokes
        if !strokes.isEmpty {
            strokes.removeLast()
            canvas.drawing = PKDrawing(strokes: strokes)
        }
    }
    
    /// Cancels the drawing mode and resets the canvas
    func cancelDrawImage() {
        canvas = PKCanvasView()
        navigateToDraw = false
    }
    
    /// Saves the drawn image by converting canvas to image and storing it
    func saveAfterDraw() {
        // Create image context with current view size
        UIGraphicsBeginImageContextWithOptions(self.rect.size, false, 1)
        canvas.drawHierarchy(in: CGRect(origin: .zero, size: self.rect.size), afterScreenUpdates: true)
        let generatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = generatedImage {
            let newUrl = ISMChatHelper.createImageURL()
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                do {
                    try imageData.write(to: newUrl)
                    capturedURL = newUrl
                    navigateToDraw = false
                } catch {
                    print("Error writing cropped image: \(error)")
                    navigateToDraw = false
                }
            }
            canvas = PKCanvasView()
        }
    }
    
    func fetchData(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    self.imageData = data
                }
            }
        }.resume()
    }
    
    private func togglePlayPause() {
            if isPlaying {
                player?.pause()
            } else {
                player?.play()
            }
            isPlaying.toggle()
        }
}

/// Camera preview implementation using UIViewControllerRepresentable
struct CameraPreview: UIViewControllerRepresentable {
    @Binding var zoomLevel: CGFloat
    @Binding var isRecording: Bool
    @Binding var capturedURL: URL?
    
    /// Creates and configures the camera view controller
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.zoomLevel = zoomLevel
        controller.isRecording = isRecording
        
        // Setup notification observers for camera controls
        NotificationCenter.default.addObserver(forName: NSNotification.Name("FlipCamera"), object: nil, queue: .main) { _ in
            controller.flipCamera()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("CapturePhoto"), object: nil, queue: .main) { _ in
            controller.capturePhoto()
        }
        
        controller.onCapture = { url in
            self.capturedURL = url
        }
        
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        uiViewController.zoomLevel = zoomLevel
        uiViewController.isRecording = isRecording
    }
}


/// Main camera view controller handling camera operations
class CameraViewController: UIViewController {
    // Camera session components
    private var captureSession: AVCaptureSession!
    private var videoOutput: AVCaptureMovieFileOutput!
    private var photoOutput: AVCapturePhotoOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    
    // Callback for captured media
    var onCapture: ((URL) -> Void)?
    
    // Camera control properties
    private var isFlashOn: Bool = false
    var isRecording: Bool = false {
        didSet {
            if isRecording {
                startRecording()
            } else {
                stopRecording()
            }
        }
    }
    
    var zoomLevel: CGFloat = 1.0 {
        didSet {
            guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
            try? videoDevice.lockForConfiguration()
            videoDevice.videoZoomFactor = max(1.0, min(zoomLevel, videoDevice.activeFormat.videoMaxZoomFactor))
            videoDevice.unlockForConfiguration()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        requestCameraPermission() // Request camera permission
        setupCamera()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ToggleFlash"), object: nil, queue: .main) { [weak self] notification in
            guard let isFlashOn = notification.object as? Bool else { return }
            self?.isFlashOn = isFlashOn
            self?.toggleFlash(isOn: isFlashOn)
        }
    }
    
    private func toggleFlash(isOn: Bool) {
        guard let currentDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition),
              currentDevice.hasTorch else {
            print("Failed to access the current camera device or torch not available.")
            return
        }

        do {
            try currentDevice.lockForConfiguration()
            currentDevice.torchMode = isOn ? .on : .off
            currentDevice.unlockForConfiguration()
        } catch {
            print("Error configuring torch: \(error)")
        }
    }
    

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        configureCamera(for: .back)
    }

    private func configureCamera(for position: AVCaptureDevice.Position) {
        
            self.captureSession.beginConfiguration()

            // Remove existing inputs and outputs
            self.captureSession.inputs.forEach { self.captureSession.removeInput($0) }
            self.captureSession.outputs.forEach { self.captureSession.removeOutput($0) }

            // Add camera input
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
                  let videoInput = try? AVCaptureDeviceInput(device: camera) else {
                print("Error: Could not configure camera for position \(position)")
                self.captureSession.commitConfiguration()
                return
            }

            if self.captureSession.canAddInput(videoInput) {
                self.captureSession.addInput(videoInput)
            }

            // Add audio input
            if let audioDevice = AVCaptureDevice.default(for: .audio),
               let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
               self.captureSession.canAddInput(audioInput) {
                self.captureSession.addInput(audioInput)
            }

            // Add photo output
            self.photoOutput = AVCapturePhotoOutput()
            if self.captureSession.canAddOutput(self.photoOutput) {
                self.captureSession.addOutput(self.photoOutput)
            }

            // Add video output
            self.videoOutput = AVCaptureMovieFileOutput()
            if self.captureSession.canAddOutput(self.videoOutput) {
                self.captureSession.addOutput(self.videoOutput)
            }

            // Configure preview layer
            if self.previewLayer == nil {
                previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                previewLayer?.videoGravity = .resizeAspectFill
                if let layer = previewLayer {
                    self.view.layer.addSublayer(layer)
                }
            }

            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        
    }
    
    private func getCamera(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        return AVCaptureDevice.devices(for: .video).first(where: { $0.position == position })
    }
    
    private func startRecording() {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
        videoOutput.startRecording(to: outputURL, recordingDelegate: self)
    }

    private func stopRecording() {
        if let videoOutput = videoOutput{
            videoOutput.stopRecording()
        }
    }

    /// Captures a photo
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = isFlashOn ? .on : .off
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
        
        // Safely unwrap previewLayer or create if nil
        if previewLayer == nil {
            previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            previewLayer?.videoGravity = .resizeAspectFill
            if let layer = previewLayer {
                self.view.layer.addSublayer(layer)
                layer.frame = view.bounds
            }
        } else {
            previewLayer?.frame = view.bounds
        }
    }

    /// Requests camera permission from the user
    private func requestCameraPermission() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorizationStatus {
        case .authorized:
            // Camera access is already granted
            break
        case .notDetermined:
            // Request access
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    // Access granted
                } else {
                    // Access denied
                }
            }
        case .denied, .restricted:
            // Access denied or restricted
            break
        @unknown default:
            break
        }
    }
}


extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        
        // Save the image to a temporary directory
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            print("Image saved at: \(fileURL)")
            onCapture?(fileURL) // Pass the captured image and the file URL to the callback
        } catch {
            print("Error saving image: \(error)")
        }
    }
}


extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            print("Video saved at: \(outputFileURL)")
            onCapture?(outputFileURL)
        }
    }
}



// Custom Capture Button
struct CaptureButton: View {
    @Binding var isRecording: Bool
    @Binding var isVideo: Bool
    var onCapture: () -> Void

    var body: some View {
        Button {
            if isVideo {
                isRecording = false
                isVideo = false
            } else {
                onCapture()
            }
        } label: {
            
            ZStack {
                // Outer ring
                Circle()
                    .stroke(lineWidth: 5)
                    .foregroundColor(isRecording ? Color.red.opacity(0.7) : Color.white)
                    .frame(width: 80, height: 80)
                
                // Inner circle
                Circle()
                    .fill(isRecording ? Color.red.opacity(0.7) : Color.white)
                    .frame(width: 70, height: 70)
            }
            
        }.simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5).onEnded({ value in
                withAnimation {
                    isVideo = true
                    isRecording = true
                }
            })
        ).buttonStyle(.plain)
        
        //        ZStack {
        //            // Outer ring
        //            Circle()
        //                .stroke(lineWidth: 5)
        //                .foregroundColor(isRecording ? Color.red.opacity(0.7) : Color.white)
        //                .frame(width: 80, height: 80)
        //
        //            // Inner circle
        //            Circle()
        //                .fill(isRecording ? Color.red.opacity(0.7) : Color.white)
        //                .frame(width: 70, height: 70)
        //        }
        //        .highPriorityGesture(
        //            DragGesture(minimumDistance: 0) // Detects a press without requiring movement
        //                .onChanged { _ in
        //                    if !isRecording {
        //                        isRecording = true // Start recording on press
        //                    }
        //                }
        //                .onEnded { _ in
        //                    isRecording = false // Stop recording on release
        //                }
        //        )
        //        .simultaneousGesture(
        //            TapGesture()
        //                .onEnded {
        //                    if !isRecording {
        //                        onCapture()
        //                    }
        //                }
        //        )
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
