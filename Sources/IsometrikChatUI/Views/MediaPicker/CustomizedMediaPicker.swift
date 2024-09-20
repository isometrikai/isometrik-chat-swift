//
//  SwiftUIView.swift
//
//
//  Created by Rasika Bharati on 20/09/24.
//

import SwiftUI
import ExyteMediaPicker

struct ISMMediaPicker: View {
    
    //MARK: - PROPERTIES
    @Binding var isPresented: Bool
    @State var medias: [Media] = []
    @Binding var sendMedias : [ISMMediaUpload]
    @State private var mediaPickerMode = MediaPickerMode.photos
    @State private var currentFullscreenMedia: Media?
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    let maxCount: Int = 5
    @State var navigateToEditor : Bool = false
    let opponenetName : String
    @Binding var mediaCaption : String
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
                ISMImageAndViderEditor(media: $medias, sendToUser: opponenetName, caption: $mediaCaption) {
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
    func appendMediaToSendMedias(completion: @escaping () -> Void) async {
        for media in medias {
            if let url = await media.getURL() {
                let isVideo = media.type == .video
                let caption = self.mediaCaption
                self.mediaCaption = ""

                let mediaUpload = ISMMediaUpload(url: url, caption: caption, isVideo: isVideo)
                sendMedias.append(mediaUpload)
            }
        }
        // Call completion once the loop is done
        completion()
    }
    //MARK: - CONFIGURATION
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
    
    var footerView: some View {
        Button {
            navigateToEditor = true
//            isPresented = false
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

extension View {
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
