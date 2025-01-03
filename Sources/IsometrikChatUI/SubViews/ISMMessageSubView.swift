//
//  ISMMessageRow.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 09/03/23.
//
enum SwipeHVDirection: String {
    case left, right, up, down, none
}


import SwiftUI
import LinkPresentation
import AVKit
import GoogleMaps
import CoreLocation
import MapKit
import SDWebImageSwiftUI
import IsometrikChat

struct ISMMessageSubView: View {
    
    //MARK:  - PROPERTIES
    
    var messageType : ISMChatMessageType
//    var userId : String?
    var viewWidth : CGFloat
    var isReceived: Bool
    var messageDeliveredType : ISMChatMessageStatus = .Clock
    let conversationId : String
    let groupconversationMember : [ISMChatGroupMember]
    let opponentDeatil : ISMChatUser
    let pasteboard = UIPasteboard.general
    var isGroup : Bool?
    let fromBroadCastFlow : Bool?
    
   
    @Binding var navigateToDeletePopUp : Bool
    @Binding var selectedMessageToReply : MessagesDB
    @Binding var messageCopied : Bool
    @Binding var previousAudioRef: AudioPlayViewModel?
    @Binding var updateMessage : MessagesDB
    @Binding var showForward : Bool
    @Binding var navigateToLocationDetail : ISMChatLocationData
    @Binding var selectedReaction : String?
    @Binding var sentRecationToMessageId : String
    @Binding var audioCallToUser : Bool
    @Binding var videoCallToUser : Bool
    @Binding var parentMsgToScroll : MessagesDB?
    @Binding var navigateToMediaSliderId : String
    @Binding var navigateToDocumentUrl : String
    @Binding var deleteMessage : [MessagesDB]
    
    
    
    @State var navigateToInfo : Bool = false
    @State var navigatetoUser : ISMChatGroupMember = ISMChatGroupMember()
    @State var navigatetoMessageInfo =  false
    @State var showMessageInfoInsideMessage : Bool = false
    @State var navigateToForwardList = false
    @State var navigateToAddMember = false
    @State var offset = CGSize.zero
//    @State var metaData : LPLinkMetadata? = nil
    @State var message : MessagesDB
    @State var pdfthumbnailImage : UIImage = UIImage()
    @State var showReplyOption = ISMChatSdkUI.getInstance().getChatProperties().features.contains(.reply)
    @State var showForwardOption = ISMChatSdkUI.getInstance().getChatProperties().features.contains(.forward)
    @State var showEditOption = ISMChatSdkUI.getInstance().getChatProperties().features.contains(.edit)
    @State var showReactionsDetail : Bool = false
    @State var settingsDetent = PresentationDetent.medium
    @State var reactionRemoved : String = ""
    @State var isAnimating = false
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    let customFontName = ISMChatSdkUI.getInstance().getCustomFontNames()
    var userData = ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig
    
   
    @EnvironmentObject var realmManager : RealmManager
    @ObservedObject var viewModel = ChatsViewModel()
    @Environment(\.viewController) public var viewControllerHolder: UIViewController?
    @Binding var postIdToNavigate : String
    @Binding var productIdToNavigate : ProductDB
    
    @Binding var navigateToSocialProfileId : String
    @Binding var navigateToExternalUserListToAddInGroup : Bool
    @Binding var navigateToProductLink : MessagesDB
    @Binding var navigateToSocialLink : MessagesDB
    @Binding var navigateToCollectionLink : MessagesDB
    //payment
    @Binding var viewDetailsForPaymentRequest : MessagesDB
    @Binding var declinePaymentRequest : MessagesDB
    
    
    //MARK:  - BODY
    var body: some View {
        VStack(alignment: isReceived == true ? .leading : .trailing, spacing: 2){
            if message.deletedMessage == true{
                ZStack{
                    VStack(alignment: isReceived == true ? .leading : .trailing, spacing: 2){
                        HStack{
                            appearance.images.deletedMessageLogo
                                .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                .frame(width: appearance.imagesSize.deletedMessageLogo.width, height: appearance.imagesSize.deletedMessageLogo.height, alignment: .center)
                            Text(isReceived == true ? appearance.constantStrings.messageDeletedByOther :  appearance.constantStrings.messageDeletedByMe)
                                .lineSpacing(8)
                                .tracking(-0.5 / 1000)
                                .font(appearance.fonts.messageListMessageDeleted)
                                .italic()
                                .foregroundColor(appearance.colorPalette.messageListMessageDeleted)
                        }
                        .opacity(0.7)
                        dateAndStatusView(onImage: false)
                    }//:VStack
                    .padding(8)
                    .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                    .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topRight] : [.topLeft,.topRight,.bottomRight]) : (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topLeft] : [.topLeft,.topRight,.bottomLeft]), bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                    .overlay(
                        appearance.messageBubbleType == .BubbleWithOutTail ?
                        AnyView(
                            UnevenRoundedRectangle(
                                topLeadingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 0 : 8) : 8,
                                bottomLeadingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 0 : 8) : 8,
                                bottomTrailingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 8 : 0) : 8,
                                topTrailingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 8 : 0) : 8,
                                style: .circular
                            )
                            .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                        ) : AnyView(EmptyView())
                    )
                }//:ZStack
                .padding(.vertical,2)
            }else{
                HStack{
                switch messageType {
                    
                    //MARK: - Text Message View
                case .text:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                            //When its group show member avatar in message
                            inGroupUserAvatarView()
                        }
                        ZStack(alignment: .bottomTrailing){
                            let str = message.body
                            VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                                if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                VStack(alignment: .trailing, spacing: 0){
                                    if message.customType == ISMChatMediaType.ReplyText.value && message.messageType != 1{
                                        repliedMessageView()
                                            .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: isReceived ? 0 : 5))
                                            .onTapGesture {
                                                parentMsgToScroll = message
                                            }
                                    }
                                    if message.messageType == 1{
                                        forwardedView()
                                    }
                                    if message.messageUpdated == true && !str.isValidURL{
                                        editedView()
                                    }
                                    VStack(alignment: (str.count < 7 && message.customType != ISMChatMediaType.ReplyText.value)  ? .leading : .trailing, spacing: 5){
                                        HStack{
                                            if ISMChatHelper.isValidEmail(str) == true{
                                                if ISMChatSdkUI.getInstance().getChatProperties().maskNumberAndEmail == true{
                                                    let maskedEmail = String(repeating: "@", count: str.trimmingCharacters(in: .whitespacesAndNewlines).count)
                                                    Text(maskedEmail)
                                                        .font(appearance.fonts.messageListMessageText)
                                                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                }else{
                                                    Link(destination: URL(string: "mailto:apple@me.com")!, label: {
                                                        Text(str)
                                                            .font(appearance.fonts.messageListMessageText)
                                                            .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                            .underline(true, color: isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                    })
                                                }
                                            }else if  ISMChatHelper.isValidPhone(phone: str) == true{
                                                if ISMChatSdkUI.getInstance().getChatProperties().maskNumberAndEmail == true{
                                                    let maskedPhoneNumber = String(repeating: "*", count: str.trimmingCharacters(in: .whitespacesAndNewlines).count)
                                                    Text(maskedPhoneNumber)
                                                        .font(appearance.fonts.messageListMessageText)
                                                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                    
                                                }else{
                                                    Link(destination: URL(string: "tel:\(str)")!, label: {
                                                        Text(str)
                                                            .font(appearance.fonts.messageListMessageText)
                                                            .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                            .underline(true, color: isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                    })
                                                }
                                            }
                                            else if str.isValidURL{
                                                if ISMChatSdkUI.getInstance().getChatProperties().hideLinkPreview == false{
                                                    if str.contains("https"){
                                                        ISMLinkPreview(url: URL(string: "\(str)")!, isRecived: self.isReceived)
                                                            .frame(width: 280)
                                                            .onTapGesture {
                                                                if str.contains("https"){
                                                                    openURLInSafari(urlString: str)
                                                                }else{
                                                                    let fullURLString = "https://" + str.trimmingCharacters(in: .whitespaces)
                                                                    openURLInSafari(urlString: fullURLString)
                                                                }
                                                            }
                                                    }else{
                                                        let URLString = "https://" + str.trimmingCharacters(in: .whitespaces)
                                                        ISMLinkPreview(url: URL(string: "\(URLString)")!, isRecived: self.isReceived)
                                                            .frame(width: 280)
                                                            .onTapGesture {
                                                                if str.contains("https"){
                                                                    openURLInSafari(urlString: str)
                                                                }else{
                                                                    let fullURLString = "https://" + str.trimmingCharacters(in: .whitespaces)
                                                                    openURLInSafari(urlString: fullURLString)
                                                                }
                                                            }
                                                    }
                                                }else{
                                                    productLinkView(message: message)
                                                }
                                            }
                                            else{
                                                if str.contains("@") && isGroup == true{
                                                    HighlightedTextView(originalText: str, mentionedUsers: groupconversationMember, isReceived: self.isReceived, navigateToInfo: $navigateToInfo, navigatetoUser: $navigatetoUser)
                                                }else{
                                                    HStack{
                                                        ISMChatExpandableText(str, lineLimit: 5, isReceived: isReceived)
                                                        if message.customType == ISMChatMediaType.ReplyText.value && message.messageType != 1{
                                                            Spacer()
                                                        }
                                                    }
//                                                    Text(str)
//                                                        .font(appearance.fonts.messageListMessageText)
//                                                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                }
                                            }
                                        }
                                        if appearance.timeInsideBubble == true{
                                            dateAndStatusView(onImage: false)
                                        }
                                    }
                                }//:VStack
                                .padding(.horizontal, str.isValidURL || str.contains("www.") == true ? 5 : 10)
                                .padding(.vertical,str.isValidURL || str.contains("www.") == true ? 5 : 8)
                                .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topRight] : [.topLeft,.topRight,.bottomRight]) : (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topLeft] : [.topLeft,.topRight,.bottomLeft]), bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                .overlay(
                                    appearance.messageBubbleType == .BubbleWithOutTail ?
                                    AnyView(
                                        UnevenRoundedRectangle(
                                            topLeadingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 0 : 8) : 8,
                                            bottomLeadingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 0 : 8) : 8,
                                            bottomTrailingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 8 : 0) : 8,
                                            topTrailingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 8 : 0) : 8,
                                            style: .circular
                                        )
                                        .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                    ) : AnyView(EmptyView())
                                )
                                
                                if appearance.timeInsideBubble == false{
                                    dateAndStatusView(onImage: false)
                                }
                            }
                            if message.reactions.count > 0{
                                reactionsView()
                            }
                        }//:ZStack
                        
                        .padding(.vertical, 2)
                        .frame(maxWidth: 250, alignment: isReceived ? .leading : .trailing)
                        .alignmentGuide(.leading) { _ in // Alignment guide for received messages
                            if isReceived { // Assuming there's a property indicating received/sent messages
                                return -250 // Adjust the value to position the received message
                            } else {
                                return 0 // For sent messages
                            }
                        }
                        .alignmentGuide(.trailing) { _ in // Alignment guide for sent messages
                            if !isReceived {
                                return 250 // Adjust the value to position the sent message
                            } else {
                                return 0 // For received messages
                            }
                        }
                    }
                    .padding(.vertical,2)
                    
                    //MARK: - Contact Message View
                case .contact:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                            //When its group show member avatar in message
                            inGroupUserAvatarView()
                        }
                        ZStack(alignment: .bottomTrailing){
                            VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                                if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                if let metaData = message.metaData{
                                    NavigationLink(destination:  ISMContactDetailView(data : metaData)){
                                        VStack(alignment: .trailing,spacing: 2){
                                            if message.messageType == 1{
                                                forwardedView()
                                            }
                                            HStack(spacing: 10){
                                                if metaData.contacts.count == 1{
                                                    UserAvatarView(avatar: metaData.contacts.first?.contactImageUrl ?? "", showOnlineIndicator: false, userName: metaData.contacts.first?.contactName ?? "")
                                                        .scaledToFill()
                                                        .frame(width: 40, height: 40)
                                                        .cornerRadius(20)
                                                }else if metaData.contacts.count == 2{
                                                    HStack(spacing: -25) { // Negative spacing for overlap
                                                        UserAvatarView(avatar: metaData.contacts.first?.contactImageUrl ?? "", showOnlineIndicator: false, userName: metaData.contacts.first?.contactName ?? "")
                                                            .scaledToFill()
                                                            .frame(width: 40, height: 40)
                                                            .cornerRadius(20)
                                                        
                                                        UserAvatarView(avatar: metaData.contacts.last?.contactImageUrl ?? "", showOnlineIndicator: false, userName: metaData.contacts.last?.contactName ?? "")
                                                            .scaledToFill()
                                                            .frame(width: 40, height: 40)
                                                            .cornerRadius(20)
                                                    }
                                                }else if metaData.contacts.count > 2{
                                                    HStack(spacing: -25) { // Negative spacing for overlap
                                                        UserAvatarView(avatar: metaData.contacts.first?.contactImageUrl ?? "", showOnlineIndicator: false, userName: metaData.contacts.first?.contactName ?? "")
                                                            .scaledToFill()
                                                            .frame(width: 40, height: 40)
                                                            .cornerRadius(20)
                                                        
                                                        UserAvatarView(avatar: metaData.contacts.last?.contactImageUrl ?? "", showOnlineIndicator: false, userName: metaData.contacts.last?.contactName ?? "")
                                                            .scaledToFill()
                                                            .frame(width: 40, height: 40)
                                                            .cornerRadius(20)
                                                        
                                                        UserAvatarView(avatar: metaData.contacts.last?.contactImageUrl ?? "", showOnlineIndicator: false, userName: metaData.contacts.last?.contactName ?? "")
                                                            .scaledToFill()
                                                            .frame(width: 40, height: 40)
                                                            .cornerRadius(20)
                                                    }
                                                }
                                                
                                                
                                                let name = metaData.contacts.first?.contactName ?? ""
                                                if metaData.contacts.count == 1{
                                                    Text(name)
                                                        .multilineTextAlignment(.leading)
                                                        .font(appearance.fonts.contactMessageTitle)
                                                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                }else{
                                                    Text("\(name) and \((metaData.contacts.count) - 1) other contact")
                                                        .multilineTextAlignment(.leading)
                                                        .font(appearance.fonts.contactMessageTitle)
                                                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                }
                                                Spacer()
                                            }.padding(5)
                                            HStack{
                                                Spacer()
                                                if appearance.timeInsideBubble == true{
                                                    dateAndStatusView(onImage: false).padding(.trailing,3)
                                                }
                                            }
                                            Divider().background(Color.docBackground)
                                            HStack{
                                                Spacer()
                                                Text(metaData.contacts.count == 1 ? "View" : "View All")
                                                    .font(appearance.fonts.contactMessageButton)
                                                    .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                Spacer()
                                            }.padding(.vertical,5)
                                        }
                                        .frame(width: 250)
                                        .padding(5)
                                        .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                        .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topRight] : [.topLeft,.topRight,.bottomRight]) : (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topLeft] : [.topLeft,.topRight,.bottomLeft]), bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                        .overlay(
                                            appearance.messageBubbleType == .BubbleWithOutTail ?
                                            AnyView(
                                                UnevenRoundedRectangle(
                                                    topLeadingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 0 : 8) : 8,
                                                    bottomLeadingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 0 : 8) : 8,
                                                    bottomTrailingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 8 : 0) : 8,
                                                    topTrailingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 8 : 0) : 8,
                                                    style: .circular
                                                )
                                                .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                            ) : AnyView(EmptyView())
                                        )
                                    }
                                }
                                if appearance.timeInsideBubble == false{
                                    dateAndStatusView(onImage: false)
                                }
                            }
                            if message.reactions.count > 0{
                                reactionsView()
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    
                    //MARK: - Photo Message View
                case .photo:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                            //When its group show member avatar in message
                            inGroupUserAvatarView()
                        }
                        ZStack(alignment: .bottomTrailing){
                            VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                                if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                
                                //                                NavigationLink(destination:  MediaSliderView(messageId: message.messageId).environmentObject(self.realmManager))
                                //                                {
                                if appearance.messageBubbleType == .BubbleWithTail{
                                    VStack(alignment: .trailing,spacing: 5){
                                        if message.messageType == 1{
                                            forwardedView()
                                        }
                                        
                                        Button {
                                            navigateToMediaSliderId = message.messageId
                                        } label: {
                                            ZStack(alignment: .bottomTrailing){
                                                ISMImageViewer(url: message.attachments.first?.mediaUrl ?? "", size: CGSizeMake(250, 300), cornerRadius: 16)
                                                    .overlay(
                                                        LinearGradient(gradient: Gradient(colors: [.clear,.clear,.clear, Color.black.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                                            .frame(width: 250, height: 300)
                                                            .mask(
                                                                RoundedRectangle(cornerRadius: 16)
                                                                    .fill(Color.white)
                                                            )
                                                    )
                                                
                                            }
                                        }
                                        
                                        dateAndStatusView(onImage: false)
                                            .padding(.bottom,5)
                                            .padding(.trailing,5)
                                    }
                                        
                                }else{
                                    
                                    
                                    VStack(alignment: .trailing,spacing: 5){
                                        if message.messageType == 1{
                                            forwardedView()
                                        }
                                        
                                        Button {
                                            navigateToMediaSliderId = message.messageId
                                        } label: {
                                            ZStack(alignment: .bottomTrailing){
                                                ISMImageViewer(url: message.attachments.first?.mediaUrl ?? "", size: CGSizeMake(250, 300), cornerRadius: 5)
                                                    .overlay(
                                                        LinearGradient(gradient: Gradient(colors: [.clear,.clear,.clear, Color.black.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                                            .frame(width: 250, height: 300)
                                                            .mask(
                                                                RoundedRectangle(cornerRadius: 5)
                                                                    .fill(Color.white)
                                                            )
                                                    )
                                                if appearance.timeInsideBubble == true{
                                                    if message.metaData?.captionMessage == nil{
                                                        dateAndStatusView(onImage: true)
                                                            .padding(.bottom,5)
                                                            .padding(.trailing,5)
                                                    }
                                                }
                                            }
                                        }
                                        
                                        
                                        if let caption = message.metaData?.captionMessage, !caption.isEmpty{
                                            Text(caption)
                                                .font(appearance.fonts.messageListMessageText)
                                                .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                            
                                            if appearance.timeInsideBubble == true{
                                                dateAndStatusView(onImage: false)
                                                    .padding(.bottom,5)
                                                    .padding(.trailing,5)
                                            }
                                            
                                        }
                                    }//:ZStack
                                    .padding(5)
                                    .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                    .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topRight] : [.topLeft,.topRight,.bottomRight]) : (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topLeft] : [.topLeft,.topRight,.bottomLeft]), bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                    .overlay(
                                        appearance.messageBubbleType == .BubbleWithOutTail ?
                                        AnyView(
                                            UnevenRoundedRectangle(
                                                topLeadingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 0 : 8) : 8,
                                                bottomLeadingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 0 : 8) : 8,
                                                bottomTrailingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 8 : 0) : 8,
                                                topTrailingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 8 : 0) : 8,
                                                style: .circular
                                            )
                                            .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                        ) : AnyView(EmptyView())
                                    )
                                    //                                }
                                    if appearance.timeInsideBubble == false{
                                        dateAndStatusView(onImage: false)
                                            .padding(.bottom,5)
                                            .padding(.trailing,5)
                                    }
                                }
                            }
                            
                            if message.reactions.count > 0{
                                reactionsView()
                            }
                        }.padding(.vertical,2)
                    }
                    
                    //MARK: - Video Message View
                case .video:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                            //When its group show member avatar in message
                            inGroupUserAvatarView()
                        }
                        ZStack(alignment: .bottomTrailing){
                            VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                                if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                
                                
                                //                                NavigationLink(destination: MediaSliderView(messageId: message.messageId).environmentObject(self.realmManager)){
                                VStack(alignment: .trailing,spacing : 5){
                                    if message.messageType == 1{
                                        forwardedView()
                                    }
                                    
                                    Button {
                                        navigateToMediaSliderId = message.messageId
                                    } label: {
                                        ZStack(alignment: .center){
                                            if let thumbnailUrl = message.attachments.first?.thumbnailUrl,
                                               thumbnailUrl.contains(".mp4") {
                                                if let image = ISMChatHelper.getThumbnailImage(url: thumbnailUrl){
                                                    Image(uiImage: image)
                                                        .scaledToFill()
                                                        .frame(width: 250, height: 300)
                                                        .cornerRadius(5)
                                                }else{
                                                    // Display the thumbnail image for non-videos
                                                    ZStack(alignment: .bottomTrailing){
                                                        ISMImageViewer(url:  message.attachments.first?.thumbnailUrl ?? "", size: CGSizeMake(250, 300), cornerRadius: 5)
                                                            .overlay(
                                                                LinearGradient(gradient: Gradient(colors: [.clear,.clear,.clear, Color.black.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                                                    .frame(width: 250, height: 300)
                                                                    .mask(
                                                                        RoundedRectangle(cornerRadius: 5)
                                                                            .fill(Color.white)
                                                                    )
                                                            )
                                                        if message.metaData?.captionMessage == nil{
                                                            dateAndStatusView(onImage: true)
                                                                .padding(.bottom,5)
                                                                .padding(.trailing,5)
                                                        }
                                                    }
                                                }
                                            } else {
                                                // Display the thumbnail image for non-videos
                                                ZStack(alignment: .bottomTrailing){
                                                    ISMImageViewer(url: message.attachments.first?.thumbnailUrl ?? "", size: CGSizeMake(250, 300), cornerRadius: 5)
                                                        .overlay(
                                                            LinearGradient(gradient: Gradient(colors: [.clear,.clear,.clear, Color.black.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                                                .frame(width: 250, height: 300)
                                                                .mask(
                                                                    RoundedRectangle(cornerRadius: 5)
                                                                        .fill(Color.white)
                                                                )
                                                        )
                                                    if appearance.timeInsideBubble == true{
                                                        if message.metaData?.captionMessage == nil{
                                                            dateAndStatusView(onImage: true)
                                                                .padding(.bottom,5)
                                                                .padding(.trailing,5)
                                                        }
                                                    }
                                                }
                                            }
                                            appearance.images.playVideo
                                                .resizable()
                                                .frame(width: 48,height: 48)
                                            
                                        }
                                    }
                                    
                                    
                                    
                                    if let caption = message.metaData?.captionMessage, !caption.isEmpty{
                                        Text(caption)
                                            .font(appearance.fonts.messageListMessageText)
                                            .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                        
                                        if appearance.timeInsideBubble == true{
                                            dateAndStatusView(onImage: false)
                                                .padding(.bottom,5)
                                                .padding(.trailing,5)
                                        }
                                    }
                                    
                                }.padding(5)
                                    .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                    .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topRight] : [.topLeft,.topRight,.bottomRight]) : (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topLeft] : [.topLeft,.topRight,.bottomLeft]), bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                    .overlay(
                                        appearance.messageBubbleType == .BubbleWithOutTail ?
                                        AnyView(
                                            UnevenRoundedRectangle(
                                                topLeadingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 0 : 8) : 8,
                                                bottomLeadingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 0 : 8) : 8,
                                                bottomTrailingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 8 : 0) : 8,
                                                topTrailingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 8 : 0) : 8,
                                                style: .circular
                                            )
                                            .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                        ) : AnyView(EmptyView())
                                    )
                                //                                }//:NavigationLink
                                //                                }
                                if appearance.timeInsideBubble == false{
                                    dateAndStatusView(onImage: false)
                                        .padding(.bottom,5)
                                        .padding(.trailing,5)
                                }
                            }
                            if message.reactions.count > 0{
                                reactionsView()
                            }
                        }.padding(.vertical, 2)
                    }
                    
                    //MARK: - Video Message View
                case .document:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                            //When its group show member avatar in message
                            inGroupUserAvatarView()
                        }
                        ZStack(alignment: .bottomTrailing){
                            VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                                if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                if let documentUrl = URL(string: message.attachments.first?.mediaUrl ?? ""){
                                    let urlExtension = ISMChatHelper.getExtensionFromURL(url: documentUrl)
                                    let fileName = ISMChatHelper.getFileNameFromURL(url: documentUrl)
                                    Button(action: {
                                        navigateToDocumentUrl = message.attachments.first?.mediaUrl ?? ""
                                    }, label: {
                                        ZStack{
                                            VStack(alignment: .trailing, spacing: 5){
                                                if message.messageType == 1{
                                                    forwardedView()
                                                }
                                                
                                                if ISMChatSdkUI.getInstance().getChatProperties().hideDocumentPreview == true{
                                                    HStack{
                                                        appearance.images.pdfLogo
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: appearance.imagesSize.documentIcon.width, height: appearance.imagesSize.documentIcon.height)
                                                        
                                                        Text(fileName)
                                                            .font(appearance.fonts.messageListMessageText)
                                                            .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                            .fixedSize(horizontal: false, vertical: true)
                                                        
                                                        Spacer()
                                                    }.padding(.leading,5).padding(.top,5)
                                                }else{
                                                    HStack(alignment: .center, spacing: 5){
                                                        if let urlExtension = urlExtension{
                                                            if urlExtension.contains(".jpg") ||  urlExtension.contains(".png"){
                                                                ISMImageViewer(url: message.attachments.first?.mediaUrl ?? "", size: CGSizeMake(250, 300), cornerRadius: 5)
                                                                
                                                            }else{
                                                                if urlExtension == "pdf" {
                                                                    ISMPDFMessageView(pdfURL: documentUrl, fileName: fileName)
                                                                } else {
                                                                    appearance.images.pdfLogo
                                                                        .resizable()
                                                                        .aspectRatio(contentMode: .fit)
                                                                        .frame(width: appearance.imagesSize.documentIcon.width, height: appearance.imagesSize.documentIcon.height)
                                                                    
                                                                    Text(fileName)
                                                                        .font(appearance.fonts.messageListMessageText)
                                                                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                                        .fixedSize(horizontal: false, vertical: true)
                                                                    
                                                                    Spacer()
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                if appearance.timeInsideBubble == true{
                                                    dateAndStatusView(onImage: false)
                                                        .padding(.bottom,(message.reactions.count > 0) ? 5 : 0).padding(.trailing,3)
                                                }
                                            }//:VStack
                                            .frame(width: 250)
                                            .padding(5)
                                            .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                            .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topRight] : [.topLeft,.topRight,.bottomRight]) : (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topLeft] : [.topLeft,.topRight,.bottomLeft]), bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                            .overlay(
                                                appearance.messageBubbleType == .BubbleWithOutTail ?
                                                AnyView(
                                                    UnevenRoundedRectangle(
                                                        topLeadingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 0 : 8) : 8,
                                                        bottomLeadingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 0 : 8) : 8,
                                                        bottomTrailingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 8 : 0) : 8,
                                                        topTrailingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 8 : 0) : 8,
                                                        style: .circular
                                                    )
                                                    .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                                ) : AnyView(EmptyView())
                                            )
                                        }//:ZStack
                                    })
                                }
                                if appearance.timeInsideBubble == false{
                                    dateAndStatusView(onImage: false)
                                }
                            }
                            if message.reactions.count > 0{
                                reactionsView()
                            }
                        }.padding(.vertical,2)
                    }
                    
                    //MARK: - Location Message View
                case .location:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                            //When its group show member avatar in message
                            inGroupUserAvatarView()
                        }
                        ZStack(alignment: .bottomTrailing){
                            VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                                if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                ZStack{
                                    VStack(alignment: .trailing, spacing: 5){
                                        if message.messageType == 1{
                                            forwardedView()
                                        }
                                        
                                        Button {
                                            let data = ISMChatLocationData(coordinate:
                                                                            CLLocationCoordinate2D(
                                                                                latitude: message.attachments.first?.latitude ?? 0,
                                                                                longitude: message.attachments.first?.longitude ?? 0),
                                                                           title: message.attachments.first?.title ?? "",
                                                                           completeAddress: message.attachments.first?.address ?? "")
                                            navigateToLocationDetail = data
                                        } label: {
                                            VStack(alignment: .trailing, spacing: 5){
                                                ISMLocationSubView(message: message)
                                                    .cornerRadius(8)
                                                    .contentShape(Rectangle())
                                                    .allowsHitTesting(true)
                                                
                                                HStack{
                                                    Text(message.attachments.first?.title ?? "")
                                                        .font(appearance.fonts.locationMessageTitle)
                                                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                    Spacer()
                                                    
                                                }
                                                HStack{
                                                    Text(message.attachments.first?.address ?? "")
                                                        .multilineTextAlignment(.leading)
                                                        .font(appearance.fonts.locationMessageDescription)
                                                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                    Spacer()
                                                }
                                            }
                                        }
                                        
                                        if appearance.timeInsideBubble == true{
                                            dateAndStatusView(onImage: false)
                                                .padding(.bottom,(message.reactions.count > 0) ? 5 : 0)
                                        }
                                    }//:VStack
                                    .frame(width: 250)
                                    .padding(5)
                                    .padding(.trailing,appearance.messageBubbleType == .BubbleWithTail ? 5 : 0)
                                    .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                    .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topRight] : [.topLeft,.topRight,.bottomRight]) : (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topLeft] : [.topLeft,.topRight,.bottomLeft]), bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                    .overlay(
                                        appearance.messageBubbleType == .BubbleWithOutTail ?
                                        AnyView(
                                            UnevenRoundedRectangle(
                                                topLeadingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 0 : 8) : 8,
                                                bottomLeadingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 0 : 8) : 8,
                                                bottomTrailingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 8 : 0) : 8,
                                                topTrailingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 8 : 0) : 8,
                                                style: .circular
                                            )
                                            .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                        ) : AnyView(EmptyView())
                                    )
                                }//:ZStack
                                if appearance.timeInsideBubble == false{
                                    dateAndStatusView(onImage: false)
                                        .padding(.bottom,(message.reactions.count > 0) ? 5 : 0)
                                }
                            }
                            if message.reactions.count > 0{
                                reactionsView()
                            }
                        }
                        .padding(.vertical,2)
                    }
                    
                    //MARK: - Audio Message View
                case .audio:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                            //When its group show member avatar in message
                            inGroupUserAvatarView()
                        }
                        ZStack(alignment: .bottomTrailing){
                            VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                                if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                ZStack(alignment: .bottomTrailing){
                                    VStack(alignment: .trailing, spacing: 2){
                                        if message.messageType == 1{
                                            forwardedView()
                                        }
                                        ISMAudioSubView(audio: message.attachments.first?.mediaUrl ?? "", sentAt: message.sentAt, senderName: message.senderInfo?.userName ?? "", senderImageUrl: message.senderInfo?.userProfileImageUrl ?? "", isReceived: self.isReceived, messageDeliveredType: self.messageDeliveredType, previousAudioRef: $previousAudioRef)
                                            .padding(.bottom,(message.reactions.count > 0) ? 2 : 0)
                                    }//:VStack
                                    .padding(8)
                                    .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                    .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topRight] : [.topLeft,.topRight,.bottomRight]) : (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topLeft] : [.topLeft,.topRight,.bottomLeft]), bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                    .overlay(
                                        appearance.messageBubbleType == .BubbleWithOutTail ?
                                        AnyView(
                                            UnevenRoundedRectangle(
                                                topLeadingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 0 : 8) : 8,
                                                bottomLeadingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 0 : 8) : 8,
                                                bottomTrailingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 8 : 0) : 8,
                                                topTrailingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 8 : 0) : 8,
                                                style: .circular
                                            )
                                            .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                        ) : AnyView(EmptyView())
                                    )
                                }//:ZStack
                                if appearance.timeInsideBubble == false{
                                    dateAndStatusView(onImage: false)
                                }
                            }
                            if message.reactions.count > 0{
                                reactionsView()
                            }
                        }
                        .padding(.vertical,2)
                    }
                    //MARK: - Video Call Message View
                case .VideoCall:
                    HStack(alignment: .bottom){
                        ZStack(alignment: .bottomTrailing){
                            VStack(alignment: .leading, spacing: 2){
                                if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                ZStack(alignment: .bottomTrailing){
                                    VStack{
                                        VStack(alignment: .trailing, spacing: 2){
                                            callView()
                                        }//:VStack
                                        .padding(4)
                                        .background(Color(hex: "#E8EFF9"))
                                        .cornerRadius(8)
                                    }
                                    .padding(8)
                                    .frame(width: 216, height: 59, alignment: .center)
                                    .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                    .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topRight] : [.topLeft,.topRight,.bottomRight]) : (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topLeft] : [.topLeft,.topRight,.bottomLeft]), bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                    .overlay(
                                        appearance.messageBubbleType == .BubbleWithOutTail ?
                                        AnyView(
                                            UnevenRoundedRectangle(
                                                topLeadingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 0 : 8) : 8,
                                                bottomLeadingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 0 : 8) : 8,
                                                bottomTrailingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 8 : 0) : 8,
                                                topTrailingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 8 : 0) : 8,
                                                style: .circular
                                            )
                                            .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                        ) : AnyView(EmptyView())
                                    )
                                    .onTapGesture(perform: {
                                        if isReceived == true{
                                            videoCallToUser = true
                                        }
                                    })
                                }//:ZStack
                            }
                            if message.reactions.count > 0{
                                reactionsView()
                            }
                        }
                        .padding(.vertical,2)
                    }
                    
                    //MARK: - Audio Call Message View
                case .AudioCall:
                    HStack(alignment: .bottom){
                        ZStack(alignment: .bottomTrailing){
                            VStack(alignment: .leading, spacing: 2){
                                if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                ZStack(alignment: .bottomTrailing){
                                    VStack{
                                        VStack(alignment: .trailing, spacing: 2){
                                            callView()
                                            
                                        }//:VStack
                                        .padding(4)
                                        .background(Color(hex: "#E8EFF9"))
                                        .cornerRadius(8)
                                    }
                                    .padding(8)
                                    .frame(width: 216, height: 59, alignment: .center)
                                    .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                    .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topRight] : [.topLeft,.topRight,.bottomRight]) : (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topLeft] : [.topLeft,.topRight,.bottomLeft]), bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                    .overlay(
                                        appearance.messageBubbleType == .BubbleWithOutTail ?
                                        AnyView(
                                            UnevenRoundedRectangle(
                                                topLeadingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 0 : 8) : 8,
                                                bottomLeadingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 0 : 8) : 8,
                                                bottomTrailingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 8 : 0) : 8,
                                                topTrailingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 8 : 0) : 8,
                                                style: .circular
                                            )
                                            .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                        ) : AnyView(EmptyView())
                                    )
                                    .onTapGesture(perform: {
                                        if isReceived == true{
                                            audioCallToUser = true
                                        }
                                    })
                                }//:ZStack
                            }
                            if message.reactions.count > 0{
                                reactionsView()
                            }
                        }
                        .padding(.vertical,2)
                    }
                    //MARK: - Gif Message View
                case .gif:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                            //When its group show member avatar in message
                            inGroupUserAvatarView()
                        }
                        ZStack(alignment: .bottomTrailing){
                            VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                                if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                //                                NavigationLink(destination:  MediaSliderView(messageId: message.messageId).environmentObject(self.realmManager))
                                //                                {
                                VStack(alignment: .trailing,spacing: 5){
                                    if message.messageType == 1{
                                        forwardedView()
                                    }
                                    
                                    Button {
                                        navigateToMediaSliderId = message.messageId
                                    } label: {
                                        ZStack(alignment: .bottomTrailing){
                                            AnimatedImage(url: URL(string: message.attachments.first?.mediaUrl ?? ""))
                                                .resizable()
                                                .frame(width: 250, height: 300)
                                                .cornerRadius(5)
                                                .overlay(
                                                    LinearGradient(gradient: Gradient(colors: [.clear,.clear,.clear, Color.black.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                                        .frame(width: 250, height: 300)
                                                        .mask(
                                                            RoundedRectangle(cornerRadius: 5)
                                                                .fill(Color.white)
                                                        )
                                                )
                                            if appearance.timeInsideBubble == true{
                                                if message.metaData?.captionMessage == nil{
                                                    dateAndStatusView(onImage: true)
                                                        .padding(.bottom,5)
                                                        .padding(.trailing,5)
                                                }
                                            }
                                        }
                                    }
                                    
                                    
                                    if let caption = message.metaData?.captionMessage, !caption.isEmpty{
                                        Text(caption)
                                            .font(appearance.fonts.messageListMessageText)
                                            .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                        
                                        if appearance.timeInsideBubble == true{
                                            dateAndStatusView(onImage: false)
                                                .padding(.bottom,5)
                                                .padding(.trailing,5)
                                        }
                                        
                                    }
                                }//:ZStack
                                .padding(5)
                                .padding(.vertical,5)
                                .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topRight] : [.topLeft,.topRight,.bottomRight]) : (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topLeft] : [.topLeft,.topRight,.bottomLeft]), bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                .overlay(
                                    appearance.messageBubbleType == .BubbleWithOutTail ?
                                    AnyView(
                                        UnevenRoundedRectangle(
                                            topLeadingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 0 : 8) : 8,
                                            bottomLeadingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 0 : 8) : 8,
                                            bottomTrailingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 8 : 0) : 8,
                                            topTrailingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 8 : 0) : 8,
                                            style: .circular
                                        )
                                        .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                    ) : AnyView(EmptyView())
                                )
                                //                                }
                                if appearance.timeInsideBubble == false{
                                    dateAndStatusView(onImage: false)
                                        .padding(.bottom,5)
                                        .padding(.trailing,5)
                                }
                            }
                            if message.reactions.count > 0{
                                reactionsView()
                            }
                        }.padding(.vertical,2)
                    }
                    //MARK: - Sticker Message View
                case .sticker:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                            //When its group show member avatar in message
                            inGroupUserAvatarView()
                        }
                        ZStack(alignment: .bottomTrailing){
                            VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                                if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                VStack(alignment: .trailing,spacing: 5){
                                    AnimatedImage(url: URL(string: message.attachments.first?.mediaUrl ?? ""))
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(5)
                                    
                                    if appearance.timeInsideBubble == true{
                                        HStack{
                                            dateAndStatusView(onImage: false)
                                                .padding(.bottom,5)
                                                .padding(.trailing,5)
                                        }.padding(.leading,5)
                                            .padding(.top,5)
                                            .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                            .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topRight] : [.topLeft,.topRight,.bottomRight]) : (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topLeft] : [.topLeft,.topRight,.bottomLeft]), bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                            .overlay(
                                                appearance.messageBubbleType == .BubbleWithOutTail ?
                                                AnyView(
                                                    UnevenRoundedRectangle(
                                                        topLeadingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 0 : 8) : 8,
                                                        bottomLeadingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 0 : 8) : 8,
                                                        bottomTrailingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 8 : 0) : 8,
                                                        topTrailingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 8 : 0) : 8,
                                                        style: .circular
                                                    )
                                                    .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                                ) : AnyView(EmptyView())
                                            )
                                    }else{
                                        dateAndStatusView(onImage: false)
                                            .padding(.bottom,5)
                                    }
                                    
                                    
                                }//:ZStack
                                .padding(5)
                                .padding(.vertical,5)
                            }
                            if message.reactions.count > 0{
                                reactionsView()
                            }
                        }.padding(.vertical,2)
                    }
                    //MARK: - Post Message View
                case .post:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                            //When its group show member avatar in message
                            inGroupUserAvatarView()
                        }
                        ZStack(alignment: .bottomTrailing){
                            VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                                if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                
                                VStack(alignment: .trailing,spacing: 5){
                                    Button {
                                        postIdToNavigate = message.metaData?.post?.postId ?? ""
                                    } label: {
                                        postButtonView(isPost: true)
                                            
                                    }.padding(.trailing,5)
                                        .frame(width: 135)
                                    
                                }//:ZStack
                                .padding(5)
                                .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topRight] : [.topLeft,.topRight,.bottomRight]) : (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topLeft] : [.topLeft,.topRight,.bottomLeft]), bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                .overlay(
                                    appearance.messageBubbleType == .BubbleWithOutTail ?
                                    AnyView(
                                        UnevenRoundedRectangle(
                                            topLeadingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 0 : 8) : 8,
                                            bottomLeadingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 0 : 8) : 8,
                                            bottomTrailingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 8 : 0) : 8,
                                            topTrailingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 8 : 0) : 8,
                                            style: .circular
                                        )
                                        .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                    ) : AnyView(EmptyView())
                                )
                                if appearance.timeInsideBubble == false{
                                    dateAndStatusView(onImage: false)
                                        .padding(.bottom,5)
                                        .padding(.trailing,5)
                                }
                            }
                            
                            if message.reactions.count > 0{
                                reactionsView()
                            }
                        }.padding(.vertical,2)
                    }
                case .Product:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                            //When its group show member avatar in message
                            inGroupUserAvatarView()
                        }
                        ZStack(alignment: .bottomTrailing){
                            VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                                if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                
                                VStack(alignment: .trailing,spacing: 5){
                                    if let product = message.metaData?.product?.productId{
                                        Button {
                                            productIdToNavigate = message.metaData?.product ?? ProductDB()
                                        } label: {
                                            postButtonView(isPost: false)
                                        }
                                    }else{
                                        //it will act same as productLink
                                        productLinkView(message: message)
                                            .onTapGesture {
                                                navigateToProductLink = message
                                            }
                                    }
                                }//:ZStack
                                .padding(5)
                                .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topRight] : [.topLeft,.topRight,.bottomRight]) : (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topLeft] : [.topLeft,.topRight,.bottomLeft]), bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                .overlay(
                                    appearance.messageBubbleType == .BubbleWithOutTail ?
                                    AnyView(
                                        UnevenRoundedRectangle(
                                            topLeadingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 0 : 8) : 8,
                                            bottomLeadingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 0 : 8) : 8,
                                            bottomTrailingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 8 : 0) : 8,
                                            topTrailingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 8 : 0) : 8,
                                            style: .circular
                                        )
                                        .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                    ) : AnyView(EmptyView())
                                )
                                if appearance.timeInsideBubble == false{
                                    dateAndStatusView(onImage: false)
                                        .padding(.bottom,5)
                                        .padding(.trailing,5)
                                }
                            }
                            
                            if message.reactions.count > 0{
                                reactionsView()
                            }
                        }.padding(.vertical,2)
                    }
                case .ProductLink:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                            //When its group show member avatar in message
                            inGroupUserAvatarView()
                        }
                        ZStack(alignment: .bottomTrailing){
                            VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                                if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                
                                VStack(alignment: .trailing,spacing: 5){
                                    
                                    productLinkView(message: message)
                                        .onTapGesture {
                                            navigateToProductLink = message
                                        }
                                }
                                .frame(width: 258)
                                .padding(5)
                                .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topRight] : [.topLeft,.topRight,.bottomRight]) : (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topLeft] : [.topLeft,.topRight,.bottomLeft]), bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                .overlay(
                                    appearance.messageBubbleType == .BubbleWithOutTail ?
                                    AnyView(
                                        UnevenRoundedRectangle(
                                            topLeadingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 0 : 8) : 8,
                                            bottomLeadingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 0 : 8) : 8,
                                            bottomTrailingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 8 : 0) : 8,
                                            topTrailingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 8 : 0) : 8,
                                            style: .circular
                                        )
                                        .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                    ) : AnyView(EmptyView())
                                )
                                if appearance.timeInsideBubble == false{
                                    dateAndStatusView(onImage: false)
                                        .padding(.bottom,5)
                                        .padding(.trailing,5)
                                }
                            }
                            
                            if message.reactions.count > 0{
                                reactionsView()
                            }
                        }.padding(.vertical,2)
                    }
                case .SocialLink:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                            //When its group show member avatar in message
                            inGroupUserAvatarView()
                        }
                        ZStack(alignment: .bottomTrailing){
                            VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                                if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                
                                VStack(alignment: .trailing,spacing: 5){
                                    
                                    socialLinkView(message: message)
                                        .onTapGesture {
                                            navigateToSocialLink = message
                                        }.padding(.trailing,5)
                                    
                                }//:ZStack
                                .frame(width: 258)
                                .padding(5)
                                .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topRight] : [.topLeft,.topRight,.bottomRight]) : (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topLeft] : [.topLeft,.topRight,.bottomLeft]), bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                .overlay(
                                    appearance.messageBubbleType == .BubbleWithOutTail ?
                                    AnyView(
                                        UnevenRoundedRectangle(
                                            topLeadingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 0 : 8) : 8,
                                            bottomLeadingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 0 : 8) : 8,
                                            bottomTrailingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 8 : 0) : 8,
                                            topTrailingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 8 : 0) : 8,
                                            style: .circular
                                        )
                                        .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                    ) : AnyView(EmptyView())
                                )
                                if appearance.timeInsideBubble == false{
                                    dateAndStatusView(onImage: false)
                                        .padding(.bottom,5)
                                        .padding(.trailing,5)
                                }
                            }
                            
                            if message.reactions.count > 0{
                                reactionsView()
                            }
                        }.padding(.vertical,2)
                    }
                case .CollectionLink:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                            //When its group show member avatar in message
                            inGroupUserAvatarView()
                        }
                        ZStack(alignment: .bottomTrailing){
                            VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                                if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                
                                VStack(alignment: .trailing,spacing: 5){
                                    collectionLinkView(message: message)
                                        .onTapGesture {
                                            navigateToCollectionLink = message
                                        }.padding(.trailing,5)
                                    
                                }//:ZStack
                                .frame(width: 258)
                                .padding(5)
                                .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topRight] : [.topLeft,.topRight,.bottomRight]) : (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topLeft] : [.topLeft,.topRight,.bottomLeft]), bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                .overlay(
                                    appearance.messageBubbleType == .BubbleWithOutTail ?
                                    AnyView(
                                        UnevenRoundedRectangle(
                                            topLeadingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 0 : 8) : 8,
                                            bottomLeadingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 0 : 8) : 8,
                                            bottomTrailingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 8 : 0) : 8,
                                            topTrailingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 8 : 0) : 8,
                                            style: .circular
                                        )
                                        .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                    ) : AnyView(EmptyView())
                                )
                                if appearance.timeInsideBubble == false{
                                    dateAndStatusView(onImage: false)
                                        .padding(.bottom,5)
                                        .padding(.trailing,5)
                                }
                            }
                            
                            if message.reactions.count > 0{
                                reactionsView()
                            }
                        }.padding(.vertical,2)
                    }
                case .paymentRequest:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                            //When its group show member avatar in message
                            inGroupUserAvatarView()
                        }
                        ZStack(alignment: .bottomTrailing){
                            VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                                if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                
                                VStack(alignment: .trailing,spacing: 5){
                                    PaymentRequestUI(status: ISMChatHelper.getPaymentStatus(myUserId: userData?.userId ?? "",metaData: self.message.metaData, sentAt: self.message.sentAt), isReceived: self.isReceived,message: self.message) {
                                        //view details
                                        viewDetailsForPaymentRequest = self.message
                                    } declineRequest: {
                                        //decline request
                                        declinePaymentRequest = self.message
                                    }
                                    dateAndStatusView(onImage: false).padding(.trailing,16).padding(.bottom,5)
                                }//:ZStack
                                .frame(width: 280)
                                .background(Color(hex: "#F5F5F2"))
                                .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topRight] : [.topLeft,.topRight,.bottomRight]) : (appearance.messageBubbleTailPosition == .top ? [.bottomLeft,.bottomRight,.topLeft] : [.topLeft,.topRight,.bottomLeft]), bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                .overlay(
                                    appearance.messageBubbleType == .BubbleWithOutTail ?
                                    AnyView(
                                        UnevenRoundedRectangle(
                                            topLeadingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 0 : 8) : 8,
                                            bottomLeadingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 0 : 8) : 8,
                                            bottomTrailingRadius: appearance.messageBubbleTailPosition == .bottom ? (isReceived ? 8 : 0) : 8,
                                            topTrailingRadius: appearance.messageBubbleTailPosition == .top ? (isReceived ? 8 : 0) : 8,
                                            style: .circular
                                        )
                                        .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                    ) : AnyView(EmptyView())
                                )
                                if appearance.timeInsideBubble == false{
                                    dateAndStatusView(onImage: false)
                                        .padding(.bottom,5)
                                        .padding(.trailing,5)
                                }
                            }
                            
                            if message.reactions.count > 0{
                                reactionsView()
                            }
                        }.padding(.vertical,2)
                    }
                default:
                    EmptyView()
//                    CustomViewRegistry.shared.view(for: <#T##[String : Any]#>)
                }
            }.simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                    let contextMenuVC = ISMCustomContextMenuViewController()
                    contextMenuVC.modalPresentationStyle = .overFullScreen
                    contextMenuVC.view.backgroundColor = .clear
                    
                    let hostingController = UIHostingController(rootView:
                        ISMCustomContextMenu(
                            conversationId: self.conversationId,
                            message: self.message,
                            viewWidth: self.viewWidth,
                            isGroup: self.isGroup ?? false,
                            isReceived: self.isReceived,
                            selectedMessageToReply: $selectedMessageToReply,
                            navigateToMessageInfo: $navigatetoMessageInfo,
                            showMessageInfoInsideMessage: $showMessageInfoInsideMessage,
                            showForward: $showForward,
                            updateMessage: $updateMessage,
                            messageCopied: $messageCopied,
                            navigateToDeletePopUp: $navigateToDeletePopUp,
                            selectedReaction: $selectedReaction,
                            sentRecationToMessageId: $sentRecationToMessageId,
                            deleteMessage: $deleteMessage,
                            fromBroadCastFlow: self.fromBroadCastFlow,
                            groupconversationMember: self.groupconversationMember
                        )
                        .environmentObject(self.realmManager)
                    )
                    
                    hostingController.view.backgroundColor = .clear
                    contextMenuVC.addChild(hostingController)
                    contextMenuVC.view.addSubview(hostingController.view)
                    hostingController.view.frame = contextMenuVC.view.bounds
                    hostingController.didMove(toParent: contextMenuVC)
                    
                    if self.message.customType != ISMChatMediaType.PaymentRequest.value{
                        self.viewControllerHolder?.present(contextMenuVC, animated: true)
                    }
                }
            )
            .allowsHitTesting(true)
            .contentShape(Rectangle())
        }
            if ISMChatSdkUI.getInstance().getChatProperties().messageInfoBelowMessage == true && showMessageInfoInsideMessage == true{
                HStack{
                    
                    messageInfo(msg: message, isReceived: self.isReceived)
                    
                }
                
            }
        }
        .background(NavigationLink("", destination: ISMMessageInfoView(conversationId: conversationId,message: message, viewWidth: 250,mediaType: .Image, isGroup: self.isGroup ?? false, groupMember: self.groupconversationMember,fromBroadCastFlow: self.fromBroadCastFlow, onClose: {
            
        }).environmentObject(self.realmManager), isActive: $navigatetoMessageInfo))
//        .background(NavigationLink("", destination:  ISMContactInfoView(conversationID: "",viewModel:self.viewModel, isGroup: false,onlyInfo: true,selectedToShowInfo : self.navigatetoUser,navigateToSocialProfileId: $navigateToSocialProfileId, navigateToExternalUserListToAddInGroup: $navigateToExternalUserListToAddInGroup).environmentObject(self.realmManager), isActive: $navigateToInfo))
        .padding(.bottom, (message.reactions.count > 0) ? 20 : 0)
        .frame(maxWidth: .infinity, alignment: isReceived ? .leading : .trailing)
        .multilineTextAlignment(.leading) // Aligning the text based on message type
        
//        .gesture(
//            DragGesture()
//                .onChanged { gesture in
//                    if !message.deletedMessage{
//                        offset = gesture.translation
//                    }
//                }
//                .onEnded { value in
//                    if !message.deletedMessage{
//                        offset = .zero
//                        ISMChatHelper.print("value ",value.translation.width)
//                        let direction = self.detectDirection(value: value)
//                        if direction == .left {
//                            if showReplyOption{
//                                selectedMessageToReply = message
//                                UINotificationFeedbackGenerator().notificationOccurred(.warning)
//                            }
//                        }else if direction == .right{
//                            if !isReceived{
//                                navigatetoMessageInfo = true
//                            }
//                        }
//                    }
//                }
//        )
        .onAppear( perform: {
            self.navigateToInfo = false
            if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.File.value && message.customType == ISMChatMediaType.ReplyText.value{
                if let documentUrl = URL(string: message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? ""){
                    ISMChatHelper.pdfThumbnail(url: documentUrl){ image in
                        guard let image else { return }
                        pdfthumbnailImage = image
                    }
                }
            }
        })
        .sheet(isPresented: $showReactionsDetail) {
            ISMReactionDetailView(message: self.message, groupconversationMember: self.groupconversationMember, isGroup: self.isGroup ?? false, opponentDeatil: self.opponentDeatil, showReactionDetail: $showReactionsDetail, reactionRemoved: $reactionRemoved)
                .environmentObject(self.realmManager)
                .presentationDetents(
                    [.medium, .large],
                    selection: $settingsDetent
                )
        }
        .onChange(of: reactionRemoved, { _, _ in
            if !reactionRemoved.isEmpty{
                realmManager.removeReactionFromMessage(conversationId: self.message.conversationId, messageId: self.message.messageId, reaction: reactionRemoved, userId: userData?.userId ?? "")
                reactionRemoved = ""
            }
        })
    }//:Body
    
    func forwardedView() -> some View{
        HStack(alignment: .center, spacing: 2) {
            appearance.images.forwardedIcon
                .resizable()
                .frame(width: 14, height: 14, alignment: .center)
            Text("Forwarded")
                .font(appearance.fonts.messageListMessageForwarded)
                .foregroundColor(appearance.colorPalette.messageListMessageForwarded)
        }
    }
    
    func editedView() -> some View{
        Text("Edited")
            .font(appearance.fonts.messageListMessageEdited)
            .foregroundColor(appearance.colorPalette.messageListMessageEdited)
    }
    
    func openURLInSafari(urlString : String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    func calculateDiscountPercentage(latestBestPrice: Double, msrpPrice: Double) -> String {
        guard msrpPrice > 0 else {
            print("Error: msrpPrice must be greater than 0.")
            return "0.00"
        }
        
        let discount = ((msrpPrice - latestBestPrice) / msrpPrice) * 100
        
        // Round to two decimal places and format as a string
        return String(format: "%.2f", discount)
    }
    
    
    func productLinkView(message: MessagesDB) -> some View {
        VStack{
            VStack {
                if message.customType == ISMChatMediaType.ProductLink.value{
                    // Product Image with Discount Label
                    ZStack(alignment: .topLeading) {
                        ISMChatImageCahcingManger.viewImage(url: message.metaData?.productImage ?? "")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 248, height: 192)
                            .clipped()
                        
                        if message.metaData?.bestPrice != message.metaData?.scratchPrice {
                            let per = calculateDiscountPercentage(latestBestPrice: message.metaData?.bestPrice ?? 0, msrpPrice: message.metaData?.scratchPrice ?? 0)
                            Text("\(per)% Off")
                                .font(Font.custom(customFontName.medium, size: 12))
                                .foregroundColor(Color(hex: "#8D1111"))
                                .padding(4)
                                .background(Color(hex: "#FDDDDD"))
                                .cornerRadius(10)
                                .padding([.top, .leading], 8)
                        }
                    }
                    .frame(width: 248, height: 192)
                    .padding(.bottom, 10)
                    
                    // Brand and Product Name
                    VStack(alignment: .leading, spacing: 4) {
                        Text(message.metaData?.storeName?.uppercased() ?? "")
                            .font(Font.custom(customFontName.bold, size: 12))
                            .foregroundColor(Color(hex: "#505050"))
                            .multilineTextAlignment(.leading)
                        
                        Text(message.metaData?.productName ?? "")
                            .font(Font.custom(customFontName.medium, size: 14))
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        // Pricing and Button
                        HStack {
                            Text("$\(String(format: "%.2f", message.metaData?.bestPrice ?? 0))")
                                .font(Font.custom(customFontName.bold, size: 18))
                                .foregroundColor(Color(hex: "#0F1E91"))
                            if message.metaData?.bestPrice ?? 0 != message.metaData?.scratchPrice ?? 0{
                                Text("$\(String(format: "%.2f", message.metaData?.scratchPrice ?? 0))")
                                    .font(Font.custom(customFontName.medium, size: 14))
                                    .strikethrough()
                                    .foregroundColor(Color(hex: "#767676"))
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 4)
                    }.padding(.horizontal,5)
                    
                    Divider()
                    
                    // View Product Button
                    HStack(spacing: 8) {
                        Spacer()
                        Text("View Product")
                            .font(Font.custom(customFontName.semibold, size: 16))
                            .foregroundColor(Color(hex: "#FC8B1A"))
                        appearance.images.productShareLogo
                            .resizable()
                            .frame(width: 24, height: 24, alignment: .center)
                        Spacer()
                    }
                    .padding(6)
                    .padding(.bottom,10)
                }else{
                    ProgressView()
                }
            }
            .frame(width: 248,height: 360)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
            )
            .padding(.horizontal,5)
            
            if message.customType == ISMChatMediaType.ProductLink.value{
                if let caption = message.metaData?.captionMessage, !caption.isEmpty{
                    HStack{
                        Text(caption)
                            .font(appearance.fonts.messageListMessageText)
                            .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                            .padding(.horizontal,5)
                        Spacer()
                    }
                }
            }else{
                Text(message.body ?? "")
                    .font(appearance.fonts.messageListMessageText)
                    .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                    .padding(.horizontal,5)
            }
            
            // Time and Status (if needed)
            if message.customType == ISMChatMediaType.ProductLink.value{
                if appearance.timeInsideBubble {
                    HStack {
                        Spacer()
                        dateAndStatusView(onImage: false)
                            .padding(.bottom, 5)
                            .padding(.trailing, 5)
                    }
                }
            }
        }
    }
    
    func collectionLinkView(message : MessagesDB) -> some View{
        VStack(alignment: .leading) {
            HStack() {
                    ISMChatImageCahcingManger.viewImage(url: message.metaData?.collectionImage ?? "")
                        .resizable()
                        .scaledToFill()
                        .background(Color.white)
                        .frame(width: 78,height: 78)
                        .clipped()
                
                VStack(alignment: .leading,spacing: 5){
                    if let des = message.metaData?.collectionTitle{
                        Text(des)
                            .font(Font.bold(size: 12))
                            .foregroundColor(isReceived == true ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                            .lineLimit(2).padding(.horizontal,8).padding(.bottom,8).padding(.top,3)
                    }
                    if let des = message.metaData?.collectionDescription{
                        Text(des)
                            .font(Font.regular(size: 10))
                            .foregroundColor(isReceived == true ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                            .lineLimit(2).padding(.horizontal,8).padding(.bottom,8).padding(.top,3)
                    }
                    if let des = message.metaData?.productCount{
                        let text = des > 1 ? "\(des) Products" : "\(des) Product"
                        Text(text)
                            .font(Font.bold(size: 12))
                            .foregroundColor(isReceived == true ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                            .lineLimit(1).padding(.horizontal,8).padding(.bottom,8).padding(.top,3)
                    }
                }
                Spacer()
            }
            .frame(width: 248)
            .background(isReceived == true ? Color.black.opacity(0.2) :  Color.white.opacity(0.2))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
            )
            .padding(.horizontal,5)
            
            if let caption = message.metaData?.captionMessage, !caption.isEmpty{
                Text(caption)
                    .font(appearance.fonts.messageListMessageText)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                    .padding(.horizontal,5)
            }
            
            
            if appearance.timeInsideBubble == true{
                HStack{
                    Spacer()
                    
                    dateAndStatusView(onImage: false)
                        .padding(.bottom,5)
                        .padding(.trailing,5)
                    
                }
            }
        }
    }
    
    
    func socialLinkView(message : MessagesDB) -> some View{
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
               
                    ISMChatImageCahcingManger.viewImage(url: message.metaData?.thumbnailUrl ?? "")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 248, height: 240)
                        .clipped()
                        .overlay {
                            if message.metaData?.isVideoPost == true{
                                appearance.images.playVideo
                                    .resizable()
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                            }
                        }
                    
                    if let des = message.metaData?.Description{
                        Text(des)
                            .font(Font.medium(size: 12))
                            .foregroundColor(isReceived == true ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                            .lineLimit(2).padding(.horizontal,8).padding(.bottom,8).padding(.top,3)
                    }
                
            }
            .frame(width: 248)
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
            )
            .padding(.horizontal,5)
            
            if let caption = message.metaData?.captionMessage, !caption.isEmpty{
                Text(caption)
                    .font(appearance.fonts.messageListMessageText)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                    .padding(.horizontal,5)
            }
            
            
            if appearance.timeInsideBubble == true{
                HStack{
                    Spacer()
                    
                    dateAndStatusView(onImage: false)
                        .padding(.bottom,5)
                        .padding(.trailing,5)
                    
                }
            }
        }
    }
    
    func postButtonView(isPost : Bool) -> some View{
        VStack(alignment: .trailing){
            if message.messageType == 1{
                forwardedView()
            }
            ZStack(alignment: .bottomTrailing){
                ZStack(alignment: .topTrailing){
                    ISMImageViewer(url: isPost == true ? (message.metaData?.post?.postUrl ?? "") : (message.metaData?.product?.productUrl ?? ""), size: isPost == true ? CGSizeMake(124, 249) : CGSizeMake(250, 300), cornerRadius: 8)
                        .overlay(
                            LinearGradient(gradient: Gradient(colors: [.clear,.clear,.clear, Color.black.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                .frame(width: 124, height: 249)
                                .mask(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.white)
                                )
                        )
                    if isPost == true{
                        appearance.images.postIcon
                            .scaledToFill()
                            .frame(width: 20, height: 20)
                    }
                }
                if appearance.timeInsideBubble == true{
                    if message.metaData?.captionMessage == nil{
                        dateAndStatusView(onImage: true)
                            .padding(.bottom,5)
                            .padding(.trailing,5)
                    }
                }
            }
            if let caption = message.metaData?.captionMessage, !caption.isEmpty{
                Text(caption)
                    .font(appearance.fonts.messageListMessageText)
                    .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                
                if appearance.timeInsideBubble == true{
                    dateAndStatusView(onImage: false)
                        .padding(.bottom,5)
                        .padding(.trailing,5)
                }
            }
        }
    }
    
    func repliedMessageView() -> some View{
        HStack{
            Rectangle()
                .fill(appearance.colorPalette.messageListReplyToolbarRectangle)
                .frame(width: 4)
                .cornerRadius(ISMChatSdkUI.getInstance().getChatProperties().messageListReplyBarMeetEnds ? 2 : 0)
                .padding(.vertical , ISMChatSdkUI.getInstance().getChatProperties().messageListReplyBarMeetEnds ? 8 : 0)
                .padding(.leading , ISMChatSdkUI.getInstance().getChatProperties().messageListReplyBarMeetEnds ? 8 : 0)
            VStack(alignment: .leading, spacing: 5){
                let parentUserName = message.metaData?.replyMessage?.parentMessageUserName ?? "User"
                let parentUserId = message.metaData?.replyMessage?.parentMessageUserId
                let name = parentUserId == userData?.userId ? ConstantStrings.you : parentUserName
                Text(name)
                    .foregroundColor(appearance.colorPalette.messageListReplyToolbarHeader)
                    .font(appearance.fonts.messageListReplyToolbarHeader)
                let msg = message.metaData?.replyMessage?.parentMessageBody ?? ""
                if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.Image.value{
                    Label {
                        Text(message.metaData?.replyMessage?.parentMessagecaptionMessage != nil ? (message.metaData?.replyMessage?.parentMessagecaptionMessage ?? "Photo") : "Photo")
                            .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                            .font(appearance.fonts.messageListReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .frame(width: 14,height: 12)
                            .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                    }
                }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.Video.value{
                    Label {
                        Text(message.metaData?.replyMessage?.parentMessagecaptionMessage != nil ? (message.metaData?.replyMessage?.parentMessagecaptionMessage ?? "Video") : "Video")
                            .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                            .font(appearance.fonts.messageListReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        Image(systemName: "video.fill")
                            .resizable()
                            .frame(width: 14,height: 10)
                            .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                    }
                }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.File.value{
                    Label {
                        let str = URL(string: message.attachments.first?.mediaUrl ?? "")?.lastPathComponent.components(separatedBy: "_").last
                        Text(str ?? "Document")
                            .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                            .font(appearance.fonts.messageListReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        Image(systemName: "doc")
                            .resizable()
                            .frame(width: 12,height: 12)
                            .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                    }
                }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.Location.value{
                    Label {
                        Text("Location")
                            .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                            .font(appearance.fonts.messageListReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        Image(systemName: "location.fill")
                            .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                    }
                }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.Contact.value{
                    let data = msg.getContactJson()
                    let name = data?.first?["displayName"] as? String
                    HStack{
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 12, height: 12, alignment: .center)
                            .tint(Color.onboardingPlaceholder)
                        if data?.count == 1{
                            Text(name ?? "Contact")
                                .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                                .font(appearance.fonts.messageListReplyToolbarDescription)
                                .fixedSize(horizontal: false, vertical: true)
                        }else{
                            Text("\(name ?? "") and \((data?.count ?? 1) - 1) other contact")
                                .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                                .font(appearance.fonts.messageListReplyToolbarDescription)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(2)
                        }
                    }
                }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.sticker.value{
                    Label {
                        Text("Sticker")
                            .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                            .font(appearance.fonts.messageListReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        appearance.images.stickerLogo
                            .resizable()
                            .frame(width: 15,height: 15)
                    }
                }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.gif.value{
                    Label {
                        Text("GIF")
                            .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                            .font(appearance.fonts.messageListReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        appearance.images.gifLogo
                            .resizable()
                            .frame(width: 20,height: 15)
                    }
                }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.AudioCall.value{
                    Label {
                        Text("Audio Call")
                            .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                            .font(appearance.fonts.messageListReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        appearance.images.audioCall
                            .resizable()
                            .frame(width: 20,height: 15)
                    }
                }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.VideoCall.value{
                    Label {
                        Text("Video Call")
                            .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                            .font(appearance.fonts.messageListReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        appearance.images.videoCall
                            .resizable()
                            .frame(width: 20,height: 15)
                    }
                }else{
                    Text(msg)
                        .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                        .font(appearance.fonts.messageListReplyToolbarDescription)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(4)
                }
            }
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 8))
            
            Spacer()
            
            if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.Image.value{
                ISMImageViewer(url: message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? "", size: CGSizeMake(45, 40), cornerRadius: 5)
            }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.Video.value{
                ISMImageViewer(url: message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? "", size: CGSizeMake(45, 40), cornerRadius: 5)
            }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.File.value{
                Image(uiImage: pdfthumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height: 40)
            }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.gif.value{
                AnimatedImage(url: URL(string: message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? ""),isAnimating: $isAnimating)
                    .resizable()
                    .frame(width: 45, height: 40)
                    .cornerRadius(5)
                    .overlay(
                        LinearGradient(gradient: Gradient(colors: [.clear,.clear,.clear, Color.black.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .frame(width: 45, height: 40)
                            .mask(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.white)
                            )
                    )
            }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.sticker.value{
                AnimatedImage(url: URL(string: message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? ""),isAnimating: $isAnimating)
                    .resizable()
                    .frame(width: 45, height: 40)
                    .cornerRadius(5)
                    .overlay(
                        LinearGradient(gradient: Gradient(colors: [.clear,.clear,.clear, Color.black.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .frame(width: 45, height: 40)
                            .mask(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.white)
                            )
                    )
            }
        }
        .background(isReceived ? appearance.colorPalette.messageListReceivedReplyMessageBackgroundColor : appearance.colorPalette.messageListSendReplyMessageBackgroundColor)
        .cornerRadius(8, corners: .allCorners)
    }

    func getImageAsset() -> ImageAsset {
        var imageAsset: ImageAsset

        if message.initiatorId == userData?.userId {
            if message.missedByMembers.count == 0 {
                if let duration = message.callDurations.first(where: { $0.memberId == userData?.userId }) {
                    let durationText = duration.durationInMilliseconds?.millisecondsToTime() ?? ""
                    if messageType == .AudioCall {
                        imageAsset = ImageAsset(image: appearance.images.audioOutgoing, title: "Voice Call", durationText: durationText)
                    } else {
                        imageAsset = ImageAsset(image: appearance.images.videoOutgoing, title: "Video Call", durationText: durationText)
                    }
                } else {
                    imageAsset = ImageAsset(image: Image(""), title: "", durationText: "")
                }
            } else {
                if messageType == .AudioCall {
                    imageAsset = ImageAsset(image: appearance.images.audioOutgoing, title: "Voice Call", durationText: "No answer")
                } else {
                    imageAsset = ImageAsset(image: appearance.images.videoOutgoing, title: "Video Call", durationText: "No answer")
                }
            }
        } else {
            if message.missedByMembers.count == 0 {
                if let duration = message.callDurations.first(where: { $0.memberId == userData?.userId }) {
                    let durationText = duration.durationInMilliseconds?.millisecondsToTime() ?? ""
                    if messageType == .AudioCall {
                        imageAsset = ImageAsset(image: appearance.images.audioIncoming, title: "Voice Call", durationText: durationText)
                    } else {
                        imageAsset = ImageAsset(image: appearance.images.videoIncoming, title: "Video Call", durationText: durationText)
                    }
                } else {
                    if messageType == .AudioCall {
                        imageAsset = ImageAsset(image: appearance.images.audioMissedCall, title: "Missed voice call", durationText: "Tap to call back")
                    } else {
                        imageAsset = ImageAsset(image: appearance.images.videoMissedCall, title: "Missed video call", durationText: "Tap to call back")
                    }
                }
            } else {
                if messageType == .AudioCall {
                    imageAsset = ImageAsset(image: appearance.images.audioMissedCall, title: "Missed voice call", durationText: "Tap to call back")
                } else {
                    imageAsset = ImageAsset(image: appearance.images.videoMissedCall, title: "Missed video call", durationText: "Tap to call back")
                }
            }
        }

        return imageAsset
    }

    func callView() -> some View {
        let imageAsset = getImageAsset()
        
        return HStack(spacing: 10) {
            imageAsset.image
                .resizable()
                .frame(width: 38, height: 38, alignment: .center)
            VStack(alignment: .leading, spacing: 5) {
                Text(imageAsset.title)
                    .font(appearance.fonts.messageListcallingHeader)
                    .foregroundColor(appearance.colorPalette.messageListcallingHeader)
                HStack {
                    Text(imageAsset.durationText)
                        .font(appearance.fonts.messageListcallingTime)
                        .foregroundColor(appearance.colorPalette.messageListcallingTime)
                    Spacer()
                    Text(message.sentAt.datetotime())
                        .font(appearance.fonts.messageListMessageTime)
                        .foregroundColor(appearance.colorPalette.messageListcallingTime)
                }
            }
        }
    }

    
    func reactionsView() -> some View{
        Button {
            showReactionsDetail = true
        } label: {
            HStack(spacing : 5){
                ForEach(message.reactions) { rec in
                    HStack(spacing: 1){
                        Text(ISMChatHelper.getEmoji(valueString: rec.reactionType))
                            .font(appearance.fonts.messageListreactionCount)
                        Text("\(rec.users.count)")
                            .foregroundColor(appearance.colorPalette.messageListreactionCount)
                            .font(appearance.fonts.messageListreactionCount)
                    }
                    .padding(5)
                    .background(Color.white)
                    .cornerRadius(12)
                    .frame(height: 24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                    )
                }
            }.offset(y: 14)
        }
    }
    
    func inGroupUserAvatarView() -> some View{
        UserAvatarView(avatar: message.senderInfo?.userProfileImageUrl ?? "", showOnlineIndicator: false, size: CGSize(width: 25, height: 25), userName: message.senderInfo?.userName ?? "",font: .regular(size: 12))
            .onTapGesture {
                let member = ISMChatGroupMember(userProfileImageUrl: message.senderInfo?.userProfileImageUrl, userName: message.senderInfo?.userName, userIdentifier: message.senderInfo?.userIdentifier, userId: message.senderInfo?.userId, online: message.senderInfo?.online, lastSeen: message.senderInfo?.lastSeen, isAdmin: false)
                navigatetoUser = member
                navigateToInfo = true
            }
    }
    
    func inGroupUserName() -> some View{
        Text(message.senderInfo?.userName ?? "")
            .font(appearance.fonts.messageListgroupMemberUserName)
            .foregroundColor(appearance.colorPalette.messageListgroupMemberUserName)
    }
    
    func messageInfo(msg : MessagesDB,isReceived : Bool) -> some View{
        VStack(alignment: isReceived ? .leading : .trailing){
            if let readAt = msg.readBy.first?.timestamp{
                Text("Read \(NSDate().descriptiveStringMessageInfo(time: readAt))")
                    .font(appearance.fonts.messageListMessageTime)
                    .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTimeReceived :  appearance.colorPalette.messageListMessageTimeSend)
            }
            if let deliveredAt = msg.deliveredTo.first?.timestamp{
                Text("Delivered \(NSDate().descriptiveStringMessageInfo(time: deliveredAt))")
                    .font(appearance.fonts.messageListMessageTime)
                    .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTimeReceived :  appearance.colorPalette.messageListMessageTimeSend)
            }
        }
    }
    
    func dateAndStatusView(onImage : Bool) -> some View{
        HStack(alignment: .center,spacing: 10){
            Text(message.sentAt.datetotime())
                .font(appearance.fonts.messageListMessageTime)
                .foregroundColor(onImage ? Color.white : (isReceived ? appearance.colorPalette.messageListMessageTimeReceived :  appearance.colorPalette.messageListMessageTimeSend))
//            if message.metaData?.isBroadCastMessage == true && fromBroadCastFlow != true && !isReceived && !message.deletedMessage{
//                appearance.images.broadcastMessageStatus
//                    .resizable()
//                    .frame(width: 11, height: 10)
//            }
            if !isReceived && !message.deletedMessage{
                switch self.messageDeliveredType{
                case .BlueTick:
                    appearance.images.messageRead
                        .resizable()
                        .frame(width: appearance.imagesSize.messageRead.width, height: appearance.imagesSize.messageRead.height)
                case .DoubleTick:
                    appearance.images.messageDelivered
                        .resizable()
                        .frame(width: appearance.imagesSize.messageDelivered.width, height: appearance.imagesSize.messageDelivered.height)
                case .SingleTick:
                    appearance.images.messageSent
                        .resizable()
                        .frame(width: appearance.imagesSize.messageSend.width, height: appearance.imagesSize.messageSend.height)
                case .Clock:
                    appearance.images.messagePending
                        .resizable()
                        .frame(width: appearance.imagesSize.messagePending.width, height: appearance.imagesSize.messagePending.height)
                }
            }
        }//:HStack
    }
    
    func detectDirection(value: DragGesture.Value) -> SwipeHVDirection {
        if value.startLocation.x < value.location.x - 24 {
            return .left
        }
        if value.startLocation.x > value.location.x + 24 {
            return .right
        }
        if value.startLocation.y < value.location.y - 24 {
            return .down
        }
        if value.startLocation.y > value.location.y + 24 {
            return .up
        }
        return .none
    }
}


public struct ImageAsset {
     let image: Image
     let title: String
     let durationText: String
 }





struct PaymentRequestUI: View {
    var status: ISMChatPaymentRequestStatus
    var isReceived : Bool
    var message : MessagesDB
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    var viewDetails : () -> ()
    var declineRequest : () -> ()
    @State private var timer: Timer?
    @State private var totalTime : Int = 0
    @State private var remainingTime: TimeInterval = 0
    var userData = ISMChatSdk.getInstance().getChatClient()?.getConfigurations().userConfig
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Header and Payment Status
            headerView.padding(.bottom,16)
            
            appearance.images.paymentLogo
                .resizable()
                .frame(width: 70, height: 60, alignment: .center)
                .padding(.bottom,10)
            
            // Payment Amount
            VStack(spacing: 8) {
                if status == .Accepted || status == .PayedByOther{
                    if let otherUserName = message.metaData?.paymentRequestedMembers.first(where: { $0.userId != userData?.userId && $0.status == 1 }) {
                        Text("Paid by \(otherUserName.userName ?? "Unknown User")")
                            .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                            .foregroundColor((status == .Rejected || status == .Expired) ? Color(hex: "#6A6C6A") : Color(hex: "#121511"))
                    } else {
                        Text("You Paid")
                            .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                            .foregroundColor((status == .Rejected || status == .Expired) ? Color(hex: "#6A6C6A") : Color(hex: "#121511"))
                    }
                }else{
                    Text(isReceived ? "Total you pay" : "Total your friend pays")
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                        .foregroundColor((status == .Rejected || status == .Expired) ? Color(hex: "#6A6C6A") : Color(hex: "#121511"))
                }
                var amount: AttributedString {
                    var attributedString = AttributedString("\(message.metaData?.amount ?? 0) \(message.metaData?.currencyCode ?? "")")
                    
                    // Style "clear chat"
                    if let range = attributedString.range(of: "\(message.metaData?.amount ?? 0)") {
                        attributedString[range].foregroundColor = (status == .Rejected || status == .Expired) ? Color(hex: "#6A6C6A") : Color(hex: "#121511")
                        attributedString[range].font = Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 26)
                    }
                    
                    return attributedString
                }
                Text(amount)
                    .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().light, size: 26))
                    .foregroundColor((status == .Rejected || status == .Expired) ? Color(hex: "#6A6C6A") : Color(hex: "#121511"))
                    .padding(.bottom,16)
                    .lineSpacing(32 - 26) // Line spacing calculated as (line height - font size)
                    .tracking(-0.015 * 26)
                
                // Conditional Messages Based on Status
                if status == .ActiveRequest {
                    var attributedText: AttributedString {
                        var attributedString = AttributedString("Payment request will expire in \(timeString(from: remainingTime))")
                        
                        // Style "clear chat"
                        if let range = attributedString.range(of: "\(timeString(from: remainingTime))") {
                            attributedString[range].foregroundColor = Color(hex: "#3A341C")
                            attributedString[range].font = Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 12).monospacedDigit()
                        }
                        
                        return attributedString
                    }
                    Text(attributedText)
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                        .foregroundColor(Color(hex: "#3A341C")).padding(.bottom,16)
                } else if status == .Rejected {
                    Text("You declined the payment request")
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                        .foregroundColor(Color(hex: "#6A6C6A")).padding(.bottom,16)
                } else if status == .Expired {
                    Text(isReceived ? "Expired" : "This payment request has expired.")
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                        .foregroundColor(Color(hex: "#6A6C6A")).padding(.bottom,16)
                }else if status == .Cancelled {
                    Text(isReceived ? "This order has been cancelled." : "You cancelled this order.")
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                        .foregroundColor(Color(hex: "#6A6C6A")).padding(.bottom,16)
                }
            }
            .padding(.horizontal, 16)
            
            // Action Buttons for Active Request Only
            if status == .ActiveRequest {
                HStack(spacing: 20) {
                    if isReceived == true{
                        Button(action: {
                            declineRequest()
                        }) {
                            Text("Decline")
                                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                                .foregroundStyle(Color(hex: "#163300"))
                                .frame(width: 121, height: 32, alignment: .center)
                                .background(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#163300"), lineWidth: 1))
                        }
                        
                        Button(action: {
                            viewDetails()
                        }) {
                            Text("View details")
                                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                                .foregroundStyle(Color(hex: "#163300"))
                                .frame(width: 121, height: 32, alignment: .center)
                                .background(Color(hex: "#86EA5D"))
                                .cornerRadius(16)
                        }
                    }else{
                        Button(action: {
                            viewDetails()
                        }) {
                            Text("View Details")
                                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                                .foregroundStyle(Color(hex: "#163300"))
                                .frame(width: 225, height: 32, alignment: .center)
                                .background(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#163300"), lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 16)
            }else if status == .PayedByOther{
                Button(action: {
                    // Decline action
                }) {
                    Text("Paid")
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                        .foregroundStyle(Color(hex: "#6A6C6A"))
                        .frame(width: 225, height: 32, alignment: .center)
                        .background(Color(hex: "#dfdfdc"))
                        .cornerRadius(16)
                }.padding(.bottom,15)
            }else if status == .Accepted{
                Button(action: {
                    // Decline action
                }) {
                    Text("Paid by myself")
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                        .foregroundStyle(Color(hex: "#6A6C6A"))
                        .frame(width: 225, height: 32, alignment: .center)
                        .background(Color(hex: "#dfdfdc"))
                        .cornerRadius(16)
                }
                .padding(.bottom,15)
            }else if status == .Expired && isReceived == false{
                Button(action: {
                    viewDetails()
                }) {
                    Text("View Details")
                        .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 14))
                        .foregroundStyle(Color(hex: "#163300"))
                        .frame(width: 225, height: 32, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#163300"), lineWidth: 1))
                }
            }
            
            if status == .Accepted{
                Text("You have successfully paid for the order.")
                    .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                    .foregroundColor(Color(hex: "#6A6C6A")).padding(.bottom,16)
            }else if status == .PayedByOther{
                Text("The payment has already been made.")
                    .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().regular, size: 12))
                    .foregroundColor(Color(hex: "#6A6C6A")).padding(.bottom,16)
            }
        }.onAppear {
            totalTime = (message.metaData?.requestAPaymentExpiryTime ?? 0) * 60
            startTimer()
        }.onDisappear{
            stopTimer()
        }
    }
    
    private func startTimer() {
        let expirationTimestamp = (message.sentAt / 1000.0) + Double(totalTime)
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                let currentTimestamp = Date().timeIntervalSince1970
                remainingTime = max(0, expirationTimestamp - currentTimestamp)
                
                // Stop the timer when countdown reaches 0
                if remainingTime <= 0 {
                    timer.invalidate()
                }
            }
        }
        
        private func stopTimer() {
            timer?.invalidate()
            timer = nil
        }
        
    private func timeString(from remainingTime: TimeInterval) -> String {
        let hours = Int(remainingTime) / 3600
        let minutes = (Int(remainingTime) % 3600) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // Header View Based on Status
    @ViewBuilder
    private var headerView: some View {
        if status == .ActiveRequest {
            Text("Payment Request")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                .foregroundColor(Color(hex: "#121511"))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#86EA5D"))
                .cornerRadius(10, corners: [.topLeft, .topRight])
        }else if status == .Accepted {
            Text("Payment Request")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                .foregroundColor(Color(hex: "#454745"))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#BDBDBA"))
                .cornerRadius(10, corners: [.topLeft, .topRight])
        } else if status == .PayedByOther {
            Text("Payment Request")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                .foregroundColor(Color(hex: "#454745"))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#BDBDBA"))
                .cornerRadius(10, corners: [.topLeft, .topRight])
        }else if status == .Rejected {
            Text("Request Declined")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#FF3B30"))
                .cornerRadius(10, corners: [.topLeft, .topRight])
        } else if status == .Expired {
            Text(isReceived ? "Payment Request" : "Payment Request Expired")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                .foregroundColor(Color(hex: "#454745"))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#BDBDBA"))
                .cornerRadius(10, corners: [.topLeft, .topRight])
        }else if status == .Cancelled {
            Text("Payment Request Cancelled")
                .font(Font.custom(ISMChatSdkUI.getInstance().getCustomFontNames().semibold, size: 16))
                .foregroundColor(isReceived ? Color(hex: "#454745") : Color.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isReceived ? Color(hex: "#BDBDBA") : Color(hex: "#FF3B30"))
                .cornerRadius(10, corners: [.topLeft, .topRight])
        }
    }
}


class ISMCustomContextMenuViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
}
