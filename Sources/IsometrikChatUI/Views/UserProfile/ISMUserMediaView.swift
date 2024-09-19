//
//  ISMUserMediaView.swift
//  ISMChatSdk
//
//  Created by Rahul Iphone123 on 06/07/23.
//

import SwiftUI
import SDWebImageSwiftUI
import IsometrikChat

struct ISMUserMediaView: View {
    
    //MARK: - PROPERTIES
    @State public var selectIndex = 0
    @State public var groupMedia = [Date: [MediaDB]]()
    @State public var groupLink = [Date: [MessagesDB]]()
    @EnvironmentObject var realmManager: RealmManager
    
    public var viewModel = ChatsViewModel()
    public var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 1, alignment: nil), count: 3)
    }
    @Environment(\.dismiss) var dismiss
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance
    
    //MARK: - BODY
    public var body: some View {
        ZStack {
            Color.backgroundView.edgesIgnoringSafeArea(.all)
            VStack {
                if selectIndex == 1{
                    if groupLink.isEmpty{
                        showEmptyView()
                    }else{
                        showLinkView()
                    }
                }else{
                    if groupMedia.isEmpty {
                        showEmptyView()
                    } else {
                        showMediaGridView()
                    }
                }
                Spacer()
            }
            .onChange(of: selectIndex, { _, newValue in
                handlePickerSelection(newValue)
            })
            .navigationBarItems(leading: navigationLeading())
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Picker("Media Picker", selection: $selectIndex) {
                            Text("Media")
                                .tag(0)
                                .font(appearance.fonts.messageListMessageText)
                                .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                            Text("Links")
                                .tag(1)
                                .font(appearance.fonts.messageListMessageText)
                                .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                            Text("Docs")
                                .tag(2)
                                .font(appearance.fonts.messageListMessageText)
                                .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                            
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 250)
                    }
                }
            }
        }
        .onAppear {
            setupGroupedMedia()
        }
    }
    
    //MARK: - CONFIGURE
    func handlePickerSelection(_ selection: Int) {
        switch selection {
        case 0:
            groupMedia = groupedEpisodesByMonth(realmManager.medias ?? [])
        case 1:
            groupLink = groupedLinkByMonth(realmManager.linksMedia ?? [])
        case 2:
            groupMedia = groupedEpisodesByMonth(realmManager.filesMedia ?? [])
        default:
            groupMedia.removeAll()
        }
    }
    
    func setupGroupedMedia() {
        groupMedia = groupedEpisodesByMonth(realmManager.medias ?? [])
    }
    
    func setupGroupedLink(){
        groupLink = groupedLinkByMonth(realmManager.linksMedia ?? [])
    }
    
    func groupedEpisodesByMonth(_ episodes: [MediaDB]) -> [Date: [MediaDB]] {
        let empty: [Date: [MediaDB]] = [:]
        
        return episodes.reduce(into: empty) { acc, cur in
            let date1 = Date(timeIntervalSince1970: (cur.sentAt / 1000))
            let components = Calendar.current.dateComponents([.year, .month, .day], from: date1)
            let date = Calendar.current.date(from: components)!
            let existing = acc[date] ?? []
            acc[date] = existing + [cur]
        }
    }
    
    func groupedLinkByMonth(_ episodes: [MessagesDB]) -> [Date: [MessagesDB]] {
        let empty: [Date: [MessagesDB]] = [:]
        
        return episodes.reduce(into: empty) { acc, cur in
            let date1 = Date(timeIntervalSince1970: (cur.sentAt / 1000))
            let components = Calendar.current.dateComponents([.year, .month, .day], from: date1)
            let date = Calendar.current.date(from: components)!
            let existing = acc[date] ?? []
            acc[date] = existing + [cur]
        }
    }
    
    func showEmptyView() -> some View {
        let placeholderImage : Image
        
        switch selectIndex {
        case 0:
            placeholderImage = appearance.images.noMediaPlaceholder
        case 1:
            placeholderImage = appearance.images.noLinkPlaceholder
        case 2:
            placeholderImage = appearance.images.noDocPlaceholder
        default:
            placeholderImage = appearance.images.fileFallback
        }
        
        return VStack{
            Spacer()
            placeholderImage
                .resizable().frame(width: 206, height: 138, alignment: .center)
            Spacer()
        }
        
    }
    
    func navigationLeading() -> some View{
        Button(action: {
            dismiss()
        }) {
            appearance.images.backButton
                .resizable()
                .frame(width: 18, height: 18)
        }
    }
    
    func showLinkView() -> some View {
        ScrollView {
            ForEach(groupLink.keys.sorted(), id: \.self) { key in
                if let messages = groupLink[key]?.filter({ message in true }), !messages.isEmpty {
                    // Section Header
                    Section(header: Text(key.toString(dateFormat: "dd MMM yyyy"))
                        .foregroundColor(.black)
                        .font(appearance.fonts.messageListMessageText)
                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    ) {
                        // List of Messages
                        ForEach(messages, id: \.self) { message in
                            showLinkViewList(msg: message.body)
                        }
                    }
                }
            }
        }
    }
    
    
    
    func showMediaGridView() -> some View {
        ScrollView {
            ForEach(groupMedia.keys.sorted(), id: \.self) { key in
                if let contacts = groupMedia[key]?.filter({ contact in true }), !contacts.isEmpty {
                    showMediaGridSection(key, contacts)
                }
            }
        }
    }
    
    func showMediaGridSection(_ key: Date, _ contacts: [MediaDB]) -> some View {
        LazyVGrid(
            columns: selectIndex == 0 ? columns : [GridItem(.flexible(), spacing: 1, alignment: nil)],
            alignment: .center,
            spacing: 1
        ) {
            Section(header: Text(key.toString(dateFormat: "dd MMM yyyy"))
                .font(appearance.fonts.messageListMessageText)
                .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            ) {
                ForEach(contacts) { value in
                    if value.customType == ISMChatMediaType.Video.value {
                        showVideoView(value)
                    } else if value.customType == ISMChatMediaType.Image.value {
                        showImageView(value)
                    } else if value.customType == ISMChatMediaType.File.value {
                        showFileView(value)
                    } else if value.customType == ISMChatMediaType.gif.value{
                        showGifView(value)
                    } else {
                        showPlaceholderRectangle()
                    }
                }
            }
        }
    }
    
    func showLinkViewList(msg : String) -> some View{
        ZStack{
            Color.white.cornerRadius(8)
            HStack{
                Button(action: {
                    if msg.contains("https://"){
                        if let url = URL(string: "\(msg)") {
                            openURLInSafari(url)
                        }
                    }else{
                        if let url = URL(string: "https://" + msg){
                            openURLInSafari(url)
                        }
                    }
                }) {
                    HStack(alignment: .center,spacing: 5){
                        ZStack(alignment: .center){
                            Color.backgroundView
                            appearance.images.linkLogo
                                .resizable()
                                .frame(width: 25,height: 25)
                        }
                        .frame(width: 51, height: 51, alignment: .center)
                        .cornerRadius(4)
                        .padding(5)
                        
                        Text(msg)
                            .font(appearance.fonts.messageListMessageTime)
                            .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                            .lineLimit(3)
                        
                        Spacer()
                    }
                }
            }
        }.frame(height: 60)
            .padding(.horizontal)
        
    }
    
    func openURLInSafari(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func showVideoView(_ value: MediaDB) -> some View {
        Button(action: {
            
        }, label: {
                ISMChatImageCahcingManger.networkImage(url: value.thumbnailUrl ,isprofileImage: false)
                    .resizable()
                    .scaledToFill()
                    .frame(width: ((UIScreen.main.bounds.width / 3) - 1), height: ((UIScreen.main.bounds.width / 3) - 1))
                    .clipped()
            
        })
    }
    
    func showGifView(_ value: MediaDB) -> some View {
        Button(action: {
            
        }, label: {
            let url = URL(string: (value.mediaUrl ))
            AnimatedImage(url: url)
                .resizable()
                .frame(width: ((UIScreen.main.bounds.width / 3) - 1), height: ((UIScreen.main.bounds.width / 3) - 1))
        })
    }
       
    
    
    func showImageView(_ value: MediaDB) -> some View {
        
        Button(action: {
            
        }, label: {
            ISMChatImageCahcingManger.networkImage(url: value.mediaUrl ,isprofileImage: false)
                .resizable()
                .scaledToFill()
                .frame(width: ((UIScreen.main.bounds.width / 3) - 1), height: ((UIScreen.main.bounds.width / 3) - 1))
                .clipped()
                .overlay {
                    appearance.images.playVideo
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                }
        })
    }
    
    func showFileView(_ value: MediaDB) -> some View {
        NavigationLink(
            destination: ISMDocumentViewer(url: URL(string: value.mediaUrl)!, title: "")
        ) {
            ZStack(alignment: .leading) {
                Color.white.cornerRadius(8)
                HStack(alignment: .center, spacing: 10){
                    appearance.images.pdfLogo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 32)
                        .padding(.leading, 10)
                    
                    Text(value.name)
                        .font(appearance.fonts.messageListMessageTime)
                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                        .lineLimit(3)
                    
                    Spacer()
                }
            }
            .frame(height: 60)
            .padding(.horizontal)
            .padding(.vertical,3)
        }
    }
    func showPlaceholderRectangle() -> some View {
        Rectangle()
            .frame(width: (UIScreen.main.bounds.width / 3) - 1, height: (UIScreen.main.bounds.width / 3) - 1)
    }
}
