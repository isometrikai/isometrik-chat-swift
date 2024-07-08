//
//  ISMHashtag.swift
//  ISMChatSdk
//
//  Created by Rasika on 26/02/24.
//

import Foundation
import SwiftUI

struct HighlightedTextView : View{
    
    @State var originalText: String
    let mentionedUsers: [ISMChat_GroupMember]
    @Binding var navigateToInfo : Bool
    @Binding var navigatetoUser : ISMChat_GroupMember
   

    var body: some View {
        HashtagText(originalText)
            .modifier(HashtagTextModifier(mentionedUsers: mentionedUsers,navigateToInfo : $navigateToInfo,navigatetoUser : $navigatetoUser))
            .onOpenURL { url in
                if let keyword = self.parseURL(url: url) {
                        if let matchedUser = mentionedUsers.first(where: { member in
                            if let memberUsername = member.userName {
                                return memberUsername.lowercased().replacingOccurrences(of: " ", with: "").contains(String(keyword).lowercased())
                            }
                            return false
                        }) {
                            let member = ISMChat_GroupMember(userProfileImageUrl: matchedUser.userProfileImageUrl, userName: matchedUser.userName, userIdentifier: matchedUser.userIdentifier, userId: matchedUser.userId, online: matchedUser.online, lastSeen: matchedUser.lastSeen, isAdmin: matchedUser.isAdmin)
                            navigatetoUser = member
                            navigateToInfo = true
                        }
                }
            }
    }
    private func parseURL(url: URL) -> String? {
        let string = url.absoluteString
        if let keyword = string.split(separator: "//").last {
            return String(keyword)
        }
        return nil
    }
}


struct HashtagText: View {
    
    var text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
    }
    
}


protocol TextModifier {
    associatedtype Body : View
    func body(text: HashtagText) -> Self.Body
}

extension HashtagText {
    func modifier<M>(_ modifier: M) -> some View where M: TextModifier {
        modifier.body(text: self)
    }
}


struct HashtagTextModifier: TextModifier {
    let mentionedUsers: [ISMChat_GroupMember]
    var firstNameIsValid : Bool = false
    @Binding var navigateToInfo : Bool
    @Binding var navigatetoUser : ISMChat_GroupMember
    @State var themeFonts = ISMChatSdk.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdk.getInstance().getAppAppearance().appearance.colorPalette

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
                             attributedString.font = themeFonts.messageList_MessageText
                             
                             attributedString.foregroundColor = themeColor.userProfile_editText
                             
                             
                             // 2
                             if let range = attributedString.range(of: word) {
                                 attributedString[range].foregroundColor = themeColor.userProfile_editText
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
                if let matchedUser = mentionedUsers.first(where: { member in
                    if let memberUsername = member.userName {
                        return memberUsername.lowercased().contains(String(word.dropFirst()).lowercased())
                    }
                    return false
                }) {
                    output = output + Text(" ") +
                    Text(String(word))
                    
                }else{
                    output = output + Text(" ") + Text(String(word))
                }
            }
        }
        return output.font(themeFonts.messageList_MessageText)
    }
}
