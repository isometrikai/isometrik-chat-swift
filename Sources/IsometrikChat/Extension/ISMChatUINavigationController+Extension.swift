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
    public static let refreshConvList = Notification.Name.init("refreshConvList")
    public static let localNotification = Notification.Name.init("localNotification")
    public static let memberAddAndRemove = Notification.Name.init("memberAddAndRemove")
    public static let refrestConversationListLocally = Notification.Name.init("refrestConversationListLocally")
    public static let refrestMessagesListLocally = Notification.Name.init("refrestMessagesListLocally")
    public static let refreshBroadCastListNotification = Notification.Name.init("refreshBroadCastList")
    public static let refreshOtherChatCount = Notification.Name.init("refreshOtherChatCount")
    public static let updateChatCount = Notification.Name.init("updateChatCount")
    public static let updateBroadCastCount = Notification.Name.init("updateBroadCastCount")
    public static let updateGroupInfo = Notification.Name.init("updateGroupInfo")
}
