//
//  LocalNotificationManager.swift
//  ISMChatSdk
//
//  Created by Rasika Bharati on 08/09/23.
//

import Foundation
import UserNotifications
import UIKit

public struct ISMChatLocalNotification {
    public var id: String
    public var title: String
    public var body: String
}

public enum ISMChatLocalNotificationDurationType {
    case days
    case hours
    case minutes
    case seconds
}

public struct ISMChatLocalNotificationManager {
    
    static public var notifications = [ISMChatLocalNotification]()
    
    static public func requestPermission() -> Void {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .alert]) { granted, error in
                if granted == true && error == nil {
                    // We have permission!
                }
        }
    }
    
    static public func addNotification(title: String, body: String) -> Void {
        notifications.append(ISMChatLocalNotification(id: UUID().uuidString, title: title, body: body))
    }
    
    static public func scheduleNotifications(_ durationInSeconds: Int, repeats: Bool, userInfo: [AnyHashable : Any]) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.body
            content.sound = UNNotificationSound.default
            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
            content.userInfo = userInfo
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(durationInSeconds), repeats: repeats)
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().add(request) { error in
                guard error == nil else { return }
                print("Scheduling notification with id: \(notification.id)")
            }
        }
        notifications.removeAll()
    }
    
    static public func scheduleNotifications(_ duration: Int, of type: ISMChatLocalNotificationDurationType, repeats: Bool, userInfo: [AnyHashable : Any]) {
        var seconds = 0
        switch type {
        case .seconds:
            seconds = duration
        case .minutes:
            seconds = duration * 60
        case .hours:
            seconds = duration * 60 * 60
        case .days:
            seconds = duration * 60 * 60 * 24
        }
        scheduleNotifications(seconds, repeats: repeats, userInfo: userInfo)
    }
    
    static public func cancel() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    static public func setNotification(_ duration: Int, of type: ISMChatLocalNotificationDurationType, repeats: Bool, title: String, body: String, userInfo: [AnyHashable : Any]) {
        requestPermission()
        addNotification(title: title, body: body)
        scheduleNotifications(duration, of: type, repeats: repeats, userInfo: userInfo)
    }
}

