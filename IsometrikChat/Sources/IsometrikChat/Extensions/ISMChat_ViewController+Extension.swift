//
//  ViewController+Extension.swift
//  ISMChatSdk
//
//  Created by Rasika on 17/04/24.
//

import Foundation
import UIKit
import SwiftUI

struct ViewControllerHolder {
    weak var value: UIViewController?
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication.shared.windows.first?.rootViewController)
    }
}

extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }
}


extension UIViewController {
    func present<Content: View>(style: UIModalPresentationStyle = .automatic, transitionStyle: UIModalTransitionStyle = .coverVertical, @ViewBuilder builder: () -> Content) {
        // Create a hosting controller with an empty view
        let toPresent = UIHostingController(rootView: AnyView(EmptyView()))
        toPresent.modalPresentationStyle = style
        toPresent.modalTransitionStyle = transitionStyle
        toPresent.view.backgroundColor = .clear
        
        // Embed the content view in the hosting controller's view
        toPresent.rootView = AnyView(
            builder()
                .environment(\.viewController, toPresent)
        )
        
        // Present the hosting controller
        self.present(toPresent, animated: true, completion: nil)
    }
}


