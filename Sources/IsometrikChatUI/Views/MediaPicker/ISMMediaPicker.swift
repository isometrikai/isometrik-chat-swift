//
//  SwiftUIView.swift
//
//
//  Created by Rasika Bharati on 20/09/24.
//

import SwiftUI
import ExyteMediaPicker

/// ISMMediaPicker is a SwiftUI view that provides media selection functionality
/// using the ExyteMediaPicker library. It allows users to select multiple photos
/// and videos with a customizable interface.
struct ISMMediaPicker: View {
    
    //MARK: - PROPERTIES
    /// Controls the presentation state of the media picker
    @Binding var isPresented: Bool
    /// Stores the currently selected media items
    @State var medias: [Media] = []
    /// Array to store processed media items ready for upload
    @Binding var sendMedias : [ISMMediaUpload]
    /// Controls the picker mode (photos/videos)
    @State private var mediaPickerMode = MediaPickerMode.photos
    /// Tracks the currently displayed full-screen media item
    @State private var currentFullscreenMedia: Media?
    /// UI appearance configuration from the SDK
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    /// Maximum number of media items that can be selected
    let maxCount: Int = 5
    /// Controls navigation to the media editor
    @State var navigateToEditor : Bool = false
    /// Name of the recipient
    let opponenetName : String
    /// Caption text for the media items
    @Binding var mediaCaption : String
    /// Trigger for sending media to message
    @Binding var sendMediaToMessage : Bool
    
    //MARK: - BODY
    var body: some View {
        NavigationStack{
            MediaPicker(
                isPresented: $isPresented,
                onChange: { medias = $0 },
                albumSelectionBuilder: { _, albumSelectionView, _ in
                    VStack {
                        headerView
                        albumSelectionView
                        Spacer()
                        footerView
                            .background(Color.white)
                    }
                    .background(Color.white)
                }
            )
            .pickerMode($mediaPickerMode)
            .currentFullscreenMedia($currentFullscreenMedia)
            .mediaSelectionStyle(.count)
            .mediaSelectionLimit(maxCount)
            .mediaPickerTheme(
                main: .init(
                    albumSelectionBackground: .white,
                    fullscreenPhotoBackground: .white
                ),
                selection: .init(
                    emptyTint: .white,
                    emptyBackground: .white.opacity(0.25),
                    selectedTint: ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette.messageListReplyToolbarRectangle,
                    fullscreenTint: .gray
                )
            )
            .background(Color.white)
            .foregroundColor(.black)
            .fullScreenCover(isPresented: $navigateToEditor, onDismiss: {navigateToEditor = false}, content: {
                ISMMediaEditor(media: $medias, sendToUser: opponenetName, caption: $mediaCaption) {
                    Task {
                        await appendMediaToSendMedias {
                            DispatchQueue.main.async{
                                self.sendMediaToMessage = true
                                isPresented = false
                            }
                        }
                    }
                }
            })
        }
    }
    /// Processes selected media items and prepares them for sending
    /// - Parameter completion: Callback executed after processing all media items
    func appendMediaToSendMedias(completion: @escaping () -> Void) async {
        for media in medias {
            if let url = await media.getURL() {
                let isVideo = media.type == .video
                let caption = self.mediaCaption
                // Reset caption after processing
                self.mediaCaption = ""
                
                // Create and append new media upload object
                let mediaUpload = ISMMediaUpload(url: url, caption: caption, isVideo: isVideo)
                sendMedias.append(mediaUpload)
            }
        }
        // Execute completion handler after processing all media
        completion()
    }
    //MARK: - CONFIGURATION
    /// Header view displaying cancel button and selection count
    var headerView: some View {
        HStack {
            HStack {
                Text("Cancel")
                    .font(appearance.fonts.navigationBarTitle)
            }
            .onTapGesture {
                withAnimation {
                    isPresented = false
                }
            }
            
            Spacer()
            
            Text("\(medias.count) out of \(maxCount) selected")
                .font(appearance.fonts.navigationBarTitle)
        }
        .padding()
    }
    
    /// Footer view with the Next button for proceeding to media editor
    var footerView: some View {
        Button {
            navigateToEditor = true
        } label: {
            HStack(spacing: 5) {
                Text("Next ( \(medias.count) )")
                    .font(appearance.fonts.navigationBarTitle)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
        }
        .greenButtonStyle(mediaCount: medias.count)
        .padding(.horizontal,25)
        .disabled(medias.count == 0 ? true : false)
    }
}

/// Custom button style extension for the media picker
extension View {
    /// Applies a green button style that changes appearance based on media selection
    /// - Parameter mediaCount: Number of selected media items
    func greenButtonStyle(mediaCount : Int) -> some View {
        self.font(.headline)
            .foregroundColor(.white)
            .padding()
            .background {
                if mediaCount == 0{
                    Color.gray.opacity(0.6)
                        .cornerRadius(16)
                }else{
                    ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette.messageListReplyToolbarRectangle
                        .cornerRadius(16)
                }
            }
    }
}
