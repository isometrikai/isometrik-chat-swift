//
//  ISMSearchTags.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 07/11/23.
//

import Foundation

enum ISMChat_SearchTags : CaseIterable{
    case ism_search_tag_text
    case ism_search_tag_photo
    case ism_search_tag_video
    case ism_search_tag_audio
    case ism_search_tag_file
    case ism_search_tag_location
    case ism_search_tag_contact
    case ism_search_tag_sticker
    case ism_search_tag_gif
    case ism_search_tag_whiteboard
    case ism_search_tag_forward
    var value : String{
        switch self {
        case .ism_search_tag_text:
            return "/@text"
        case .ism_search_tag_photo:
            return "/@photo"
        case .ism_search_tag_video:
            return "/@video"
        case .ism_search_tag_audio:
            return "/@audio"
        case .ism_search_tag_file:
            return "/@file"
        case .ism_search_tag_location:
            return "/@location"
        case .ism_search_tag_contact:
            return "/@contact"
        case .ism_search_tag_sticker:
            return "/@sticker"
        case .ism_search_tag_gif:
            return "/@gif"
        case .ism_search_tag_whiteboard:
            return "/@whiteboard"
        case .ism_search_tag_forward:
            return "/@forward"
        }
    }
}
