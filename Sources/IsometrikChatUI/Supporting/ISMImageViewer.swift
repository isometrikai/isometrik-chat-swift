//
//  ISMImageViewer.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 24/04/23.
//

import SwiftUI
import IsometrikChat

struct ISMImageViewer: View {
    //MARK:  - PROPERTIES
    var url : String
    var size : CGSize
    var cornerRadius : CGFloat?
    
    public init(url: String,size : CGSize,cornerRadius : CGFloat? = nil) {
        self.url = url
        self.size = size
        self.cornerRadius = cornerRadius
    }
    //MARK:  - LIFECYCLE
    var body: some View {
        ISMChatImageCahcingManger.viewImage(url: url ?? "")
            .scaledToFill()
            .frame(width: size.width,height: size.height)
            .cornerRadius(cornerRadius ?? 0)
    }
}
