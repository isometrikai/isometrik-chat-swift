//
//  File.swift
//  
//
//  Created by Rasika Bharati on 20/09/24.
//

import Foundation
import SwiftUI

class ISMKeyboardHeightHelper: ObservableObject {

    static var shared = ISMKeyboardHeightHelper()

    @Published var keyboardHeight: CGFloat = 0
    @Published var keyboardDisplayed: Bool = false

    init() {
        self.listenForKeyboardNotifications()
    }

    private func listenForKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
            guard let userInfo = notification.userInfo,
                  let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

            DispatchQueue.main.async {
                self.keyboardHeight = keyboardRect.height
                self.keyboardDisplayed = true
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
            DispatchQueue.main.async {
                self.keyboardHeight = 0
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: .main) { (notification) in
            DispatchQueue.main.async {
                self.keyboardDisplayed = false
            }
        }
    }
}
