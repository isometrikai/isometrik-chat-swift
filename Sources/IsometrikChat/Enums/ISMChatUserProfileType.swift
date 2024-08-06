//
//  File.swift
//  
//
//  Created by Rasika Bharati on 06/08/24.
//

import Foundation

public enum ISMChatUserProfileType : CaseIterable{
    case NormalUser
    case Influencer
    case Bussiness
    
    public var value : String{
        switch self {
        case .NormalUser:
            return "NormalUser"
        case .Influencer:
            return "Influencer"
        case .Bussiness:
            return "Bussiness"
        }
    }
}


public enum ISMChatStatus : CaseIterable{
    case Accept
    case Reject
    
    public var value : String{
        switch self {
        case .Accept:
            return "Accept"
        case .Reject:
            return "Reject"
        }
    }
}
