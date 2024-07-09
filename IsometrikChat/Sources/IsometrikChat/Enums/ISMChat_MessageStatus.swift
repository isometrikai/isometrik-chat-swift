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
}

public enum ISMChat_SyncStatus : CaseIterable{
    case Local
    case Synch
    public var txt : String{
        switch self {
        case .Local:
            return "Local"
        case .Synch:
            return "Synch"
        }
    }
}
