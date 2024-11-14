//
//  View+Extension.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 17/03/23.
//

import Foundation
import SwiftUI

extension View {
    public func viewSize(_ size: CGFloat) -> some View {
        self.frame(width: size, height: size)
    }

    public func circleBackground(_ color: Color) -> some View {
        self.background {
            Circle().fill(color)
        }
    }
    
    public func modify<Content>(@ViewBuilder _ transform: (Self) -> Content) -> Content {
        transform(self)
    }
    
    public func endEditing(_ force: Bool) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


extension View {
    func placeholder<Content: View>(
            when shouldShow: Bool,
            alignment: Alignment = .leading,
            @ViewBuilder placeholder: () -> Content
        ) -> some View {
            ZStack(alignment: alignment) {
                if shouldShow {
                    placeholder()
                }
                self
            }
        }}
