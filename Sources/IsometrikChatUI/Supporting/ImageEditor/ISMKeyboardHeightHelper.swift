//
//  ISMKeyboardHeightHelper.swift
//  
//
//  Created by Rasika Bharati on 20/09/24.
//

import Foundation
import SwiftUI

/// A helper class that monitors and manages keyboard height changes in the app
/// This class provides real-time updates about the keyboard's state and dimensions
class ISMKeyboardHeightHelper: ObservableObject {
    
    /// Shared singleton instance for app-wide keyboard height monitoring
    static var shared = ISMKeyboardHeightHelper()
    
    /// Current height of the keyboard. Zero when keyboard is hidden
    @Published var keyboardHeight: CGFloat = 0
    
    /// Boolean flag indicating whether the keyboard is currently displayed
    @Published var keyboardDisplayed: Bool = false
    
    /// Initializes the keyboard helper and sets up notification observers
    init() {
        self.listenForKeyboardNotifications()
    }
    
    /// Sets up observers for keyboard show/hide notifications
    private func listenForKeyboardNotifications() {
        // Observer for keyboard will show notification
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main) { (notification) in
                guard let userInfo = notification.userInfo,
                      let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                
                DispatchQueue.main.async {
                    // Update keyboard height and display state
                    self.keyboardHeight = keyboardRect.height
                    self.keyboardDisplayed = true
                }
        }
        
        // Observer for keyboard will hide notification
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main) { (notification) in
                DispatchQueue.main.async {
                    // Reset keyboard height when hiding
                    self.keyboardHeight = 0
                }
        }
        
        // Observer for keyboard did hide notification
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardDidHideNotification,
            object: nil,
            queue: .main) { (notification) in
                DispatchQueue.main.async {
                    // Update display state after keyboard is hidden
                    self.keyboardDisplayed = false
                }
        }
    }
}
