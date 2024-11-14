//
//  NavigationUtil.swift
//  ISMChatSdk
//
//  Created by Rahul Iphone123 on 22/06/23.
//

import Foundation
import UIKit


public protocol ChatViewIdentifiable {}

public struct NavigationUtil {
    static public func popToRootView() {
        // Access windows from the active scene
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        findNavigationController(viewController: keyWindow?.rootViewController)?
            .popToRootViewController(animated: true)
    }
    
    static public func popToChatVC() {
            // Access windows from the active scene
            let keyWindow = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }

            // Find the navigation controller
            if let navigationController = findNavigationController(viewController: keyWindow?.rootViewController) {
                // Check if ChatVC exists in the navigation stack and pop to it
                for viewController in navigationController.viewControllers {
                    if viewController is ChatViewIdentifiable {
                        navigationController.popToViewController(viewController, animated: true)
                        return
                    }
                }
            }
        }

    static public func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
        for childViewController in viewController.children {
            if let navigationController = findNavigationController(viewController: childViewController) {
                return navigationController
            }
        }
        return nil
    }
}

