//
//  ISMConversationRow.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 09/03/23.
//

import SwiftUI
import IsometrikChat

/// A SwiftUI view that represents a single conversation row in a chat list
/// Displays user avatar, name, last message, timestamp and unread count
struct ISMConversationSubView: View {
    
    //MARK:  - PROPERTIES
    
    /// The conversation database model containing chat details
    let chat : ConversationDB
    /// Flag indicating if there are unread messages
    let hasUnreadCount : Bool
    /// UI appearance configuration for the chat SDK
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    /// Current user's configuration
    var userData = ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig
    
    //MARK:  - BODY
    var body: some View {
        HStack(spacing:15){
            if chat.isGroup == false && chat.opponentDetails?.userId == nil && chat.opponentDetails?.userName == nil{
                BroadCastAvatarView(size: CGSize(width: 54, height: 54), broadCastImageSize: CGSize(width: 24, height: 24),broadCastLogo: appearance.images.broadCastLogo)
            }else{
                if chat.opponentDetails?.metaData?.userType == 9 && appearance.images.defaultImagePlaceholderForBussinessUser != nil, let avatar =  chat.opponentDetails?.userProfileImageUrl, ISMChatHelper.shouldShowPlaceholder(avatar: avatar) {
                    appearance.images.defaultImagePlaceholderForBussinessUser?
                    .resizable()
                    .frame(width: 54, height: 54, alignment: .center)
                    .cornerRadius(54/2)
                }else if chat.opponentDetails?.metaData?.userType == 1 && appearance.images.defaultImagePlaceholderForNormalUser != nil , let avatar =  chat.opponentDetails?.userProfileImageUrl, ISMChatHelper.shouldShowPlaceholder(avatar: avatar){
                    appearance.images.defaultImagePlaceholderForNormalUser?
                    .resizable()
                    .frame(width: 54, height: 54, alignment: .center)
                    .cornerRadius(54/2)
                }else{
                    UserAvatarView(
                        avatar: chat.isGroup == true ? (chat.conversationImageUrl ) : (chat.opponentDetails?.userProfileImageUrl ?? ""),
                        showOnlineIndicator: false,
                        size: CGSize(width: 54, height: 54),
                        userName: chat.isGroup == true ? chat.conversationTitle  : chat.opponentDetails?.userName ?? "",
                        font: appearance.fonts.messageListMessageText)
                    .overlay(
                        ISMChatSdkUI.getInstance().getChatProperties().otherConversationList == true ?
                        
                        userTypeImageView(userType: chat.opponentDetails?.metaData?.userType ?? 0, isStarUser: chat.opponentDetails?.metaData?.isStarUser ?? false)
                        
                        : nil
                    )
                }
            }
            VStack(alignment: .leading, spacing: 5, content: {
                HStack{
                    if chat.isGroup == false && chat.opponentDetails?.userId == nil && chat.opponentDetails?.userName == nil{
                        Text("Recipients: \(chat.membersCount)")
                            .foregroundColor(appearance.colorPalette.chatListUserName)
                            .font(appearance.fonts.chatListUserName)
                    }else{
                        HStack(spacing: 5){
                            Text(chat.isGroup == true ? (chat.conversationTitle ) : (chat.opponentDetails?.userName?.capitalizingFirstLetter() ?? ""))
                                .foregroundColor(appearance.colorPalette.chatListUserName)
                                .font(appearance.fonts.chatListUserName)
                            if ISMChatSdkUI.getInstance().getChatProperties().showUserTypeInConversationListAfterName{
                                if chat.opponentDetails?.metaData?.userTypeString == "Owner"{
                                    Text("🛒")
                                        .foregroundColor(appearance.colorPalette.chatListUserName)
                                        .font(appearance.fonts.chatListUserName)
                                }
                            }
                        }
                    }
                    Spacer()
                    let dateVar = NSDate()
                    let date = dateVar.descriptiveString(time: (chat.lastMessageDetails?.sentAt ?? 0), dateFormat: appearance.dateFormats.conversationListLastMessageDate)
                    Text(date)
                        .foregroundColor(appearance.colorPalette.chatListLastMessageTime)
                        .font(appearance.fonts.chatListLastMessageTime)
                }//:HStack
                getMessageText()
            })//:VStack
        }//:HStack
        .frame(maxHeight: 60)
    }//:Body
    
    
    /// Generates the appropriate message preview text based on message type and status
    func getMessageText() -> some View {
        HStack {
            if chat.typing == true{
                Text("Typing...".localized())
                    .foregroundColor(appearance.colorPalette.chatListUserMessage)
                    .font(appearance.fonts.chatListUserMessage)
                
                let count = chat.unreadMessagesCount
                if count > 0{
                    Spacer()
                    Text("\(count)")
                        .foregroundColor(appearance.colorPalette.chatListUnreadMessageCount)
                        .font(appearance.fonts.chatListUnreadMessageCount)
                        .padding(7)
                        .background(appearance.colorPalette.chatListUnreadMessageCountBackground)
                        .frame(height: 20)
                        .cornerRadius(10)
                }
                
            }else{
                if chat.lastMessageDetails?.deletedMessage == true{
                    HStack{
                        Image(systemName: "minus.circle")
                            .resizable()
                            .frame(width: 15, height: 15, alignment: .center)
                            .tint(appearance.colorPalette.chatListUserMessage)
                            .foregroundColor(appearance.colorPalette.chatListUserMessage)
                        
                        Text(chat.lastMessageDetails?.senderId == userData?.userId ? "You deleted this message.".localized() : "This message was deleted".localized())
                            .foregroundColor(appearance.colorPalette.chatListUserMessage)
                            .font(appearance.fonts.chatListUserMessage)
                            .padding(.trailing, 40)
                            .lineLimit(1)
                    }
                }else{
                    if let customType = chat.lastMessageDetails?.customType {
                        switch customType {
                        case ISMChatMediaType.Image.value:
                            getLabel(text: "Image".localized(), image: "camera.fill")
                        case ISMChatMediaType.Video.value:
                            getLabel(text: "Video".localized(), image: "video.fill")
                        case ISMChatMediaType.File.value:
                            getLabel(text: "Document".localized(), image: "doc.fill")
                        case ISMChatMediaType.Voice.value:
                            getLabel(text: "Audio".localized(), image: "mic.fill")
                        case ISMChatMediaType.Location.value:
                            getLabel(text: "Location".localized(), image: "location.fill")
                        case ISMChatMediaType.Contact.value:
                            getLabel(text: "Contact".localized(), image: "person.crop.circle.fill")
                        case ISMChatMediaType.sticker.value:
                            getLabel(text: "Sticker".localized(), image: "",isSticker: true)
                        case ISMChatMediaType.gif.value:
                            getLabel(text: "Gif".localized(), image: "",isSticker: true)
                        case ISMChatMediaType.AudioCall.value:
                            AudioCallUI()
                        case ISMChatMediaType.VideoCall.value:
                            VideoCallUI()
                        case ISMChatMediaType.PaymentRequest.value:
                            PaymentRequestUI()
                        case ISMChatMediaType.DineInInvite.value:
                            let sentAtSeconds = (chat.lastMessageDetails?.sentAt ?? 0) / 1000.0
                            let expirationTimestamp = sentAtSeconds + Double((chat.lastMessageDetails?.metaData?.requestAPaymentExpiryTime ?? 0) * 60) // expireAt is in minutes
                            let currentTimestamp = Date().timeIntervalSince1970

                            // Check if the current time exceeds the expiration timestamp
                            if currentTimestamp >= expirationTimestamp {
                                getLabel(hideImage: true,text: "Dine-in invite expired".localized(), image: "")
                            } else {
                                if chat.lastMessageDetails?.senderId ?? chat.lastMessageDetails?.userId == userData?.userId{
                                    getLabel(hideImage: true,text: "You sent a dine-in invite".localized(), image: "")
                                }else{
                                    getLabel(hideImage: true,text: "invited you for dine-in".localized(), image: "")
                                }
                            }
                            
                        case ISMChatMediaType.DineInStatus.value:
                            
                            if let status = chat.lastMessageDetails?.metaData?.inviteMembers.first?.status{
                                dineInPaymentStatus(status: status)
                            }else if let status = chat.lastMessageDetails?.metaData?.paymentRequestedMembers.first?.status{
                                dineInPaymentStatus(status: status)
                            }else if let status = chat.lastMessageDetails?.metaData?.status{
                                dineInPaymentStatus(status: status)
                            }else {
                                actionLabels()
                            }
                        default:
                            actionLabels()
                        }
                    }else{
                        if chat.lastMessageDetails?.metaData?.paymentRequestId != nil{
                            PaymentRequestUI()
                        }else if chat.lastMessageDetails?.metaData?.paymentRequestId != nil{
                            PaymentRequestUI()
                        }
                        else{
                            actionLabels()
                        }
                    }
                }
            }
        }
    }
    
    func dineInPaymentStatus(status:Int) -> some View {
        if chat.lastMessageDetails?.senderId ?? chat.lastMessageDetails?.userId == userData?.userId {
            if status == 1 {
                return AnyView(getLabel(hideImage: true,text: "You accepted dine-in invite".localized(), image: ""))
            }else if status == 2 {
                return AnyView(getLabel(hideImage: true,text: "You declined dine-in invite".localized(), image: ""))
            }else if status == 3 {
                return AnyView(getLabel(hideImage: true,text: "Dine-in invite expired".localized(), image: ""))
            }else if status == 4 {
                return AnyView(getLabel(hideImage: true,text: "You cancelled the dine-in invite".localized(), image: ""))
            }else{
                return AnyView(Text(""))
            }
        }else{
            if status == 1 {
                return AnyView(getLabel(hideImage: true,text: "Dine-in invite accepted".localized(), image: ""))
            }else if status == 2 {
                return AnyView(getLabel(hideImage: true,text: "Dine-in invite declined".localized(), image: ""))
            }else if status == 3 {
                return AnyView(getLabel(hideImage: true,text: "Dine-in invite expired".localized(), image: ""))
            }else if status == 4 {
                return AnyView(getLabel(hideImage: true,text: "Dine-in invite cancelled".localized(), image: ""))
            }else{
                return AnyView(Text(""))
            }
        }
    }
    
    /// Generates UI for payment request messages with status indicators
    func PaymentRequestUI() -> some View{
        let text = getPaymentRequestText()
        return HStack(alignment: .top,spacing: 5){
            if chat.isGroup == false{
                if chat.lastMessageDetails?.senderId ?? chat.lastMessageDetails?.userId == userData?.userId{
                    messageDeliveryStatus()
                        .padding(.top,3)
                }
            }
            Text(text)
                .foregroundColor(appearance.colorPalette.chatListUserMessage)
                .font(appearance.fonts.chatListUserMessage)
                .padding(.trailing, 40)
                .lineLimit(2)
            //UNREAD MESSAGE COUNT
            if chat.lastMessageDetails?.customType == ISMChatMediaType.PaymentRequest.value && ISMChatHelper.getPaymentStatus(myUserId: userData?.userId ?? "", opponentId: chat.opponentDetails?.userId ?? "", metaData: self.chat.lastMessageDetails?.metaData, sentAt: self.chat.lastMessageDetails?.sentAt ?? 0) == .ActiveRequest{
                Spacer()
                
                if chat.lastMessageDetails?.senderId ?? chat.lastMessageDetails?.userId != userData?.userId{
                    Text("Pay Now")
                        .foregroundColor(appearance.colorPalette.chatListUnreadMessageCount)
                        .font(appearance.fonts.chatListUnreadMessageCount)
                        .frame(width: 68, height: 22)
                        .background(appearance.colorPalette.chatListUnreadMessageCountBackground)
                        .cornerRadius(11)
                }
                
            }else{
                let count = chat.unreadMessagesCount
                if count > 0{
                    Spacer()
                    let textWidth = "\(chat.unreadMessagesCount)".widthOfString(usingFont: UIFont.regular(size: 12))
                    let circleSize = max(20, textWidth + 14)
                    
                    Text("\(count)")
                        .foregroundColor(appearance.colorPalette.chatListUnreadMessageCount)
                        .font(appearance.fonts.chatListUnreadMessageCount)
                        .padding(7)
                        .frame(width: circleSize, height: circleSize)
                        .background(
                            Circle()
                                .fill(appearance.colorPalette.chatListUnreadMessageCountBackground)
                        )
                }
            }
        }
    }
    
    /// Displays video call status with appropriate icons and text
    func VideoCallUI() -> some View{
        HStack{
            if chat.lastMessageDetails?.action == ISMChatActionType.meetingCreated.value{
                if chat.lastMessageDetails?.initiatorId == userData?.userId{
                    callKitText(text1: "Video Call", text2: "In call", color: Color.green, outgoing: true, missedCall: false, addDot: true, image: "arrow.up.right.video.fill")
                }else{
                    callKitText(text1: "Video Call", text2: "Ringing", color: Color.green, outgoing: false, missedCall: false, addDot: true, image: "arrow.down.left.video.fill")
                }
            }
            else if chat.lastMessageDetails?.action == ISMChatActionType.meetingEndedDueToNoUserPublishing.value{
                if chat.lastMessageDetails?.initiatorId == userData?.userId{
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
                if chat.lastMessageDetails?.initiatorId == userData?.userId{
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
    
    /// Displays audio call status with appropriate icons and text
    func AudioCallUI() -> some View{
        HStack{
            if chat.lastMessageDetails?.action == ISMChatActionType.meetingCreated.value{
                if chat.lastMessageDetails?.initiatorId == userData?.userId{
                    callKitText(text1: "Voice Call", text2: "In call", color: Color.green, outgoing: true, missedCall: false, addDot: true, image: "phone.arrow.up.right.fill")
                }else{
                    callKitText(text1: "Voice Call", text2: "Ringing", color: Color.green, outgoing: false, missedCall: false, addDot: true, image: "phone.arrow.down.left.fill")
                }
            }
            else if chat.lastMessageDetails?.action == ISMChatActionType.meetingEndedDueToNoUserPublishing.value{
                if chat.lastMessageDetails?.initiatorId == userData?.userId{
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
                if chat.lastMessageDetails?.initiatorId == userData?.userId{
                    callKitText(text1: "", text2: "Voice call", color: Color.green, outgoing: true, missedCall: false, addDot: false, image: "phone.arrow.up.right.fill")
                }else{
                    if chat.lastMessageDetails?.missedByMembers.count == 0{
                        callKitText(text1: "", text2: "Voice call", color: Color.green, outgoing: false, missedCall: false, addDot: false, image: "phone.arrow.up.right.fill")
                    }else{
                        callKitText(text1: "", text2: "Missed voice call".localized(), color: Color.green, outgoing: false, missedCall: true, addDot: false, image: "phone.arrow.down.left.fill")
                    }
                }
            }
        }
    }
    
    /// Handles display of various chat action messages (group changes, reactions etc)
    func actionLabels() -> some View{
        HStack {
            if chat.lastMessageDetails?.action == ISMChatActionType.conversationCreated.value{
                getLabel(text: "Conversation created".localized(), image: "person.fill")
            }else if chat.lastMessageDetails?.action == ISMChatActionType.userBlock.value || chat.lastMessageDetails?.action == ISMChatActionType.userBlockConversation.value{
                if ISMChatSdkUI.getInstance().getChatProperties().dontShowBlockedStatusinConversationList == true{
                    Text("")
                }else{
                    getLabel(text: "Blocked".localized(), image: "circle.slash")
                }
            }else if chat.lastMessageDetails?.action == ISMChatActionType.userUnblock.value || chat.lastMessageDetails?.action == ISMChatActionType.userUnblockConversation.value{
                if ISMChatSdkUI.getInstance().getChatProperties().dontShowBlockedStatusinConversationList == true{
                    Text("")
                }else{
                    getLabel(text: "Unblocked".localized(), image: "circle.slash")
                }
            }else if chat.lastMessageDetails?.action == ISMChatActionType.reactionAdd.value{
                let emoji = ISMChatHelper.getEmoji(valueString: chat.lastMessageDetails?.reactionType ?? "")
                if chat.lastMessageDetails?.userId == userData?.userId{
                    getLabel(hideImage: true,text: chat.isGroup ? "Reacted \(emoji) to a message" : "You reacted \(emoji) to a message", image: "",isReaction : true)
                }else{
                    getLabel(hideImage: true,text: chat.isGroup ? "Reacted \(emoji) to a message" : "\(chat.lastMessageDetails?.userName ?? "") reacted \(emoji) to a message", image: "",isReaction : true)
                }
            }else if chat.lastMessageDetails?.action == ISMChatActionType.reactionRemove.value{
                let emoji = ISMChatHelper.getEmoji(valueString: chat.lastMessageDetails?.reactionType ?? "")
                if chat.lastMessageDetails?.userId == userData?.userId{
                    getLabel(hideImage: true,text: chat.isGroup ? "Removed \(emoji) from a message" : "You removed \(emoji) from a message", image: "",isReaction : true)
                }else{
                    getLabel(hideImage: true,text: chat.isGroup ? "Removed \(emoji) from a message" : "\(chat.lastMessageDetails?.userName ?? "") removed \(emoji) from a message", image: "",isReaction : true)
                }
            }
            else if chat.lastMessageDetails?.action == ISMChatActionType.memberLeave.value{
                getLabel(hideImage: false,text: "\(chat.lastMessageDetails?.memberName.capitalizingFirstLetter() ?? "") left", image: "figure.walk",isReaction : true)
            }
            else if chat.lastMessageDetails?.action == ISMChatActionType.addAdmin.value{
                if chat.lastMessageDetails?.memberId == userData?.userId{
                    getLabel(hideImage: true,text: "Added you as an admin".localized(), image: "",isReaction : true)
                }else{
                    getLabel(hideImage: true,text: "Added \(chat.lastMessageDetails?.memberName ?? "") as an admin", image: "",isReaction : true)
                }
            }else if chat.lastMessageDetails?.action == ISMChatActionType.removeAdmin.value{
                if chat.lastMessageDetails?.memberId == userData?.userId{
                    getLabel(hideImage: true,text: "Removed you as an admin".localized(), image: "",isReaction : true)
                }else{
                    getLabel(hideImage: true,text: "Removed \(chat.lastMessageDetails?.memberName ?? "") as an admin", image: "",isReaction : true)
                }
            }else if chat.lastMessageDetails?.action == ISMChatActionType.membersRemove.value{
                if chat.lastMessageDetails?.members.first?.memberId == userData?.userId{
                    getLabel(hideImage: true,text: "Removed you".localized(), image: "",isReaction : true)
                }else{
                    getLabel(hideImage: true,text: "Removed \(chat.lastMessageDetails?.members.first?.memberName?.capitalizingFirstLetter() ?? "")", image: "",isReaction : true)
                }
            }else if chat.lastMessageDetails?.action == ISMChatActionType.membersAdd.value{
                if chat.lastMessageDetails?.members.first?.memberId == userData?.userId{
                    getLabel(hideImage: true,text: "Added you".localized(), image: "",isReaction : true)
                }else{
                    getLabel(hideImage: true,text: "Added \(chat.lastMessageDetails?.members.first?.memberName ?? "")", image: "",isReaction : true)
                }
            }else if chat.lastMessageDetails?.action == ISMChatActionType.conversationTitleUpdated.value{
                getLabel(hideImage: true,text: "Changed this group title".localized(), image: "",isReaction : true)
            }
            else if chat.lastMessageDetails?.action == ISMChatActionType.clearConversation.value{
                getLabel(hideImage: true,text: "", image: "",isReaction : true)
            }
            else if chat.lastMessageDetails?.action == ISMChatActionType.conversationImageUpdated.value{
                getLabel(hideImage: true,text: "Changed this group image".localized(), image: "",isReaction : true)
            }else if chat.lastMessageDetails?.action == ISMChatActionType.messageDetailsUpdated.value{
                if let body = chat.lastMessageDetails?.body {
                    getLabel(hideImage: true, text: body, image: "")
                }else{
                    if let status = chat.lastMessageDetails?.metaData?.inviteMembers.first?.status{
                        dineInPaymentStatus(status: status)
                    }else if let status = chat.lastMessageDetails?.metaData?.paymentRequestedMembers.first?.status{
                        dineInPaymentStatus(status: status)
                    }else if let status = chat.lastMessageDetails?.metaData?.status{
                        dineInPaymentStatus(status: status)
                    }
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
    
    /// Generates call-related status text with icons
    /// - Parameters:
    ///   - text1: Primary text (e.g. "Video Call")
    ///   - text2: Secondary text (e.g. "In call")
    ///   - color: Text color
    ///   - outgoing: If call is outgoing
    ///   - missedCall: If call was missed
    ///   - addDot: Show separator dot
    ///   - image: System image name for icon
    func callKitText(text1 : String,text2 : String,color : Color,outgoing : Bool,missedCall : Bool,addDot : Bool,image : String) -> some View{
        HStack(alignment: .center,spacing: 5){
            
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 19, height: 11)
                .tint(missedCall ? Color.red : appearance.colorPalette.chatListUserMessage)
                .foregroundColor(appearance.colorPalette.chatListUserMessage)
            
            HStack(alignment: .center,spacing: 2){
                Text(text1)
                    .foregroundColor(color)
                    .font(appearance.fonts.chatListUserMessage)
                    .lineLimit(1)
                
                if addDot == true{
                    Text(".")
                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                        .font(appearance.fonts.chatListUserMessage)
                        .lineLimit(1)
                }
                
                Text(text2)
                    .foregroundColor(appearance.colorPalette.chatListUserMessage)
                    .font(appearance.fonts.chatListUserMessage)
                    .padding(.trailing, 40)
                    .lineLimit(1)
            }
            
            //UNREAD MESSAGE COUNT
            let count = chat.unreadMessagesCount
            if count > 0{
                Spacer()
                Text("\(count)")
                    .foregroundColor(appearance.colorPalette.chatListUnreadMessageCount)
                    .font(appearance.fonts.chatListUnreadMessageCount)
                    .padding(7)
                    .background(appearance.colorPalette.chatListUnreadMessageCountBackground)
                    .frame(height: 20)
                    .cornerRadius(10)
            }
        }
    }
    
    /// Gets the appropriate payment request status text
    func getPaymentRequestText() -> String{
        let metaData = self.chat.lastMessageDetails?.metaData
        let status = ISMChatHelper.getPaymentStatus(myUserId: userData?.userId ?? "", opponentId: chat.opponentDetails?.userId ?? "",metaData: metaData, sentAt: self.chat.lastMessageDetails?.sentAt ?? 0)
        let amount = "\(metaData?.currencyCode ?? "") \(metaData?.amount?.rounded(to: 2) ?? 0)"
        if status == .ActiveRequest {
            if chat.lastMessageDetails?.senderId ?? chat.lastMessageDetails?.userId == userData?.userId{
                return "Payment request sent"
            }else{
                return "sent you a payment request of \(amount)"
            }
        } else if status == .Rejected {
            if let otherUserName = self.chat.lastMessageDetails?.metaData?.paymentRequestedMembers.first(where: { $0.userId == userData?.userId && $0.status == 2 }) {
                return "You declined payment request"
            }else{
                return "payment request declined"
            }
        } else if status == .Expired {
            return "Request expired - \(amount)"
        }else if status == .Cancelled {
            if chat.lastMessageDetails?.senderId ?? chat.lastMessageDetails?.userId == userData?.userId{
                return "You cancelled payment request"
            }else{
                return "Request cancelled"
            }
        }else if status == .Accepted{
            return "You paid \(amount)"
        }else if status == .PayedByOther{
            return "Paid \(amount)"
        }
        return ""
    }
    
    /// Generates label for messages with optional image icon
    func getLabel(hideImage : Bool? = false, text : String, image : String,isReaction : Bool? = false,isSticker : Bool? = false) -> some View{
        HStack(alignment: .top,spacing: 5){
            
            if chat.isGroup == false{
                if chat.lastMessageDetails?.senderId ?? chat.lastMessageDetails?.userId == userData?.userId{
                    if isReaction == false{
                        messageDeliveryStatus()
                            .padding(.top,3)
                    }
                }
            }
            
            if chat.isGroup == true{
                 getSenderNameText()
            }
            
            if hideImage == false{
                if isSticker == true{
                    appearance.images.stickerLogo
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 19, height: 11)
                }else{
                    Image(systemName: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 19, height: 11)
                        .tint(appearance.colorPalette.chatListUserMessage)
                        .foregroundColor(appearance.colorPalette.chatListUserMessage)
                }
            }
            
            if  ISMChatHelper.isValidPhone(phone: text) == true && ISMChatSdkUI.getInstance().getChatProperties().maskNumberAndEmail == true{
                let maskedPhoneNumber = String(repeating: "*", count: text.trimmingCharacters(in: .whitespacesAndNewlines).count)
                Text(maskedPhoneNumber)
                    .foregroundColor(appearance.colorPalette.chatListUserMessage)
                    .font(appearance.fonts.chatListUserMessage)
                    .padding(.trailing, 40)
                    .lineLimit(2)
            }else if ISMChatHelper.isValidEmail(text) == true && ISMChatSdkUI.getInstance().getChatProperties().maskNumberAndEmail == true{
                let maskedEmail = String(repeating: "@", count: text.trimmingCharacters(in: .whitespacesAndNewlines).count)
                Text(maskedEmail)
                    .foregroundColor(appearance.colorPalette.chatListUserMessage)
                    .font(appearance.fonts.chatListUserMessage)
                    .padding(.trailing, 40)
                    .lineLimit(2)
            }else{
                Text(text)
                    .foregroundColor(appearance.colorPalette.chatListUserMessage)
                    .font(appearance.fonts.chatListUserMessage)
                    .padding(.trailing, 40)
                    .lineLimit(2)
            }
            
            
            
            //UNREAD MESSAGE COUNT
            let count = chat.unreadMessagesCount
            if count > 0{
                Spacer()
                let textWidth = "\(chat.unreadMessagesCount)".widthOfString(usingFont: UIFont.regular(size: 12))
                let circleSize = max(20, textWidth + 14)

                Text("\(count)")
                    .foregroundColor(appearance.colorPalette.chatListUnreadMessageCount)
                    .font(appearance.fonts.chatListUnreadMessageCount)
                    .padding(7)
                    .frame(width: circleSize, height: circleSize)
                    .background(
                        Circle()
                            .fill(appearance.colorPalette.chatListUnreadMessageCountBackground)
                    )
            }
        }
    }
    /// Shows message delivery status indicators (sent/delivered/read)
    /// If its not group, then we check 'DeliveredTo' count should be one and 'DeliveredTo' should contain userId, same we will check for read
    func messageDeliveryStatus() -> some View {
        if chat.isGroup == false{
            if (chat.lastMessageDetails?.deliveredTo.count == 1 && chat.lastMessageDetails?.deliveredTo.first?.userId != nil) && (chat.lastMessageDetails?.readBy.count == 1 && chat.lastMessageDetails?.readBy.first?.userId != nil) {
                return AnyView(appearance.images.chatList_messageRead
                    .resizable()
                    .frame(width: appearance.imagesSize.messageRead.width, height: appearance.imagesSize.messageRead.height))
            }else if (chat.lastMessageDetails?.deliveredTo.count == 1 && chat.lastMessageDetails?.deliveredTo.first?.userId != nil) && chat.lastMessageDetails?.readBy.count == 0{
                return AnyView(appearance.images.chatList_messageDelivered
                    .resizable()
                    .frame(width: appearance.imagesSize.messageDelivered.width, height: appearance.imagesSize.messageDelivered.height))
            }else{
                if chat.lastMessageDetails?.msgSyncStatus == ISMChatSyncStatus.Local.txt {
                    return AnyView(appearance.images.chatList_messagePending
                        .resizable()
                        .frame(width: appearance.imagesSize.messagePending.width, height: appearance.imagesSize.messagePending.height))
                }
                return AnyView(appearance.images.chatList_messageSent
                    .resizable()
                    .frame(width: appearance.imagesSize.messageSend.width, height: appearance.imagesSize.messageSend.height))
            }
        }else{
            //write code for group after grp implementations
            return AnyView(EmptyView())
        }
    }
    /// Gets the sender name text for group chats
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
        
            let prefix = senderId == userData?.userId ? "You:" : "\(senderName):"
            
            return AnyView(
                Text(prefix)
                    .foregroundColor(appearance.colorPalette.chatListUserMessage)
                    .font(appearance.fonts.chatListUserMessage)
                    .lineLimit(1)
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    /// Shows user type indicator icon (business/influencer)
    func userTypeImageView(userType : Int,isStarUser : Bool) -> some View{
        VStack{
            if userType == 1 && isStarUser == true{
                appearance.images.influencerUserIcon
                    .resizable()
                    .frame(width: 16, height: 16)
                    .background(Color.white)
                    .clipShape(Circle())
                    .offset(x: 54 * 0.35, y: 54 * 0.35)
            }else if userType == 9{
                appearance.images.businessUserIcon
                    .resizable()
                    .frame(width: 16, height: 16)
                    .background(Color.white)
                    .clipShape(Circle())
                    .offset(x: 54 * 0.35, y: 54 * 0.35)
            }else{
                
            }
        }
    }
}

