//
//  DocumentPicker.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 10/03/23.
//

import Foundation
import SwiftUI
import UIKit

/// A SwiftUI wrapper for UIDocumentPickerViewController that enables document selection
/// from the device's file system.
struct DocumentPicker: UIViewControllerRepresentable {
    
    //MARK: - PROPERTIES
    /// The selected document's URL, passed as a binding to update the parent view
    @Binding var documents: URL?
    /// Controls the presentation state of the document picker
    @Binding var isShown: Bool
    
    //MARK: - CONFIGURE
    /// Creates and configures the UIDocumentPickerViewController
    /// - Parameter context: The context in which the picker is created
    /// - Returns: A configured UIDocumentPickerViewController
    func makeUIViewController(context: Context) -> some UIViewController {
        // Initialize picker with supported file types (.text, .pdf, .image)
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.text, .pdf, .image])
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

/// Coordinator class that handles the UIDocumentPickerDelegate callbacks
class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
    
    //MARK: - PROPERTIES
    /// Reference to the selected document URL
    @Binding var documents: URL?
    /// Reference to the presentation state
    @Binding var isShown: Bool
    
    /// Initializes the coordinator with necessary bindings
    /// - Parameters:
    ///   - documents: Binding to the selected document URL
    ///   - isShown: Binding to control the picker's presentation state
    init(documents: Binding<URL?>, isShown: Binding<Bool>) {
        _documents = documents
        _isShown = isShown
    }
    
    //MARK: - CONFIGURE
    /// Handles the document selection
    /// - Parameters:
    ///   - controller: The document picker controller
    ///   - urls: Array of selected document URLs
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        documents = url
        isShown = false
    }
    
    /// Handles the cancellation of document picking
    /// - Parameter controller: The document picker controller
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        isShown = false
    }
}
