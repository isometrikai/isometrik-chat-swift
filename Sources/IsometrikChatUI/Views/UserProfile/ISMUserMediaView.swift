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
    @State public var selectIndex = 0 // Index to track selected media type (Media, Links, Docs)
    @State public var groupMedia = [Date: [MediaDB]]() // Dictionary to group media by date
    @State public var groupLink = [Date: [MessagesDB]]() // Dictionary to group links by date
    @EnvironmentObject var realmManager: RealmManager // Environment object for managing Realm database
    
    public var viewModel = ChatsViewModel() // ViewModel for chat functionality
    public var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 1, alignment: nil), count: 3) // Grid layout for media display
    }
    @Environment(\.dismiss) var dismiss // Dismiss action for the view
    let appearance = ISMChatSdkUI.getInstance().getAppAppearance().appearance // Appearance settings
    @State var navigateToMediaSlider : Bool = false // State to control navigation to media slider
    @State var navigateToMediaSliderId : String = "" // ID of the media to navigate to
    
    //MARK: - BODY
    public var body: some View {
        ZStack {
            Color.backgroundView.edgesIgnoringSafeArea(.all) // Background color
            VStack {
                // Conditional view rendering based on selected index
                if selectIndex == 1 {
                    if groupLink.isEmpty {
                        showEmptyView() // Show empty view if no links are available
                    } else {
                        showLinkView() // Show links if available
                    }
                } else {
                    if groupMedia.isEmpty {
                        showEmptyView() // Show empty view if no media is available
                    } else {
                        showMediaGridView() // Show media grid if available
                    }
                }
                Spacer()
            }
            .onChange(of: selectIndex, { _, newValue in
                handlePickerSelection(newValue) // Handle selection change
            })
            .navigationBarItems(leading: navigationLeading()) // Navigation bar items
            .navigationBarBackButtonHidden() // Hide back button
            .navigationBarTitleDisplayMode(.inline) // Inline title display
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        // Picker for selecting media type
                        Picker("Media Picker", selection: $selectIndex) {
                            Text("Media").tag(0)
                                .font(appearance.fonts.messageListMessageText)
                                .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                            Text("Links").tag(1)
                                .font(appearance.fonts.messageListMessageText)
                                .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                            Text("Docs").tag(2)
                                .font(appearance.fonts.messageListMessageText)
                                .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                        }
                        .pickerStyle(.segmented) // Segmented picker style
                        .frame(width: 250) // Frame width for the picker
                    }
                }
            }
//            .fullScreenCover(isPresented: $navigateToMediaSlider) {
//                // Full screen cover for media viewer
//                let attachments = self.viewModelNew.medias ?? [] // Get media attachments
//                let currentMediaId = navigateToMediaSliderId // Current media ID
//                let index = attachments.firstIndex { $0.messageId == currentMediaId } ?? 0 // Find index of current media
//                ISMChatMediaViewer(viewModel: ISMChatMediaViewerViewModel(attachments: attachments, index: index)) {
//                    navigateToMediaSlider = false // Dismiss media viewer
//                }.onAppear {
//                    self.navigateToMediaSliderId = "" // Reset media ID on appear
//                }
//            }
        }
        .onAppear {
            setupGroupedMedia() // Setup grouped media on appear
        }
    }
    
    //MARK: - CONFIGURE
    // Handle selection change for media type
    func handlePickerSelection(_ selection: Int) {
        switch selection {
        case 0:
            groupMedia = groupedEpisodesByMonth(realmManager.medias ?? []) // Group media by month
        case 1:
            groupLink = groupedLinkByMonth(realmManager.linksMedia ?? []) // Group links by month
        case 2:
            groupMedia = groupedEpisodesByMonth(realmManager.filesMedia ?? []) // Group files by month
        default:
            groupMedia.removeAll() // Clear media if selection is invalid
        }
    }
    
    // Setup grouped media initially
    func setupGroupedMedia() {
        groupMedia = groupedEpisodesByMonth(realmManager.medias ?? []) // Group media by month
    }
    
    // Setup grouped links
    func setupGroupedLink() {
        groupLink = groupedLinkByMonth(realmManager.linksMedia ?? []) // Group links by month
    }
    
    // Group episodes by month
    func groupedEpisodesByMonth(_ episodes: [MediaDB]) -> [Date: [MediaDB]] {
        let empty: [Date: [MediaDB]] = [:] // Empty dictionary for grouping
        
        return episodes.reduce(into: empty) { acc, cur in
            let date1 = Date(timeIntervalSince1970: (cur.sentAt / 1000)) // Convert timestamp to date
            let components = Calendar.current.dateComponents([.year, .month, .day], from: date1) // Get date components
            let date = Calendar.current.date(from: components)! // Create date from components
            let existing = acc[date] ?? [] // Get existing media for the date
            acc[date] = existing + [cur] // Append current media to the date
        }
    }
    
    // Group links by month
    func groupedLinkByMonth(_ episodes: [MessagesDB]) -> [Date: [MessagesDB]] {
        let empty: [Date: [MessagesDB]] = [:] // Empty dictionary for grouping
        
        return episodes.reduce(into: empty) { acc, cur in
            let date1 = Date(timeIntervalSince1970: (cur.sentAt / 1000)) // Convert timestamp to date
            let components = Calendar.current.dateComponents([.year, .month, .day], from: date1) // Get date components
            let date = Calendar.current.date(from: components)! // Create date from components
            let existing = acc[date] ?? [] // Get existing links for the date
            acc[date] = existing + [cur] // Append current link to the date
        }
    }
    
    // Show empty view based on selected index
    func showEmptyView() -> some View {
        let placeholderImage: Image // Placeholder image based on selection
        
        switch selectIndex {
        case 0:
            placeholderImage = appearance.images.noMediaPlaceholder // No media placeholder
        case 1:
            placeholderImage = appearance.images.noLinkPlaceholder // No link placeholder
        case 2:
            placeholderImage = appearance.images.noDocPlaceholder // No document placeholder
        default:
            placeholderImage = appearance.images.fileFallback // Fallback placeholder
        }
        
        return VStack {
            Spacer()
            placeholderImage
                .resizable().frame(width: 206, height: 138, alignment: .center) // Placeholder image frame
            Spacer()
        }
    }
    
    // Leading navigation button
    func navigationLeading() -> some View {
        Button(action: {
            dismiss() // Dismiss the view
        }) {
            appearance.images.backButton
                .resizable()
                .frame(width: appearance.imagesSize.backButton.width, height: appearance.imagesSize.backButton.height) // Back button frame
        }
    }
    
    // Show links view
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
                            showLinkViewList(msg: message.body) // Show each link
                        }
                    }
                }
            }
        }
    }
    
    // Show media grid view
    func showMediaGridView() -> some View {
        ScrollView {
            ForEach(groupMedia.keys.sorted(), id: \.self) { key in
                if let contacts = groupMedia[key]?.filter({ contact in true }), !contacts.isEmpty {
                    showMediaGridSection(key, contacts) // Show media grid section
                }
            }
        }
    }
    
    // Show media grid section
    func showMediaGridSection(_ key: Date, _ contacts: [MediaDB]) -> some View {
        LazyVGrid(
            columns: selectIndex == 0 ? columns : [GridItem(.flexible(), spacing: 1, alignment: nil)], // Use different columns based on selection
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
                    // Show media based on custom type
                    if value.customType == ISMChatMediaType.Video.value {
                        showVideoView(value) // Show video view
                    } else if value.customType == ISMChatMediaType.Image.value {
                        showImageView(value) // Show image view
                    } else if value.customType == ISMChatMediaType.File.value {
                        showFileView(value) // Show file view
                    } else if value.customType == ISMChatMediaType.gif.value {
                        showGifView(value) // Show GIF view
                    } else {
                        showPlaceholderRectangle() // Show placeholder for unknown type
                    }
                }
            }
        }
    }
    
    // Show individual link view
    func showLinkViewList(msg: String) -> some View {
        ZStack {
            Color.white.cornerRadius(8) // Background color for link
            HStack {
                Button(action: {
                    // Open URL in Safari
                    if msg.contains("https://") {
                        if let url = URL(string: "\(msg)") {
                            openURLInSafari(url)
                        }
                    } else {
                        if let url = URL(string: "https://" + msg) {
                            openURLInSafari(url)
                        }
                    }
                }) {
                    HStack(alignment: .center, spacing: 5) {
                        ZStack(alignment: .center) {
                            Color.backgroundView // Background for link logo
                            appearance.images.linkLogo
                                .resizable()
                                .frame(width: 25, height: 25) // Link logo frame
                        }
                        .frame(width: 51, height: 51, alignment: .center)
                        .cornerRadius(4)
                        .padding(5)
                        
                        Text(msg)
                            .font(appearance.fonts.messageListMessageTime)
                            .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                            .lineLimit(3) // Limit text lines
                        
                        Spacer()
                    }
                }
            }
        }.frame(height: 60) // Frame height for link view
            .padding(.horizontal)
    }
    
    // Open URL in Safari
    func openURLInSafari(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url) // Open URL
        }
    }
    
    // Show video view
    func showVideoView(_ value: MediaDB) -> some View {
        Button(action: {
            self.navigateToMediaSliderId = value.messageId // Set media ID for navigation
            self.navigateToMediaSlider = true // Trigger navigation
        }, label: {
            ISMChatImageCahcingManger.viewImage(url: value.thumbnailUrl)
                .scaledToFill()
                .frame(width: ((UIScreen.main.bounds.width / 3) - 1), height: ((UIScreen.main.bounds.width / 3) - 1)) // Frame for video thumbnail
                .clipped()
                .overlay {
                    appearance.images.playVideo
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36) // Play button overlay
                }
        })
    }
    
    // Show GIF view
    func showGifView(_ value: MediaDB) -> some View {
        Button(action: {
            self.navigateToMediaSliderId = value.messageId // Set media ID for navigation
            self.navigateToMediaSlider = true // Trigger navigation
        }, label: {
            let url = URL(string: (value.mediaUrl)) // URL for GIF
            AnimatedImage(url: url)
                .resizable()
                .frame(width: ((UIScreen.main.bounds.width / 3) - 1), height: ((UIScreen.main.bounds.width / 3) - 1)) // Frame for GIF
        })
    }
    
    // Show image view
    func showImageView(_ value: MediaDB) -> some View {
        Button(action: {
            self.navigateToMediaSliderId = value.messageId // Set media ID for navigation
            self.navigateToMediaSlider = true // Trigger navigation
        }, label: {
            ISMChatImageCahcingManger.viewImage(url: value.mediaUrl)
                .scaledToFill()
                .frame(width: ((UIScreen.main.bounds.width / 3) - 1), height: ((UIScreen.main.bounds.width / 3) - 1)) // Frame for image
                .clipped()
        })
    }
    
    // Show file view
    func showFileView(_ value: MediaDB) -> some View {
        NavigationLink(
            destination: ISMDocumentViewer(url: value.mediaUrl) // Navigate to document viewer
        ) {
            ZStack(alignment: .leading) {
                Color.white.cornerRadius(8) // Background color for file
                HStack(alignment: .center, spacing: 10) {
                    appearance.images.pdfLogo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 32) // PDF logo frame
                        .padding(.leading, 10)
                    
                    Text(value.name)
                        .font(appearance.fonts.messageListMessageTime)
                        .foregroundColor(appearance.colorPalette.messageListHeaderTitle)
                        .lineLimit(3) // Limit text lines
                        
                    Spacer()
                }
            }
            .frame(height: 60) // Frame height for file view
            .padding(.horizontal)
            .padding(.vertical, 3)
        }
    }
    
    // Show placeholder rectangle for unknown media types
    func showPlaceholderRectangle() -> some View {
        Rectangle()
            .frame(width: (UIScreen.main.bounds.width / 3) - 1, height: (UIScreen.main.bounds.width / 3) - 1) // Placeholder frame
    }
}
