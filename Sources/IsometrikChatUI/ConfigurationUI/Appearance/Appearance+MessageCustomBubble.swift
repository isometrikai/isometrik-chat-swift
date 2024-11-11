//
//  File.swift
//  
//
//  Created by Rasika Bharati on 11/11/24.
//

import Foundation
import SwiftUI


public class ISMChatMessageCustomBubble {
    public var productLink : AnyView = AnyView(VStack{})
    public init(){}
    public init(productLink: AnyView) {
        self.productLink = productLink
    }
}
