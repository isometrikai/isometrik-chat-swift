//
//  ResizeableTextView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 03/03/23.
//

import Foundation
import SwiftUI

struct ResizeableTextView: UIViewRepresentable {

    // MARK: - PROPERTIES
    @Binding var text: String
    @Binding var height: CGFloat
    @Binding var typingStarted: Bool
    var placeholderText: String
    @Binding var showMentionList: Bool
    var filteredMentionUserCount: Int
    @Binding var mentionUser: String?
    let placeholderColor: Color
    let textViewColor: UIColor

    // MARK: - CONFIGURE
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

    func updateUIView(_ textView: UITextView, context: Context) {
        if !text.isEmpty || textView.isFirstResponder {
            textView.text = text
            textView.textColor = textViewColor
        } else {
            textView.text = placeholderText
            textView.textColor = UIColor(placeholderColor)
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

        func textViewDidBeginEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.typingStarted = true
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.typingStarted = false
            }
        }

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


struct CaptionTextView: UIViewRepresentable{
    
    //MARK:  - PROPERTIES
    @Binding var text:String
    @Binding var height:CGFloat
    var placeholderText: String
    
    //MARK: - CONFIGURE
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
    
    func updateUIView(_ textView: UITextView, context: Context) {
        textView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        CaptionTextView.Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate{
        var parent: CaptionTextView
        
        init(_ params: CaptionTextView) {
            self.parent = params
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
        }
        
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.height = textView.contentSize.height
                self.parent.text = textView.text

            }
        }
    }
}
