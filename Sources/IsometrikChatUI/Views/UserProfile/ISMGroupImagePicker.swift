//
//  SwiftUIView.swift
//  
//
//  Created by Rasika Bharati on 08/10/24.
//

import SwiftUI
import ExyteMediaPicker

struct ISMGroupImagePicker: View {
    // Binding to control the presentation of the image picker
    @Binding var isPresented: Bool
    // Binding to hold the selected images' URLs
    @Binding var images: [URL] 
    // State to manage the media items selected from the picker
    @State var medias: [Media] = []
    // State to manage the media picker mode (photos or videos)
    @State private var mediaPickerMode = MediaPickerMode.photos
//    @State private var currentFullscreenMedia: Media?
    // Appearance settings for the UI
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    // Maximum number of images that can be selected
    let maxCount: Int = 1
    
    // MARK: - BODY
    var body: some View {
        NavigationStack {
            MediaPicker(
                isPresented: $isPresented,
                onChange: { medias = $0 }, // Update medias when selection changes
                albumSelectionBuilder: { _, albumSelectionView, _ in
                    VStack {
                        headerView // Custom header view
                        albumSelectionView // The album selection view provided by the picker
                        Spacer()
                        footerView // Custom footer view
                            .background(Color.white)
                    }
                    .background(Color.white) // Background color for the entire view
                }
            )
            .pickerMode($mediaPickerMode) // Set the media picker mode
            .mediaSelectionStyle(.checkmark) // Style for media selection
            .mediaSelectionLimit(maxCount) // Limit the number of selections
//            .showLiveCameraCell()
            .mediaSelectionType(.photo) // Specify that only photos can be selected
            .mediaPickerTheme(
                main: .init(
                    albumSelectionBackground: .white, // Background for album selection
                    fullscreenPhotoBackground: .white // Background for fullscreen photo view
                ),
                selection: .init(
                    emptyTint: .white, // Tint for empty selection
                    emptyBackground: .white.opacity(0.25), // Background for empty selection
                    selectedTint: ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette.messageListReplyToolbarRectangle, // Tint for selected items
                    fullscreenTint: .gray // Tint for fullscreen view
                )
            )
            .background(Color.white) // Background color for the picker
            .foregroundColor(.black) // Text color for the picker
        }
    }
    
    // MARK: - CONFIGURATION
    var headerView: some View {
        HStack {
            HStack {
                Text("Cancel") // Cancel button text
                    .font(appearance.fonts.navigationBarTitle) // Font for the button
            }
            .onTapGesture {
                withAnimation {
                    isPresented = false // Dismiss the picker with animation
                }
            }
            
            Spacer() // Spacer to push content to the edges
        }
        .padding() // Padding around the header
    }
    
    var footerView: some View {
        Button {
            images.removeAll() // Clear the selected images
            Task {
                await getData { // Fetch data asynchronously
                    DispatchQueue.main.async {
                        isPresented = false // Dismiss the picker after fetching data
                    }
                }
            }
        } label: {
            HStack(spacing: 5) {
                Text("Done") // Done button text
                    .font(appearance.fonts.navigationBarTitle) // Font for the button
                    .foregroundColor(.white) // Text color for the button
            }
            .frame(maxWidth: .infinity) // Make the button take full width
        }
        .greenButtonStyle(mediaCount: medias.count) // Custom style for the button
        .padding(.horizontal, 25) // Horizontal padding for the button
        .disabled(medias.count == 0) // Disable button if no media is selected
    }
    
    // Function to fetch the URL of the first selected media
    func getData(completion: @escaping () -> Void) async {
        if let url = await medias.first?.getURL() { // Get URL of the first media
            images.append(url) // Append the URL to the images array
        }
    }
}
