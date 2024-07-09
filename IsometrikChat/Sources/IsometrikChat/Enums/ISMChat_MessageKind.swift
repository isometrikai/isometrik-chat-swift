//
//  ISMMessageKind.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 03/04/23.
//

import Foundation

public enum ISMChat_MessageKind {
    case normal // 0
    case forward //1
    case reply //2
    
    public var value : Int{
        switch self {
        case .normal:
            return 0
        case .forward:
            return 1
        case .reply:
            return 2
        }
    }
}
