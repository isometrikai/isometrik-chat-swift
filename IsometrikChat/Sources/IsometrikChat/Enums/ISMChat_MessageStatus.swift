//
//  ISMMessageStatus.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 03/04/23.
//

import Foundation

public enum ISMChat_MessageStatus : CaseIterable{
    case Clock
    case SingleTick
    case DoubleTick
    case BlueTick
//    var image : String{
//        switch self {
//        case .Clock:
//            return "clock"
//        case .SingleTick:
//            return "single_tick_sent"
//        case .DoubleTick:
//            return "double_tick_sent"
//        case .BlueTick:
//            return "double_tick_received"
//        }
//    }
}

public enum ISMChat_SyncStatus : CaseIterable{
    case Local
    case Synch
    var txt : String{
        switch self {
        case .Local:
            return "Local"
        case .Synch:
            return "Synch"
        }
    }
}
