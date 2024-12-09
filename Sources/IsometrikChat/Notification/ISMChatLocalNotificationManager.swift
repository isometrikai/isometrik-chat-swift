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
    // A key for storing badge count in UserDefaults
    static public let badgeCountKey = "badgeCount"
    
    static public func requestPermission() -> Void {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .alert]) { granted, error in
                if granted == true && error == nil {
                    // We have permission!
                }
        }
    }
    
    static public func addNotification(title: String, body: String) -> Void {
        notifications.append(ISMChatLocalNotification(id: UUID().uuidString, title: title, body: body))
    }
    
    

    static public func scheduleNotifications(_ durationInSeconds: Int, repeats: Bool, userInfo: [AnyHashable : Any]) {
           // Reset badge count to 0
//           UNUserNotificationCenter.current().setBadgeCount(0) { error in
//               if let error = error {
//                   print("Error resetting badge count: \(error)")
//               }
//           }

           // Retrieve current badge count from UserDefaults (default is 0 if not set)
//           let currentBadgeCount = UserDefaults.standard.integer(forKey: badgeCountKey)

           for notification in notifications {
               let content = UNMutableNotificationContent()
               content.title = notification.title
               content.body = notification.body
               content.sound = UNNotificationSound.default
               
               // Increment the badge count
//               let newBadgeCount = currentBadgeCount + 1
//               UNUserNotificationCenter.current().setBadgeCount(newBadgeCount) { error in
//                   if let error = error {
//                       print("Error setting badge count: \(error)")
//                   }
//               }
//               content.badge = NSNumber(value: newBadgeCount)
               content.userInfo = userInfo

               // Save the new badge count in UserDefaults
//               UserDefaults.standard.set(newBadgeCount, forKey: badgeCountKey)
               
               let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(durationInSeconds), repeats: repeats)
               let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
               
               UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
               UNUserNotificationCenter.current().add(request) { error in
                   guard error == nil else { return }
                   print("Scheduling notification with id: \(notification.id)")
               }
           }
           
           // Clear the notifications array after scheduling
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

