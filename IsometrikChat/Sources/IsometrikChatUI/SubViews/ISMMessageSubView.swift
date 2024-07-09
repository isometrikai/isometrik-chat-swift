//
//  ISM_MessageRow.swift
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
    
    var messageType : ISMChat_MessageType
//    var userId : String?
    var viewWidth : CGFloat
    var isReceived: Bool
    var messageDeliveredType : ISMChat_MessageStatus = .Clock
    let conversationId : String
    let groupconversationMember : [ISMChat_GroupMember]
    let opponentDeatil : ISMChat_User
    let pasteboard = UIPasteboard.general
    var isGroup : Bool?
    let fromBroadCastFlow : Bool?
    
   
    @Binding var navigateToDeletePopUp : Bool
    @Binding var selectedMessageToReply : MessagesDB
    @Binding var messageCopied : Bool
    @Binding var previousAudioRef: AudioPlayViewModel?
    @Binding var updateMessage : MessagesDB
    @Binding var showForward : Bool
    @Binding var navigateToLocationDetail : ISMChat_LocationData
    @Binding var selectedReaction : String?
    @Binding var sentRecationToMessageId : String
    @Binding var audioCallToUser : Bool
    @Binding var videoCallToUser : Bool
    @Binding var parentMsgToScroll : MessagesDB?
    
    
    
    @State var navigateToInfo : Bool = false
    @State var navigatetoUser : ISMChat_GroupMember = ISMChat_GroupMember()
    @State var navigatetoMessageInfo =  false
    @State var navigateToForwardList = false
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
    @State var themeFonts = ISMChatSdkUI.getInstance().getAppAppearance().appearance.fonts
    @State var themeColor = ISMChatSdkUI.getInstance().getAppAppearance().appearance.colorPalette
    @State var themeImages = ISMChatSdkUI.getInstance().getAppAppearance().appearance.images
    @State var themeBubbleType = ISMChatSdkUI.getInstance().getAppAppearance().appearance.messageBubbleType
    @State var userSession = ISMChatSdk.getInstance().getUserSession()
    
   
    @EnvironmentObject var realmManager : RealmManager
    @ObservedObject var viewModel = ChatsViewModel(ismChatSDK: ISMChatSdk.getInstance())
    @Environment(\.viewController) public var viewControllerHolder: UIViewController?
    
    
    //MARK:  - BODY
    var body: some View {
        HStack{
            if message.deletedMessage == true{
                ZStack{
                    VStack(alignment: isReceived == true ? .leading : .trailing, spacing: 2){
                        HStack{
                            Image(systemName: "minus.circle")
                            Text(isReceived == true ? "This message was deleted." :  "You deleted this message.")
                                .font(themeFonts.messageList_MessageDeleted)
                                .foregroundColor(themeColor.messageList_MessageDeleted)
                        }
                        .opacity(0.2)
                        dateAndStatusView(onImage: false)
                    }//:VStack
                    .padding(8)
                    .background(isReceived ? themeColor.messageList_ReceivedMessageBackgroundColor : themeColor.messageList_SendMessageBackgroundColor)
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
                                .stroke(themeColor.messageList_MessageBorderColor, lineWidth: 1)
                            ) : AnyView(EmptyView())
                    )
                    .background(NavigationLink("", destination: ISMMessageInfoView(conversationId: conversationId, message: message, viewWidth: viewWidth, mediaType: .Text, isGroup: self.isGroup ?? false, groupMember: self.groupconversationMember,fromBroadCastFlow: self.fromBroadCastFlow).environmentObject(self.realmManager), isActive: $navigatetoMessageInfo))
                }//:ZStack
                .padding(.vertical,2)
            }else{
                switch messageType {
                    
                    //MARK: - Text Message View
                case .text:
                    HStack(alignment: .bottom){
                        if isGroup == true && isReceived == true{
                            //When its group show member avatar in message
                            inGroupUserAvatarView()
                        }
                        ZStack(alignment: .bottomTrailing){
                            let str = message.body
                            VStack(alignment: .leading, spacing: 2){
                                if isGroup == true && isReceived == true{
                                    //when its group show member name in message
                                    inGroupUserName()
                                }
                                VStack(alignment: .trailing, spacing: 0){
                                    if message.customType == ISMChat_MediaType.ReplyText.value && message.messageType != 1{
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
                                            if ISMChat_Helper.isValidEmail(str) == true{
                                                Link(str, destination: URL(string: "mailto:apple@me.com")!)
                                                    .font(themeFonts.messageList_MessageText)
                                                    .foregroundColor(themeColor.userProfile_editText)
                                                    .underline(true, color: themeColor.userProfile_editText)
                                            }else if  ISMChat_Helper.isValidPhone(phone: str) == true{
                                                Link(str, destination: URL(string: "tel:\(str)")!)
                                                    .font(themeFonts.messageList_MessageText)
                                                    .foregroundColor(themeColor.userProfile_editText)
                                                    .underline(true, color: themeColor.userProfile_editText)
                                            }
                                            else if str.isValidURL || str.contains("www."){
//                                                ISMLinkPreview(urlString: str)
//                                                    .font(themeFonts.messageList_MessageText)
//                                                    .foregroundColor(themeColor.messageList_MessageText)
                                            }
                                            else{
                                                if str.contains("@") && isGroup == true{
                                                    HighlightedTextView(originalText: str, mentionedUsers: groupconversationMember, navigateToInfo: $navigateToInfo, navigatetoUser: $navigatetoUser)
                                                }else{
                                                    Text(str)
                                                        .font(themeFonts.messageList_MessageText)
                                                        .foregroundColor(themeColor.messageList_MessageText)
                                                }
                                            }
                                        }
                                        dateAndStatusView(onImage: false)
                                    }
                                }//:VStack
                                .padding(.horizontal, str.isValidURL || str.contains("www.") == true ? 5 : 10)
                                .padding(.vertical,str.isValidURL || str.contains("www.") == true ? 5 : 8)
                                .background(isReceived ? themeColor.messageList_ReceivedMessageBackgroundColor : themeColor.messageList_SendMessageBackgroundColor)
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
                                            .stroke(themeColor.messageList_MessageBorderColor, lineWidth: 1)
                                        ) : AnyView(EmptyView())
                                )
                                .background(NavigationLink("", destination: ISMMessageInfoView(conversationId: conversationId, message: message, viewWidth: viewWidth, mediaType: .Text, isGroup: self.isGroup ?? false, groupMember: self.groupconversationMember,fromBroadCastFlow: self.fromBroadCastFlow).environmentObject(self.realmManager), isActive: $navigatetoMessageInfo))
                                .background(NavigationLink("", destination:  ISMContactInfoView(conversationID: "",viewModel:self.viewModel, isGroup: false,onlyInfo: true,selectedToShowInfo : self.navigatetoUser).environmentObject(self.realmManager), isActive: $navigateToInfo))
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
                                if let metaData = message.metaData{
                                    NavigationLink(destination:  ISMContactDetailView(data : metaData)){
                                        VStack(alignment: .trailing,spacing: 2){
                                            if message.messageType == 1{
                                                forwardedView()
                                            }
                                            HStack(spacing: 10){
                                                
                                                ISMChat_ImageCahcingManger.networkImage(url: metaData.contacts.first?.contactImageUrl ?? "" ,isprofileImage: true)
                                                    .scaledToFill()
                                                    .frame(width: 40, height: 40)
                                                    .cornerRadius(20)
                                                
                                                let name = metaData.contacts.first?.contactName ?? ""
                                                if metaData.contacts.count == 1{
                                                    Text(name)
                                                        .font(themeFonts.messageList_MessageText)
                                                        .foregroundColor(themeColor.messageList_MessageText)
                                                }else{
                                                    Text("\(name) and \((metaData.contacts.count) - 1) other contact")
                                                        .font(themeFonts.messageList_MessageText)
                                                        .foregroundColor(themeColor.messageList_MessageText)
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
                                                    .font(themeFonts.messageList_MessageText)
                                                    .foregroundColor(themeColor.userProfile_editText)
                                                Spacer()
                                            }.padding(.vertical,5)
                                        }
                                        .frame(width: 250)
                                        .padding(5)
                                        .background(isReceived ? themeColor.messageList_ReceivedMessageBackgroundColor : themeColor.messageList_SendMessageBackgroundColor)
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
                                                    .stroke(themeColor.messageList_MessageBorderColor, lineWidth: 1)
                                                ) : AnyView(EmptyView())
                                        )
                                        .background(NavigationLink("", destination: ISMMessageInfoView(conversationId: conversationId,message: message, viewWidth: 250,mediaType: .Image, isGroup: self.isGroup ?? false, groupMember: self.groupconversationMember,fromBroadCastFlow: self.fromBroadCastFlow).environmentObject(self.realmManager), isActive: $navigatetoMessageInfo))
                                        .background(NavigationLink("", destination:  ISMContactInfoView(conversationID: "",viewModel:self.viewModel, isGroup: false,onlyInfo: true,selectedToShowInfo : self.navigatetoUser).environmentObject(self.realmManager), isActive: $navigateToInfo))
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
                                let index = self.realmManager.medias?.firstIndex(where: {$0.messageId == message.messageId})
                                NavigationLink(destination:  MediaSliderView(viewModel: self.viewModel, index:index ?? 0).environmentObject(self.realmManager))
                                {
                                    VStack(alignment: .trailing,spacing: 5){
                                        if message.messageType == 1{
                                            forwardedView()
                                        }
                                        ZStack(alignment: .bottomTrailing){
                                            ISMChat_ImageCahcingManger.networkImage(url: message.attachments.first?.mediaUrl ?? "",isprofileImage: false)
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
                                                .font(themeFonts.messageList_MessageText)
                                                .foregroundColor(themeColor.messageList_MessageText)
                                            
                                            dateAndStatusView(onImage: false)
                                                .padding(.bottom,5)
                                                .padding(.trailing,5)
                                            
                                        }
                                    }//:ZStack
                                    .padding(5)
                                    .background(isReceived ? themeColor.messageList_ReceivedMessageBackgroundColor : themeColor.messageList_SendMessageBackgroundColor)
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
                                                .stroke(themeColor.messageList_MessageBorderColor, lineWidth: 1)
                                            ) : AnyView(EmptyView())
                                    )
                                    .background(NavigationLink("", destination: ISMMessageInfoView(conversationId: conversationId,message: message, viewWidth: 250,mediaType: .Image, isGroup: self.isGroup ?? false, groupMember: self.groupconversationMember,fromBroadCastFlow: self.fromBroadCastFlow).environmentObject(self.realmManager), isActive: $navigatetoMessageInfo))
                                    .background(NavigationLink("", destination:  ISMContactInfoView(conversationID: "",viewModel:self.viewModel, isGroup: false,onlyInfo: true,selectedToShowInfo : self.navigatetoUser).environmentObject(self.realmManager), isActive: $navigateToInfo))
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
                                let index = self.realmManager.medias?.firstIndex(where: {$0.messageId == message.messageId})
                                NavigationLink(destination: MediaSliderView(viewModel: self.viewModel, index:index ?? 0).environmentObject(self.realmManager)){
                                    VStack(alignment: .trailing,spacing : 5){
                                        if message.messageType == 1{
                                            forwardedView()
                                        }
                                        ZStack(alignment: .center){
                                            if let thumbnailUrl = message.attachments.first?.thumbnailUrl,
                                               thumbnailUrl.contains(".mp4") {
                                                if let image = ISMChat_Helper.getThumbnailImage(url: thumbnailUrl){
                                                    Image(uiImage: image)
                                                        .scaledToFill()
                                                        .frame(width: 250, height: 300)
                                                        .cornerRadius(5)
                                                }else{
                                                    // Display the thumbnail image for non-videos
                                                    ZStack(alignment: .bottomTrailing){
                                                        ISMChat_ImageCahcingManger.networkImage(url: message.attachments.first?.thumbnailUrl ?? "", isprofileImage: false)
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
                                                    ISMChat_ImageCahcingManger.networkImage(url: message.attachments.first?.thumbnailUrl ?? "", isprofileImage: false)
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
                                                .font(themeFonts.messageList_MessageText)
                                                .foregroundColor(themeColor.messageList_MessageText)
                                            
                                            dateAndStatusView(onImage: false)
                                                .padding(.bottom,5)
                                                .padding(.trailing,5)
                                        }
                                        
                                    }.padding(5)
                                        .background(isReceived ? themeColor.messageList_ReceivedMessageBackgroundColor : themeColor.messageList_SendMessageBackgroundColor)
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
                                                    .stroke(themeColor.messageList_MessageBorderColor, lineWidth: 1)
                                                ) : AnyView(EmptyView())
                                        )
                                        .background(NavigationLink("", destination: ISMMessageInfoView(conversationId: conversationId,message: message, viewWidth: 250,mediaType: .Image, isGroup: self.isGroup ?? false, groupMember: self.groupconversationMember,fromBroadCastFlow: self.fromBroadCastFlow).environmentObject(self.realmManager), isActive: $navigatetoMessageInfo))
                                        .background(NavigationLink("", destination:  ISMContactInfoView(conversationID: "",viewModel:self.viewModel, isGroup: false,onlyInfo: true,selectedToShowInfo : self.navigatetoUser).environmentObject(self.realmManager), isActive: $navigateToInfo))
                                }//:NavigationLink
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
                                if let documentUrl = URL(string: message.attachments.first?.mediaUrl ?? ""){
                                    let urlExtension = ISMChat_Helper.getExtensionFromURL(url: documentUrl)
                                    let fileName = ISMChat_Helper.getFileNameFromURL(url: documentUrl)
                                    NavigationLink(destination: ISMDocumentViewer(url: documentUrl, title: fileName)){
                                        ZStack{
                                            VStack(alignment: .trailing, spacing: 5){
                                                if message.messageType == 1{
                                                    forwardedView()
                                                }
                                                
                                                HStack(alignment: .center, spacing: 5){
                                                    if let urlExtension = urlExtension{
                                                        if urlExtension.contains(".jpg") ||  urlExtension.contains(".png"){
                                                            ISMChat_ImageCahcingManger.networkImage(url: message.attachments.first?.mediaUrl ?? "",isprofileImage: false)
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
                                                                    .font(themeFonts.messageList_MessageText)
                                                                    .foregroundColor(themeColor.messageList_MessageText)
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
                                            .background(isReceived ? themeColor.messageList_ReceivedMessageBackgroundColor : themeColor.messageList_SendMessageBackgroundColor)
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
                                                        .stroke(themeColor.messageList_MessageBorderColor, lineWidth: 1)
                                                    ) : AnyView(EmptyView())
                                            )
                                            .background(NavigationLink("", destination: ISMMessageInfoView(conversationId: conversationId, message: message, viewWidth: viewWidth, mediaType: .Text, isGroup: self.isGroup ?? false, groupMember: self.groupconversationMember,fromBroadCastFlow: self.fromBroadCastFlow)
                                                .environmentObject(self.realmManager), isActive: $navigatetoMessageInfo))
                                            .background(NavigationLink("", destination:  ISMContactInfoView(conversationID: "",viewModel:self.viewModel, isGroup: false,onlyInfo: true,selectedToShowInfo : self.navigatetoUser).environmentObject(self.realmManager), isActive: $navigateToInfo))
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
                                ZStack{
                                    VStack(alignment: .trailing, spacing: 5){
                                        if message.messageType == 1{
                                            forwardedView()
                                        }
                                        
                                        ISMLocationSubView(message: message)
                                            .cornerRadius(5)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                let data = ISMChat_LocationData(coordinate:
                                                                                    CLLocationCoordinate2D(
                                                                                        latitude: message.attachments.first?.latitude ?? 0,
                                                                                        longitude: message.attachments.first?.longitude ?? 0),
                                                                                title: message.attachments.first?.title ?? "",
                                                                                completeAddress: message.attachments.first?.address ?? "")
                                                navigateToLocationDetail = data
                                            }
                                            .allowsHitTesting(true)
                                        
                                        HStack{
                                            Text(message.attachments.first?.title ?? "")
                                                .font(themeFonts.messageList_MessageText)
                                                .foregroundColor(themeColor.userProfile_editText)
                                            Spacer()
                                            
                                        }
                                        HStack{
                                            Text(message.attachments.first?.address ?? "")
                                                .font(themeFonts.messageList_ReplyToolbarDescription)
                                                .foregroundColor(themeColor.messageList_TextViewPlaceholder)
                                            Spacer()
                                        }
                                        dateAndStatusView(onImage: false)
                                            .padding(.bottom,(message.reactions.count > 0) ? 5 : 0)
                                    }//:VStack
                                    .frame(width: 250)
                                    .padding(5)
                                    .background(isReceived ? themeColor.messageList_ReceivedMessageBackgroundColor : themeColor.messageList_SendMessageBackgroundColor)
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
                                                .stroke(themeColor.messageList_MessageBorderColor, lineWidth: 1)
                                            ) : AnyView(EmptyView())
                                    )
                                    .background(NavigationLink("", destination: ISMMessageInfoView(conversationId: conversationId,message: message, viewWidth: 250,mediaType: .Image, isGroup: self.isGroup ?? false, groupMember: self.groupconversationMember,fromBroadCastFlow: self.fromBroadCastFlow).environmentObject(self.realmManager), isActive: $navigatetoMessageInfo))
                                    .background(NavigationLink("", destination:  ISMContactInfoView(conversationID: "",viewModel:self.viewModel, isGroup: false,onlyInfo: true,selectedToShowInfo : self.navigatetoUser).environmentObject(self.realmManager), isActive: $navigateToInfo))
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
                                ZStack(alignment: .bottomTrailing){
                                    VStack(alignment: .trailing, spacing: 2){
                                        if message.messageType == 1{
                                            forwardedView()
                                        }
                                        ISMAudioSubView(audio: message.attachments.first?.mediaUrl ?? "",message : self.message, isReceived: self.isReceived, messageDeliveredType: self.messageDeliveredType, previousAudioRef: $previousAudioRef)
                                            .padding(.bottom,(message.reactions.count > 0) ? 2 : 0)
                                    }//:VStack
                                    .padding(8)
                                    .background(isReceived ? themeColor.messageList_ReceivedMessageBackgroundColor : themeColor.messageList_SendMessageBackgroundColor)
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
                                                .stroke(themeColor.messageList_MessageBorderColor, lineWidth: 1)
                                            ) : AnyView(EmptyView())
                                    )
                                    .background(NavigationLink("", destination: ISMMessageInfoView(conversationId: conversationId, message: message, viewWidth: viewWidth, mediaType: .Text, isGroup: self.isGroup ?? false, groupMember: self.groupconversationMember,fromBroadCastFlow: self.fromBroadCastFlow).environmentObject(self.realmManager), isActive: $navigatetoMessageInfo))
                                    .background(NavigationLink("", destination:  ISMContactInfoView(conversationID: "",viewModel:self.viewModel, isGroup: false,onlyInfo: true,selectedToShowInfo : self.navigatetoUser).environmentObject(self.realmManager), isActive: $navigateToInfo))
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
                                    .background(isReceived ? themeColor.messageList_ReceivedMessageBackgroundColor : themeColor.messageList_SendMessageBackgroundColor)
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
                                                .stroke(themeColor.messageList_MessageBorderColor, lineWidth: 1)
                                            ) : AnyView(EmptyView())
                                    )
                                    .onTapGesture(perform: {
                                        if isReceived == true{
                                            videoCallToUser = true
                                        }
                                    })
                                    .background(NavigationLink("", destination: ISMMessageInfoView(conversationId: conversationId, message: message, viewWidth: viewWidth, mediaType: .Text, isGroup: self.isGroup ?? false, groupMember: self.groupconversationMember,fromBroadCastFlow: self.fromBroadCastFlow).environmentObject(self.realmManager), isActive: $navigatetoMessageInfo))
                                    .background(NavigationLink("", destination:  ISMContactInfoView(conversationID: "",viewModel:self.viewModel, isGroup: false,onlyInfo: true,selectedToShowInfo : self.navigatetoUser).environmentObject(self.realmManager), isActive: $navigateToInfo))
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
                                    .background(isReceived ? themeColor.messageList_ReceivedMessageBackgroundColor : themeColor.messageList_SendMessageBackgroundColor)
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
                                                .stroke(themeColor.messageList_MessageBorderColor, lineWidth: 1)
                                            ) : AnyView(EmptyView())
                                    )
                                    .onTapGesture(perform: {
                                        if isReceived == true{
                                            audioCallToUser = true
                                        }
                                    })
                                    .background(NavigationLink("", destination: ISMMessageInfoView(conversationId: conversationId, message: message, viewWidth: viewWidth, mediaType: .Text, isGroup: self.isGroup ?? false, groupMember: self.groupconversationMember,fromBroadCastFlow: self.fromBroadCastFlow).environmentObject(self.realmManager), isActive: $navigatetoMessageInfo))
                                    .background(NavigationLink("", destination:  ISMContactInfoView(conversationID: "",viewModel:self.viewModel, isGroup: false,onlyInfo: true,selectedToShowInfo : self.navigatetoUser).environmentObject(self.realmManager), isActive: $navigateToInfo))
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
                                let index = self.realmManager.medias?.firstIndex(where: {$0.messageId == message.messageId})
                                NavigationLink(destination:  MediaSliderView(viewModel: self.viewModel, index:index ?? 0).environmentObject(self.realmManager))
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
                                                .font(themeFonts.messageList_MessageText)
                                                .foregroundColor(themeColor.messageList_MessageText)
                                            
                                            dateAndStatusView(onImage: false)
                                                .padding(.bottom,5)
                                                .padding(.trailing,5)
                                            
                                        }
                                    }//:ZStack
                                    .padding(5)
                                    .padding(.vertical,5)
                                    .background(isReceived ? themeColor.messageList_ReceivedMessageBackgroundColor : themeColor.messageList_SendMessageBackgroundColor)
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
                                                .stroke(themeColor.messageList_MessageBorderColor, lineWidth: 1)
                                            ) : AnyView(EmptyView())
                                    )
                                    .background(NavigationLink("", destination: ISMMessageInfoView(conversationId: conversationId,message: message, viewWidth: 250,mediaType: .Image, isGroup: self.isGroup ?? false, groupMember: self.groupconversationMember,fromBroadCastFlow: self.fromBroadCastFlow).environmentObject(self.realmManager), isActive: $navigatetoMessageInfo))
                                    .background(NavigationLink("", destination:  ISMContactInfoView(conversationID: "",viewModel:self.viewModel, isGroup: false,onlyInfo: true,selectedToShowInfo : self.navigatetoUser).environmentObject(self.realmManager), isActive: $navigateToInfo))
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
                                        .background(isReceived ? themeColor.messageList_ReceivedMessageBackgroundColor : themeColor.messageList_SendMessageBackgroundColor)
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
                                                    .stroke(themeColor.messageList_MessageBorderColor, lineWidth: 1)
                                                ) : AnyView(EmptyView())
                                        )
                                    
                                    
                                }//:ZStack
                                .padding(5)
                                .padding(.vertical,5)
                                .background(NavigationLink("", destination: ISMMessageInfoView(conversationId: conversationId,message: message, viewWidth: 250,mediaType: .Image, isGroup: self.isGroup ?? false, groupMember: self.groupconversationMember,fromBroadCastFlow: self.fromBroadCastFlow).environmentObject(self.realmManager), isActive: $navigatetoMessageInfo))
                                .background(NavigationLink("", destination:  ISMContactInfoView(conversationID: "",viewModel:self.viewModel, isGroup: false,onlyInfo: true,selectedToShowInfo : self.navigatetoUser).environmentObject(self.realmManager), isActive: $navigateToInfo))
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
        .padding(.bottom, (message.reactions.count > 0) ? 20 : 0)
        .frame(maxWidth: .infinity, alignment: isReceived ? .leading : .trailing)
        .multilineTextAlignment(.leading) // Aligning the text based on message type
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
                        ISMChat_Helper.print("value ",value.translation.width)
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
        .simultaneousGesture(!isReceived ? LongPressGesture(minimumDuration: 0.5).onEnded { _ in
            self.viewControllerHolder?.present(style: .overCurrentContext, transitionStyle: .crossDissolve) {
                ISMCustomContextMenu(conversationId: self.conversationId, message: self.message, viewWidth: self.viewWidth, isGroup: self.isGroup ?? false, isReceived: self.isReceived, selectedMessageToReply: $selectedMessageToReply, showForward: $showForward, updateMessage: $updateMessage, messageCopied: $messageCopied, navigatetoMessageInfo: $navigatetoMessageInfo, navigateToDeletePopUp: $navigateToDeletePopUp, selectedReaction: $selectedReaction,sentRecationToMessageId: $sentRecationToMessageId,fromBroadCastFlow: self.fromBroadCastFlow)
                    .environmentObject(self.realmManager)
            }
        } : nil)
        .onAppear( perform: {
            self.navigateToInfo = false
            if message.metaData?.replyMessage?.parentMessageMessageType == ISMChat_MediaType.File.value && message.customType == ISMChat_MediaType.ReplyText.value{
                if let documentUrl = URL(string: message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? ""){
                    ISMChat_Helper.pdfThumbnail(url: documentUrl){ image in
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
        .onChange(of: reactionRemoved) { newVALUE in
            if !reactionRemoved.isEmpty{
                realmManager.removeReactionFromMessage(conversationId: self.message.conversationId, messageId: self.message.messageId, reaction: reactionRemoved, userId: userSession.getUserId() ?? "")
                reactionRemoved = ""
            }
        }
    }//:Body
    
    func forwardedView() -> some View{
        HStack(alignment: .center, spacing: 2) {
            Image("forwarded")
                .resizable()
                .frame(width: 14, height: 14, alignment: .center)
            Text("Forwarded")
                .font(themeFonts.messageList_MessageForwarded)
                .foregroundColor(themeColor.messageList_MessageForwarded)
        }
    }
    
    func editedView() -> some View{
        Text("Edited")
            .font(themeFonts.messageList_MessageEdited)
            .foregroundColor(themeColor.messageList_MessageEdited)
    }
    
    func repliedMessageView() -> some View{
        HStack{
            Rectangle()
                .fill(themeColor.messageList_ReplyToolbarRectangle)
                .frame(width: 4)
            VStack(alignment: .leading, spacing: 2){
                let parentUserName = message.metaData?.replyMessage?.parentMessageUserName ?? "User"
                let name = parentUserName == userSession.getUserName() ? ConstantStrings.you : parentUserName
                Text(name)
                    .foregroundColor(themeColor.messageList_ReplyToolbarHeader)
                    .font(themeFonts.messageList_ReplyToolbarHeader)
                let msg = message.metaData?.replyMessage?.parentMessageBody ?? ""
                if message.metaData?.replyMessage?.parentMessageMessageType == ISMChat_MediaType.Image.value{
                    Label {
                        Text(message.metaData?.replyMessage?.parentMessagecaptionMessage != nil ? (message.metaData?.replyMessage?.parentMessagecaptionMessage ?? "Photo") : "Photo")
                            .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                            .font(themeFonts.messageList_ReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .frame(width: 14,height: 12)
                            .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                    }
                }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChat_MediaType.Video.value{
                    Label {
                        Text(message.metaData?.replyMessage?.parentMessagecaptionMessage != nil ? (message.metaData?.replyMessage?.parentMessagecaptionMessage ?? "Video") : "Video")
                            .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                            .font(themeFonts.messageList_ReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        Image(systemName: "video.fill")
                            .resizable()
                            .frame(width: 14,height: 10)
                            .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                    }
                }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChat_MediaType.File.value{
                    Label {
                        let str = URL(string: message.attachments.first?.mediaUrl ?? "")?.lastPathComponent.components(separatedBy: "_").last
                        Text(str ?? "Document")
                            .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                            .font(themeFonts.messageList_ReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        Image(systemName: "doc")
                            .resizable()
                            .frame(width: 12,height: 12)
                            .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                    }
                }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChat_MediaType.Location.value{
                    Label {
                        Text("Location")
                            .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                            .font(themeFonts.messageList_ReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        Image(systemName: "location.fill")
                            .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                    }
                }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChat_MediaType.Contact.value{
                    let data = msg.getContactJson()
                    let name = data?.first?["displayName"] as? String
                    HStack{
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 12, height: 12, alignment: .center)
                            .tint(Color.onboardingPlaceholder)
                        if data?.count == 1{
                            Text(name ?? "Contact")
                                .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                                .font(themeFonts.messageList_ReplyToolbarDescription)
                                .fixedSize(horizontal: false, vertical: true)
                        }else{
                            Text("\(name ?? "") and \((data?.count ?? 1) - 1) other contact")
                                .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                                .font(themeFonts.messageList_ReplyToolbarDescription)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(2)
                        }
                    }
                }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChat_MediaType.sticker.value{
                    AnimatedImage(url: URL(string: message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? ""),isAnimating: $isAnimating)
                        .resizable()
                        .frame(width: 30, height: 30)
                }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChat_MediaType.gif.value{
                    Label {
                        Text("GIF")
                            .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                            .font(themeFonts.messageList_ReplyToolbarDescription)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration:0.3)))
                    } icon: {
                        Image("gif_logo")
                            .resizable()
                            .frame(width: 20,height: 15)
                    }
                }else{
                    Text(msg)
                        .foregroundColor(themeColor.messageList_ReplyToolbarDescription)
                        .font(themeFonts.messageList_ReplyToolbarDescription)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 8))
            if message.metaData?.replyMessage?.parentMessageMessageType == ISMChat_MediaType.Image.value{
                ISMChat_ImageCahcingManger.networkImage(url: message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? "",isprofileImage: false)
                    .scaledToFill()
                    .frame(width: 45, height: 40)
            }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChat_MediaType.Video.value{
                ISMChat_ImageCahcingManger.networkImage(url: message.metaData?.replyMessage?.parentMessageAttachmentUrl ?? "",isprofileImage: false)
                    .scaledToFill()
                    .frame(width: 45, height: 40)
            }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChat_MediaType.File.value{
                Image(uiImage: pdfthumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height: 40)
            }else if message.metaData?.replyMessage?.parentMessageMessageType == ISMChat_MediaType.gif.value{
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
    
    func callView() -> some View{
        var imageString : String = ""
        var titleText : String = ""
        var durationText : String = ""
        
        
        if message.initiatorIdentifier == userSession.getEmailId(){
            if message.missedByMembers.count == 0{
                if let duration = message.callDurations.first(where: { $0.memberId == userSession.getUserId() }) {
                    // Duration found
                    if messageType == .AudioCall{
                        imageString = "audio_outgoing"
                        titleText = "Voice Call"
                        durationText = duration.durationInMilliseconds?.millisecondsToTime() ?? ""
                    }else{
                        imageString = "video_outgoing"
                        titleText = "Video Call"
                        durationText = duration.durationInMilliseconds?.millisecondsToTime() ?? ""
                    }
                } else {
                    imageString = ""
                    titleText = ""
                    durationText = ""
                }
            } else {
                //correct
                if messageType == .AudioCall{
                    imageString = "audio_outgoing"
                    titleText = "Voice Call"
                    durationText = "No answer"
                }else{
                    imageString = "video_outgoing"
                    titleText = "Video Call"
                    durationText = "No answer"
                }
            }
        }else{
            if message.missedByMembers.count == 0{
                if let duration = message.callDurations.first(where: { $0.memberId == userSession.getUserId() }) {
                    if messageType == .AudioCall{
                        imageString = "audio_incoming"
                        titleText = "Voice Call"
                        durationText = duration.durationInMilliseconds?.millisecondsToTime() ?? ""
                    }else{
                        imageString = "video_incoming"
                        titleText = "Video Call"
                        durationText = duration.durationInMilliseconds?.millisecondsToTime() ?? ""
                    }
                } else {
                    if messageType == .AudioCall{
                        imageString = "audio_missedCall"
                        titleText = "Missed voice call"
                        durationText = "Tap to call back"
                    }else{
                        imageString = "video_missedCall"
                        titleText = "Missed video call"
                        durationText = "Tap to call back"
                    }
                }
            }else{
                //correct
                if messageType == .AudioCall{
                    imageString = "audio_missedCall"
                    titleText = "Missed voice call"
                    durationText = "Tap to call back"
                }else{
                    imageString = "video_missedCall"
                    titleText = "Missed video call"
                    durationText = "Tap to call back"
                }
            }
        }
        
        
        return HStack(spacing: 10){
            Image(imageString)
                .resizable()
                .frame(width: 38, height: 38, alignment: .center)
            VStack(alignment : .leading,spacing : 5){
                Text(titleText)
                    .font(themeFonts.messageList_callingHeader)
                    .foregroundColor(themeColor.messageList_callingHeader)
                HStack{
                    Text(durationText)
                        .font(themeFonts.messageList_callingTime)
                        .foregroundColor(themeColor.messageList_callingTime)
                    Spacer()
                    Text(message.sentAt.datetotime())
                        .font(themeFonts.messageList_MessageTime)
                        .foregroundColor(themeColor.messageList_MessageTime)
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
                        Text(ISMChat_Helper.getEmoji(valueString: rec.reactionType))
                            .font(themeFonts.messageList_reactionCount)
                        Text("\(rec.users.count)")
                            .foregroundColor(themeColor.messageList_reactionCount)
                            .font(themeFonts.messageList_reactionCount)
                    }
                    .padding(5)
                    .background(Color.white)
                    .cornerRadius(12)
                    .frame(height: 24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(themeColor.messageList_MessageBorderColor, lineWidth: 1)
                    )
                }
            }.offset(y: 14)
        }
    }
    
    func inGroupUserAvatarView() -> some View{
        UserAvatarView(avatar: message.senderInfo?.userProfileImageUrl ?? "", showOnlineIndicator: false, size: CGSize(width: 25, height: 25), userName: message.senderInfo?.userName ?? "",font: .regular(size: 12))
            .onTapGesture {
                let member = ISMChat_GroupMember(userProfileImageUrl: message.senderInfo?.userProfileImageUrl, userName: message.senderInfo?.userName, userIdentifier: message.senderInfo?.userIdentifier, userId: message.senderInfo?.userId, online: message.senderInfo?.online, lastSeen: message.senderInfo?.lastSeen, isAdmin: false)
                navigatetoUser = member
                navigateToInfo = true
            }
    }
    
    func inGroupUserName() -> some View{
        Text(message.senderInfo?.userName ?? "")
            .font(themeFonts.messageList_groupMemberUserName)
            .foregroundColor(themeColor.messageList_groupMemberUserName)
    }
    
    func dateAndStatusView(onImage : Bool) -> some View{
        HStack(alignment: .center,spacing: 3){
            Text(message.sentAt.datetotime())
                .font(themeFonts.messageList_MessageTime)
                .foregroundColor(onImage ? Color.white : themeColor.messageList_MessageTime)
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
