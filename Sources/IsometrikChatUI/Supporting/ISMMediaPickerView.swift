//
//  ISMMediaPickerView.swift
//  ISMChatSdk
//
//  Created by Rasika on 06/03/24.
//

import SwiftUI
import Foundation
import UIKit
import YPImagePicker
import IsometrikChat

struct ISMMediaPickerView: View {
    
    //MARK:  - PROPERTIES
    @Binding var selectedMedia: [URL]
    @Binding var selectedProfilePicture : [UIImage]
    @State var cancel : Bool = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    var isProfile : Bool = false
    @State var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    //MARK:  - LIFECYCLE
    var body: some View {
        ZStack{
            VStack{
                YPImagePickerWrapper(selectedProfile: $selectedProfilePicture, selectedVideos: $selectedMedia, isProfile: isProfile) {
                    dismiss()
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("")
                            .font(themeFonts.navigationBarTitle)
                            .foregroundColor(themeColor.navigationBarTitle)
                    }
                }
            }
        }
    }
}


struct YPImagePickerWrapper: UIViewControllerRepresentable {
    @Binding var selectedProfile : [UIImage]
    @Binding var selectedVideos: [URL]
    var isProfile : Bool = false
    var dismissalHandler: () -> Void
    
    
    class Coordinator: NSObject, UINavigationControllerDelegate {
        var parent: YPImagePickerWrapper
        
        init(parent: YPImagePickerWrapper) {
            self.parent = parent
        }
        
        func imagePicker(_ picker: YPImagePicker, didFinishWith items: [YPMediaItem]) {
            parent.selectedVideos.removeAll()
            parent.selectedProfile.removeAll()
            for item in items {
                switch item {
                case .photo(let photo):
                    //                    parent.selectedImages.append(photo.url!)
                    print(photo.image)
                case .video(let video):
                    parent.selectedVideos.append(video.url)
                }
            }
            parent.dismissalHandler()
        }
        
        func imagePickerDidCancel(_ picker: YPImagePicker) {
            parent.dismissalHandler()
        }
    }
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        var config = YPImagePickerConfiguration()
        if isProfile == true{
            config.screens = [.library]
            config.library.maxNumberOfItems = 1
            config.showsCrop = .circle
            config.library.mediaType = YPlibraryMediaType.photo
            config.shouldSaveNewPicturesToAlbum = false
        }
        
        let picker = YPImagePicker(configuration: config)
        picker.modalPresentationStyle = .fullScreen
        
        picker.didFinishPicking { items, cancelled in
            if cancelled{
                dismissalHandler()
            }
            selectedVideos.removeAll()
            selectedProfile.removeAll()
            for item in items {
                switch item {
                case .photo(let photo):
                    print(photo.image)
                    if isProfile == true{
                        selectedProfile.append(photo.image)
                    }
                case .video(let video):
                    selectedVideos.append(video.url)
                }
            }
            dismissalHandler()
        }
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the view controller if needed
    }
}
