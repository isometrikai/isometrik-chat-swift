//
//  NavigationUtil.swift
//  ISMChatSdk
//
//  Created by Rahul Iphone123 on 22/06/23.
//

import Foundation
import UIKit

/// Protocol to identify chat view controllers in the navigation stack
public protocol ChatViewIdentifiable {}

/// Utility struct for handling navigation operations
public struct NavigationUtil {
    /// Pops to the root view controller of the navigation stack
    /// This method finds the key window's root navigation controller and removes all view controllers except the root
    static public func popToRootView() {
        // Find the key window from active scene using a chain of filters and transformations:
        // 1. Get all connected scenes
        // 2. Filter for active scenes only
        // 3. Convert scenes to window scenes
        // 4. Get all windows from the scenes
        // 5. Find the key window
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        // Find navigation controller and pop to root
        findNavigationController(viewController: keyWindow?.rootViewController)?
            .popToRootViewController(animated: true)
    }
    
    /// Pops to the most recent ChatViewIdentifiable view controller in the navigation stack
    /// If no chat view controller is found, this operation will have no effect
    static public func popToChatVC() {
        // Find key window using the same approach as popToRootView
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        // Find the navigation controller
        if let navigationController = findNavigationController(viewController: keyWindow?.rootViewController) {
            // Iterate through the navigation stack to find the first view controller
            // that conforms to ChatViewIdentifiable protocol
            for viewController in navigationController.viewControllers {
                if viewController is ChatViewIdentifiable {
                    navigationController.popToViewController(viewController, animated: true)
                    return
                }
            }
        }
    }

    /// Recursively searches for a UINavigationController in the view controller hierarchy
    /// - Parameter viewController: The root view controller to start the search from
    /// - Returns: The first found UINavigationController, or nil if none is found
    static public func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }
        
        // If the current viewController is a navigation controller, return it
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
        
        // Recursively search through child view controllers
        for childViewController in viewController.children {
            if let navigationController = findNavigationController(viewController: childViewController) {
                return navigationController
            }
        }
        return nil
    }
}

