//
//  UserAvatarView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 26/06/23.
//

import SwiftUI
import IsometrikChat

/// A view that displays a user's avatar with an optional online status indicator
public struct UserAvatarView: View {
    // Properties for configuring the avatar display
    var avatar: String          // URL string for the avatar image
    var showOnlineIndicator: Bool
    var size: CGSize = .defaultAvatarSize
    var userName: String
    var font: Font = .regular(size: 16)
    
    public init(
        avatar: String,
        showOnlineIndicator: Bool,
        size: CGSize = .defaultAvatarSize,
        userName: String,
        font: Font = .headline
    ) {
        self.avatar = avatar
        self.showOnlineIndicator = showOnlineIndicator
        self.size = size
        // Transform full name into initials (up to 2 characters)
        self.userName = userName
            .components(separatedBy: " ")     // Split name into words
            .compactMap { $0.first }          // Get first character of each word
            .prefix(2)                        // Take first two characters
            .map { String($0).uppercased() }  // Convert to uppercase strings
            .joined()                         // Join characters together
        self.font = font
    }
    
    public var body: some View {
        HStack{
            ZStack(alignment: .bottomTrailing) {
                // Avatar view
                AvatarView(avatar: avatar, size: size, userName: userName, font: font)
                
                // Online indicator positioned at bottom right corner of the avatar circle
                if showOnlineIndicator {
                    OnlineIndicatorView(indicatorSize: onlineIndicatorSize)
                        // Position indicator on the circle edge by moving it inward from the corner
                        .offset(x: indicatorOffset, y: indicatorOffset)
                }
            }
            .frame(width: size.width, height: size.height)
        }
        .accessibilityIdentifier("ISMProfileImageView")
    }
    
    /// Calculates the online indicator size based on avatar size
    /// If avatar is too large, returns a default size to prevent the indicator from looking oversized
    private var onlineIndicatorSize: CGFloat {
        // Default size for online indicator (typically 12 points works well)
        let defaultIndicatorSize: CGFloat = 12
        
        // Maximum threshold for avatar size where we still scale proportionally
        // For avatars larger than this, we use the default size instead
        let maxProportionalSize: CGFloat = 60
        
        // Calculate proportional size (30% of avatar width)
        let proportionalSize = size.width * 0.3
        
        // If avatar is larger than threshold, use default size
        // Otherwise, use the proportional size
        if size.width > maxProportionalSize {
            return defaultIndicatorSize
        } else {
            // Use proportional size, but ensure it doesn't exceed the default size
            return min(proportionalSize, defaultIndicatorSize)
        }
    }
    
    /// Calculates the offset for positioning the online indicator on the circle edge
    /// Positions the indicator so it sits on the circle's circumference at bottom-right
    private var indicatorOffset: CGFloat {
        // Calculate the radius of the avatar circle
        let radius = size.width / 2
        let indicatorRadius = onlineIndicatorSize / 2
        
        // At 45 degrees (bottom-right), distance from frame corner to circle edge
        // Frame corner is at distance radius*√2 from center
        // Circle edge at 45° is at distance radius from center
        // Distance from corner to circle edge: radius * (√2 - 1) ≈ radius * 0.414
        let distanceFromCornerToEdge = radius * (sqrt(2) - 1)
        
        // For large avatars (where indicator size is fixed at 12), use a more accurate calculation
        // Since the indicator size is constant, we need to balance the offset
        if size.width > 60 {
            // Large avatars: calculate offset to position indicator on circle edge
            // Move inward by distance to edge, but add back some to account for indicator size
            // This positions the indicator so its edge touches the circle
            let offset = distanceFromCornerToEdge - indicatorRadius * 2
            return -offset
        } else {
            // Small avatars: use the full calculated offset
            // Move inward by: (distance to edge - indicator radius)
            return -(distanceFromCornerToEdge - indicatorRadius)
        }
    }
}

/// A view that renders either a network image or a placeholder with user initials
public struct AvatarView: View {
    // Properties for avatar configuration
    var avatar: String
    var size: CGSize = .defaultAvatarSize
    var userName: String
    var font: Font = .headline
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @State private var isValid: Bool?    // Tracks if the avatar URL is valid
    
    public var body: some View {
        Group {
            if !ISMChatHelper.shouldShowPlaceholder(avatar: avatar) {
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
    
    /// Placeholder view shown when avatar image is unavailable
    private var placeholderView: some View {
        ZStack {
            Circle()
                .fill(appearance.colorPalette.avatarBackground) // Fill the circle with the desired color
                .overlay(
                    Circle()
                        .stroke(.gray.opacity(0.3), lineWidth: 1) // Add a stroke on top
                )
                .frame(width: size.width, height: size.height)
            Text(userName.uppercased())
                .font(appearance.fonts.avatarText)
                .foregroundColor(appearance.colorPalette.avatarText)
        }
        .frame(width: size.width, height: size.height)
        .clipShape(Circle())
    }
    
    /// Validates if the provided image URL is accessible
    private func validateImageURL() {
        isValidImageURL(avatar) { isValid in
            DispatchQueue.main.async {
                self.isValid = isValid
            }
        }
    }
    
    /// Checks if a URL points to a valid image resource
    /// - Parameters:
    ///   - urlString: The URL string to validate
    ///   - completion: Closure called with boolean indicating URL validity
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

/// A specialized avatar view for broadcast messages
public struct BroadCastAvatarView: View {
    var size: CGSize = .defaultAvatarSize
    var broadCastImageSize: CGSize
    var broadCastLogo: Image
    
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
