//
//  ISMHashtag.swift
//  ISMChatSdk
//
//  Created by Rasika on 26/02/24.
//

import Foundation
import SwiftUI
import IsometrikChat

/// A view that displays text with highlighted mentions of users
/// - Parameters:
///   - originalText: The text content to display
///   - mentionedUsers: Array of users that can be mentioned in the text
///   - isReceived: Boolean indicating if the message is received or sent
///   - navigateToInfo: Binding to control navigation to user info
///   - navigatetoUser: Binding to the selected user for navigation
struct HighlightedTextView : View{
    
    @State var originalText: String
    let mentionedUsers: [ISMChatGroupMember]
    let isReceived : Bool
    @Binding var navigateToInfo : Bool
    @Binding var navigatetoUser : ISMChatGroupMember
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
   

    var body: some View {
        HashtagText(originalText)
            .modifier(HashtagTextModifier(mentionedUsers: mentionedUsers,isReceived: self.isReceived, navigateToInfo : $navigateToInfo,navigatetoUser : $navigatetoUser))
            .onOpenURL { url in
                // Handle taps on mentioned users by parsing the URL and navigating to user info
                if let keyword = self.parseURL(url: url) {
                        if let matchedUser = mentionedUsers.first(where: { member in
                            if let memberUsername = member.userName {
                                return memberUsername.lowercased().replacingOccurrences(of: " ", with: "").contains(String(keyword).lowercased())
                            }
                            return false
                        }) {
                            let member = ISMChatGroupMember(userProfileImageUrl: matchedUser.userProfileImageUrl, userName: matchedUser.userName, userIdentifier: matchedUser.userIdentifier, userId: matchedUser.userId, online: matchedUser.online, lastSeen: matchedUser.lastSeen, isAdmin: matchedUser.isAdmin)
                            navigatetoUser = member
                            navigateToInfo = true
                        }
                }
            }
    }
    
    /// Extracts the username from a mention URL
    /// - Parameter url: URL in format "hashtagtext://username"
    /// - Returns: The extracted username or nil if invalid format
    private func parseURL(url: URL) -> String? {
        let string = url.absoluteString
        if let keyword = string.split(separator: "//").last {
            return String(keyword)
        }
        return nil
    }
}

/// A basic text view wrapper for applying mention highlighting
struct HashtagText: View {
    
    var text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
    }
    
}

/// Protocol defining the interface for text modification
protocol TextModifier {
    associatedtype Body : View
    func body(text: HashtagText) -> Self.Body
}

extension HashtagText {
    func modifier<M>(_ modifier: M) -> some View where M: TextModifier {
        modifier.body(text: self)
    }
}

/// Modifier that handles the highlighting and styling of mentioned users in text
struct HashtagTextModifier: TextModifier {
    let mentionedUsers: [ISMChatGroupMember]
    var firstNameIsValid : Bool = false
    let isReceived : Bool
    @Binding var navigateToInfo : Bool
    @Binding var navigatetoUser : ISMChatGroupMember
    @State var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette

    func body(text: HashtagText) -> some View {
        let words = text.text.split(separator: " ")
        var output: Text = Text("")
        for word in words {
            if word.hasPrefix("@"){
                if let matchedUser = mentionedUsers.first(where: { member in
                    if let memberUsername = member.userName {
                        return memberUsername.lowercased().contains(String(word.dropFirst()).lowercased())
                    }
                    return false
                }) {
                    
                     var attributedString: AttributedString {
                         if let string = matchedUser.userName?.split(separator: " ").first{
                             var attributedString = AttributedString("@\(string)")
                             // 1
                             attributedString.font = themeFonts.messageListMessageText
                             
                             attributedString.foregroundColor = themeColor.userProfileEditText
                             
                             
                             // 2
                             if let range = attributedString.range(of: word) {
                                 attributedString[range].foregroundColor = themeColor.userProfileEditText
                                 attributedString[range].link = URL(string: "hashtagtext://" + String(matchedUser.userName ?? "").replacingOccurrences(of: " ", with: ""))
                             }
                             
                             return attributedString
                         }
                         return ""
                    }
                    output = output + Text(" ") +
                        Text(attributedString)
                    
                    
                }else{
                    output = output + Text(" ") + Text(String(word))
                }
            }
            else {
                // Check if there's a match and update `output` accordingly
                _ = mentionedUsers.contains { member in
                    if let memberUsername = member.userName {
                        return memberUsername.lowercased().contains(String(word.dropFirst()).lowercased())
                    }
                    return false
                }

                output = output + Text(" ") + Text(String(word))
            }
        }
        return output
            .font(themeFonts.messageListMessageText)
            .foregroundColor(isReceived ? themeColor.messageListMessageTextReceived :  themeColor.messageListMessageTextSend)
    }
}
