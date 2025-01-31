//
//  File.swift
//  IsometrikChat
//
//  Created by Rasika Bharati on 31/01/25.
//

import Foundation
import UIKit

extension UIApplication {
    
    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController? {
            if let nav = viewController as? UINavigationController {
                return topViewController(nav.visibleViewController)
            }
            if let tab = viewController as? UITabBarController {
                if let selected = tab.selectedViewController {
                    return topViewController(selected)
                }
            }
            if let presented = viewController?.presentedViewController {
                return topViewController(presented)
            }
            return viewController
        }
}
