//
//  ImageCachingManger.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 20/04/23.
//

import SDWebImageSwiftUI
import SwiftUI

public class ISMChatImageCahcingManger {
    
    /// Loads an image from a URL with a placeholder
    static public func networkImage(url: String, isProfileImage: Bool, size: CGSize? = nil, placeholderView: some View) -> some View {
        WebImage(url: URL(string: url))
            .resizable()
            .indicator(.activity) // Show loading spinner
            .transition(.fade) // Smooth fade-in effect
            .scaledToFill()
            .background(
                AnyView(
                    isProfileImage ? AnyView(placeholderView) :
                        AnyView(Image("loading")
                            .resizable()
                            .frame(width: 20, height: 20))
                )
            )
    }

     

    static public func viewImage(url: String) -> some View {
        WebImage(url: URL(string: url))
            .resizable()
            .indicator(.activity)
            .transition(.fade)
            .scaledToFill()
     }
 }

