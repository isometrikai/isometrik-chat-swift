//
//  ISMEmojiReaction.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 13/07/23.
//

import Foundation

public enum ISMChatEmojiReaction : CaseIterable{
    case yes
    case surprised
    case cryingWithLaughter
    case crying
    case heart
    case sarcastic
    case rock
    case facepal
    case star
    case no
    case bowing
    case party
    case highFive
    case talkingTooMuch
    case dancing
    public var info : (valueString : String, emoji : String){
        switch self {
        case .yes:
            return ("yes","👍")
        case .surprised:
            return ("surprised","😲")
        case .cryingWithLaughter:
            return ("crying_with_laughter","😂")
        case .crying:
            return ("crying","😭")
        case .heart:
            return ("heart","❤️")
        case .sarcastic:
            return ("sarcastic","😏")
        case .rock:
            return ("rock","🤟")
        case .facepal:
            return ("facepalm","🤦‍♂️")
        case .star:
            return ("star","🤩")
        case .no:
            return ("no","👎")
        case .bowing:
            return ("bowing","🙇‍♂️")
        case .party:
            return ("party","🥳")
        case .highFive:
            return ("high_five","🙏")
        case .talkingTooMuch:
            return ("talking_too_much","🤐")
        case .dancing:
            return ("dancing","🕺")
        }
    }
}
