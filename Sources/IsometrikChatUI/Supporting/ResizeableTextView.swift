//
//  ResizeableTextView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 03/03/23.
//

import Foundation
import SwiftUI

struct ResizeableTextView: UIViewRepresentable{
    
    //MARK:  - PROPERTIES
    @Binding var text:String
    @Binding var height:CGFloat
    @Binding var typingStarted : Bool
    var placeholderText: String
    @State var editing:Bool = false
    @Binding var showMentionList : Bool
    var filteredMentionUserCount : Int
    @Binding var mentionUser : String?
    let placeholderColor : Color
    let textViewColor : UIColor
    
    //MARK: - CONFIGURE
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
        textView.text = text
        if typingStarted { // If typingStarted is true, set the text view as the first responder
            textView.becomeFirstResponder()
        }
        if self.text.isEmpty == true{
            textView.text = self.editing ? "" : self.placeholderText
            textView.textColor = textView.text == self.placeholderText ? UIColor(placeholderColor) : textViewColor
        }
        
        DispatchQueue.main.async {
            self.height = max(textView.contentSize.height, 32)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        ResizeableTextView.Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate{
        var parent: ResizeableTextView
        
        init(_ params: ResizeableTextView) {
            self.parent = params
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.typingStarted = true
            DispatchQueue.main.async {
                self.parent.editing = true
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.typingStarted = false
            DispatchQueue.main.async {
                self.parent.editing = false
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.height = textView.contentSize.height
                self.parent.text = textView.text
                
                //Mention User Flow
                if textView.text.last == "@" {
                    self.parent.showMentionList = true
                }else if !textView.text.contains("@"){
                    self.parent.showMentionList = false
                }else if textView.text.isEmpty{
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
