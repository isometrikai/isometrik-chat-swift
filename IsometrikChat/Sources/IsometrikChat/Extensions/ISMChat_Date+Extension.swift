//
//  Date.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 10/02/23.
//

import Foundation

extension NSDate{
    func descriptiveString(time: Double,dateStyle : DateFormatter.Style = .short) -> String{
        let unixTimeStamp: Double = time / 1000.0
        let exactDate = NSDate.init(timeIntervalSince1970: unixTimeStamp)
        let daysBetween = self.daysBetween(date: exactDate)
        
        if daysBetween == 0{
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            return "\(timeFormatter.string(from: exactDate as Date))"
        }else if daysBetween == 1 || daysBetween == -1{
            return "Yesterday"
        }
//        else if daysBetween < 5{
//            let weekIndex = Calendar.current.component(.weekday, from: self as Date) - 1
//            return dateFormatt.weekdaySymbols[weekIndex]
//        }
        else{
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "dd/MM/yyyy"
            return  timeFormatter.string(from: exactDate as Date)
        }
    }
    
    func descriptiveStringLastSeen(time: Double,dateStyle : DateFormatter.Style = .short,isSectionHeader : Bool? = false) -> String{
        let unixTimeStamp: Double = time / 1000.0
        let exactDate = NSDate.init(timeIntervalSince1970: unixTimeStamp)
        let daysBetween = self.daysBetween(date: exactDate)
        if daysBetween == 0{
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            if isSectionHeader == false{
                return "\(timeFormatter.string(from: exactDate as Date))"
            }else{
                return "Today"
            }
        }else if daysBetween == 1 || daysBetween == -1{
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            if isSectionHeader == false{
                return "Yesterday \(timeFormatter.string(from: exactDate as Date))"
            }else{
                return "Yesterday"
            }
        }else{
            let timeFormatter = DateFormatter()
            if isSectionHeader == false{
                timeFormatter.dateFormat = "MMM d, yyyy h:mm a"
            }else{
                timeFormatter.dateFormat = "d MMM yyyy"
            }
            return "\(timeFormatter.string(from: exactDate as Date))"
        }
    }
    
    func daysBetween(date : NSDate) -> Int{
        let calander = Calendar.current
        let date1 = calander.startOfDay(for: self as Date)
        let date2 = calander.startOfDay(for: date as Date)
        if let daysBetween = calander.dateComponents([.day], from: date1, to: date2).day{
            return daysBetween
        }else{
            return 0
        }
    }
    func doubletoDate(time: Double,dateStyle : DateFormatter.Style = .short) -> String{
        let unixTimeStamp: Double = time / 1000.0
        let exactDate = NSDate.init(timeIntervalSince1970: unixTimeStamp)
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "dd/MM/yyyy"
        return  timeFormatter.string(from: exactDate as Date)
        
    }
    
    func doubletoTime(time: Double,dateStyle : DateFormatter.Style = .short) -> String{
        let unixTimeStamp: Double = time / 1000.0
        let exactDate = NSDate.init(timeIntervalSince1970: unixTimeStamp)
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        return  timeFormatter.string(from: exactDate as Date)
        
    }
}


extension Date{
    func toString( dateFormat format  : String ) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
