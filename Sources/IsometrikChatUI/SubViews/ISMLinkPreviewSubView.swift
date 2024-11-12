////
////  ISMLinkPreviewSubView.swift
////  ISMChatSdk
////
////  Created by Rahul Sharma on 04/04/23.
////
//
import Foundation
import SwiftUI
import LinkPresentation
//
//enum PreviewType : Int, CaseIterable{
//    case Cell
//    case TextView
//}
//
//struct ISMLinkPreview: View {
//    let urlString: String
//    var body: some View {
//        URLEmbeddedViewRepresentable(urlString: urlString, type: .Cell)
//            .frame(width: 250,height: 100)
//            .onTapGesture {
//                if urlString.contains("https"){
//                    openURLInSafari(urlString: urlString)
//                }else{
//                    let fullURLString = "https://" + urlString
//                    openURLInSafari(urlString: fullURLString)
//                }
//            }
//    }
//    
//    func openURLInSafari(urlString : String) {
//        if let url = URL(string: urlString) {
//            UIApplication.shared.open(url)
//        }
//    }
//}
//
//struct URLEmbeddedViewRepresentable: UIViewRepresentable {
//    
//   
//    let urlString: String
//    let type : PreviewType
//    @State var themeFonts = ISMChatSdk.getInstance().getAppAppearance().appearance.fonts
//    @State var themeColor = ISMChatSdk.getInstance().getAppAppearance().appearance.colorPalette
//
//    func makeUIView(context: Context) -> URLEmbeddedView {
//        let embeddedView = URLEmbeddedView()
//        embeddedView.load(urlString: urlString)
//        return embeddedView
//    }
//
//    func updateUIView(_ uiView: URLEmbeddedView, context: Context) {
//        uiView.load(urlString: urlString)
//        
//        uiView.textProvider[.title].font = UIFont.regular(size: 14)
//        uiView.textProvider[.title].fontColor = UIColor(themeColor.messageList_MessageText ?? Color.primary)
//        uiView.textProvider[.title].numberOfLines = type == .Cell ? 2 : 1
//        
//        uiView.textProvider[.description].font = UIFont.regular(size: 12)
//        uiView.textProvider[.description].fontColor = UIColor(themeColor.messageList_MessageText ?? Color.primary)
//        uiView.textProvider[.description].numberOfLines = type == .Cell ? 2 : 1
//        
//        
//        uiView.textProvider[.noDataTitle].font = UIFont.regular(size: 12)
//        uiView.textProvider[.noDataTitle].fontColor = UIColor(themeColor.messageList_MessageText ?? Color.primary)
//        uiView.textProvider[.noDataTitle].numberOfLines = type == .Cell ? 2 : 1
//        
//        uiView.textProvider[.domain].font = UIFont.regular(size: 10)
//        uiView.textProvider[.domain].fontColor = UIColor(themeColor.messageList_MessageText ?? Color.primary)
//        uiView.textProvider[.domain].numberOfLines = type == .Cell ? 2 : 1
//        
//        uiView.cornerRaidus = type == .Cell ? 10 : 0
//        uiView.borderColor = type == .Cell ? UIColor(themeColor.messageList_attachmentBackground ?? Color.gray) : UIColor.clear
//    }
//}
//
struct LinkPreviewToolBarView : View {
    let text : String
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    @State private var metadata: LPLinkMetadata?
    @State private var isLoading = true
    
    var body : some View{
        VStack {
            if let metadata = metadata {
                HStack(spacing: 8) {
                    if let imageProvider = metadata.imageProvider {
                        LinkPreviewImage(imageProvider: imageProvider)
                            .frame(width: 45, height: 45)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .clipped()
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(metadata.title ?? "")
                            .font(appearance.fonts.messageListReplyToolbarHeader)
                            .foregroundColor(appearance.colorPalette.messageListReplyToolbarHeader)
                            .lineLimit(1)
                        
                        
                        Text(text)
                            .font(appearance.fonts.messageListReplyToolbarDescription)
                            .foregroundColor(appearance.colorPalette.messageListReplyToolbarDescription)
                    }
                    Spacer()
                }
            } else if isLoading {
                ProgressView()
            }
        }
        .onAppear {
            loadMetadata()
        }
        .background(appearance.colorPalette.messageListattachmentBackground)
        .frame(height: 70)
    }
    private func loadMetadata() {
        let provider = LPMetadataProvider()
        var url = URL(string: text)
        if !text.contains("https"){
            let URLString = "https://" + text.trimmingCharacters(in: .whitespaces)
            url = URL(string: URLString)
        }
        
        provider.startFetchingMetadata(for: url!) { metadata, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.metadata = metadata
                self.isLoading = false
            }
        }
    }
}




struct ISMLinkPreview: View {
    let url: URL
    let isRecived : Bool
    @State private var metadata: LPLinkMetadata?
    @State private var isLoading = true
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    var body: some View {
        Group {
            if let metadata = metadata {
                VStack(alignment: .leading, spacing: 8) {
                    if let imageProvider = metadata.imageProvider {
                        LinkPreviewImage(imageProvider: imageProvider)
                            .frame(width: 280, height: 200)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .clipped()
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(metadata.title ?? "")
                            .font(appearance.fonts.messageListMessageText)
                            .foregroundColor(isRecived ? appearance.colorPalette.messageListMessageTextReceived   : appearance.colorPalette.messageListMessageTextSend)
                            .lineLimit(2)
                        
                        
                        Text(url.host ?? "")
                            .font(appearance.fonts.messageListMessageTime)
                            .foregroundColor(isRecived ? appearance.colorPalette.messageListMessageTimeReceived : appearance.colorPalette.messageListMessageTimeSend)
                    }
                    .padding(.horizontal,5)
                }
                .cornerRadius(8)
            } else if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            }
        }
        .onAppear {
            loadMetadata()
        }
    }
    
    private func loadMetadata() {
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { metadata, error in
            DispatchQueue.main.async {
                self.metadata = metadata
                self.isLoading = false
            }
        }
    }
}

struct LinkPreviewImage: View {
    let imageProvider: NSItemProvider
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.gray.opacity(0.3)
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        imageProvider.loadObject(ofClass: UIImage.self) { image, error in
            if let image = image as? UIImage {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}


