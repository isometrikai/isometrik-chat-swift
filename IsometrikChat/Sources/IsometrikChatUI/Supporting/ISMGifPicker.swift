//
//  ISMGifPicker.swift
//  ISMChatSdk
//
//  Created by Rasika on 10/04/24.
//

//import Foundation
//import SwiftUI
//import GiphyUISDK
//import WebKit

//struct GiphyPicker: UIViewControllerRepresentable {
//    let didSelectMedia: (GPHMedia?) -> Void
//
//    
//    func makeUIViewController(context: UIViewControllerRepresentableContext<GiphyPicker>) -> GiphyViewController {
//         
//        Giphy.configure(apiKey:"cDCLXNXoBVvNOVMHKEVcMSoz0xq7YUV0")
//        let giphy = GiphyViewController()
//        giphy.delegate = context.coordinator
//        giphy.mediaTypeConfig = [.stickers,.emoji,.gifs]
//        GiphyViewController.trayHeightMultiplier = 1.0
//        giphy.swiftUIEnabled = true
//        giphy.shouldLocalizeSearch = true
//        giphy.dimBackground = true
//        giphy.modalPresentationStyle = .currentContext
//        giphy.theme = GPHTheme(type: .light)
//        return giphy
//    }
//    
//    func updateUIViewController(_ uiViewController: GiphyViewController, context: Context) {}
//
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    final class Coordinator: NSObject, GiphyDelegate {
//        var parent: GiphyPicker
//
//        init(_ parent: GiphyPicker) {
//            self.parent = parent
//        }
//        func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
//            print(media)
//            parent.didSelectMedia(media)
//        }
//        func didDismiss(controller: GiphyUISDK.GiphyViewController?) {
//            parent.didSelectMedia(nil)
//        }
//    }
//}
