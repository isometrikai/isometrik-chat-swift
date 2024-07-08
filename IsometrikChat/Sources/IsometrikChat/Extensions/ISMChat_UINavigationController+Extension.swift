//
//  UINavigationController+Extension.swift
//  ISMChatSdk
//
//  Created by Rahul Iphone123 on 27/06/23.
//

import Foundation
import UIKit

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }

    // To make it works also with ScrollView
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
extension NSNotification {
    static let refreshConvList = Notification.Name.init("refreshConvList")
    static let localNotification = Notification.Name.init("localNotification")
    static let memberAddAndRemove = Notification.Name.init("memberAddAndRemove")
    static let refrestConversationListLocally = Notification.Name.init("refrestConversationListLocally")
    static let refreshBroadCastListNotification = Notification.Name.init("refreshBroadCastList")
}
