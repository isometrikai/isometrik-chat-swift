//
//  UserAvatarView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 26/06/23.
//

import SwiftUI
import IsometrikChat

public struct UserAvatarView: View {
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
        self.userName = userName
            .components(separatedBy: " ")
            .compactMap { $0.first }
            .prefix(2)
            .map { String($0).uppercased() }
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
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @State private var isValid: Bool?
    
    public var body: some View {
        Group {
            if !shouldShowPlaceholder(avatar: avatar) {
                ISMChatImageCahcingManger.networkImage(url: avatar, isProfileImage: true, placeholderView: placeholderView)
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(.gray.opacity(0.3), lineWidth: 1)
                    }
            } else {
                placeholderView
            }
        }
        .onAppear {
            validateImageURL()
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            Circle()
                .stroke(.gray.opacity(0.3), lineWidth: 1)
                .frame(width: size.width, height: size.height)
                .foregroundColor(appearance.colorPalette.avatarBackground)
            Text(userName.uppercased())
                .font(appearance.fonts.avatarText)
                .foregroundColor(appearance.colorPalette.avatarText)
        }
        .frame(width: size.width, height: size.height)
        .clipShape(Circle())
    }
    
    private func validateImageURL() {
        isValidImageURL(avatar) { isValid in
            DispatchQueue.main.async {
                self.isValid = isValid
            }
        }
    }
    private func shouldShowPlaceholder(avatar: String) -> Bool {
        return avatar == "https://res.cloudinary.com/dxkoc9aao/image/upload/v1616075844/kesvhgzyiwchzge7qlsz_yfrh9x.jpg" ||
        avatar.isEmpty ||
        avatar == "https://admin-media.isometrik.io/profile/def_profile.png" ||
        avatar.contains("svg") || avatar == "https://www.gravatar.com/avatar/?d=identicon"
    }
    
    func isValidImageURL(_ urlString: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD" // Use HEAD to avoid downloading the full image
        
        let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                // Check for a valid status code (200 is typically what we want)
                completion(httpResponse.statusCode == 200)
            } else {
                completion(false)
            }
        }
        task.resume()
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
