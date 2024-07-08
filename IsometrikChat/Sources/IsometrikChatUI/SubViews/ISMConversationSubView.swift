//
//  ISM_ConversationRow.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 09/03/23.
//

import SwiftUI

struct ISMConversationSubView: View {
    
    //MARK:  - PROPERTIES
    
    let chat : ConversationDB
    let hasUnreadCount : Bool
    @State var themeFonts = ISMChatSdk.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdk.getInstance().getAppAppearance().appearance.colorPalette
    @State var themeImage = ISMChatSdk.getInstance().getAppAppearance().appearance.images
    @State var userSession = ISMChatSdk.getInstance().getUserSession()
    
    //MARK:  - BODY
    var body: some View {
        HStack(spacing:15){
            if chat.isGroup == false && chat.opponentDetails?.userId == nil && chat.opponentDetails?.userName == nil{
                BroadCastAvatarView(size: CGSize(width: 54, height: 54), broadCastImageSize: CGSize(width: 24, height: 24),broadCastLogo: themeImage.broadCastLogo)
            }else{
                UserAvatarView(
                    avatar: chat.isGroup == true ? (chat.conversationImageUrl ) : (chat.opponentDetails?.userProfileImageUrl ?? ""),
                    showOnlineIndicator: false,
                    size: CGSize(width: 54, height: 54),
                    userName: chat.isGroup == true ? chat.conversationTitle  : chat.opponentDetails?.userName ?? "",
                    font: themeFonts.messageList_MessageText)
            }
            VStack(alignment: .leading, spacing: 5, content: {
                HStack{
                    if chat.isGroup == false && chat.opponentDetails?.userId == nil && chat.opponentDetails?.userName == nil{
                        Text("Recipients: \(chat.membersCount)")
                            .foregroundColor(themeColor.chatList_UserName)
                            .font(themeFonts.chatList_UserName)
                    }else{
                        Text(chat.isGroup == true ? (chat.conversationTitle ) : (chat.opponentDetails?.userName?.capitalizingFirstLetter() ?? ""))
                            .foregroundColor(themeColor.chatList_UserName)
                            .font(themeFonts.chatList_UserName)
                    }
                    Spacer()
                    let dateVar = NSDate()
                    let date = dateVar.descriptiveString(time: (chat.lastMessageDetails?.sentAt ?? 0))
                    Text(date)
                        .foregroundColor(themeColor.chatList_LastMessageTime)
                        .font(themeFonts.chatList_LastMessageTime)
                }//:HStack
                getMessageText()
            })//:VStack
        }//:HStack
        .frame(height: 60)
    }//:Body
    
    
    func getMessageText() -> some View {
        HStack {
            if chat.typing == true{
                Text("Typing...")
                    .foregroundColor(themeColor.chatList_UserMessage)
                    .font(themeFonts.chatList_UserMessage)
            }else{
                if chat.lastMessageDetails?.deletedMessage == true{
                    HStack{
                        Image(systemName: "minus.circle")
                            .resizable()
                            .frame(width: 15, height: 15, alignment: .center)
                            .tint(themeColor.chatList_UserMessage)
                            .foregroundColor(themeColor.chatList_UserMessage)
                        
                        Text(chat.lastMessageDetails?.senderId == userSession.getUserId() ? "You deleted this message." : "This message was deleted")
                            .foregroundColor(themeColor.chatList_UserMessage)
                            .font(themeFonts.chatList_UserMessage)
                            .padding(.trailing, 40)
                            .lineLimit(1)
                    }
                }else{
                    if let customType = chat.lastMessageDetails?.customType {
                        switch customType {
                        case ISMChat_MediaType.Image.value:
                            getLabel(text: "Image", image: "camera.fill")
                        case ISMChat_MediaType.Video.value:
                            getLabel(text: "Video", image: "video.fill")
                        case ISMChat_MediaType.File.value:
                            getLabel(text: "Document", image: "doc.fill")
                        case ISMChat_MediaType.Voice.value:
                            getLabel(text: "Audio", image: "mic.fill")
                        case ISMChat_MediaType.Location.value:
                            getLabel(text: "Location", image: "location.fill")
                        case ISMChat_MediaType.Contact.value:
                            getLabel(text: "Contact", image: "person.crop.circle.fill")
                        case ISMChat_MediaType.sticker.value:
                            getLabel(text: "Sticker", image: "gif_sticker",imageNormal: true)
                        case ISMChat_MediaType.gif.value:
                            getLabel(text: "Gif", image: "gif_sticker",imageNormal: true)
                        case ISMChat_MediaType.AudioCall.value:
                            AudioCallUI()
                        case ISMChat_MediaType.VideoCall.value:
                            VideoCallUI()
                        default:
                            actionLabels()
                        }
                    }else{
                        actionLabels()
                    }
                }
            }
        }
    }
    
    func VideoCallUI() -> some View{
        HStack{
            if chat.lastMessageDetails?.action == ISMChat_ActionType.meetingCreated.value{
                if chat.lastMessageDetails?.initiatorIdentifier == userSession.getEmailId(){
                    callKitText(text1: "Video Call", text2: "In call", color: Color.green, outgoing: true, missedCall: false, addDot: true, image: "arrow.up.right.video.fill")
                }else{
                    callKitText(text1: "Video Call", text2: "Ringing", color: Color.green, outgoing: false, missedCall: false, addDot: true, image: "arrow.down.left.video.fill")
                }
            }
            else if chat.lastMessageDetails?.action == ISMChat_ActionType.meetingEndedDueToNoUserPublishing.value{
                if chat.lastMessageDetails?.initiatorIdentifier == userSession.getEmailId(){
                    callKitText(text1: "", text2: "Video call", color: Color.green, outgoing: true, missedCall: false, addDot: false, image: "arrow.up.right.video.fill")
                }else{
                    if chat.lastMessageDetails?.missedByMembers.count == 0{
                        callKitText(text1: "", text2: "Video call", color: Color.green, outgoing: false, missedCall: false, addDot: false, image: "arrow.up.right.video.fill")
                    }else{
                        callKitText(text1: "", text2: "Missed video call", color: Color.green, outgoing: false, missedCall: true, addDot: false, image: "arrow.down.left.video.fill")
                    }
                }
            }
            else if chat.lastMessageDetails?.action == ISMChat_ActionType.meetingEndedDueToRejectionByAll.value{
                if chat.lastMessageDetails?.initiatorIdentifier == userSession.getEmailId(){
                    callKitText(text1: "", text2: "Video call", color: Color.green, outgoing: true, missedCall: false, addDot: false, image: "arrow.up.right.video.fill")
                }else{
                    if chat.lastMessageDetails?.missedByMembers.count == 0{
                        callKitText(text1: "", text2: "Video call", color: Color.green, outgoing: false, missedCall: false, addDot: false, image: "arrow.up.right.video.fill")
                    }else{
                        callKitText(text1: "", text2: "Missed video call", color: Color.green, outgoing: false, missedCall: true, addDot: false, image: "arrow.down.left.video.fill")
                    }
                }
            }
        }
    }
    
    func AudioCallUI() -> some View{
        HStack{
            if chat.lastMessageDetails?.action == ISMChat_ActionType.meetingCreated.value{
                if chat.lastMessageDetails?.initiatorIdentifier == userSession.getEmailId(){
                    callKitText(text1: "Voice Call", text2: "In call", color: Color.green, outgoing: true, missedCall: false, addDot: true, image: "phone.arrow.up.right.fill")
                }else{
                    callKitText(text1: "Voice Call", text2: "Ringing", color: Color.green, outgoing: false, missedCall: false, addDot: true, image: "phone.arrow.down.left.fill")
                }
            }
            else if chat.lastMessageDetails?.action == ISMChat_ActionType.meetingEndedDueToNoUserPublishing.value{
                if chat.lastMessageDetails?.initiatorIdentifier == userSession.getEmailId(){
                    callKitText(text1: "", text2: "Voice call", color: Color.green, outgoing: true, missedCall: false, addDot: false, image: "phone.arrow.up.right.fill")
                }else{
                    if chat.lastMessageDetails?.missedByMembers.count == 0{
                        callKitText(text1: "", text2: "Voice call", color: Color.green, outgoing: false, missedCall: false, addDot: false, image: "phone.arrow.up.right.fill")
                    }else{
                        callKitText(text1: "", text2: "Missed voice call", color: Color.green, outgoing: false, missedCall: true, addDot: false, image: "phone.arrow.down.left.fill")
                    }
                }
            }
            else if chat.lastMessageDetails?.action == ISMChat_ActionType.meetingEndedDueToRejectionByAll.value{
                if chat.lastMessageDetails?.initiatorIdentifier == userSession.getEmailId(){
                    callKitText(text1: "", text2: "Voice call", color: Color.green, outgoing: true, missedCall: false, addDot: false, image: "phone.arrow.up.right.fill")
                }else{
                    if chat.lastMessageDetails?.missedByMembers.count == 0{
                        callKitText(text1: "", text2: "Voice call", color: Color.green, outgoing: false, missedCall: false, addDot: false, image: "phone.arrow.up.right.fill")
                    }else{
                        callKitText(text1: "", text2: "Missed voice call", color: Color.green, outgoing: false, missedCall: true, addDot: false, image: "phone.arrow.down.left.fill")
                    }
                }
            }
        }
    }
    
    func actionLabels() -> some View{
        HStack {
            if chat.lastMessageDetails?.action == ISMChat_ActionType.conversationCreated.value{
                getLabel(text: "Conversation created", image: "person.fill")
            }else if chat.lastMessageDetails?.action == ISMChat_ActionType.userBlock.value || chat.lastMessageDetails?.action == ISMChat_ActionType.userBlockConversation.value{
                getLabel(text: "Blocked", image: "circle.slash")
            }else if chat.lastMessageDetails?.action == ISMChat_ActionType.userUnblock.value || chat.lastMessageDetails?.action == ISMChat_ActionType.userUnblockConversation.value{
                getLabel(text: "Unblocked", image: "circle.slash")
            }else if chat.lastMessageDetails?.action == ISMChat_ActionType.reactionAdd.value{
                let emoji = ISMChat_Helper.getEmoji(valueString: chat.lastMessageDetails?.reactionType ?? "")
                if chat.lastMessageDetails?.userId == userSession.getUserId(){
                    getLabel(hideImage: true,text: chat.isGroup ? "Reacted \(emoji) to a message" : "You reacted \(emoji) to a message", image: "",isReaction : true)
                }else{
                    getLabel(hideImage: true,text: chat.isGroup ? "Reacted \(emoji) to a message" : "\(chat.lastMessageDetails?.userName ?? "") reacted \(emoji) to a message", image: "",isReaction : true)
                }
            }else if chat.lastMessageDetails?.action == ISMChat_ActionType.reactionRemove.value{
                let emoji = ISMChat_Helper.getEmoji(valueString: chat.lastMessageDetails?.reactionType ?? "")
                if chat.lastMessageDetails?.userId == userSession.getUserId(){
                    getLabel(hideImage: true,text: chat.isGroup ? "Removed \(emoji) from a message" : "You removed \(emoji) from a message", image: "",isReaction : true)
                }else{
                    getLabel(hideImage: true,text: chat.isGroup ? "Removed \(emoji) from a message" : "\(chat.lastMessageDetails?.userName ?? "") removed \(emoji) from a message", image: "",isReaction : true)
                }
            }
            else if chat.lastMessageDetails?.action == ISMChat_ActionType.memberLeave.value{
                getLabel(hideImage: false,text: "\(chat.lastMessageDetails?.memberName.capitalizingFirstLetter() ?? "") left", image: "figure.walk",isReaction : true)
            }
            else if chat.lastMessageDetails?.action == ISMChat_ActionType.addAdmin.value{
                if chat.lastMessageDetails?.memberId == userSession.getUserId(){
                    getLabel(hideImage: true,text: "Added you as an admin", image: "",isReaction : true)
                }else{
                    getLabel(hideImage: true,text: "Added \(chat.lastMessageDetails?.memberName ?? "") as an admin", image: "",isReaction : true)
                }
            }else if chat.lastMessageDetails?.action == ISMChat_ActionType.removeAdmin.value{
                if chat.lastMessageDetails?.memberId == userSession.getUserId(){
                    getLabel(hideImage: true,text: "Removed you as an admin", image: "",isReaction : true)
                }else{
                    getLabel(hideImage: true,text: "Removed \(chat.lastMessageDetails?.memberName ?? "") as an admin", image: "",isReaction : true)
                }
            }else if chat.lastMessageDetails?.action == ISMChat_ActionType.membersRemove.value{
                if chat.lastMessageDetails?.members.first?.memberId == userSession.getUserId(){
                    getLabel(hideImage: true,text: "Removed you", image: "",isReaction : true)
                }else{
                    getLabel(hideImage: true,text: "Removed \(chat.lastMessageDetails?.members.first?.memberName?.capitalizingFirstLetter() ?? "")", image: "",isReaction : true)
                }
            }else if chat.lastMessageDetails?.action == ISMChat_ActionType.membersAdd.value{
                if chat.lastMessageDetails?.members.first?.memberId == userSession.getUserId(){
                    getLabel(hideImage: true,text: "Added you", image: "",isReaction : true)
                }else{
                    getLabel(hideImage: true,text: "Added \(chat.lastMessageDetails?.members.first?.memberName ?? "")", image: "",isReaction : true)
                }
            }else if chat.lastMessageDetails?.action == ISMChat_ActionType.conversationTitleUpdated.value{
                getLabel(hideImage: true,text: "Changed this group title", image: "",isReaction : true)
            }
            else if chat.lastMessageDetails?.action == ISMChat_ActionType.conversationImageUpdated.value{
                getLabel(hideImage: true,text: "Changed this group image", image: "",isReaction : true)
            }else if chat.lastMessageDetails?.action == ISMChat_ActionType.messageDetailsUpdated.value{
                if let body = chat.lastMessageDetails?.body {
                    getLabel(hideImage: true, text: body, image: "")
                }
            }
            else{
                if let body = chat.lastMessageDetails?.body {
                    let str = body
                    getLabel(hideImage: true, text: str, image: "")
                }
            }
        }
    }
    
    func callKitText(text1 : String,text2 : String,color : Color,outgoing : Bool,missedCall : Bool,addDot : Bool,image : String) -> some View{
        HStack(alignment: .center,spacing: 5){
            
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 19, height: 11)
                .tint(missedCall ? Color.red : themeColor.chatList_UserMessage)
                .foregroundColor(themeColor.chatList_UserMessage)
            
            HStack(alignment: .center,spacing: 2){
                Text(text1)
                    .foregroundColor(color)
                    .font(themeFonts.chatList_UserMessage)
                    .lineLimit(1)
                
                if addDot == true{
                    Text(".")
                        .foregroundColor(themeColor.chatList_UserMessage)
                        .font(themeFonts.chatList_UserMessage)
                        .lineLimit(1)
                }
                
                Text(text2)
                    .foregroundColor(themeColor.chatList_UserMessage)
                    .font(themeFonts.chatList_UserMessage)
                    .padding(.trailing, 40)
                    .lineLimit(1)
            }
            
            //UNREAD MESSAGE COUNT
            let count = chat.unreadMessagesCount
            if count > 0{
                Spacer()
                Text("\(count)")
                    .foregroundColor(themeColor.chatList_UnreadMessageCount)
                    .font(themeFonts.chatList_UnreadMessageCount)
                    .padding(7)
                    .background(themeColor.chatList_UnreadMessageCountBackground)
                    .frame(height: 20)
                    .cornerRadius(10)
            }
        }
    }
    
    func getLabel(hideImage : Bool? = false, text : String, image : String,isReaction : Bool? = false,imageNormal : Bool? = false) -> some View{
        HStack(alignment: .center,spacing: 5){
            
            if chat.isGroup == false{
                if chat.lastMessageDetails?.senderId == userSession.getUserId(){
                    if isReaction == false{
                        messageDeliveryStatus()
                    }
                }
            }
            
            if chat.isGroup == true{
                 getSenderNameText()
            }
            
            if hideImage == false{
                if imageNormal == true{
                    Image(image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 19, height: 11)
                }else{
                    Image(systemName: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 19, height: 11)
                        .tint(themeColor.chatList_UserMessage)
                        .foregroundColor(themeColor.chatList_UserMessage)
                }
            }
            Text(text)
                .foregroundColor(themeColor.chatList_UserMessage)
                .font(themeFonts.chatList_UserMessage)
                .padding(.trailing, 40)
                .lineLimit(1)
            
            
            //UNREAD MESSAGE COUNT
            let count = chat.unreadMessagesCount
            if count > 0{
                Spacer()
                Text("\(count)")
                    .foregroundColor(themeColor.chatList_UnreadMessageCount)
                    .font(themeFonts.chatList_UnreadMessageCount)
                    .padding(7)
                    .background(themeColor.chatList_UnreadMessageCountBackground)
                    .frame(height: 20)
                    .cornerRadius(10)
            }
        }
    }
    func messageDeliveryStatus() -> some View {
        if chat.isGroup == false{
            if (chat.lastMessageDetails?.deliveredTo.count == 1 && chat.lastMessageDetails?.deliveredTo.first?.userId != nil) && (chat.lastMessageDetails?.readBy.count == 1 && chat.lastMessageDetails?.readBy.first?.userId != nil) {
                return AnyView(themeImage.messageRead
                    .resizable()
                    .frame(width: 15, height: 9))
            }else if (chat.lastMessageDetails?.deliveredTo.count == 1 && chat.lastMessageDetails?.deliveredTo.first?.userId != nil) && chat.lastMessageDetails?.readBy.count == 0{
                return AnyView(themeImage.messageDelivered
                    .resizable()
                    .frame(width: 15, height: 9))
            }else{
                if chat.lastMessageDetails?.msgSyncStatus == ISMChat_SyncStatus.Local.txt {
                    return AnyView(themeImage.messagePending
                        .resizable()
                        .frame(width: 9, height: 9))
                }
                return AnyView(themeImage.messageSent
                    .resizable()
                    .frame(width: 11, height: 9))
            }
        }else{
            //write code for group after grp implementations
            return AnyView(EmptyView())
        }
    }
    func getSenderNameText() -> some View {
        if let messageDetails = chat.lastMessageDetails {
            let senderId = messageDetails.initiatorId ?? (messageDetails.senderId ?? messageDetails.userId)
            var senderName = ""
            
            if let name = messageDetails.initiatorName, !name.isEmpty {
                senderName = name
            } else if let name = messageDetails.senderName, !name.isEmpty {
                senderName = name
            } else {
                senderName = messageDetails.userName ?? ""
            }
        
            let prefix = senderId == userSession.getUserId() ? "You:" : "\(senderName):"
            
            return AnyView(
                Text(prefix)
                    .foregroundColor(themeColor.chatList_UserMessage)
                    .font(themeFonts.chatList_UserMessage)
                    .lineLimit(1)
            )
        } else {
            return AnyView(EmptyView())
        }
    }
}

