//
//  ImageCachingManger.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 20/04/23.
//

import SwiftUI
import Kingfisher
import Alamofire

public class ISMChatImageCahcingManger{

    static public func networkImage(url: String, isProfileImage: Bool, size: CGSize? = nil,placeholderView : some View) -> KFImage {
        return KFImage(URL(string: url))
            .placeholder {
                placeholderView
            }
            .onFailure { error in
                // Show the placeholder when loading fails
                if isProfileImage {
                    placeholderView
                } else {
                    Image("loading")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
            .resizable()
    }
    
    
    
    static public func viewImage(url: String)-> KFImage{
        return KFImage(URL(string: url)).placeholder {
            ProgressView()
        }.resizable()
    }
}
