//
//  SwiftUIView.swift
//  
//
//  Created by Rasika Bharati on 08/10/24.
//

import SwiftUI
import ExyteMediaPicker

struct ISMGroupImagePicker: View {
    @Binding var isPresented: Bool
    @Binding var images : [URL] 
    @State var medias: [Media] = []
    @State private var mediaPickerMode = MediaPickerMode.photos
//    @State private var currentFullscreenMedia: Media?
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    let maxCount: Int = 1
    
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
//            .currentFullscreenMedia($currentFullscreenMedia)
            .mediaSelectionStyle(.checkmark)
            .mediaSelectionLimit(maxCount)
//            .showLiveCameraCell()
            .mediaSelectionType(.photo)
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
        }
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
            
            
        }
        .padding()
    }
    
    var footerView: some View {
        Button {
            images.removeAll()
            Task {
                await getData {
                    DispatchQueue.main.async{
                        isPresented = false
                    }
                }
            }
        } label: {
            HStack(spacing: 5) {
                Text("Done")
                    .font(appearance.fonts.navigationBarTitle)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
        }
        .greenButtonStyle(mediaCount: medias.count)
        .padding(.horizontal,25)
        .disabled(medias.count == 0 ? true : false)
    }
    
    func getData(completion: @escaping () -> Void) async {
        if let url = await medias.first?.getURL() {
            images.append(url)
        }
    }
}
