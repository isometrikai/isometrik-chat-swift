//
//  UIView+Extension.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 28/04/23.
//

import Foundation
import SwiftUI

extension View {
    
//    func navigationBarBackButtonTitleHidden() -> some View {
//        self.modifier(NavigationBarBackButtonTitleHiddenModifier())
//    }
}

//struct NavigationBarBackButtonTitleHiddenModifier: ViewModifier {
//    
//    @Environment(\.dismiss) var dismiss
//    
//    @ViewBuilder @MainActor func body(content: Content) -> some View {
//        content
//            .navigationBarBackButtonHidden(true)
//            .navigationBarItems(
//                leading: Button(action: { dismiss() }) {
//                    Image(systemName: "chevron.left")
//                        .foregroundColor(.blue)
//                    .imageScale(.large) })
//            .contentShape(Rectangle()) // Start of the gesture to dismiss the navigation
//            .gesture(
//                DragGesture(coordinateSpace: .local)
//                    .onEnded { value in
//                        if value.translation.width > .zero
//                            && value.translation.height > -30
//                            && value.translation.height < 30 {
//                            dismiss()
//                        }
//                    }
//            )
//    }
//}
