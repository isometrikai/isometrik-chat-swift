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
    
    
    
    @State var navigateToInfo : Bool = false
    @State var navigatetoUser : ISMChatGroupMember = ISMChatGroupMember()
    @State var navigatetoMessageInfo =  false
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
    @State var userData = ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig
    
   
    @EnvironmentObject var realmManager : RealmManager
    @ObservedObject var viewModel = ChatsViewModel()
    @Environment(\.viewController) public var viewControllerHolder: UIViewController?
    @Binding var postIdToNavigate : String
    
    @Binding var navigateToSocialProfileId : String
    
    
    //MARK:  - BODY
    var body: some View {
        HStack{
            if message.deletedMessage == true{
                ZStack{
                    VStack(alignment: isReceived == true ? .leading : .trailing, spacing: 2){
                        HStack{
                            Image(systemName: "minus.circle")
                            Text(isReceived == true ? "This message was deleted." :  "You deleted this message.")
                                .font(appearance.fonts.messageListMessageDeleted)
                                .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                        }
                        .opacity(0.2)
                        dateAndStatusView(onImage: false)
                    }//:VStack
                    .padding(8)
                    .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                    .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                    .overlay(
                        appearance.messageBubbleType == .BubbleWithOutTail ?
                            AnyView(
                                UnevenRoundedRectangle(
                                    topLeadingRadius: 8,
                                    bottomLeadingRadius: isReceived ? 0 : 8,
                                    bottomTrailingRadius: isReceived ? 8 : 0,
                                    topTrailingRadius: 8,
                                    style: .circular
                                )
                                .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                            ) : AnyView(EmptyView())
                    )
                }//:ZStack
                .padding(.vertical,2)
            }else{
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
                            VStack(alignment: .leading, spacing: 2){
                                 if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                VStack(alignment: .trailing, spacing: 0){
                                    if message.customType == ISMChatMediaType.ReplyText.value && message.messageType != 1{
                                        repliedMessageView()
                                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 5))
                                            .onTapGesture {
                                                parentMsgToScroll = message
                                            }
                                    }
                                    if message.messageType == 1{
                                        forwardedView()
                                    }
                                    if message.messageUpdated == true{
                                        editedView()
                                    }
                                    VStack(alignment: .trailing, spacing: 5){
                                        HStack{
                                            if ISMChatHelper.isValidEmail(str) == true{
                                                Link(destination: URL(string: "mailto:apple@me.com")!, label: {
                                                    Text(str)
                                                        .font(appearance.fonts.messageListMessageText)
                                                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                        .underline(true, color: isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                })
                                            }else if  ISMChatHelper.isValidPhone(phone: str) == true{
                                                Link(destination: URL(string: "tel:\(str)")!, label: {
                                                    Text(str)
                                                        .font(appearance.fonts.messageListMessageText)
                                                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                        .underline(true, color: isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                })
                                            }
                                            else if str.isValidURL || str.contains("www."){
//                                                ISMLinkPreview(urlString: str)
//                                                    .font(themeFonts.messageListMessageText)
//                                                    .foregroundColor(themeColor.messageListMessageText)
                                                Link(destination: URL(string: str)!, label: {
                                                    Text(str)
                                                        .font(appearance.fonts.messageListMessageText)
                                                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                        .underline(true, color: isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                })
                                            }
                                            else{
                                                if str.contains("@") && isGroup == true{
                                                    HighlightedTextView(originalText: str, mentionedUsers: groupconversationMember, isReceived: self.isReceived, navigateToInfo: $navigateToInfo, navigatetoUser: $navigatetoUser)
                                                }else{
                                                    Text(str)
                                                        .font(appearance.fonts.messageListMessageText)
                                                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                }
                                            }
                                        }
                                        dateAndStatusView(onImage: false)
                                    }
                                }//:VStack
                                .padding(.horizontal, str.isValidURL || str.contains("www.") == true ? 5 : 10)
                                .padding(.vertical,str.isValidURL || str.contains("www.") == true ? 5 : 8)
                                .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                .overlay(
                                    appearance.messageBubbleType == .BubbleWithOutTail ?
                                        AnyView(
                                            UnevenRoundedRectangle(
                                                topLeadingRadius: 8,
                                                bottomLeadingRadius: isReceived ? 0 : 8,
                                                bottomTrailingRadius: isReceived ? 8 : 0,
                                                topTrailingRadius: 8,
                                                style: .circular
                                            )
                                            .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                        ) : AnyView(EmptyView())
                                )
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
                            VStack(alignment: .leading, spacing: 2){
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
                                                
                                                UserAvatarView(avatar: metaData.contacts.first?.contactImageUrl ?? "", showOnlineIndicator: false, userName: metaData.contacts.first?.contactName ?? "")
                                                    .scaledToFill()
                                                    .frame(width: 40, height: 40)
                                                    .cornerRadius(20)
                                                
                                                let name = metaData.contacts.first?.contactName ?? ""
                                                if metaData.contacts.count == 1{
                                                    Text(name)
                                                        .font(appearance.fonts.messageListMessageText)
                                                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                }else{
                                                    Text("\(name) and \((metaData.contacts.count) - 1) other contact")
                                                        .font(appearance.fonts.messageListMessageText)
                                                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                }
                                                Spacer()
                                            }.padding(5)
                                            HStack{
                                                Spacer()
                                                dateAndStatusView(onImage: false)
                                            }
                                            Divider().background(Color.docBackground)
                                            HStack{
                                                Spacer()
                                                Text(metaData.contacts.count == 1 ? "View" : "View All")
                                                    .font(appearance.fonts.messageListMessageText)
                                                    .foregroundColor(appearance.colorPalette.userProfileEditText)
                                                Spacer()
                                            }.padding(.vertical,5)
                                        }
                                        .frame(width: 250)
                                        .padding(5)
                                        .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                        .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                        .overlay(
                                            appearance.messageBubbleType == .BubbleWithOutTail ?
                                                AnyView(
                                                    UnevenRoundedRectangle(
                                                        topLeadingRadius: 8,
                                                        bottomLeadingRadius: isReceived ? 0 : 8,
                                                        bottomTrailingRadius: isReceived ? 8 : 0,
                                                        topTrailingRadius: 8,
                                                        style: .circular
                                                    )
                                                    .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                                ) : AnyView(EmptyView())
                                        )
                                    }
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
                            VStack(alignment: .leading, spacing: 2){
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
                                                ISMChatImageCahcingManger.viewImage(url: message.attachments.first?.mediaUrl ?? "")
                                                    .scaledToFill()
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
                                            
                                            dateAndStatusView(onImage: false)
                                                .padding(.bottom,5)
                                                .padding(.trailing,5)
                                            
                                        }
                                    }//:ZStack
                                    .padding(5)
                                    .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                    .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                    .overlay(
                                        appearance.messageBubbleType == .BubbleWithOutTail ?
                                            AnyView(
                                                UnevenRoundedRectangle(
                                                    topLeadingRadius: 8,
                                                    bottomLeadingRadius: isReceived ? 0 : 8,
                                                    bottomTrailingRadius: isReceived ? 8 : 0,
                                                    topTrailingRadius: 8,
                                                    style: .circular
                                                )
                                                .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                            ) : AnyView(EmptyView())
                                    )
//                                }
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
                            VStack(alignment: .leading, spacing: 2){
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
                                                            ISMChatImageCahcingManger.viewImage(url: message.attachments.first?.thumbnailUrl ?? "")
                                                                .scaledToFill()
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
                                                        ISMChatImageCahcingManger.viewImage(url: message.attachments.first?.thumbnailUrl ?? "")
                                                            .scaledToFill()
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
                                                        if message.metaData?.captionMessage == nil{
                                                            dateAndStatusView(onImage: true)
                                                                .padding(.bottom,5)
                                                                .padding(.trailing,5)
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
                                            
                                            dateAndStatusView(onImage: false)
                                                .padding(.bottom,5)
                                                .padding(.trailing,5)
                                        }
                                        
                                    }.padding(5)
                                    .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                    .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                        .overlay(
                                            appearance.messageBubbleType == .BubbleWithOutTail ?
                                                AnyView(
                                                    UnevenRoundedRectangle(
                                                        topLeadingRadius: 8,
                                                        bottomLeadingRadius: isReceived ? 0 : 8,
                                                        bottomTrailingRadius: isReceived ? 8 : 0,
                                                        topTrailingRadius: 8,
                                                        style: .circular
                                                    )
                                                    .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                                ) : AnyView(EmptyView())
                                        )
//                                }//:NavigationLink
                                //                                }
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
                            VStack(alignment: .leading, spacing: 2){
                                 if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                if let documentUrl = URL(string: message.attachments.first?.mediaUrl ?? ""){
                                    let urlExtension = ISMChatHelper.getExtensionFromURL(url: documentUrl)
                                    let fileName = ISMChatHelper.getFileNameFromURL(url: documentUrl)
                                    NavigationLink(destination: ISMDocumentViewer(url: documentUrl, title: fileName)){
                                        ZStack{
                                            VStack(alignment: .trailing, spacing: 5){
                                                if message.messageType == 1{
                                                    forwardedView()
                                                }
                                                
                                                HStack(alignment: .center, spacing: 5){
                                                    if let urlExtension = urlExtension{
                                                        if urlExtension.contains(".jpg") ||  urlExtension.contains(".png"){
                                                            ISMChatImageCahcingManger.viewImage(url: message.attachments.first?.mediaUrl ?? "")
                                                                .scaledToFill()
                                                                .frame(width: 250, height: 300)
                                                                .cornerRadius(5)
                                                            
                                                        }else{
                                                            if urlExtension == "pdf" {
                                                                ISMPDFMessageView(pdfURL: documentUrl, fileName: fileName)
                                                            } else {
                                                                appearance.images.pdfLogo
                                                                    .resizable()
                                                                    .aspectRatio(contentMode: .fit)
                                                                    .frame(width: 30, height: 30)
                                                                
                                                                Text(fileName)
                                                                    .font(appearance.fonts.messageListMessageText)
                                                                    .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                                    .fixedSize(horizontal: false, vertical: true)
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                dateAndStatusView(onImage: false)
                                                    .padding(.bottom,(message.reactions.count > 0) ? 5 : 0)
                                            }//:VStack
                                            .frame(width: 250)
                                            .padding(5)
                                            .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                            .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                            .overlay(
                                                appearance.messageBubbleType == .BubbleWithOutTail ?
                                                    AnyView(
                                                        UnevenRoundedRectangle(
                                                            topLeadingRadius: 8,
                                                            bottomLeadingRadius: isReceived ? 0 : 8,
                                                            bottomTrailingRadius: isReceived ? 8 : 0,
                                                            topTrailingRadius: 8,
                                                            style: .circular
                                                        )
                                                        .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                                    ) : AnyView(EmptyView())
                                            )
                                        }//:ZStack
                                    }
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
                            VStack(alignment: .leading, spacing: 2){
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
                                                    .cornerRadius(5)
                                                    .contentShape(Rectangle())
                                                    .allowsHitTesting(true)
                                                
                                                HStack{
                                                    Text(message.attachments.first?.title ?? "")
                                                        .font(appearance.fonts.messageListMessageText)
                                                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                    Spacer()
                                                    
                                                }
                                                HStack{
                                                    Text(message.attachments.first?.address ?? "")
                                                        .font(appearance.fonts.messageListReplyToolbarDescription)
                                                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                    Spacer()
                                                }
                                            }
                                        }
                                       
                                        dateAndStatusView(onImage: false)
                                            .padding(.bottom,(message.reactions.count > 0) ? 5 : 0)
                                    }//:VStack
                                    .frame(width: 250)
                                    .padding(5)
                                    .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                    .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                    .overlay(
                                        appearance.messageBubbleType == .BubbleWithOutTail ?
                                            AnyView(
                                                UnevenRoundedRectangle(
                                                    topLeadingRadius: 8,
                                                    bottomLeadingRadius: isReceived ? 0 : 8,
                                                    bottomTrailingRadius: isReceived ? 8 : 0,
                                                    topTrailingRadius: 8,
                                                    style: .circular
                                                )
                                                .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                            ) : AnyView(EmptyView())
                                    )
                                }//:ZStack
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
                            VStack(alignment: .leading, spacing: 2){
                                 if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                ZStack(alignment: .bottomTrailing){
                                    VStack(alignment: .trailing, spacing: 2){
                                        if message.messageType == 1{
                                            forwardedView()
                                        }
                                        ISMAudioSubView(audio: message.attachments.first?.mediaUrl ?? "",message : self.message, isReceived: self.isReceived, messageDeliveredType: self.messageDeliveredType, previousAudioRef: $previousAudioRef)
                                            .padding(.bottom,(message.reactions.count > 0) ? 2 : 0)
                                    }//:VStack
                                    .padding(8)
                                    .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                    .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                    .overlay(
                                        appearance.messageBubbleType == .BubbleWithOutTail ?
                                            AnyView(
                                                UnevenRoundedRectangle(
                                                    topLeadingRadius: 8,
                                                    bottomLeadingRadius: isReceived ? 0 : 8,
                                                    bottomTrailingRadius: isReceived ? 8 : 0,
                                                    topTrailingRadius: 8,
                                                    style: .circular
                                                )
                                                .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                            ) : AnyView(EmptyView())
                                    )
                                }//:ZStack
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
                                    .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                    .overlay(
                                        appearance.messageBubbleType == .BubbleWithOutTail ?
                                            AnyView(
                                                UnevenRoundedRectangle(
                                                    topLeadingRadius: 8,
                                                    bottomLeadingRadius: isReceived ? 0 : 8,
                                                    bottomTrailingRadius: isReceived ? 8 : 0,
                                                    topTrailingRadius: 8,
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
                                    .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                    .overlay(
                                        appearance.messageBubbleType == .BubbleWithOutTail ?
                                            AnyView(
                                                UnevenRoundedRectangle(
                                                    topLeadingRadius: 8,
                                                    bottomLeadingRadius: isReceived ? 0 : 8,
                                                    bottomTrailingRadius: isReceived ? 8 : 0,
                                                    topTrailingRadius: 8,
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
                            VStack(alignment: .leading, spacing: 2){
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
                                            
                                            dateAndStatusView(onImage: false)
                                                .padding(.bottom,5)
                                                .padding(.trailing,5)
                                            
                                        }
                                    }//:ZStack
                                    .padding(5)
                                    .padding(.vertical,5)
                                    .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                    .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                    .overlay(
                                        appearance.messageBubbleType == .BubbleWithOutTail ?
                                            AnyView(
                                                UnevenRoundedRectangle(
                                                    topLeadingRadius: 8,
                                                    bottomLeadingRadius: isReceived ? 0 : 8,
                                                    bottomTrailingRadius: isReceived ? 8 : 0,
                                                    topTrailingRadius: 8,
                                                    style: .circular
                                                )
                                                .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                            ) : AnyView(EmptyView())
                                    )
//                                }
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
                            VStack(alignment: .leading, spacing: 2){
                                 if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                VStack(alignment: .trailing,spacing: 5){
                                    AnimatedImage(url: URL(string: message.attachments.first?.mediaUrl ?? ""))
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(5)
                                    
                                    HStack{
                                        dateAndStatusView(onImage: false)
                                            .padding(.bottom,5)
                                            .padding(.trailing,5)
                                    }.padding(.leading,5)
                                        .padding(.top,5)
                                        .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                        .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                        .overlay(
                                            appearance.messageBubbleType == .BubbleWithOutTail ?
                                                AnyView(
                                                    UnevenRoundedRectangle(
                                                        topLeadingRadius: 8,
                                                        bottomLeadingRadius: isReceived ? 0 : 8,
                                                        bottomTrailingRadius: isReceived ? 8 : 0,
                                                        topTrailingRadius: 8,
                                                        style: .circular
                                                    )
                                                    .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                                ) : AnyView(EmptyView())
                                        )
                                    
                                    
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
                            VStack(alignment: .leading, spacing: 2){
                                 if isGroup == true && isReceived == true && ISMChatSdkUI.getInstance().getChatProperties().isOneToOneGroup == false{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                
                                    VStack(alignment: .trailing,spacing: 5){
                                        Button {
                                            postIdToNavigate = message.metaData?.post?.postId ?? ""
                                        } label: {
                                            postButtonView()
                                        }

                                    }//:ZStack
                                    .padding(5)
                                    .background(isReceived ? appearance.colorPalette.messageListReceivedMessageBackgroundColor : appearance.colorPalette.messageListSendMessageBackgroundColor)
                                    .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: appearance.messageBubbleType, direction: isReceived ? .left : .right))
                                    .overlay(
                                        appearance.messageBubbleType == .BubbleWithOutTail ?
                                            AnyView(
                                                UnevenRoundedRectangle(
                                                    topLeadingRadius: 8,
                                                    bottomLeadingRadius: isReceived ? 0 : 8,
                                                    bottomTrailingRadius: isReceived ? 8 : 0,
                                                    topTrailingRadius: 8,
                                                    style: .circular
                                                )
                                                .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
                                            ) : AnyView(EmptyView())
                                    )
                            }
                            
                            if message.reactions.count > 0{
                                reactionsView()
                            }
                        }.padding(.vertical,2)
                    }
                default:
                    EmptyView()
                }
            }
        }
//        .background(NavigationLink("", destination: ISMMessageInfoView(conversationId: conversationId,message: message, viewWidth: 250,mediaType: .Image, isGroup: self.isGroup ?? false, groupMember: self.groupconversationMember,fromBroadCastFlow: self.fromBroadCastFlow).environmentObject(self.realmManager), isActive: $navigatetoMessageInfo))
        .background(NavigationLink("", destination:  ISMContactInfoView(conversationID: "",viewModel:self.viewModel, isGroup: false,onlyInfo: true,selectedToShowInfo : self.navigatetoUser,navigateToSocialProfileId: $navigateToSocialProfileId).environmentObject(self.realmManager), isActive: $navigateToInfo))
        .padding(.bottom, (message.reactions.count > 0) ? 20 : 0)
        .frame(maxWidth: .infinity, alignment: isReceived ? .leading : .trailing)
        .multilineTextAlignment(.leading) // Aligning the text based on message type
        .simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded { _ in
            self.viewControllerHolder?.present(style: .overCurrentContext, transitionStyle: .crossDissolve) {
                ISMCustomContextMenu(conversationId: self.conversationId, message: self.message, viewWidth: self.viewWidth, isGroup: self.isGroup ?? false, isReceived: self.isReceived, selectedMessageToReply: $selectedMessageToReply, showForward: $showForward, updateMessage: $updateMessage, messageCopied: $messageCopied, navigateToDeletePopUp: $navigateToDeletePopUp, selectedReaction: $selectedReaction,sentRecationToMessageId: $sentRecationToMessageId,fromBroadCastFlow: self.fromBroadCastFlow,groupconversationMember: self.groupconversationMember)
                    .environmentObject(self.realmManager)
            }
        })
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if !message.deletedMessage{
                        offset = gesture.translation
                    }
                }
                .onEnded { value in
                    if !message.deletedMessage{
                        offset = .zero
                        ISMChatHelper.print("value ",value.translation.width)
                        let direction = self.detectDirection(value: value)
                        if direction == .left {
                            if showReplyOption{
                                selectedMessageToReply = message
                                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                            }
                        }else if direction == .right{
                            if !isReceived{
                                navigatetoMessageInfo = true
                            }
                        }
                    }
                }
        )
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
                realmManager.removeReactionFromMessage(conversationId: self.message.conversationId, messageId: self.message.messageId, reaction: reactionRemoved, userId: userData.userId)
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
    
    func postButtonView() -> some View{
        VStack{
            if message.messageType == 1{
                forwardedView()
            }
            ZStack(alignment: .bottomTrailing){
                ZStack(alignment: .topTrailing){
                    ISMChatImageCahcingManger.viewImage(url: message.metaData?.post?.postUrl ?? "")
                        .scaledToFill()
                        .frame(width: 124, height: 249)
                        .cornerRadius(5)
                        .overlay(
                            LinearGradient(gradient: Gradient(colors: [.clear,.clear,.clear, Color.black.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                .frame(width: 250, height: 300)
                                .mask(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.white)
                                )
                        )
                    
                    appearance.images.postIcon
                        .scaledToFill()
                        .frame(width: 20, height: 20)
                }
                if message.metaData?.captionMessage == nil{
                    dateAndStatusView(onImage: true)
                        .padding(.bottom,5)
                        .padding(.trailing,5)
                }
            }
            if let caption = message.metaData?.captionMessage, !caption.isEmpty{
                Text(caption)
                    .font(appearance.fonts.messageListMessageText)
                    .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                
                dateAndStatusView(onImage: false)
                    .padding(.bottom,5)
                    .padding(.trailing,5)
                
            }
        }
    }
    
    func repliedMessageView() -> some View{
        HStack{
            Rectangle()
                .fill(appearance.colorPalette.messageListReplyToolbarRectangle)
                .frame(width: 4)
            VStack(alignment: .leading, spacing: 2){
                let parentUserName = message.metaData?.replyMessage?.parentMessageUserName ?? "User"
                let parentUserId = message.metaData?.replyMessage?.parentMessageUserId
                let name = parentUserId == userData.userId ? ConstantStrings.you : parentUserName
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
                    AnimatedImage(url: URL(string: message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? ""),isAnimating: $isAnimating)
                        .resizable()
                        .frame(width: 30, height: 30)
                }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.gif.value{
                    Label {
                        Text("GIF")
                            .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                            .font(appearance.fonts.messageListReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        Image("gif_logo")
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
                }
            }
            .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 8))
            if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.Image.value{
                ISMChatImageCahcingManger.viewImage(url: message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? "")
                    .scaledToFill()
                    .frame(width: 45, height: 40)
            }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.Video.value{
                ISMChatImageCahcingManger.viewImage(url: message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? "")
                    .scaledToFill()
                    .frame(width: 45, height: 40)
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
            }
        }
        .background(Color.docBackground)
        .cornerRadius(5, corners: .allCorners)
    }
    
//    func callView() -> some View{
//        var imageString : String = ""
//        var titleText : String = ""
//        var durationText : String = ""
//        
//        
//        if message.initiatorIdentifier == userSession.getEmailId(){
//            if message.missedByMembers.count == 0{
//                if let duration = message.callDurations.first(where: { $0.memberId == userSession.getUserId() }) {
//                    // Duration found
//                    if messageType == .AudioCall{
//                        imageString = "audio_outgoing"
//                        titleText = "Voice Call"
//                        durationText = duration.durationInMilliseconds?.millisecondsToTime() ?? ""
//                    }else{
//                        imageString = "video_outgoing"
//                        titleText = "Video Call"
//                        durationText = duration.durationInMilliseconds?.millisecondsToTime() ?? ""
//                    }
//                } else {
//                    imageString = ""
//                    titleText = ""
//                    durationText = ""
//                }
//            } else {
//                //correct
//                if messageType == .AudioCall{
//                    imageString = "audio_outgoing"
//                    titleText = "Voice Call"
//                    durationText = "No answer"
//                }else{
//                    imageString = "video_outgoing"
//                    titleText = "Video Call"
//                    durationText = "No answer"
//                }
//            }
//        }else{
//            if message.missedByMembers.count == 0{
//                if let duration = message.callDurations.first(where: { $0.memberId == userSession.getUserId() }) {
//                    if messageType == .AudioCall{
//                        imageString = "audio_incoming"
//                        titleText = "Voice Call"
//                        durationText = duration.durationInMilliseconds?.millisecondsToTime() ?? ""
//                    }else{
//                        imageString = "video_incoming"
//                        titleText = "Video Call"
//                        durationText = duration.durationInMilliseconds?.millisecondsToTime() ?? ""
//                    }
//                } else {
//                    if messageType == .AudioCall{
//                        imageString = "audio_missedCall"
//                        titleText = "Missed voice call"
//                        durationText = "Tap to call back"
//                    }else{
//                        imageString = "video_missedCall"
//                        titleText = "Missed video call"
//                        durationText = "Tap to call back"
//                    }
//                }
//            }else{
//                //correct
//                if messageType == .AudioCall{
//                    imageString = "audio_missedCall"
//                    titleText = "Missed voice call"
//                    durationText = "Tap to call back"
//                }else{
//                    imageString = "video_missedCall"
//                    titleText = "Missed video call"
//                    durationText = "Tap to call back"
//                }
//            }
//        }
//        
//        
//        return HStack(spacing: 10){
//            Image(imageString)
//                .resizable()
//                .frame(width: 38, height: 38, alignment: .center)
//            VStack(alignment : .leading,spacing : 5){
//                Text(titleText)
//                    .font(themeFonts.messageListcallingHeader)
//                    .foregroundColor(themeColor.messageListcallingHeader)
//                HStack{
//                    Text(durationText)
//                        .font(themeFonts.messageListcallingTime)
//                        .foregroundColor(themeColor.messageListcallingTime)
//                    Spacer()
//                    Text(message.sentAt.datetotime())
//                        .font(themeFonts.messageListMessageTime)
//                        .foregroundColor(isReceived ? themeColor.messageListMessageTextReceived :  themeColor.messageListMessageTimeSend)
//                }
//            }
//        }
//    }

    func getImageAsset() -> ImageAsset {
        var imageAsset: ImageAsset

        if message.initiatorId == userData.userId {
            if message.missedByMembers.count == 0 {
                if let duration = message.callDurations.first(where: { $0.memberId == userData.userId }) {
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
                if let duration = message.callDurations.first(where: { $0.memberId == userData.userId }) {
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
    
    func dateAndStatusView(onImage : Bool) -> some View{
        HStack(alignment: .center,spacing: 3){
            Text(message.sentAt.datetotime())
                .font(appearance.fonts.messageListMessageTime)
                .foregroundColor(onImage ? Color.white : (isReceived ? appearance.colorPalette.messageListMessageTimeReceived :  appearance.colorPalette.messageListMessageTimeSend))
            if message.metaData?.isBroadCastMessage == true && fromBroadCastFlow != true && !isReceived && !message.deletedMessage{
                Image("broadcastMessageIcon")
                    .resizable()
                    .frame(width: 11, height: 10)
            }
            if !isReceived && !message.deletedMessage{
                switch self.messageDeliveredType{
                case .BlueTick:
                    appearance.images.messageRead
                        .resizable()
                        .frame(width: 15, height: 9)
                case .DoubleTick:
                    appearance.images.messageDelivered
                        .resizable()
                        .frame(width: 15, height: 9)
                case .SingleTick:
                    appearance.images.messageSent
                        .resizable()
                        .frame(width: 11, height: 9)
                case .Clock:
                    appearance.images.messagePending
                        .resizable()
                        .frame(width: 9, height: 9)
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



enum PaymentRequestStatus {
    case active
    case accept
    case declined
    case expired
}

struct PaymentRequestUI: View {
    var status: PaymentRequestStatus
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                // Header and Payment Status
                headerView
                
                // Payment Amount
                VStack(spacing: 8) {
                    Text("Total you pay")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("28.00 JOD")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    // Conditional Messages Based on Status
                    if status == .active {
                        Text("Payment request will expire in 5:3:00")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    } else if status == .declined {
                        Text("You declined the payment request")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    } else if status == .expired {
                        Text("Payment request expired")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 16)
                
                // Action Buttons for Active Request Only
                if status == .active {
                    HStack(spacing: 20) {
                        Button(action: {
                            // Decline action
                        }) {
                            Text("Decline")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                        
                        Button(action: {
                            // View Details action
                        }) {
                            Text("View Details")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Timestamp
                HStack {
                    Spacer()
                    Text("11:27 pm")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 16)
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 4)
            .padding()
            .blur(radius: status == .expired ? 2 : 0) // Blurred effect when expired
            
            // Dimmed overlay for the expired view
            if status == .expired {
                Color.black.opacity(0.2)
                    .cornerRadius(16)
                    .padding()
            }
        }
    }
    
    // Header View Based on Status
    @ViewBuilder
    private var headerView: some View {
        if status == .active {
            Text("Payment Request")
                .font(.headline)
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(10, corners: [.topLeft, .topRight])
        } else if status == .declined {
            Text("Request Declined")
                .font(.headline)
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(10, corners: [.topLeft, .topRight])
        } else if status == .expired {
            Text("Payment Request")
                .font(.headline)
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray)
                .cornerRadius(10, corners: [.topLeft, .topRight])
        }
    }
}
