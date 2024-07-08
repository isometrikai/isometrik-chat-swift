//
//  Double+Extension.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 09/03/23.
//

import Foundation

extension Double{
    func datetotime() -> String{
        let unixTimeStamp: Double = self / 1000.0
        let exactDate = NSDate.init(timeIntervalSince1970: unixTimeStamp)
        let dateFormatt = DateFormatter()
        dateFormatt.locale = .current
        dateFormatt.dateFormat = "h:mm a"
        return dateFormatt.string(from: exactDate as Date)
    }
}
extension Int{
    func datetotime() -> String{
        let unixTimeStamp: Int = self / 1000
        let exactDate = NSDate.init(timeIntervalSince1970: Double(unixTimeStamp))
        let dateFormatt = DateFormatter()
//        dateFormatt.locale = .init(identifier: "en_US_POSIX")
        dateFormatt.dateFormat = "MMM d, h:mm a"
        return dateFormatt.string(from: exactDate as Date)
    }
}
extension Double {
    func millisecondsToTime() -> String {
        let totalSeconds = self / 1000
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        let seconds = (Int(totalSeconds) % 3600) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
