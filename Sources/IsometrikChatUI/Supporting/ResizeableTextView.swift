//
//  ResizeableTextView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 03/03/23.
//

import Foundation
import SwiftUI

/// A SwiftUI wrapper for UITextView that provides resizable text input with placeholder support
/// and mention user functionality
struct ResizeableTextView: UIViewRepresentable {

    // MARK: - PROPERTIES
    /// The text content of the text view
    @Binding var text: String
    /// Dynamic height of the text view that adjusts with content
    @Binding var height: CGFloat
    /// Indicates if user has started typing
    @Binding var typingStarted: Bool
    /// Placeholder text shown when text view is empty
    var placeholderText: String
    /// Controls visibility of mention user list
    @Binding var showMentionList: Bool
    /// Number of filtered users available for mention
    var filteredMentionUserCount: Int
    /// Currently selected mention user
    @Binding var mentionUser: String?
    /// Color for placeholder text
    let placeholderColor: Color
    /// Color for active text
    let textViewColor: UIColor

    // MARK: - CONFIGURE
    /// Creates and configures the initial UITextView
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.textContainerInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        textView.isScrollEnabled = true
        textView.text = placeholderText
        textView.textColor = UIColor(placeholderColor)
        textView.backgroundColor = .clear
        textView.font = UIFont.regular(size: 16)
        textView.autocorrectionType = .no
        textView.keyboardType = .default
        return textView
    }

    /// Updates the UITextView when SwiftUI state changes
    func updateUIView(_ textView: UITextView, context: Context) {
        if text.isEmpty && !textView.isFirstResponder {
            textView.text = placeholderText
            textView.textColor = UIColor(placeholderColor)
        } else {
            textView.text = text
            textView.textColor = textViewColor
        }

        if typingStarted {
            textView.becomeFirstResponder()
        }

        DispatchQueue.main.async {
            self.height = max(textView.contentSize.height, 32)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: ResizeableTextView

        init(_ parent: ResizeableTextView) {
            self.parent = parent
        }

        /// Handles text view editing start
        /// - Clears placeholder text and updates text color
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.placeholderText {
                textView.text = ""
                textView.textColor = parent.textViewColor
            }
            DispatchQueue.main.async {
                self.parent.typingStarted = true
            }
        }

        /// Handles text view editing end
        /// - Restores placeholder if text is empty
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholderText
                textView.textColor = UIColor(parent.placeholderColor)
            }
            DispatchQueue.main.async {
                self.parent.typingStarted = false
            }
        }

        /// Handles text changes in real-time
        /// - Updates parent text and height
        /// - Manages mention list visibility based on @ symbol
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.text = textView.text
                self.parent.height = max(textView.contentSize.height, 32)

                // Mention User Flow
                if textView.text.last == "@" {
                    self.parent.showMentionList = true
                } else if !textView.text.contains("@") {
                    self.parent.showMentionList = false
                } else if textView.text.isEmpty {
                    self.parent.showMentionList = false
                }
            }
        }
    }
}

/// A SwiftUI wrapper for UITextView specifically designed for caption input
/// with custom styling and border
struct CaptionTextView: UIViewRepresentable {
    
    // MARK: - PROPERTIES
    /// The text content of the caption
    @Binding var text: String
    /// Dynamic height of the text view
    @Binding var height: CGFloat
    /// Placeholder text shown when caption is empty
    var placeholderText: String
    
    // MARK: - CONFIGURE
    /// Creates and configures the initial UITextView with custom styling
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.textContainerInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        textView.isScrollEnabled = true
        textView.text = placeholderText
        textView.textColor = UIColor.white
        textView.backgroundColor = UIColor.black
        textView.font = UIFont.regular(size: 16)
        textView.autocorrectionType = .no
        textView.keyboardType = .default
        
        // Set up rounded rectangle border
        textView.layer.cornerRadius = max(textView.contentSize.height, 32)/2
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(named: "#272727")?.cgColor
        
        return textView
    }
    
    /// Updates the UITextView when SwiftUI state changes
    func updateUIView(_ textView: UITextView, context: Context) {
        textView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        CaptionTextView.Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CaptionTextView
        
        init(_ params: CaptionTextView) {
            self.parent = params
        }
        
        /// Updates parent text and height when content changes
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.height = textView.contentSize.height
                self.parent.text = textView.text
            }
        }
    }
}
