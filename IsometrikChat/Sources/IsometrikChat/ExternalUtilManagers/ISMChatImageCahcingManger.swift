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
    
    static public func networkImage(url: String,isprofileImage : Bool,size: CGSize? = nil)-> KFImage{
        return KFImage(URL(string: url)).placeholder {
            if isprofileImage == true{
                Image("placeholder_New")
                    .resizable()
                    .frame(width: size?.width,height: size?.height)
            }else{
                Image("loading")
                    .resizable()
                    .frame(width: 20,height: 20)
            }
        }.resizable()
    }
}
