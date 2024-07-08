//
//  UserAvatarView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 26/06/23.
//

import SwiftUI

struct UserAvatarView: View {
    var avatar: String
    var showOnlineIndicator: Bool
    var size: CGSize = .defaultAvatarSize
    var userName : String
    var font : Font = .regular(size: 16)
    
    public init(
        avatar: String,
        showOnlineIndicator: Bool,
        size: CGSize = .defaultAvatarSize,
        userName : String,
        font : Font = .headline
    ) {
        self.avatar = avatar
        self.showOnlineIndicator = showOnlineIndicator
        self.size = size
        self.userName = userName.components(separatedBy: " ")
            .compactMap { $0.first }
            .prefix(2)
            .map(String.init)
            .joined()
        self.font = font
    }
    
    public var body: some View {
        HStack{
            AvatarView(avatar: avatar, size: size, userName: userName,font: font)
                .overlay(
                    showOnlineIndicator ?
                    BottomRightView {
                        OnlineIndicatorView(indicatorSize: size.width * 0.3)
                    }
                        .offset(x: 3, y: -1)
                    : nil
                )
        }
        .accessibilityIdentifier("ISMProfileImageView")
    }
}

public struct AvatarView: View {
    var avatar: String
    var size: CGSize = .defaultAvatarSize
    var userName : String
    var font : Font = .headline
    
    public var body: some View {
        if avatar == "https://res.cloudinary.com/dxkoc9aao/image/upload/v1616075844/kesvhgzyiwchzge7qlsz_yfrh9x.jpg" || avatar == "" || avatar == "https://admin-media.isometrik.io/profile/def_profile.png"{
            ZStack{
                Circle()
                    .frame(width: size.width,height: size.height)
                    .foregroundColor(Color(hex: "#EDEBFE"))
                Text(userName.uppercased())
                    .font(font)
                    .overlay {
                        LinearGradient(
                            colors: [Color(hex: "#A399F7"),Color(hex: "#7062E9")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .mask(
                            Text(userName.uppercased())
                                .font(font)
                        )
                    }
            }.frame(
                width: size.width,
                height: size.height
            ) 
            .clipShape(
                Circle()
            )
        }else{
            ISMChat_ImageCahcingManger.networkImage(url: avatar, isprofileImage: true,size: self.size)
                .scaledToFill()
                .frame(
                    width: size.width,
                    height: size.height
                )
                .clipShape(
                    Circle()
                )
                .overlay {
                    Circle()
                        .stroke(.gray.opacity(0.3), lineWidth: 1)
                }
        }
    }
}

public struct BroadCastAvatarView: View {
    var size: CGSize = .defaultAvatarSize
    var broadCastImageSize : CGSize
    var broadCastLogo : Image
    public var body: some View {
        ZStack{
            Circle()
                .frame(width: size.width,height: size.height)
                .foregroundColor(Color(hex: "#EDEBFE"))
            broadCastLogo
                .resizable()
                .frame(width: broadCastImageSize.width, height: broadCastImageSize.height, alignment: .center)
        }.frame(
            width: size.width,
            height: size.height
        )
        .clipShape(
            Circle()
        )
    }
}


/// View used for the online indicator.
public struct OnlineIndicatorView: View {
    
    var indicatorSize: CGFloat
    
    public var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: indicatorSize, height: indicatorSize)
            
            Circle()
                .fill(Color.green)
                .frame(width: innerCircleSize, height: innerCircleSize)
        }
    }
    
    private var innerCircleSize: CGFloat {
        2 * indicatorSize / 3
    }
}

/// View container that allows injecting another view in its top right corner.
public struct BottomRightView<Content: View>: View {
    var content: () -> Content
    
    public init(content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                content()
            }
        }
    }
}
