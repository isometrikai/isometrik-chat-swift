//
//  ISMMessageInfoSubView.swift
//  ISMChatSdk
//
//  Created by Rahul Sharma on 24/08/23.
//

import SwiftUI
import LinkPresentation
import AVKit
import GoogleMaps
import CoreLocation
import MapKit
import SDWebImageSwiftUI
import IsometrikChat

struct ISMMessageInfoSubView: View {
    
    //MARK:  - PROPERTIES
    
    @Binding var previousAudioRef: AudioPlayViewModel?
    
    var messageType : ISMChatMessageType
    var message : MessagesDB
    var userId : String?
    var viewWidth : CGFloat
    var isReceived : Bool
    var messageDeliveredType : ISMChatMessageStatus = .Clock
    let conversationId : String
    @ObservedObject var viewModel = ChatsViewModel()
    @State private var offset = CGSize.zero
    @State var metaData : LPLinkMetadata? = nil
    let pasteboard = UIPasteboard.general
    @State private var completeAddress : String = ""
    @EnvironmentObject var realmManager : RealmManager
    var isGroup : Bool?
    
    //mention flow
    @State var navigateToInfo : Bool = false
    @State var navigatetoUser : ISMChatGroupMember = ISMChatGroupMember()
    let groupconversationMember : [ISMChatGroupMember]
    @State private var pdfthumbnailImage : UIImage = UIImage()
    
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    let customFontName = ISMChatSdkUI.getInstance().getCustomFontNames()
    @State var userData = ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig
    
    let fromBroadCastFlow : Bool?
    
    //MARK:  - BODY
    var body: some View {
        HStack{
            if message.deletedMessage == true{
                ZStack{
                    VStack(alignment: isReceived == true ? .leading : .trailing, spacing: 2){
                        HStack{
                            Image(systemName: "minus.circle")
                                .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                            Text(isReceived == true ? "This message was deleted." :  "You deleted this message.")
                                .font(appearance.fonts.messageListMessageDeleted)
                                .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                        }
                        .opacity(0.2)
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
                switch messageType {
                    
                    //MARK: - Text Message View
                case .text:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true{
                            inGroupUserAvatarView()
                        }
                        ZStack{
                            let str = message.body
                            VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                                if isGroup == true && isReceived == true{
                                    inGroupUserName()
                                }
                                VStack(alignment: .trailing, spacing: 0){
                                    if message.customType == ISMChatMediaType.ReplyText.value && message.messageType != 1{
                                        repliedMessageView()
                                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 5))
                                    }
                                    if message.messageType == 1{
                                        forwardedView()
                                    }
                                    if message.messageUpdated == true{
                                        editedView()
                                    }
                                    VStack(alignment: .leading, spacing: 5){
                                        HStack{
                                            if ISMChatHelper.isValidEmail(str) == true{
                                                Link(str, destination: URL(string: "mailto:apple@me.com")!)
                                                    .font(appearance.fonts.messageListMessageText)
                                                    .foregroundColor(appearance.colorPalette.userProfileEditText)
                                                    .underline(true, color: appearance.colorPalette.userProfileEditText)
                                            }else if  ISMChatHelper.isValidPhone(phone: str) == true{
                                                Link(str, destination: URL(string: "tel:\(str)")!)
                                                    .font(appearance.fonts.messageListMessageText)
                                                    .foregroundColor(appearance.colorPalette.userProfileEditText)
                                                    .underline(true, color: appearance.colorPalette.userProfileEditText)
                                            }
                                            else if str.isValidURL || str.contains("www."){
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
                                                    Text(str)
                                                        .font(appearance.fonts.messageListMessageText)
                                                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                        .onTapGesture {
                                                            if str.contains("https"){
                                                                openURLInSafari(urlString: str)
                                                            }else{
                                                                let fullURLString = "https://" + str.trimmingCharacters(in: .whitespaces)
                                                                openURLInSafari(urlString: fullURLString)
                                                            }
                                                        }
                                                }
                                            }
                                            else{
                                                if str.contains("@") && isGroup == true{
                                                    HighlightedTextView(originalText: str, mentionedUsers: groupconversationMember, isReceived: self.isReceived, navigateToInfo: $navigateToInfo, navigatetoUser: $navigatetoUser)
                                                }else{
                                                    ISMChatExpandableText(str, lineLimit: 5, isReceived: isReceived)
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
                        if isGroup == true && isReceived == true{
                            inGroupUserAvatarView()
                        }
                        VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                            if isGroup == true && isReceived == true{
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
                                            
                                            ISMImageViewer(url: metaData.contacts.first?.contactImageUrl ?? "", size: CGSizeMake(40, 40), cornerRadius: 20)
                                            
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
                                            if appearance.timeInsideBubble == true{
                                                dateAndStatusView(onImage: false)
                                            }
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
                        .padding(.vertical, 2)
                    }
                    
                    //MARK: - Photo Message View
                case .photo:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true{
                            inGroupUserAvatarView()
                        }
                        VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                            if isGroup == true && isReceived == true{
                                //when its group show member name in message
                                inGroupUserName()
                            }
                            //                        NavigationLink(destination:  MediaSliderView(messageId: message.messageId).environmentObject(self.realmManager))
                            //                        {
                            VStack(alignment: .trailing,spacing: 5){
                                if message.messageType == 1{
                                    forwardedView()
                                }
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
                                    if  appearance.timeInsideBubble == true{
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
                                    
                                    if  appearance.timeInsideBubble == true{
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
                            //                        }
                            if  appearance.timeInsideBubble == false{
                                dateAndStatusView(onImage: false)
                            }
                        }.padding(.vertical,2)
                    }
                    
                    //MARK: - Video Message View
                case .video:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true{
                            inGroupUserAvatarView()
                        }
                        VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                            if isGroup == true && isReceived == true{
                                //when its group show member name in message
                                inGroupUserName()
                            }
                            
                            //                        NavigationLink(destination: MediaSliderView(messageId: message.messageId).environmentObject(self.realmManager)){
                            VStack(alignment: .trailing,spacing : 5){
                                if message.messageType == 1{
                                    forwardedView()
                                }
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
                                                ISMImageViewer(url: message.attachments.first?.thumbnailUrl ?? "", size: CGSizeMake(250, 300), cornerRadius: 5)
                                                    .overlay(
                                                        LinearGradient(gradient: Gradient(colors: [.clear,.clear,.clear, Color.black.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                                            .frame(width: 250, height: 300)
                                                            .mask(
                                                                RoundedRectangle(cornerRadius: 5)
                                                                    .fill(Color.white)
                                                            )
                                                    )
                                                if  appearance.timeInsideBubble == true{
                                                    if message.metaData?.captionMessage == nil{
                                                        dateAndStatusView(onImage: true)
                                                            .padding(.bottom,5)
                                                            .padding(.trailing,5)
                                                    }
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
                                            if  appearance.timeInsideBubble == true{
                                                if message.metaData?.captionMessage == nil{
                                                    dateAndStatusView(onImage: true)
                                                        .padding(.bottom,5)
                                                        .padding(.trailing,5)
                                                }
                                            }
                                        }
                                    }
                                    Image("playvideo")
                                        .resizable()
                                        .frame(width: 48,height: 48)
                                    
                                }
                                
                                if let caption = message.metaData?.captionMessage, !caption.isEmpty{
                                    Text(caption)
                                        .font(appearance.fonts.messageListMessageText)
                                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                    if  appearance.timeInsideBubble == true{
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
                            //                        }//:NavigationLink
                            //                                }
                            if  appearance.timeInsideBubble == false{
                                dateAndStatusView(onImage: false)
                            }
                        } .padding(.vertical, 2)
                    }
                    
                    //MARK: - Video Message View
                case .document:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true{
                            inGroupUserAvatarView()
                        }
                        VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                            if isGroup == true && isReceived == true{
                                //when its group show member name in message
                                inGroupUserName()
                            }
                            if let documentUrl = URL(string: message.attachments.first?.mediaUrl ?? ""){
                                let urlExtension = ISMChatHelper.getExtensionFromURL(url: documentUrl)
                                let fileName = ISMChatHelper.getFileNameFromURL(url: documentUrl)
//                                NavigationLink(destination: ISMDocumentViewer(url: documentUrl, title: fileName)){
                                    ZStack{
                                        VStack(alignment: .trailing, spacing: 5){
                                            if message.messageType == 1{
                                                forwardedView()
                                            }
                                            
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
                                                                .frame(width: 30, height: 30)
                                                            
                                                            Text(fileName)
                                                                .font(appearance.fonts.messageListMessageText)
                                                                .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                                                                .fixedSize(horizontal: false, vertical: true)
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            if  appearance.timeInsideBubble == true{
                                                dateAndStatusView(onImage: false)
                                                    .padding(.bottom,(message.reactions.count > 0) ? 5 : 0)
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
//                                }
                            }
                            if  appearance.timeInsideBubble == false{
                                dateAndStatusView(onImage: false)
                            }
                        }.padding(.vertical,2)
                    }
                    
                    //MARK: - Location Message View
                case .location:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true{
                            inGroupUserAvatarView()
                        }
                        VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                            if isGroup == true && isReceived == true{
                                //when its group show member name in message
                                inGroupUserName()
                            }
                            ZStack{
                                VStack(alignment: .trailing, spacing: 5){
                                    if message.messageType == 1{
                                        forwardedView()
                                    }
                                    
                                    ISMLocationSubView(message: message)
                                        .cornerRadius(5)
                                        .contentShape(Rectangle())
                                        .allowsHitTesting(true)
                                    
                                    HStack{
                                        Text(message.attachments.first?.title ?? "")
                                            .font(appearance.fonts.messageListMessageText)
                                            .foregroundColor(appearance.colorPalette.userProfileEditText)
                                        Spacer()
                                        
                                    }
                                    HStack{
                                        Text(message.attachments.first?.address ?? "")
                                            .font(appearance.fonts.messageListReplyToolbarDescription)
                                            .foregroundColor(appearance.colorPalette.messageListTextViewPlaceholder)
                                        Spacer()
                                    }
                                    if  appearance.timeInsideBubble == true{
                                        dateAndStatusView(onImage: false)
                                            .padding(.bottom,(message.reactions.count > 0) ? 5 : 0)
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
                            if  appearance.timeInsideBubble == false{
                                dateAndStatusView(onImage: false)
                                    .padding(.bottom,(message.reactions.count > 0) ? 5 : 0)
                            }
                        }
                        .padding(.vertical,2)
                    }
                    
                    //MARK: - Audio Message View
                case .audio:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true{
                            inGroupUserAvatarView()
                        }
                        VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                            if isGroup == true && isReceived == true{
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
                            if  appearance.timeInsideBubble == false{
                                dateAndStatusView(onImage: false)
                                    .padding(.bottom,(message.reactions.count > 0) ? 5 : 0)
                            }
                        }
                        .padding(.vertical,2)
                    }
                case .VideoCall:
                    HStack(alignment: .bottom){
                        VStack(alignment: .leading, spacing: 2){
                            if isGroup == true && isReceived == true{
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
                            }//:ZStack
                        }
                        .padding(.vertical,2)
                    }
                case .AudioCall:
                    HStack(alignment: .bottom){
                        VStack(alignment: .leading, spacing: 2){
                            if isGroup == true && isReceived == true{
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
                            }//:ZStack
                        }
                        .padding(.vertical,2)
                    }
                case .gif:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true{
                            inGroupUserAvatarView()
                        }
                        VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                            if isGroup == true && isReceived == true{
                                //when its group show member name in message
                                inGroupUserName()
                            }
                            
                            //                        NavigationLink(destination:  MediaSliderView(messageId: message.messageId).environmentObject(self.realmManager))
                            //                        {
                            VStack(alignment: .trailing,spacing: 5){
                                if message.messageType == 1{
                                    forwardedView()
                                }
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
                                    if  appearance.timeInsideBubble == true{
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
                                    if  appearance.timeInsideBubble == true{
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
                            //                        }
                            if  appearance.timeInsideBubble == false{
                                dateAndStatusView(onImage: false)
                                    .padding(.bottom,5)
                                    .padding(.trailing,5)
                            }
                        }.padding(.vertical,2)
                    }
                case .sticker:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true{
                            inGroupUserAvatarView()
                        }
                        VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                            if isGroup == true && isReceived == true{
                                //when its group show member name in message
                                inGroupUserName()
                            }
                            VStack(alignment: .trailing,spacing: 5){
                                AnimatedImage(url: URL(string: message.attachments.first?.mediaUrl ?? ""))
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(5)
                                if  appearance.timeInsideBubble == true{
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
                                        .padding(.trailing,5)
                                }
                                
                                
                            }//:ZStack
                            .padding(5)
                            .padding(.vertical,5)
                        }.padding(.vertical,2)
                    }
                    //MARK: - Post Message View
                case .post:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true{
                            //When its group show member avatar in message
                            inGroupUserAvatarView()
                        }
                        ZStack(alignment: .bottomTrailing){
                            VStack(alignment: isReceived ? .leading : .trailing, spacing: 2){
                                if isGroup == true && isReceived == true{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                
                                VStack(alignment: .trailing,spacing: 5){
                                    postButtonView(isPost: true)
                                    
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
                                if  appearance.timeInsideBubble == false{
                                    dateAndStatusView(onImage: false)
                                        .padding(.bottom,5)
                                        .padding(.trailing,5)
                                }
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
                                            postButtonView(isPost: false)
                                        }else{
                                            //it will act same as productLink
                                            productLinkView(message: message)
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
                                    Button {
                                        
                                    } label: {
                                        productLinkView(message: message)
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
                                    Button {
                                       
                                    } label: {
                                        socialLinkView(message: message)
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
                        }.padding(.vertical,2)
                    }
                default:
                    EmptyView()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: isReceived ? .leading :.trailing)
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
    }//:Body
    
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
                    
                    Text(message.metaData?.productName ?? "")
                        .font(Font.custom(customFontName.medium, size: 14))
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
            }
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
            )
            .frame(width: 248)
            .padding(.horizontal,5)
            
            if let url = message.metaData?.url{
                Text(url)
                    .font(appearance.fonts.messageListMessageText)
                    .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived :  appearance.colorPalette.messageListMessageTextSend)
                    .padding(.horizontal,5)
            }
            
            // Time and Status (if needed)
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
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(appearance.colorPalette.messageListMessageBorderColor, lineWidth: 1)
            )
            .frame(width: 248)
            
            if let url = message.metaData?.url{
                Text(url)
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
                    ISMImageViewer(url: isPost == true ? (message.metaData?.post?.postUrl ?? "") : (message.metaData?.product?.productUrl ?? ""), size: isPost == true ? CGSizeMake(124, 249) : CGSizeMake(250, 300), cornerRadius: 5)
                        .overlay(
                            LinearGradient(gradient: Gradient(colors: [.clear,.clear,.clear, Color.black.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                .frame(width: 250, height: 300)
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
    
    func dateAndStatusView(onImage : Bool) -> some View{
        HStack(alignment: .center,spacing: 3){
            Text(message.sentAt.datetotime())
                .font(Font.regular(size: 12))
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
    
    func forwardedView() -> some View{
        HStack(alignment: .center, spacing: 2) {
            Image("forwarded")
                .resizable()
                .frame(width: 14, height: 14, alignment: .center)
            Text("Forwarded")
                .font(Font.italic(size: 12))
                .foregroundStyle(Color.onboardingPlaceholder)
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
    
    private func getExtensionFromURL(url: URL) -> String? {
        let filename = url.lastPathComponent
        let components = filename.components(separatedBy: "_")
        guard let lastComponent = components.last else { return "" }
        return NSURL(fileURLWithPath: lastComponent).pathExtension
    }
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 70) / 2 // between 0.1 and 35
        
        return CGFloat(level * (40/35))
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
    
    func getAddressFromLatLon(Latitude: String,Longitude: String, completion:@escaping(String?)->()){
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(Latitude)")!
        let lon: Double = Double("\(Longitude)")!
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        var addressString : String = ""
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
            if (error != nil){
                ISMChatHelper.print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            if let pm = placemarks{
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    completion(addressString)
                }
            }
        })
    }
    
    
    func repliedMessageView() -> some View{
        HStack{
            Rectangle()
                .fill(appearance.colorPalette.messageListReplyToolbarRectangle)
                .frame(width: 4)
            VStack(alignment: .leading, spacing: 2){
                let parentUserName = message.metaData?.replyMessage?.parentMessageUserName ?? "User"
                let parentUserID = message.metaData?.replyMessage?.parentMessageUserId
                let name = parentUserID == userData.userId ? ConstantStrings.you : parentUserName
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
                    AnimatedImage(url: URL(string: message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? ""))
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
                }else{
                    Text(msg)
                        .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                        .font(appearance.fonts.messageListReplyToolbarDescription)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 8))
            if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.Image.value{
                ISMImageViewer(url:  message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? "", size: CGSizeMake(45, 40), cornerRadius: 0)
//                ISMChatImageCahcingManger.viewImage(url: message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? "")
//                    .scaledToFill()
//                    .frame(width: 45, height: 40)
            }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.Video.value{
                ISMImageViewer(url:  message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? "", size: CGSizeMake(45, 40), cornerRadius: 0)
//                ISMChatImageCahcingManger.viewImage(url: message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? "")
//                    .scaledToFill()
//                    .frame(width: 45, height: 40)
            }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.File.value{
                Image(uiImage: pdfthumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height: 40)
            }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.gif.value{
                AnimatedImage(url: URL(string: message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? ""))
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
        }.fixedSize(horizontal: false, vertical: true)
        .background(Color.docBackground)
        .cornerRadius(5, corners: .allCorners)
    }
    
    func editedView() -> some View{
        Text("Edited")
            .font(appearance.fonts.messageListMessageEdited)
            .foregroundColor(appearance.colorPalette.messageListMessageEdited)
    }
    
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
                        .foregroundColor(isReceived ? appearance.colorPalette.messageListMessageTextReceived : appearance.colorPalette.messageListMessageTimeSend)
                }
            }
        }
    }

}
