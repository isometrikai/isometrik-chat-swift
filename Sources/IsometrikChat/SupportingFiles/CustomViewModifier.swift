//
//  CustomViewModifier.swift
//  ISMChatSdk
//
//  Created by Rahul Iphone123 on 13/07/23.
//

import Foundation
import SwiftUI

public struct ViewDidLoadModifier: ViewModifier {

    @State public var didLoad = false
    public let action: (() -> Void)?

    public init(perform action: (() -> Void)? = nil) {
        self.action = action
    }

    public func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action?()
            }
        }
    }

}

extension View {

    public func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }

}
