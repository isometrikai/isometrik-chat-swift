//
//  DocumentPicker.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 10/03/23.
//

import Foundation
import SwiftUI
import UIKit


struct DocumentPicker: UIViewControllerRepresentable {
    
    //MARK:  - PROPERTIES
    @Binding var documents : URL?
    @Binding var isShown: Bool
    
    //MARK:  - CONFIGURE
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.text,.pdf,.image])
        controller.allowsMultipleSelection = false
        controller.shouldShowFileExtensions = true
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    func makeCoordinator() -> DocumentPickerCoordinator {
        DocumentPickerCoordinator(documents: $documents, isShown: $isShown)
    }
    
}
class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
    
    //MARK:  - PROPERTIES
    @Binding var documents : URL?
    @Binding var isShown: Bool
    
    init(documents: Binding<URL?>,isShown: Binding<Bool>) {
        _documents = documents
        _isShown = isShown
    }
    
    //MARK:  - CONFIGURE
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        documents = url
        isShown = false
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        isShown = false
    }
}
