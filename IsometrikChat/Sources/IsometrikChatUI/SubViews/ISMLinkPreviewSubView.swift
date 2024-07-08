////
////  ISMLinkPreviewSubView.swift
////  ISMChatSdk
////
////  Created by Rahul Sharma on 04/04/23.
////
//
//import Foundation
//import SwiftUI
//import LinkPresentation
//import URLEmbeddedView
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
//struct LinkPreviewToolBarView : View {
//    let text : String
//    @State var themeColor = ISMChatSdk.getInstance().getAppAppearance().appearance.colorPalette
//    var body : some View{
//        HStack {
//            URLEmbeddedViewRepresentable(urlString: text, type: .TextView)
//        }
//        .background(themeColor.messageList_attachmentBackground)
//        .frame(height: 70)
//    }
//}
//
//
