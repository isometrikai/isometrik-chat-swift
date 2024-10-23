//
//  File.swift
//  
//
//  Created by Rasika Bharati on 30/09/24.
//

import Foundation
import SwiftUI
import GiphyUISDK
import WebKit
import IsometrikChat

struct ISMGiphyPicker: UIViewControllerRepresentable {
    let didSelectMedia: (GPHMedia?) -> Void
    let giphyApiKey = ISMChatSdk.getInstance().getGiphyApiKey()
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ISMGiphyPicker>) -> GiphyViewController {
         
        Giphy.configure(apiKey:giphyApiKey)
        let giphy = GiphyViewController()
        giphy.delegate = context.coordinator
        giphy.mediaTypeConfig = [.stickers,.emoji,.gifs]
        GiphyViewController.trayHeightMultiplier = 1.0
        giphy.swiftUIEnabled = true
        giphy.shouldLocalizeSearch = true
        giphy.dimBackground = true
        giphy.modalPresentationStyle = .currentContext
        giphy.theme = GPHTheme(type: .light)
        return giphy
    }
    
    func updateUIViewController(_ uiViewController: GiphyViewController, context: Context) {}

    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, GiphyDelegate {
        var parent: ISMGiphyPicker

        init(_ parent: ISMGiphyPicker) {
            self.parent = parent
        }
        func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
            print(media)
            parent.didSelectMedia(media)
        }
        func didDismiss(controller: GiphyUISDK.GiphyViewController?) {
            parent.didSelectMedia(nil)
        }
    }
}

