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
    
    @State var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State var themeImages = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    @State var themeBubbleType = ISMChatSdkUI.getInstance().getAppAppearance().appearance.messageBubbleType
    @State var userData = ISMChatSdk.getInstance().getChatClient().getConfigurations().userConfig
    
    let fromBroadCastFlow : Bool?
    
    //MARK:  - BODY
    var body: some View {
        HStack{
            switch messageType {
                
                //MARK: - Text Message View
            case .text:
                HStack(alignment: .bottom){
                    if isGroup == true && isReceived == true{
                        inGroupUserAvatarView()
                    }
                    ZStack{
                        let str = message.body
                        VStack(alignment: .leading, spacing: 2){
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
                                VStack(alignment: .trailing, spacing: 5){
                                    HStack{
                                        if ISMChatHelper.isValidEmail(str) == true{
                                            Link(str, destination: URL(string: "mailto:apple@me.com")!)
                                                .font(themeFonts.messageListMessageText)
                                                .foregroundColor(themeColor.userProfileEditText)
                                                .underline(true, color: themeColor.userProfileEditText)
                                        }else if  ISMChatHelper.isValidPhone(phone: str) == true{
                                            Link(str, destination: URL(string: "tel:\(str)")!)
                                                .font(themeFonts.messageListMessageText)
                                                .foregroundColor(themeColor.userProfileEditText)
                                                .underline(true, color: themeColor.userProfileEditText)
                                        }
                                        else if str.isValidURL || str.contains("www."){
//                                            ISMLinkPreview(urlString: str)
//                                                .font(themeFonts.messageListMessageText)
//                                                .foregroundColor(themeColor.messageListMessageText)
                                        }
                                        else{
                                            if str.contains("@") && isGroup == true{
                                                HighlightedTextView(originalText: str, mentionedUsers: groupconversationMember, isReceived: self.isReceived, navigateToInfo: $navigateToInfo, navigatetoUser: $navigatetoUser)
                                            }else{
                                                Text(str)
                                                    .font(themeFonts.messageListMessageText)
                                                    .foregroundColor(isReceived ? themeColor.messageListMessageTextReceived :  themeColor.messageListMessageTextSend)
                                            }
                                        }
                                    }
                                    dateAndStatusView(onImage: false)
                                }
                            }//:VStack
                            .padding(.horizontal, str.isValidURL || str.contains("www.") == true ? 5 : 10)
                            .padding(.vertical,str.isValidURL || str.contains("www.") == true ? 5 : 8)
                            .background(isReceived ? themeColor.messageListReceivedMessageBackgroundColor : themeColor.messageListSendMessageBackgroundColor)
                            .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: self.themeBubbleType, direction: isReceived ? .left : .right))
                            .overlay(
                                themeBubbleType == .BubbleWithOutTail ?
                                    AnyView(
                                        UnevenRoundedRectangle(
                                            topLeadingRadius: 8,
                                            bottomLeadingRadius: isReceived ? 0 : 8,
                                            bottomTrailingRadius: isReceived ? 8 : 0,
                                            topTrailingRadius: 8,
                                            style: .circular
                                        )
                                        .stroke(themeColor.messageListMessageBorderColor, lineWidth: 1)
                                    ) : AnyView(EmptyView())
                            )
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
                    VStack(alignment: .leading, spacing: 2){
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
                                        
                                        
                                        ISMChatImageCahcingManger.networkImage(url: metaData.contacts.first?.contactImageUrl ?? "" ,isprofileImage: true)
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .cornerRadius(20)
                                        
                                        let name = metaData.contacts.first?.contactName ?? ""
                                        if metaData.contacts.count == 1{
                                            Text(name)
                                                .font(themeFonts.messageListMessageText)
                                                .foregroundColor(isReceived ? themeColor.messageListMessageTextReceived :  themeColor.messageListMessageTextSend)
                                        }else{
                                            Text("\(name) and \((metaData.contacts.count) - 1) other contact")
                                                .font(themeFonts.messageListMessageText)
                                                .foregroundColor(isReceived ? themeColor.messageListMessageTextReceived :  themeColor.messageListMessageTextSend)
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
                                            .font(themeFonts.messageListMessageText)
                                            .foregroundColor(themeColor.userProfileEditText)
                                        Spacer()
                                    }.padding(.vertical,5)
                                }
                                .frame(width: 250)
                                .padding(5)
                                .background(isReceived ? themeColor.messageListReceivedMessageBackgroundColor : themeColor.messageListSendMessageBackgroundColor)
                                .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: self.themeBubbleType, direction: isReceived ? .left : .right))
                                .overlay(
                                    themeBubbleType == .BubbleWithOutTail ?
                                        AnyView(
                                            UnevenRoundedRectangle(
                                                topLeadingRadius: 8,
                                                bottomLeadingRadius: isReceived ? 0 : 8,
                                                bottomTrailingRadius: isReceived ? 8 : 0,
                                                topTrailingRadius: 8,
                                                style: .circular
                                            )
                                            .stroke(themeColor.messageListMessageBorderColor, lineWidth: 1)
                                        ) : AnyView(EmptyView())
                                )
                            }
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
                    VStack(alignment: .leading, spacing: 2){
                        if isGroup == true && isReceived == true{
                            //when its group show member name in message
                            inGroupUserName()
                        }
                        NavigationLink(destination:  MediaSliderView(messageId: message.messageId).environmentObject(self.realmManager))
                        {
                            VStack(alignment: .trailing,spacing: 5){
                                if message.messageType == 1{
                                    forwardedView()
                                }
                                ZStack(alignment: .bottomTrailing){
                                    ISMChatImageCahcingManger.networkImage(url: message.attachments.first?.mediaUrl ?? "",isprofileImage: false)
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
                                if let caption = message.metaData?.captionMessage, !caption.isEmpty{
                                    Text(caption)
                                        .font(themeFonts.messageListMessageText)
                                        .foregroundColor(isReceived ? themeColor.messageListMessageTextReceived :  themeColor.messageListMessageTextSend)
                                    
                                    dateAndStatusView(onImage: false)
                                        .padding(.bottom,5)
                                        .padding(.trailing,5)
                                    
                                }
                            }//:ZStack
                            .padding(5)
                            .background(isReceived ? themeColor.messageListReceivedMessageBackgroundColor : themeColor.messageListSendMessageBackgroundColor)
                            .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: self.themeBubbleType, direction: isReceived ? .left : .right))
                            .overlay(
                                themeBubbleType == .BubbleWithOutTail ?
                                    AnyView(
                                        UnevenRoundedRectangle(
                                            topLeadingRadius: 8,
                                            bottomLeadingRadius: isReceived ? 0 : 8,
                                            bottomTrailingRadius: isReceived ? 8 : 0,
                                            topTrailingRadius: 8,
                                            style: .circular
                                        )
                                        .stroke(themeColor.messageListMessageBorderColor, lineWidth: 1)
                                    ) : AnyView(EmptyView())
                            )
                        }
                    }.padding(.vertical,2)
                }
                
                //MARK: - Video Message View
            case .video:
                HStack(alignment: .bottom){
                    if isGroup == true && isReceived == true{
                        inGroupUserAvatarView()
                    }
                    VStack(alignment: .leading, spacing: 2){
                        if isGroup == true && isReceived == true{
                            //when its group show member name in message
                            inGroupUserName()
                        }
                     
                        NavigationLink(destination: MediaSliderView(messageId: message.messageId).environmentObject(self.realmManager)){
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
                                                ISMChatImageCahcingManger.networkImage(url: message.attachments.first?.thumbnailUrl ?? "", isprofileImage: false)
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
                                            ISMChatImageCahcingManger.networkImage(url: message.attachments.first?.thumbnailUrl ?? "", isprofileImage: false)
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
                                    Image("playvideo")
                                        .resizable()
                                        .frame(width: 48,height: 48)
                                    
                                }
                                
                                if let caption = message.metaData?.captionMessage, !caption.isEmpty{
                                    Text(caption)
                                        .font(themeFonts.messageListMessageText)
                                        .foregroundColor(isReceived ? themeColor.messageListMessageTextReceived :  themeColor.messageListMessageTextSend)
                                    
                                    dateAndStatusView(onImage: false)
                                        .padding(.bottom,5)
                                        .padding(.trailing,5)
                                }
                                
                            }.padding(5)
                                .background(isReceived ? themeColor.messageListReceivedMessageBackgroundColor : themeColor.messageListSendMessageBackgroundColor)
                                .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: self.themeBubbleType, direction: isReceived ? .left : .right))
                                .overlay(
                                    themeBubbleType == .BubbleWithOutTail ?
                                        AnyView(
                                            UnevenRoundedRectangle(
                                                topLeadingRadius: 8,
                                                bottomLeadingRadius: isReceived ? 0 : 8,
                                                bottomTrailingRadius: isReceived ? 8 : 0,
                                                topTrailingRadius: 8,
                                                style: .circular
                                            )
                                            .stroke(themeColor.messageListMessageBorderColor, lineWidth: 1)
                                        ) : AnyView(EmptyView())
                                )
                        }//:NavigationLink
                        //                                }
                    } .padding(.vertical, 2)
                }
                
                //MARK: - Video Message View
            case .document:
                HStack(alignment: .bottom){
                    if isGroup == true && isReceived == true{
                        inGroupUserAvatarView()
                    }
                    VStack(alignment: .leading, spacing: 2){
                        if isGroup == true && isReceived == true{
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
                                                    ISMChatImageCahcingManger.networkImage(url: message.attachments.first?.mediaUrl ?? "",isprofileImage: false)
                                                        .scaledToFill()
                                                        .frame(width: 250, height: 300)
                                                        .cornerRadius(5)
                                                    
                                                }else{
                                                    if urlExtension == "pdf" {
                                                        ISMPDFMessageView(pdfURL: documentUrl, fileName: fileName)
                                                    } else {
                                                        themeImages.pdfLogo
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 30, height: 30)
                                                        
                                                        Text(fileName)
                                                            .font(themeFonts.messageListMessageText)
                                                            .foregroundColor(isReceived ? themeColor.messageListMessageTextReceived :  themeColor.messageListMessageTextSend)
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
                                    .background(isReceived ? themeColor.messageListReceivedMessageBackgroundColor : themeColor.messageListSendMessageBackgroundColor)
                                    .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: self.themeBubbleType, direction: isReceived ? .left : .right))
                                    .overlay(
                                        themeBubbleType == .BubbleWithOutTail ?
                                            AnyView(
                                                UnevenRoundedRectangle(
                                                    topLeadingRadius: 8,
                                                    bottomLeadingRadius: isReceived ? 0 : 8,
                                                    bottomTrailingRadius: isReceived ? 8 : 0,
                                                    topTrailingRadius: 8,
                                                    style: .circular
                                                )
                                                .stroke(themeColor.messageListMessageBorderColor, lineWidth: 1)
                                            ) : AnyView(EmptyView())
                                    )
                                }//:ZStack
                            }
                        }
                    }.padding(.vertical,2)
                }
                
                //MARK: - Location Message View
            case .location:
                HStack(alignment: .bottom){
                    if isGroup == true && isReceived == true{
                        inGroupUserAvatarView()
                    }
                    VStack(alignment: .leading, spacing: 2){
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
                                        .font(themeFonts.messageListMessageText)
                                        .foregroundColor(themeColor.userProfileEditText)
                                    Spacer()
                                    
                                }
                                HStack{
                                    Text(message.attachments.first?.address ?? "")
                                        .font(themeFonts.messageListReplyToolbarDescription)
                                        .foregroundColor(themeColor.messageListTextViewPlaceholder)
                                    Spacer()
                                }
                                dateAndStatusView(onImage: false)
                                    .padding(.bottom,(message.reactions.count > 0) ? 5 : 0)
                            }//:VStack
                            .frame(width: 250)
                            .padding(5)
                            .background(isReceived ? themeColor.messageListReceivedMessageBackgroundColor : themeColor.messageListSendMessageBackgroundColor)
                            .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: self.themeBubbleType, direction: isReceived ? .left : .right))
                            .overlay(
                                themeBubbleType == .BubbleWithOutTail ?
                                    AnyView(
                                        UnevenRoundedRectangle(
                                            topLeadingRadius: 8,
                                            bottomLeadingRadius: isReceived ? 0 : 8,
                                            bottomTrailingRadius: isReceived ? 8 : 0,
                                            topTrailingRadius: 8,
                                            style: .circular
                                        )
                                        .stroke(themeColor.messageListMessageBorderColor, lineWidth: 1)
                                    ) : AnyView(EmptyView())
                            )
                        }//:ZStack
                    }
                    .padding(.vertical,2)
                }
                
                //MARK: - Audio Message View
            case .audio:
                HStack(alignment: .bottom){
                    if isGroup == true && isReceived == true{
                        inGroupUserAvatarView()
                    }
                    VStack(alignment: .leading, spacing: 2){
                        if isGroup == true && isReceived == true{
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
                            .background(isReceived ? themeColor.messageListReceivedMessageBackgroundColor : themeColor.messageListSendMessageBackgroundColor)
                            .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: self.themeBubbleType, direction: isReceived ? .left : .right))
                            .overlay(
                                themeBubbleType == .BubbleWithOutTail ?
                                    AnyView(
                                        UnevenRoundedRectangle(
                                            topLeadingRadius: 8,
                                            bottomLeadingRadius: isReceived ? 0 : 8,
                                            bottomTrailingRadius: isReceived ? 8 : 0,
                                            topTrailingRadius: 8,
                                            style: .circular
                                        )
                                        .stroke(themeColor.messageListMessageBorderColor, lineWidth: 1)
                                    ) : AnyView(EmptyView())
                            )
                        }//:ZStack
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
                            .background(isReceived ? themeColor.messageListReceivedMessageBackgroundColor : themeColor.messageListSendMessageBackgroundColor)
                            .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: self.themeBubbleType, direction: isReceived ? .left : .right))
                            .overlay(
                                themeBubbleType == .BubbleWithOutTail ?
                                    AnyView(
                                        UnevenRoundedRectangle(
                                            topLeadingRadius: 8,
                                            bottomLeadingRadius: isReceived ? 0 : 8,
                                            bottomTrailingRadius: isReceived ? 8 : 0,
                                            topTrailingRadius: 8,
                                            style: .circular
                                        )
                                        .stroke(themeColor.messageListMessageBorderColor, lineWidth: 1)
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
                            .background(isReceived ? themeColor.messageListReceivedMessageBackgroundColor : themeColor.messageListSendMessageBackgroundColor)
                            .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: self.themeBubbleType, direction: isReceived ? .left : .right))
                            .overlay(
                                themeBubbleType == .BubbleWithOutTail ?
                                    AnyView(
                                        UnevenRoundedRectangle(
                                            topLeadingRadius: 8,
                                            bottomLeadingRadius: isReceived ? 0 : 8,
                                            bottomTrailingRadius: isReceived ? 8 : 0,
                                            topTrailingRadius: 8,
                                            style: .circular
                                        )
                                        .stroke(themeColor.messageListMessageBorderColor, lineWidth: 1)
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
                    VStack(alignment: .leading, spacing: 2){
                        if isGroup == true && isReceived == true{
                            //when its group show member name in message
                            inGroupUserName()
                        }
                        
                        NavigationLink(destination:  MediaSliderView(messageId: message.messageId).environmentObject(self.realmManager))
                        {
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
                                    if message.metaData?.captionMessage == nil{
                                        dateAndStatusView(onImage: true)
                                            .padding(.bottom,5)
                                            .padding(.trailing,5)
                                    }
                                }
                                if let caption = message.metaData?.captionMessage, !caption.isEmpty{
                                    Text(caption)
                                        .font(themeFonts.messageListMessageText)
                                        .foregroundColor(isReceived ? themeColor.messageListMessageTextReceived :  themeColor.messageListMessageTextSend)
                                    
                                    dateAndStatusView(onImage: false)
                                        .padding(.bottom,5)
                                        .padding(.trailing,5)
                                    
                                }
                            }//:ZStack
                            .padding(5)
                            .padding(.vertical,5)
                            .background(isReceived ? themeColor.messageListReceivedMessageBackgroundColor : themeColor.messageListSendMessageBackgroundColor)
                            .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: self.themeBubbleType, direction: isReceived ? .left : .right))
                            .overlay(
                                themeBubbleType == .BubbleWithOutTail ?
                                    AnyView(
                                        UnevenRoundedRectangle(
                                            topLeadingRadius: 8,
                                            bottomLeadingRadius: isReceived ? 0 : 8,
                                            bottomTrailingRadius: isReceived ? 8 : 0,
                                            topTrailingRadius: 8,
                                            style: .circular
                                        )
                                        .stroke(themeColor.messageListMessageBorderColor, lineWidth: 1)
                                    ) : AnyView(EmptyView())
                            )
                        }
                    }.padding(.vertical,2)
                }
            case .sticker:
                HStack(alignment: .bottom){
                    if isGroup == true && isReceived == true{
                        inGroupUserAvatarView()
                    }
                    VStack(alignment: .leading, spacing: 2){
                        if isGroup == true && isReceived == true{
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
                                .background(isReceived ? themeColor.messageListReceivedMessageBackgroundColor : themeColor.messageListSendMessageBackgroundColor)
                                .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: self.themeBubbleType, direction: isReceived ? .left : .right))
                                .overlay(
                                    themeBubbleType == .BubbleWithOutTail ?
                                        AnyView(
                                            UnevenRoundedRectangle(
                                                topLeadingRadius: 8,
                                                bottomLeadingRadius: isReceived ? 0 : 8,
                                                bottomTrailingRadius: isReceived ? 8 : 0,
                                                topTrailingRadius: 8,
                                                style: .circular
                                            )
                                            .stroke(themeColor.messageListMessageBorderColor, lineWidth: 1)
                                        ) : AnyView(EmptyView())
                                )
                            
                            
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
                        VStack(alignment: .leading, spacing: 2){
                            if isGroup == true && isReceived == true{
                                //when its group show member name in message
                                inGroupUserName()
                            }
                            
                                VStack(alignment: .trailing,spacing: 5){
                                    postButtonView()

                                }//:ZStack
                                .padding(5)
                                .background(isReceived ? themeColor.messageListReceivedMessageBackgroundColor : themeColor.messageListSendMessageBackgroundColor)
                                .clipShape(ChatBubbleType(cornerRadius: 8, corners: isReceived ? [.topLeft,.topRight,.bottomRight] : [.topLeft,.topRight,.bottomLeft], bubbleType: self.themeBubbleType, direction: isReceived ? .left : .right))
                                .overlay(
                                    themeBubbleType == .BubbleWithOutTail ?
                                        AnyView(
                                            UnevenRoundedRectangle(
                                                topLeadingRadius: 8,
                                                bottomLeadingRadius: isReceived ? 0 : 8,
                                                bottomTrailingRadius: isReceived ? 8 : 0,
                                                topTrailingRadius: 8,
                                                style: .circular
                                            )
                                            .stroke(themeColor.messageListMessageBorderColor, lineWidth: 1)
                                        ) : AnyView(EmptyView())
                                )
                            
                        }
                    }.padding(.vertical,2)
                }
            default:
                EmptyView()
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
    
    
    func postButtonView() -> some View{
        VStack{
            if message.messageType == 1{
                forwardedView()
            }
            ZStack(alignment: .bottomTrailing){
                ZStack(alignment: .topTrailing){
                    ISMChatImageCahcingManger.networkImage(url: message.metaData?.post?.postUrl ?? "",isprofileImage: false)
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
                    
                    themeImages.postIcon
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
                    .font(themeFonts.messageListMessageText)
                    .foregroundColor(isReceived ? themeColor.messageListMessageTextReceived :  themeColor.messageListMessageTextSend)
                
                dateAndStatusView(onImage: false)
                    .padding(.bottom,5)
                    .padding(.trailing,5)
                
            }
        }
    }
    
    func dateAndStatusView(onImage : Bool) -> some View{
        HStack(alignment: .center,spacing: 3){
            Text(message.sentAt.datetotime())
                .font(Font.regular(size: 12))
                .foregroundColor(onImage ? Color.white : (isReceived ? themeColor.messageListMessageTimeReceived :  themeColor.messageListMessageTimeSend))
            if message.metaData?.isBroadCastMessage == true && fromBroadCastFlow != true && !isReceived && !message.deletedMessage{
                Image("broadcastMessageIcon")
                    .resizable()
                    .frame(width: 11, height: 10)
            }
            if !isReceived && !message.deletedMessage{
                switch self.messageDeliveredType{
                case .BlueTick:
                    themeImages.messageRead
                        .resizable()
                        .frame(width: 15, height: 9)
                case .DoubleTick:
                    themeImages.messageDelivered
                        .resizable()
                        .frame(width: 15, height: 9)
                case .SingleTick:
                    themeImages.messageSent
                        .resizable()
                        .frame(width: 11, height: 9)
                case .Clock:
                    themeImages.messagePending
                        .resizable()
                        .frame(width: 9, height: 9)
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
            .font(themeFonts.messageListgroupMemberUserName)
            .foregroundColor(themeColor.messageListgroupMemberUserName)
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
                .fill(themeColor.messageListReplyToolbarRectangle)
                .frame(width: 4)
            VStack(alignment: .leading, spacing: 2){
                let parentUserName = message.metaData?.replyMessage?.parentMessageUserName ?? "User"
                let parentUserID = message.metaData?.replyMessage?.parentMessageUserId
                let name = parentUserID == userData.userId ? ConstantStrings.you : parentUserName
                Text(name)
                    .foregroundColor(themeColor.messageListReplyToolbarHeader)
                    .font(themeFonts.messageListReplyToolbarHeader)
                let msg = message.metaData?.replyMessage?.parentMessageBody ?? ""
                if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.Image.value{
                    Label {
                        Text(message.metaData?.replyMessage?.parentMessagecaptionMessage != nil ? (message.metaData?.replyMessage?.parentMessagecaptionMessage ?? "Photo") : "Photo")
                            .foregroundColor(themeColor.messageListReplyToolbarDescription)
                            .font(themeFonts.messageListReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .frame(width: 14,height: 12)
                            .foregroundColor(themeColor.messageListReplyToolbarDescription)
                    }
                }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.Video.value{
                    Label {
                        Text(message.metaData?.replyMessage?.parentMessagecaptionMessage != nil ? (message.metaData?.replyMessage?.parentMessagecaptionMessage ?? "Video") : "Video")
                            .foregroundColor(themeColor.messageListReplyToolbarDescription)
                            .font(themeFonts.messageListReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        Image(systemName: "video.fill")
                            .resizable()
                            .frame(width: 14,height: 10)
                            .foregroundColor(themeColor.messageListReplyToolbarDescription)
                    }
                }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.File.value{
                    Label {
                        let str = URL(string: message.attachments.first?.mediaUrl ?? "")?.lastPathComponent.components(separatedBy: "_").last
                        Text(str ?? "Document")
                            .foregroundColor(themeColor.messageListReplyToolbarDescription)
                            .font(themeFonts.messageListReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        Image(systemName: "doc")
                            .resizable()
                            .frame(width: 12,height: 12)
                            .foregroundColor(themeColor.messageListReplyToolbarDescription)
                    }
                }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.Location.value{
                    Label {
                        Text("Location")
                            .foregroundColor(themeColor.messageListReplyToolbarDescription)
                            .font(themeFonts.messageListReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        Image(systemName: "location.fill")
                            .foregroundColor(themeColor.messageListReplyToolbarDescription)
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
                                .foregroundColor(themeColor.messageListReplyToolbarDescription)
                                .font(themeFonts.messageListReplyToolbarDescription)
                                .fixedSize(horizontal: false, vertical: true)
                        }else{
                            Text("\(name ?? "") and \((data?.count ?? 1) - 1) other contact")
                                .foregroundColor(themeColor.messageListReplyToolbarDescription)
                                .font(themeFonts.messageListReplyToolbarDescription)
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
                            .foregroundColor(themeColor.messageListReplyToolbarDescription)
                            .font(themeFonts.messageListReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        Image("gif_logo")
                            .resizable()
                            .frame(width: 20,height: 15)
                    }
                }else{
                    Text(msg)
                        .foregroundColor(themeColor.messageListReplyToolbarDescription)
                        .font(themeFonts.messageListReplyToolbarDescription)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 8))
            if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.Image.value{
                ISMChatImageCahcingManger.networkImage(url: message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? "",isprofileImage: false)
                    .scaledToFill()
                    .frame(width: 45, height: 40)
            }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChatMediaType.Video.value{
                ISMChatImageCahcingManger.networkImage(url: message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? "",isprofileImage: false)
                    .scaledToFill()
                    .frame(width: 45, height: 40)
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
            .font(themeFonts.messageListMessageEdited)
            .foregroundColor(themeColor.messageListMessageEdited)
    }
    
    func getImageAsset() -> ImageAsset {
        var imageAsset: ImageAsset

        if message.initiatorId == userData.userId {
            if message.missedByMembers.count == 0 {
                if let duration = message.callDurations.first(where: { $0.memberId == userData.userId }) {
                    let durationText = duration.durationInMilliseconds?.millisecondsToTime() ?? ""
                    if messageType == .AudioCall {
                        imageAsset = ImageAsset(image: themeImages.audioOutgoing, title: "Voice Call", durationText: durationText)
                    } else {
                        imageAsset = ImageAsset(image: themeImages.videoOutgoing, title: "Video Call", durationText: durationText)
                    }
                } else {
                    imageAsset = ImageAsset(image: Image(""), title: "", durationText: "")
                }
            } else {
                if messageType == .AudioCall {
                    imageAsset = ImageAsset(image: themeImages.audioOutgoing, title: "Voice Call", durationText: "No answer")
                } else {
                    imageAsset = ImageAsset(image: themeImages.videoOutgoing, title: "Video Call", durationText: "No answer")
                }
            }
        } else {
            if message.missedByMembers.count == 0 {
                if let duration = message.callDurations.first(where: { $0.memberId == userData.userId }) {
                    let durationText = duration.durationInMilliseconds?.millisecondsToTime() ?? ""
                    if messageType == .AudioCall {
                        imageAsset = ImageAsset(image: themeImages.audioIncoming, title: "Voice Call", durationText: durationText)
                    } else {
                        imageAsset = ImageAsset(image: themeImages.videoIncoming, title: "Video Call", durationText: durationText)
                    }
                } else {
                    if messageType == .AudioCall {
                        imageAsset = ImageAsset(image: themeImages.audioMissedCall, title: "Missed voice call", durationText: "Tap to call back")
                    } else {
                        imageAsset = ImageAsset(image: themeImages.videoMissedCall, title: "Missed video call", durationText: "Tap to call back")
                    }
                }
            } else {
                if messageType == .AudioCall {
                    imageAsset = ImageAsset(image: themeImages.audioMissedCall, title: "Missed voice call", durationText: "Tap to call back")
                } else {
                    imageAsset = ImageAsset(image: themeImages.videoMissedCall, title: "Missed video call", durationText: "Tap to call back")
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
                    .font(themeFonts.messageListcallingHeader)
                    .foregroundColor(themeColor.messageListcallingHeader)
                HStack {
                    Text(imageAsset.durationText)
                        .font(themeFonts.messageListcallingTime)
                        .foregroundColor(themeColor.messageListcallingTime)
                    Spacer()
                    Text(message.sentAt.datetotime())
                        .font(themeFonts.messageListMessageTime)
                        .foregroundColor(isReceived ? themeColor.messageListMessageTextReceived : themeColor.messageListMessageTimeSend)
                }
            }
        }
    }

}
