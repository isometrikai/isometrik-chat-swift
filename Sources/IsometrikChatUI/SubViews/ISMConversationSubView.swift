//
//  ISMConversationRow.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 09/03/23.
//

import SwiftUI
import IsometrikChat

struct ISMConversationSubView: View {
    
    //MARK:  - PROPERTIES
    
    let chat : ConversationDB
    let hasUnreadCount : Bool
    @State var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State var themeImage = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    @State var userData = ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig
    
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
                    font: themeFonts.messageListMessageText)
            }
            VStack(alignment: .leading, spacing: 5, content: {
                HStack{
                    if chat.isGroup == false && chat.opponentDetails?.userId == nil && chat.opponentDetails?.userName == nil{
                        Text("Recipients: \(chat.membersCount)")
                            .foregroundColor(themeColor.chatListUserName)
                            .font(themeFonts.chatListUserName)
                    }else{
                        Text(chat.isGroup == true ? (chat.conversationTitle ) : (chat.opponentDetails?.userName?.capitalizingFirstLetter() ?? ""))
                            .foregroundColor(themeColor.chatListUserName)
                            .font(themeFonts.chatListUserName)
                    }
                    Spacer()
                    let dateVar = NSDate()
                    let date = dateVar.descriptiveString(time: (chat.lastMessageDetails?.sentAt ?? 0))
                    Text(date)
                        .foregroundColor(themeColor.chatListLastMessageTime)
                        .font(themeFonts.chatListLastMessageTime)
                }//:HStack
                getMessageText()
            })//:VStack
        }//:HStack
        .frame(maxHeight: 60)
    }//:Body
    
    
    func getMessageText() -> some View {
        HStack {
            if chat.typing == true{
                Text("Typing...")
                    .foregroundColor(themeColor.chatListUserMessage)
                    .font(themeFonts.chatListUserMessage)
            }else{
                if chat.lastMessageDetails?.deletedMessage == true{
                    HStack{
                        Image(systemName: "minus.circle")
                            .resizable()
                            .frame(width: 15, height: 15, alignment: .center)
                            .tint(themeColor.chatListUserMessage)
                            .foregroundColor(themeColor.chatListUserMessage)
                        
                        Text(chat.lastMessageDetails?.senderId == userData.userId ? "You deleted this message." : "This message was deleted")
                            .foregroundColor(themeColor.chatListUserMessage)
                            .font(themeFonts.chatListUserMessage)
                            .padding(.trailing, 40)
                            .lineLimit(1)
                    }
                }else{
                    if let customType = chat.lastMessageDetails?.customType {
                        switch customType {
                        case ISMChatMediaType.Image.value:
                            getLabel(text: "Image", image: "camera.fill")
                        case ISMChatMediaType.Video.value:
                            getLabel(text: "Video", image: "video.fill")
                        case ISMChatMediaType.File.value:
                            getLabel(text: "Document", image: "doc.fill")
                        case ISMChatMediaType.Voice.value:
                            getLabel(text: "Audio", image: "mic.fill")
                        case ISMChatMediaType.Location.value:
                            getLabel(text: "Location", image: "location.fill")
                        case ISMChatMediaType.Contact.value:
                            getLabel(text: "Contact", image: "person.crop.circle.fill")
                        case ISMChatMediaType.sticker.value:
                            getLabel(text: "Sticker", image: "gif_sticker",imageNormal: true)
                        case ISMChatMediaType.gif.value:
                            getLabel(text: "Gif", image: "gif_sticker",imageNormal: true)
                        case ISMChatMediaType.AudioCall.value:
                            AudioCallUI()
                        case ISMChatMediaType.VideoCall.value:
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
            if chat.lastMessageDetails?.action == ISMChatActionType.meetingCreated.value{
                if chat.lastMessageDetails?.initiatorId == userData.userId{
                    callKitText(text1: "Video Call", text2: "In call", color: Color.green, outgoing: true, missedCall: false, addDot: true, image: "arrow.up.right.video.fill")
                }else{
                    callKitText(text1: "Video Call", text2: "Ringing", color: Color.green, outgoing: false, missedCall: false, addDot: true, image: "arrow.down.left.video.fill")
                }
            }
            else if chat.lastMessageDetails?.action == ISMChatActionType.meetingEndedDueToNoUserPublishing.value{
                if chat.lastMessageDetails?.initiatorId == userData.userId{
                    callKitText(text1: "", text2: "Video call", color: Color.green, outgoing: true, missedCall: false, addDot: false, image: "arrow.up.right.video.fill")
                }else{
                    if chat.lastMessageDetails?.missedByMembers.count == 0{
                        callKitText(text1: "", text2: "Video call", color: Color.green, outgoing: false, missedCall: false, addDot: false, image: "arrow.up.right.video.fill")
                    }else{
                        callKitText(text1: "", text2: "Missed video call", color: Color.green, outgoing: false, missedCall: true, addDot: false, image: "arrow.down.left.video.fill")
                    }
                }
            }
            else if chat.lastMessageDetails?.action == ISMChatActionType.meetingEndedDueToRejectionByAll.value{
                if chat.lastMessageDetails?.initiatorId == userData.userId{
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
            if chat.lastMessageDetails?.action == ISMChatActionType.meetingCreated.value{
                if chat.lastMessageDetails?.initiatorId == userData.userId{
                    callKitText(text1: "Voice Call", text2: "In call", color: Color.green, outgoing: true, missedCall: false, addDot: true, image: "phone.arrow.up.right.fill")
                }else{
                    callKitText(text1: "Voice Call", text2: "Ringing", color: Color.green, outgoing: false, missedCall: false, addDot: true, image: "phone.arrow.down.left.fill")
                }
            }
            else if chat.lastMessageDetails?.action == ISMChatActionType.meetingEndedDueToNoUserPublishing.value{
                if chat.lastMessageDetails?.initiatorId == userData.userId{
                    callKitText(text1: "", text2: "Voice call", color: Color.green, outgoing: true, missedCall: false, addDot: false, image: "phone.arrow.up.right.fill")
                }else{
                    if chat.lastMessageDetails?.missedByMembers.count == 0{
                        callKitText(text1: "", text2: "Voice call", color: Color.green, outgoing: false, missedCall: false, addDot: false, image: "phone.arrow.up.right.fill")
                    }else{
                        callKitText(text1: "", text2: "Missed voice call", color: Color.green, outgoing: false, missedCall: true, addDot: false, image: "phone.arrow.down.left.fill")
                    }
                }
            }
            else if chat.lastMessageDetails?.action == ISMChatActionType.meetingEndedDueToRejectionByAll.value{
                if chat.lastMessageDetails?.initiatorId == userData.userId{
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
            if chat.lastMessageDetails?.action == ISMChatActionType.conversationCreated.value{
                getLabel(text: "Conversation created", image: "person.fill")
            }else if chat.lastMessageDetails?.action == ISMChatActionType.userBlock.value || chat.lastMessageDetails?.action == ISMChatActionType.userBlockConversation.value{
                getLabel(text: "Blocked", image: "circle.slash")
            }else if chat.lastMessageDetails?.action == ISMChatActionType.userUnblock.value || chat.lastMessageDetails?.action == ISMChatActionType.userUnblockConversation.value{
                getLabel(text: "Unblocked", image: "circle.slash")
            }else if chat.lastMessageDetails?.action == ISMChatActionType.reactionAdd.value{
                let emoji = ISMChatHelper.getEmoji(valueString: chat.lastMessageDetails?.reactionType ?? "")
                if chat.lastMessageDetails?.userId == userData.userId{
                    getLabel(hideImage: true,text: chat.isGroup ? "Reacted \(emoji) to a message" : "You reacted \(emoji) to a message", image: "",isReaction : true)
                }else{
                    getLabel(hideImage: true,text: chat.isGroup ? "Reacted \(emoji) to a message" : "\(chat.lastMessageDetails?.userName ?? "") reacted \(emoji) to a message", image: "",isReaction : true)
                }
            }else if chat.lastMessageDetails?.action == ISMChatActionType.reactionRemove.value{
                let emoji = ISMChatHelper.getEmoji(valueString: chat.lastMessageDetails?.reactionType ?? "")
                if chat.lastMessageDetails?.userId == userData.userId{
                    getLabel(hideImage: true,text: chat.isGroup ? "Removed \(emoji) from a message" : "You removed \(emoji) from a message", image: "",isReaction : true)
                }else{
                    getLabel(hideImage: true,text: chat.isGroup ? "Removed \(emoji) from a message" : "\(chat.lastMessageDetails?.userName ?? "") removed \(emoji) from a message", image: "",isReaction : true)
                }
            }
            else if chat.lastMessageDetails?.action == ISMChatActionType.memberLeave.value{
                getLabel(hideImage: false,text: "\(chat.lastMessageDetails?.memberName.capitalizingFirstLetter() ?? "") left", image: "figure.walk",isReaction : true)
            }
            else if chat.lastMessageDetails?.action == ISMChatActionType.addAdmin.value{
                if chat.lastMessageDetails?.memberId == userData.userId{
                    getLabel(hideImage: true,text: "Added you as an admin", image: "",isReaction : true)
                }else{
                    getLabel(hideImage: true,text: "Added \(chat.lastMessageDetails?.memberName ?? "") as an admin", image: "",isReaction : true)
                }
            }else if chat.lastMessageDetails?.action == ISMChatActionType.removeAdmin.value{
                if chat.lastMessageDetails?.memberId == userData.userId{
                    getLabel(hideImage: true,text: "Removed you as an admin", image: "",isReaction : true)
                }else{
                    getLabel(hideImage: true,text: "Removed \(chat.lastMessageDetails?.memberName ?? "") as an admin", image: "",isReaction : true)
                }
            }else if chat.lastMessageDetails?.action == ISMChatActionType.membersRemove.value{
                if chat.lastMessageDetails?.members.first?.memberId == userData.userId{
                    getLabel(hideImage: true,text: "Removed you", image: "",isReaction : true)
                }else{
                    getLabel(hideImage: true,text: "Removed \(chat.lastMessageDetails?.members.first?.memberName?.capitalizingFirstLetter() ?? "")", image: "",isReaction : true)
                }
            }else if chat.lastMessageDetails?.action == ISMChatActionType.membersAdd.value{
                if chat.lastMessageDetails?.members.first?.memberId == userData.userId{
                    getLabel(hideImage: true,text: "Added you", image: "",isReaction : true)
                }else{
                    getLabel(hideImage: true,text: "Added \(chat.lastMessageDetails?.members.first?.memberName ?? "")", image: "",isReaction : true)
                }
            }else if chat.lastMessageDetails?.action == ISMChatActionType.conversationTitleUpdated.value{
                getLabel(hideImage: true,text: "Changed this group title", image: "",isReaction : true)
            }
            else if chat.lastMessageDetails?.action == ISMChatActionType.conversationImageUpdated.value{
                getLabel(hideImage: true,text: "Changed this group image", image: "",isReaction : true)
            }else if chat.lastMessageDetails?.action == ISMChatActionType.messageDetailsUpdated.value{
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
                .tint(missedCall ? Color.red : themeColor.chatListUserMessage)
                .foregroundColor(themeColor.chatListUserMessage)
            
            HStack(alignment: .center,spacing: 2){
                Text(text1)
                    .foregroundColor(color)
                    .font(themeFonts.chatListUserMessage)
                    .lineLimit(1)
                
                if addDot == true{
                    Text(".")
                        .foregroundColor(themeColor.chatListUserMessage)
                        .font(themeFonts.chatListUserMessage)
                        .lineLimit(1)
                }
                
                Text(text2)
                    .foregroundColor(themeColor.chatListUserMessage)
                    .font(themeFonts.chatListUserMessage)
                    .padding(.trailing, 40)
                    .lineLimit(1)
            }
            
            //UNREAD MESSAGE COUNT
            let count = chat.unreadMessagesCount
            if count > 0{
                Spacer()
                Text("\(count)")
                    .foregroundColor(themeColor.chatListUnreadMessageCount)
                    .font(themeFonts.chatListUnreadMessageCount)
                    .padding(7)
                    .background(themeColor.chatListUnreadMessageCountBackground)
                    .frame(height: 20)
                    .cornerRadius(10)
            }
        }
    }
    
    func getLabel(hideImage : Bool? = false, text : String, image : String,isReaction : Bool? = false,imageNormal : Bool? = false) -> some View{
        HStack(alignment: .center,spacing: 5){
            
            if chat.isGroup == false{
                if chat.lastMessageDetails?.senderId == userData.userId{
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
                        .tint(themeColor.chatListUserMessage)
                        .foregroundColor(themeColor.chatListUserMessage)
                }
            }
            Text(text)
                .foregroundColor(themeColor.chatListUserMessage)
                .font(themeFonts.chatListUserMessage)
                .padding(.trailing, 40)
                .lineLimit(2)
            
            
            //UNREAD MESSAGE COUNT
            let count = chat.unreadMessagesCount
            if count > 0{
                Spacer()
                Text("\(count)")
                    .foregroundColor(themeColor.chatListUnreadMessageCount)
                    .font(themeFonts.chatListUnreadMessageCount)
                    .padding(7)
                    .background(themeColor.chatListUnreadMessageCountBackground)
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
                if chat.lastMessageDetails?.msgSyncStatus == ISMChatSyncStatus.Local.txt {
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
        
            let prefix = senderId == userData.userId ? "You:" : "\(senderName):"
            
            return AnyView(
                Text(prefix)
                    .foregroundColor(themeColor.chatListUserMessage)
                    .font(themeFonts.chatListUserMessage)
                    .lineLimit(1)
            )
        } else {
            return AnyView(EmptyView())
        }
    }
}

